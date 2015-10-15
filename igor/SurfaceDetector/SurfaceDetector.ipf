// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModSurfaceDetector
#include ":SurfaceDetectorUtil"
#include ":SurfacePreProc"
#include ":SurfaceDefines"

Static Function Main()
	// Initialize the folders and global view obect
	ModSurfaceDefines#InitSurfaceWorkspace()
	// Initialize the view itself
	ModSurfaceView#InitView()
End Function

// Given a Zsnsr and deflVolts,returns the invols and surfaceZsnsr as pass-by-reference variables.
// Has options (see above) for fitting interference artifacts, and can return informational structures and the corrected DeflVolts
// Does *not* alter the original data in any way.
Static Function SurfaceDetect(Zsnsr,DeflVolts,Invols,surfaceZsnsr,[Options,Detector,PreProcessor,CorrectedDeflVolts])
	Wave Zsnsr, DeflVolts,CorrectedDeflVolts
	Variable &Invols,&surfaceZsnsr
	Struct SurfaceDetector & Detector
	Struct SurfacePreProcInfo & PreProcessor
	Struct SurfaceDetectionOptions & Options
	Struct SurfaceDetectionOptions optToUse
	// Get the user options
	If (ParamIsDefault(Options))
		ModSurfaceDefines#DefOptions(optToUse)
	else
		optToUse = Options
	EndIf	
	Struct SurfaceDetector mDetector
	Struct SurfacePreProcInfo mProc
	// we may need to correct the DeflV channel; this reference will hold whatever
	// we intend to detect on (uncorrected if something like DNA)
	Wave deflToDetect 
	// Determine if we should correct things
	if (optToUse.correctInterference)
		// Then correct everything 
		Duplicate /O DeflVolts,DeflVoltsCorrected
		Make /O/N=(0) coeffs 
		ModSurfacePreProc#ArtifactCorrect(Zsnsr,DeflVolts,DeflVoltsCorrected,coeffs,optToUse,preproc=mProc)		
		Wave deflToDetect= DeflVoltsCorrected
	 	if (!ParamIsDefault(CorrectedDeflVolts))
	 		Duplicate /O DeflVoltsCorrected,CorrectedDeflVolts
	 	EndIf
	else
		// no need to correct
		deflToDetect= DeflVolts
	EndIf
	// then call the surface routine with the artifact-corrected version
	 ModSurfaceDetectorUtil#GetApproachInvols(zsnsr,DeflVoltsCorrected,invols,surfaceZsnsr,debugStruct=mDetector)
	// Write back the debugging structs, if need be 
	if (!ParamIsDefault(detector))
		Detector = mDetector
	EndIF
	if (!ParamIsDefault(PreProcessor))
		PreProcessor = mProc
	EndIF
	KillWaves /Z DeflVoltsCorrected
	// that's it!
End Function