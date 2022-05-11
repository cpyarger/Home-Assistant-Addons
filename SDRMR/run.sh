#!/bin/bash
export LD_LIBRARY_PATH=/usr/local/lib64
export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

CONFIG_PATH=/data/options.json
# Parse the variables
DEBUG="$(jq --raw-output '.debug' $CONFIG_PATH)"

AMR_MSGTYPE="$(jq --raw-output '.msgType' $CONFIG_PATH)"
AMR_IDS="$(jq --raw-output '.ids' $CONFIG_PATH)"
DURATION="$(jq --raw-output '.duration' $CONFIG_PATH)"
PT="$(jq --raw-output '.pause_time' $CONFIG_PATH)"
GUOM="$(jq --raw-output '.gas_unit_of_measurement' $CONFIG_PATH)"
EUOM="$(jq --raw-output '.electric_unit_of_measurement' $CONFIG_PATH)"
WUOM="$(jq --raw-output '.water_unit_of_measurement' $CONFIG_PATH)"

SCMPGD="$(jq --raw-output '.scm_plus_gas_divisor' $CONFIG_PATH)"
# Print the set variables to the log
echo "Starting RTLAMR with parameters:"
echo "AMR Message Type =" $AMR_MSGTYPE
echo "AMR Device IDs =" $AMR_IDS
echo "Time Between Readings =" $PT
echo "Duration = " $DURATION
echo "Electric Unit of measurement = " $EUOM
echo "Gas Unit of measurement = " $GUOM
echo "Water Unit of measurement = " $WUOM
echo "SCM PLUS GAS DIVISOR = " $SCMPGD
echo "Debug is " $DEBUG
# Starts the RTL_TCP Application
if ($DEBUG); then
  /usr/local/bin/rtl_tcp &
else
  /usr/local/bin/rtl_tcp > /dev/null &
fi
# Sleep to fill buffer a bit
sleep 5
function is_gas() {
    LIST=(0 1 2 9 156)
    VALUE=$1
    [[ ${LIST[@]} =~ $VALUE ]]
}
function is_electric() {
    LIST=(4 5 7 8)
    VALUE=$1
    [[ ${LIST[@]} =~ $VALUE ]]
}
function is_water() {
    LIST=(3 11 13)
    VALUE=$1
    [[ ${LIST[@]} =~ $VALUE ]]
}

function scmplus_parse {
  STATE="$(echo $line | jq -rc '.Message.Consumption' | tr -s ' ' '_')"

  FIXED_STATE=$(($STATE/$SCMPGD))
  EPT="$(echo $line | jq -rc '.Message.EndpointType' | tr -s ' ' '_')"
  if [[ $EPT =~ "null" ]]; then
    EPT="$(echo $line | jq -rc '.Message.Type' | tr -s ' ' '_')"
  fi
  scmUID=$DEVICEID-sdrmr
  if is_gas $EPT; then
    RESTDATA=$( jq -nrc --arg state "$FIXED_STATE" --arg uid "$scmUID" --arg uom "$GUOM" '{"state": $state, "attributes": {"unique_id": $uid, "state_class": "total_increasing", "device_class": "gas",  "unit_of_measurement": $uom }}')
  elif is_electric $EPT; then
    RESTDATA=$( jq -nrc --arg state "$STATE" --arg uid "$scmUID" --arg uom "$EUOM" '{"state": $state, "attributes": {"unique_id": $uid, "device_class": "energy", "unit_of_measurement": $uom, "state_class": "total_increasing" }}')
  elif is_water $EPT; then
    RESTDATA=$( jq -nrc --arg state "$STATE" --arg uid "$scmUID" --arg uom "$WUOM" '{"state": $state, "attributes": {"unique_id": $uid}, "unit_of_measurement": $uom }')
  else
    RESTDATA=$( jq -nrc --arg state "$STATE" --arg uid "$scmUID" '{"state": $state, "attributes": {"unique_id": $uid}}')
  fi
  }

function r900_parse {
  STATE="$(echo $line | jq -rc '.Message.Consumption' | tr -s ' ' '_')"
  LEAK="$(echo $line | jq -rc '.Message.Leak' | tr -s ' ' '_')"
  LEAKNOW="$(echo $line | jq -rc '.Message.LeakNow' | tr -s ' ' '_')"
  BACKFLOW="$(echo $line | jq -rc '.Message.BackFlow' | tr -s ' ' '_')"
  UNKN1="$(echo $line | jq -rc '.Message.Unkn1' | tr -s ' ' '_')"
  UNKN3="$(echo $line | jq -rc '.Message.Unkn3' | tr -s ' ' '_')"
  NOUSE="$(echo $line | jq -rc '.Message.NoUse' | tr -s ' ' '_')"
  RESTDATA=$( jq -nrc \
  --arg st "$STATE" \
  --arg le "$LEAK" \
  --arg ln "$LEAKNOW" \
  --arg uid "$DEVICEID-sdrmr" \
  --arg bf "$BACKFLOW" \
  --arg unkn1 "$UNKN1" \
  --arg unkn3 "$UNKN3" \
  --arg nouse "$NOUSE" \
  '{"state": $st, "extra_state_attributes": {"unique_id": $uid}, "attributes": { "entity_id": $uid, "state_class": "total_increasing", "unit_of_measurement": "gal", "leak": $le, "leak_now": $ln, "BackFlow": $bf, "NoUse": $nouse, "Unknown1": $unkn1, "Unknown3": $unkn3 }}')
}
# Function, posts data to home assistant that is gathered by the rtlamr script
function postto {
  if ($DEBUG); then
  echo $line
  fi
  DEVICEID="$(echo $line | jq -rc '.Message.ID' | tr -s ' ' '_')"
  TYPE="$(echo $line | jq -rc '.Type' | tr -s ' ' '_')"
  if [ "$DEVICEID" = "null" ]; then
    DEVICEID="$(echo $line | jq -rc '.Message.EndpointID' | tr -s ' ' '_')"
  fi

  if [ "$TYPE" = "R900" ]; then
    r900_parse
  elif [ "$TYPE" = "SCM+" ] || [ "$TYPE" = "SCM" ]; then
    scmplus_parse
  else
    VAL="$(echo $line | jq -rc '.Message.Consumption' | tr -s ' ' '_')" # replace ' ' with '_'
    RESTDATA=$( jq -nrc --arg state "$VAL" '{"state": $state}')
  fi


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

