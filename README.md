# Arctic vendor

This gem is the backbone used for communication from Vendors to the Core API.

## Usage

Install the gem:

```ruby
gem 'arctic-vendor'
```

Then in your code:

```ruby
require 'bundler/setup'
require 'arctic/vendor'

module Arctic
  module Vendor
    module Dandomain # <-- Change this depending on the vendor you're using
      def collect_products
        Arctic::Vendor.collect_products do |shop|
          # Retrieve products from the shop and return them to the block
        end
      end
      module_function :collect_products

      def distribute_products
        Arctic::Vendor.distribute_products do |shop, products|
          # Send the products to the shop and return the products to the block
        end
      end
      module_function :distribute_products
    end
  end
end
```

Then in your Rakefile:

```ruby
require_relative "./path/to/your/lib"

desc "Sync"
task :sync do
  # You can skip either of these if the vendor doesn't support either pulling or
  # pushing products and orders.
  Arctic::Vendor::Dandomain.collect_products
  Arctic::Vendor::Dandomain.distribute_products
end
```

## Testing

Run all the tests:

```bash
rake test
```
