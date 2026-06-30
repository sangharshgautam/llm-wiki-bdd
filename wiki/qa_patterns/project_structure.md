# Project Structure

How Cucumber BDD test projects are organized. This is the target structure that generated projects follow.

## Directory Layout

```
journey-<api-name>-service-test/
├── pom.xml                              # Build file (e.g., Maven)
├── scenarios.md                         # Tabular documentation of all scenarios
└── src/test/
    ├── java/
    │   └── <package>/
    │       ├── CucumberTest.java        # JUnit Platform Suite runner
    │       └── steps/
    │           └── AppSetup.java        # @BeforeAll / @AfterAll lifecycle hooks
    └── resources/
        ├── features/
        │   ├── happyPath.feature        # 2xx scenarios, tagged @H001, @H002, …
        │   ├── negativePath.feature     # 4xx/5xx error scenarios, tagged @N001, @N002, …
        │   └── businessScenarios.feature # Business rule violations, tagged @B001, @B002, …
        ├── junit-platform.properties    # Cucumber/JUnit configuration
        ├── requestPayload/              # Request body JSON files named by tag (H001.json, …)
        ├── responsePayload/             # Expected response JSON files named by tag (H001.json, …)
        └── mocks/                       # Backend stub JSON files named by tag (H001.json, …)
```

## Key Conventions

- **Test runner**: JUnit Platform Suite with `@IncludeEngines("cucumber")` and `@SelectClasspathResource("features")`
- **Lifecycle hooks**: Cucumber's `@BeforeAll`/`@AfterAll` (not JUnit's) in a separate step class
- **Step definitions**: Imported from `openapi-bdd` Maven artifact — no step defs in the test project itself
- **Payload files**: Stored on the classpath under `requestPayload/`, `responsePayload/`, and `mocks/`, referenced by filename without extension
- **Payload/Mock naming**: All files named by scenario tag (e.g., `H001.json`) — never by descriptive name
- **Glue packages**: Two packages — one for step definitions (`com.example.api.steps` from openapi-bdd) and one for lifecycle hooks (`<project>.steps`)
- **scenarios.md**: Every generated project includes a `scenarios.md` at the root documenting all scenarios in tabular form (Tag, Type, Description, Request Payload, Mock, Expected Response)
