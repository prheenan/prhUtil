// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModSurfaceDetectorUtil
#include "::Util:StatUtil"
#include "::Util:Defines"
#include "::Util:FitUtil"
#include "::Util:PlotUtil"
#include "::Util:CypherUtil"

// By  default, smooth to Xs ((1/X)Hz) for surface detection (calculating derivatives)
Static Constant DEF_SMOOTH_TIMECONST = 0.03
Static Constant MIN_SURF_DWELL = 0.1 // a tenth of a second dwell is 'minimum', triggers using both sides of the curve. 

Structure SurfaceDetector
	// the indices before and after the max index where the median derivative 
	// was crossed. this is useful for debugging; the algorithm uses this to 
	// determine where it should fit a line for the invols
	double indexBefore
	double indexAfter
	double indexMax
	// The coefficients in fitting a line to [0,indexBefore] and [indexAfter,N] in the data
	double slopeBefore
	double interceptBefore
	double slopeAfter
	double interceptAfter
	// Based on the first/last intersection of the after/before lines (see above) with the data,
	// determines where it should calculate the invols
	double indexInvolsStart
	double indexInvolsEnd
	// The calculated invols, slope of V verus m (V/m <-> 1/Invols)
	//  and intercept (from the start/end above), in whatever Y/X was when you called the invols function
	double invols
	double oneOverInvols
	double involsIntercept
	// The index where the invols curve intersects the 'before' curve
	double surfaceIndexBefore
	// The index where the invols curve intersects the 'after' curve'
	double surfaceIndexAfter
	// *only* once we know if we are retract or approach, we can find the surface X/index
	uint32 surfaceKnown
	double surfaceIndex
	double surfaceX
EndStructure

// Given a time constant, gets the smoothing factor
Static Function GetNPointsForSmoothing(original,[timeConstant])
	Wave original
	// make sure we have the time constant and order we need
	Variable timeConstant
	timeConstant =  ParamIsDefault(timeConstant) ? DEF_SMOOTH_TIMECONST : timeConstant
	// From the time constant, we need to get the number of points to smooth to.
	// this must be an integer...
	Variable nPoints = ceil(timeConstant/DimDelta(Original,0))
	return nPoints
End Function 

// Original : a wave to smooth for surface detction (assuming time is the x axis)
// ToOutput : an already-allocated wave of the same size
// timeConstant : a time (same units as x of original ) to filter by. 
// order: what SG order to use
// we will output into
Static Function SurfaceSmooth(Original,ToOutput,[timeConstant])
	Wave Original
	Wave ToOutput
	Variable timeConstant
	Variable nPoints
	if (ParamIsDefault(timeConstant))
		nPoints=  GetNPointsForSmoothing(original)
	else
		nPoints=  GetNPointsForSmoothing(original,timeConstant=timeConstant)
	EndIf		
	// Ensure nPoints works for sabitsky golay
	// Number of smoothing points must be between the min and the max
	// duplicate the original wave, since smooth overrides.
	Duplicate /O original,toOutput
	ModFitUtil#SavitskySmooth(toOutput,nPoints=nPoints)
End Function

// Function takes in an (assumed smoothed) force or defl or delfV curve,
// assumes it has only one area of highest derivative (ie: approach/retract "invols")
// and gives the indices of the maximum derivative, and where the derivative
// was back to the median (within a small tolerance) before and after the max
Static Function GetSurfaceBoundingIndices(approachOrRetract,idxBefore,idxMax,idxAfter)
	Wave approachOrRetract
	Variable & idxBefore, &idxMax, &idxAfter
	Differentiate approachOrRetract /D=mDerivative
	// Take the absolute value; only looking for those differences
	MatrixOp /O mDerivative = abs(mDerivative)
	Variable nPoints = DimSize(mDerivative,0)
	// Get the median value
	Variable mMedianDeriv = StatsMedian(mDerivative)
	// Get the maximum index
	Struct WaveStat mStats
	ModStatUtil#GetWaveStats(mDerivative,mStats)
	idxMax = mStats.maxRowLoc
	// Get where the derivative first crosses median before max, searching backwards
	 idxBefore = ModStatUtil#FindIdxLevelCrossing(mDerivative,mMedianDeriv,0,idxMax-1,ModDefine#True())
	// Get where the derivative crosses median after max, searching forwards
	 idxAfter = ModStatUtil#FindIdxLevelCrossing(mDerivative,mMedianDeriv,idxMax+1,nPoints-1,ModDefine#False())
	// POST: all done , go ahead an kill the wave we made
	KillWaves /Z mDerivative
