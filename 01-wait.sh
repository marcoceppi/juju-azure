#!/bin/bash
# This script configures the environment

# Make it verbose for debug
set -ex 

# Load variables
HERE=`pwd`
. ${HERE}/common.sh

find ${UPLOAD_FOLDER} -name "*.publishsettings" -exec mv "{}" "${AZURECREDS}" \;

sleep 1

[ -f "${AZURECREDS}" ] && ${HERE}/02-bootstrap.sh || logger "Nothing yet. Waiting for next cronjob..."



