# Response Assertion Steps

Steps for asserting on responses in `ApiStepDefinitions.java`.

## Status Code

**Expression:** `sg: the response status code should be {int}`
**Java:** `theResponseStatusCodeShouldBe(int statusCode)`
**Description:** Asserts the HTTP response status code.
**Usage:**
```gherkin
Then sg: the response status code should be 200
Then sg: the response status code should be 201
Then sg: the response status code should be 400
Then sg: the response status code should be 404
Then sg: the response status code should be 204
```

## Response Contains String

**Expression:** `sg: the response should contain {string}`
**Java:** `theResponseShouldContain(String expectedContent)`
**Description:** Asserts the response body contains a substring.
**Usage:**
```gherkin
Then sg: the response should contain "Missing required field"
Then sg: the response should contain "error"
```

## Field Equals String

**Expression:** `sg: the response should have field {string} with value {string}`
**Java:** `theResponseShouldHaveFieldWithValue(String fieldName, String expectedValue)`
**Description:** Asserts a JSON field in the response equals the given string value. Supports dot-notation for nested fields.
**Usage:**
```gherkin
Then sg: the response should have field "status" with value "brewing"
Then sg: the response should have field "error" with value "Missing required field: coffeeType"
```

## Field Contains String

**Expression:** `sg: the response should have field {string} containing {string}`
**Java:** `theResponseShouldHaveFieldContaining(String fieldName, String expectedValue)`
**Description:** Asserts a JSON field contains the given substring.
**Usage:**
```gherkin
Then sg: the response should have field "error" containing "size"
Then sg: the response should have field "error" containing "quantity"
```

## Field Equals Integer

**Expression:** `sg: the response should have field {string} with value {int}`
**Java:** `theResponseShouldHaveFieldWithIntValue(String fieldName, int expectedValue)`
**Description:** Asserts a JSON field equals the given integer value.
**Usage:**
```gherkin
Then sg: the response should have field "totalPrice" with value 9
```

## Field Equals Double

**Expression:** `sg: the response should have field {string} with value {double}`
**Java:** `theResponseShouldHaveFieldWithDoubleValue(String fieldName, double expectedValue)`
**Description:** Asserts a JSON field equals the given decimal value.
**Usage:**
```gherkin
Then sg: the response should have field "totalPrice" with value 9.5
```

## Field Exists (Not Null)

**Expression:** `sg: the response should have field {string}`
**Java:** `theResponseShouldHaveField(String fieldName)`
**Description:** Asserts a JSON field exists and is not null.
**Usage:**
```gherkin
Then sg: the response should have field "orderId"
Then sg: the response should have field "estimatedReadyTime"
```

## Response is Empty

**Expression:** `sg: the response should be empty`
**Java:** `theResponseShouldBeEmpty()`
**Description:** Asserts the response body is empty or null.
**Usage:**
```gherkin
Then sg: the response should be empty
```

## Response Time

**Expression:** `sg: the response time should be less than {long} milliseconds`
**Java:** `theResponseTimeShouldBeLessThanMilliseconds(long maxTime)`
**Description:** Asserts the response time is under the specified threshold.
**Usage:**
```gherkin
Then sg: the response time should be less than 5000 milliseconds
```

## Content Type

**Expression:** `sg: the response content type should be {string}`
**Java:** `theResponseContentTypeShouldBe(String contentType)`
**Description:** Asserts the response Content-Type header.
**Usage:**
```gherkin
Then sg: the response content type should be "application/json"
```

## Response Array Size

**Expression:** `sg: the response array size should be {int}`
**Java:** `theResponseArraySizeShouldBe(int expectedSize)`
**Description:** Asserts the response JSON array has the expected size.
**Usage:**
```gherkin
Then sg: the response array size should be 3
```

## Match JSON Schema

**Expression:** `sg: the response should match schema {string}`
**Java:** `theResponseShouldMatchSchema(String schema)`
**Description:** Validates the response body against a JSON schema. The schema is provided as a string (can reference a file).
**Usage:**
```gherkin
Then sg: the response should match schema "order-schema.json"
```

## Match File Exactly

**Expression:** `sg: the response should match file {string}`
**Java:** `theResponseShouldMatchFile(String fileName)`
**Description:** Asserts the response body exactly equals the content of a file from `responsePayload/<fileName>.json`.
**Usage:**
```gherkin
Then sg: the response should match file "userResponse"
```

## Contains File Content (partial/subset match)

**Expression:** `sg: the response should contain file {string}`
**Java:** `theResponseShouldContainFile(String fileName)`
**Description:** Asserts the response body contains all fields/values from a file in `responsePayload/<fileName>.json`. Uses deep subset matching (nested objects are recursively checked, arrays check minimum size). This is a superset/subset match, not exact equality.
**Usage:**
```gherkin
Then sg: the response should contain file "orderResponse"
Then sg: the response should contain file "errorResponse"
```
