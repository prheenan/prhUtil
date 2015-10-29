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

class WlcOpts:
    DEF_FEC_HEADER = "Time[s],Separation[m],Force[N]"
    DEF_FEC_DELIM = ","
    DEF_FEC_FMT = "%015.10g"

class WlcFittingObject:
    def __init__(self,mFile):
        # file is assumed to be an hdf5 binary file.
        self._mFile = mFile

# save time,sep and force to a (text) file.
def SaveTimeSepForceToFile(time,sep,force,filePath,
                           header=WlcOpts.DEF_FEC_HEADER,
                           delim=WlcOpts.DEF_FEC_DELIM,fmt=WlcOpts.DEF_FEC_FMT,
                           **kwargs):
    mToSave = np.column_stack((sep.flatten(),time.flatten(),force.flatten()))
    np.savetxt(filePath,mToSave,fmt=fmt,delimiter=delim,header=header,**kwargs)

def run():
    pass

if __name__ == "__main__":
    run()
