module Arctic
  module Vendor
    MAX_THREADS = ENV.fetch('MAX_THREADS', 4).to_s.to_i.freeze

    def threaded(collection, &block)
      threads = Arctic::Vendor::MAX_THREADS.times.collect do
        Thread.new do
          while item = collection.pop do
            yield item
          end
        end
      end
      threads.compact.map &:join
    end
    module_function :threaded

    def each_shop(type: :source)
      api.list_accounts.each do |account|
        api.list_shops(account['id']).each do |shop|
          yield shop, account if shop['type'] == type.to_s
        end
      end
    end
    module_function :each_shop

    def api
      @api ||= Arctic::Vendor::API.new
    end
    module_function :api

    def time
      t1 = Time.now.to_f
      yield
      Time.now.to_f - t1
    end
    module_function :time

    # Fetches all products from all shops, where this vendor is the source
    # vendor and pushes them to the Core API.
    def collect_products(&block)
      Arctic.logger.info "Collecting products from source vendor..."
      products_count = 0

      seconds = time do
        each_shop do |shop, account|
          products = api.send_products account['id'], shop['id'], yield(shop)
          products_count += products.size
        end
      end

      Arctic.logger.info "Collected #{products_count} products in #{seconds} seconds"
    end
    module_function :collect_products

    # Fetches all products from the Core API and distributes them to the
    # target vendors
    def distribute_products
      Arctic.logger.info "Distributing products to target vendor..."
      products_count = 0

      seconds = time do
        each_shop(type: :target) do |shop, account|
          products = api.list_products account['id'], shop['id']
          products_count += products.size
          yield shop, products
        end
      end

      Arctic.logger.info "Distributed #{products_count} products in #{seconds} seconds"
    end
    module_function :distribute_products
  end
end
