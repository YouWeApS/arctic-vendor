require 'faraday'
require 'json'
require 'active_support/all'

require_relative 'product'

module Arctic
  module Vendor
    class API
      attr_reader :vendor_id, :token, :connection

      def initialize(**options)
        @vendor_id = options.fetch(:vendor_id, ENV.fetch('VENDOR_ID'))

        @token = options.fetch(:token, ENV.fetch('ARCTIC_CORE_API_TOKEN'))

        api_url = options.fetch(:url,
          ENV.fetch('ARCTIC_CORE_API_URL',
            'http://localhost:5000/v1/vendors'))

        headers = {
          'Content-Type': 'application/json',
          Accept: 'application/json',
        }

        @connection = Faraday.new url: api_url.chomp('/'), headers: headers do |conn|
          conn.basic_auth(vendor_id, token)
          conn.adapter Faraday.default_adapter
        end
      end

      # List shops for a single account
      def list_shops
        make_request :get, "shops"
      end

      # Send products to the Core API
      def send_products(shop_id, products)
        Arctic::Vendor.threaded(products) do |prod|
          make_request :post, "shops/#{shop_id}/products", params: prod
        end
      end

      # Retrieve products from the Core API
      def list_products(shop_id, **params)
        params[:per_page] = params.delete(:batch_size) || 100
        make_paginated_request(:get, "shops/#{shop_id}/products", params: params) do |products|
          yield products.collect { |prod| Arctic::Vendor::Product.new shop_id, prod, self }
        end
      end

      # Marks the shop as synchronized by the vendor
      def update_product(shop_id, sku, **params)
        make_request :patch, "shops/#{shop_id}/products/#{sku}", params: params
      end

      def update_products(shop_id, products, **params)
        Arctic::Vendor.threaded(products) do |prod|
          update_product shop_id, prod.fetch('sku'), **params
        end
      end

      private

        def raw_request(method, path, body: {}, params: {})
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
        end

        def make_request(method, path, body: {}, params: {})
          response = raw_request method, path, body: body, params: params

          json = begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            {}
          end

          raise json['error'] if json.is_a?(Hash) && json['error']

          Arctic.logger.info "#{method.to_s.upcase} #{path}?#{params.to_query}: #{response.status}"

          json
        end

        def make_paginated_request(method, path, body: {}, params: {})
          response = raw_request :head, path, body: body, params: params
          Arctic.logger.debug "Pagination response headers: #{response.headers}"

          page = response.headers['page'] || 1
          per_page = response.headers['per-page'] || 1
          total_record = response.headers['total'] || 1
          pages = (total_record.to_f / per_page.to_f).ceil
          collection = (1..pages).to_a

          Arctic::Vendor.threaded collection do |n|
            params = params.merge page: n
            yield make_request method, path, body: body, params: params
          end
        end
    end
  end
end
