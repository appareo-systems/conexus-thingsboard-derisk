#!/usr/bin/env bash

# let's make our home the current script folder
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd ${SCRIPT_DIR}
CHECK_CONNECTION="ping -w 3 -i 1 -c1"


# test Connectivity options
CUSTOM=$1
ETH_IP=${CUSTOM:-"airgradient-one.local"}
IP_ADDR=""


while [ -z "${IP_ADDR}" ]; do
    if ${CHECK_CONNECTION} ${ETH_IP}; then
        IP_ADDR=${ETH_IP}
    else
        echo "Failed to connect. Retrying..."
        sleep 2
    fi
done

echo "=============================================================="
echo "airgradient-one is online - reading data..."
echo "=============================================================="

LAST_TMPR=$(curl http://${ETH_IP}/sensor/temperature | jq -c  '. | {temperature: .value}')
LAST_CO2=$(curl http://${ETH_IP}/sensor/co2 | jq -c  '. | {co2: .value}')

# 
echo $LAST_TMPR
echo $LAST_CO2

echo "Merging values..."

DATA=$(jq -s '.[0] * .[1]' <<<"$LAST_TMPR $LAST_CO2")
echo $DATA

coap-client -v 6 -m POST coap://ap-paris-ldl.local:5683/api/v1/5wHZ2bu8kkxPo78xlh4L/telemetry -t json -e "${DATA}"
coap-client -v 6 -m POST coap://coap.eu.thingsboard.cloud:5683/api/v1/5wHZ2bu8kkxPo78xlh4L/telemetry -t json -e "${DATA}"
coap-client -v 6 -m POST coap://coap.eu.thingsboard.cloud:5683/api/v1/eUPmfGRXcysmSHuIGdh6/telemetry -t json -e "${DATA}"

