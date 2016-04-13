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
sys.path.append("../../PyUtil")
sys.path.append("../../PyWlc")
sys.path.append("../../SqlModels/PySurfDetec")
import HDF5Util,SqlUtil,SurfaceModel,IgorUtil
from mpl_toolkits.mplot3d import Axes3D


def getFilesAndMeta():
    # start up the sql link, get the objects
    sqlObj = SqlUtil.InitSqlGetSessionAndClasses()
    mFiles = SqlUtil.GetSrcFiles(sqlObj,ModelName="SurfDetect")
    # get their meta information
    MyMeta = [SurfaceModel.GetSurfParams(sqlObj,f) for f in mFiles]
    mFileNames = [f.FileTimSepFor for f in mFiles]
    return MyMeta,mFileNames

def plotSpotDist(mLabels,spots,outPath,subtractMean):
    colors = ['r', 'g', 'b', 'y','k']
    nColors = len(colors)
    # go to nm
    mLabelsNm = mLabels *  1e9
    mSetSpots = sorted(set(spots))
    labelsBySpot = []
    rawBySpot = []
    flattenedFromMean = []
    # first, get the spot-wise labelling
    for i,spot in enumerate(mSetSpots):
        # get the indices of the spots
        spotIdx = np.where(abs((spots - spot)) < 1e-9)[0]
        thisSpotLabels = mLabelsNm[spotIdx]
        meanV = np.mean(thisSpotLabels)
        if (subtractMean):
            thisSpotLabels -= meanV
        labelsBySpot.append(thisSpotLabels)
        flattenedFromMean.extend(thisSpotLabels)
        if (subtractMean):
            rawBySpot.append(thisSpotLabels + meanV)
        else:
            rawBySpot.append(thisSpotLabels)        
    #  get the min and max from the labelsBySpot array
    bins = np.linspace(min(flattenedFromMean),max(flattenedFromMean),10)
    fig = pPlotUtil.figure(xSize=12,ySize=12)
    ax = fig.add_subplot(111, projection='3d',)
    for i,thisSpotLabels in enumerate(labelsBySpot):
        mColor = colors[i % nColors]
        height,left = np.histogram(thisSpotLabels,bins=bins)
        ax.bar(left[:-1], height, zs=i,zdir='y', color=mColor, alpha=0.7,
               edgecolor="none",linewidth=0)
    xStr = r'$\Delta$ from Expected Surface Loc. [nm]'
    pPlotUtil.lazyLabel(xStr,
                        "Surface Position (arb)",
                    "Dependence of Surface Location Distribution on Position",
                        zlab="Count")
    pPlotUtil.savefig(fig,outPath + "AllSpots.png")
    # get a figure showing the mean surface location, assuming
    # we reshape into an Nx(whatever) array
    N = 5
    # -1: infer dimension
    meanVals = [np.mean(mList) for mList in rawBySpot]
    meanSurf = np.reshape(meanVals,(-1,N))
    meanSurf -= np.min(meanSurf)
    fig = pPlotUtil.figure(ySize=14,xSize=10)
    ax = fig.add_subplot(111, projection='3d')
    # convert to nm (XXX assuming grid is 1micron for each)
    Nx = N
    Ny = meanSurf.shape[0]
    x = np.linspace(0, Nx, Nx) * 1e3
    y = np.linspace(0, Ny, Ny) * 1e3
    xv, yv = np.meshgrid(x, y)
    ax.plot_wireframe(xv,yv,meanSurf)
    pPlotUtil.lazyLabel("X Location [nm]","Y Location [nm]",
                        "Surface Position Varies with height")
    pPlotUtil.zlabel("Surface height (relative to min)")
    pPlotUtil.savefig(fig,outPath + "Surface.png")
    fig = pPlotUtil.figure(ySize=14,xSize=10)
    plt.subplot(2,1,1)
    nPoints = len(flattenedFromMean)
    vals,edges,_=plt.hist(flattenedFromMean,bins=bins)
    # add a 'fudge' factor to make plotting better,
    fudgeX = (max(edges)-min(edges))*0.05
    xlim = [min(edges)-fudgeX,max(edges)+fudgeX]
    yLim = [0,max(vals)]
    pPlotUtil.lazyLabel(xStr,
                        "Number of counts",
                        "Algorithm finds surface within 10nm, >98%, N={:d}".\
                        format(nPoints))
    normed = [0,max(vals)/sum(vals)]
    plt.xlim(xlim)
    propAx = pPlotUtil.secondAxis(plt.gca(),"Proportion",normed,yColor="Red")
    propAx.axhline("0.05",color='r',
                   label="5% of Curves",linestyle='--',linewidth=4.0)
    pPlotUtil.legend()
    # plot the CDF 
    plt.subplot(2,1,2)
    # add a zero at the start, so the plot matches the PDF
    cdf = np.zeros(edges.size)
    cdf[1:] = np.cumsum(vals/sum(vals))
    mX = edges
    plt.plot(mX,cdf,linestyle='--',linewidth=4,color='k')
    plt.xlim(xlim)
    pPlotUtil.lazyLabel(xStr,
                        "Cummulative Proportion",
                        ("Cummulative Density Function," +
                         "Surface Detection Performance"))
    plt.gca().fill_between(mX, 0, cdf,alpha=0.3)
    pPlotUtil.savefig(fig,outPath + "FlatSpots.png")

