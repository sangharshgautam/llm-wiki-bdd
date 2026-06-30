# Operation Log

## [2026-06-28] ingest | Step Definitions — openapi-bdd
- Parsed `ApiStepDefinitions.java`
- Created 6 category pages in `wiki/step_dictionary/`
- Documented 23 available steps across HTTP methods, payloads, parameters, auth, assertions, context variables, and helpers

## [2026-06-28] ingest | Golden Features — coffee-ordering-service-test
- Analyzed `coffee-ordering.feature` (10 scenarios)
- Analyzed `CucumberTest.java`, `AppSetup.java`, `junit-platform.properties`, `pom.xml`
- Created 5 pattern pages in `wiki/qa_patterns/`
- Created `wiki/apis/coffee-ordering.md`

## [2026-06-28] generate | FleetRoute AI Optimization API
- Analyzed `raw_sources/frontend_spec/fleetroute-openapi.yaml`
- Generated `generated/fleetroute-service-test/` (6 scenarios, 2 request payloads, 3 response payloads)
- Created `wiki/apis/fleetroute.md`
- Coverage: 200 happy path, 200 alternative strategy, 400 missing field, 400 UNREACHABLE_STOPS, 500 server error, response time

## [2026-06-29] re-ingest | Golden Service — coffee-ordering-api (architecture context)
- Re-analyzed `coffee-ordering-service-test` with frontend-backend architecture context
- Updated all 5 `wiki/qa_patterns/` pages:
  - `project_structure.md` — added mocks/, scenarios.md, feature file split by type, tag-based naming
  - `scenario_patterns.md` — added architecture flow, H/N/B tagging, scenario types, coverage expectations
  - `error_testing.md` — added two-layer error origin (frontend validation vs backend error), mock requirements
  - `payload_management.md` — added tag-based naming convention, mocks/ directory, mock requirements table
  - `lifecycle_setup.md` — added mock considerations section
- Updated `wiki/apis/coffee-ordering.md` — added tag mapping for existing scenarios
- Updated `wiki/index.md` — re-ingestion recorded

## [2026-06-30] convention | mdg_test_scenario header
- Added `mdg_test_scenario` header requirement: every scenario request must include this header with its tag value (e.g., `H001`)
- Updated `AGENTS.md` generate workflow (step 8), validation checks (step 10), and rules section
- Updated `wiki/qa_patterns/scenario_patterns.md` — added Scenario Identification Header section, added header step to all Gherkin examples, updated common step patterns table
- Updated `wiki/qa_patterns/payload_management.md` — added header matching requirement for mock stubs
- Mock stubs now must include `mdg_test_scenario` header matching to ensure the correct stub responds for each scenario
