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

# use 'lineSedStmt' [3] on all files matching 'mExt'[2] in 'mDir'[1]
mDir=$1
mExt=$2
lineSedStmt=$3

# script to replace all patterns like 
# "#include (<whatever>/)*" --> "#include (<whatever>:)*"
original=`pwd`
mDir="../../"
# change to the working directory
cd $mDir
# single quotes: don't interpret anything. 
# http://stackoverflow.com/questions/6697753/difference-between-single-and-double-quotes-in-bash
mExt='*ipf' 
# (1) find all the files
# (2) on the lines where the sed line applies
# http://unix.stackexchange.com/questions/155331/sed-replace-a-character-in-a-matched-line-in-place
find . -type f -iname "$mExt" | xargs sed -E -i .bak $lineSedStmt
# go back to the original directory
cd $original


