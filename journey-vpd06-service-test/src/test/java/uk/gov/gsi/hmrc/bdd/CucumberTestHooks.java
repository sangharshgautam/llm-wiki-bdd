package uk.gov.gsi.hmrc.bdd;

import io.cucumber.java.After;
import io.cucumber.java.BeforeAll;
import io.cucumber.java.AfterAll;
import io.cucumber.java8.En;
import lombok.extern.slf4j.Slf4j;
import uk.gov.hmrc.eis.tests.cucumber.ScenarioContext;
import uk.gov.hmrc.eis.tests.cucumber.service.*;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;

@Slf4j
public class CucumberTestHooks implements En {
    private static final String JOURNEY_NAME = System.getProperty("journeyName");  // value from pom.xml
    static ScenarioContext scenarioContext;
    static ReportService reportService;
    static CurlGenerationService curlGenerationService;

    public CucumberTestHooks(ScenarioContext scenarioContext, ReportService reportService, CurlGenerationService curlGenerationService) {
        CucumberTestHooks.reportService = reportService;
        CucumberTestHooks.curlGenerationService = curlGenerationService;
        CucumberTestHooks.scenarioContext = scenarioContext;
        Before(scenarioContext::setScenario);
    }

    @BeforeAll
    public static void wiremockStartup() throws IOException, NoSuchAlgorithmException, KeyManagementException {
        log.info("********* Wiremock startup, calling host ==> {}", WiremockURLService.getUrl());
        log.info("********* Wiremock creating mappings for {}", JOURNEY_NAME);
        WiremockHttpService.deleteMappings(JOURNEY_NAME);
        WiremockJSONMockService.sendJsonFiles(JOURNEY_NAME);
    }

    @AfterAll
    public static void wiremockTeardown() throws NoSuchAlgorithmException, KeyManagementException {
        log.info("********* Wiremock tearDown, removing all mappings for {}", JOURNEY_NAME);
        WiremockHttpService.deleteMappings(JOURNEY_NAME);
    }

    @After
    public void afterEachScenario() throws Exception {
        reportService.attachScenarioSummary();
        curlGenerationService.produceCurlFile();
    }
}
