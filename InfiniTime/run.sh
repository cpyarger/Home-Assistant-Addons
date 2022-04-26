#!/bin/sh
export LD_LIBRARY_PATH=/usr/local/lib64
export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

CONFIG_PATH=/data/options.json

ls

echo "infinitime addon"

echo "battery" 
itctl get batt

echo ""
echo "heartrate"
itctl get heart

echo "test notification"
itctl notify "this is a test"