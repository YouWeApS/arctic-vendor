---
title: API Reference

language_tabs: # must be one of https://git.io/vQNgJ
  - ruby
  - python
  - php

toc_footers:
  - <a href='#'>Sign Up for a Developer Key</a>
  - <a href='https://github.com/lord/slate'>Documentation Powered by Slate</a>

includes:
  - errors

search: true
---

# Introduction

The Arctic Vendor project is a wrapper around the [Arcic Core API](https://arctic-project.io).

An Arctic Vendor is an application that connects a marketplace to the Arctic platform.

This project looks to simplify setting up these vendors and thus simplifying the onboarding of new marketplaces for the merchangs on the Arctic platform.

An Arctic Vendor has two aspects to it: Collection and distribution.

# Installation

> To install in your project

```ruby
gem 'arctic-vendor', '~> 2.2'
```

```php
/*
   # composer.json
   {
     "require": {
       "vendor/arctic-vendor": "^2.2"
     }
   }

   curl -sS https://getcomposer.org/installer | php

   php composer.phar install
*/
require 'vendor/autoload.php';
```

```python
pip install arctic-vendor
```

The Arctic Vendor is available on several different, popular distribution
platforms including python, [ruby](https://rubygems.org/gems/arctic-vendor), and
php,or you can download the [ruby source](https://github.com/YouWeApS/arctic-vendor).

# Setup

In order to connect to the Arctici Core API, you need to have a Vendor Token,
and you need to store this token in the `ARCTIC_CORE_API_TOKEN` environment
variable.

If you need to run your application against another environment you can override
the URL by setting the `ARCTIC_CORE_API_URL` environment variable.

# Collecting products

> Collect products from the marketplace

```ruby
Arctic::Vendor.collect_products do |shop|
  # Connect to the marketplace and retrieve the products for the shop
end
```

First, initialize the `Vendor.collect_products` method to receive each of the
shops that your vendor should process.

Then retrieve the products for that shop, and return them to the block, and the
Vendor Project will send them to the Core API.

# Distributing products

> Distribute products to the marketplace

```ruby
Arctic::Vendor.distribute_products do |shop, products|
  # Connect to the marketplace and publish the products to the shop
end
```

First, initialize the `Vendor.distribute_products` method to receive each of the
shops and related products to distribute to the marketplace.

Then connect to the marketplace and distribute the products to the shop.
