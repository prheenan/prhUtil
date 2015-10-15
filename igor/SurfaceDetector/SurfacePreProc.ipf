// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#include ":SurfaceDetectorUtil"
#include ":SurfaceDefines"
#pragma ModuleName = ModSurfacePreProc
// Module used to pre-process data before using the surface detector method
// (e.g., removing interference artifacts / "wiggles")

Structure SurfacePreProcInfo
	double fitIdxAppr
	Wave mCoeffs
	// only have a fit index for retract if we used the option to fit the retract
	double fitIdxRetr
	uint32 hasFitIdxRetr
EndStructure

// Corrects "mDeflV", storing the results in "mDeflVCorrected". Optional smoothing points and boolean
//. Preproc struct is for debugging. Zsnsr is recquired for correcting the retraction based on the approach
Static Function ArtifactCorrect(Zsnsr,mDeflV,mDeflVCorrected,mCoeffs,opt,[preProc])
	Wave Zsnsr,mDeflV,mDeflVCorrected,mCoeffs
	Struct SurfaceDetectionOptions & opt
	Struct SurfacePreProcInfo & preProc
	Variable correctRetract = opt.correctRetract
	Variable nPointsSmooth = ceil(opt.SavitskyTImeConstantArtifact/deltax(mDeflV))
	// Make a duplicate of the original y
	Duplicate /O mDeflV,mSmoothedDeflV
	// smooth the original y
	ModFitUtil#SavitskySmooth(mSmoothedDeflV,nPoints=nPointsSmooth)
	// Duplicate for derivative taking
	Duplicate /O mSmoothedDeflV,mSmoothedDeriv
	// Take  the derivative (in place)
	Differentiate mSmoothedDeriv
	// Get where  the (smoothed) derivative is maximum. only look at the approach
	Variable halfIndex = ModSurfaceDetectorUtil#GetHalfThroughDwellIdx(mDeflV)
	Duplicate /O/R=[0,halfIndex] mSmoothedDeriv,approachDeriv
	// Max deriv should be on the invols curve (note that the taylor series of any
	// sinusoid has a zero derivative close enough to where you are evaluating it*)
	Struct WaveStat mStats
	ModStatUtil#GetWaveStats(approachDeriv,mStats)
	Variable maxIdx = mStats.maxRowLoc
	Variable maxTimeDeriv = pnt2x(approachDeriv,maxIdx)
	// Get the median point on the Smoothed,approachDeriv derivative
	Variable mMedian= StatsMedian(approachDeriv)
	// Get there the median last intersects the smoothed data
	// Searh from the 0 to max, *backwards* (true for last arg)
	Variable lastCrossingIdx = ModStatUtil#FindIdxLevelCrossing(approachDeriv,mMedian,0,maxIdx,ModDefine#True())
	// Get the x value at the last crossing index
	Variable lastCrossX = pnt2x(approachDeriv,lastCrossingIdx)
	// Fit the portion between 0 and lastCrossX
	Duplicate /O/R=[0,lastCrossingIdx] mDeflV,toFItArtifact,fittedArtifactAppr
	// Make new coefficients for the "just-artifact" fit of the curve
	ModFitUtil#CreatePolyCoeffs(toFitArtifact,mCoeffs)
	// Generate the fitted artifact curve
	ModFitUtil#polyval(mCoeffs,fittedArtifactAppr)
	// We have to be careful looking at the corrected. The polynomial will have
	// a zero mean (or close). However, by construction, the fit is known to start at the
	// median value (or very close to it). So, to correct, we look at the residuals (mDeflV-artifact)
	// but add in a constant value (the median, or close to it). This ensures smoothness.
	mDeflVCorrected[0,lastCrossingIdx] = mDeflVCorrected[p] - fittedArtifactAppr[p] + mDeflV[lastCrossingIdx]
	Variable retractFitIdx = -1
	if (correctRetract)
		//  correct the retraction curve. 
		// Reverse the fitted artifact curve; /P prevents the X from also reversing itself
		Reverse /P fittedArtifactAppr
		// Determine where the symmetric point (in Zsnsr space) is on the retract. False: Search forwards
		Variable wherWeFitZsnsr = Zsnsr[lastCrossingIdx]
		retractFitIdx = ModStatUtil#FindIdxLevelCrossing(Zsnsr,wherWeFitZsnsr,halfIndex,Inf,ModDefine#False())
		Variable nPoints = DimSize(mDeflVCorrected,0)
		Variable endIndx = min(nPoints-1,retractFitIdx+(lastCrossingIdx-1))
		Variable offset =  mDeflV[lastCrossingIdx]
		mDeflVCorrected[retractFitIdx,endIndx] = mDeflV[p] - fittedArtifactAppr[p-retractFitIdx] + offset
	EndIf
	if (!ParamIsDefault(preProc))
		// Then set the variables
		preProc.fitIdxAppr = lastCrossingIdx
		preProc.fitIdxRetr = retractFitIdx
		if (retractFitIdx >=0)
			preProc.hasFitIdxRetr= ModDefine#True() 
		EndIf
		Wave preProc.mCoeffs = mCoeffs
	EndIf
	KillWaves /Z toFItArtifact,approachDeriv,mSmoothedDeflV,mSmoothedDeriv
End Function