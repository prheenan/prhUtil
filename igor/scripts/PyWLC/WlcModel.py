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
sys.path.append('../PyUtil')
sys.path.append('../PyWlc')

from SqlUtil import GetTraceParams

class ModelParams:
    # has parameters: 
    #self._xyOff     : index for the XY offset (touchoff)
    #self._wlc1Init  : index for the start of the *first* linear WLC region
    #self._wlc1Final  : index for the end   of the *first* linear WLC region
    #self._oStretchInit : index for the start of the overstretching region
    #self._ostretchFinal : index for the end of the overstretching region
    #self._wlc2Init  : index for the start of the *second* linear WLC region
    #self._wlc2Final : index for the end of the *second* linear WLC region
    #self._rupture   : index for thefinal rupture
    # Note: only guarenteed to have the first three be non-null
    def __init__(self,xyOff,wlc1Init,wlc1Final,oStretch1=None,oStretch2=None,
                 wlc2Init=None,wlc2Final=None,rupture=None):
        self._xyOff = xyOff
        self._wlc1Init = wlc1Init
        self._wlc1Final = wlc1Final
        self._oStretchInit = oStretch1
        self._ostretchFinal = oStretch2
        self._wlc2Init = wlc2Init
        self._wlc2Final = wlc2Final
        self._rupture = rupture

def GetWlcParams(sqlObj,fileObj):
    mVals,mMeta = GetTraceParams(sqlObj,fileObj)
    mIndices = [int(val.DataIndex) for val in mVals]
    return ModelParams(*mIndices)
