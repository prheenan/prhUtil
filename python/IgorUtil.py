# force floating point division. Can still use integer with //
from __future__ import division
# This file is used for importing the common utilities classes.
import numpy as np
import matplotlib.pyplot as plt
# import the patrick-specific utilities
import GenUtilities  as pGenUtil
import PlotUtilities as pPlotUtil
import CheckpointUtilities as pCheckUtil
from scipy.signal import savgol_filter
DEF_FILTER_CONST = 0.005 # 0.5%

def DemoDir():
    '''
    :return: the absolute path to the demo directory
    ''' 
    return "/Volumes/group/4Patrick/DemoData/IgorDemos/"

# read a txt or similarly formatted file
def readIgorWave(mFile,skip_header=3,skip_footer=1,comments="X "):
    data = np.genfromtxt(mFile,comments=comments,skip_header=skip_header,
                         skip_footer=skip_footer)
    return data


def savitskyFilter(inData,nSmooth = None,degree=2):
    if (nSmooth is None):
        nSmooth = int(len(inData)/200)
    # POST: have an nSmooth
    if (nSmooth % 2 == 0):
        # must be odd
        nSmooth += 1
    # get the filtered version of the data
    return savgol_filter(inData,nSmooth,degree)

# plot a force extension curve with approach and retract
def PlotFec(sep,force,surfIdx = None,normalizeSep=True,normalizeFor=True,
            filterN=None):
    """
    Plot a force extension curve

    :param sep: The separation in meters
    :param force: The force in meters
    :param surfIdx: The index between approach and retract. if not present, 
    intuits approximate index from minmmum Sep
    :param normalizeSep: If true, then zeros sep to its minimum 
    :paran normalizeFor: If true, then zeros force to the median-filtered last
    5% of data, by separation (presummably, already detached) 
    :param filterT: Plots the raw data in grey, and filters 
    the force to the Number of points given. If none, assumes default % of curve
    """
    sepNm = sep * 1e9
    forcePn = force * 1e12
    if (surfIdx is None):
        surfIdx = np.argmin(sep)
    if (filterN is None):
        filterN = int(np.ceil(DEF_FILTER_CONST*sepNm.size))
    forcePnFilt = savitskyFilter(forcePn,filterN)
    if (normalizeSep):
        sepNm -= sepNm[surfIdx]
    if (normalizeFor):
        # reverse: sort low to high
        sortIdx = np.argsort(sep)[::-1]
        # get the percentage of points we want
        percent = 0.05
        nPoints = int(percent*sortIdx.size)
        idxForMedian = sortIdx[:nPoints]
        # get the median force at these indices
        forceMedPn = np.median(forcePn[idxForMedian])
        # correct the force
        forcePn -= forceMedPn
        forcePnFilt -= forceMedPn
    # POST: go ahead and normalize/color
    sepAppr = sepNm[:surfIdx]
    forceAppr = forcePnFilt[:surfIdx]
    sepRetr = sepNm[surfIdx:]
    forceRetr = forcePnFilt[surfIdx:]
    linewidthFilt = 3.0
    plt.plot(sepAppr,forceAppr,color="r",lw=linewidthFilt,label="Approach")
    plt.plot(sepRetr,forceRetr,color="b",lw=linewidthFilt,label="Retract")
    # plot the raw data as grey
    plt.plot(sepNm,forcePn,color='k',alpha=0.3)
    pPlotUtil.lazyLabel("Separation [nm]","Force [pN]","Force Extension Curve")
