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
# installs (lots of python stuff) patrick uses, assuming on ubuntu

# We assume python is already install on ubuntu

## install pip
sudo apt-get install python-pip python-dev build-essential 
sudo pip install --upgrade pip 
sudo pip install --upgrade virtualenv
## get packages we use, need the dependencies
sudo apt-get build-dep python-matplotlib
sudo pip install --upgrade scipy
sudo pip install --upgrade matplotlib
sudo pip install --upgrade numpy
# for hdf5 stack
sudo pip install --upgrade h5py
# for sql stuff 
sudo pip install --upgrade sqlalchemy
# move the utilities folder, if we need to
mv ~/prhUtil/ ~/utilities/



