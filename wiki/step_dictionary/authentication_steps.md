# Authentication Steps

Steps for setting authentication in `ApiStepDefinitions.java`.

## OAuth2 Token

**Expression:** `sg: I set authentication with token {string}`
**Java:** `iSetAuthenticationWithToken(String token)`
**Description:** Adds an OAuth2 Bearer token to the Authorization header.
**Usage:**
```gherkin
And sg: I set authentication with token "eyJhbGciOiJIUzI1NiIs..."
```

## Basic Authentication

**Expression:** `sg: I set basic authentication with username {string} and password {string}`
**Java:** `iSetBasicAuthenticationWithUsernameAndPassword(String username, String password)`
**Description:** Sets HTTP Basic Authentication credentials.
**Usage:**
```gherkin
And sg: I set basic authentication with username "admin" and password "password123"
```

## Base URI

**Expression:** `sg: I set the base URI to {string}`
**Java:** `iSetTheBaseURITo(String baseUri)`
**Description:** Sets the REST Assured `baseURI` for subsequent requests.
**Usage:**
```gherkin
And sg: I set the base URI to "http://coffee-api"
```

## Base Path

**Expression:** `sg: I set the base path to {string}`
**Java:** `iSetTheBasePathTo(String basePath)`
**Description:** Sets the REST Assured `basePath` for subsequent requests.
**Usage:**
```gherkin
And sg: I set the base path to "/api/orders"
```
