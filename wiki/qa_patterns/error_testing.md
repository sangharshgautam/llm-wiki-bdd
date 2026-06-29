# Error Testing Patterns

How 4xx/5xx error scenarios are written, extracted from `coffee-ordering.feature` and generalized for the frontend-backend architecture.

## Error Origin: Two Layers

Errors can come from two layers of the Camel REST gateway:

### 1. Frontend-side validation (no mock needed)

The Camel route validates the incoming request against the frontend schema before calling the backend. These errors are **tested without mocks**.

```gherkin
@N001
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

### 2. Backend-originated error (include mock)

The backend returns an error response. A mock is placed in `mocks/<TAG>.json` to simulate the backend error, derived from the backend spec.

```gherkin
@N002
Scenario: Backend returns 500 internal error
  Given sg: I have a REST API endpoint at "http://coffee-api/api/orders"
  And sg: I have the following request body:
    """
    {"coffeeType":"Latte","size":"medium","quantity":1}
    """
  When sg: I send a POST request
  Then sg: the response status code should be 500
  And sg: the response should have field "error" containing "internal"
```

## Error Assertion Styles

| Style | Step | When to Use |
|---|---|---|
| **Exact field match** | `the response should have field "error" with value "exact message"` | Error message is fully deterministic |
| **Partial field match** | `the response should have field "error" containing "partial"` | Error message has dynamic parts (IDs, timestamps) |
| **Body contains** | `the response should contain "text"` | Error is in the body but not in a structured field |
| **File-based match** | `the response should contain file "errorResponse"` | Complex error response structure, reused across scenarios |

## Key Rules

1. Each validation failure gets its **own scenario** (one invalid field per scenario)
2. Frontend validation errors (4xx) need **no mock** — the Camel route produces them directly
3. Backend errors (4xx/5xx) need a **mock stub** in `mocks/<TAG>.json` derived from the backend spec
4. Use inline JSON for clear, one-off invalid inputs
5. Use file-based payloads for commonly reused invalid inputs
