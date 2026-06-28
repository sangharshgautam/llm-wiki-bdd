# FleetRoute AI Optimization API

## Overview

- **Title:** FleetRoute AI Optimization API
- **Version:** 2.1.0
- **Base URL:** `https://api.fleetroute-ai.com/v2`
- **Test host placeholder:** `fleetroute-api`

## Endpoints

### POST /routes/optimize

Computes the most efficient stop sequence and turn-by-turn metrics for a set of shipments using a specific vehicle profile.

**Request body (required fields):**
| Field | Type | Constraints |
|---|---|---|
| `vehicleProfile` | object | Required |
| `vehicleProfile.type` | string | Required, enum: `box_truck`, `semi_trailer`, `electric_van`, `drone` |
| `vehicleProfile.maxCapacityKg` | integer (int64) | Required |
| `vehicleProfile.hazmatCertified` | boolean | Optional, default: false |
| `origin` | object | Required |
| `origin.latitude` | number (float) | Required |
| `origin.longitude` | number (float) | Required |
| `origin.depotName` | string | Optional |
| `stops` | array | Required, minItems: 1 |
| `stops[].stopId` | string (uuid) | Required |
| `stops[].latitude` | number (float) | Required |
| `stops[].longitude` | number (float) | Required |
| `stops[].weightKg` | integer | Required |
| `stops[].timeWindow` | object | Optional |
| `optimizationStrategy` | string | Optional, enum: `shortest_time`, `shortest_distance`, `lowest_carbon`, default: `shortest_time` |

**Success response (200):**
| Field | Type | Example |
|---|---|---|
| `optimizationId` | string (uuid) | `c3b0fa14-...` |
| `summary.totalDurationMinutes` | number (float) | `245.5` |
| `summary.totalDistanceKm` | number (float) | `184.2` |
| `summary.estimatedCarbonSavedKg` | number (float) | `14.8` |
| `itinerary[].sequenceOrder` | integer | `1` |
| `itinerary[].stopId` | string (uuid) | `9b1deb4d-...` |
| `itinerary[].estimatedArrival` | string (date-time) | `2026-06-28T10:15:00Z` |
| `itinerary[].etaStatus` | string | `on_time`, `risk_of_delay`, `tight_window` |
| `itinerary[].distanceFromPreviousKm` | number (float) | `12.4` |

**Error responses:**
- **400** — Bad Request (invalid syntax or geometry conflicts). Response: `{"errorCode": "UNREACHABLE_STOPS", "message": "...", "invalidStops": [...]}`
- **500** — Internal Optimization Engine Error. Response: `{"traceId": "err-...", "message": "..."}`

## Test Scenarios

6 scenarios in the generated feature file covering:
- Happy path with `semi_trailer` and `shortest_time` strategy
- Alternative happy path with `electric_van` and `lowest_carbon` strategy
- Missing required field (vehicleProfile) → 400
- Unreachable stops → 400 UNREACHABLE_STOPS
- Internal engine error → 500
- Response time < 5000ms
