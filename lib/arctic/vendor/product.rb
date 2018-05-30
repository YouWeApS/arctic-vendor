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
        :id,
        :characteristics,
        :api,
        :account_id,
        :shop_id,
        :state,
        :master

      def initialize(account_id, shop_id, product_hash, api_instance)
        @api = api_instance

        @shop_id = shop_id
        @account_id = account_id

        @id = product_hash.fetch 'id'
        @characteristics = Characteristics.new product_hash.fetch 'characteristics'

        @state = product_hash.fetch 'state'
        @master = product_hash.fetch 'master'
      end

      def update_state(state)
        api.update_product_state account_id, shop_id, id, state
      end
    end
  end
end
