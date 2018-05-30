# Changelog

### 0.2.1

* Added Arctic::Vendor::API#list_products method to allow vendors to retrieve products from the Core API - Emil Kampp <emil@youwe.dk>

### 0.2.2

* Added synchronization endpoint to mark a shop as synchronized

### 0.2.3

* When retrieving products from the Core API it will now be an array of Product objects.
* Introduce Product#update_state to update each product state
* Product#characteristics is now a Hashie::Mash to allow for dot-notation
