#!/bin/bash

# determine the directory where this script resides
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/version.config

REDCAP_DIR=~/projects/REDCap

pushd $REDCAP_DIR
git diff -U5 -p -r --diff-algorithm=minimal master..shibboleth-table-auth --output=$DIR/../redcap-${REDCAP_VERSION}.patch
popd

# replace all non-diff lines with CRLF line endings
perl -p -i -e 's/^(?!(diff|index|@@|---|\+\+\+))(.*)\n$/\2\n/' redcap-${REDCAP_VERSION}.patch
