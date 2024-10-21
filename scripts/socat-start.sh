#!/bin/bash

set -e

# SOCAT
# =============================================================================

while IFS= read -r _socat_env || [[ -n $_socat_env ]]; do
  if [ -n "${_socat_env}" ]; then
    socat_cmd="socat ${_socat_env}"
    echo " >> [socat-start] command: ${socat_cmd}"
    bash -c "${socat_cmd}" &
  fi
done < <(printf '%s' "$(env | sort | grep ^SOCAT_ARGS_ | cut -d'=' -f2-)")
