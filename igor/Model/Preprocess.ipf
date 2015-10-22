// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#pragma ModuleName = ModPreprocess
#include "::Util:IoUtil"
#include "::MVC_Common:MvcDefines"
#include ":ModelDefines"
#include "::Util:CypherUtil"
#include "::Util:FitUtil"

Static StrConstant XNAMEPRE = "XWave"
Static StrConstant YNAMEPRE = "YWave"
Static StrConstant HIRES = "HighBW"
Static StrConstant LowRes = "LowBW"
// naame to add for a separate folder for the pre-processor
Static StrConstant PREPROC_SUBFOLDER = "PreProc"
// 
Static StrConstant FORCE_WAVE_NAME = "AllForces"
Static StrConstant SEP_WAVE_NAME = "AllSeps"

Static Constant PROC_NAMEMAX = 200
Static Constant MAX_PREPROC_PARAMS = 15
Static Constant PROC_NAME_SUFFIX_MAXLEN = 20

Structure ProcessStruct
	// BAse directory
	char baseDir[PROC_NAMEMAX]
	// Following are preprocessing waves for text names
	// "X" refers to the x values (e.g. separation, Zsnsr)
	char XLowRes[PROC_NAMEMAX]
	char XHighRes[PROC_NAMEMAX]
	// "Y" refers to the y values (e.g. Force, Defl,DeflV)
	char YLowRes[PROC_NAMEMAX]
	char YHighRes[PROC_NAMEMAX]
	// What the X and Y suffixes are. Must be et by 'FuncGetWaves'
	char xLowResSuffix[PROC_NAME_SUFFIX_MAXLEN]
	char xHighResSuffix[PROC_NAME_SUFFIX_MAXLEN]
	char yLowResSuffix[PROC_NAME_SUFFIX_MAXLEN]
	char yHighResSuffix[PROC_NAME_SUFFIX_MAXLEN]
	// Same thing for Force and Sep
	char ForceSuffix[PROC_NAME_SUFFIX_MAXLEN]
	char SepSuffix[PROC_NAME_SUFFIX_MAXLEN]
	// Force and Seapration Waves are populated by "FuncConvert"
	char Force[PROC_NAMEMAX]
	char Sep[PROC_NAMEMAX]	
	// 'FuncGetWaves' is a a function which, given a list of waves, populates 
	//XLowRes, XHighRes,YLowRes,YHighRes
	// with a list of exisintg waves, where index I refers to the same experiment.
	// Note: This does *not* create XHighRes (ie: does not interpolate), it *only*
	// creates the wave. Interpolation is done below
	// Follows prototype for "ProtoGetInputNames"
	char FuncGetWaves[PROC_NAMEMAX]
	// "FuncInterp" interpolates the low resolution waves into high resolution.
	// Usually, this will just mean we interpolate the X (ie: Zsensor), since high
	// resolution Y is already given
	char FuncInterp[PROC_NAMEMAX]
	// 'FuncOffset' is a Function which, given a time offset in seconds, aligns all the data.
	// Follows prototype for 'ProtoAlignByOffset', uses current time offsets
	// It *must* update the time offsets in this (to be the same, for use by the others)
	char FuncOffset[PROC_NAMEMAX]
	// 'FuncCorrect' is a function which corrects for the 'wiggles', given the offsets provided.
	// Follows prototype for ProtoCorrect
	char FuncCorrect[PROC_NAMEMAX]
	// 'FuncConvert is a function which converts all the waves present here into 
	// Force and Separation Waves, saving the names into ForceFinal and SepFinal
	// Note that if baseDir is Present, it should copy the waves into baseDir.
	char FuncConvert[PROC_NAMEMAX] 
	// The parameter numebrs associated with the pre-processing parameters
	char paramIdx[MAX_PREPROC_PARAMS]
	// How many pre-processing parameters there are
	char NPreProcParams
	// True if pre-processing should happen
	char PreProcessingRecquired
	// True if conversion should happen immediately
	char convertImmediately
EndStructure

Function  ProtoGetInputNames(InWave,mProc)
	Wave /T InWave
	Struct ProcessStruct & mProc
End Function


Function ProtoAlignByOffset(mProc,mParamObj,Index)
	Struct ProcessStruct & mProc
	Struct ParamObj & mParamObj	
	Variable index
	// by default, dont do anything. assume no aligning.
End Function

// Correct the *force* wave.
// Note: this converts the low resolution Y into force for correction
Function ProtoCorrect(mProc,mParamObj,Index)
	// By default, dont do anything
	Struct ProcessStruct & mProc
	Struct ParamObj & mParamObj	
	Variable Index
End Function

