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
# /^#include/ -- this selects lines that start with include
# s/\\/:/g    -- this replaces the literal <\> with a colon literal <:> on 
# the entire line (global
mRegex='/^#include/s/\\/:/g'
bash ./ApplySedToFiles.sh $mDir $fileRegex $mRegex




