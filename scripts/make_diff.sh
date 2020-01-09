#!/bin/bash

# determine the directory where this script resides
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/version.config

pushd $VANDY_REDCAP_DIR
git diff -U15 -p -r --diff-algorithm=minimal tags/${VANDY_REDCAP_BRANCH_A}..${VANDY_REDCAP_BRANCH_B} --output=$DIR/../redcap-${REDCAP_VERSION}.patch
#git diff -U15 -p -r --diff-algorithm=minimal master..shibboleth-table-auth --output=$DIR/../redcap-${REDCAP_VERSION}.patch
popd

# add CRLF line endings to all context and diff lines by excluding lines introduced by diff
perl -p -i -e 's/^(?!(diff|index|@@|---|\+\+\+))(.*)\n$/\2\n/' redcap-${REDCAP_VERSION}.patch
