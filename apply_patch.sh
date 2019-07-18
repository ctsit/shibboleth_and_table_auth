#!/bin/bash

#TODO: read from file?
REDCAP_VERSION=9.1.1
REDCAP_PATCH_VERSION=9.1.1

# determine the directory where this script resides
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# create a random 15 char alphanumeric string to avoid any possible clashes
RAND="$(head -n 1 /dev/urandom | tr -dc '[:alnum:]' | fold -w 15 | head -n 1)"

TEMP_UNZIP_DIR=/tmp/redcap_unzip_${RAND}

# unzip files into redcap_unzip directory
unzip redcap${REDCAP_VERSION}.zip -d $TEMP_UNZIP_DIR

pushd $TEMP_UNZIP_DIR/redcap/redcap_v${REDCAP_VERSION}
    DRY="$(patch -p4 --dry-run < $DIR/redcap-${REDCAP_PATCH_VERSION}.patch)"
    # first check if the patch has any issues
    if [[ $DRY == *"FAILED"* ]]; then
        echo "Patching has failed due to "
        echo $DRY
        exit 1
    elif [[ $DRY == *"offset"* ]]; then
        echo "Patching was offset but will proceed"
        echo $DRY
    fi
    echo "REDCap ${REDCAP_VERSION} was successfully patched"
    patch -p4 < $DIR/redcap-${REDCAP_PATCH_VERSION}.patch # actually perform the patch

pushd $TEMP_UNZIP_DIR
    zip -ur $DIR/redcap${REDCAP_VERSION}.zip . # update the zip file with the new information

pushd -0 && dirs -c # return to home directory and clear directory stack

rm -rf $TEMP_UNZIP_DIR

echo "Please use the patched zip file, redcap${REDCAP_VERSION}, as you normally would."
