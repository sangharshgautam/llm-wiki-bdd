# Payload Management

Conventions for request and response payload files.

## Request Payloads

Stored in `requestPayload/` directory on the classpath.

**File naming:** camelCase describing the payload purpose.
- `createOrder.json` — Valid payload for creating an order
- `invalidOrder.json` — Invalid payload (e.g., empty required fields)

**Referenced in features by filename without extension:**
```gherkin
And sg: I have request payload from file "createOrder"
```

**Examples:**

`requestPayload/createOrder.json`:
```json
{"coffeeType":"Vanilla Latte","size":"medium","quantity":2}
```

`requestPayload/invalidOrder.json`:
```json
{"coffeeType":"","size":"medium","quantity":1}
```

## Response Payloads

Stored in `responsePayload/` directory on the classpath.

**File naming:** camelCase describing the expected response.
- `orderResponse.json` — Expected success response fields
- `errorResponse.json` — Expected error response fields

**Referenced in features by filename without extension:**
```gherkin
Then sg: the response should contain file "orderResponse"
```

**Examples:**

`responsePayload/orderResponse.json`:
```json
{"status":"brewing"}
```

`responsePayload/errorResponse.json`:
```json
{"error":"Missing required field: coffeeType"}
```

## When to Use Inline vs File

| Approach | When to Use |
|---|---|
| **Inline JSON** (triple-quoted) | Simple payloads, one-off test data, clearly showing what's being tested |
| **File reference** | Complex payloads, reusable across multiple scenarios, shared invalid data |
