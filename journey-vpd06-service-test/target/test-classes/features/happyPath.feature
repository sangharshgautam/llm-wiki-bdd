@happy @vpd06 @test
Feature: Happy Path Scenarios

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

  @H001
  Scenario: Valid vpd06 request processed successfully
    Given the payload "H001"
    And the backend mock scenario "H001"
    When a "POST" request is sent to the journey
    Then a 201 response should be returned from the journey
    And the response should have no body
    And the following headers should be returned:
      | X-Correlation-ID | $uuid            |
      | Content-Type     | application/json |
    And the date header is returned in http format

  @H002
  Scenario: Valid vpd06 request with approvalStatus 02
    Given the payload "H002"
    And the backend mock scenario "H002"
    When a "POST" request is sent to the journey
    Then a 201 response should be returned from the journey
    And the response should have no body
    And the following headers should be returned:
      | X-Correlation-ID | $uuid            |
      | Content-Type     | application/json |
    And the date header is returned in http format

  @H003
  Scenario: Valid vpd06 request with approvalStatus 03
    Given the payload "H003"
    And the backend mock scenario "H003"
    When a "POST" request is sent to the journey
    Then a 201 response should be returned from the journey
    And the response should have no body
    And the following headers should be returned:
      | X-Correlation-ID | $uuid            |
      | Content-Type     | application/json |
    And the date header is returned in http format
