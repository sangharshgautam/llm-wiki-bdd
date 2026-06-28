# Helper Steps

Debugging and utility steps in `ApiStepDefinitions.java`.

## Print Response

**Expression:** `sg: I print the response`
**Java:** `iPrintTheResponse()`
**Description:** Prints the full response body (headers, body, status) to the console using REST Assured's `prettyPrint()`. Useful for debugging during test development.
**Usage:**
```gherkin
And sg: I print the response
```
