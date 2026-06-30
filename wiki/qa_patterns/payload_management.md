# Payload Management

Conventions for request payloads, response payloads, and mock files.

## File Naming Convention

All payload and mock files are named by **scenario tag**, not by descriptive name:

| Directory | File Pattern | Example |
|---|---|---|
| `requestPayload/` | `<TAG>.json` | `H001.json`, `N001.json`, `B001.json` |
| `responsePayload/` | `<TAG>.json` | `H001.json`, `N001.json`, `B001.json` |
| `mocks/` | `<TAG>.json` | `H001.json`, `N002.json` |

Each tagged scenario (H/N/B) produces its own set of files, all sharing the same tag-based filename.

## Request Payloads

Stored in `requestPayload/` directory on the classpath.

**Naming:** `<TAG>.json` matching the scenario tag.
- `H001.json` — H001's valid frontend request body (per frontend spec request schema)
- `N001.json` — N001's invalid frontend request body
- `B001.json` — B001's business-violation request body

**Referenced in features by filename without extension:**
```gherkin
And sg: I have request payload from file "H001"
```

**Example** `requestPayload/H001.json`:
```json
{"coffeeType":"Vanilla Latte","size":"medium","quantity":2}
```

## Response Payloads

Stored in `responsePayload/` directory on the classpath.

**Naming:** `<TAG>.json` matching the scenario tag.
- `H001.json` — Expected frontend response for H001 (per frontend spec response schema)
- `N002.json` — Expected error response for N002

**Referenced in features by filename without extension:**
```gherkin
Then sg: the response should contain file "H001"
```

**Example** `responsePayload/H001.json`:
```json
{"status":"brewing"}
```

## Backend Mocks

Stored in `mocks/` directory on the classpath.

**Naming:** `<TAG>.json` matching the scenario tag.
- `H001.json` — Backend stub for H001 (valid 200 response per backend spec)
- `N002.json` — Backend error stub for N002 (error response per backend spec)

**Purpose:** Each mock stub is derived from the backend OpenAPI spec's corresponding endpoint and response schema. For H scenarios, the mock returns a valid backend response. For N scenarios, the mock returns the relevant error response.

**Mock file format (WireMock stub mapping JSON):**

| Section | Content | Source |
|---------|---------|--------|
| `request.method` | HTTP method (GET, POST, etc.) | Backend spec endpoint |
| `request.urlPath` | Backend endpoint path (e.g., `/api/backend/orders`) | Backend spec path |
| `request.headers.mdg_test_scenario` | `equalTo: <TAG>` | Scenario tag — ensures correct stub is triggered |
| `response.status` | HTTP status code (200, 400, 500, etc.) | Backend spec response |
| `response.jsonBody` | Response body from backend spec's response schema | Backend spec response schema |
| `response.headers.Content-Type` | `application/json` | Standard |

**Example** `mocks/H001.json`:
```json
{
  "request": {
    "method": "POST",
    "urlPath": "/backend/orders",
    "headers": {
      "mdg_test_scenario": {
        "equalTo": "H001"
      }
    }
  },
  "response": {
    "status": 200,
    "jsonBody": {
      "orderId": "a8b3c4d5-e6f7-8a9b-0c1d-2e3f4a5b6c7d",
      "status": "confirmed"
    },
    "headers": {
      "Content-Type": "application/json"
    }
  }
}
```

### Which scenarios need mocks?

| Scenario Type | Mock Required? | Reason |
|---|---|---|
| Happy (H) | Always | Backend must return a valid response for the frontend to process |
| Negative (N) — frontend validation | No | Error is produced by Camel route before reaching backend |
| Negative (N) — backend error | Yes | Mock the backend's error response |
| Business (B) — frontend-only | No | Business rule enforced by frontend before backend |
| Business (B) — requires backend | Yes | Business rule requires backend interaction |

## When to Use Inline vs File

| Approach | When to Use |
|---|---|
| **Inline JSON** (triple-quoted) | Simple payloads, one-off test data, clearly showing what's being tested |
| **File reference** | Complex payloads, when the payload is reused, or generated per scenario tag |
