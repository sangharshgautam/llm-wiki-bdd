# llm-wiki-bdd

An LLM-powered wiki for generating Cucumber/BDD test suites from OpenAPI specifications. It sits between raw source files (step definitions,
golden feature files, OpenAPI specs) and generated test output.

## Directory Structure

- `raw_sources/` — Immutable source documents. NEVER modify.
  - `step_definitions/` — Step definition source files
  - `golden_services/<project>/` — Example BDD projects with feature files, config, and lifecycle setup
  - `frontend_spec/` — New frontend API specs (OpenAPI, etc.) waiting to be processed
  - `backend_spec/` — New backend API specs (OpenAPI, etc.) waiting to be processed
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

### 2. Ingest Golden Features

Read `raw_sources/golden_services/<project>/` or paths from `SOURCES.md`. Each path points to a service project root directory containing:
- `public/openapi.yaml` — the OpenAPI spec for the service
- `*-test/` — one or more immediate subdirectories with feature files and config

For each given path, list its **immediate child directories** and filter those whose name ends with `-test`. These are the test subdirectories (e.g., `coffee-ordering-service-test/`). Do NOT go up to parent directories, and do NOT treat the project root itself as a test directory. For each found `*-test/` subdirectory, discover the project structure automatically — look for:
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

### 3. Generate Tests

When the user asks to generate tests (after ingest is complete), do NOT re-ingest or re-read source files. Use only what is already in the wiki:

1. **Read both target specs**: Parse the frontend OpenAPI spec and backend OpenAPI spec from their `SOURCES.md` paths (`frontend_spec` and `backend_spec`). These are the new specs under test and must be read fresh. Extract `<api-name>` from the frontend spec's `info.x-integration-catalogue.publisher-reference` — this value determines the project directory name and wiki page name. Understand the service architecture: frontend Camel REST service validates requests against the frontend request schema, transforms via XSLT, validates against the backend request schema, forwards to backend, validates the backend response against the backend response schema, transforms back, validates against the frontend response schema, and returns.

2. **Read golden examples from wiki**: Read `wiki/qa_patterns/` and `wiki/apis/` for scenario patterns, testing conventions, and example API docs. Do NOT re-read golden service source files — the wiki already contains the extracted knowledge.

3. **Compile step dictionary**: Read ALL pages in `wiki/step_dictionary/` and compile a complete list of every available step expression. Do NOT re-read step definition source files.

4. **Reason about scenarios**: For each endpoint/operation in the frontend spec, reason through the full flow:
   - **Happy path** — a valid frontend request is sent, backend responds with a valid response, and the expected frontend response is returned. Mock the backend with a valid stub derived from the backend spec.
   - **Negative path** — frontend validation rejects (4xx), backend returns error (4xx/5xx), or transforms fail.
   - **Business scenarios** — valid-by-schema requests that violate business rules (e.g., duplicate ID, out-of-range values, conflicting state).

5. **Map endpoints to steps**: For each scenario, map the required actions (request setup, assertions, mocks, etc.) to steps from the compiled dictionary only. Use the **step expression** (e.g., `sg: I send a POST request`) — do NOT copy example data or placeholder URLs from the dictionary pages. Generate fresh URIs, field names, and payloads from the target spec's schemas. Do NOT write any step that is not in the list. If no existing step covers a required action, flag it as a **gap** — do not invent a new step expression.

6. **Consult QA patterns**: Follow conventions from `wiki/qa_patterns/` for scenario structure, payload management, lifecycle setup, and error testing.

7. **Draft the generated project** at `<current-working-dir>/journey-<api-name>-service-test/` (in the current working directory) with this structure:
    ```
    journey-<api-name>-service-test/
    ├── pom.xml (or equivalent build file)
    ├── src/
    │   └── test/
    │       ├── java/<package>/
    │       │   ├── CucumberTest.java (or equivalent runner)
    │       │   └── AppSetup.java (or equivalent lifecycle setup)
    │       └── resources/
    │           ├── features/
    │           │   ├── happyPath.feature      — 2xx scenarios, tagged @H001, @H002, …
    │           │   ├── negativePath.feature    — 4xx/5xx error scenarios, tagged @N001, @N002, …
    │           │   └── businessScenarios.feature — business rule violations, tagged @B001, @B002, …
    │           ├── requestPayload/
    │           │   ├── H001.json              — H001's valid frontend request body
    │           │   └── …
    │           ├── responsePayload/
    │           │   ├── H001.json              — H001's expected frontend response body
    │           │   └── …
    │           ├── mocks/
    │           │   ├── H001.json              — H001's backend stub (derived from backend spec)
    │           │   └── …
    │           └── junit-platform.properties (or equivalent config)
    └── scenarios.md                           — explanation of every scenario in tabular form
    ```

