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
# Add the ptdraft folder path to the utilities
sys.path.append('../PyUtil')
sys.path.append('../PyWlc')
# import what we need 
from scipy.signal import savgol_filter
import HDF5Util,SqlUtil,WlcModel

class AnalysisObject:
    def __init__(self,time,sep,force,number,mParams,sqlFileObj,
                 mDir="./out/",nSmooth=51,degSmooth=2,
                 fractionForApproach=0.5):
        # work in nm, seconds, and pN
        sep *= 1e9
        force *= 1e12
        self._mDir = mDir
        self._mIndices = mParams
        self._sqlId = sqlFileObj.idTraceData
        self._srcFile= sqlFileObj.FileTimSepFor
        # time is assumed to be OK
        self._time = time
        self._sep = sep
        self._force = force
        self._nSmooth= nSmooth
        self._mDir = mDir + str(number)
        self._degSmooth = degSmooth
        self._nApproach = np.ceil(fractionForApproach * (time.size))
        self._forceSmooth = self.smooth(force)
        self._rawDeriv = np.gradient(force)
        self._smoothDeriv = np.gradient(self._forceSmooth)
    def smooth(self,toSmooth):
        return savgol_filter(toSmooth,self._nSmooth,self._degSmooth)
    def getApproachTimeSepForce(self):
        N = self._nApproach
        return self._time[:N],self._sep[:N],self._force[:N]

def forceHistogram(force,firstDeriv,outName):
    fig = pPlotUtil.figure(dpi=200)
    nPoints = np.sqrt(len(force))
    plt.subplot(2,1,1)
    plt.hist(force,bins=nPoints)
    pPlotUtil.lazyLabel("Force [pN]","Counts","Histogram of force")
    plt.subplot(2,1,2)
    plt.hist(firstDeriv,bins=nPoints)
    pPlotUtil.lazyLabel("Force Differential [pN]","Counts","Histogram of DelF")
    pPlotUtil.savefig(fig,outName)

# gets the start and end index of the surface touchoff (ie: where invols
# are calcularted)
# XXX TODO: add in different methods?
def getCrossIdxFromApproach(forceDiff,method=None):
    # get the maximum force change location
    maxDiffIdx = np.argmax(forceDiff)
    # get the median, and where we are <= the median
    median = np.median(forceDiff)
    whereLess = np.where(forceDiff <= median)[0]
    # look where we are less than the median *and* {before/after} the max
    # this gets a decent guess for where the surface contact happens
    # (ie: between the two bounds)
    # last element is -1
    lastIndexBefore = whereLess[np.where(whereLess < maxDiffIdx)][-1]
    # first element is 0 
    possibleFirstIdx = whereLess[np.where(whereLess > maxDiffIdx)]
    # if we neever went back to the median, we likely had no dwell.
    # just use the entire curve.
    if (possibleFirstIdx.size == 0):
        firstIndexAfter = forceDiff.size-1
    else:
        firstIndexAfter =  possibleFirstIdx[0]
    return lastIndexBefore,firstIndexAfter

def plotForceWithDerivs(force,time,outName,smoothed=False,rawForce=None):
    idxStart = None
    idxEnd = None
    firstDeriv = np.gradient(force)
    # only if we are smoothing do we try to find the start/endpoints
    if (smoothed):
        idxStart,idxEnd = getCrossIdxFromApproach(firstDeriv)
    fig = pPlotUtil.figure(dpi=200)
    nPlots = 2
    counter=  1
    plt.subplot(nPlots,1,counter)
    counter += 1
    plt.plot(time,force,'r-')
    if (rawForce is not None):
        plt.plot(time,rawForce,'k.',markersize=0.1,alpha=0.5,label="Raw Data")
    # if smoothing, show where we found the touchoff points
    if (smoothed):
        timeStart = time[idxStart]
        timeEnd = time[idxEnd]
        plt.axvline(timeEnd,color='b')
        plt.axvline(timeStart,color='b',label="Calculated bounds of touchoff")
    pPlotUtil.lazyLabel("Time (s)","Force (pN)","Force Verus Time")
    plt.subplot(nPlots,1,counter)
    counter += 1
    plt.plot(time,firstDeriv)
    plt.axhline(np.median(firstDeriv),color='r',
                linewidth=3.0,linestyle='--',label="Median Force Diff")
    pPlotUtil.lazyLabel("Time (s)","Delta Force (pN)","Force Differential")
    # plot the gradient of force over time
    pPlotUtil.savefig(fig,outName)    

def setAnalysisObj(time,sep,force,number,*args,**kwargs):
    mObj = AnalysisObject(time,sep,force,number,*args,**kwargs)
    mDerivApproach = mObj._smoothDeriv[:mObj._nApproach]
    idxStart,idxEnd = getCrossIdxFromApproach(mDerivApproach)
    mObj._idxTouchStart = idxStart
    mObj._idxTouchEnd  = idxEnd 
    # fit lines to the force
    mObj._sliceAppr = np.s_[:mObj._idxTouchStart]
    mObj._sliceTouch = np.s_[mObj._idxTouchStart:mObj._idxTouchEnd]
    timeAppr,_,forceAppr = mObj.getApproachTimeSepForce()
    timeApprLow = timeAppr[mObj._sliceAppr]
    timeTouch = timeAppr[mObj._sliceTouch]
    mObj._paramsAppr,mObj._paramsStdAppr,mObj._predictedAppr = \
                            pGenUtil.GenFit(timeApprLow,
                                            forceAppr[mObj._sliceAppr])
    mObj._paramsTouch,mObj._paramsStdTouch,mObj._predictedTouch = \
                            pGenUtil.GenFit(timeTouch,
                                            forceAppr[mObj._sliceTouch])
    # XXX get error estimate using standard deviations?
    mObj._timeSurface = pGenUtil.lineIntersectParam(mObj._paramsAppr,
                                                    mObj._paramsTouch)
    mObj._idxSurface = np.argmin(np.abs(timeAppr-mObj._timeSurface))
    return mObj

