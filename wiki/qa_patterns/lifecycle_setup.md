# Lifecycle Setup

Spring Boot application lifecycle management for BDD tests.

## AppSetup Pattern

The test project uses a dedicated `AppSetup` class with Cucumber's `@BeforeAll`/`@AfterAll` annotations to start and stop the application under test.

```java
package com.example.coffee.steps;

import com.example.api.steps.ApiStepDefinitions;
import com.example.coffee.CoffeeOrderingApplication;
import io.cucumber.java.AfterAll;
import io.cucumber.java.BeforeAll;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.ConfigurableApplicationContext;

public class AppSetup {

    private static ConfigurableApplicationContext context;

    @BeforeAll
    public static void startApp() {
        context = new SpringApplicationBuilder(CoffeeOrderingApplication.class)
                .properties("server.port=0")
                .run();
        int port = Integer.parseInt(context.getEnvironment().getProperty("local.server.port"));
        ApiStepDefinitions.setTargetPort(port);
        ApiStepDefinitions.setBaseHost("coffee-api");
    }

    @AfterAll
    public static void stopApp() {
        if (context != null) {
            context.close();
        }
    }
}
```

## Key Mechanics

1. **Random port**: `server.port=0` lets Spring Boot pick an available port
2. **Port propagation**: The actual port is passed to `ApiStepDefinitions.setTargetPort()`
3. **Host rewriting**: `ApiStepDefinitions.setBaseHost("coffee-api")` enables URL rewriting
   - When a feature file uses `http://coffee-api/api/orders`, the step definition rewrites it to `http://localhost:<dynamic-port>/api/orders`
4. **Cleanup**: `@AfterAll` gracefully closes the application context

## Mock Considerations

The coffee-ordering golden service does NOT use external mocks — it starts the real Spring Boot application. For projects with frontend-backend architecture where the backend is mocked:

- The `mocks/` directory contains stub JSON files
- Mock setup steps would appear in the feature file before the request is sent
- If the test framework supports WireMock or similar, the lifecycle setup would include mock server startup/teardown alongside the app context

## Glue Configuration

The `AppSetup` class must be in a package included in the Cucumber glue:

```properties
cucumber.glue=com.example.api.steps,<project>.steps
```

- `com.example.api.steps` — Step definitions from openapi-bdd
- `<project>.steps` — Lifecycle hooks (AppSetup)
