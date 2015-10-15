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

# idea of this file is to hold a lot of the 'brains' for the 
# actual surface detection. should be fairly easy to port, etc. 

class CalibrateObject:
    # keeps track of calibration (approach or retraction touchoff)
    # idxStart and idxEnd are from 'getCrossIdxFromApproach': the start
    # and end of the 'invols' region. sliceAppr and sliceTouch are the
    # slices before and after this region. the parameters are the GenFit
    # returns for the two regions; time and index are where the intersections
    # happen (nominally, where the surface is)
    def __init__(self,idxStart,idxEnd,sliceAppr,sliceTouch,
                 params1,paramsStd1,predicted1,
                 params2,paramsStd2,predicted2,
                 timeSurface,idxSurface):
        self._idxStart = idxStart 
        self._idxEnd = idxEnd
        self._sliceAppr = sliceAppr
        self._sliceTouch = sliceTouch
        self._params1 = params1
        self._paramsStd1 = paramsStd1
        self._predicted1 = predicted1
        self._params2 = params2
        self._paramsStd2 = paramsStd2
        self._predicted2 = predicted2
        self._timeSurface = timeSurface
        self._idxSurface = idxSurface

# gets the start and end index of the surface touchoff (ie: where invols
# are calculated). Assumes that somewhere in forceDiff is a *single*
# high location (high derivative), followed by a low derivate until the end.
def getCrossIdxFromApproach(forceDiff,method=None,approachIfTrue=True):
    # get the maximum force change location
    maxDiffIdx = np.argmax(forceDiff)
    # get the median, and where we are <= the median
    median = np.median(forceDiff)
    whereLess = np.where(forceDiff <= median)[0]
    # look where we are less than the median *and* {before/after} the max
    # this gets a decent guess for where the surface contact happens
    # (ie: between the two bounds)
    # last element is -1
    lastIndexBeforeList = whereLess[np.where(whereLess < maxDiffIdx)]
    if (lastIndexBeforeList.size == 0):
        lastIndexBefore = 0
    else:
        lastIndexBefore = lastIndexBeforeList[-1]
    # first element is 0 
    possibleFirstIdx = whereLess[np.where(whereLess > maxDiffIdx)]
    # if we neever went back to the median, we likely had no dwell.
    # just use the entire curve.
    if (possibleFirstIdx.size == 0):
        firstIndexAfter = forceDiff.size-1
    else:
        firstIndexAfter =  possibleFirstIdx[0]
    return lastIndexBefore,firstIndexAfter

def getTouchoffCalibration(timeAppr,forceAppr,mDerivApproach,isApproach):
    idxStart,idxEnd = getCrossIdxFromApproach(mDerivApproach)
    # fit lines to the force
    # start and end *always demarcate the start and end (ish) of the invols
    # if we are approach, we take everything *before* as constant
    # if we are touchoff, we take everything *after* as constant
    if (isApproach):
        constantSlice = np.s_[0:idxStart]
        touchoffSlice = np.s_[idxStart:idxEnd]
    else:
        constantSlice = np.s_[idxEnd:]
        touchoffSlice = np.s_[idxStart:idxEnd]
    timeApprLow = timeAppr[constantSlice]
    timeTouch = timeAppr[touchoffSlice]
    paramsFirst,stdFirst,predFirst= pGenUtil.GenFit(timeApprLow,
                                                    forceAppr[constantSlice])
    paramsSecond,stdSecond,predSecond = \
                    pGenUtil.GenFit(timeTouch,forceAppr[touchoffSlice])
    # XXX get error estimate using standard deviations?
    timeSurface = pGenUtil.lineIntersectParam(paramsFirst,
                                              paramsSecond)
    idxSurface = np.argmin(np.abs(timeAppr-timeSurface))
    # set the variables we care about
    calibObj = CalibrateObject(idxStart,idxEnd,
                               constantSlice,touchoffSlice,
                               paramsFirst,stdFirst,predFirst,
                               paramsSecond,stdSecond,predSecond,
                               timeSurface,idxSurface)
    return calibObj

def run():
    pass

if __name__ == "__main__":
    run()
