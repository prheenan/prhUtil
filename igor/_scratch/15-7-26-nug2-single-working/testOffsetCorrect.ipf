// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModTestOffsetCorrect
#include "::..:Util:PlotUtil"
#include "::..:Model:PreProcess"

Static Function Main()
	// Get the offsets we need.
	Variable t0Slow = 0.62572
	Variable t0Fast = 0.63217
	Variable tfSlow = 1.6178
	Variable tfFast = 1.6244
	String fastLoc = "root:Packages:View_NUG2:Data:Data_AzideB1:Image2449DeflV_Towd"
	String slowLoc = "root:Packages:View_NUG2:Data:Data_AzideB1:Image2449Full_Defl"
	String mSLow = "mSlow"
	String mFast = "mFast"
	Duplicate /O $slowLoc  $mSlow
	Duplicate /O $fastLoc  $mFast
	Display
	AppendToGraph /C=(50000,50000,50000) $mFast
	AppendToGraph /C=(0,10000,0) $mSlow
	ModPlotUtil#SaveFig(saveName="1Before")
	// Correct the fast extract based on the fast touchoff
	// Get the indices, for this purpose
	Wave mFitWave = $mSlow
	Wave mFastWave = $mFast
	Variable idxInitFit = x2pnt(mFitWave,t0Slow)
	Variable idxFinalCorrect= x2pnt(mFastWave,tfFast)
	// Get the fit we will use
	Duplicate /O/R=[0,idxInitFit] mFitWave,mPolyFit
	Variable nPoints = DimSize(mPolyFit,0)
	Make /O/N=(0) mCoeffs
	Make /O/N=(nPoints) outputFit
	Reverse mPolyFit
	// MOdPreProcess#GetPolyFit(mPolyFit,mCoeffs,outputFit)
	ModPreProcess#Correct(mFitWave,mFastWave,idxInitFit,idxFinalCorrect)
	Display
	AppendToGraph /C=(50000,50000,50000) $mFast
	AppendToGraph /C=(0,10000,0) $mSlow
	MOdPlotUtil#SaveFig(saveName="2Corr")
	// Now, offset the *slow* to the fast
	// Offset the wave so that t0Slow,new = t0Fast
	Variable offset = t0Slow-t0Fast
	ModPreProcess#OffsetX(mSlow,offset)
	Display
	AppendToGraph /C=(50000,50000,50000) $mFast
	AppendToGraph /C=(0,10000,0) $mSlow
	ModPlotUtil#SaveFig(saveName="3Offset")
	// Recommend window of ~ 50 (effectively N/F = 50/5Mhz = 50 * 200ns = 10us
	Variable WindowAround = 50
	Make /O ruptureIdx = {8596842,8902402,9100550,9263106,9489858}
	Variable yOffDeflV = 0.0039927
	Variable Invols = ModCypherUtil#GetInvols($mFast)
	Variable springConst = ModCypherUtil#GetSpringConstant($mFast)
	Duplicate /O $mFast,mForce
	// offset the deflection, then convert to force and flip, so that extension is positive
	String mFolder
	ModIoUtil#GetFolderInteractive(mFolder)
	mForce = (mForce - yOffDeflV) * Invols * SpringConst * (-1)
	MOdNUG2#SaveRupture(mForce,ruptureIdx,mFolder)
End Function
