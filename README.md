# llm-wiki-bdd

An LLM-maintained knowledge base that catalogs your Cucumber step definitions and QA
testing patterns, then generates accurate, style-consistent BDD feature files from any
OpenAPI specification. No hallucinated steps. Human approval before output.

Instead of asking the LLM to guess how your custom step definitions map to an API,
the wiki acts as a **compiled dictionary** — it catalogs your available Cucumber steps,
extracts your QA team's testing conventions from existing `.feature` files, and uses
that knowledge to generate test suites that match your team's exact style.

The wiki compounds: every project you ingest makes future generations better.

## How It Works

```
                       ┌─────────────────────────────────────────────────────┐
                       │                     INGEST PHASE                    │
                       │  (run once per source; wiki compounds over time)    │
                       └─────────────────────────────────────────────────────┘
                                                  │
                    ┌─────────────────────────────┼─────────────────────────────┐
                    │                             │                             │
                    ▼                             ▼                             ▼
    ┌───────────────────────────┐   ┌──────────────────────────────┐   ┌──────────────────┐
    │  Step Definition Source   │   │  Golden Service Projects     │   │  New Specs       │
    │  (Java @Given/@When/@Then)│   │  (feature files, config,     │   │  (public/        │
    │  e.g. openapi-bdd         │   │   lifecycle, payloads)       │   │   openapi.yaml)  │
    └───────────┬───────────────┘   └──────────────┬───────────────┘   └────────┬─────────┘
                │                                  │                            │
                │ parse annotations                │ extract patterns           │ read fresh on
                │                                  │                            │ each generate
                ▼                                  ▼                            ▼
    ┌───────────────────────────┐   ┌──────────────────────────────┐   ┌──────────────────┐
    │  wiki/step_dictionary/    │   │  wiki/qa_patterns/           │   │  frontend spec   │
    │  ┌─────────────────────┐  │   │  ┌────────────────────────┐  │   │  backend spec    │
    │  │ http_method_steps   │  │   │  │ project_structure      │  │   │                  │
    │  │ request_payload_    │  │   │  │ scenario_patterns      │  │   │  Parse schemas,  │
    │  │   steps             │  │   │  │ error_testing          │  │   │  endpoints,      │
    │  │ parameter_steps     │  │   │  │ payload_management     │  │   │  responses       │
    │  │ authentication_     │  │   │  │ lifecycle_setup        │  │   │                  │
    │  │   steps             │  │   │  └────────────────────────┘  │   └────────┬─────────┘
    │  │ response_assertion_ │  │   └──────────────┬───────────────┘            │
    │  │   steps             │  │                  │                            │
    │  │ context_variable_   │  │                  │                            │
    │  │   steps             │  │                  ▼                            ▼
    │  │ helper_steps        │  │   ┌───────────────────────────────────────────────────────┐
    │  └─────────────────────┘  │   │                  GENERATE PHASE                       │
    │  (exact step expressions) │   │                                                       │
    └───────────┬───────────────┘   │  1. Reason about scenarios (Happy/Negative/Business)  │
                │                   │  2. Map each scenario to available steps from wiki    │
                │                   │  3. Generate payloads & mocks per scenario tag        │
                ▼                   │                                                       │
    ┌───────────────────────────┐   │                    ┌────────────────────┐             │
    │  Verify: every Gherkin    │   │                    │  For each scenario │             │
    │  step exists verbatim in  │   │                    │  (H001, N001,      │             │
    │  wiki/step_dictionary/    │   │                    │   B001, ...):      │             │
    └───────────────────────────┘   │                    │                    │             │
                                    │                    │  1. requestPayload │             │
                                    │                    │     /<TAG>.json    │             │
                                    │                    │  2. responsePayload│             │
                                    │                    │     /<TAG>.json    │             │
                                    │                    │  3. mocks/<TAG>.json             │
                                    │                    └────────────────────┘             │
                                    └──────────────────────────┬────────────────────────────┘
                                                               ▼
                                    ┌────────────────────────────────────────────────────┐
                                    │              GENERATED OUTPUT                      │
                                    │  ┌─────────────────────────────────────────────┐   │
                                    │  │ journey-<api-name>-service-test/            │   │
                                    │  │ ├── pom.xml                                 │   │
                                    │  │ ├── scenarios.md   (tabular doc)            │   │
                                    │  │ └── src/test/resources/                     │   │
                                    │  │     ├── features/                           │   │
                                    │  │     │   ├── happyPath.feature  (@H001,…)    │   │
                                    │  │     │   ├── negativePath.feature(@N001,…)   │   │
                                    │  │     │   └── businessScenarios.feature(@B…)  │   │
                                    │  │     ├── requestPayload/ (H001.json, …)      │   │
                                    │  │     ├── responsePayload/(H001.json, …)      │   │
                                    │  │     └── mocks/        (H001.json, …)        │   │
                                    │  └─────────────────────────────────────────────┘   │
                                    └────────────────────────────────────────────────────┘
```

