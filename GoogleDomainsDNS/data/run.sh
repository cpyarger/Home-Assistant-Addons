#!/usr/bin/env bashio

#CERT_DIR=/data/letsencrypt
#WORK_DIR=/data/workdir

# Let's encrypt
#LE_UPDATE="0"

# DuckDNS
if bashio::config.has_value "ipv4"; then IPV4=$(bashio::config 'ipv4'); else IPV4=""; fi
if bashio::config.has_value "ipv6"; then IPV6=$(bashio::config 'ipv6'); else IPV6=""; fi
DOMAIN=$(bashio::config 'domain')
USERNAME=$(bashio::config 'username')
PASSWORD=$(bashio::config 'password')
WAIT_TIME=$(bashio::config 'seconds')
#ALGO=$(bashio::config 'lets_encrypt.algo')

# Function that performe a renew
#**
#function le_renew() {
#    dehydrated --cron --algo "${ALGO}" --hook ./hooks.sh --challenge dns-01 --domain "${DOMAIN}" --out "${CERT_DIR}" --config "${WORK_DIR}/config" || true
#    LE_UPDATE="$(date +%s)"
#}/#

# Register/generate certificate if terms accepted
#if bashio::config.true 'lets_encrypt.accept_terms'; then
#    # Init folder structs
#    mkdir -p "${CERT_DIR}"
#    mkdir -p "${WORK_DIR}"

    # Clean up possible stale lock file
#    if [ -e "${WORK_DIR}/lock" ]; then
#        rm -f "${WORK_DIR}/lock"
#        bashio::log.warning "Reset dehydrated lock file"
#    fi

    # Generate new certs
#    if [ ! -d "${CERT_DIR}/live" ]; then
#        # Create empty dehydrated config file so that this dir will be used for storage
#        touch "${WORK_DIR}/config"
#
#        dehydrated --register --accept-terms --config "${WORK_DIR}/config"
#    fi
#fi

# Run Script
while true; do
    # Get public IP Address
    currentipaddress="$(curl icanhazip.com)"
    # Update Google Domains
    if answer="$(curl -s -o /dev/null -w "%{http_code}" --data-urlencode "hostname=$DOMAIN" --data-urlencode "myip=$currentipaddress" -H "Host: domains.google.com" -u "$USERNAME:$PASSWORD" "https://domains.google.com/nic/update")" && [ "${answer}" != 'KO' ]; then
        bashio::log.info "${answer}"
    else
        bashio::log.warning "${answer}"
    fi
    # Check if enough time has passed and update Let's Encrypt
    #now="$(date +%s)"
    #if bashio::config.true 'lets_encrypt.accept_terms' && [ $((now - LE_UPDATE)) -ge 43200 ]; then
    #    le_renew
    #fi

    sleep "${WAIT_TIME}"
done
