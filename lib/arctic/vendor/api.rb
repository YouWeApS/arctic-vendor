require 'faraday'
require 'json'
require 'active_support/all'

require_relative 'product'

module Arctic
  module Vendor
    class API
      attr_reader :token, :connection

      def initialize(**options)
        api_token = options.fetch(:token, ENV.fetch('ARCTIC_CORE_API_TOKEN'))
        api_url = options.fetch(:url,
          ENV.fetch('ARCTIC_CORE_API_URL',
            'http://localhost:5000/v1/vendors'))

        @token = api_token
        headers = {
          Authorization: "Vendor #{token}",
          'Content-Type': 'application/json',
          Accept: 'application/json',
        }
        @connection = Faraday.new url: api_url.chomp('/'), headers: headers
      end

      # List the current accounts available to the vendor
      def list_accounts
        make_request :get, 'accounts'
      end

      # Show details about a single account
      def show_account(account_id)
        make_request :get, "accounts/#{account_id}"
      end

      # List shops for a single account
      def list_shops(account_id)
        make_request :get, "accounts/#{account_id}/shops"
      end

      # Send products to the Core API
      def send_products(account_id, shop_id, products)
        products.tap do |px|
          make_batch_request :post, "accounts/#{account_id}/shops/#{shop_id}/products", body: px
        end
      end

      # Retrieve products from the Core API
      def list_products(account_id, shop_id)
        products = make_request :get, "accounts/#{account_id}/shops/#{shop_id}/products"
        products.collect { |prod| Arctic::Vendor::Product.new account_id, shop_id, prod, self }
      end

      # Marks the shop as synchronized by the vendor
      def synchronized(account_id, shop_id)
        make_request :put, "accounts/#{account_id}/shops/#{shop_id}/synchronized"
      end

      # Marks the shop as synchronized by the vendor
      def update_product_state(account_id, shop_id, product_id, state)
        make_request :put, "accounts/#{account_id}/shops/#{shop_id}/products/#{product_id}/state/#{state}"
      end

      private

        def make_batch_request(*args, **options)
          batches = Array(options.delete(:body)).flatten.in_groups_of(1000, false)
          Arctic::Vendor.threaded(batches) { |batch| make_request *args, **(options.merge(body: batch)) }
        end

        def make_request(method, path, body: {}, params: {})
          # Remove preceeding slash to avoid going from base url /v1 to /
          path = path.reverse.chomp('/').reverse

          response = connection.public_send(method, path) do |r|
            if params.any?
              params.each do |k, v|
                r.params[k.to_s] = v
              end
            end

            r.body = body.to_json if body.any?
          end

          json = begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            {}
          end

          raise json['error'] if json.is_a?(Hash) && json['error']

          Arctic.logger.info "#{method.to_s.upcase} #{path}: #{response.status}"

          json
        end
    end
  end
end
