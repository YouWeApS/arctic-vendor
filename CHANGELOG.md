# Changelog

### 2.5.11
* move #encode to top api class

### 2.5.10
* add #remove_scheduled_update API method

### 2.5.9
* fix response JSON parsing error

### 2.5.8
* add request to get single product
* change #get_shop request to return nil if shop is not found

### 2.5.7
* handle error reponse from Core in list_products dispersal api request

### 2.5.6
* fix #synced method to send data through body not params

### 2.5.5
* add ability to specify custom time for last_synced_at

### 2.5.4
* add GET vendor_shop_configuration API method

### 2.5.3
* update request retry logic

### 2.5.2
* update #create_product_categories API request

### 2.5.1
* add #create_product_categories API request

### 2.5
* remove WebhookAPI (move to dandomain project)

### 2.4.1
* Dispersal::Api#list_products: add 'collected_at' time

### 2.4
* Dispersal::API: collect products with state update

### 2.3.7
* Api#paginated_request: refactor header values assignment

### 2.3.6
* Dispersal::Api: add handling for API#paginated_request Per-Page header missing case

### 2.3.5
* Dispersal::Api: add max_items to list_products request

### 2.3.4
* add webhooks requests params and body logging to separate file (log/webhook.log)

### 2.3.3
* Dispersal::API#update_products_dispersals: accept custom body

### 2.3.2
* initialize faraday response object from faraday error object when catching response with < 500 status

### 2.3.1
* workaround for faraday gem errors statuses mapping

### 2.3
* retry on failed request

### 2.2.12
* accept params for #update_products_dispersals

### 2.2.11
* fix object_id encoding

### 2.2.10
* fix escaping slash in object_id

### 2.2.9
* change #update_products_dispersals param name

### 2.2.8
* add #update_products_dispersals to dispersal API

### 2.2.7
* Update retry logic for DispersalApi list_products method

### 2.2.6
* Add retry logic for DispersalApi list_products method

### 2.2.5
* Order dispersed at changed on disperse process.

### 2.2.4
* Encode changed.

### 2.2.3
* Added encode for product SKU during API request.

### 2.2.2
* Added order errors API request

### 2.2.1
* Added Webhook API that will handle stock count changes for products and send them to Core.

### 2.1.0

* Refactor API to more unified method naming across dispersal and collection
* Rename completed_dispersal -> synced
* Add update_order
* Add orders
* Enforce validator class method signature
* Allow looking up a single shop
* Allow updating single order line

### 2.0.1

* Change order creation endpoint to POST
* Add validation API grape class
* Add call to get last_synced_at for different sync routines
* Allow routing in completed_dispersal endpoint
* Allow collecting invoices for collected orders
* Allow attaching order lines to orders

### 2.0.0

* Major rewrite of the dispersal api. This is now namespaced to Dispersal.
* Add order collection endpoint for dispersal vendors
* Add endpoint to report product queue state
* Ensure that API sends body in JSON format
* Allow dispersal vendor to report dispersal process completed

### 1.1.0

* Allow reporting individual product errors

### 1.0.1

* Add ruby version dependency

### 1.0.0

* Remove a number of superfluous endpoints
* Remove need for account_id
* Rename some existing endpoints
* Remove Product objetc. Use POR hashes
* Add call to update when the shop was last collected after each collection cycle

### 0.2.5

* Add latest_only key to distribute_products
* Added api method for adding orders to the Core API

### 0.2.1

* Added Arctic::Vendor::API#list_products method to allow vendors to retrieve products from the Core API - Emil Kampp <emil@youwe.dk>

### 0.2.2

* Added synchronization endpoint to mark a shop as synchronized

### 0.2.3

* When retrieving products from the Core API it will now be an array of Product objects.
* Introduce Product#update_state to update each product state
* Product#characteristics is now a Hashie::Mash to allow for dot-notation
* Allow traversing API pagination with API#make_paginated_request
* Allow setting batch size for Arctic::Vendor#distribute_products
