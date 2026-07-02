# Running locally

## tl;dr (docker route)

- `mvn clean install` service
- update camel jar version in [Dockerfile](Dockerfile) and [pre-docker.sh](pre-docker.sh) to match
  what was built
- run `pre-docker.sh`
- run `start-docker.sh`

URL to use on Postman http://localhost:8085RESTAdapter/generic/approval-status

## In full

**You can either:**

1. Run the wiremock-standalone and run JourneyMain using the IntelliJ xml run configs provided
2. Run the service and wiremock both as docker containers

### IntelliJ Run Configuration

An [IntelliJ run configuration](../../.run/JourneyMain.run.xml) (stored as a [project file](https://www.jetbrains.com/help/idea/run-debug-configuration.html#share-configurations))
has been provided in the `.run` directory named `JourneyMain.run.xml`.
It should not need any further configuration and will launch the journey on port `8085`.

This can be run and edited like any other IntelliJ run configuration. If you make changes, these
will be reflected in the *.run.xml file and can be committed with git/VCS like any other changes.

If it fails, the changes are most likely needed in the `VM_PARAMETERS`, due to changes in file paths
or envars/system properties required for the particular service.

You will also need to run the [start-wiremock.sh](wiremock-standalone/start-wiremock.sh) script to 
start up wiremock and mock the backend to be hit by the journey.

### Docker

1. You must run a `mvn clean install` for the service
2. Move across relevant files into the service-configs folder (list below). This has to be done as
   docker forbids paths outside the build context.
    * The `pre-docker.sh` script will do this for you as long as you update the jar version
3. Update jar version inside dockerfile
4. run `start-docker.sh`

<details>
<summary><b>Required Files in Service Config</b></summary>
Existing / create: 

| file                                | location                                                       |
|-------------------------------------|----------------------------------------------------------------|
| env-ct-vpd06-1.0.0-audit.xml  | journey-vpd06-service-camel/src/test/resources/config    |
| env-ct-vpd06-1.0.0-config.xml | journey-vpd06-service-camel/src/test/resources/config    |
| jmx_prometheus_javaagent-0.12.0.jar | journey-vpd06-service-camel/target/image/dependency-jars |
| logback.xml                         | journey-vpd06-service-camel/src/test/resources           |
| prometheus_config.yaml              | service-configs                                                |
| startup.sh                          | journey-vpd06-service-camel/target/image                 |

Need checking:

| file                                                 | location                                                         |
|------------------------------------------------------|------------------------------------------------------------------|
| journey-vpd06-service-camel-1.0.5-SNAPSHOT.jar | journey-vpd06-service-camel/target                         |
| api-assets                                           | journey-vpd06-service-camel/target/image/apiassets/systems |

</details>