def plotFec(expect,algorithm,inFile,saveAs):
    time,sep,force = HDF5Util.GetTimeSepForce(inFile)
    fig = pPlotUtil.figure()
    IgorUtil.PlotFec(sep,force)
    # limit the axis to close to the touchoff (10% of range)
    # (plotFEC starts at 0)
    minV = min(sep)
    rangeSepNm = 1e9 * abs(max(sep)-minV)
    rangeX = [0,rangeSepNm/10]
    plt.xlim(rangeX)
    # plot the expected and algorithm locations as nm, normalized to min
    norm  = lambda x : (x-minV)*1e9
    plt.axvline(norm(expect),
                label="Expected surface location",lw=3,linestyle="--",
                color="g")
    plt.axvline(norm(algorithm),label="Algorithm surface location",lw=3,
                linestyle="--",color="k")
    pPlotUtil.legend()
    pPlotUtil.savefig(fig,saveAs)

# reads in Detected labels (assumed to be in same order as database)
# and compares them to the hand-labelled data
# to use: make sure we have access to database, then probive offlinelabels
# (this can be obained by running 
# 'Demos/SurfaceDetection/SurfaceDetectorDistribution.ipf')
def run(offlineLabelsPath,outDir,datDir):
    # get the meta information associated with the file names from mySql
    meta,files = pCheckUtil.getCheckpoint(outDir + "meta.pkl",getFilesAndMeta,
                                          False)
    # read in all the labels
    mLabels = IgorUtil.readIgorWave(offlineLabelsPath)
    # get the expected labels
    expected = np.array([obj._xyOffSep for obj in meta])
    # get the spots 
    spots = np.array([obj._mMeta.Spot for obj in meta])
    # output path 
    plotSpotDist(expected,spots,outDir + "Manual",subtractMean=True)
    # get the number to compare...
    nCompare = min(len(expected),len(mLabels))
    expected = expected[:nCompare]
    mLabels = mLabels[:nCompare]
    # get the difference (in m)
    diff = mLabels-expected
    # get just the spots we care about
    spots = spots[:nCompare]
    # plot the differences!
    plotSpotDist(diff,spots,outDir + "Auto",subtractMean=False)
    # get the 'worst case' offenders, save them to their own figures
    cutoff = 10e-9 
    worstOffenders = np.where(np.abs(diff)  > cutoff)[0]
    for i in worstOffenders:
        handlLabeldLoc = expected[i]
        algorithmLoc = mLabels[i]
        plotFec(handlLabeldLoc,algorithmLoc,
                datDir + files[i],saveAs=outDir + files[i] + ".png")

if __name__ == "__main__":
    mDemo = IgorUtil.DemoDir() + "SurfaceDetectorDistributionDemo/"    
    datDir= mDemo + "Input/"
    offlineLabelsPath= datDir + "DetectedLabels.itx"
    outDir =mDemo + "Output/Python/"
    run(offlineLabelsPath,outDir,datDir)
