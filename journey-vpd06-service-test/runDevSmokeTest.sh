#!/bin/bash

mvn clean verify \
  -Dspring.profiles.active="dev" \
  -U \
  -Djourney=vpd06 \
  -Dproject=vpd \
  -Dnamespace=emcsdev \
  -Dintellij=true \
  -Dstage=dev \
  -Dcucumber.filter.tags="@smokeTest"

