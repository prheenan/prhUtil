# force floating point division. Can still use integer with //
from __future__ import division
# This file is used for importing the common utilities classes.
import numpy as np
import matplotlib.pyplot as plt
# need to add the utilities class. Want 'home' to be platform independent
from os.path import expanduser
home = expanduser("~")
# get the utilties directory (assume it lives in ~/utilities/python)
# but simple to change
path= home +"/utilities/python"
import sys
sys.path.append(path)
# import the patrick-specific utilities
import GenUtilities  as pGenUtil
import PlotUtilities as pPlotUtil
import CheckpointUtilities as pCheckUtil
# recquired packages for HD5
import h5py

READ_MODE ='r'
# default output from igor.
DEFAULT_IGOR_DATASET = u'PrhHD5GenericData'
# binary hdf5 extention
DEFAULT_HDF5_EXTENSION = ".hdf"
# Binary file columns
COLUMN_TIME = 0
COLUMN_SEP = 1
COLUMN_FORCE = 2

def ReadHDF5FileDataSet(inFile,dataSet=DEFAULT_IGOR_DATASET ):
    if (not pGenUtil.isfile(inFile)):
        mErr = ("ReadHDF5File : File {:s} not found.".format(inFile) +
                "Do you need to connect to a netwrok drive to find your data?")
        raise IOError(mErr)
    # POST: the file at least exists
    try:
        mFile = h5py.File(inFile,READ_MODE)
        toRet = mFile[dataSet][:]
    finally:
        # always close the file
        mFile.close()
    return toRet

