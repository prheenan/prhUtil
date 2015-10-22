#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include ":PreProcess"
#pragma ModuleName = ModPreProcessWiggles

// Interpolate2 Constant 
Static Constant INTERPOLATE2_TYPE_LINEAR = 1

Static Function InterpAtI(mProc,index)
	Struct ProcessStruct & mProc
	Variable index
	Wave /T mLowResXWaves = $(mProc.XLowRes)
	Wave /T mHighResXWaves = $(mProc.XHighRes)
	Wave /T mHighResYWaves = $(mProc.YHighRes)
	Wave mLowResX = $(mLowResXWaves[index])
	Wave mHighResX = $(mHighResXWaves[index])
	Wave mHighResY = $(mHighResYWaves[index])
	// Interpolate the low resolution X into the high resolution X, using the x values from mHighResY 
	InterpolateSingleWave(mLowResX,mHighResY,mHighResX)
End Function

Static Function InterpolateSingleWave(lowResRef,highResRef,outputRef)
	Wave lowResRef,highResRef,outputRef
	// Using the x of highResRef, interpolate lowResRef, putting the results in outputRef
	Variable nInterp, deltaHighRes, t0HighRes
	// Get the parameters needed for interpolation		
	nInterp = DImSize(highResRef,0)
	deltaHighRes = DimDelta(highResRef,0)
	t0HighRes = DimOffset(highResRef,0)
	String mUnits = ModIoUtil#GetXUnits(highResRef)
	// Set the X scaling of the output wave explicitly
	// /P: first number is offset, second number is delta
	SetScale /P x,t0HighRes,deltaHighRes,mUnits,outputRef
	// Redimension to the size we need.
	Redimension /N=(nInterp) outputRef
	// See: "Interpolate Help.ihf"
	// (go to Analysis --> Interpolate --> Help) 
	// Note: as shown in 'Smoothing Spline Parameters' in the help file,
	//  if an wave is not specified, then
	// " the points at which the interpolation is done are determined by the destination of the interpolation."
	// In other words, the y coordinates set the inteperpolation
	// Y: name of destination wave
	// T: type (linear, cubic spline, smoothing spline)
	// N: number of points
	Interpolate2 /Y=outputRef/N=(nInterp) /T=(INTERPOLATE2_TYPE_LINEAR) lowResRef
End Function

Function ModPreProcessWigglesInterp(mProc) 
	// Interpolates the low-bandwidth X and Y to the same resolution as the high bandwith.
	// *must* be called before conert, if using the standard conversion function
	Struct ProcessStruct & mProc
	Variable i
	// Assume that we count low resolution X 
	// (ie: same as Y low Res)
	// XXX check this?
	// Also assume that the ihgh resolution Y carries the X incformation we care about. 
	Variable nWaves = DimSize($mProc.XLowRes,0)
	for ( i=0; i<nWaves; i+=1)
		InterpAtI(mProc,i)
	EndFor
End Function

Static Function OffsetX(WaveToOffset,AmountOffset)
	// The x values of WaveToOffset are shifted to the right by 'amountoffset'
	String WaveToOffset
	Variable AmountOffset
	Wave mWave = $WaveToOffset
	Variable t0 = DimOffset(mWave,0)
	Variable deltaT = DimDelta(mWave,0)
	String mScale = MOdIoUtil#GetXUnits(mWave)
	SetScale /P x,(t0-AmountOffset),deltaT,mWave
End Function

 Function ModPreProcessWigglesOffsetX(mProc,mParamObj,Index) 
        Struct ProcessStruct & mProc
        Struct ParamObj & mParamObj
       Variable Index
       // Get the (default) pre-processing times
       Variable t0Slow, t0Fast, tfSlow, tfFast
       GetDefaultPreProc(mParamObj,t0Slow,t0Fast,tfSlow,tfFast)
       // Get the average offset we want. This helps be more accurate.
       Variable averageOffset = 0.5 * ( t0Slow-t0Fast + tfSlow-tfFast)
       // Offset the high-resolution X by this offset (ie: since we assume
       // the high resolution X) is interpolated by default, align to high res
       Wave /T highRes = $(mProc.XHighRes)
       OffsetX(highRes[index],averageOffset)
 End Function

