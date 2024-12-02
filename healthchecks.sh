#!/bin/bash

source /scripts/config-vars.sh

/scripts/warp-healthcheck.sh || exit 1

exit 0
