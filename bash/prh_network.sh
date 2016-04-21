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

# Description:
# bash utility to mount the network drives
ServerLoc="perknas2.colorado.edu/group/"
UserName="pahe3165"
MountLocation="/Volumes/group/"

function MountServer(){
    sudo mkdir -p "${MountLocation}"
    # try to unmount the mount location, dont worry if it breaks
    sudo umount "${MountLocation}" || true
    # mount the server with my username at the 'conventional' location
    sudo mount -t cifs "//${ServerLoc}"  -o "username=${UserName}" \
	"${MountLocation}"
}


MountServer



