# Request Payload Steps

Steps for setting request bodies in `ApiStepDefinitions.java`.

## Inline Request Body

**Expression:** `sg: I have the following request body:`
**Java:** `iHaveTheFollowingRequestBody(String body)`
**Description:** Sets the request body from an inline JSON string (using Cucumber docstring/triple quotes).
**Usage:**
```gherkin
And sg: I have the following request body:
  """
  {"coffeeType":"Vanilla Latte","size":"medium","quantity":2}
  """
```

## Request Payload from File

**Expression:** `sg: I have request payload from file {string}`
**Java:** `iHaveRequestPayloadFromFile(String fileName)`
**Description:** Loads a request payload from a JSON file on the classpath. Reads from `requestPayload/<fileName>.json`. The `.json` extension is appended automatically.
**Usage:**
```gherkin
And sg: I have request payload from file "createOrder"
```
This reads `requestPayload/createOrder.json` from the classpath.
