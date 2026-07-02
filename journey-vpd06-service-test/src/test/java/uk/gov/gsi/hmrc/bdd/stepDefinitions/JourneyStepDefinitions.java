package uk.gov.gsi.hmrc.bdd.stepDefinitions;

import com.fasterxml.jackson.databind.JsonNode;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java8.En;
import lombok.RequiredArgsConstructor;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import uk.gov.hmrc.eis.tests.cucumber.ScenarioContext;
import uk.gov.hmrc.eis.tests.cucumber.service.DataSubstitutionService;
import uk.gov.hmrc.eis.tests.cucumber.service.JsonDeserializationService;
import uk.gov.hmrc.eis.tests.cucumber.service.JsonManipulationService;
import uk.gov.hmrc.eis.tests.cucumber.service.PayloadService;
import uk.gov.hmrc.eis.tests.cucumber.service.assertions.JsonAssertionService;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@RequiredArgsConstructor
public class JourneyStepDefinitions implements En {

    private final ScenarioContext testContext;
    private final PayloadService payloadService;
    private final DataSubstitutionService dataSubstitutionService;
    private final JsonAssertionService jsonAssertionService;
    private final JsonManipulationService jsonManipulationService;
    private final JsonDeserializationService jsonDeserializationService;

    @Then("the correlation id is returned")
    public void checkCorrelationId(){
        assertEquals(testContext.getJourneyRequestHeaders().get("x-correlation-id"), testContext.getJourneyResponse().getHeaders().get("x-correlation-id").get(0));
    }

    @Then("the date header is returned in http format")
    public void checkDateHeader() {
        assertTrue(testContext.getJourneyResponse().getHeaders().containsKey("date"));
        String dateHeader = testContext.getJourneyResponse().getHeaders().get("date").get(0);
        try {
            LocalDateTime.parse(dateHeader, DateTimeFormatter.RFC_1123_DATE_TIME);
        } catch(DateTimeParseException e) {
            fail("Failed to parse date " + dateHeader + " with format RFC_1123_DATE_TIME ," +
                    " with exception - " + e.getMessage());
        }
    }

    @Then("the response body is not null")
    public void checkResponseBodyExists() {
        assertNotNull(testContext.getJourneyResponse().getBody());
    }

    @Then("the response body should extend the Common Error Detail JSON with the following values")
    public void checkErrorDetail(DataTable dataTable) throws IOException, JsonDeserializationService.JsonDeserializationServiceException {
        String expectedJSON = payloadService.loadResponsePayload("errorDetail");
        String actualJSON = testContext.getJourneyResponse().getBody();
        Map<String, String> replacementValues = dataSubstitutionService.processDataTable(dataTable);

        // Error detail includes correlationId
        replacementValues.put("/errorDetail/correlationId", testContext.getCorrelationId());

        expectedJSON = jsonManipulationService.setNodes(expectedJSON, replacementValues);
        jsonAssertionService.assertJsonStringsExtensibleUnorderedEqual(expectedJSON, actualJSON);

        // Error detail should also include timestamp and sourceFaultDetail:
        JsonNode responseJSON = jsonDeserializationService.jsonStringToJsonNode(actualJSON);
        assertNotNull(responseJSON.findValue("timestamp"), "timestamp missing");
        assertNotNull(responseJSON.findValue("detail"), "detail missing");
    }

    @Then("the response body should extend the Error Detail JSON {} with the following values")
    public void checkErrorDetail(String payloadFileName, DataTable dataTable) throws IOException, JsonDeserializationService.JsonDeserializationServiceException {
        String expectedJSON = payloadService.loadResponsePayload(payloadFileName);
        String actualJSON = testContext.getJourneyResponse().getBody();
        System.out.print("actual payload " + actualJSON);
        Map<String, String> replacementValues = dataSubstitutionService.processDataTable(dataTable);

        // Error detail includes correlationId
        replacementValues.put("/errorDetail/correlationId", testContext.getCorrelationId());
        JSONObject responseJSONobj = new JSONObject(actualJSON);
        String timeStamp = responseJSONobj.getJSONObject("errorDetail").getString("timestamp");

        replacementValues.put("/errorDetail/timestamp", timeStamp);

        expectedJSON = jsonManipulationService.setNodes(expectedJSON, replacementValues);
        jsonAssertionService.assertJsonStringsExtensibleUnorderedEqual(expectedJSON, actualJSON);

        // Error detail should also include timestamp and sourceFaultDetail:
        JsonNode responseJSON = jsonDeserializationService.jsonStringToJsonNode(actualJSON);
        assertNotNull(responseJSON.findValue("timestamp"), "timestamp missing");
        assertNotNull(responseJSON.findValue("detail"), "detail missing");
    }


    @And("the sourcefaultdetail should contain the following details")
    public void checkDetailValues(List<String> expectedDetails) {

        String response = testContext.getJourneyResponse().getBody();
        JSONObject responseJSON = new JSONObject(response);
        System.out.println("RESPONSE: " + responseJSON);
        System.out.println("EXPECTED: " + expectedDetails);
        JSONArray detailList = responseJSON.getJSONObject("errorDetail").getJSONObject("sourceFaultDetail").getJSONArray("detail");
        for (String expectedDetail : expectedDetails) {
            assertTrue(jsonArrayContains(detailList, expectedDetail), "expected value missing from detail list");
        }
    }

    private boolean jsonArrayContains(JSONArray jsonArray, String value) {
        for (int i = 0; i < jsonArray.length(); i++) {
            if(jsonArray.getString(i).equals(value)) return true;
        }
        return false;
    }
}