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

class WLC_DEF:
    L0 = 650e-9 # meters
    Lp = 50e-9 # meters
    K0 = 1200e-12 # Newtons
    kbT = 4.1e-21 # 4.1 pN * nm = 4.1e-21 N*m
    
#"Estimating the Persistence Length of a Worm-Like Chain Molecule from Force-Extension Measurements"
# C. Bouchiat, M.D. Wang, J.-F. Allemand, T. Strick, S.M. Block, V. Croquette
# Biophysical Journal Volume 76, Issue 1, January 1999, Pages 409-413
def WlcPolyCorrect(kbT,Lp,l):
    # kbT is the thermal energy in units of [ForceOutput]/Lp
    # Lp is the persisence length, sensible units of length
    # l is either extension/Contour=z/L0 Length (inextensible) or 
    # z/L0 - F/K0, where f is the force and K0 is the bulk modulus 
    a0=0 
    a1=0
    a2=-.5164228
    a3=-2.737418
    a4=16.07497
    a5=-38.87607
    a6=39.49949
    a7=-14.17718
    #http://docs.scipy.org/doc/numpy/reference/generated/numpy.polyval.html
    #If p is of length N, this function returns the value:a
    # p[0]*x**(N-1) + p[1]*x**(N-2) + ... + p[N-2]*x + p[N-1]
    # note: a0 and a1 are zero, including them for easy of use of polyval.
    polyValCoeffs = [a7,a6,a5,a4,a3,a2,a1,a0]
    inner = 1/(4*(1-l)**2) -1/4 + l + np.polyval(polyValCoeffs,l)
    return kbT/Lp * inner

def WlcNonExtensible(kbT,L0,Lp,ext):
    # see WlcPolyCorrect for params, except
    # L0: contour length, same units as ext
    # ext: extension, same units as L0
    return WlcPolyCorrect(kbT,Lp,ext/L0)

def WlcExtensible(kbT,L0,Lp,ext,K0,Force):
    # see  Wang et al. (1997), extensible WLC
    thisArg = ext/L0-Force/K0
    return WlcPolyCorrect(kbT,Lp,thisArg)

def FitWlc(extRef,forceRef,kbT=None,Lp=None,L0=None,fitL0=True,fitLp=True,
           K0=None,extensible=False,offsetIdx=None):
    if (L0 == None):
        L0 = WLC_DEF.L0
    if (Lp == None):
        Lp = WLC_DEF.Lp
    if (kbT==None):
        kbT= WLC_DEF.kbT
    if (K0 == None):
        K0 = WLC_DEF.K0
    # POST: all parameters are filled out 
    # determine what we are fitting
    p0 = [L0]
    if (fitLp):
        p0.append(Lp)
    # POST: guesses have been made
    # add in the offset if we need if
    if (offsetIdx is not None):
        # then offset the force and extension to this location
        # make local *value* copies of the force and ext, since we offset
        force = np.copy(forceRef)
        ext = np.copy(extRef)
        force -= force[offsetIdx]
        ext -= ext[offsetIdx]
    else:
        # not changing the force or extension; OK to use a reference.
        force = forceRef
        ext = extRef
    # determine what our fit function is
    if (extensible):
        # determine what the function signature is 
        if (fitLp):
            mFunc = lambda x,L0,Lp:  WlcExtensible(kbT,L0,Lp,x,K0,force)
        else:
            mFunc = lambda x,L0   :  WlcExtensible(kbT,L0,Lp,x,K0,force)
    else:
        # determine what the function signature is 
        if (fitLp):
            mFunc = lambda x,L0,Lp:  WlcNonExtensible(kbT,L0,Lp,x)
        else:
            mFunc = lambda x,L0   :  WlcNonExtensible(kbT,L0,Lp,x)
    # POST: mfunc has a function we can used to call whatever we want
    # note: we use p0 as the initial guess for the parameter values
    params,paramsStd,predicted = pGenUtil.GenFit(ext,force,mFunc,p0=p0,
                                                 maxfev=2000)
    # first parameter is L0; adjust by offset
    if (offsetIdx is not None):
        params[0] += extRef[offsetIdx]
        predicted += forceRef[offsetIdx]
    # return all the relevant information
    return params,paramsStd,predicted
        

# fits sep and force between idxStart[i] and idxEnd[i], defined relative
# to force and sep
# for i=0 to 2, inclusive (ie: first WLC, ostretch, third WLC)
# returns the parameters, x used, y used, deltaL0, and overstretch
# note that parameters[i] is the slope and intercept associated with fit i
# x and y are defined simiarly, deltaL0 and overstretch are just scalars
def GetOStretchByIndices(sep,force,idxStart,idxEnd):
    mParams = []
    mPredictedX = []
    mPredictedY = []
    # make (linear fits for each)
    for realIdxInit,realIdxFinal in zip(idxStart,idxEnd):
        toFitX = sep[realIdxInit:realIdxFinal]
        toFitY = force[realIdxInit:realIdxFinal]
        # get the parameters
        params,_,predictedOStretch = pGenUtil.GenFit(toFitX,toFitY)
        # add the values we need...
        mParams.append(params)
        mPredictedX.append(toFitX)
        mPredictedY.append(predictedOStretch)
    # POST: all parameters calculared
    # need to get the start of the delta L0
    L0Init = pGenUtil.lineIntersectParam(mParams[0],mParams[1])
    # get the end of the final
    L0Final = pGenUtil.lineIntersectParam(mParams[1],mParams[2])
    approxDelL0 = L0Final-L0Init
    # get the midpoint, to find the overstretching force
    midPoint = L0Init + 0.5 * approxDelL0
    # get the index of the midpoint
    idxBetween = np.argmin(np.abs(sep-midPoint))
    # if for some reason the data is very noisy, just
    # use the mean index of the transition (index 2)
    # to get the indices...
    indexOStretch = 1
    if (idxBetween < idxStart[indexOStretch]):
        startTx = idxStart[indexOStretch]
        endTx = idxEnd[indexOStretch]
        idxBetween = np.mean([startTx,endTx])
    whereOStretch = sep[idxBetween]
    oStretchForce = np.polyval(mParams[1],whereOStretch)
    return mParams,mPredictedX,mPredictedY,whereOStretch,oStretchForce












