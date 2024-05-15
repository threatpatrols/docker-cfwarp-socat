#!/bin/bash

# Set exit on any exit code
# ===
set -e

# Set some env var defaults
# ===
CLOUDFLAREWARP_INFO_DELAY="${CLOUDFLAREWARP_INFO_DELAY:-90}"
CLOUDFLAREWARP_DATA_MOUNT="${CLOUDFLAREWARP_DATA_MOUNT:-/var/lib/cloudflare-warp/data}"

# Create a tun device for CloudflareWARP to work with
# ===
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun

# Echo version data
# ===
printf "========\n"
warp-cli --version

# Setup and echo cloudflare-warp/reg.json
# ===
printf "\n========\n"
echo " >> reg.json mount: ${CLOUDFLAREWARP_DATA_MOUNT}/reg.json"
mkdir -p "${CLOUDFLAREWARP_DATA_MOUNT}"
touch "${CLOUDFLAREWARP_DATA_MOUNT}/reg.json"
cp "${CLOUDFLAREWARP_DATA_MOUNT}/reg.json" /var/lib/cloudflare-warp/reg.json
printf " >> reg.json head : "
head -c64 /var/lib/cloudflare-warp/reg.json
printf "\n"

# Create the /var/lib/cloudflare-warp/mdm.xml file
# ===
if [ -z ${CLOUDFLAREWARP_ORGANIZATION} ]; then echo "ERROR: CLOUDFLAREWARP_ORGANIZATION not set"; exit 1; fi
if [ -z ${CLOUDFLAREWARP_CLIENT_ID} ]; then echo "ERROR: CLOUDFLAREWARP_CLIENT_ID not set"; exit 1; fi
if [ -z ${CLOUDFLAREWARP_CLIENT_SECRET} ]; then echo "ERROR: CLOUDFLAREWARP_CLIENT_SECRET not set"; exit 1; fi
if [ -z ${CLOUDFLAREWARP_CONNECTOR_TOKEN} ]; then echo "ERROR: CLOUDFLAREWARP_CONNECTOR_TOKEN not set"; exit 1; fi

# https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/mdm-deployment/parameters/
cat >/var/lib/cloudflare-warp/mdm.xml <<EOF
<dict>
  <key>organization</key>
  <string>${CLOUDFLAREWARP_ORGANIZATION}</string>
  <key>auth_client_id</key>
  <string>${CLOUDFLAREWARP_CLIENT_ID}</string>
  <key>auth_client_secret</key>
  <string>${CLOUDFLAREWARP_CLIENT_SECRET}</string>
  <key>warp_connector_token</key>
  <string>${CLOUDFLAREWARP_CONNECTOR_TOKEN}</string>
</dict>
EOF

# Start the CloudflareWARP daemon
# ===
mkdir -p /run/cloudflare-warp
warp-svc | grep -v "DEBUG" | grep -v "FileNotFound" | grep -v "D-Bus error" &

# Create the socat pipes defined by env vars
# ===
printf "\n========\n"
while IFS= read -r socat_args || [[ -n $socat_args ]]; do
  if [ -n "${socat_args}" ]; then
    socat_cmd="socat ${socat_args}"
    echo " >> ${socat_cmd}"
    $(${socat_cmd}) &
  fi
done < <(printf '%s' "$(env | grep CLOUDFLAREWARP_SOCAT | cut -d'=' -f2-)")
printf "\n"

# Output networking details after a delay that waits for CloudflareWARP to become stable
# ===
sleep "${CLOUDFLAREWARP_INFO_DELAY}"
printf "\n\n========\n"
ip -4 addr | grep -v valid_

printf "\n========\n"
route -n

printf "\n========\n"
ip route show table all | grep -v ':' | grep Cloudflare
printf "\n"

# Final loop to keep container running; and copy cloudflare-warp/reg.json to the data mount
# ===
while true; do
  cp /var/lib/cloudflare-warp/reg.json "${CLOUDFLAREWARP_DATA_MOUNT}/reg.json"
  sleep 30
done

exit 1
