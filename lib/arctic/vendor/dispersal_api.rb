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

          begin
            retries ||= 0

            products = []
            paginated_request(:get, url, options) do |response|
              yield response.body if block_given?
              products.concat response.body
            end
          rescue TypeError # caused by 400 error from Core, which is causing response.body to be Hash
                           # 400 is caused by Pagy::OutOfRangeError, which is raised if number of pages changes during
                           # requests so you could request non existing page
            retry if (retries += 1) < 3
            products = []
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
          request :patch, "shops/#{shop_id}/products/#{encode(sku)}", body: {
            state: state,
          }
        end

        # Report an error with a specific product.
        # This can be used to report feedback fom the marketplace after
        # attempting distribution.
        def report_error(shop_id, sku, error)
          request :post, "shops/#{shop_id}/products/#{encode(sku)}/errors", body: error
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

        def encode(text)
          result = URI.encode(text).gsub '/', '%2F'
          replacements = [ [' ', "%20"], ["(", "%28"], [")", "%29"], ["|", "%7C"], [".", "%2e"] ]
          replacements.each {|replacement| result.gsub!(replacement[0], replacement[1])}
          result
        end

        #Collect errors from wrong Order import/expot
        def order_error(shop_id, order_id, error)
          request :post, "shops/#{shop_id}/orders/#{order_id}/errors", body: {
              shop_id:shop_id,
              order_id: order_id,
              error_type: 'import',
              severity: 'error',
              message: error.message,
              details: error.full_message
          }
        end

        def update_products_dispersals(shop_id, product_skus, state)
          request :patch, "shops/#{shop_id}/products/dispersals", body: {
            product_skus: product_skus,
            state: state,
          }
        end
      end
    end
  end
end
