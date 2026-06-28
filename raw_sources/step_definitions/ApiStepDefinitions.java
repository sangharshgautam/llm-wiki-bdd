package com.example.api.steps;

import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import static io.restassured.RestAssured.*;
import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchema;
import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class ApiStepDefinitions {

    private static String baseHost = "api.example.com";
    private static int targetPort = -1;

    public static void setTargetPort(int port) {
        targetPort = port;
    }

    public static void setBaseHost(String host) {
        baseHost = host;
    }

    private String baseUrl;
    private RequestSpecification request;
    private Response response;
    private String requestBody;
    private Map<String, String> headers = new HashMap<>();
    private Map<String, String> queryParams = new HashMap<>();
    private Map<String, String> pathParams = new HashMap<>();

    @Given("sg: I have a REST API endpoint at {string}")
    public void iHaveARESTAPIEndpointAt(String url) {
        if (targetPort > 0) {
            this.baseUrl = url.replace("https://" + baseHost, "http://localhost:" + targetPort)
                              .replace("http://" + baseHost, "http://localhost:" + targetPort);
        } else {
            this.baseUrl = url;
        }
        request = given();
    }

    @And("sg: I have the following request body:")
    public void iHaveTheFollowingRequestBody(String body) {
        this.requestBody = body;
        request.body(body);
    }

    @And("sg: I have request payload from file {string}")
    public void iHaveRequestPayloadFromFile(String fileName) {
        try {
            String path = "requestPayload/" + fileName + ".json";
            InputStream is = getClass().getClassLoader().getResourceAsStream(path);
            if (is == null) {
                throw new RuntimeException("Request payload not found on classpath: " + path);
            }
            String content = new String(is.readAllBytes());
            this.requestBody = content;
            request.body(content);
        } catch (IOException e) {
            throw new RuntimeException("Failed to read request payload file: " + fileName + ".json", e);
        }
    }

    @And("sg: I have the following headers:")
    public void iHaveTheFollowingHeaders(io.cucumber.datatable.DataTable dataTable) {
        Map<String, String> headerMap = dataTable.asMap(String.class, String.class);
        headers.putAll(headerMap);
        for (Map.Entry<String, String> entry : headerMap.entrySet()) {
            request.header(entry.getKey(), entry.getValue());
        }
    }

    @And("sg: I have the following query parameters:")
    public void iHaveTheFollowingQueryParameters(io.cucumber.datatable.DataTable dataTable) {
        queryParams.putAll(dataTable.asMap(String.class, String.class));
    }

    @And("sg: I have the following path parameters:")
    public void iHaveTheFollowingPathParameters(io.cucumber.datatable.DataTable dataTable) {
        pathParams.putAll(dataTable.asMap(String.class, String.class));
    }

    private String buildUrl() {
        String url = baseUrl;
        for (Map.Entry<String, String> entry : pathParams.entrySet()) {
            url = url.replace("{" + entry.getKey() + "}", entry.getValue());
        }
        if (!queryParams.isEmpty()) {
            StringBuilder sb = new StringBuilder(url);
            String separator = url.contains("?") ? "&" : "?";
            for (Map.Entry<String, String> entry : queryParams.entrySet()) {
                sb.append(separator).append(entry.getKey()).append("=").append(entry.getValue());
                separator = "&";
            }
            url = sb.toString();
        }
        return url;
    }

    @When("sg: I send a GET request")
    public void iSendAGETRequest() {
        response = given().spec(request).get(buildUrl());
    }

    @When("sg: I send a POST request")
    public void iSendAPOSTRequest() {
        response = given().spec(request).post(buildUrl());
    }

    @When("sg: I send a PUT request")
    public void iSendAPUTRequest() {
        response = given().spec(request).put(buildUrl());
    }

    @When("sg: I send a DELETE request")
    public void iSendADELETERequest() {
        response = given().spec(request).delete(buildUrl());
    }

    @When("sg: I send a PATCH request")
    public void iSendAPATCHRequest() {
        response = given().spec(request).patch(buildUrl());
    }

    @Then("sg: the response status code should be {int}")
    public void theResponseStatusCodeShouldBe(int statusCode) {
        response.then().statusCode(statusCode);
    }

    @And("sg: the response should contain {string}")
    public void theResponseShouldContain(String expectedContent) {
        response.then().body(containsString(expectedContent));
    }

    @And("sg: the response should have field {string} with value {string}")
    public void theResponseShouldHaveFieldWithValue(String fieldName, String expectedValue) {
        response.then().body(fieldName, equalTo(expectedValue));
    }

    @And("sg: the response should have field {string} containing {string}")
    public void theResponseShouldHaveFieldContaining(String fieldName, String expectedValue) {
        response.then().body(fieldName, containsString(expectedValue));
    }

    @And("sg: the response should have field {string} with value {int}")
    public void theResponseShouldHaveFieldWithIntValue(String fieldName, int expectedValue) {
        response.then().body(fieldName, equalTo(expectedValue));
    }

    @And("sg: the response should have field {string} with value {double}")
    public void theResponseShouldHaveFieldWithDoubleValue(String fieldName, double expectedValue) {
        response.then().body(fieldName, equalTo((float) expectedValue));
    }

    @And("sg: the response should have field {string}")
    public void theResponseShouldHaveField(String fieldName) {
        response.then().body(fieldName, notNullValue());
    }

    @And("sg: the response should be empty")
    public void theResponseShouldBeEmpty() {
        response.then().body(isEmptyOrNullString());
    }

    @And("sg: the response time should be less than {long} milliseconds")
    public void theResponseTimeShouldBeLessThanMilliseconds(long maxTime) {
        response.then().time(lessThan(maxTime));
    }

    @And("sg: the response content type should be {string}")
    public void theResponseContentTypeShouldBe(String contentType) {
        response.then().contentType(contentType);
    }

    @And("sg: I print the response")
    public void iPrintTheResponse() {
        response.prettyPrint();
    }

    @And("sg: I save the response field {string} to variable {string}")
    public void iSaveTheResponseFieldToVariable(String fieldPath, String variableName) {
        String value = response.jsonPath().getString(fieldPath);
        ScenarioContext.setContext(variableName, value);
    }

    @And("sg: I use variable {string} in the request body")
    public void iUseVariableInTheRequestBody(String variableName) {
        String value = ScenarioContext.getContext(variableName);
        if (value != null && requestBody != null) {
            requestBody = requestBody.replace("{" + variableName + "}", value);
            request.body(requestBody);
        }
    }

    @And("sg: I set authentication with token {string}")
    public void iSetAuthenticationWithToken(String token) {
        request.auth().oauth2(token);
    }

    @And("sg: I set basic authentication with username {string} and password {string}")
    public void iSetBasicAuthenticationWithUsernameAndPassword(String username, String password) {
        request.auth().basic(username, password);
    }

    @And("sg: I set the base URI to {string}")
    public void iSetTheBaseURITo(String baseUri) {
        baseURI = baseUri;
    }

    @And("sg: I set the base path to {string}")
    public void iSetTheBasePathTo(String basePath) {
        basePath = basePath;
    }

    @Then("sg: the response array size should be {int}")
    public void theResponseArraySizeShouldBe(int expectedSize) {
        response.then().body("size()", equalTo(expectedSize));
    }

    @And("sg: the response should match schema {string}")
    public void theResponseShouldMatchSchema(String schema) {
        response.then().body(matchesJsonSchema(schema));
    }

    @And("sg: the response should match file {string}")
    public void theResponseShouldMatchFile(String fileName) {
        try {
            String path = "responsePayload/" + fileName + ".json";
            InputStream is = getClass().getClassLoader().getResourceAsStream(path);
            if (is == null) {
                throw new RuntimeException("Response payload not found on classpath: " + path);
            }
            String expectedContent = new String(is.readAllBytes());
            response.then().body(equalTo(expectedContent));
        } catch (IOException e) {
            throw new RuntimeException("Failed to read response payload file: " + fileName + ".json", e);
        }
    }

    private void assertNodeContains(JsonNode actual, JsonNode expected) {
        if (expected.isObject()) {
            Iterator<Map.Entry<String, JsonNode>> fields = expected.fields();
            while (fields.hasNext()) {
                Map.Entry<String, JsonNode> field = fields.next();
                String key = field.getKey();
                JsonNode expectedValue = field.getValue();
                JsonNode actualValue = actual.get(key);
                assertThat("Missing field: " + key, actualValue, notNullValue());
                assertNodeContains(actualValue, expectedValue);
            }
        } else if (expected.isArray() && actual.isArray()) {
            assertThat("Array size mismatch", actual.size(), greaterThanOrEqualTo(expected.size()));
        } else {
            assertThat("Value mismatch for path", actual, equalTo(expected));
        }
    }

    @And("sg: the response should contain file {string}")
    public void theResponseShouldContainFile(String fileName) {
        try {
            String path = "responsePayload/" + fileName + ".json";
            InputStream is = getClass().getClassLoader().getResourceAsStream(path);
            if (is == null) {
                throw new RuntimeException("Response payload not found on classpath: " + path);
            }
            String expectedContent = new String(is.readAllBytes());
            String actualBody = response.getBody().asString();
            ObjectMapper mapper = new ObjectMapper();
            JsonNode actualNode = mapper.readTree(actualBody);
            JsonNode expectedNode = mapper.readTree(expectedContent);
            assertNodeContains(actualNode, expectedNode);
        } catch (IOException e) {
            throw new RuntimeException("Failed to read response payload file: " + fileName + ".json", e);
        }
    }
}

class ScenarioContext {
    private static Map<String, String> context = new HashMap<>();

    public static void setContext(String key, String value) {
        context.put(key, value);
    }

    public static String getContext(String key) {
        return context.get(key);
    }

    public static void clearContext() {
        context.clear();
    }
}