End Function

// If we dont have any points, we should throw and error here
// If we have one point, just use the single point as a mean (essentially, no dwell :-( )
Static Function SafeLinFit(mWave,xScale,slopeSet,interSet)
	Wave mWave,xScale
	Variable & slopeSet, &interSet
	Variable minNPoints
	Variable nPoints = DimSize(mWave,0)
	if (nPoints ==0)	
		// throw error; can't possibly fit
		ModErrorUtil#OutOfRangeError(description="Cant fit to a zero point wave.")
	elseif (nPoints == 1)
		slopeSet = 0
		interSet = mWave[0]
	else
		// at least two points; we can fit!
		ModFitUtil#LinearFit(mWave,slopeSet,interSet,mX=xScale)
	EndIF
End Function

// From a single approach or retract curve, gets the surface location and 'invols'
// ('invols' are in units of ApproachOrRetract/xScale, so only invols if V/m are the units). 
// Assumes: ApproachOrRetractSmooth has x units of time, and is smoothed/pre-processed
// so that derivatives can work on it. Also assumes it has at most *one* of retract/approach
// See: 'SurfaceSmooth' for smoothing and just cut a full wave in half 
// ApproachOrRetractRaw is the 'raw' version of smoothed, used for getting an invols
// without artifacts
// 'startIdx' is the relative start; at the end, we add this to any index we find 
Static Function GetSurfaceLocationAndInvols(ApproachOrRetractRaw,ApproachOrRetractSmooth,xScale,toRet,startIdx,isApproach)
	Wave ApproachOrRetractRaw,ApproachOrRetractSmooth,xScale
	Variable startIdx,isApproach
	Struct SurfaceDetector & toRet
	Variable idxBefore,idxMax,idxAfter
	// First, get the indices bounding the maximum (absolute) derivative change
	 ModSurfaceDetectorUtil#GetSurfaceBoundingIndices(ApproachOrRetractSmooth,idxBefore,idxMax,idxAfter)
	 // Next, fit lines to the before and after portions of the curves
	 Variable nPoints = DimSize(ApproachOrRetractSmooth,0)
	 // duplicate the 'before' defl curve and xscale
	 Duplicate /O /R=[0,idxBefore] ApproachOrRetractRaw,beforeCurve 
	 Duplicate /O /R=[0,idxBefore] xScale,xScaleBefore
	  // duplicate the 'after' defl curve and xscale
	 Duplicate /O /R=[idxAfter,nPoints] ApproachOrRetractRaw,afterCurve 
	 Duplicate /O /R=[idxAfter,nPoints] xScale,xScaleAfter 
	 // Get the slopes and intercepts using a linear fit to the two regions
	Variable slopeBefore,interceptBefore,slopeAfter,interceptAfter
	// Get the fit coefficients on the before and after curves
	SafeLinFit(beforeCurve,xScaleBefore,slopeBefore,interceptBefore)
	SafeLinFit(afterCurve,xScaleAfter,slopeAfter,interceptAfter)
	 // Get the asbolute difference between the predicted value and the real curve
	 // XXX Duplicating the entire wave is certainly overkill; would likely be better to just take up to the max, make it ~2x efficient this part
	 Duplicate /O ApproachOrRetractRaw,diffBefore
	 Duplicate /O ApproachOrRetractRaw,diffAfter
	 // the special index 'y' stores the y value; we can easily use this to get the diffference 
	 // (same logic with x)
	 diffBefore[] -= slopeBefore*xScale[p]+interceptBefore
	 diffAfter[]   -= slopeAfter*xScale[p]+interceptAfter
	// need to determien where to fit invols based on if this is approach or retract.
	Variable idxStartInvols 
	Variable idxEndInvols 
	if (isApproach)
		// then we fit between the maximum derivative and where 'diffafter' line intersects the data
		idxStartInvols=idxMax
		idxEndInvols= ModStatUtil#FindIdxLevelCrossing(diffAfter,0,idxMax,Inf,ModDefine#False())
	else
		// then we fit between where 'diffbefore' intersects  the data and the maximum derivative
		idxStartInvols = ModStatUtil#FindIdxLevelCrossing(diffBefore,0,0,Inf,ModDefine#True())
		idxEndInvols=idxMax
	EndIF
	// Fit the invols between the bounds
	Duplicate /O /R=[idxStartInvols,idxEndInvols] ApproachOrRetractRaw,mInvolsCurve
	Duplicate /O /R=[idxStartInvols,idxEndInvols] xScale, mInvolsXScale
	// fit for the real invols, noting that the slope here is V/m, so invols = m/V = 1/slope. 
	Variable oneOverInvols,realInvolIntercept
	ModFitUtil#LinearFit(mInvolsCurve,oneOverInvols,realInvolIntercept,mX=mInvolsXScale)
	// Determine where (x value, *not* index, converted below) 
	// the invols intersects with the before/after curves (should be close to indexInvolsStart/End)
	Variable intersectBefore = ModFitUtil#LineIntersect(oneOverInvols,realInvolIntercept,slopeBefore,interceptBefore)
	Variable intersectAfter = ModFitUtil#LineIntersect(oneOverInvols,realInvolIntercept,slopeAfter,interceptAfter)
	// convert the x values  to index 
	// Find where the x scale first crosses the intersection before and after the invols curve 
	Variable intersectBeforeIndex = ModStatUtil#FindIdxLevelCrossing(xScale,intersectBefore,0,idxStartInvols,ModDefine#False())
	Variable intersectAfterIndex = ModStatUtil#FindIdxLevelCrossing(xScale,intersectAfter,idxStartInvols,Inf,ModDefine#False())
	// Assign the values we calculated to the results object.
	 // the indices before and after the max, where 'before' and 'after' means earlier or later indices crossing the median
	 toRet.indexBefore = idxBefore + startIdx
	 toRet.indexAfter = idxAfter + startIdx
	 toRet.indexmax = idxMax + startIdx
	// The coefficients in fitting a line to [0,indexBefore] and [indexAfter,N] in the data
	 toRet.slopeBefore = slopeBefore
	 toRet.interceptBefore = interceptBefore
	 toRet.slopeAfter = slopeAfter 
	 toRet.interceptAfter = interceptAfter
	 // The bounds for where we calculated the invols
	 toRet.indexInvolsStart = idxStartInvols + startIdx
	 toRet.indexInvolsEnd = idxEndInvols + startIdx
	 // Save the invols
	 toRet.invols = 1/oneOverInvols
	 toRet.oneOverInvols = oneOverInvols  //one over the slope is the invols
	 toRet.involsIntercept = realInvolIntercept
	 // The index where the invols curve intersects the 'before' curve
	 toRet.surfaceIndexBefore = intersectBeforeIndex+ startIdx
	 // The index where the invols curve intersects the 'after' curve'
	toRet.surfaceIndexAfter =intersectAfterIndex + startIdx
	KillWaves /Z  fitCoeffsBefore,fitCoeffsAfter,beforeCurve,afterCurve,diffBefore,diffAfter
