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
function p_install(){
    sudo apt-get install "$@"
}

function p_depend(){
    sudo apt-get build-dep "$@"
}

function p_pyinstall(){
    sudo pip install --upgrade "$@"
}

# install emacs( i know, i know)...
p_install emacs
## install pip
p_install python-pip python-dev build-essential 
p_pyinstall pip 
p_pyinstall virtualenv
### get packages we use, need the dependencies
## numpy / matplotlib dependencies
p_depend python-matplotlib
## hdf5 dependencies
# we need this for h5py
p_install libhdf5-serial-dev
# actual python backages
p_pyinstall  scipy
p_pyinstall  matplotlib
p_pyinstall  numpy
p_pyinstall  scikit-image
p_pyinstall  scikit-learn
# for hdf5 stack
p_pyinstall  h5py
# for sql stuff 
p_pyinstall  sqlalchemy
# move the utilities folder, if we need to
mv ~/prhUtil/ ~/utilities/



