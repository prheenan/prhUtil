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
from scipy.signal import savgol_filter,welch
import HDF5Util,SqlUtil,WlcModel
import CypherUtil
from SurfaceUtil import getCrossIdxFromApproach,getTouchoffCalibration
import scipy.interpolate as interpolate


# rationale for 20Hz smoothing: in approach curve, PSD
# shows a rolloff frequency (knee) of about 200-300Hz
# filtering to 20Hz has two effects:
# (1) Squashes the knee frequency down by a ~factor of 10 
# (2) More importantly, removes (most) noise on the order of 
# our time of interest (typically O(0.05 to 0.1s) for 'invols' touchoff) )
DEFAULT_SMOOTH_TIME = 0.05 # 20Hz
# this could probably be dynamically calculated using a small amount of
# labelled data, or a simple change point algorithm (classic step function)


class AnalysisObject:
    def __init__(self,time,sep,force,number,mParams,sqlFileObj,
                 mDir="./out/",nSmooth=None,degSmooth=2,
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
        if (nSmooth == None):
            # use the default, assume time increase linearly
            totalTOverDesired =DEFAULT_SMOOTH_TIME/np.median(np.diff(time))
            nSmooth = int(np.ceil(totalTOverDesired))
            # nSmooth *must* be odd for the savitsky golay filter to work
            if (nSmooth % 2 == 0):
                nSmooth += 1
        self._nSmooth= nSmooth
        self._mDir = mDir + str(number)
        self._degSmooth = degSmooth
        self._nApproach = np.ceil(fractionForApproach * (time.size))
        self._forceSmooth = self.smooth(force)
        self._rawDeriv = np.gradient(force)
        self._smoothDeriv = np.gradient(self._forceSmooth)
        # calibration objects
        self._mApproach = None
        self._mRetract = None
    # smooth whatever by a savitsky golay, using the parameters from
    # the constructor
    def smooth(self,toSmooth):
        return savgol_filter(toSmooth,self._nSmooth,self._degSmooth)
    # get the approach or retract slice
    def getSlice(self,isApproach):
        N = self._nApproach
        # return the first N, or everything after the first N.
        if (isApproach):
            return np.s_[:N]
        else:
            return np.s_[N:]
    def getApproachTimeSepForce(self):
        mSlice = self.getSlice(isApproach=True)
        return self._time[mSlice],self._sep[mSlice],self._force[mSlice]
    def getRetractTimeSepForce(self):
        # get everything *not* the approach...
        mSlice = self.getSlice(isApproach=False)
        return self._time[mSlice],self._sep[mSlice],self._force[mSlice]
    def getTimeSepForce(self,isApproach):
        if (isApproach):
            return self.getApproachTimeSepForce()
        else:
            return self.getRetractTimeSepForce()  
    # given an (absolute list) of time, find the index where
    # we predict the surface is
    def getSurfaceIndexFromTime(self,time,isApproach):
        if (isApproach):
            mTime = self._mApproach._timeSurface
        else:
            mTime = self._mRetract._timeSurface
        # return the index where the absolute value is the smallest.
        return np.argmin(np.abs(time-mTime))

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
    approach = [True,False]
    for isApproach in approach:
        # save the approach and retraction velocity curves
        timeAppr,_,forceAppr =mObj.getTimeSepForce(isApproach)
        # get the slice we want, for the derivative
        mSlice = mObj.getSlice(isApproach)
        mDeriv = mObj._smoothDeriv[mSlice]
        # looking for maximum derivatives; 
        # if we aren't approach, then the slope will be 
        # negative, so flip it.
        if (not isApproach):
            mDeriv *= -1
        calibObj = getTouchoffCalibration(timeAppr,forceAppr,mDeriv,isApproach)
        # Get he calibration object for this region 
        # (ie: we have a single high-derivative 
        # set the calibration object appropriately.
        if (isApproach):
            mObj._mApproach = calibObj
        else:
            mObj._mRetract = calibObj
    return mObj

def plotApproachObject(mObj):
    # plot both the approach and retraction
    appr = [False,True]
    lab = ["Approach","Retract"]
    for isApproach,lab in zip(appr,lab):
        mDir = mObj._mDir + lab
        timeAppr,sepAppr,forceAppr = mObj.getTimeSepForce(isApproach)
        calibObj = mObj._mApproach if isApproach else mObj._mRetract
        # get the smoothed gradient of the approach:
        if (isApproach):
            smoothApproach = mObj._forceSmooth[:mObj._nApproach]
        else:
            smoothApproach = mObj._forceSmooth[mObj._nApproach:] * -1
            forceAppr *= -1
        # start plotting stuff!
        plotForceWithDerivs(forceAppr,timeAppr,
                            mDir + "ForceNoFilter.png")
        plotForceWithDerivs(smoothApproach,timeAppr,
                            mDir + "ForceWithFilter.png",
                            smoothed=True,rawForce=forceAppr)
        # get the raw and smoothed derivatives...
        rawDeriv = mObj._rawDeriv
        smoothDeriv = mObj._smoothDeriv
        # get the distribution of the force and derivatives
        forceHistogram(forceAppr,rawDeriv,mDir + "HistRaw.png")
        forceHistogram(mObj._forceSmooth,mObj._smoothDeriv,mDir +\
                       "HistFilter.png")
        # determine the indices for the start/end of the ramp
        fig = pPlotUtil.figure()
        # plot versus time and separation
        plt.subplot(2,1,1)
        timeApprLow = timeAppr[calibObj._sliceAppr]
        timeTouch = timeAppr[calibObj._sliceTouch]
        plt.plot(timeAppr,forceAppr,'k.',alpha=0.3,markersize=0.5)
        plt.plot(timeApprLow,calibObj._predicted1,'r-',label='Approach Line')
        plt.plot(timeTouch,calibObj._predicted2,'b-',label='Touchoff Line')
        plt.axvline(calibObj._timeSurface,color='k',linewidth=0.5,
                    linestyle='--',label="Inferred surface location")
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
        plt.axvline(offsetSep[calibObj._idxSurface],color='b',linewidth=2.0,
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

# plots the approach noise from an analysis object
def PlotApproachNoise(mObj):
    isApproach = True
    timeAppr,_,forceAppr = mObj.getTimeSepForce(isApproach)
    calibObj = mObj._mApproach if isApproach else mObj._mRetract
    mIndex = mObj.getSurfaceIndexFromTime(timeAppr,isApproach)
    # only look up to where we touch the surface for the approach,
    # or after the surface for the retraction
    if (isApproach):
        timeBeforeSurface = timeAppr[:calibObj._idxSurface]
        forceBeforeSurface = forceAppr[:calibObj._idxSurface]
    else:
        timeBeforeSurface = timeAppr[calibObj._idxSurface:]
        forceBeforeSurface = forceAppr[calibObj._idxSurface:]
    mFFT = np.fft.rfft(forceBeforeSurface)
    # get the relevant frequencies
    sampleSpacing = timeAppr[1]-timeAppr[0]
    sampleFrequency = 1./sampleSpacing
    smoothApproach = mObj.smooth(forceBeforeSurface)
    f,PSD_Raw = welch(forceBeforeSurface,fs=sampleFrequency)
    _,PSD_Filtered = welch(smoothApproach,fs=sampleFrequency)
    fig = pPlotUtil.figure()
    plt.subplot(2,1,1)
    plt.plot(timeBeforeSurface,forceBeforeSurface,'b',label="Approach Data")
    plt.plot(timeAppr,forceAppr,'k',alpha=0.3)
    plt.plot(timeBeforeSurface,smoothApproach,'r-',label="SV Filtered")
    pPlotUtil.lazyLabel("Time (s)","Force (pN)","Force versus Time")
    ax = plt.subplot(2,1,2)
    plt.plot(f,PSD_Raw,label="PSD, raw data")
    plt.plot(f,PSD_Filtered,label="PSD, SV Filtered")
    ax.set_xscale('log')
    ax.set_yscale('log')
    pPlotUtil.lazyLabel("Frequency (Hz)","FFT Coefficient Value (au/Hz)",
                        "PSD of approach")
    pPlotUtil.savefig(fig,mObj._mDir + "Spectrum.png")

def getZsnsr(analysisObj,normToMax=True):
    mMeta = analysisObj._mIndices._mMeta
    springConstpNnm = float(mMeta.SpringConstant) * 1e3
    involsNm = float(mMeta.DeflInvols) * 1e9
    startDist = float(mMeta.StartDist) * 1e9
    Zsnsr = CypherUtil.convertToZSensorLocation(analysisObj._sep,analysisObj._force,
                                                involsNm,springConstpNnm)
    if (normToMax == True):
        Zsnsr -= np.max(Zsnsr)
    return Zsnsr

# gets the low and high indices for plotting for the analysis objects
def getLowHighIdx(analysisObj):
    mSurfaceIdx = analysisObj._mApproach._idxSurface
    nApproach = analysisObj._nApproach
    lowIdx = (mSurfaceIdx-nApproach/100)
    highIdx = nApproach
    return lowIdx,highIdx

# get lists (effectively uneven 2-D arrays)
# of the approach force and zsensor, zeroed to the min
# force and the maximum Zsensor, respectively
def getApproachZsnsrForceList(mAnalysisObjects):
    # first of all, get a grid on which to interpolate
    # find the full max and minimum
    forceToRet = []
    ZsnsrToRet = []
    for mObj in mAnalysisObjects:
        lowX,highX = getLowHighIdx(mObj)
        myZ = getZsnsr(mObj)[lowX:highX]
        # determine wht we are interpolating
        forces = mObj._force[lowX:highX]
        forces -= np.amin(forces)
        forceToRet.append(forces)
        ZsnsrToRet.append(myZ)
    return forceToRet,ZsnsrToRet

def plotAnalysisObjects(mAnalysisObjects):
    forces,Zsnsr = getApproachZsnsrForceList(mAnalysisObjects)
    # get the times of the analysis objects, for coloring the traces
    # we use the approach curve, although probably the retract should be fine
    # too (they come from the same wave internally, so same meta data)
    mStartTimes = [obj._mIndices.getStartTimeOfFEC() 
                   for obj in mAnalysisObjects]
    # normalize the start times to between 0 and 1
    minV = min(mStartTimes)
    maxV = max(mStartTimes)
    mStartTimes = (np.array(mStartTimes) - minV)/(maxV-minV)
    # POST: mStartTimes are between 0 and 1...
    mCat = lambda x : np.concatenate(x)
    minForce = np.amin(mCat(forces))
    maxForce = np.amax(mCat(forces))
    minZsnsr = np.amin(mCat(Zsnsr))
    maxZsnsr = np.amax(mCat(Zsnsr))
    # make grids for the forces and Z (Z sensor)
    nObj =  len(mAnalysisObjects)
    nInterpForce = 15
    nInterpZ = 15
    gridForce = np.linspace(minForce,maxForce,num=nInterpForce)
    gridZ = np.linspace(minZsnsr,maxZsnsr,num=nInterpZ)
    # save all of the interpolated values
    # all grid z is where we interpolate forces onto a Z grid
    allGridZ = np.zeros((nObj,nInterpZ))
    # all grid forc is where we interpolate Zsnsr onto a force grid
    allGridForce = np.zeros((nObj,nInterpForce))
    for i,(forceTmp,Ztmp) in enumerate(zip(forces,Zsnsr)):
        allGridForce[i,:] = np.interp(gridForce,forceTmp,Ztmp)
        allGridZ[i,:] = np.interp(gridZ,Ztmp,forceTmp)
    # get the mean and standard deviation for the force and Z grids
    meanZsens = np.mean(allGridForce,axis=0)
    stdZsens = np.std(allGridForce,axis=0)
    # do the sane for forces
    meanForce = np.mean(allGridZ,axis=0)
    stdForce = np.std(allGridZ,axis=0)
    # get the mean and standard deviaton of the error distributions
    averageForceDelta = np.mean(stdForce)
    averageZsnsrDelta = np.mean(stdZsens)
    stdForceDelta = np.std(stdForce)
    stdZsnsrDelta = np.std(stdZsens)
    # plot the Force versus Z sensor
    fig = pPlotUtil.figure(xSize=12,ySize=10,dpi=300)
    # only plot up to the approach index
    defLabel = lambda :   pPlotUtil.lazyLabel("Z Sensor (nm)","Force(pN)","")
    mColorIntensity = mStartTimes
    colormap = plt.cm.autumn
    lineAlpha = 0.5
    axisbg=[0.8,0.8,0.8]
    for i,(forceTmp,Ztmp) in enumerate(zip(forces,Zsnsr)):
        # copy and pasted....
        plt.subplot(2,2,1,axisbg=axisbg)
        plt.plot(Ztmp,forceTmp,color=colormap(mColorIntensity[i]),
                 alpha=lineAlpha)
        defLabel()
        plt.subplot(2,2,2,axisbg=axisbg)
        ax = plt.plot(Ztmp,forceTmp,color=colormap(mColorIntensity[i]),
                      alpha=lineAlpha)
        pPlotUtil.xlabel("Z Sensor(nm)")
        pPlotUtil.tickAxisFont()
    stdDict = dict(marker="o",linewidth=3.0,markersize=9.0)
    lineDict = dict(color="k",linewidth=5.0)
    forceColor = 'g'
    zColor = 'b'
    plt.subplot(2,2,1,axisbg=axisbg)
    # add the mean and standard deviation for F
    plt.errorbar(gridZ,meanForce,yerr=stdForce,color=forceColor,**stdDict)
    defLabel()
    plt.subplot(2,2,3,axisbg=axisbg)
    plt.plot(gridZ,stdForce,color=forceColor,**stdDict)
    plt.axhline(averageForceDelta,label="Force Err\n {:.0f}{:s}{:.0f}pN".\
                format(averageForceDelta,r'$\pm$',stdForceDelta),
                **lineDict)
    pPlotUtil.lazyLabel("Z Sensor (nm)","Force Error (pN)","",loc="upper left")
    plt.subplot(2,2,2,axisbg=axisbg)
    plt.errorbar(meanZsens,gridForce,xerr=stdZsens,color=zColor,**stdDict)
    pPlotUtil.legend()
    plt.subplot(2,2,4,axisbg=axisbg)
    plt.errorbar(meanZsens,stdZsens,color=zColor,**stdDict)
    plt.axhline(averageZsnsrDelta,label="Sensor Err\n {:.0f}{:s}{:.0f} nm".\
                format(averageZsnsrDelta,r'$\pm$',stdZsnsrDelta),
                **lineDict)
    pPlotUtil.lazyLabel(r'Z Sensor (nm)',r'$Z_{snsr}$ Error (nm)',"")
    # plot the standard deviation separately
    plt.suptitle("Approach curves shift over time",
                 fontsize=25) 
    fig.subplots_adjust(top=0.9)
    timeRange = maxV-minV
    colorRange = [0,timeRange]
    labels = ["Experiment\nStart","{:.1f} Hours".format(timeRange/(2*3600)),
              "{:.1f} hours".format(timeRange/3600)]
    pPlotUtil.addColorbar(fig,colormap,len(forces),denormFactor=colorRange,
                          tickLabels=labels)
    pPlotUtil.savefig(fig,"./out/ZSnsr.png",tight=False)

def getLabelledAndDetectedOffsets(mDataPath,mOutDir,
                                  limit=None,errorOnMissingFile=True,
                                  plotDuringAnalysis=False,
                                  forceDataGeneration=False):
    sqlObj = SqlUtil.InitSqlGetSessionAndClasses()
    mFiles = SqlUtil.GetSrcFiles(sqlObj)
    nFiles = len(mFiles)
    mGuesses = []
    mTrue = []
    mIds = []
    mAnalysisObjects = []
    for i in range(nFiles):
        # limit to one.
        if (limit is not None and (i == limit)):
            break
        mFileTmp = mDataPath + mFiles[i].FileTimSepFor + ".hdf"
        if not pGenUtil.isfile(mFileTmp):
            if errorOnMissingFile:
                raise IOError("Couldn't find file {:s}".format(mFileTmp))
            else:
                continue
        # POST: file exists
        mId = mFiles[i].idTraceData
        print(mFiles[i].FileTimSepFor)
        mCheckDir = mOutDir + "_" + str(mId) + "Data.pkl"
        mObj = pCheckUtil.getCheckpoint(mCheckDir,AnalyzeSingle,
                                        forceDataGeneration,
                                        sqlObj,mFiles[i],mDataPath,mId,
                                        mOutDir,plotDuringAnalysis)
        # save  the analysis objects, so we can look at them later.
        mAnalysisObjects.append(mObj)
        sep = mObj._sep
        sepLabelled = sep[mObj._mIndices._xyOff]
        sepAuto = sep[mObj._mRetract._idxSurface]
        # add the guesses and the true values of the separation
        mGuesses.append(sepAuto)
        mTrue.append(sepLabelled)
        mIds.append(mId)
        if (plotDuringAnalysis):
            PlotApproachNoise(mObj)
    plotAnalysisObjects(mAnalysisObjects)
    return mGuesses,mTrue,mIds

# plot a histogram of how well the surface detector did, compairing 
# mGuesses with mTrue. 
def plotErrorHistogram(mGuesses,mTrue,mIds,idsWithAdhesions):
    sepAuto = np.array(mGuesses)
    sepLabelled = np.array(mTrue)
    mIds = np.array(mIds)
    diffArr = sepAuto-sepLabelled
    # sort the ids by their magnitude of error
    lowestToHighestErrIdx = np.argsort(np.abs(diffArr))
    # hand-made a 'blacklist', ids of curves with adhesions
    properIdx = [i for i in range(len(mIds)) if mIds[i] not in idsWithAdhesions]
    sepAuto = sepAuto[properIdx]
    sepLabelled = sepLabelled[properIdx]
    diffArr = sepAuto-sepLabelled
    fig = pPlotUtil.figure()
    stepSize= 1 # nm
    ax = plt.subplot(1,1,1)
    binRange = np.arange(np.min(diffArr)-stepSize,np.max(diffArr)+stepSize,
                         stepSize)
    valsInBins,_,_ =plt.hist(diffArr,bins=binRange)
    mIndex = diffArr[np.where(np.abs(diffArr) < 10)]
    proportionIn10Nm = mIndex.size/diffArr.size
    limitsAbs = [0,max(valsInBins)]
    plt.ylim(limitsAbs)
    pPlotUtil.lazyLabel("Difference from label (nm)","Count",
                        "Histogram of Surface Detection Error \n" + 
                        "{:.0f}% within 10nm (1% of 650nm construct)".\
                        format(proportionIn10Nm*100))
    pPlotUtil.secondAxis(ax,"Proportion",limitsAbs/sum(valsInBins))
    pPlotUtil.savefig(fig,"./out/SurfaceDetectionError.pdf")

# right now, really can only run on patricks machine. switch...
def run(mDataPath=None,mOutDir=None,forceRun=True,**kwargs):
    if (mDataPath is None):
        # assume that the binary files live in the default directory
        mDataPath = SqlUtil.DefaultDataDir
    if (mOutDir is None):
        # output directory
        mOutDir = SqlUtil.DefaultWorkDir + "SurfaceDection/"
    # get all the files we need in the database
    pGenUtil.ensureDirExists(mOutDir)
    mGuesses,mTrue,mIds = \
        pCheckUtil.getCheckpoint(mOutDir+"DistSave.pkl",
                                 getLabelledAndDetectedOffsets,forceRun,
                                 forceDataGeneration=forceRun,
                                 mDataPath=mDataPath,
                                 mOutDir=mOutDir,
                                 **kwargs)
    idsWithAdhesions = [11,24,211,182,175,29,139,159,157,149,17,98,150]
    plotErrorHistogram(mGuesses,mTrue,mIds,idsWithAdhesions)

def runLocal(**kwargs):
    run(limit=25,forceRun=True,mOutDir="./out/",
        mDataPath="/Users/patrickheenan/Desktop/DnaBinariesTmp/",
        plotDuringAnalysis=False)

def runJila(**kwargs):
    run(**kwargs)

if __name__ == "__main__":
    runLocal()
