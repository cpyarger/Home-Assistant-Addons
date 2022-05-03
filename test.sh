
#!/bin/bash

SCMPGD=100
line='{"Time":"2022-05-02T07:24:37.453867711-04:00","Offset":0,"Length":0,"Type":"SCM","Message":{"ID":23876447,"Type":4,"TamperPhy":0,"TamperEnc":2,"Consumption":22281,"ChecksumVal":44665}}'
function is_gas() {
    LIST="00,01,02,09,156"
    DELIMITER=","
    VALUE=$1
    [[ "$LIST" =~ ($DELIMITER|^)$VALUE($DELIMITER|$) ]]
}
function is_electric() {
    LIST="04,05,07,08"
    DELIMITER=","
    VALUE=$1
    [[ "$LIST" =~ ($DELIMITER|^)$VALUE($DELIMITER|$) ]]
}
function is_water() {
    LIST="03,11,13"
    DELIMITER=","
    VALUE=$1
    [[ "$LIST" =~ ($DELIMITER|^)$VALUE($DELIMITER|$) ]]
}

function scmplus_parse {
  STATE="$(echo $line | jq -rc '.Message.Consumption' | tr -s ' ' '_')"
  FIXED_STATE=$(($STATE/$SCMPGD))
  EPT=$(echo $line | jq -rc '.Message.EndpointType' | tr -s ' ' '_')
  if [ ! -z "$EPT" ]; then
    echo "ept null try '.Message.Type'"
    EPT=$(echo $line | jq -rc '.Message.Type' | tr -s ' ' '_')
  fi
  echo "EPT= " $EPT
  scmUID=$DEVICEID-sdrmr
  if is_gas $EPT; then
    echo "is gas"
    RESTDATA=$( jq -nrc --arg state "$FIXED_STATE" --arg uid "$scmUID" --arg uom "$GUOM" '{"state": $state, "attributes": {"unique_id": $uid, "state_class": "total_increasing", "device_class": "gas",  "unit_of_measurement": $uom }}')
  elif is_electric $EPT; then
    echo "is electric"
    RESTDATA=$( jq -nrc --arg state "$STATE" --arg uid "$scmUID" --arg uom "$EUOM" '{"state": $state, "attributes": {"unique_id": $uid, "device_class": "energy", "unit_of_measurement": $uom }}')
  elif is_water $EPT; then
    echo "is water"
    RESTDATA=$( jq -nrc --arg state "$STATE" --arg uid "$scmUID" --arg uom "$WUOM"'{"state": $state, "attributes": {"unique_id": $uid}, "unit_of_measurement": $uom }')
  else
    echo "is default"
    RESTDATA=$( jq -nrc --arg state "$STATE" --arg uid "$scmUID" '{"state": $state, "attributes": {"unique_id": $uid}}')
  fi
  }
