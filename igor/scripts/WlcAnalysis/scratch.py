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

from HDF5Util import  ReadHDF5FileDataSet
from SqlUtil import InitSqlGetSessionAndClasses,GetSrcFiles,GetTraceParams
from WlcFuncs import FitWlc,GetOStretchByIndices
from WlcUtil import SaveTimeSepForceToFile
from multiprocessing import Pool

class AnalysisObj:
    def __init__(self,params,paramsStd,mFile,deltaL0,oStretchForce,
                 whereOStretch):
        self._params = params
        self._paramsStd = paramsStd
        self._file = mFile
        self._deltaL0 = deltaL0
        self._oStretchForce = oStretchForce
        self._whereOStretch = whereOStretch
        

def analyzeSingleFile(sqlObj,mFileObj,i,nFiles,inPath,outPath,plotFile,fitLp,
                      nMedianMeters=150e-6):
    mVals,mMeta = GetTraceParams(sqlObj,mFileObj)
    mIndex = [int(val.DataIndex) for val in mVals]
    f = mFileObj.FileTimSepFor
    # XXX need to fix this; database gets filenames not in hdf
    fullFilePath = inPath + f + ".hdf"
    mDat = ReadHDF5FileDataSet(fullFilePath)
    mOffIdx = mIndex[0] # first index is the offset
    # get the data columns. need to offset everything
    time,sep,force = mDat[:,0],mDat[:,1],mDat[:,2]  
    nMaxParams = 8
    # use a median offset filter
    medianSep = sep[mOffIdx:]
    # get the change in extension over the entire range of interest
    averageDelta = max(medianSep)-min(medianSep)
    # determine the (integer) number of points to average)
    nMedian = int(np.ceil(nMedianMeters/averageDelta))
    offset = lambda x,idx1: x[idx1:] - np.median(x[idx1:idx1+nMedian])
    startOfWLC = mIndex[1]
    time = time[mOffIdx:] - time[mOffIdx]
    sep = offset(sep,mOffIdx)
    force = offset(force,mOffIdx)
    # force is flipped by default
    force *= -1
    mLastIdx= mIndex[2]-mOffIdx # third index is the final fit location
    forceFit = force[:mLastIdx]
    sepFit = sep[:mLastIdx] 
    L0Guess = sepFit[-1]
    # fouth parameter is actual extensions
    params,paramsStd,predicted = FitWlc(sepFit,forceFit,L0=L0Guess,Lp=43e-9,
                                          extensible=True,fitLp=fitLp)
    deltaL0 = None
    oStretchForce = None
    whereOStretch = None
    mParams = []
    mPredictedX = []
    mPredictedY = []
    finalWlcPred = None
    sepFinalWLC = None
    if (len(mIndex) == nMaxParams):
        # then we have all the parameters needed to determine deltaL0 and
        # the overstretching force
        # XXX put this in a model somewhere
        mStartIdx = [1,3,5]
        fitInitials = [ mIndex[idx]-mOffIdx for idx in mStartIdx]
        fitFinals = [ mIndex[idx+1]-mOffIdx for idx in mStartIdx]
        res = GetOStretchByIndices(sep,force,fitInitials,fitFinals)
        # get all the information relevant to the plotting...
        mParams,mPredictedX,mPredictedY,whereOStretch,oStretchForce=res
        # get the final WLC index
        finalWlcEnd = mIndex[nMaxParams-1]-mOffIdx
        startOfFinalWLC = mIndex[nMaxParams-4]-mOffIdx
        # get the force and sep for the WLC fit...
        # colon notation ('[:]') makes a hard copy
        forceFinalWLC = force[startOfFinalWLC:finalWlcEnd]
        sepFinalWLC = sep[startOfFinalWLC:finalWlcEnd]
        wlcFinalParams,_,finalWlcPred = FitWlc(sepFinalWLC,forceFinalWLC,
                                               extensible=True,offsetIdx=0)
        finalL0 = wlcFinalParams[0]
        firstL0 = params[0]
        deltaL0 = wlcFinalParams[0]-firstL0
    # if the user wants, plot
    if (plotFile):
        PlotFile(sepFit,predicted,sep,force,mIndex,outPath,i,deltaL0,
                 oStretchForce,mParams,mPredictedX,mPredictedY,whereOStretch,
                 sepFinalWLC,finalWlcPred)
    return AnalysisObj(params,paramsStd,f,deltaL0,oStretchForce,whereOStretch)

def PlotFile(sepFit,predictedFit,sepFull,forceFull,mIndex,outPath,i,deltaL0,
             oStretchForce,mParams,mPredictedX,mPredictedY,whereOStretch,
             sepFinalWlc,finalWlcPred):
    mOffIdx = mIndex[0]
    plotSep = lambda x: x * 1e9 # to nm
    plotForce = lambda x: x * 1e12 # to pn
    fig = pPlotUtil.figure(dpi=300)
    plt.plot(plotSep(sepFull),plotForce(forceFull),color='k',alpha=0.4,
             label="Raw Data")
    plt.plot(plotSep(sepFit),plotForce(predictedFit),linestyle='-',
             label="Initial WLC",linewidth=3.0)
    for idx in mIndex:
        plt.axvline(plotSep(sepFull[idx-mOffIdx]))
    if (deltaL0 is not None):
        # then we should plot things related to overstretching
        for mX,mY in zip(mPredictedX,mPredictedY):
            plt.plot(plotSep(mX),plotForce(mY),linestyle='-',linewidth=4)
        plt.plot(plotSep(whereOStretch),plotForce(oStretchForce),'o',
                 markersize=8)
        plt.plot(plotSep(sepFinalWlc),plotForce(finalWlcPred),'m',
                 label="Final WLC",linewidth=3,linestyle='--')
    pPlotUtil.lazyLabel("Separation, microns",'Force [pN]',
                        "Force Sep")
    pPlotUtil.savefig(fig,outPath + str(i) + ".png")

