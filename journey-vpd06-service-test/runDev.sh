#!/bin/bash

mvn clean verify \
  -Dspring.profiles.active="dev" \
  -U \
  -Djourney=vpd06 \
  -Dproject=vpd \
  -Dnamespace=emcsdev \
  -Dintellij=true \
  -Dstage=dev \
  -Dcucumber.filter.tags="$1"

echo -e "\nTests on $env with tags [$1] completed.\n"
