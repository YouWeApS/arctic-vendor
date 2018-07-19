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
        :shop_id

      def initialize(shop_id, product_hash, api_instance)
        @product_hash = product_hash

        @api = api_instance

        @shop_id = shop_id

        @sku = product_hash.fetch 'sku'
        @characteristics = Characteristics.new product_hash.fetch 'characteristics'
      end

      def update(**params)
        api.update_product shop_id, sku, **params
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
