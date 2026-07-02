package uk.gov.gsi.hmrc.bdd;

import io.cucumber.spring.CucumberContextConfiguration;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@CucumberContextConfiguration
@SpringBootTest
public class CucumberTestContext {
    
    @Configuration
    @ComponentScan(basePackages = {
        "uk.gov.gsi.hmrc.bdd",
        "uk.gov.hmrc.eis.tests.cucumber"
    })
    @EnableAutoConfiguration
    public static class TestConfig {

    }

}