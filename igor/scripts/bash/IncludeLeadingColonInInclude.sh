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


mDir="../../"
fileRegex='*ipf'
# /^#include/             -- this selects lines that start with include
# s/(#include ")/"\1:/g'  -- adds a colon to an include followed by a quote
# XXX should check for a alpha character?
mRegex='/^#include/s/(#include ")/"\1:/g'
bash ./ApplySedToFiles.sh $mDir $fileRegex $mRegex


