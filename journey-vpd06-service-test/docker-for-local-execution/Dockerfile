# vpd06 Service config

FROM docker.artifactory.n.mes.corp.hmrc.gov.uk:80/alpine-java17-base:poc


RUN echo 'Loading the Service configs required...'

#deploy configs
ADD service-configs/config/ /opt/vpd06/config/

#service config
COPY service-configs/jmx_prometheus_javaagent-0.12.0.jar /opt/vpd06/dependency-jars/
COPY service-configs/startup.sh /opt/vpd06/

# TODO: check version here
COPY service-configs/journey-vpd06-service-camel-1.0.0-SNAPSHOT.jar /opt/vpd06/

#api assests
ADD service-configs/apiassets/ /opt/vpd06/apiassets/

RUN echo 'Switching Directory opt vpd06'
WORKDIR /opt/vpd06/

RUN echo 'Running the startup script'
ENTRYPOINT ["sh", "startup.sh"]
