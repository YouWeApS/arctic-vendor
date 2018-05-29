---
title: API Reference

language_tabs: # must be one of https://git.io/vQNgJ
  - ruby

toc_footers:
  - <a href='https://arctic-project.dk/vendor/register' target="_blank">Register a Vendor</a>
  - <a href='https://arctic-project.io' target="_blank">Core API documentation</a>
  - <a href='https://github.com/YouWeApS/arctic-vendor/issues' target="_blank">Found a bug?</a>

includes:
  - errors

search: true
---

# Introduction

The Arctic Vendor project is a wrapper around the [Arcic Core API](https://arctic-project.io).

An Arctic Vendor is an application that connects a marketplace to the Arctic platform.

This project looks to simplify setting up these vendors and thus simplifying the onboarding of new marketplaces for the merchangs on the Arctic platform.

An Arctic Vendor has two aspects to it: Collection and distribution.

**Collecting products** means tranforming (possibly) unstructured product data
from the marketplace into structured data.

**Distributing products** means sending structured products onto the connected
marketplace.

# Setup

> To install in your project

```ruby
gem 'arctic-vendor', '~> 2.2'
```

First you must [register your Vendor](https://arctic-project.dk/vendor/register)
with the Core API to obtain a Vendor Token.

In order to connect to the Arctici Core API, you need to have a Vendor Token,
and you need to store this token in the `ARCTIC_CORE_API_TOKEN` environment
variable.

If you need to run your application against another environment you can override
the URL by setting the `ARCTIC_CORE_API_URL` environment variable.

# Object descriptions

### Shop

A single object.

Parameter | Description
--------- | -----------
id | Shop ID
name | Human friendly shop name
synced_at | [ISO 8601 HTTP date](https://en.wikipedia.org/wiki/ISO_8601)
auth_config | Sensitive marketplace authentication information
config | Non-sensitive, general configuration set for the shop
format_config | JSON formatting instructions

<aside class="notice">
All <code>*config</code> fields are filled or enhanced by the merchant when
configuring the Vendor to distribute products through the Vendor's marketplace.
When registering the vendor with the Core API, JSON schema definitions for these
fields must be supplied by the Vendor developer.
</aside>

### Products

An array of product objects.

Parameter | Description
--------- | -----------
id | Product ID
characteristics | Normalized product characteristics
master | Product is master. Will have a Product ID value if this product is a variant of another.
state | Last known product state. Can be <code>created</code>, <code>updated</code>, or <code>deleted</code>

### Product characteristics

Name | Description
---- | -----------
name | Human readable product name
description | Human readable description of the product
color | Color
size | Size
ean | EAN number
price | Price without currency
currency | [ISO 4217](https://en.wikipedia.org/wiki/ISO_4217) currency code
stock | Stock count
images | Array of image URLs

# Collecting products

> Collect products from the marketplace

```ruby
Arctic::Vendor.collect_products do |shop|
  # 1. Connect to the marketplace and retrieve the products for the shop
  # 2. Format each of the products according to the shop's format_config
end
```

First, initialize the `Vendor.collect_products` method to receive each of the
shops that your vendor should process.

Then retrieve the products for that shop, and return them to the block, and the
Vendor Project will send them to the Core API.

The products you return to the block should be a JSON array of products, each
formatted according to the `shop`s `format_config` block.

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

# Going live

When you have fully developed your Vendor, you will have to go through a
verification and testing process with the Arctic Team.

Once you pass this verification process your Vendor will be released into
production and merchants can distribute their products through your Vendor to
the marketplace.