def plotApproachObject(mObj):
    mDir = mObj._mDir
    timeAppr,sepAppr,forceAppr = mObj.getApproachTimeSepForce()
    plotForceWithDerivs(forceAppr,timeAppr,
                        mDir + "ForceNoFilter.png")
    # get the smoothed gradient of the approach:
    smoothApproach = mObj._forceSmooth[:mObj._nApproach]
    plotForceWithDerivs(smoothApproach,timeAppr,
                        mDir + "ForceWithFilter.png",
                        smoothed=True,rawForce=forceAppr)
    # get the raw and smoothed derivatives...
    rawDeriv = mObj._rawDeriv
    smoothDeriv = mObj._smoothDeriv
    # get the distribution of the force and derivatives
    forceHistogram(forceAppr,rawDeriv,mDir + "HistRaw.png")
    forceHistogram(mObj._forceSmooth,mObj._smoothDeriv,mDir + "HistFilter.png")
    # determine the indices for the start/end of the ramp
    fig = pPlotUtil.figure()
    # plot versus time and separation
    plt.subplot(2,1,1)
    timeApprLow = timeAppr[mObj._sliceAppr]
    timeTouch = timeAppr[mObj._sliceTouch]
    plt.plot(timeAppr,forceAppr,'k.',alpha=0.3,markersize=0.5)
    plt.plot(timeApprLow,mObj._predictedAppr,'r-',label='Approach Line')
    plt.plot(timeTouch,mObj._predictedTouch,'b-',label='Touchoff Line')
    plt.axvline(mObj._timeSurface,color='k',linewidth=0.5,linestyle='--',
                label="Inferred surface location")
    pPlotUtil.lazyLabel("Time [s]","Force[pN]","Surface Touchoff")
    plt.subplot(2,1,2)
    # get the actual XY offset 
    idxOffset = mObj._mIndices._xyOff
    # offset everything to that
    offsetSep   = mObj._sep - mObj._sep[idxOffset] 
    offsetForce = mObj._force - mObj._force[idxOffset] 
    # flip the force upside down, since that is the way it is stored
    offsetForce *= -1
    plt.plot(offsetSep,offsetForce,'k-',alpha=0.3)
    plt.axvline(offsetSep[mObj._idxSurface],color='b',linewidth=2.0,
                linestyle='--',label="Surface Location (Auto)")
    plt.plot(offsetSep[idxOffset],offsetForce[idxOffset],'ro',markersize=8,
             label="Surface Location (By Hand)")
    pPlotUtil.lazyLabel("Separation [nm]","Force[pN]","")
    pPlotUtil.savefig(fig,mDir + "ApprSepCurves.png")


def AnalyzeSingle(sqlObj,sqlFileObj,mDataPath,number,outDir,plot=True):
    # for now, simple plotting
    # convert the force to pN, separation to um
    # Look for the approach curve; limit to first half initially
    mFilePath = mDataPath + sqlFileObj.FileTimSepFor
    mParams = WlcModel.GetWlcParams(sqlObj,sqlFileObj)
    time,sep,force =  SqlUtil.GetTimeSepForce(mFilePath)
    nPoints = len(force)
    approachIndex = nPoints/2
    timeAppr = time[:approachIndex]
    sepAppr = sep[:approachIndex]
    forceAppr = force[:approachIndex]
    mObj = setAnalysisObj(time,sep,force,number,mParams,sqlFileObj,mDir=outDir)
    if (plot):
        plotApproachObject(mObj)
    # return the object, we can re-analyze if need be
    return mObj
    
# right now, really can only run on patricks machine. switch...
def run(limit=None):
    # get all the files we need in the database
    sqlObj = SqlUtil.InitSqlGetSessionAndClasses()
    mFiles = SqlUtil.GetSrcFiles(sqlObj)
    nFiles = len(mFiles)
    # assume that the binary files live in the default directory
    mDataPath = SqlUtil.DefaultDataDir
    # output directory
    mOutDir = SqlUtil.DefaultWorkDir + "SurfaceDection/"
    pGenUtil.ensureDirExists(mOutDir)
    for i in range(nFiles):
        # limit to one.
        if (limit is not None and (i == limit)):
            break
        mId = mFiles[i].idTraceData
        mCheckDir = mOutDir + "_" + str(mId) + "Data.pkl"
        mObj = pCheckUtil.getCheckpoint(mCheckDir,AnalyzeSingle,False,
                                        sqlObj,mFiles[i],mDataPath,mId,mOutDir)
        sep = mObj._sep
        sepLabelled = sep[mObj._mIndices._xyOff]
        sepAuto = sep[mObj._idxSurface]

if __name__ == "__main__":
    run()
