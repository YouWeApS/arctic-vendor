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

        # Mark a product's state
        #
        # States:
        #  * distributed: This will exclude it from redistribution by the vendor until the
        #    product has changed in some way.
        #  * inprogress: The product is currently being distributed
        def update_product_state(shop_id, sku, state)
          request :patch, "shops/#{shop_id}/products/#{sku}", body: {
            state: state,
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
          request :post, "shops/#{shop_id}/orders", body: order
        end

        # Collected invoice for a specific order
        # An order can have multiple invoices, so this endpoint can be called
        # multiple times.
        def collect_invoice(shop_id, order_id, invoice)
          request :post, "shops/#{shop_id}/orders/#{order_id}/invoices", body: invoice
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
        #   api.completed_dispersal(1)
        #
        #   # completing orders collection
        #   api.completed_dispersal(1, :orders)
        def completed_dispersal(shop_id, routine = :products)
          request :patch, "shops/#{shop_id}/#{routine}_synced"
        end
      end
    end
  end
end
