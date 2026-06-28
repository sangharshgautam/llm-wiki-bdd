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
