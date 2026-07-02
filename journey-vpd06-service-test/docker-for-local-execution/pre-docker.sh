# copy across built files
mkdir ./service-configs

cp -r ../../config/ ./service-configs
echo "copied config files"

cp ../../journey-vpd06-service-camel/target/image/dependency-jars/jmx_prometheus_javaagent-0.12.0.jar ./service-configs
cp ../../journey-vpd06-service-camel/target/image/startup.sh ./service-configs

cp -r ../../journey-vpd06-service-camel/target/image/apiassets/ ./service-configs
echo "copied schema files"

# TODO: Update with your Version
cp ../../journey-vpd06-service-camel/target/journey-vpd06-service-camel-1.0.0-SNAPSHOT.jar ./service-configs
echo "copied jar files"