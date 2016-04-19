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

function p_setup(){
    # p_setup: call this before installing anything
    # remove the local cache
    sudo rm /var/lib/apt/lists/* -vf & 
    # update apt
    sudo apt-get update
}

# We assume python is already install on ubuntu
function p_install(){
    # p_install: command to install a 'system' package (e.g. emacs)
    # flags:
    # -y: assume yes to all prompts, run non-interactively
    sudo apt-get install --fix-missing -y "$@"
    
}

function p_depend(){
    # p_depend: command to build dependencies (e.g. for matplotlib)
    sudo apt-get build-dep "$@"
}

function p_pyinstall(){
    # p_pyinstall: command to install a python package
    sudo pip install --upgrade "$@"
}



# setup the install
p_setup
# install emacs( i know, i know)...
p_install emacs
# install sql 
p_install mysql-server
# get cifs-utils, for mapping network drives
p_install cifs-utils
# get windbind so we can recognize windows names
p_install libnss-winbind
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



