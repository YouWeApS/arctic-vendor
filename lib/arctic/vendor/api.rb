require 'active_support/all'
require "faraday"
require 'typhoeus/adapters/faraday'
require 'faraday_middleware'

module Arctic
  module Vendor
    class API
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
          conn.response :json
          conn.adapter :typhoeus
        end
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

      private

        # Make a single request and return the response object
        def request(method, endpoint, **options)
          response = connection.public_send method, endpoint do |r|
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
