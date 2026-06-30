# Scenario Patterns

Common scenario structures extracted from golden service `coffee-ordering.feature`, generalized for the frontend-backend architecture.

## Service Architecture

The tested service is a Camel REST gateway:

```
Frontend Request
  → Validate against frontend request schema
  → Transform (XSLT)
  → Validate against backend request schema
  → Send to backend
  → Validate backend response against backend response schema
  → Transform (XSLT)
  → Validate against frontend response schema
  → Frontend Response
```

Tests verify this full flow. Backend is mocked using stubs derived from the backend spec.

## Scenario Identification Header

Every scenario request MUST include the `mdg_test_scenario` HTTP header with the scenario tag as its value (e.g., `H001`). This header:
- Uniquely identifies which scenario is being executed
- Enables the mock backend to match requests to the correct stub (each mock stub expects `mdg_test_scenario` to match its tag)
- Is set using the `I have the following headers:` step in every scenario

## Scenario Types and Tagging

Scenarios are split across three feature files by type, with sequential tags:

| Feature File | Tag Prefix | Type | Description |
|---|---|---|---|
| `happyPath.feature` | `@H001, @H002, …` | Happy path | 2xx success flows |
| `negativePath.feature` | `@N001, @N002, …` | Negative | 4xx/5xx error flows |
| `businessScenarios.feature` | `@B001, @B002, …` | Business | Valid-schema but business-rule violations |

## Standard Happy Path Flow (H-tagged)

```gherkin
@H001
Scenario: Place a valid coffee order
  Given sg: I have a REST API endpoint at "http://<host>/api/orders"
  And sg: I have the following headers:
    | mdg_test_scenario | H001 |
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
```

For each H scenario, the agent generates:
- `requestPayload/H001.json` — valid frontend request body
- `responsePayload/H001.json` — expected frontend response body
- `mocks/H001.json` — backend stub derived from backend spec (valid 200 response)

## Negative Path Flow (N-tagged)

Errors can originate from two layers:

### Frontend validation error (no mock needed)
```gherkin
@N001
Scenario: Reject order with missing required field
  Given sg: I have a REST API endpoint at "http://<host>/api/orders"
  And sg: I have the following headers:
    | mdg_test_scenario | N001 |
  And sg: I have the following request body:
    """
    {"size":"medium","quantity":1}
    """
  When sg: I send a POST request
  Then sg: the response status code should be 400
  And sg: the response should have field "error" with value "Missing required field: coffeeType"
```

### Backend error (mock the backend error response)
```gherkin
@N002
Scenario: Backend returns server error
  Given sg: I have a REST API endpoint at "http://<host>/api/orders"
  And sg: I have the following headers:
    | mdg_test_scenario | N002 |
  And sg: I have the following request body:
    """
    {"coffeeType":"Latte","size":"medium","quantity":1}
    """
  When sg: I send a POST request
  Then sg: the response status code should be 500
  And sg: the response should have field "error" containing "internal"
```

For N scenarios:
- If error is frontend-side validation (4xx) — no mock needed
- If error originates from backend — include `mocks/<TAG>.json` with the error stub

## Business Scenario Flow (B-tagged)

Valid-by-schema requests that violate business rules (duplicate, conflict, out-of-range):

```gherkin
@B001
Scenario: Duplicate order ID returns conflict
  Given sg: I have a REST API endpoint at "http://<host>/api/orders"
  And sg: I have the following headers:
    | mdg_test_scenario | B001 |
  And sg: I have the following request body:
    """
    {"coffeeType":"Latte","size":"large","quantity":1}
    """
  When sg: I send a POST request
  Then sg: the response status code should be 409
  And sg: the response should have field "error" containing "duplicate"
```

For B scenarios: include request/response payloads. Include backend mock only if the business validation requires backend interaction.

## Common Step Patterns

| Step | Usage |
|---|---|
| `sg: I have a REST API endpoint at "{url}"` | Always — sets the endpoint |
| `sg: I have the following headers:` | Always — sets the `mdg_test_scenario` header (and any other headers) |
| `sg: I have the following request body:` | Inline JSON for simple/one-off cases |
| `sg: I have request payload from file "{name}"` | File-based for reusable payloads |
| `sg: I send a POST request` | The action |
| `sg: the response status code should be {code}` | Assert status |
| `sg: the response should have field "{field}"` | Assert field exists |
| `sg: the response should have field "{field}" with value {value}` | Assert field value |
| `sg: the response should have field "{field}" containing "{text}"` | Partial match on field |
| `sg: the response should contain "{text}"` | Body text contains |
| `sg: the response should contain file "{name}"` | File-based response match |
| `sg: the response content type should be "{type}"` | Content type assertion |
| `sg: the response time should be less than {ms} milliseconds` | Timing assertion |

## Scenario Coverage Expectation

For each endpoint:
- **1+ H scenarios** — happy path with field-level assertions
- **1 N scenario per documented 4xx** — each validation error tested separately
- **1 N scenario per documented 5xx** — backend error
- **1 B scenario per business rule** — duplicate, conflict, out-of-range, etc.
- **1 response time scenario** — performance assertion
- **1 content type scenario** — content type assertion
