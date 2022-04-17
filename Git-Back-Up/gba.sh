#!/bin/sh
export LANG=C
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"

CONFIG_PATH=/data/options.json
REMOTE_REPO="$(jq --raw-output '.git_url' $CONFIG_PATH)"
RSA_KEY="$(jq --raw-output '.git_rsa_kay' $CONFIG_PATH)"
HA_ENABLE="$(jq --raw-output '.home_assistant_config_enable' $CONFIG_PATH)"
ESPH_ENABLE="$(jq --raw-output '.esphome_config_enable' $CONFIG_PATH)"

echo "Git Back Up Start"


ls /
ls /config
sleep 1
echo "Git Back Up Start"