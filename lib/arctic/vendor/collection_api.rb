require_relative 'api'

module Arctic
  module Vendor
    module Collection
      class API < Arctic::Vendor::API
        def order_dispersed( shop_id, order_id)
          request :patch, "shops/#{shop_id}/orders/#{order_id}/dispersed", body: {
            shop_id:shop_id,
            order_id: order_id
          }
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

        def create_product_category shop_id:, category:
          request :post, "shops/#{shop_id}/products/collection_vendor_categories", body: category
        end
      end
    end
  end
end
