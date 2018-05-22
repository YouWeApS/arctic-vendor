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

## Testing

Run all the tests:

```bash
rake test
```
