@negative @vpd06 @test
Feature: Negative Path Scenarios

  Background:
    Given the following headers:
      | date             | $date            |
      | x-forwarded-host | ETDS             |
      | x-regime         | VPD              |
      | X-Correlation-ID | $uuid            |
      | Content-Type     | application/json |
      | Accept           | application/json |
      | Authorization    | $auth            |
      | x-eis-sender-classification | external         |

  @N001
  Scenario: Invalid payload with empty emr and bad dates
    Given the payload "N001"
    When a "POST" request is sent to the journey
    And the response body should extend the JSON present in "N001" with the following values:
      | /errorDetail/correlationId | $uuid |
      | /errorDetail/errorCode     | 400   |
      | /errorDetail/source        | journey-vpd06-service-camel |
    Then a 400 response should be returned from the journey
    And the following headers should be returned:
      | X-Correlation-ID | $uuid            |
      | Content-Type     | application/json |
    And the date header is returned in http format

  @N002
  Scenario: Backend Internal Server Error
    Given the payload "N002"
    And the backend mock scenario "N002"
    When a "POST" request is sent to the journey
    Then a 500 response should be returned from the journey
    And the response body should match the JSON present in "N002"
    And the following headers should be returned:
      | X-Correlation-ID | $uuid            |
      | Content-Type     | application/json |
    And the date header is returned in http format
