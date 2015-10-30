// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModSurfaceDefines
#include "::DataStruct:SafeWaveStruct"
#include "::Util:IoUtil"

// interference smoothing constant, in seconds
Static Constant DEF_INTERFERENCE_SMOOTH = 0.01
Static StrConstant WorkingDir = "root:Packages:SurfaceDetector:"
Static StrConstant ViewSubDir = "ViewWaves"
Static StrConstant NumericName = "NumericOptions"

Structure SurfaceDetectionOptions 
	// time constant for smoothing the artifact
	double savitskyTimeConstantArtifact
	// whether we should correct the approach for interference
	uint32 correctInterference
	// whether we should correct the retract for interference (based on approach!)
	uint32 correctRetract
EndStructure

Static Function /S GetViewSubDir()
	return ModIoUtil#AppendedPath(WorkingDir,ViewSubDir)
End Function

// Get the names of the waves we will use
Static Function WaveNames(numeric)
	String & numeric
	String mSub = GetViewSubDir()
	numeric = ModIoUtil#AppendedPath(mSub,NumericName)
End Function

Static Function SaveViewOpt(mViewOpt)
	Struct SurfaceDetectionOptions  & mViewOpt 
	String numeric 
	WaveNames(numeric)
	StructPut /B=(ModDefine#StructFmt())  mViewOpt, $numeric
End Function

Static Function LoadViewOpt(mViewOpt)
	Struct SurfaceDetectionOptions  & mViewOpt 
	String numeric 
	WaveNames(numeric)
	StructGet /B=(ModDefine#StructFmt())  mViewOpt, $numeric
End Function

Static Function DefOptions(Opt)
	Struct SurfaceDetectionOptions & Opt
	opt.correctInterference = ModDefine#True()
	opt.correctRetract = ModDefine#False()
	opt.savitskyTimeConstantArtifact = DEF_INTERFERENCE_SMOOTH
End Function

Static Function InitWaves()
	String numeric 
	WaveNames(numeric)
	Make /O/N=(0) $numeric
End Function

// function to get the possible fitters for the interference artifact
Static Function /S GetFitters()
	return "40th-order Polynomial;Sinusoid with positionally-dependent frequency";
End Function	

Static Function InitSurfaceWorkspace()
	ModIoUtil#EnsurePathExists(WorkingDir)
	String viewSubDir  = GetViewSubDir()
	ModIoUtil#EnsurePathExists(viewSubDir)
	// POST: all the directories exist.
	// Go ahead and make the waves we will want. 
	InitWaves()
	Struct SurfaceDetectionOptions mViewOpt 
	DefOptions(mViewOpt)
	SaveViewOpt(mViewOpt)
End Function


