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
gem 'arctic-vendor', '~> 1.0'
```

First you must [register your Vendor](https://arctic-project.dk/vendor/register)
with the Core API to obtain a Vendor Token and ID.

Then store the token and ID in your environment as `ARCTIC_CORE_API_TOKEN` and `VENDOR_ID`.

If you need to run your application against another environment you can override
the URL by setting the `ARCTIC_CORE_API_URL` environment variable.

# Object descriptions

You can see the objects returned by the API to this library in the [Core API documentation](https://arctic-project.io).

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
Arctic::Vendor.distribute_products(batch_size: 300) do |shop, product_batch|
  # 1. Connect to the marketplace and publish the products to the shop

  product_batch.each do |product|
    # 2. As each of the products are published, update the state
    product.update_state 'created'
  end
end
```

First, initialize the `Vendor.distribute_products` method to receive each of the
shops and batches of related products to distribute to the marketplace.

Then connect to the marketplace and distribute the products to the shop.

<aside class="notice">
<code>Arctic::Vendor.distribute_products</code> returns products in batches of 100 by default.
</aside>

# Going live

When you have fully developed your Vendor, you will have to go through a
verification and testing process with the Arctic Team.

Once you pass this verification process your Vendor will be released into
production and merchants can distribute their products through your Vendor to
the marketplace.
