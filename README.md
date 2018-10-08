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

## Logger

To change the logging mechanism simply override the standard STDOUT logging.

```ruby
require 'arctic/vendor'
logger = Logger.new 'file.log'
logger.formatter = Ruby::JSONFormatter::Base.new \
  ENV.fetch('HOST'),
  source: :your_application
Arctic.logger = logger
```

### Validation API

Each vendor should implement a validation API, which the Core API can use to
ensure that a product is valid for the given vendor before sending the product
to the vendor, and to allow the user to quickly see if his changes to the
product has made it invalid for this vendor.

Your implementation should have a validation class taking two arguments, a
`product` json object and an `options` hash.

You should then add this to your code somewhere:

```ruby
Arctic.validator_class = 'YourValidatorClass'
```

And then you should ensure that you expose the validation API somewhere
publically available. This is most easily done using a `config.ru` file with
the `rackup` command.

```ruby
# config.ru
run Arctic::ValidationApi
```

## Testing

Run all the tests:

```bash
rake test
```
