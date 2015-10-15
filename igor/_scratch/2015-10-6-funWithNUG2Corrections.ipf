// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchNugCorrection
#include "::Util:PlotUtil"
#include "::Util:FitUtil"
#include "::Util:StatUtil"
#include "::Util:UnitUtil"
#include "::SurfaceDetector:SurfacePlotting"
#include "::SurfaceDetector:SurfaceDetectorUtil"
#include "::SurfaceDetector:SurfacePreProc"

Static Function Main()
	ModPlotUtil#ClearAllGraphs()
	// Assume we have the "deflV" wave with the interference artifact in the experiment
	Wave mDeflV = $"DeflVolts"
	Wave Zsnsr = $"Zsnsr"
	// Get the corrected DeflV
	Struct SurfacePreProcInfo preProc
	Duplicate /O mDeflV,mDeflVCorrected
	Make /O/N=0 mCoeffs
	ModSurfacePreProc#ArtifactCorrect(Zsnsr,mDeflV,mDeflVCorrected,mCoeffs,preProc=preProc,correctRetract=ModDefine#True())
	// Get the surface detector
	Variable invols,surfaceX
	Struct SurfaceDetector mDetector
	ModSurfaceDetectorUtil#GetApproachInvols(Zsnsr,mDeflVCorrected,invols,surfaceX,debugStruct=mDetector)
	ModSurfacePlotting#PlotArtifactCorrectionCurve(Zsnsr,mDeflV,mDeflVCorrected,mDetector,preProc)
	ModSurfacePlotting#PlotInvolsCurve(mDetector,Zsnsr,mDeflVCorrected,hide=ModDefine#False())
End Function