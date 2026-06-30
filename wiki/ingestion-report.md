# Ingestion Report — 2026-06-30

## Step Definitions

| Source | Files Found | Steps Identified |
|--------|------------|------------------|
| openapi-bdd (C:/Users/sangh/IdeaProjects/sangharshgautam/openapi-bdd) | 1 | 31 |

### Steps by Category

| Category | Count |
|----------|-------|
| HTTP Method Steps | 5 (GET, POST, PUT, DELETE, PATCH) |
| Request Payload Steps | 2 (inline body, file-based) |
| Parameter Steps | 3 (query params, path params, headers) |
| Authentication Steps | 4 (OAuth2 token, basic auth, base URI, base path) |
| Response Assertion Steps | 14 (status code, contains, field equals, field contains, field exists, empty, time, content type, array size, schema match, file match, file contain) |
| Helper Steps | 1 (print response) |
| Context Variable Steps | 2 (save field, use variable) |

## Golden Service: coffee-ordering-api

**Path:** C:/Users/sangh/IdeaProjects/sangharshgautam/coffee-ordering-api

### coffee-ordering-service-test

| Metric | Count |
|--------|-------|
| Feature files | 1 |
| Total scenarios | 10 |
| — Happy path | 6 |
| — Negative (4xx) | 4 |
| — Negative (5xx) | 0 |
| — Business | 0 |
| requestPayload files | 2 (createOrder.json, invalidOrder.json) |
| responsePayload files | 2 (orderResponse.json, errorResponse.json) |
| Mock files | 0 |

### Step Expressions Identified from Feature Files

| # | Expression |
|---|------------|
| 1 | sg: I have a REST API endpoint at "{url}" |
| 2 | sg: I have the following request body: |
| 3 | sg: I have request payload from file "{name}" |
| 4 | sg: I send a POST request |
| 5 | sg: the response status code should be {int} |
| 6 | sg: the response should have field "{field}" with value {value} |
| 7 | sg: the response should have field "{field}" |
| 8 | sg: the response content type should be "{type}" |
| 9 | sg: the response should contain "{text}" |
| 10 | sg: the response should have field "{field}" containing "{text}" |
| 11 | sg: the response time should be less than {long} milliseconds |
| 12 | sg: the response should contain file "{name}" |

### Payload Conventions

- **Inline JSON**: Used for simple/one-off scenarios (docstring/triple quotes)
- **File-based**: Used for reusable payloads via `requestPayload/<name>.json` and `responsePayload/<name>.json`
- **File naming**: Descriptive names (createOrder, invalidOrder, orderResponse, errorResponse)
- **Backend mocks**: Not used — service starts the real Spring Boot application in-process
