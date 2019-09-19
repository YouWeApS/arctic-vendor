# Changelog

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