# gets the WLC L0,deltaL0, ostretchTx, etc, makes a list 
# of AnalysisObj for this purpose
def getWLCFeatures(mFiles,sqlObj,inPath,outPath,plotWLC,fitLp,limit):
    toRet = []
    nFiles = len(mFiles)
    for i,f in enumerate(mFiles):
        # check and see if we reached the limit.
        if ( (limit is not None) and i == limit):
            print("Breaking Early, reached limit of {:d}".format(i))
            break
        mNew= analyzeSingleFile(sqlObj,f,i,nFiles,inPath,outPath,plotWLC,
                                fitLp=fitLp)
        toRet.append(mNew)
        print("{:d}/{:d}".format(i,nFiles))
    return toRet

def analyzeObjWithOStretch(mObjs,outPath):
    n = 0
    objWithTx = []
    miniStr = "DNA_MINI"
    robStr = "From_Rob"
    for i,obj in enumerate(mObjs):
        if (obj._deltaL0 is None):
            continue
        if (np.abs(obj._deltaL0) > 3e-6):
            continue
        mFile = obj._file
        # only look at minis and robs data
        if (not (miniStr in mFile or robStr in mFile)):
            continue
        print(obj._file)
        objWithTx.append(obj)
    nObjTx = len(objWithTx)
    # get the countour lengths, deltaL0, and ostretcxTx
    # convert to plotting units
    toMicrons = 1e6
    toPn = 1e12
    oStretchTxForce = np.array([ o._oStretchForce for o in objWithTx ]) * toPn
    deltaL0 = np.array([ o._deltaL0 for o in objWithTx ]) * toMicrons
    L0 =  np.array([ o._params[0] for o in objWithTx ]) * toMicrons
    xVals = np.array([L0,L0])
    yVals = [oStretchTxForce,deltaL0]
    nBasePairs = 1800
    metersPerBp=0.34e-9
    # 1800 bp, 0.34nm/bp, convert to microns
    expectedL0 = nBasePairs*metersPerBp*toMicrons 
    # expected force is 65pN (cannonical DNA ostretch)
    # expected deltaL0 is 70% of the contour length
    expectedY = [65,expectedL0*0.7]
    expectedX = [expectedL0,expectedL0]
    # make labels for the plot
    contourLab = r'Contour Length $L_0$ [$\mu$m]'
    forceLab = r'$F_{Ovr}$ [pN]'
    deltaLab = r'$\Delta L_0$ [$\mu$m]'
    xLab = [contourLab,contourLab]
    yLab = [forceLab,deltaLab]
    getColor = lambda fileName: 'red' if robStr in fileName else 'blue'
    mColors = [ getColor(obj._file) for obj in objWithTx]
    for datX,datY,xExp,yExp,xLab,yLab in \
        zip(xVals,yVals,expectedX,expectedY,xLab,yLab):
        mTitle = "{:s} vs {:s} for {:d} Curves".format(yLab,xLab,nObjTx)
        mOut = outPath + mTitle + ".png"
        fig = pPlotUtil.figure()
        plt.scatter(datX,datY,marker='o',color=mColors,
                    label="Data from fitting WLC")
        # draw a marker at the expected location
        plt.plot(xExp,yExp,'+',markersize=20,label="Expected Value")
        pPlotUtil.lazyLabel(xLab,yLab,mTitle,frameon=True)
        pPlotUtil.savefig(fig,mOut)

def run(inPath='/Volumes/group/4Patrick/PRH_AFM_Databases/BinaryFilesTimeSeparationForce/',
        outPath='/Users/patrickheenan/Desktop/WorkingDNA/',
        fitLp=True,limit=None):
    pGenUtil.ensureDirExists(outPath)
    # set up a session, dynamically get all the classes.
    sqlObj = InitSqlGetSessionAndClasses()
    mFiles = GetSrcFiles(sqlObj)
    nFiles = len(mFiles)
    mGlobalSql = sqlObj
    mGlobalFiles = mFiles
    plotWLC = False
    forceAnalysis = False
    lpStr = "FitLp" if fitLp else "NoFitLp"
    mCheckAnalysis = outPath + "mAnalysis{:s}.pkl".format(lpStr)
    mObjs = pCheckUtil.getCheckpoint(mCheckAnalysis,getWLCFeatures,
                                     forceAnalysis,mFiles,sqlObj,inPath,
                                     outPath,plotWLC,fitLp,limit=limit)
    # analyze all the WLC curves with overstretching transitions.
    analyzeObjWithOStretch(mObjs,outPath)
if __name__ == "__main__":
    run()
