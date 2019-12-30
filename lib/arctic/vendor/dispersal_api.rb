require_relative 'api'

module Arctic
  module Vendor
    module Dispersal
      class API < Arctic::Vendor::API
        PRODUCTS_LIST_MAX = 25_000

        # Lists products for dispersal
        def list_products(shop_id, max_items=nil, **params, &block)
          url = "shops/#{shop_id}/products"

          products = []
          while products.size < (max_items.present? ? max_items : PRODUCTS_LIST_MAX) do
            collected_products = request(:get, url, params: params.merge(with_state_update: true)).body

            break if collected_products.empty?

            collected_at = Time.current

            collected_products.map! { |collected_product| collected_product.merge! 'collected_at' => collected_at }

            yield collected_products if block_given?

            products.concat collected_products
          end

          products
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

        def update_products_dispersals(shop_id, **body)
          request :patch, "shops/#{shop_id}/products/dispersals", body: body
        end
      end
    end
  end
end
