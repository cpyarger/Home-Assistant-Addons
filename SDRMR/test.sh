#!/bin/bash
line='{"Time":"2022-05-11T11:44:19.672941168-05:00","Offset":0,"Length":0,"Type":"SCM","Message":{"ID":31500996,"Type":13,"TamperPhy":0,"TamperEnc":0,"Consumption":44805,"ChecksumVal":58702}}'
DEVICEID="$(echo $line | jq -rc '.Message.ID' | tr -s ' ' '_')"

TYPE="$(echo $line | jq -rc '.Type' | tr -s ' ' '_')"

if [ "$DEVICEID" = "null" ]; then
    DEVICEID="$(echo $line | jq -rc '.Message.EndpointID' | tr -s ' ' '_')"
fi
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
	echo "state is : " $STATE
  EPT="$(echo $line | jq -rc '.Message.EndpointType' | tr -s ' ' '_')"
  if [[ $EPT =~ "null" ]]; then
    EPT="$(echo $line | jq -rc '.Message.Type' | tr -s ' ' '_')"
  fi
	echo "EPT is :" $EPT
  scmUID=$DEVICEID-sdrmr
  if is_gas $EPT; then
    RESTDATA=$( jq -nrc --arg state "$FIXED_STATE" --arg uid "$scmUID" --arg uom "$GUOM" '{"state": $state, "attributes": {"unique_id": $uid, "state_class": "total_increasing", "device_class": "gas",  "unit_of_measurement": $uom }}')
	echo "is gas"
  elif is_electric $EPT; then
    RESTDATA=$( jq -nrc --arg state "$STATE" --arg uid "$scmUID" --arg uom "$EUOM" '{"state": $state, "attributes": {"unique_id": $uid, "device_class": "energy", "unit_of_measurement": $uom, "state_class": "total_increasing" }}')
	echo "is electric"
  elif is_water $EPT; then
    RESTDATA=$( jq -nrc --arg state "$STATE" --arg uid "$scmUID" --arg uom "$WUOM" '{"state": $state, "attributes": {"unique_id": $uid}, "unit_of_measurement": $uom }')
	echo "is water : " $RESTDATA
  else
    RESTDATA=$( jq -nrc --arg state "$STATE" --arg uid "$scmUID" '{"state": $state, "attributes": {"unique_id": $uid}}')
  fi
  }
scmplus_parse
echo -n "Sending  $RESTDATA  to http://supervisor/core/api/states/sensor.$DEVICEID -- "


