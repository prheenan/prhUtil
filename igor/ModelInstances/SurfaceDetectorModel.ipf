#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#pragma ModuleName = ModSurfaceDetectorModel
// Used to fit the WLC functions

#include "::Util:ErrorUtil"
#include "::Model:ModelDefines"
#include "::Util:GlobalObject"
#include "::Util:StatUtil"
#include "::Util:IoUtil"
#include "::Model:Model"
#include "::MVC_Common:MvcDefines"

Static StrConstant ZSNSR_NAME = "ZSnsr"
Static StrConstant DEFL_NAME = "Defl"

// InWave is the wave of paths to the wave stems we are interested in
Function GetInputNamesSurfaceDetector(InWave,mProc)
	Struct ProcessStruct & mProc
	Wave /T InWave
	Variable n = DimSize(InWave,0)
	Variable i=0
	Make /O/T mExtInputSurf = {ZSNSR_NAME,DEFL_NAME}
	for (i=0; i<n; i+=1)
		String mWaveStem = InWave[i]
		// Check if all the necessary waves exist...
		if (!ModDevinHighResConvert#AllWavesExistForStem(mWaveStem,mExt=mExtInputSurf))
			continue
		EndIf
		// POST: both low and high resolution waves (seem to) exist
		//Create all the waves we want
		String fullZsnsrLow,fullZsnsrHigh,fullDeflLow,fullDeflHigh
		// True: Create the waves we want in the same folder.
		ModDevinHighResConvert#GetRelevantStems(mWaveStem,ModDefine#True(),fullZsnsrLow,fullZsnsrHigh,fullDeflLow,fullDeflHigh)
		// for now, just put the DeflV high resolution into the Zsnsr (interpolated later)
		Duplicate /O $fullDeflHigh,$fullZsnsrHigh
		ModPreprocess#AddStringToWaves(mProc,fullZsnsrLow,fullZsnsrHigh,fullDeflLow,fullDeflHigh)
	EndFor
	// Set the suffixes we used
	mProc.xLowResSuffix = ZSNSR_NAME
	mProc.xHighResSuffix= ZSNSR_NAME
	mProc.yLowResSuffix = DEFL_NAME
	mProc.yHighResSuffix= DEFL_NAME
End Function


Function SurfaceDetectorModelFit(xRef,yRef,fitParameters,mStruct)
	String xRef,yRef
	Struct ParamObj & fitParameters
	Struct ViewModelStruct & mStruct
	// Dont go anything
End Function

Static Function InitSurfaceModel(ToInit)
	Struct ModelObject & ToInit
	Struct Global GlobalDef
	ModGlobal#InitGlobalObj(GlobalDef)
	// Create the functions this object will use
	Struct ModelFunctions mFuncs
	ModModelDefines#InitModelFunctions(mFuncs,SurfaceDetectorModelFit)
	FuncRef ProtoGetInputNames mGetWaves = GetInputNamesSurfaceDetector
	Struct ProcessStruct mProc
	// make a path, just for this view
	String mName = "SurfDetect"
	//Get the preproc struct. note we do want to convert (from Zsnsr/deflV) immediately
	ModPreprocess#InitProcStruct(mProc,mName,mGetWaves,ConvertImmediately=MOdDefine#True())
	// Actually add the functions, parameters, and description to the model object
	// initialize our model-specific pre-processing
	// Note: this model cares about plotting versus *time*, to get the rupture force (after pre-processing)
	InitModelGen(ToInit,mName,mFuncs,"SurfaceDetector",ZSNSR_NAME,DEFL_NAME,mPreProc=mProc,mPlotType=PLOT_TYPE_X_VS_SEP)
	// Load the predefined model stuff
	Struct ModelDefines modDef 
	modDef = GlobalDef.modV
	// Make the units and prefix for the parameters
	Struct Unit meter
	Struct Prefix nano
	nano = modDef.pref.nano
	meter = modDef.unit.meters
	// Add in all the parameters for the pre-processing
	Variable true= ModDefine#True()
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Initial Surface Contact,Slow","Surface_Contact",preproc=true)
End Function
