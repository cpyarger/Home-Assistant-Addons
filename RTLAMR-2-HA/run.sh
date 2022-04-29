#!/bin/sh
export LD_LIBRARY_PATH=/usr/local/lib64
export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

CONFIG_PATH=/data/options.json
# Parse the variables
AMR_MSGTYPE="$(jq --raw-output '.msgType' $CONFIG_PATH)"
AMR_IDS="$(jq --raw-output '.ids' $CONFIG_PATH)"
DURATION="$(jq --raw-output '.duration' $CONFIG_PATH)"
PT="$(jq --raw-output '.pause_time' $CONFIG_PATH)"

# Print the set variables to the log
echo "Starting RTLAMR with parameters:"
echo "AMR Message Type =" $AMR_MSGTYPE
echo "AMR Device IDs =" $AMR_IDS
echo "Time Between Readings =" $PT
echo "Duration = " $DURATION

# Starts the RTL_TCP Application
/usr/local/bin/rtl_tcp &
# Sleep to fill buffer a bit
sleep 15

# Function, posts data to home assistant that is gathered by the rtlamr script
function postto {
  echo $line
VAL="$(echo $line | jq --raw-output '.Message.Consumption' | tr -s ' ' '_')" # replace ' ' with '_'
DEVICEID="$(echo $line | jq --raw-output '.Message.ID' | tr -s ' ' '_')"
ATTR="$(echo $line | jq --raw-output '.Message' | tr -s ' ' '_')"
if [ "$DEVICEID" = "null" ]; then
  DEVICEID="$(echo $line | jq --raw-output '.Message.EndpointID' | tr -s ' ' '_')"
fi
RESTDATA=$( jq -nrc --arg state "$VAL" --arg attr "$ATTR"  '{"state": $state, "attributes": $attr}')
echo -n "Sending  $RESTDATA  to http://supervisor/core/api/states/sensor.$DEVICEID -- "
curl -s -o /dev/null -w "%{http_code}" -X POST -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
-H "Content-Type: application/json" \
-d $RESTDATA \
http://supervisor/core/api/states/sensor.$DEVICEID
echo -e "\n"
}

# Set flags if variables are set
x=""
if [ ! -z "$AMR_IDS" ]; then
  x="-filterid=$AMR_IDS"
fi

if $de; then
  x="$x -duration=${DURATION}s"
fi
# Function, runs a rtlamr listen event
function listener {
  /go/bin/rtlamr -format json -msgtype=$AMR_MSGTYPE $x| while read line
  do
    postto
  done
}

# Main Event Loop, will restart if buffer runs out
while true; do
  listener
  sleep $PT
done

