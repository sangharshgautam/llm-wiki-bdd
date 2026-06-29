# Coffee Ordering API

## Overview

- **Title:** Express Coffee Ordering API
- **Version:** 1.0.0
- **Base URL:** `https://api.expresscoffee.mock`
- **Architecture:** Single Camel REST service (no separate backend mock needed — service starts in-process)

## Endpoints

### POST /orders

Place a new coffee order.

**Request body (required fields):**
| Field | Type | Constraints |
|---|---|---|
| `coffeeType` | string | Required |
| `size` | string | Required, enum: `small`, `medium`, `large` |
| `quantity` | integer | Required, minimum: 1 |
| `specialInstructions` | string | Optional |

**Success response (201):**
| Field | Type | Example |
|---|---|---|
| `orderId` | string (uuid) | `a8b3c4d5-...` |
| `status` | string | `brewing` |
| `estimatedReadyTime` | string (date-time) | `2026-06-28T08:15:00Z` |
| `totalPrice` | number (float) | `9.50` |

**Error responses:**
- **400** — Invalid request body or missing required fields. Response: `{"error": "Missing required field: coffeeType"}`

## Test Scenarios (Golden Reference)

11 scenarios in `coffee-ordering.feature` serving as a pattern reference:

| Scenario | Type | Tag Pattern (if generated today) |
|---|---|---|
| Place a valid coffee order | Happy (inline) | H001 |
| Place order with request payload file | Happy (file) | H002 |
| Reject order with empty coffee type | Negative (file) | N001 |
| Reject order with missing coffee type | Negative (inline, exact) | N002 |
| Reject order with empty size | Negative (inline, contains) | N003 |
| Reject order with invalid quantity | Negative (inline, contains) | N004 |
| Calculate price for small size | Business | B001 |
| Calculate price for large size | Business | B002 |
| Response time is acceptable | Helper | — |
| Response contains expected fields (file) | Happy (file assert) | H003 |
| Error response matches file | Negative (file assert) | N005 |

## Notes

- No backend mock needed — the service under test is self-contained
- Payload files use descriptive names (`createOrder.json`, `invalidOrder.json`) — the old convention before tag-based naming
