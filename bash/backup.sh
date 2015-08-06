#!/bin/bash
# courtesy of: http://redsymbol.net/articles/unofficial-bash-strict-mode/
# (helps with debugging)
# set -e: immediately exit if we find a non zero
# set -u: undefined references cause errors
# set -o: single error causes full pipeline failure.
set -euo pipefail
IFS=$'\n\t'
# run this every hour by the following in <crontab-e>:
# MAILTO="" # disable mail
# 0 * * * * bash /Users/patrickheenan/utilities/bash/backup.sh # run this file

# backup all the utilitty files
inDir="/Users/patrickheenan/utilities/"
outDir="/Users/patrickheenan/Dropbox/backup"
# flags:
# <a>: archive mode, preserves links 
# <v>: more verbose
# <z>: compress during transfer
rsync -avz $inDir $outDir




