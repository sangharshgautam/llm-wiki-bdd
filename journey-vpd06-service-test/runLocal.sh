#!/bin/bash

mvn clean verify \
  -Dspring.profiles.active="local" \
  -U \
  -Djourney=vpd06 \
  -Dproject=vpd \
  -Dnamespace=local \
  -Dintellij=true \
  -Dstage=local
