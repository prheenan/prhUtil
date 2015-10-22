// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModNUG2
// Used to fit the WLC functions
#include "::Util:ErrorUtil"
#include "::Model:ModelDefines"
#include "::Model:PreProcess"
#include "::Util:GlobalObject"
#include "::Util:Defines"
#include "::Util:StatUtil"
#include "::Model:Model"
#include "::Util:IoUtil"
#include "::Util:CypherUtil"
#include "::Converters:DevinHighResConvert"
#include "::MVC_Common:MvcDefines"


StrConstant X_HIGH_RES_SUFFIX = ""// no X required; all taken care of by (1) extension of a proper length after the file.
// See: Inteperpolate Help.ihf
// you can find this by clicking interpolate --> Help --> Done, then searching
// for interpolate2 in the help menu (on a MAC, Igor 6.37, 7/23/2015, size 12 shoe)
Constant INTERPOLATE2_LINEAR = 1
// Window for saving ruptures. Units of high bandwidth. e.g. if 5MHz, then N/5MHz is the amount of time saved
Constant DEF_NUG2_WINDOW_AFTER_RUPT = 400
Constant DEF_NUG2_WINDOW_BEFORE_RUPT = 30000
// Indices for the ruptures
Constant RUPTURE_OFFSET_0 = 4
Constant RUPTURE_IDX_0 = 5
Constant RUPTURE_IDX_1 = 7
Constant RUPTURE_IDX_2 = 9
Constant RUPTURE_IDX_3 = 11
Constant RUPTURE_IDX_FINAL = 13

// Generalize: Method to ask for recquired waves (for full extension), method to get full extension, assuming they exist
// High resolution extension (version)
StrConstant ZSNSR_INTERP = "ZSnsr_Interp"