Static Function GetDefaultPreProc(mParamObj,t0Slow,t0Fast,tfSlow,tfFast)
	Struct ParamObj & mParamObj	
	Variable & t0Slow, &t0Fast, &tfSlow, &tfFast
	// By Default, we assume the following indices in the parameters
	Variable idxSlowt0 = 0
	Variable idxFast0 = 1
	Variable idxSlowtf = 2
	Variable idxFasttf = 3
	// Get the times we are interested in
	// // Get the initial (touchoff/approach) parameters
	t0Slow = mParamObj.params[idxSlowt0].NumericValue
	t0Fast = mParamObj.params[idxFast0].NumericValue
	// Get the final (leave/retract)parameters
	tfSlow = mParamObj.params[idxSlowtf].NumericValue
	tfFast = mParamObj.params[idxFasttf].NumericValue
End Function


Static Function Correct(ForceWaveToFit,ForceWaveToCorrect,touchIdxInitialFit,touchIdxFinalCorrect)
	// fits the waves from 0 to touchoffinitial (reversed), then subtracts the result from touchofffinal
	Wave ForceWaveToFit,ForceWaveToCorrect
	Variable touchIdxInitialFit,touchIdxFinalCorrect
	// Get just the first touchoff part
	Duplicate /O/R=[0,touchIdxInitialFit] ForceWaveToFit mToFit
	// Reverse it, so we can immediately apply the results
	// This is because we assume the approach and retraction 
	// are symmetric about the y axis, with the exception of the molecule
	Reverse /P mToFit
	Make /O/N=0 mCoeff 
	ModFitUtil#CreatePolyCoeffs(mToFit,mCoeff)
	Variable fitN = DImSIze(mToFit,0)
	// Get the maximum 'delta' times, for fitting
	Variable tfCorrect =  pnt2x(ForceWaveToCorrect,touchIdxFinalCorrect)
	Variable finalFitTime = ModIOUtil#GetMaxX(mToFit)
	Variable finalCorrectTime = ModIOUtil#GetMaxX(ForceWaveToCorrect) - tfCorrect
	Variable maxFitTime = min(finalFitTime,finalCorrectTime) + tfCorrect
	Variable maxFitIdx = x2pnt(ForceWaveToCorrect,maxFitTime)-1
	ForceWaveToCorrect[touchIdxFinalCorrect,maxFitIdx] = ForceWaveToCorrect[p] - poly(mCoeff,x-tfCorrect)
	// POSt: we have all the cofficients we need.
	KillWaves /Z mCoeff,mToFIt
End Function

Function ModPreProcessWiggleCorrect(mProc,mParamObj,Index)
	Struct ProcessStruct & mProc
	Struct ParamObj & mParamObj	
	Variable Index
	// Correct the high-resolution force using the (converted to force) low resolution Y
	Wave /T mYWavesToFit = $(mProc.YLowRes)
	Wave /T mYWaveHIgh = $(mProc.Force)
	// Convert the Y, whatever it is, into force for fitting.
	// XXX check that Y isn't force?
	Wave yToFit = $(mYWavesToFit[index])
	Make /O/N=(DimSize(yToFit,0)) ForceWaveToFit
	ModCypherUtil#GetForceInferType(yToFit,ForceWaveToFit)
	Wave ForceWaveToCorrect= $(mYWaveHIgh[index])
	// get the times
	Variable t0Slow, t0Fast, tfSlow, tfFast
	GetDefaultPreProc(mParamObj,t0Slow,t0Fast,tfSlow,tfFast)
	// Get the indices
	Variable idxInitFit = x2pnt(ForceWaveToFit,t0Slow)
	Variable idxFinalCorrect= x2pnt(ForceWaveToCorrect,tfFast)
	// Correct the high-resolution wave, based on the low resolution one.
	Correct(ForceWaveToFit,ForceWaveToCorrect,idxInitFit,idxFinalCorrect)
	KillWaves /Z tmpForceCorrect
End Function
