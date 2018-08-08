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

        # Dispersal vendors collect orders for the collection vendor. So orders
        # generally flow in the opposite direction of products.
        # If the order
        def collect_order(shop_id, order)
          id = order.with_indifferent_access.fetch :id
          request :put, "shops/#{shop_id}/orders/#{id}", body: order
        end

        # Update the state of the product in this vendor
        def update_product_state(shop_id, sku, state)
          request :patch, "shops/#{shop_id}/products/#{sku}/queues", body: {
            state: state,
          }
        end
      end
    end
  end
end
