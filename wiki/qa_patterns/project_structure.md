# Project Structure

How Cucumber BDD test projects are organized, based on `coffee-ordering-service-test`.

## Directory Layout

```
<project>-service-test/
├── pom.xml
└── src/test/
    ├── java/
    │   └── <package>/
    │       ├── CucumberTest.java          # JUnit Platform Suite runner
    │       └── steps/
    │           └── AppSetup.java          # @BeforeAll / @AfterAll lifecycle hooks
    └── resources/
        ├── features/
        │   └── <api-name>.feature         # Gherkin feature file
        ├── junit-platform.properties      # Cucumber/JUnit configuration
        ├── requestPayload/                # JSON files for request bodies
        └── responsePayload/               # JSON files for expected responses
```

## Key Conventions

- **Test runner**: JUnit Platform Suite with `@IncludeEngines("cucumber")` and `@SelectClasspathResource("features")`
- **Lifecycle hooks**: Cucumber's `@BeforeAll`/`@AfterAll` (not JUnit's) in a separate step class
- **Step definitions**: Imported from `openapi-bdd` Maven artifact — no step defs in the test project itself
- **Payload files**: Stored on the classpath under `requestPayload/` and `responsePayload/`, referenced by filename without extension
- **Glue packages**: Two packages — one for step definitions (`com.example.api.steps` from openapi-bdd) and one for lifecycle hooks (`<project>.steps`)
