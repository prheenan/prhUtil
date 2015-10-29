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
sys.path.append('../../PyUtil')
sys.path.append('../../PyWlc')
import datetime # for epoch seconds
from SqlUtil import GetTraceParams,GetMeta

class ModelParams:
    # has parameters: 
    #self._xyOff     : index for the XY offset (touchoff)
    # Note: only guarenteed to have the first three be non-null
    def __init__(self,mSqlObj,fileObj,xyOffIdx,xyOffSep):
        self._xyOffIdx = xyOffIdx
        self._xyOffSep = xyOffSep
        self._mMeta = GetMeta(mSqlObj,fileObj)

def GetSurfParams(sqlObj,fileObj):
    mVals,mMeta = GetTraceParams(sqlObj,fileObj)
    idx = mVals[0].DataIndex
    val = float(mVals[0].DataValues)
    return ModelParams(sqlObj,fileObj,idx,val)
