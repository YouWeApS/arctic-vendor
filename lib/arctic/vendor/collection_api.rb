require_relative 'api'

module Arctic
  module Vendor
    module Collection
      class API < Arctic::Vendor::API
        Error = Class.new StandardError
        InvalidResponse = Class.new Error

        # Collect orders from the Core API and updates them on the marketplace
        def collect_orders(shop_id)
          url = "shops/#{shop_id}/orders"

          options = {
            params: {
              since: last_synced_at(shop_id, :orders),
            },
          }

          orders = []

          paginated_request(:get, url, options) do |response|
            yield response.body if block_given?
            orders.concat response.body
          end

          orders
        end

        def order_error(shop_id, order_id, error)
          request :post, "shops/#{shop_id}/orders/#{order_id}/errors", body: {
            shop_id:shop_id,
            order_id: order_id,
            error_type: 'export',
            severity: 'error',
            message: error.message,
            details: error.full_message
          }
        end
      end
    end
  end
end
