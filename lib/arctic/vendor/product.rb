module Arctic
  module Vendor
    class Product
      class Characteristics
        def initialize(characteristics)
          @characteristics = characteristics
        end

        def method_missing(name, *args)
          @characteristics[name.to_s]
        end
      end

      attr_reader \
        :product_hash,
        :sku,
        :characteristics,
        :api,
        :account_id,
        :shop_id

      def initialize(account_id, shop_id, product_hash, api_instance)
        @product_hash = product_hash

        @api = api_instance

        @shop_id = shop_id
        @account_id = account_id

        @sku = product_hash.fetch 'sku'
        @characteristics = Characteristics.new product_hash.fetch 'characteristics'
      end

      def update_state(state)
        api.update_product_state account_id, shop_id, sku, state
      end

      def method_missing(name, *args)
        if product_hash.stringify_keys.keys.include? name.to_s
          product_hash.stringify_keys[name.to_s]
        else
          super name, *args
        end
      end
    end
  end
end
