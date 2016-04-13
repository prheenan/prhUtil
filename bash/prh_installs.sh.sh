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
## get packages we use
pip install scipy
pip install matplotlib
pip install numpy
# for hdf5 stack
pip install h5py
# for sql stuff 
pip install sqlalchemy
# move the utilities folder, if we need to
mv ~/prhUtil/ ~/utilities/