8. **For each scenario, generate the following**:
    - **Feature file scenario** — Gherkin steps for the test
    - **Request payload** (`requestPayload/<TAG>.json`) — valid/invalid frontend request body matching the operation's request schema
    - **Response payload** (`responsePayload/<TAG>.json`) — expected frontend response body for assertion
    - **Backend mock** (`mocks/<TAG>.json`) — stub derived from the backend spec's endpoint and response schema (for H scenarios, a valid 200 stub; for N scenarios, the relevant error stub)
    - **All payload/mock files named by scenario tag** — `H001.json`, `N001.json`, `B001.json`, etc.

9. **Generate `scenarios.md`** — place at the project root documenting all scenarios in tabular form:
    ```markdown
    # Scenarios — <api-name>

    | Tag  | Type     | Description                        | Request Payload           | Mock                        | Expected Response           |
    |------|----------|------------------------------------|---------------------------|-----------------------------|-----------------------------|
    | H001 | Happy    | Valid request returns 200 OK       | requestPayload/H001.json  | mocks/H001.json (backend)   | responsePayload/H001.json   |
    | H002 | Happy    | Valid request with optional fields  | requestPayload/H002.json  | mocks/H002.json (backend)   | responsePayload/H002.json   |
    | N001 | Negative | Missing required field returns 400  | requestPayload/N001.json  | —                           | —                           |
    | N002 | Negative | Backend returns 500                 | requestPayload/N002.json  | mocks/N002.json (backend)   | responsePayload/N002.json   |
    | B001 | Business | Duplicate ID returns 409            | requestPayload/B001.json  | —                           | responsePayload/B001.json   |
    ```

    Include columns: Tag, Type (Happy/Negative/Business), Description, Request Payload (file path), Mock (file path), Expected Response (file path).

10. **Before finalizing**, verify:
    - Every Gherkin step line exists **verbatim** in `wiki/step_dictionary/` — match the exact expression including prefix
    - Every payload file referenced in feature files exists in `requestPayload/` or `responsePayload/`
    - Every mock file referenced exists in `mocks/`
    - The scenario count provides reasonable coverage

11. Write all files to `<current-working-dir>/journey-<api-name>-service-test/`

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
- Generated project directory name: STRICTLY `journey-<lowercase-kebab-of-publisher-reference>-service-test`. Never deviate from this convention. E.g., if `publisher-reference` is "FleetRoute" → `journey-fleetroute-service-test`, if it's "coffee ordering api" → `journey-coffee-ordering-service-test`
- **Overwrite existing files**: If the target directory `<current-working-dir>/journey-<api-name>-service-test/` already exists and contains files, overwrite/replace every file. Do not merge — regenerate all files fresh.
- The generated project must follow the exact conventions documented in `wiki/qa_patterns/`:
  - `project_structure.md` — directory layout, config files, build tool
  - `lifecycle_setup.md` — how the app under test is started/stopped, host/port rewriting
  - `payload_management.md` — inline JSON vs file-based payloads
- **Payload and mock file naming**: Every scenario payload and mock file MUST be named by its scenario tag (e.g., `H001.json`, `N001.json`, `B001.json`) — never by endpoint name or other convention
- **For each happy path scenario (H-tagged)**: generate all three files:
  - `requestPayload/H001.json` — valid frontend request body per the frontend spec request schema
  - `responsePayload/H001.json` — expected frontend response body per the frontend spec response schema
  - `mocks/H001.json` — a valid backend stub derived from the backend spec's corresponding endpoint and response schema
- **For each negative scenario (N-tagged)**: if the error originates from the backend, include a mock; if it's frontend-side validation (4xx), no mock is needed
- **For each business scenario (B-tagged)**: include request and response payloads; include a backend mock only if the business validation requires backend interaction
- **Backend mock content**: must be derived from the backend spec's response schema for the relevant operation — a valid response stub for the scenario (e.g., 200 for happy, 400/500 for error)
- **Every generated project must include `scenarios.md`** at the root, documenting all scenarios in tabular form
- NEVER hallucinate step definitions. If a needed step is not in `wiki/step_dictionary/`, flag it as a gap.
- If the lifecycle or config patterns from `wiki/qa_patterns/` don't apply to this project, flag the gap
- Validate all generated files against the rules above before writing

## Validation Before Generating

Before writing files, verify:
1. Every Gherkin step in the feature file exists **verbatim** in `wiki/step_dictionary/` — match the exact expression including prefix (e.g., `sg:`)
2. Payload file references match actual files in the generated structure
3. All generated config files follow the patterns in `wiki/qa_patterns/`
4. The scenario count provides reasonable coverage (happy path + all error codes + business scenarios)
5. For each scenario tag (H/N/B), the corresponding `requestPayload/<TAG>.json`, `responsePayload/<TAG>.json`, and `mocks/<TAG>.json` (where applicable) all exist and are referenced correctly in feature files
6. `scenarios.md` is present at the project root with all scenarios documented in tabular form
7. If any step had to be invented (not in step dictionary), flag it as a gap instead of generating it
8. Output location: `<current-working-dir>/journey-<api-name>-service-test/`
