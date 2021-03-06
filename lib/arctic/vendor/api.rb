require 'active_support/all'
require 'faraday'
require 'typhoeus/adapters/faraday'
require 'faraday_middleware'

module Arctic
  module Vendor
    class API
      FAILED_REQUEST_RETRY_COUNT = 5

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
          conn.response :raise_error
          conn.adapter :typhoeus
        end
      end

      def create_product(shop_id, product)
        response = request :post, "shops/#{shop_id}/products", body: product

        raise InvalidResponse, response.status unless response.success?

        response
      end

      def create_financial_event(shop_id, event)
        response = request :post, "shops/#{shop_id}/financial_events", body: event

        raise InvalidResponse, response.status unless response.success?

        response.body
      end

      def get_financial_events(shop_id, params={})
        if params[:dispersal_vendor].present?
          response = request(:get, "shops/#{shop_id}/financial_events", params: params)

          raise InvalidResponse, response.status unless response.success?

          financial_events_data = response.body
        else
          financial_events = []

          paginated_request(:get, "shops/#{shop_id}/financial_events", params: params) do |response|
            raise InvalidResponse, response.status unless response.success?

            response.body.each { |financial_event| yield financial_event } if block_given?

            financial_events.concat(response.body)
          end

          financial_events_data = financial_events
        end

        financial_events_data
      end

      def update_financial_events(shop_id, data)
        request :patch, "shops/#{shop_id}/financial_events", body: data
      end

      def delete_financial_events(shop_id, params={})
        response = request :delete, "shops/#{shop_id}/financial_events", params: params

        raise InvalidResponse, response.status unless response.success?

        response.body
      end

      def get_financial_report(shop_id, report_id)
        response = request :get, "shops/#{shop_id}/financial_reports/#{report_id}"

        response.success? ? response.body : nil
      end

      def create_financial_report(shop_id, report_data)
        response = request :post, "shops/#{shop_id}/financial_reports", body: report_data

        raise InvalidResponse, response.status unless response.success?

        response.body
      end

      def update_financial_report(shop_id, report_id, data)
        response = request :patch, "shops/#{shop_id}/financial_reports/#{report_id}", body: data

        raise InvalidResponse, response.status unless response.success?
      end

      def ready_for_update_products(shop_id)
        paginated_request(:get, "shops/#{shop_id}/products/update_scheduled") do |response|
          response.body.each { |product| yield product }
        end
      end

      def remove_scheduled_update(shop_id, sku)
        response = request :patch, "shops/#{shop_id}/products/update_scheduled", body: { sku: sku }
        response.body
      end

      def update_product_stock(shop_id, product, data)
        request :patch, "shops/#{shop_id}/products/#{product}/change_stock", body: data
      end

      def list_shops(type = :dispersal, **params, &block)
        all_shops = []

        paginated_request(:get, 'shops', params: params.merge(type: type)) do |response|
          shops = response.body

          shops.each { |shop| yield shop } if block_given?

          all_shops.concat shops
        end

        all_shops
      end

      def get_shop(id)
        shop_response = request(:get, "shops/#{id}")

        return if shop_response.body['error'].present?

        shop_response.body
      end

      def get_vendor_shop_configuration(shop_id)
        request(:get, "shops/#{shop_id}/vendor_shop_configuration").body
      end

      def get_shipping_mappings_for_shop(id)
        request(:get, "shops/#{id}").body.dig('shipping_mappings')
      end

      def get_product(shop_id, sku)
        request(:get, "shops/#{shop_id}/products/#{encode(sku)}").body
      end

      def delete_product(shop_id, sku)
        request(:delete, "shops/#{shop_id}/products/#{encode(sku)}")
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
        raise ArgumentError, 'order_id must be present' unless order_id.present?

        request :get, "shops/#{shop_id}/orders/#{order_id}"
      end

      def orders(shop_id, **params)
        all_orders = []

        options = { params: params }

        paginated_request(:get, "shops/#{shop_id}/orders", options) do |response|
          response_orders = response.body || []

          response_orders.each { |order| yield order } if block_given?

          all_orders.concat response_orders
        end

        all_orders
      end

      # Creates an order error
      #
      # @param [String] shop_id the shop ID
      # @param [String] order_id the order ID
      # @param [String] error_type enum: ['import', 'export', 'shipment_confirm']
      # @param [String] message the error message
      # @param [String] severity enum: ['error', 'warning']
      # @param [String] details the error details
      # @return [Faraday::Response]
      def create_order_error(shop_id, order_id, error_type:, message:, severity: 'error', details: nil)
        request :post, "shops/#{shop_id}/orders/#{order_id}/errors", body: {
          error_type: error_type,
          severity: severity,
          message: message,
          details: details
        }
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
      #   api.synced(1, :products)
      #
      #   # completing orders collection
      #   api.synced(1, :orders)
      def synced(shop_id:, routine:, time: nil)
        request :patch, "shops/#{shop_id}/#{routine}_synced", body: { last_synced_at: time }
      end

      def encode(text)
        result = URI.encode(text).gsub '/', '%2F'

        replacements = [ [' ', "%20"], ["(", "%28"], [")", "%29"], ["|", "%7C"], [".", "%2e"] ]

        replacements.each { |replacement| result.gsub!(replacement[0], replacement[1]) }

        result
      end

      private
        # Make a single request and return the response object
        def request(method, endpoint, **options)
          retries ||= 0

          connection.public_send method, endpoint do |r|
            options.fetch(:params, {}).each { |k, v| r.params[k] = v }
            r.body = options[:body].to_json if options[:body]
          end
        rescue Faraday::ClientError, Faraday::ServerError, Faraday::ConnectionFailed => e
          if e.is_a?(Faraday::ClientError) || (e.is_a?(Faraday::ServerError) && e.response[:status] == 500)
            response_body = JSON.parse(e.response[:body]) rescue e.response[:body]

            return Faraday::Response.new \
              status: e.response[:status], body: response_body, response_headers: e.response[:headers]
          end

          if (retries += 1) <= FAILED_REQUEST_RETRY_COUNT
            sleep 60 # 1 min
            retry
          else
            raise e
          end
        end

        # Calls the API, and traverses the pagination and yields each resulting
        # response
        def paginated_request(*args, **options, &block)
          initial_response = request *args, **options
          yield initial_response

          max_items = options[:max_items]
          total = begin
            raise('Missing "Total" header value') unless initial_response.headers['Total'].present?

            initial_response.headers['Total'].to_i
          end
          per_page = begin
            raise('Missing "Per-Page" header value') unless initial_response.headers['Per-Page'].present?

            initial_response.headers['Per-Page'].to_i
          end

          pages = \
            if max_items.present? && total > max_items
              (max_items / per_page.to_f).ceil
            else
              (total / per_page.to_f).ceil
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
