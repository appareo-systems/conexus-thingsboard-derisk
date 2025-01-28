#!/usr/bin/env bash
THINGSBOARD_DOCKER=ap-paris-ldl.local
THINGSBOARD_DOCKER=10.105.32.45


# let's make our home the current script folder
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd ${SCRIPT_DIR}
CHECK_CONNECTION="ping -w 3 -i 1 -c1"


# test Connectivity options
CUSTOM=$1
ETH_IP=${CUSTOM:-"192.168.95.1"}
IP_ADDR=""


if [ -z "$NB_RETRY" ]; then
  NB_RETRY=0
fi

while [ -z "${IP_ADDR}" ] &&  [ "$NB_RETRY" -lt 2 ] ; do
    if ${CHECK_CONNECTION} ${ETH_IP}; then
        IP_ADDR=${ETH_IP}
    else
        echo "Failed to connect. Retrying..."
        sleep 2
    fi
    NB_RETRY=$((NB_RETRY + 1))
done


if ${CHECK_CONNECTION} ${ETH_IP}; then
    echo "=============================================================="
    echo "ACU200 is online - reading data..."
    PING_TIME=$(date +%FT%T)
    echo $PING_TIME
    echo "=============================================================="

    ACU_INFOS=$(curl http://192.168.95.1/info | jq  -c '. | {"serialNumber":.serialNumber,"partNumber":.partNumber,"softwareVersion":.softwareVersion,"cpuTemperature":.cpuTemperature,"aircraftId":.aircraftId,"wogStatus":.wogStatus,"cellConnected":.cellConnected}')
    CELL_STATUS=$(curl http://192.168.95.1/info | jq  -c '. | {"cellConnected":.cellConnected,"cellProvider":.cellProvider,"cellRssi":.cellRssi}')
    GPS=$(curl http://192.168.95.1/info | jq  -c '.gps | {"longitude":.longitude,"latitude":.latitude}')
    OUTBOX_STATUS=$(curl http://192.168.95.1/info | jq  -c '.loggerInfos | {"bootNumber":.bootNumber,"sequenceNumber":.sequenceNumber,"outboxNbfiles":.outboxNbfiles}')
    coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/4gfxbxs92ont5vlphbnh/telemetry -t json -e ${ACU_INFOS}
    coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/4gfxbxs92ont5vlphbnh/telemetry -t json -e ${CELL_STATUS}
    coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/4gfxbxs92ont5vlphbnh/telemetry -t json -e ${OUTBOX_STATUS}
    coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/4gfxbxs92ont5vlphbnh/telemetry -t json -e {ping:\"${PING_TIME}\"}
    coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/4gfxbxs92ont5vlphbnh/telemetry -t json -e ${GPS}
fi

echo "............................."
echo "Demo data for dummy ACU200 PARIS2024..."
echo "............................."

ACU_INFOS='{"serialNumber":"011111","partNumber":"153510-000095R00","softwareVersion":"2.3.2.999","cellProvider":"VERIZON","aircraftId":"PARIS2024","wogStatus":"InAir","cellConnected":false}'
coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/0xsr0dcnv8z2w1ezli1s/telemetry -t json -e ${ACU_INFOS}
# Generate a random number between 50 and 60
RANDOM_TEMPERATURE=$((RANDOM % 11 + 50))
coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/0xsr0dcnv8z2w1ezli1s/telemetry -t json -e {cpuTemperature:$RANDOM_TEMPERATURE}
coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/0xsr0dcnv8z2w1ezli1s/telemetry -t json -e {ping:\"${PING_TIME}\"}
coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/0xsr0dcnv8z2w1ezli1s/telemetry -t json -e '{longitude:2.260505,latitude:48.720788}'

echo "............................."
echo "Demo data for dummy ACU200 PARIS2025..."
echo "............................."

ACU_INFOS='{"serialNumber":"022222","partNumber":"153510-000095R00","softwareVersion":"2.3.2.999","cellProvider":"VERIZON","aircraftId":"PARIS2025","wogStatus":"OnGround","cellConnected":true}'
coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e ${ACU_INFOS}
coap-client -v 6 -m POST coap://coap.eu.thingsboard.cloud:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e  ${ACU_INFOS}

# Generate a random number between 60 and 80
RANDOM_TEMPERATURE=$((RANDOM % 21 + 60))
coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e {cpuTemperature:$RANDOM_TEMPERATURE}
coap-client -v 6 -m POST coap://coap.eu.thingsboard.cloud:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e  {cpuTemperature:$RANDOM_TEMPERATURE}

# Generate a random number between -65 and -95
RANDOM_RSSI=$((RANDOM % 31 - 95))
coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e {cellConnected:true}
coap-client -v 6 -m POST coap://coap.eu.thingsboard.cloud:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e  {cellConnected:true}

coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e {cellRssi:$RANDOM_RSSI}
coap-client -v 6 -m POST coap://coap.eu.thingsboard.cloud:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e  {cellRssi:$RANDOM_RSSI}

coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e {ping:\"${PING_TIME}\"}
coap-client -v 6 -m POST coap://coap.eu.thingsboard.cloud:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e  {ping:\"${PING_TIME}\"}

coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e {latitude:48.720788}
coap-client -v 6 -m POST coap://coap.eu.thingsboard.cloud:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e  {latitude:48.720788}


source newLongitude.sh
echo $NEW_LONGITUDE
coap-client -v 6 -m POST coap://${THINGSBOARD_DOCKER}:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e {longitude:$NEW_LONGITUDE}
coap-client -v 6 -m POST coap://coap.eu.thingsboard.cloud:5683/api/v1/q08J643lz0yowd7F2ZEY/telemetry -t json -e  {longitude:$NEW_LONGITUDE}











