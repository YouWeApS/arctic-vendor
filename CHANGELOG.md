# Changelog

### 2.0.0

* Major rewrite of the dispersal api. This is now namespaced to Dispersal.
* Add order collection endpoint for dispersal vendors

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
