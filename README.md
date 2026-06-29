# llm-wiki-bdd

An LLM-maintained knowledge base that catalogs your Cucumber step definitions and QA
testing patterns, then generates accurate, style-consistent BDD feature files from any
OpenAPI specification. No hallucinated steps. Human approval before output.

Instead of asking the LLM to guess how your custom step definitions map to an API,
the wiki acts as a **compiled dictionary** — it catalogs your available Cucumber steps,
extracts your QA team's testing conventions from existing `.feature` files, and uses
that knowledge to generate test suites that match your team's exact style.

The wiki compounds: every project you ingest makes future generations better.

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

golden_features:
  - path: C:/Path/To/Your/FirstTestProject
    description: First QA project with feature files
  - path: C:/Path/To/Your/SecondTestProject
    description: Second QA project (add as many as you want)

new_specs:
  - path: C:/Path/To/Your/NewApi/openapi.yaml
    description: New API spec to generate tests for
```

> For `step_definitions`, point to the **project root directory**. The LLM recursively
> searches for all Java files containing Cucumber annotations. You don't need to specify
> individual files.
>
> Alternatively, copy files directly into `raw_sources/` instead of using `SOURCES.md`
> (see `raw_sources/` structure below).

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

Add a new spec path to `SOURCES.md` (or drop it in `raw_sources/new_specs/`) and tell your LLM:

```
Generate tests for the new API spec from SOURCES.md.
```

The LLM will:
- Read the OpenAPI spec
- Consult the wiki (step dictionary + QA patterns)
- Draft a complete test suite (feature file, config, payloads)
- Present it for your review
- Write to `generated/` only after your approval

## Project Structure

```
llm-wiki-bdd/
├── AGENTS.md                    # Schema — tells the LLM how to maintain the wiki
├── SOURCES.md                   # External path references to your projects (optional)
│
├── raw_sources/                 # Immutable source files (or use SOURCES.md instead)
│   ├── step_definitions/        # Your Java step definition files
│   ├── golden_features/<project>/  # Existing QA feature files + test config
│   └── new_specs/               # New OpenAPI specs to process
│
├── wiki/                        # LLM-maintained knowledge base (auto-generated)
│   ├── step_dictionary/         # Catalog of available Cucumber steps
│   ├── qa_patterns/             # Your team's testing conventions and style
│   ├── apis/                    # Documented APIs
│   ├── index.md                 # Page catalog
│   └── log.md                   # Append-only operation log
│
└── generated/                   # Generated test output (written after your approval)
    └── <api-name>-service-test/
        └── (structure follows wiki/qa_patterns/project_structure.md)
```

## Workflows

### Ingest step definitions

The LLM reads your `@Given`/`@When`/`@Then`/`@And`-annotated Java classes and creates
categorized pages in `wiki/step_dictionary/` documenting each step's expression, method
signature, and usage examples from your golden feature files.

### Ingest golden features

The LLM reads existing `.feature` files and test project configuration to extract your
team's testing patterns — how scenarios are structured, how error cases are written,
how payloads are managed, how Spring Boot lifecycle is set up. Stored in
`wiki/qa_patterns/`.

### Generate tests

For a new OpenAPI spec, the LLM consults the wiki to match endpoints to available steps,
applies your team's conventions, and generates a complete test project. You review and
approve before anything is written.

### Clean and regenerate all

Wipe `wiki/` and `generated/`, then re-ingest everything from `SOURCES.md` and regenerate
tests from scratch.

This workflow is pre-authorized — `opencode.json` grants automatic permission for
write operations inside `wiki/` and `generated/`. Just tell your LLM:

```
Follow AGENTS.md. Clean wiki/ and generated/ completely, then ingest
everything from SOURCES.md and generate tests for each new_specs entry.
Present the output for approval before finalizing.
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

1. Create a `SOURCES.md` (or `raw_sources/`) pointing to your new projects on that machine
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

## Adding New Golden Feature Sources

To compound the wiki with more example projects:

1. Add the new project path to `SOURCES.md`:
   ```yaml
   golden_features:
     - path: C:/Path/To/ExistingProject1
       description: First project
     - path: C:/Path/To/NewProject2          # <-- add this
       description: New project with different patterns
   ```

2. Tell the LLM:
   ```
   Ingest the new golden feature project at the path I just added to SOURCES.md.
   ```

The LLM reads the new `.feature` files, extracts patterns, and updates existing
wiki pages. For example, if the new project uses a different assertion style or
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
Lint the wiki. Check if step_dictionary/ still matches raw_sources/step_definitions/
or the paths in SOURCES.md. Flag any discrepancies.
```

## Rules

- All generated steps use the `sg:` prefix
- Host placeholder convention: `<api-name>-api` (e.g., `coffee-api`, `fleetroute-api`)
- The LLM never modifies `raw_sources/`
- The LLM never writes to `generated/` without your approval
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