// Process a single curve. Does *not* save the processed struct; caller must do that.
Static Function GetProcessedSepForce(mProc,mParamObj,index,mSepNAme,mForceName)
	Struct ProcessStruct & mProc
	Struct ParamObj & mParamObj	
	Variable index
	String & mForceName,&mSepName
	// Offset the high resolution X curve
	FuncRef ProtoAlignByOffset mOffset = $(mProc.FuncOffset)
	mOffset(mProc,mParamObj,index) 
	// Go ahead and convert to force and separation
	// This will make the force and separation curves we actually care about
	if (!mProc.convertImmediately)
		// Then things havent already been converted; go ahead
		FuncRef ProtoConvertSingle mConvert = $(mProc.FuncConvert)
		mConvert(mProc,index)
	EndIf
	// Then, correct the (force) curve
	FuncRef ProtoCorrect mCorrect = $(mProc.FuncCorrect)
	mCorrect(mPRoc,mParamObj,index)
	// POST: the curve is corrected and offset.
	// POST: Force and sep are created, set the names
	Wave /T mForces = $(mProc.Force)
	Wave /T mSep = $(mProc.Sep)
	mForceName = mForces[index]
	mSepName = mSep[index]
End Function

Function ProtoInterpLowResToHigh(mProc)
	// by default, dont do anything (no interpolation necessary)
	Struct ProcessStruct & mProc

End Function


// Function to fit a non-linear interference artifact
function interference(w,x):fitfunc
	wave w
	variable x
	return w[0]+w[1]*x+(w[2]+w[5]*x)*Sin(w[3]*x+w[4])
end

Function ProtoConvertSingle(mProc,index)
	Struct ProcessStruct & mProc 
	Variable index
	Wave /T mXWave = $(mProc.XHighRes)
	Wave /T mYWave = $(mProc.YHighRes)
	Wave /T mForces = $(mProc.Force)
	Wave /T mSep = $(mProc.Sep)
	// Convert each of the waves
	String mForceName
	String mSepName
	mForceName = GetForceName(mProc,mYWave[index])
	mSepName = GetsepName(mProc,mXWave[index])
	// POST: have both the waves we need
	ModCypherUtil#GetForceSepInferTypes($mXWave[index],$mYWave[index],mForceName,mSepName)
	mForces[index] = mForceName
	mSep[index] = mSepName
End Function

Static Function PopulatePreProc(InWaves,mProc)
	// filteres the waves referenced in Inwaves to determine the 'true'
	// waves we want to pre-process
	// PRE: Inwaves should have something in it.
	Wave /T InWaves
	Struct ProcessStruct & mProc
	// Filter the input waves	
	// Get the 'true' waves, convert them to force/sep
	FuncRef ProtoGetInputNames mFuncGet = $(mProc.FuncGetWaves)
	FuncRef ProtoInterpLowResToHigh mInterp =$(mProc.FuncInterp)
	mFuncGet(InWaves,mProc)
	// POST: we have the known curves (high and low resolution X)
	// Make space for the (eventual) force and separation curves
	// These are made *after* pre-processing, to avoid stale curves.
	Variable nWaves = DimSize(inWaves,0)
	Make /O/N=(nWaves)/T $(mProc.Force)
	Make /O/N=(nWaves)/T $(mProc.Sep) 
	Wave /T mForce = $(mProc.Force)
	Wave /T mSep = $(mProc.Sep)
	// By default, copy the low res name array into the high res name array	Wave yHighRes = $(mProc.YHighRes)	
	Duplicate /O inwaves, $(mProc.YHighRes),$(mProc.YLowRes),$(mProc.XHighRes),$(mProc.XLowRes)
	Wave /T yLowRes = $(mProc.YLowRes)
	Wave /T xLowRes = $(mProc.XLowRes)
	Wave /T yHiRes = $(mProc.YHighRes)
	Wave /T xHiRes = $(mProc.XHighRes)
	yHiRes[] = yHiRes[p] + mProc.yHighResSuffix
	xHiRes[] = xHiRes[p] + mProc.xHIghResSuffix
	yLowRes[] = yLowRes[p] + mProc.yLowResSuffix
	xLowRes[] = xLowRes[p] + mProc.xLowResSuffix
	if (mProc.convertImmediately)
		// Go ahead and convert everything
		// Then things havent already been converted; go ahead
		Variable i
		FuncRef ProtoConvertSingle mConvert = $(mProc.FuncConvert)
		for (i=0;  i < nWaves ; i+=1)
			mConvert(mProc,i)
		EndFor
	EndIF
	// Populate them according to the suffixes
	// Go ahead and interpolate the curves, so that we can operate only on the high resolution ones
	mInterp(mProc)
	// POST: mProc has all of the X and Y names stored  that it needs.
End function

