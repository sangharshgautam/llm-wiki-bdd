# HTTP Method Steps

Available HTTP request steps from `ApiStepDefinitions.java`.

## GET

**Expression:** `sg: I send a GET request`
**Java:** `iSendAGETRequest()`
**Description:** Sends an HTTP GET request to the configured endpoint URL.
**Usage:**
```gherkin
Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
When sg: I send a GET request
Then sg: the response status code should be 200
```

## POST

**Expression:** `sg: I send a POST request`
**Java:** `iSendAPOSTRequest()`
**Description:** Sends an HTTP POST request to the configured endpoint URL.
**Usage:**
```gherkin
Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
And sg: I have the following request body:
  """
  {"coffeeType":"Vanilla Latte","size":"medium","quantity":2}
  """
When sg: I send a POST request
Then sg: the response status code should be 201
```

## PUT

**Expression:** `sg: I send a PUT request`
**Java:** `iSendAPUTRequest()`
**Description:** Sends an HTTP PUT request to the configured endpoint URL.
**Usage:**
```gherkin
Given sg: I have a REST API endpoint at "http://coffee-api/api/orders/1"
And sg: I have request payload from file "updateOrder"
When sg: I send a PUT request
Then sg: the response status code should be 200
```

## DELETE

**Expression:** `sg: I send a DELETE request`
**Java:** `iSendADELETERequest()`
**Description:** Sends an HTTP DELETE request to the configured endpoint URL.
**Usage:**
```gherkin
Given sg: I have a REST API endpoint at "http://coffee-api/api/orders/1"
When sg: I send a DELETE request
Then sg: the response status code should be 204
```

## PATCH

**Expression:** `sg: I send a PATCH request`
**Java:** `iSendAPATCHRequest()`
**Description:** Sends an HTTP PATCH request to the configured endpoint URL.
**Usage:**
```gherkin
Given sg: I have a REST API endpoint at "http://coffee-api/api/orders/1"
And sg: I have the following request body:
  """
  {"status":"cancelled"}
  """
When sg: I send a PATCH request
Then sg: the response status code should be 200
```
