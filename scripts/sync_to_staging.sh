#!/bin/bash

# determine the directory where this script resides
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/version.config

rsync -rcv --exclude=.git --exclude=.DS_Store --exclude='*.*.swp' ${VANDY_REDCAP_DIR}/ deploy@redcapstage.ctsi.ufl.edu:/var/https/stage_c/redcap_v${REDCAP_VERSION}/
