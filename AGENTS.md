# llm-wiki-bdd

An LLM-powered wiki for generating Cucumber/BDD test suites from OpenAPI specifications. It sits between raw source files (step definitions,
golden feature files, OpenAPI specs) and generated test output.

## Directory Structure

- `raw_sources/` — Immutable source documents. NEVER modify.
  - `step_definitions/` — Step definition source files
  - `golden_services/<project>/` — Example BDD projects with feature files, config, and lifecycle setup
  - `new_specs/` — New API specs (OpenAPI, etc.) waiting to be processed
- `wiki/` — LLM-maintained knowledge base. Create and update freely.
  - `step_dictionary/` — Compiled catalog of known step definitions
  - `qa_patterns/` — Extracted testing conventions and style
  - `apis/` — Documented APIs that have been ingested
  - `index.md` — Catalog of all wiki pages
  - `log.md` — Append-only chronological record of operations
- `SOURCES.md` — Optional file listing external paths to reference projects without copying. See below.

## Workflows

### 0. External Source References (Optional)

Instead of copying files into `raw_sources/`, you can list external project paths in `SOURCES.md`.
The LLM will read directly from those paths.

Example `SOURCES.md`:
```markdown
# External Source References

step_definitions:
  - path: /path/to/step-definition-library
    description: Shared step definition library

golden_services:
  - path: /path/to/golden-project-1
    description: First reference test project (scans *-test/ subdirs)
  - path: /path/to/golden-project-2
    description: Second reference test project (scans *-test/ subdirs)

new_specs:
  - path: /path/to/new-api-spec.yaml
    description: New API under test
```

When `SOURCES.md` exists, the LLM reads external paths from it instead of
requiring files inside `raw_sources/`. You can mix both approaches.

For `step_definitions` paths that point to a directory (not a file), the LLM
must recursively search that directory for all files containing step definition markers
(`@Given`, `@When`, `@Then`, `@And`) — do not search outside the given path.

### 1. Ingest Step Definitions

Read step definition files (from `raw_sources/step_definitions/` or
`SOURCES.md`). For each step definition
marker (e.g., Cucumber annotations like `@Given`, `@When`, `@Then`, `@And`),
create or update a page in `wiki/step_dictionary/` grouped by category.

Discover categories dynamically from the steps found. Typical categories
include HTTP methods, request payloads, parameters, authentication, response
assertions, context variables, and helpers — but derive them from the actual
steps rather than assuming.

Each step page must document:
- The exact step expression (e.g. `sg: I send a POST request`)
- The method/function signature
- What the step does in plain language
- Concrete examples from golden feature files (quote the exact Gherkin)

### 2. Ingest Golden Features

Read `raw_sources/golden_services/<project>/` or paths from `SOURCES.md`. Each path points to a service project directory containing:
- `public/openapi.yaml` — the OpenAPI spec for the service
- `*-test/` — test subdirectories with feature files and config

For each path, list only its immediate subdirectories matching `*-test/` — do not search parent directories or the project root. For each found test subdirectory, discover the project structure automatically — look for:
- Feature files (`.feature`) — scenario structure, step sequencing, assertion style
- Test runner configuration
- Lifecycle setup (app startup/shutdown, host/port rewriting)
- Build/config files
- `requestPayload/` — request body JSON files referenced in feature files
- `responsePayload/` — expected response JSON files for file-based assertions
- `mocks/` or `mappings/` + `__files/` — WireMock stub mappings and response files
- Any other supporting file directories

Store the discovered file names, directory layout, and build tool in the wiki.

Update `wiki/qa_patterns/`:
- `project_structure.md` — how test projects are organized
- `scenario_patterns.md` — common scenario structures and flows
- `error_testing.md` — how 4xx/5xx error scenarios are written
- `payload_management.md` — inline JSON vs file reference conventions
- `lifecycle_setup.md` — app startup/shutdown, host/port rewriting patterns

### 3. Generate Tests for a New OpenAPI Spec

When the user adds a spec to `raw_sources/new_specs/` or `SOURCES.md` and asks to generate tests:

