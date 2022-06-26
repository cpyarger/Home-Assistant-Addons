#!/usr/bin/bash

export LD_LIBRARY_PATH=/usr/local/lib64
export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

CONFIG_PATH=/data/options.json

# Parse the variables
DEBUG=true

AMR_MSGTYPE="ALL"
GUOM="ft3"
EUOM="kWh"
WUOM="gal"
WTEN=true

SCMPGD="1"

# Print the set variables to the log
echo "Starting RTLAMR with parameters:"
echo "AMR Message Type =" $AMR_MSGTYPE
echo "AMR Device IDs =" $AMR_IDS
echo "Time Between Readings =" $PT
echo "Duration = " $DURATION
echo "Electric Unit of measurement = " $EUOM
echo "Gas Unit of measurement = " $GUOM
echo "Water Unit of measurement = " $WUOM
echo "Water measurements provided in tenths = " $WTEN
echo "SCM PLUS GAS DIVISOR = " $SCMPGD
echo "Debug is " $DEBUG

function is_gas() {
    LIST=(0 1 2 9 12 156)
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

# Function, parses scm and scmplus data
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

# Function, parses R900 data
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

# Function, insert decimal in state value to effectively divide by ten
function tenths {
  RESTDATA=$(echo $RESTDATA | jq -rc --arg state "$(echo $RESTDATA | jq -rc '.state' | sed 's/.$/.&/;')" '.state = $state')
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

  if  [ "$TYPE" = "R900" ] || is_water $EPT; then
    if $WTEN; then
      tenths
    fi
  fi

  echo -e "\n Rest Output"
  echo $RESTDATA
  echo -e "\n"
}

# Set flags if variables are set
x=""
if [ ! -z "$AMR_IDS" ]; then
  x="-filterid=$AMR_IDS"
fi

if [[ "$DURATION" != "0" ]]; then
  x="$x -duration=${DURATION}s"
fi
# Function, runs a rtlamr listen event
function listener {
  line='{"Time":"2022-06-25T15:10:38.160105524-04:00","Offset":0,"Length":0,"Type":"R900","Message":{"ID":1540559732,"Unkn1":163,"NoUse":32,"BackFlow":0,"Consumption":3543684,"Unkn3":0,"Leak":0,"LeakNow":0}}'
  #line='{"Time":"2022-06-25T15:10:36.618461523-04:00","Offset":0,"Length":0,"Type":"SCM","Message":{"ID":23876447,"Type":11,"TamperPhy":0,"TamperEnc":2,"Consumption":25813,"ChecksumVal":64424}}'
  postto
}

# run listener once
listener

