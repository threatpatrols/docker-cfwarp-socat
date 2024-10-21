#!/bin/bash

# exit when any command fails
set -e

source /scripts/config-vars.sh

if [ -n "${DEBUG}" ]; then
  set -x
fi

/scripts/warp-connect.sh
/scripts/warp-system-status.sh 60 &  # display system status after a delay
/scripts/socat-start.sh

while true; do
  cp /var/lib/cloudflare-warp/reg.json "${WARP_REGDATA_MOUNT}/reg.json"

  if [ $(pgrep --exact --count warp-svc) -lt 1 ]; then
    echo " >> [entrypoint] warp-svc process not running, exiting now."
    exit 1
  fi

  if [ $(pgrep --exact --count socat) -lt 1 ]; then
    echo " >> [entrypoint] socat process not running, exiting now."
    exit 1
  fi

  sleep 10
done
