module Arctic
  module Vendor
    class Product
      attr_reader :id, :characteristics, :api, :account_id, :shop_id

      def initialize(account_id, shop_id, product_hash, api_instance)
        @api = api_instance

        @shop_id = shop_id
        @account_id = account_id

        @id = product_hash.fetch 'id'
        @characteristics = product_hash.fetch 'characteristics'
      end

      def update_state(state)
        api.update_product_state account_id, shop_id, id, state
      end
    end
  end
end