// InWave is the wave of paths to the wave stems we are interested in
Function GetInputNamesNUG2(InWave,mProc)
	Struct ProcessStruct & mProc
	Wave /T InWave
	Variable n = DimSize(InWave,0)
	Variable i=0
	for (i=0; i<n; i+=1)
		String mWaveStem = InWave[i]
		// Check if all the necessary waves exist...
		if (!ModDevinHighResConvert#AllWavesExistForStem(mWaveStem))
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
	mProc.xLowResSuffix = ZSNSR_FULL_LOWRES
	mProc.xHighResSuffix= ZSNSR_FULL_HIGHRES
	mProc.yLowResSuffix = DEFLV_LOW_RES_SUFFIX_FULL
	mProc.yHighResSuffix= DEFLV_HIGH_RES_SUFFIX
End Function

// Save the four ruptures and the final rupture of a given wave
Function SaveRupture(srcWave,ruptureIdx,offsetIdx,mStruct)
	Wave ruptureIdx,offsetIdx,srcWave
	Struct ViewModelStruct & mStruct
	String mFolder = mStruct.modelBaseOutputFolder
	Variable nRupt = DimSize(ruptureIdx,0)
	Variable nPointsPerRupt = DEF_NUG2_WINDOW_BEFORE_RUPT+DEF_NUG2_WINDOW_AFTER_RUPT
	// Add an underscore to prevent evil name conflicts
	// XXX fix? Just use uniquename?
	String mWaveName = NameOfWave(srcWave) + "_"
	Make /O/N=(nPointsPerRupt,nRupt) $mWaveName
	Wave /D allRupt = $mWaveName
	Variable i
	Variable nPointsBefore = DEF_NUG2_WINDOW_BEFORE_RUPT
	Variable nPointsAfter = DEF_NUG2_WINDOW_AFTER_RUPT
	For (i=0; i<nRupt; i+=1)
		Variable mIdxRupt = ruptureIdx[i]
		Duplicate /O/R=[mIdxRupt-nPointsBefore,mIdxRupt+nPointsAfter-1] srcWave tmpSaveRupt
		allRupt[0,nPointsPerRupt-1][i] = tmpSaveRupt[p]
	EndFor
	// relative to the start of the slice, where is the end of the rupture (ie: the offset for the next WLC)
	offsetIdx -= ruptureIdx
	offsetIdx += nPointsBefore
	Make /O/N=(1,nRupt) mRuptIdxToFile
	mRuptIdxToFile[][] = nPointsBefore 
	Redimension /N=(1,nRupt) offsetIdx
	Concatenate /NP=(0) {mRuptIdxToFile,offsetIdx},allRupt
	ModIoUtil#SaveWaveDelimited(allRupt, mFolder,name=mStruct.mExp + "_" + NameOfWave(srcWave) +".itx")
	KillWaves /Z tmpSaveRupt
End Function

Function /Wave CreateRuptureIdx(fitParameters,mRuptIdx,mOffIdx)
	Struct ParamObj & fitParameters
	Wave mRuptIdx,mOffIdx
	// XXX todo
	mRuptIdx  =  {RUPTURE_IDX_0,RUPTURE_IDX_1,RUPTURE_IDX_2 ,RUPTURE_IDX_3, RUPTURE_IDX_FINAL}
	Variable nRupt = DimSIze(mRuptIdx,0)
	Redimension /N=(nRupt) mOffIdx
	mOffIdx[] =  mRuptIdx[p] + 1 // offsets for the next are right after the ruptures.
	// overwrite the rupture indices with their actual indices in the data
	Variable i
	for (i=0; i<nRupt; i+=1)
		mRuptIdx[i] = fitParameters.params[mRuptIdx[i]].pointIndex
		mOffIdx[i] = fitParameters.params[mOffIdx[i]].pointIndex
	EndFor
	// return the array we want
	return mRuptIdx
End Function

// Can't be static or funcref gets confused
Function NUG2Fit(xRef,yRef,fitParameters,mStruct)
	String xRef,yRef
	Struct ParamObj & fitParameters
	Struct ViewModelStruct & mStruct
	String mName = yRef + "_"
	Duplicate /O $(yRef) $mName
	Wave srcWave = $mName
	// do the initial y offset and flip
	Variable mYOffset = srcWave[fitParameters.params[RUPTURE_OFFSET_0].pointIndex]
	srcWave -= mYOffset
	srcWave *= -1
	Make /O/N=0 mRupt
	Make /O/N=0 mOff
	CreateRuptureIdx(fitParameters,mRupt,mOff)
	SaveRupture(srcWave,mRupt,mOff,mStruct)
	KillWaves /Z mRupt,srcWave
End Function

Static Function InitNUG2Model(ToInit)
	Struct ModelObject & ToInit
	Struct Global GlobalDef
	ModGlobal#InitGlobalObj(GlobalDef)
	// Create the functions this object will use
	Struct ModelFunctions mFuncs
	ModModelDefines#InitModelFunctions(mFuncs,NUG2Fit)
	FuncRef ProtoGetInputNames mGetWaves = GetInputNamesNUG2
	FuncRef ProtoInterpLowResToHigh mInterp = ModPreProcessWigglesInterp
	FuncRef ProtoAlignByOffset AlignByOffset = ModPreProcessWigglesOffsetX
	FuncRef ProtoCorrect Correct = ModPreProcessWiggleCorrect
	Struct ProcessStruct mProc
	// make a path, just for this file.
	String mName = "NUG2"
	// Get the directory for the view
	ModPreprocess#InitProcStruct(mProc,mName,mGetWaves,mInterp=mInterp,AlignByOffset=AlignByOffset,Correct=Correct)	
	// Actually add the functions, parameters, and description to the model object
	// initialize our model-specific pre-processing
	// Note: this model cares about plotting versus *time*, to get the rupture force (after pre-processing)
	InitModelGen(ToInit,mName,mFuncs,"DNA WLC And Overstretching Fitter",X_HIGH_RES_SUFFIX,DEFLV_HIGH_RES_SUFFIX,mPreProc=mProc,mPlotType=PLOT_TYPE_X_VS_TIME)
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
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Initial Surface Contact,Slow","Initial_Contact_Slow",preproc=true)
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Initial Surface Contact,Fast","Initial_Contact_Fast",preproc=true)
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Final Surface Contact,Slow","Final_Contact_Slow",preproc=true)
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Final Surface Contact,Fast","Final_Contact_Fast",preproc=true)
	// Add in all the parameters or the model
	Variable nUnfolds = 4
	Variable i=0
	String offsetDescr = "Start of this WLC"
	String ruptureDescr = "Rupture of this WLC"
	for (i=0; i <nUnfolds; i+=1)
		// Add an XY offset for touching off
		String mOffsetName
		sprintf mOffsetName, "WlcOffset_%d",i
		String mRuptureName 
		sprintf mRuptureName,"Rupture_%d",i
		AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,offsetDescr,mOffsetName)
		AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,ruptureDescr,mRuptureName)
	EndFor
	// POST: have offset and rupture for all 
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Final Rupture Offset","FinalRuptureOffset")
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Final Rupture Completed","FinalRupturePeak")
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Final Rupture Completed","FinalRuptureEnd")
End Function
