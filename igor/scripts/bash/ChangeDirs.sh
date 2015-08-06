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

# script to replace all patterns like 
# "#include (<whatever>/)*" --> "#include (<whatever>:)*"
original=`pwd`
mDir="../../"
fileRegex='*ipf'
# change to the working directory
cd $mDir
# (1) find all the files
# (2) on the lines where:
## (2a) the line starts with '#include'
## (2b) replace all backwards slashes with colon
# note, coming from
# http://unix.stackexchange.com/questions/155331/sed-replace-a-character-in-a-matched-line-in-place
# /^#include/ -- this selects lines that start with include
# s/\\/:/g    -- this replaces the literal <\> with a colon literal <:> on 
# the entire line (global
find . -type f -iname '*ipf' | xargs sed -E -i .bak '/^#include/s/\\/:/g'
# go back to the original directory
cd $original



