#!/bin/bash

# check for input, exit if none given
if [ $# -eq 0 ]; then
    echo "Please provide the filename of the redcap zip file you wish to patch."
    exit
fi

REDCAP_ZIP=${1}
REDCAP_VERSION=`echo ${REDCAP_ZIP} | sed "s/redcap//; s/_upgrade//; s/.zip//;"`

# autodetect proper patch version
MIN_REDCAP_PATCH_VERSION=9.1.1

PATCH_VERSIONS=$(mktemp)
$(ls *.patch | grep -v "sql" | sed "s/redcap-//; s/\.patch//;" > $PATCH_VERSIONS)
if [[ $(cat $PATCH_VERSIONS | grep "$REDCAP_VERSION") ]]; then
    REDCAP_PATCH_VERSION=$REDCAP_VERSION
else
    echo "${REDCAP_VERSION}" >> "$PATCH_VERSIONS"
    if [[ "$(cat $PATCH_VERSIONS | sort -V | head -n 1)" != "$MIN_REDCAP_PATCH_VERSION" ]]; then
        echo "${REDCAP_VERSION} is below the minimum supported version, ${MIN_REDCAP_PATCH_VERSION} and will not be patched. Aborting process."
        rm $PATCH_VERSIONS
        exit
    fi
    REDCAP_PATCH_VERSION=$(cat $PATCH_VERSIONS | sort -V | grep "$REDCAP_VERSION" -B 1 | head -n1)
fi

rm $PATCH_VERSIONS

echo "Attempting to patch ${REDCAP_ZIP} using patch version ${REDCAP_PATCH_VERSION}"

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
    DRY="$(patch -p1 --dry-run < $DIR/redcap-${REDCAP_PATCH_VERSION}.patch)"
    # first check if the patch has any issues
    if [[ $DRY == *"FAILED"* || $DRY == *"malformed"* ]]; then
        echo "Patching has failed"
        echo $DRY
        echo "Please report this error as an issue at https://github.com/ctsit/shibboleth_and_table_auth/issues"
        echo "Please include the text of the error and the REDCap version you were trying to patch."
        exit 1
    elif [[ $DRY == *"offset"* || $DRY == *"fuzz"* ]]; then
        echo "Patching was offset but will proceed"
        echo "Please report this warning as an issue at https://github.com/ctsit/shibboleth_and_table_auth/issues"
        echo "Please include the text of the warning and the REDCap version you are patching."
    fi
    patch -p1 < $DIR/redcap-${REDCAP_PATCH_VERSION}.patch # actually perform the patch
    echo "REDCap ${REDCAP_ZIP} was successfully patched"

echo "Zipping patched redcap into ${TARGET_FILE}"
pushd $TEMP_UNZIP_DIR > /dev/null
    rm -f ${TARGET_DIR}/${REDCAP_ZIP}
    zip -q -r ${TARGET_DIR}/${REDCAP_ZIP} . # write a new zip file with the patch applied

pushd -0 > /dev/null && dirs -c # return to home directory and clear directory stack

rm -rf $TEMP_UNZIP_DIR

echo "Please use the patched zip file, ${TARGET_FILE}, as you normally would."
