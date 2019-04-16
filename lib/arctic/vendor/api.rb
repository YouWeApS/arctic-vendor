require 'active_support/all'
require "faraday"
require 'typhoeus/adapters/faraday'
require 'faraday_middleware'

module Arctic
  module Vendor
    class API
      Error = Class.new StandardError
      InvalidResponse = Class.new Error

      attr_reader :connection

      def initialize(**options)
        vendor_id = options.fetch(:vendor_id) { ENV.fetch('VENDOR_ID') }
        vendor_token = options.fetch(:vendor_token) { ENV.fetch('VENDOR_TOKEN') }

        api_url = options.fetch :url,
          ENV.fetch('ARCTIC_CORE_API_URL') { 'http://localhost:5000/v1/vendors' }

        headers = {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          'User-Agent': 'Arctic-Vendor v1.0',
        }

        parallel_manager = Typhoeus::Hydra.new \
          max_concurrency: 10 # default is 200

        options = {
          url: api_url.chomp('/'),
          headers: headers,
          parallel_manager: parallel_manager,
        }

        @connection = Faraday.new options do |conn|
          conn.basic_auth(vendor_id, vendor_token)
          conn.response :detailed_logger, Arctic.logger
          conn.response :json
          conn.adapter :typhoeus
        end
      end

      def create_product(shop_id, product)
        response = request :post, "shops/#{shop_id}/products", body: product
        raise InvalidResponse, response.status unless response.success?
        response
      end

      def ready_for_update_products(shop_id)
        response = request :get, "shops/#{shop_id}/products/update_scheduled"
        response.body
      end

      def list_shops(type = :dispersal, &block)
        all_shops = []

        paginated_request(:get, 'shops') do |response|
          shops = response.body[type.to_s]
          shops.each { |s| yield s } if block_given?
          all_shops.concat shops
        end

        all_shops
      end

      def get_shop(id)
        request(:get, "shops/#{id}").body
      end

      def get_shipping_mappings_for_shop(id)
        request(:get, "shops/#{id}").body.dig('shipping_mappings')
      end

      def update_order(shop_id, order_data)
        id = order_data.as_json.fetch 'id'
        request :patch, "shops/#{shop_id}/orders/#{id}", body: order_data
      end

      def update_order_line(shop_id, order_id, order_line_id, data)
        request :patch, "shops/#{shop_id}/orders/#{order_id}/order_lines/#{order_line_id}", body: data
      end

      def create_order(shop_id, order_data)
        request :post, "shops/#{shop_id}/orders", body: order_data.as_json
      end

      def lookup_order(shop_id, order_id)
        request :get, "shops/#{shop_id}/orders/#{order_id}"
      end

      def orders(shop_id, since: nil)
        all_orders = []
        options = {
          params: {
            since: since,
          },
        }

        paginated_request(:get, "shops/#{shop_id}/orders", options) do |response|
          all_orders.concat response.body || []
        end

        all_orders
      end

      # Calls the Core API and queries when this vendor last ran the given
      # sync routine
      def last_synced_at(shop_id, routine)
        response = request :get, "shops/#{shop_id}/#{routine}/last_synced_at"
        response.body['last_synced_at']
      end

      # Notifies the Core API that the vendor has completed its dispersal
      # process for a specific type.
      #
      # Examples:
      #
      #   api = Arctic::Vendor::Dispersal::API.new
      #
      #   # completing products dispersal
      #   api.synced(1)
      #
      #   # completing orders collection
      #   api.synced(1, :orders)
      def synced(shop_id, routine)
        request :patch, "shops/#{shop_id}/#{routine}_synced"
      end

      private

        # Make a single request and return the response object
        def request(method, endpoint, **options)
          Arctic.logger.info "#{method.to_s.upcase} #{endpoint}: #{options.to_json}"
          connection.public_send method, endpoint do |r|
            options.fetch(:params, {}).each { |k, v| r.params[k] = v }
            r.body = options[:body].to_json if options[:body]
          end
        end

        # Calls the API, and traverses the pagination and yields each resulting
        # response
        def paginated_request(*args, **options, &block)
          initial_response = request *args, **options
          yield initial_response

          # Calculate pages
          total = initial_response.headers['Total'].to_i
          per_page = initial_response.headers['Per-Page'].to_i
          pages = begin
            (total.to_f / per_page.to_f).ceil
          rescue FloatDomainError
            0
          end

          # Ignoring first page because that was the initial response
          (2..pages).each do |page|
            options[:params] ||= {}
            options[:params][:page] = page
            yield request *args, **options
          end
        end
    end
  end
end
