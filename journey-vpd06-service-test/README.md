# vpd06 BDD

This readme will cover running the BDD tests. To run the service locally (a pre-requisite if not
running against dev), see [RUN-LOCALLY-README.md](docker-for-local-execution/RUN-LOCALLY-README.md).

You have 3 main options:

1. Running via the gitlab-ci pipeline
2. Running IntelliJ configs
3. Running Bash scripts

## Gitlab-CI Pipeline

Use the Gitlab GUI to run tests as defined on a chosen branch against the service deployed in dev.

1. Go to "Build" > "Pipelines"
2. Click "New pipeline"
3. Select branch with the _tests_ you want to run
4. Enter variables
    * action: test
    * environment: dev
5. Click "New pipeline" at the bottom to run it

## IntelliJ configs

As with the `JourneyMain.run.xml` described in
[RUN-LOCALLY-README.md](docker-for-local-execution/RUN-LOCALLY-README.md#intellij-run-configuration)
some IntelliJ configs are provided out of the box and tracked by your VCS to provide some typical
test running combinations.

The main benefit is that you can run them in the IDE's debug mode to aid debugging.

> If it isn't already, the test module will need to be added "as Maven Project" by right-clicking on 
> the [pom.xml](pom.xml). You may also need to manually edit the run config so "use classpath of 
> module" points to the test module

* `local_all.run.xml` - Run the full feature set against a locally running instance
* `local_happy.run.xml` - Run the [happy path](src/test/resources/features/HappyPath.feature)
  feature against a locally running instance

> If these are edited or added to, please update here accordingly.

## Bash run.sh Script(s)

There are "runXYZ.sh" bash scripts parallel to this readme which can be executed from a CLI, 
leveraging the `mvn clean verify` execution as the journey pipeline 
[would do](http://gitlab.services.eis.n.mes.corp.hmrc.gov.uk/devops/helmcharts/gitlab-runner/-/blob/master/gitlab-runner-docker/files/bdd-tests.sh).

Like with the IntelliJ configs, the tests largely depend on the spring profile (e.g. 
`-Dspring.profiles.active=dev`) and only need arguments typically provided by the journey pipeline 
to populate the `environment` spring values (e.g. stage, namespace) and optional cucumber tag 
filters (e.g. `-Dcucumber.filter.tags="@smokeTest"`).

## Appendix - Useful URLs

Dev URL: https://apism.emcsdev.ext.dev.mt.n.mes.corp.hmrc.gov.uk/vpd/vpd06/v1

### WireMock

Base URL: https://wiremock.emcsdev.int.dev.mt.n.mes.corp.hmrc.gov.uk

Endpoints:

* /__admin/mappings
    * (**POST**) request to "seed" mapping
    * (**GET**) request to retrieve mapping(s)
* /__admin/requests
    * (**GET**) request to retrieve request(s) sent to wiremock (with optional query payload)
* /__admin/requests/count
    * (**POST**) request to retrieve request count sent to wiremock
* RESTAdapter/generic/approval-status
    * Test the mock behaviour directly as the service would

Query body example:

```
{
  "headers": {
    "x-correlation-id": {
      "matches": "123"
    }
  }
}
```
