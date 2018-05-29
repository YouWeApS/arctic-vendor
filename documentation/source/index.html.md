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

<!-- # Authentication

> To authorize, use this code:

```ruby
require 'kittn'

api = Kittn::APIClient.authorize!('meowmeowmeow')
```

```python
import kittn

api = kittn.authorize('meowmeowmeow')
```

```shell
# With shell, you can just pass the correct header with each request
curl "api_endpoint_here"
  -H "Authorization: meowmeowmeow"
```

```javascript
const kittn = require('kittn');

let api = kittn.authorize('meowmeowmeow');
```

> Make sure to replace `meowmeowmeow` with your API key.

Kittn uses API keys to allow access to the API. You can register a new Kittn API key at our [developer portal](http://example.com/developers).

Kittn expects for the API key to be included in all API requests to the server in a header that looks like the following:

`Authorization: meowmeowmeow`

<aside class="notice">
You must replace <code>meowmeowmeow</code> with your personal API key.
</aside>

# Kittens

## Get All Kittens

```ruby
require 'kittn'

api = Kittn::APIClient.authorize!('meowmeowmeow')
api.kittens.get
```

```python
import kittn

api = kittn.authorize('meowmeowmeow')
api.kittens.get()
```

```shell
curl "http://example.com/api/kittens"
  -H "Authorization: meowmeowmeow"
```

```javascript
const kittn = require('kittn');

let api = kittn.authorize('meowmeowmeow');
let kittens = api.kittens.get();
```

> The above command returns JSON structured like this:

```json
[
  {
    "id": 1,
    "name": "Fluffums",
    "breed": "calico",
    "fluffiness": 6,
    "cuteness": 7
  },
  {
    "id": 2,
    "name": "Max",
    "breed": "unknown",
    "fluffiness": 5,
    "cuteness": 10
  }
]
```

This endpoint retrieves all kittens.

### HTTP Request

`GET http://example.com/api/kittens`

### Query Parameters

Parameter | Default | Description
--------- | ------- | -----------
include_cats | false | If set to true, the result will also include cats.
available | true | If set to false, the result will include kittens that have already been adopted.

<aside class="success">
Remember — a happy kitten is an authenticated kitten!
</aside>

## Get a Specific Kitten

```ruby
require 'kittn'

api = Kittn::APIClient.authorize!('meowmeowmeow')
api.kittens.get(2)
```

```python
import kittn

api = kittn.authorize('meowmeowmeow')
api.kittens.get(2)
```

```shell
curl "http://example.com/api/kittens/2"
  -H "Authorization: meowmeowmeow"
```

```javascript
const kittn = require('kittn');

let api = kittn.authorize('meowmeowmeow');
let max = api.kittens.get(2);
```

> The above command returns JSON structured like this:

```json
{
  "id": 2,
  "name": "Max",
  "breed": "unknown",
  "fluffiness": 5,
  "cuteness": 10
}
```

This endpoint retrieves a specific kitten.

<aside class="warning">Inside HTML code blocks like this one, you can't use Markdown, so use <code>&lt;code&gt;</code> blocks to denote code.</aside>

### HTTP Request

`GET http://example.com/kittens/<ID>`

### URL Parameters

Parameter | Description
--------- | -----------
ID | The ID of the kitten to retrieve

## Delete a Specific Kitten

```ruby
require 'kittn'

api = Kittn::APIClient.authorize!('meowmeowmeow')
api.kittens.delete(2)
```

```python
import kittn

api = kittn.authorize('meowmeowmeow')
api.kittens.delete(2)
```

```shell
curl "http://example.com/api/kittens/2"
  -X DELETE
  -H "Authorization: meowmeowmeow"
```

```javascript
const kittn = require('kittn');

let api = kittn.authorize('meowmeowmeow');
let max = api.kittens.delete(2);
```

> The above command returns JSON structured like this:

```json
{
  "id": 2,
  "deleted" : ":("
}
```

This endpoint deletes a specific kitten.

### HTTP Request

`DELETE http://example.com/kittens/<ID>`

### URL Parameters

Parameter | Description
--------- | -----------
ID | The ID of the kitten to delete

 -->
