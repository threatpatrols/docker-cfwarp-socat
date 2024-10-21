#!/bin/bash

set -e

# setup an isolated cloudflare reg.json file that is required to make sure cloudflare warp does not
# break when previous var-data exists in /var/lib/cloudflare-warp
mkdir -p "${WARP_REGDATA_MOUNT}"
touch "${WARP_REGDATA_MOUNT}/reg.json"
cp "${WARP_REGDATA_MOUNT}/reg.json" /var/lib/cloudflare-warp/reg.json
printf " >> [warp-register] reg.json (head-64b): %s\n" "$(head -c64 /var/lib/cloudflare-warp/reg.json)"

# create an appropriate cloudflare-warp/mdm.xml if the data for it exists
if [ -n "${WARP_ORGANIZATION}" ]; then
  if [ -z "${WARP_CLIENT_ID}" ]; then echo " >> [warp-register] WARP_CLIENT_ID not set"; exit 1; fi
  if [ -z "${WARP_CLIENT_SECRET}" ]; then echo " >> [warp-register] WARP_CLIENT_SECRET not set"; exit 1; fi
  if [ -z "${WARP_CONNECTOR_TOKEN}" ]; then echo " >> [warp-register] WARP_CONNECTOR_TOKEN not set"; exit 1; fi

# https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/mdm-deployment/parameters/
cat >/var/lib/cloudflare-warp/mdm.xml <<EOF
<dict>
  <key>organization</key>
  <string>${WARP_ORGANIZATION}</string>
  <key>auth_client_id</key>
  <string>${WARP_CLIENT_ID}</string>
  <key>auth_client_secret</key>
  <string>${WARP_CLIENT_SECRET}</string>
  <key>warp_connector_token</key>
  <string>${WARP_CONNECTOR_TOKEN}</string>
</dict>
EOF
fi

if [ -f "/var/lib/cloudflare-warp/mdm.xml" ]; then
  echo " >> [warp-register] cloudflare-warp/mdm.xml file present"
  ls -al "/var/lib/cloudflare-warp/mdm.xml"
fi

# if /var/lib/cloudflare-warp/reg.json not exists, register the warp client
if [ "$(wc -c /var/lib/cloudflare-warp/reg.json | cut -d' ' -f1)" -eq 0 ]; then
    echo " >> [warp-register] registering new Warp client"
    rm -f /var/lib/cloudflare-warp/reg.json
    warp-cli registration new

  # if license key is provided, set it
  if [ -n "$WARP_LICENSE_KEY" ]; then
      echo " >> [warp-register] setting Warp license"
      warp-cli set-license "$WARP_LICENSE_KEY"
  fi
fi
