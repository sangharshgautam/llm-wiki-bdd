# Parameter Steps

Steps for setting query, path, and header parameters in `ApiStepDefinitions.java`.

## Query Parameters

**Expression:** `sg: I have the following query parameters:`
**Java:** `iHaveTheFollowingQueryParameters(DataTable dataTable)`
**Description:** Adds query parameters to the request URL. Accepts a Cucumber DataTable with key-value pairs.
**Usage:**
```gherkin
And sg: I have the following query parameters:
  | page  | 1  |
  | limit | 10 |
```

## Path Parameters

**Expression:** `sg: I have the following path parameters:`
**Java:** `iHaveTheFollowingPathParameters(DataTable dataTable)`
**Description:** Replaces path parameter placeholders in the URL. For a URL like `/users/{id}`, it replaces `{id}` with the provided value. Accepts a Cucumber DataTable with key-value pairs.
**Usage:**
```gherkin
Given sg: I have a REST API endpoint at "http://coffee-api/api/orders/{orderId}"
And sg: I have the following path parameters:
  | orderId | a8b3c4d5-e6f7-8a9b-0c1d-2e3f4a5b6c7d |
```

## Headers

**Expression:** `sg: I have the following headers:`
**Java:** `iHaveTheFollowingHeaders(DataTable dataTable)`
**Description:** Adds HTTP headers to the request. Accepts a Cucumber DataTable with key-value pairs. Headers are additive (previous headers are preserved).
**Usage:**
```gherkin
And sg: I have the following headers:
  | Content-Type  | application/json       |
  | Authorization | Bearer token123         |
  | X-Request-Id  | 550e8400-e29b-41d4-... |
```