## Getting Started

### Prerequisites

- An LLM agent (OpenCode, Claude Code, Codex, etc.) that can read `AGENTS.md` and follow instructions
- Your Cucumber step definition Java files (with `@Given`/`@When`/`@Then`/`@And` annotations)
- Existing QA-authored `.feature` files and test config from a real project (optional but recommended)
- An OpenAPI spec (YAML/JSON) for the API you want to generate tests for

### Quick Start

**1. Download the portable skeleton**

Use `llm-wiki-bdd-skeleton.zip` — unzip it on any machine.

**2. Configure your source paths**

Edit `SOURCES.md` to point to your actual projects:

```yaml
# SOURCES.md

step_definitions:
  - path: C:/Path/To/Your/StepDefinitionProject
    description: Your step definition library (LLM auto-discovers @Given/@When/@Then files)

golden_services:
  - path: C:/Path/To/Your/FirstTestProject
    description: First QA project (LLM scans *-test/ subdirs for feature files)
  - path: C:/Path/To/Your/SecondTestProject
    description: Second QA project (add as many as you want)

# frontend_spec: optional — defaults to public/openapi.yaml in project root
# backend_spec: optional — defaults to <current-working-dir>/assets/backend/openapi.yaml
# backend_spec:
#   - path: C:/Path/To/Your/BackendApi/openapi.yaml
#     description: Backend API spec for mock generation

```

> For `step_definitions`, point to the **project root directory**. The LLM recursively
> searches for all Java files containing Cucumber annotations. You don't need to specify
> individual files.
>

**3. Run the ingest command**

Tell your LLM:

```
Follow AGENTS.md. Read SOURCES.md and ingest everything into the wiki.
```

The LLM will:
- Find and parse all step definition files → build `wiki/step_dictionary/`
- Analyze your QA's `.feature` files and config → build `wiki/qa_patterns/`
- Document the example API → build `wiki/apis/`
- Create `wiki/index.md` and `wiki/log.md`

**4. Generate tests for a new API**

Add a new spec path to `SOURCES.md` and tell your LLM:

```
Generate tests for the new API spec from SOURCES.md.
```

The LLM will:
- Read the OpenAPI spec
- Consult the wiki (step dictionary + QA patterns)
- Draft and write a complete test suite to `<current-working-dir>/journey-<api-name>-service-test/`

Project Structure

```
llm-wiki-bdd/
├── AGENTS.md                    # Schema — tells the LLM how to maintain the wiki
├── opencode.json                # Permission config — pre-authorizes wiki/ and test output dirs
├── SOURCES.md                   # External path references to your projects (optional)
│
└── wiki/                        # LLM-maintained knowledge base (auto-generated)
    ├── step_dictionary/         # Catalog of known step definitions
    ├── qa_patterns/             # Your team's testing conventions and style
    ├── apis/                    # Documented APIs
    ├── index.md                 # Page catalog
    └── log.md                   # Append-only operation log
```

Generated test projects are created in the current working directory as `<current-working-dir>/journey-<api-name>-service-test/`,
mirroring the golden service layout.

## Workflows

### Ingest step definitions

The LLM reads your `@Given`/`@When`/`@Then`/`@And`-annotated Java classes and creates
categorized pages in `wiki/step_dictionary/` documenting each step's expression, method
signature, and usage examples from your golden feature files.

### Ingest golden services

The LLM reads the project path from `SOURCES.md`, scans for `*-test/` subdirectories, and extracts
your team's testing patterns — how scenarios are structured, how error cases are written,
how payloads are managed, how the app lifecycle is set up. Stored in
`wiki/qa_patterns/`.

### Generate tests

For a new OpenAPI spec, the LLM consults the wiki to match endpoints to available steps,
applies your team's conventions, and generates a complete test project. You review and
approve before anything is written.

