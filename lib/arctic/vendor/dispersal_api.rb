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
          request(:post, "shops/#{shop_id}/orders", body: order).tap do |response|
            raise InvalidResponse, response.body unless response.status == 201
          end
        end

        # Collected invoice for a specific order
        # An order can have multiple invoices, so this endpoint can be called
        # multiple times.
        def collect_invoice(shop_id, order_id, invoice)
          request(:post, "shops/#{shop_id}/orders/#{order_id}/invoices", body: invoice).tap do |response|
            raise InvalidResponse, response.body unless response.status == 201
          end
        end

        # Attach collected order lines to orders
        def collect_order_line(shop_id, order_id, order_line)
          request(:post, "shops/#{shop_id}/orders/#{order_id}/order_lines", body: order_line).tap do |response|
            raise InvalidResponse, response.body unless response.status == 201
          end
        end
      end
    end
  end
end
