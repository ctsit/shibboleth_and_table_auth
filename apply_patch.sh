#!/bin/bash

# check for input, exit if none given
if [ $# -eq 0 ]; then
    echo "Please provide the filename of the redcap zip file you wish to patch."
    exit
fi

REDCAP_ZIP=${1}
REDCAP_PATCH_VERSION=9.1.1
REDCAP_VERSION=`echo ${REDCAP_ZIP} | sed "s/redcap//; s/_upgrade//; s/.zip//;"`

# determine the directory where this script resides
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# make sure we have a place to write our output
TARGET_DIR=${DIR}/output
if [[ ! -e  $TARGET_DIR ]]; then
    mkdir ${TARGET_DIR}
fi
TARGET_FILE=output/${REDCAP_ZIP}

# unzip files into a temporary redcap_unzip directory
if [ ! -e ${REDCAP_ZIP} ]; then
    echo "${REDCAP_ZIP} does not exist. Please provide a valid file name."
    exit
fi
echo "Unzipping ${REDCAP_ZIP} into a temporary folder"
echo "Please be patient, this may take a few minutes"
TEMP_UNZIP_DIR=`mktemp -d`
unzip -q ${REDCAP_ZIP} -d $TEMP_UNZIP_DIR

pushd $TEMP_UNZIP_DIR/redcap/redcap_v${REDCAP_VERSION} > /dev/null
    DRY="$(patch -p4 --dry-run < $DIR/redcap-${REDCAP_PATCH_VERSION}.patch)"
    # first check if the patch has any issues
    if [[ $DRY == *"FAILED"* ]]; then
        echo "Patching has failed"
        echo $DRY
        echo "Please report this error as an issue at https://github.com/ctsit/shibboleth_and_table_auth/issues"
        echo "Please include the text of the error and the REDCap version you were trying to patch."
        exit 1
    elif [[ $DRY == *"offset"* ]]; then
        echo "Patching was offset but will proceed"
        echo $DRY
        echo "Please report this warning as an issue at https://github.com/ctsit/shibboleth_and_table_auth/issues"
        echo "Please include the text of the warning and the REDCap version you are patching."
    fi
    patch -p4 < $DIR/redcap-${REDCAP_PATCH_VERSION}.patch # actually perform the patch
    echo "REDCap ${REDCAP_ZIP} was successfully patched"

echo "Zipping patched redcap into ${TARGET_FILE}"
pushd $TEMP_UNZIP_DIR > /dev/null
    zip -q -ur ${TARGET_DIR}/${REDCAP_ZIP} . # write a new zip file with the patch applied

pushd -0 > /dev/null && dirs -c # return to home directory and clear directory stack

rm -rf $TEMP_UNZIP_DIR

echo "Please use the patched zip file, ${TARGET_FILE}, as you normally would."
