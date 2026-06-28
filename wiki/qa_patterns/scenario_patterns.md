# Scenario Patterns

Common scenario structures extracted from `coffee-ordering.feature`.

## Standard Happy Path Flow

```
Given sg: I have a REST API endpoint at "<url>"
  [And sg: I have the following request body: / I have request payload from file "..."]
  [And sg: I have the following headers:]
  [And sg: I have the following query parameters:]
  [And sg: I have the following path parameters:]
  [And sg: I set authentication with token "..."]
When sg: I send a <METHOD> request
Then sg: the response status code should be <expected-status>
  [And sg: the response should have field "<field>" with value "<value>"]
  [And sg: the response should have field "<field>"]
  [And sg: the response content type should be "application/json"]
  [And sg: the response time should be less than <N> milliseconds]
```

## Error Scenario Flow

```
Given sg: I have a REST API endpoint at "<url>"
  [And sg: I have the following request body: / I have request payload from file "..."]
  [And sg: I have the following headers:]
When sg: I send a <METHOD> request
Then sg: the response status code should be <4xx/5xx>
  [And sg: the response should contain "<error-message>"]
  [And sg: the response should have field "error" with value "<expected-error>"]
  [And sg: the response should have field "error" containing "<partial-message>"]
  [And sg: the response should contain file "errorResponse"]
```

## File-Based Assertion Flow

```
Given sg: I have a REST API endpoint at "<url>"
  [And sg: I have the following request body: / I have request payload from file "..."]
When sg: I send a <METHOD> request
Then sg: the response status code should be <expected-status>
  And sg: the response should contain file "<response-file>"
```

## Naming Conventions

- **Scenario names**: Descriptive, action-oriented sentences
  - `Place a valid coffee order`
  - `Reject order with missing coffee type`
  - `Response time is acceptable`
- **File names**: camelCase matching the entity/action
  - `createOrder.json`, `invalidOrder.json`, `orderResponse.json`
