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
          create_order_error(
            shop_id, order_id,
            error_type: 'export',
            severity: 'error',
            message: error.message.force_encoding('UTF-8'),
            details: error.full_message.force_encoding('UTF-8')
          )
        end

        def create_product_category shop_id:, category:
          request :post, "shops/#{shop_id}/products/collection_vendor_categories", body: category
        end
      end
    end
  end
end
