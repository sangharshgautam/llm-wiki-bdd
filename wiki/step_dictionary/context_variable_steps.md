# Context Variable Steps

Steps for saving and reusing response values across steps in `ApiStepDefinitions.java`.

These use the `ScenarioContext` helper class (a static `HashMap<String, String>`) to store and retrieve values within a scenario.

## Save Field to Variable

**Expression:** `sg: I save the response field {string} to variable {string}`
**Java:** `iSaveTheResponseFieldToVariable(String fieldPath, String variableName)`
**Description:** Extracts a value from the JSON response using dot-notation and stores it in the scenario context. The value is stored as a string.

## Use Variable in Request Body

**Expression:** `sg: I use variable {string} in the request body`
**Java:** `iUseVariableInTheRequestBody(String variableName)`
**Description:** Replaces `{variableName}` placeholders in the current request body with the stored value. The request body must have been set beforehand with `I have the following request body:` or `I have request payload from file`.
