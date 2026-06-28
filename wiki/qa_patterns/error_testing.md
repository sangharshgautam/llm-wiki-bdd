# Error Testing Patterns

How 4xx/5xx error scenarios are written, extracted from `coffee-ordering.feature`.

## Error Testing Conventions

**400 Bad Request** — Test each invalid/missing field separately:

```gherkin
Scenario: Reject order with missing coffee type
  Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
  And sg: I have the following request body:
    """
    {"size":"medium","quantity":1}
    """
  When sg: I send a POST request
  Then sg: the response status code should be 400
  And sg: the response should have field "error" with value "Missing required field: coffeeType"
```

**400 with empty field:**
```gherkin
Scenario: Reject order with empty coffee type
  Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
  And sg: I have request payload from file "invalidOrder"
  When sg: I send a POST request
  Then sg: the response status code should be 400
  And sg: the response should contain "Missing required field"
```

**400 with partial match assertion (contains):**
```gherkin
Scenario: Reject order with invalid quantity
  Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
  And sg: I have the following request body:
    """
    {"coffeeType":"Latte","size":"medium","quantity":0}
    """
  When sg: I send a POST request
  Then sg: the response status code should be 400
  And sg: the response should have field "error" containing "quantity"
```

## Key Rules

1. Test each validation failure in a **separate scenario** (one invalid field per scenario)
2. For validation errors, choose between:
   - **Exact field match** — `should have field "error" with value "exact message"` when the error message is deterministic
   - **Contains match** — `should have field "error" containing "partial"` when the error message might have dynamic parts
   - **Body contains** — `should contain "text"` when the error is in the response body but not in a structured field
3. Use **file-based payload** (`I have request payload from file "invalidOrder"`) for commonly reused invalid inputs
4. Use **inline JSON** for one-off invalid inputs that clearly show what field is being tested
