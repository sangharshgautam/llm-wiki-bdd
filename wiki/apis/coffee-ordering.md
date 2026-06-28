# Coffee Ordering API

## Overview

- **Title:** Express Coffee Ordering API
- **Version:** 1.0.0
- **Base URL:** `https://api.expresscoffee.mock`
- **Test host placeholder:** `coffee-api`

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

## Test Scenarios

10 scenarios in the golden feature file covering:
- Valid order with inline JSON body
- Valid order with file-based payload
- Rejected order (empty coffeeType) with file-based invalid payload
- Rejected order (missing coffeeType) with inline body
- Rejected order (empty size)
- Rejected order (quantity = 0)
- Price calculation for small size (totalPrice = 10.5)
- Price calculation for large size (totalPrice = 11.0)
- Response time under 5000ms
- File-based response assertions (contains file)
- File-based error response assertions
