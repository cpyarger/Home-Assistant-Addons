#!/bin/sh
export LD_LIBRARY_PATH=/usr/local/lib64
export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

CONFIG_PATH=/data/options.json
AMR_MSGTYPE="$(jq --raw-output '.msgType' $CONFIG_PATH)"
AMR_IDS="$(jq --raw-output '.ids' $CONFIG_PATH)"

# Start the listener and enter an endless loop
echo "Starting RTLAMR with parameters:"
echo "AMR Message Type =" $AMR_MSGTYPE
echo "AMR Device IDs =" $AMR_IDS


# set -x  ## uncomment for MQTT logging...
/usr/local/bin/rtl_tcp &
# Sleep to fill buffer a bit
sleep 15

LASTVAL="0"

# set a time to listen for. Set to 0 for unliminted

# Do this loop, so will restart if buffer runs out
while true; do

/go/bin/rtlamr -format json -msgtype=$AMR_MSGTYPE -filterid=$AMR_IDS  | while read line
#/go/bin/rtlamr -msgtype=all -format json  | while read line

do

VAL="$(echo $line | jq --raw-output '.Message.Consumption' | tr -s ' ' '_')" # replace ' ' with '_'
DEVICEID="$(echo $line | jq --raw-output '.Message.ID' | tr -s ' ' '_')"
if [ "$DEVICEID" = "null" ]; then
  DEVICEID="$(echo $line | jq --raw-output '.Message.EndpointID' | tr -s ' ' '_')"
fi
RESTDATA=$( jq -nrc --arg state "$VAL" '{state: $state}')
#echo $VAL | /usr/bin/mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -u $MQTT_USER -P $MQTT_PASS -i RTL_433 -r -l -t $MQTT_PATH
#curl -X POST -H "Authorization: Bearer $HA_TOKEN" \
echo -n "Sending  $RESTDATA  to http://supervisor/core/api/states/sensor.$DEVICEID -- "
curl -s -o /dev/null -w "%{http_code}" -X POST -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
-H "Content-Type: application/json" \
-d $RESTDATA \
http://supervisor/core/api/states/sensor.$DEVICEID
#$HA_HOST:$HA_PORT/api/states/sensor.$DEVICEID
echo -e "\n"

done
sleep 30s

done

