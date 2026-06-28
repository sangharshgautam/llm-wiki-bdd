Feature: Coffee Ordering API
  As a coffee lover
  I want to place coffee orders via the API
  So that I can get my coffee brewed

  Scenario: Place a valid coffee order
    Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
    And sg: I have the following request body:
      """
      {"coffeeType":"Vanilla Latte","size":"medium","quantity":2}
      """
    When sg: I send a POST request
    Then sg: the response status code should be 201
    And sg: the response should have field "status" with value "brewing"
    And sg: the response should have field "totalPrice" with value 9.0
    And sg: the response should have field "orderId"
    And sg: the response should have field "estimatedReadyTime"
    And sg: the response content type should be "application/json"

  Scenario: Place order with request payload file
    Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
    And sg: I have request payload from file "createOrder"
    When sg: I send a POST request
    Then sg: the response status code should be 201
    And sg: the response should have field "status" with value "brewing"

  Scenario: Reject order with empty coffee type
    Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
    And sg: I have request payload from file "invalidOrder"
    When sg: I send a POST request
    Then sg: the response status code should be 400
    And sg: the response should contain "Missing required field"

  Scenario: Reject order with missing coffee type
    Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
    And sg: I have the following request body:
      """
      {"size":"medium","quantity":1}
      """
    When sg: I send a POST request
    Then sg: the response status code should be 400
    And sg: the response should have field "error" with value "Missing required field: coffeeType"

  Scenario: Reject order with empty size
    Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
    And sg: I have the following request body:
      """
      {"coffeeType":"Latte","size":"","quantity":1}
      """
    When sg: I send a POST request
    Then sg: the response status code should be 400
    And sg: the response should have field "error" containing "size"

  Scenario: Reject order with invalid quantity
    Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
    And sg: I have the following request body:
      """
      {"coffeeType":"Latte","size":"medium","quantity":0}
      """
    When sg: I send a POST request
    Then sg: the response status code should be 400
    And sg: the response should have field "error" containing "quantity"

  Scenario: Calculate price for small size
    Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
    And sg: I have the following request body:
      """
      {"coffeeType":"Espresso","size":"small","quantity":3}
      """
    When sg: I send a POST request
    Then sg: the response status code should be 201
    And sg: the response should have field "totalPrice" with value 10.5

  Scenario: Calculate price for large size
    Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
    And sg: I have the following request body:
      """
      {"coffeeType":"Mocha","size":"large","quantity":2}
      """
    When sg: I send a POST request
    Then sg: the response status code should be 201
    And sg: the response should have field "totalPrice" with value 11.0

  Scenario: Response time is acceptable
    Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
    And sg: I have the following request body:
      """
      {"coffeeType":"Latte","size":"medium","quantity":1}
      """
    When sg: I send a POST request
    Then sg: the response status code should be 201
    And sg: the response time should be less than 5000 milliseconds

  Scenario: Response contains expected fields (file-based assertion)
    Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
    And sg: I have the following request body:
      """
      {"coffeeType":"Cappuccino","size":"large","quantity":1}
      """
    When sg: I send a POST request
    Then sg: the response status code should be 201
    And sg: the response should contain file "orderResponse"

  Scenario: Error response matches file
    Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
    And sg: I have request payload from file "invalidOrder"
    When sg: I send a POST request
    Then sg: the response status code should be 400
    And sg: the response should contain file "errorResponse"
