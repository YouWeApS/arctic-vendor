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

    def each_shop(type = :collection)
      api.list_shops.with_indifferent_access[type].each do |shop|
        yield shop
      end
    end
    module_function :each_shop

    def collect_currencies(&block)
      Arctic.logger.info "Collecting currencies from collection shop"

      currencies_count = 0

      seconds = time do
        each_shop(:collection) do |shop|
          currencies = api.send_currencies shop['id'], yield(shop)
          currencies_count += currencies.size
        end
      end

      Arctic.logger.info "Collected #{currencies_count} exchange rates in #{seconds} seconds."
    end
    module_function :collect_currencies

    def api(*args)
      @api ||= Arctic::Vendor::API.new(*args)
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
      Arctic.logger.info "Collecting products from vendor..."
      products_count = 0

      seconds = time do
        each_shop(:collection) do |shop|
          products = api.send_products shop['id'], yield(shop)
          products_count += products.size
        end
      end

      Arctic.logger.info "Collected #{products_count} products in #{seconds} seconds"
    end
    module_function :collect_products

    # Fetches all products from the Core API and distributes them to the
    # target vendors
    def distribute_products(**params)
      Arctic.logger.info "Distributing products to target vendor..."
      products_count = 0

      params.reverse_merge! \
        batch_size: 100

      seconds = time do
        each_shop(:dispersal) do |shop|
          api.list_products(shop['id'], params) do |products|
            products_count += products.size
            yield shop, products
            # api.update_products shop['id'], products, dispersed_at: Time.now.to_s(:db)
          end
        end
      end

      Arctic.logger.info "Distributed #{products_count} products in #{seconds} seconds"
    end
    module_function :distribute_products
  end
end
