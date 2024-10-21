#!/bin/bash

set -e

# Start
# =============================================================================
printf "cfwarp-socat: %s\n" "$(date -u -Iseconds)"


# SOCAT_
# =============================================================================

while IFS= read -r _socat_env || [[ -n $_socat_env ]]; do
  if [ -n "${_socat_env}" ]; then
    _socat_args="$(echo "SOCAT_ARGS_${_socat_env}" | cut -d'_' -f1,2,5- )"
    export "$(echo "${_socat_args}" | cut -d'=' -f1)"="$(echo "${_socat_args}" | cut -d'=' -f2-)"
  fi
done < <(printf '%s' "$(env | grep ^CLOUDFLAREWARP_SOCAT)")  # handle legacy SOCAT_ env var names

# Output SOCAT_ configs
env | grep -v -i "secret" | grep "^SOCAT_" || true


# Global
# =============================================================================
export DEBUG=${DEBUG:=}

# Output DEBUG configs
env | grep -v -i "secret" | grep "^DEBUG"


# Cloudflare Warp
# =============================================================================
export WARP_START_DELAY=${WARP_START_DELAY:=5}
export WARP_CONNECT_RETRY_MAX=${WARP_CONNECT_RETRY_MAX:=20}
export WARP_CONNECT_RETRY_SLEEP=${WARP_CONNECT_RETRY_SLEEP:=5}
export WARP_LICENSE_KEY=${WARP_LICENSE_KEY:=}
# export WARP_EXCLUDE_LOCALNETS=${WARP_EXCLUDE_LOCALNETS:=}

if [ -n "${CLOUDFLAREWARP_DATA_MOUNT}" ]; then
  export WARP_REGDATA_MOUNT=${CLOUDFLAREWARP_DATA_MOUNT}  # support for legacy WARP_REGDATA_MOUNT variable name
else
  export WARP_REGDATA_MOUNT=${WARP_REGDATA_MOUNT:=/var/lib/cloudflare-warp/regdata}
fi

if [ -n "${CLOUDFLAREWARP_ORGANIZATION}" ]; then
  export WARP_ORGANIZATION=${CLOUDFLAREWARP_ORGANIZATION}  # support for legacy WARP_ORGANIZATION variable name
else
  export WARP_ORGANIZATION=${WARP_ORGANIZATION:=}
fi

if [ -n "${CLOUDFLAREWARP_CLIENT_ID}" ]; then
  export WARP_CLIENT_ID=${CLOUDFLAREWARP_CLIENT_ID}  # support for legacy WARP_CLIENT_ID variable name
else
  export WARP_CLIENT_ID=${WARP_CLIENT_ID:=}
fi

if [ -n "${CLOUDFLAREWARP_CLIENT_SECRET}" ]; then
  export WARP_CLIENT_SECRET=${CLOUDFLAREWARP_CLIENT_SECRET}  # support for legacy WARP_CLIENT_SECRET variable name
else
  export WARP_CLIENT_SECRET=${WARP_CLIENT_SECRET:=}
fi

if [ -n "${CLOUDFLAREWARP_CONNECTOR_TOKEN}" ]; then
  export WARP_CONNECTOR_TOKEN=${CLOUDFLAREWARP_CONNECTOR_TOKEN}  # support for legacy WARP_CONNECTOR_TOKEN variable name
else
  export WARP_CONNECTOR_TOKEN=${WARP_CONNECTOR_TOKEN:=}
fi


# Output WARP_ configs
env | grep -v -i "secret" | grep "^WARP_"


# End
# =============================================================================
printf "\n"
