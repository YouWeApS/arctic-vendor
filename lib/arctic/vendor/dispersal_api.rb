require 'active_support/time'

require_relative 'api'

module Arctic
  module Vendor
    module Dispersal
      class API < Arctic::Vendor::API
        # Lists products for dispersal
        def list_products(shop_id, **params, &block)
          url = "shops/#{shop_id}/products"

          options = {
            params: params,
          }

          products = []

          paginated_request(:get, url, options) do |response|
            yield response.body if block_given?
            products.concat response.body
          end

          products
        end

        # Mark a product as having been distributed.
        # This will exclude it from redistribution by the vendor until the
        # product has changed in some way.
        def mark_as_distributed(shop_id, sku)
          request :patch, "shops/#{shop_id}/products/#{sku}", body: {
            dispersed_at: Time.now.to_s(:db),
          }
        end

        # Report an error with a specific product.
        # This can be used to report feedback fom the marketplace after
        # attempting distribution.
        def report_error(shop_id, sku, error)
          request :post, "shops/#{shop_id}/products/#{sku}/errors", body: error
        end
      end
    end
  end
end