1. Read the OpenAPI spec (parse YAML for endpoints, operations, schemas, responses)
2. Read ALL pages in `wiki/step_dictionary/` and compile a complete list of every available step expression
3. For each endpoint+HTTP method, map it to steps from that list only. Do NOT write any step that is not in the list
4. If no existing step covers a required action (e.g., setting a specific header, asserting a nested field), flag it as a **gap** — do not invent a new step expression
5. Read the OpenAPI specs from each golden service's `public/openapi.yaml` and cross-reference how their endpoints map to test scenarios in corresponding `*-test/` feature files — use these as examples for mapping the new spec
6. Consult `wiki/qa_patterns/` to match the team's testing conventions
7. Draft the generated project at `<service-dir>/<api-name>-test/` (sibling to the spec's `public/` directory, mirroring the golden service layout) following the exact directory tree from `wiki/qa_patterns/project_structure.md`:
   - Java files (`CucumberTest.java`, lifecycle setup) go under `src/test/java/<package>/`
   - Feature files go under `src/test/resources/features/` organized as:
     - `happyPath.feature` — all 2xx scenarios, each tagged `@H001`, `@H002`, …
     - `negativePath.feature` — all 4xx/5xx error scenarios, each tagged `@N001`, `@N002`, …
     - `businessScenarios.feature` — business rule violations, validation failures, each tagged `@B001`, `@B002`, …
   - Config files (`junit-platform.properties`) go under `src/test/resources/`
   - `requestPayload/` — request body JSON files named by scenario tag (e.g., `H001.json`)
   - `responsePayload/` — expected response JSON files named by scenario tag (e.g., `H001.json`)
   - `mocks/` — mock/stub JSON files named by scenario tag (e.g., `H001.json`)
   - Build file (`pom.xml`) goes at the project root
8. Before finalizing, verify **every single Gherkin step line** against the compiled step list. If any step doesn't match exactly, remove it and either replace with an existing step or flag as a gap
9. Write all files to `<service-dir>/<api-name>-test/`

#### Coverage expectations per endpoint:
- **Happy path** (2xx) with field-level assertions on key response fields
- **Each documented 4xx error** — at least one scenario per error code
- **5xx error** if documented in the spec
- **Response time** assertion
- **Content type** assertion
- **Schema validation** if applicable — use assertion steps from `wiki/step_dictionary/`

### 4. Update Wiki After Approval

After user approves generated tests:
- Create `wiki/apis/<api-name>.md` documenting the new API
- Update `wiki/index.md` with new page entries
- Append entry to `wiki/log.md`

### 5. Portable Wiki (Move Without Raw Sources)

When the user moves `wiki/` and `AGENTS.md` to a new machine (without raw sources):

1. Read the existing `wiki/` pages to understand current knowledge
2. Read `SOURCES.md` or `raw_sources/` for any new sources on the new machine
3. If no new sources exist on the new machine, report that the wiki is
   self-contained and ready to generate tests from existing knowledge alone
4. Update `wiki/log.md` with the relocation

### 6. Add New Golden Feature Sources

When the user adds a new golden service project path to `SOURCES.md` (or drops
files into `raw_sources/golden_services/`) and asks to ingest:

1. Read the path, find `public/openapi.yaml` and scan for `*-test/` subdirectories
2. Compare patterns against existing `wiki/qa_patterns/`
3. Update relevant pages with new patterns, noting differences from existing ones
4. Create `wiki/apis/<new-api>.md` if applicable
5. Update `wiki/index.md` and append to `wiki/log.md`

### 7. Re-Ingest Updated Step Definitions

When step definitions change (user modifies source files or updates the path):

1. Re-read all step definition files from `SOURCES.md` or `raw_sources/`
2. Compare against existing `wiki/step_dictionary/` pages
3. For each change:
   - **New step** — add a new entry to the appropriate category page
   - **Modified step** — update the expression, method, and usage notes
   - **Removed step** — mark as deprecated or remove, noting in log
4. Flag breaking changes (expression syntax changed, method signature changed)
5. Check existing test projects (from golden services or previous generations) for any feature files that reference removed/modified steps
6. Update `wiki/index.md` and append to `wiki/log.md`

### 8. Lint (Periodic)

Scan `wiki/` for:
- Orphan pages with no inbound links from other wiki pages
- Stale claims contradicted by newer source ingests
- Missing cross-references between step dictionary and QA patterns
- Gaps where the step library doesn't cover a pattern needed by a known spec
- Step dictionary entries that no longer match the actual source files

## Rules

- ALL step references in generated feature files MUST use the step prefix documented in `wiki/step_dictionary/` (e.g., `sg:`)
- Generated project directory name: derive from the OpenAPI spec's `info.title` — convert to kebab-case and append `-service-test`. E.g., "FleetRoute AI Optimization API" → `fleetroute-service-test`
- Host placeholder convention: derive from the API name (e.g., `<api-name>-api`)
- The generated project must follow the exact conventions documented in `wiki/qa_patterns/`:
  - `project_structure.md` — directory layout, config files, build tool
  - `lifecycle_setup.md` — how the app under test is started/stopped, host/port rewriting
  - `payload_management.md` — inline JSON vs file-based payloads
- For each POST/PUT endpoint with a request body schema, generate a request payload JSON file in `requestPayload/`
- For each non-trivial response schema, generate a response payload JSON file in `responsePayload/` for file-based assertions
- If the golden services use mocks (WireMock or similar), generate `mocks/` or `mappings/` + `__files/` with stubs matching the new API's endpoints
- NEVER hallucinate step definitions. If a needed step is not in `wiki/step_dictionary/`, flag it as a gap.
- If the lifecycle or config patterns from `wiki/qa_patterns/` don't apply to this project, flag the gap
- Validate all generated files against the rules above before writing

## Validation Before Generating

Before writing files, verify:
1. Every Gherkin step in the feature file exists **verbatim** in `wiki/step_dictionary/` — match the exact expression including prefix (e.g., `sg:`)
2. Host placeholder is consistent across all generated files
3. Payload file references match actual files in the generated structure
4. All generated config files follow the patterns in `wiki/qa_patterns/`
5. The scenario count provides reasonable coverage (happy path + all error codes)
6. If any step had to be invented (not in step dictionary), flag it as a gap instead of generating it
7. Output location: `<service-dir>/<api-name>-test/`