### Clean and regenerate all

Wipe `wiki/` and any previously generated test directories, then re-ingest everything from
`SOURCES.md` and regenerate tests from scratch.

This workflow is pre-authorized — `opencode.json` grants automatic permission for
write operations inside `wiki/`. Just tell your LLM:

```
Follow AGENTS.md. Clean wiki/ completely, then ingest everything from SOURCES.md
and generate tests for the API spec in public/openapi.yaml.
```

### Lint (periodic)

Ask the LLM to health-check the wiki for orphan pages, stale claims, missing
cross-references, or gaps where the step library doesn't cover a pattern the spec needs.

## Making Wiki Knowledge Portable

Once ingested, the **wiki IS the portable knowledge**. It's just markdown files — copy
them anywhere.

### Moving the wiki to another machine

Copy only these two things:

```
llm-wiki-bdd/
├── AGENTS.md       # The schema — defines workflows and rules
└── wiki/           # All ingested knowledge (step dict, patterns, APIs, index, log)
```

That's it. On the new machine:

1. Create a `SOURCES.md` pointing to your new projects on that machine
2. Tell the LLM:
   ```
   Follow AGENTS.md. Read wiki/ for existing knowledge. Then ingest SOURCES.md.
   ```

The LLM reads the existing wiki first, then augments it with whatever new sources you
provide. No raw sources needed on the new machine — the compiled knowledge is already
in `wiki/`.

### Why this works

The wiki contains everything the LLM needs to generate tests:
- `step_dictionary/` — exact Gherkin expressions and method signatures
- `qa_patterns/` — scenario structures, error patterns, conventions
- `apis/` — endpoint schemas and testing notes

None of this changes unless your step definitions or testing style change (see below).

## Adding New Golden Service Projects

To compound the wiki with more example projects:

1. Add the new project path to `SOURCES.md`:
   ```yaml
   golden_services:
     - path: C:/Path/To/ExistingProject1
       description: First project
     - path: C:/Path/To/NewProject2          # <-- add this
       description: New project with different patterns
   ```

2. Tell the LLM:
   ```
   Ingest the new golden service at the path I just added to SOURCES.md.
   ```

The LLM reads the path, scans for `*-test/` subdirectories, extracts patterns from
`.feature` files and config, and updates existing wiki pages. For example, if the new
project uses a different assertion style or
auth pattern, the LLM adds it to `qa_patterns/`. The wiki compounds — next time
you generate tests, the LLM will know both styles.

## Re-Ingesting Updated Step Definitions

When your step definition library changes (new steps added, expressions modified):

1. Update `SOURCES.md` if the path changed, or just keep the existing path

2. Tell the LLM:
   ```
   Re-ingest step definitions from SOURCES.md. Update wiki/step_dictionary/ to
   reflect any changes, additions, or removals. Flag any breaking changes.
   ```

The LLM re-reads your Java files, compares against existing `wiki/step_dictionary/`
pages, and:
- Adds pages for new steps
- Updates expressions/method signatures for changed steps
- Removes pages for deleted steps
- Updates `index.md` and appends to `log.md`

### Detection of stale step definitions

You can also periodically ask:

```
Lint the wiki. Check if step_dictionary/ still matches the paths in SOURCES.md. Flag any discrepancies.
```

## Rules

- All generated steps use the `sg:` prefix
- The LLM only modifies `wiki/` and generated test projects; source files are never modified
- The LLM generates test projects directly without requiring approval
- If a needed step isn't in the wiki, the LLM flags it as a gap (never hallucinates)

## Acknowledgments

This project is based on the **LLM Wiki** pattern by [Andrej Karpathy](https://github.com/karpathy).

The core idea — using a persistent, LLM-maintained markdown wiki as a compiled knowledge
layer between raw source documents and generated output — is described in:
[https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)

This implementation adapts that pattern to the specific domain of OpenAPI-to-Cucumber
test generation, adding a structured step dictionary, QA pattern extraction, and
human-in-the-loop generation workflows.

## Portable Skeleton

The `llm-wiki-bdd-skeleton.zip` file contains everything you need to start fresh on any
machine: `AGENTS.md`, empty directory structure, `.gitignore`, and a template `SOURCES.md`.
No wiki content is included — it regenerates from your actual projects during ingest.
