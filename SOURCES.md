# External Source References

# Add as many services as you want under each section.
# Each golden_services path points to a service project root containing:
#   public/openapi.yaml  — the service's OpenAPI spec
#   *-test/              — test project subdirectories with feature files

step_definitions:
  - path: C:/Users/sangh/IdeaProjects/sangharshgautam/openapi-bdd
    description: Shared openapi-bdd step definitions (LLM will discover @Given/@When/@Then files automatically)

golden_services:
  - path: C:/Users/sangh/IdeaProjects/sangharshgautam/coffee-ordering-api
    description: Coffee Ordering API service (LLM reads public/openapi.yaml + scans *-test/ subdirs)
  # Add more golden service projects below:
  # - path: C:/Path/To/Another/Service

# frontend_spec: optional — defaults to <current-working-dir>/public/openapi.yaml
# backend_spec: optional — defaults to <current-working-dir>/assets/backend/openapi.yaml
backend_spec:
  - path: C:/Users/sangh/IdeaProjects/sangharshgautam/llm-wiki-bdd/assets/backend/openapi.yaml
    description: FleetRoute backend API spec