End Function

// Get the halfway point, using the dwell times and velocities as a guide (the
// wave must have the cyphers notes )
Static Function GetHalfThroughDwellIdx(notedWave)
	Wave notedWave
	// Get some meta information
	Variable dwellAbove =  ModCypherUtil#GetDwellAbove(notedWave)
	Variable dwellSurface =  ModCypherUtil#GetDwellSurface(notedWave)
	Variable approachVel =  ModCypherUtil#GetApproachVel(notedWave)
	Variable startDist = ModCypherUtil#GetStartDist(notedWave)
	Variable forceDist = ModCypherUtil#GetForceDist(notedWave)
	Variable dwellSetting = ModCypherUtil#GetDwellSetting(notedWave)
	Variable timeToHalf 
	// get the 'effective end time', correcting for dwells after data collection
	Variable effectiveEndTime  = rightx(notedWave)
	if (ModCypherUtil#HasEndDwell(dwellSetting))
		// then we are using a dwell above; go ahead and subtract it off
		effectiveEndTime -= dwellAbove
	EndIF
	timeToHalf =  effectiveEndTime/2
	// Get this in an index, normalized to whatever zsnsr has
	Variable timeDelta = deltax(notedWave)
	Variable timeOffset = leftx(notedWave)
	// get the index, starting from whatever means zero to the half time
	Variable mIndex = ceil((timeToHalf-timeOffset)/timeDelta)
	return mIndex
End Function	

// Uses 'Zsnsr" and "deflV" to get either the approch (much better) or retraction invols (pass by reference)
// and surface location. also records all the information it finds for debugging in 'myDetectionObj'
Static Function GetInvols(zsnsr,deflV,invols,surfaceX,myDetectionObj,isApproach)
	Wave zsnsr,deflV
	Variable &invols, &surfaceX
	Variable isApproach
	Struct SurfaceDetector & myDetectionObj
	// Get a smoothed version of the RawForce
	Duplicate /O deflV,SgFiltered
	ModSurfaceDetectorUtil#SurfaceSmooth(deflV,SgFiltered)
	// Get just the approach/retract porton of the smoothed vector, depending on what we were  told
	Variable nPoints = DimSize(Zsnsr,0)
	Variable halfPoint = GetHalfThroughDwellIdx(deflV)
	Variable StartPoint
	Variable EndPoint
	if (isApproach)	
		// first half of the curve is approach
		StartPoint = 0
		EndPoint = halfPoint
	else
		// second half of the curve is retract
		StartPoint = halfPoint
		EndPoint = Inf
	EndIf
	Duplicate /O /R=[startPoint,EndPoint] zsnsr,rangedX
	Duplicate /O /R=[startPoint,EndPoint] SgFiltered,smoothed
	Duplicate /O /R=[StartPoint,EndPoint] deflV,rangedY
	// POST: have the approach curve (smoothed and unsmoothed!)
	// Get the surface detetion object using Zsnsr for the X, DeflV
	ModSurfaceDetectorUtil#GetSurfaceLocationAndInvols(rangedY,smoothed,rangedX,myDetectionObj,startPoint,isApproach)
	// set the invols and x location
	invols = myDetectionObj.invols
	// Find the surface index based on if this is approach or retract
	// 'before'/'after' refers to before to after the invols curve. for approach, the surface is right before,
	// for retract, the surface is right after (since during, we are pressing into the surface) 
	Variable idxBefore = myDetectionObj.surfaceIndexBefore
	Variable idxAfter = myDetectionObj.surfaceIndexAfter 
	// Get the surface index.
	Variable surfaceIdx = isApproach ?  idxBefore :  idxAfter
	surfaceX = zsnsr[surfaceIdx]
	// POST: set up the surface properties, so the object matches what we pass
	myDetectionObj.surfaceIndex = surfaceIdx
	myDetectionObj.surfaceX = surfaceX
	myDetectionObj.surfaceKnown = ModDefine#True()
	KillWaves /Z SgFiltered
End Function

// See GetInvols above
Static Function GetApproachInvols(zsnsr,deflV,invols,surfaceX,[debugStruct])
	Wave zsnsr,deflV
	Variable &invols, &surfaceX
	// if we need to, set the reference of the struct passed in 
	Struct SurfaceDetector & debugStruct
	Struct SurfaceDetector myDetectionObj
	GetInvols(zsnsr,deflV,invols,surfaceX,myDetectionObj,ModDefine#True())
	if (!ParamIsDefault(debugStruct))
		debugStruct = myDetectionObj
	EndIf
End Function

// See getInvols above
Static Function GetRetractInvols(zsnsr,deflV,invols,surfaceX,[debugStruct])
	Wave zsnsr,deflV
	Variable &invols, &surfaceX
	// if we need to, set the reference of the struct passed in 
	Struct SurfaceDetector & debugStruct
	Struct SurfaceDetector myDetectionObj
	GetInvols(zsnsr,deflV,invols,surfaceX,myDetectionObj,ModDefine#False())
	if (!ParamIsDefault(debugStruct))
		debugStruct = myDetectionObj
	EndIf
End Function

// Given an in and out wave, scales everything
//scales and zeroes the waves according to 'indexSurface'
Static Function GetScaledWave(inX,outX,inY,outY,idxSurf)
	Wave InX,outX,inY,outY
	Variable idxSurf
	Variable startIdx,endIdx,getBefore
	// First, zero everything. probably more efficient ways to do this, but it works. 
	Duplicate /O /R=[0,Inf ] inX, xZeroed
	Duplicate /O /R=[0,Inf] inY, yZeroed
	// we are given the x location of the surface
	// Get the zero points, recalculated based on the last index 
	Variable mZeroX = inX[idxSurf]
	// *only* scale the x (there is a y offset between approach and retract )
	xZeroed[] = xZeroed[p] - mZeroX
	// Reverse the y axis
	yZeroed[] *= -1
	Duplicate /O xZeroed, outX
	Duplicate /O yZeroed, outY
	// Kill the temporary Waves
	KillWaves /Z xZeroed,yZeroed
End Function

Static Function Main()

End Function