// Method to save (to a wave in memory a pre-processing object)
Static Function SavePreProc(mProc,mName)
	Struct ProcessStruct & mProc
	String mName
	if (!WaveExists($mName))
		Make /O/N=0 $mName	
	EndIf
	// POST: wave is guareteed to exist.
	StructPut /B=(ModDefine#StructFmt())  mProc, $(mName)
End Function

// Method to load a pre-processing object from a given name
Static Function LoadPreProc(mProc,mName)
	Struct ProcessStruct & mProc
	String mName
	// PRE: must have saved it before. 
	// XXX generic method for checking this?
	ModErrorUtil#WaveExistsOrError(mName)
	// POST: wave exists
	StructGet /B=(ModDefine#StructFmt()) mProc, $(mName)
End Function

Static Function InitProcStruct(mProc,ModelName,GetInputNames,[mInterp,AlignByOffset,Correct,Convert,ConvertImmediately])
	Struct ProcessStruct & mProc
	String ModelName
	FuncRef ProtoGetInputNames GetInputNames
	FuncRef ProtoInterpLowResToHigh mInterp
	FuncRef ProtoAlignByOffset AlignByOffset
	FuncRef ProtoCorrect Correct
	FuncRef ProtoConvertSingle Convert
	Variable ConvertImmediately
	// Make a subfoler for the pre-processor, ensure it exists
	String mDir = ModIoUtil#AppendedPath(ModMvcDefines#GetViewBase(ModelName),PREPROC_SUBFOLDER)
	ModIoUtil#EnsurePathExists(mDir)
	mProc.baseDir = mDir
	// Yes; we have some pre-processing step
	mProc.PreProcessingRecquired = ModDefine#True()
	// Initialize all the waves,
	mProc.XLowRes = ModIoUtil#AppendedPath(mDir,XNAMEPRE +LOWRES)
	mProc.XHighRes = ModIoUtil#AppendedPath(mDir,XNAMEPRE +HIRES)
	mProc.YLowRes = ModIoUtil#AppendedPath(mDir,YNAMEPRE +LOWRES)
	mProc.YHighRes = ModIoUtil#AppendedPath(mDir,YNAMEPRE +HIRES)
	mProc.Force = ModIoUtil#AppendedPath(mDir,FORCE_WAVE_NAME )
	mProc.Sep = ModIoUtil#AppendedPath(mDir,SEP_WAVE_NAME)
	Make /O/T/N=(0) $(mProc.XLowRes)
	Make /O/T/N=(0) $(mProc.XHighRes)
	Make /O/T/N=(0) $(mProc.YLowRes)
	Make /O/T/N=(0) $(mProc.YHighRes)
	ConvertImmediately = ParamIsDefault(ConvertImmediately) ? ModDefine#False() : ConvertImmediately
	mProc.ConvertImmediately =  ConvertImmediately		
	// POST: all function strings defined, set them up
	// XXX check that they exist?
	mProc.FuncGetWaves = ModIoUtil#GetFuncName(FuncRefInfo(GetInputNames))
	mProc.FuncInterp = ModIoUtil#GetFuncName(FuncRefInfo(mInterp))
	mProc.FuncOffset = ModIoUtil#GetFuncName(FuncRefInfo(AlignByOffset))
	mProc.FuncCorrect= ModIoUtil#GetFuncName(FuncRefInfo(Correct))
	mProc.FuncConvert= ModIoUtil#GetFuncName(FuncRefInfo(Convert))
	// Add the final suffixes for the force and separation
	// Note: these come from CypherUtil.
	mProc.ForceSuffix =  ModcYpherUtil#ForceSuffix()
	mProc.SepSuffix = MOdCypherUtil#SepSuffix()
End Function

// Function to add known waves to the pre-procoessor
Static Function AddStringToWaves(mProc,xLow,xHigh,yLow,yHigh)
	Struct ProcessStruct & mProc
	String xLow,xHigh,yLow,yHigh
	Make /O/T tmpXLow = {xLow}
	Make /O/T tmpXHIgh = {xHIgh}
	Make /O/T tmpYLow = {yLow}
	Make /O/T tmpYHigh= {yHigh}
	Concatenate /NP/T {tmpXLow},$mProc.XLowRes
	Concatenate /NP/T {tmpXHIgh},$mProc.XHIghRes
	Concatenate /NP/T {tmpYLow},$mProc.YLowRes
	Concatenate /NP/T {tmpYHigh},$mProc.YHighRes
End Function

Static Function /S GetForceName(mProc,highResYName)
	Struct ProcessStruct & mProc 
	String highResYName
	return ReplaceString(mProc.yHighResSuffix,highResYName,mProc.ForceSuffix)
End Function

Static Function /S GetSepName(mProc,highResXName)
	Struct ProcessStruct & mProc 
	String highResXName
	return ReplaceString(mProc.xHighResSuffix,highResXName,mProc.SepSuffix)
End Function
