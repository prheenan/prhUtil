#!/bin/bash
# courtesy of: http://redsymbol.net/articles/unofficial-bash-strict-mode/
# (helps with debugging)
# set -e: immediately exit if we find a non zero
# set -u: undefined references cause errors
# set -o: single error causes full pipeline failure.
set -euo pipefail
IFS=$'\n\t'
# datestring, used in many different places...
dateStr=`date +%Y-%m-%d:%H:%M:%S`


#include ":ViewUtil" // replace ".: with ":
#include "::Sql:SqlCypherInterface" // replace ".." with "::"

mDir="../../"
fileRegex='*ipf'
# apply to double colons, starting with a dot
mRegex='/^#include/s/"\.:\.\.:/"::/g'
bash ./ApplySedToFiles.sh $mDir $fileRegex $mRegex
# aplly to double colons, not starting with a dot
mRegex='/^#include/s/"\.\.:/"::/g'
bash ./ApplySedToFiles.sh $mDir $fileRegex $mRegex
# apply to single colons
mRegex='/^#include/s/"\.:/":/g'
bash ./ApplySedToFiles.sh $mDir $fileRegex $mRegex

