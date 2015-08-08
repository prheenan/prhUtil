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

StrConstant TIME_HIGH_RES_SUFFIX = "Time_Towd"
StrConstant DEFLV_HIGH_RES_SUFFIX =  "DeflV_Towd"
// See: Inteperpolate Help.ihf
// you can find this by clicking interpolate --> Help --> Done, then searching
// for interpolate2 in the help menu (on a MAC, Igor 6.37, 7/23/2015, size 12 shoe)
Constant INTERPOLATE2_LINEAR = 1
// Window for saving ruptures. Units of high bandwidth. e.g. if 5MHz, then N/5MHz is the amount of time saved
Constant DEF_NUG2_WINDOW = 400
// Indices for the ruptures
Constant RUPTURE_OFFSET_0 = 4
Constant RUPTURE_IDX_0 = 5
Constant RUPTURE_IDX_1 = 7
Constant RUPTURE_IDX_2 = 9
Constant RUPTURE_IDX_3 = 11
Constant RUPTURE_IDX_FINAL = 13

// Generalize: Method to ask for recquired waves (for full extension), method to get full extension, assuming they exist
// Low Resolution Extensions
StrConstant ZSNSR_APPROACH = "ZSnsr_Ext"
StrConstant ZSNSR_DWELL = "ZSnsr_Towd"
StrConstant ZSNSR_RET = "ZSnsr_Ret"
StrConstant ZSNSR_FULL_LOWRES = "Full_ZSnsr"
StrConstant ZSNSR_FULL_HIGHRES = "Hi_ZSnsr"
StrConstant DEFL_LOW_RES_SUFFIX_APPROACH = "Defl_Ext"
StrConstant DEFL_LOW_RES_SUFFIX_DWELL = "Defl_Towd"
StrConstant DEFL_LOW_RES_SUFFIX_RET = "Defl_Ret"
// Full *deflection in volts*
StrConstant DEFLV_LOW_RES_SUFFIX_FULL = "Full_DeflV"
// High resolution extension (version)
StrConstant ZSNSR_INTERP = "ZSnsr_Interp"
// Struct used to keep track of the low and high resolution versions of the 
//  X and Y values during pre-processing
// Indices for the 5 ruptures


// A function which returns the recquired extensions for making the higher-resolution wave
Static Function /Wave CreateRecquiredExtensions()
	Make /O/T toRet = {ZSNSR_APPROACH,ZSNSR_DWELL,ZSNSR_RET,DEFL_LOW_RES_SUFFIX_APPROACH, DEFL_LOW_RES_SUFFIX_DWELL, DEFL_LOW_RES_SUFFIX_RET  }
	return toRet
End Function

Static Function CreateGen(stemName,outName,approach,dwell,ext)
	String outName
	String stemName,approach,dwell,ext
	Concatenate /O/NP {$(stemName+approach),$(stemName+dwell),$(stemName+ext)},$outName
End Function

Static Function CreateLowResDeflVFromDefl(stemName,outName)
	String stemName,outName
	String tmpName = outName + "tmp"
	CreateGen(stemName,tmpNAme,DEFL_LOW_RES_SUFFIX_APPROACH,DEFL_LOW_RES_SUFFIX_DWELL,DEFL_LOW_RES_SUFFIX_RET)	
	// Convert to deflV
	Wave mInWave = $tmpName
	Variable n=DImSize(mInWave,0)
	MAke /O/N=(n) $outName
	Wave mOut = $outName
	Variable InType = MOD_Y_TYPE_DEFL_METERS
	Variable OutType = MOD_Y_TYPE_DEFL_VOLTS
	ModCypherUtil#ConvertY(mInWave,InType,mOut,OutType)
	KillWaves mInWave
End Function

// A function which created the low resolution wave from an input stem
Static Function CreateLowResZSnsr(stemName,outName)
	// PRE: all the waves recquired exist
	// Check that the lower resolution files we need exist
	String outName, stemName
	CreateGen(stemName,outName,ZSNSR_APPROACH,ZSNSR_DWELL,ZSNSR_RET)
End Function

// InWave is the wave of paths to the wave stems we are interested in
// OutWave is the wave we will populated with the new, processed waves,
// possibly created here
Function GetInputNamesNUG2(InWave,mProc)
	Wave /T InWave
	Struct ProcessStruct & mProc
	Variable n = DimSize(InWave,0)
	Variable i=0
	// XXX need to figure out how many leading zeros
	for (i=0; i<n; i+=1)
		String mWaveStem = InWave[i]
		String mFile = ModIoUtil#GetFileName(mWaveStem)
		String mNum
		// XXX check that this matches (*really* need a generic method to do this for us)
		// Find the number of this wave
		SplitString /E=(DEFAULT_ASYLUM_FILENUM_REGEX) mWaveStem,mNum
		// Find where the number happens, since we assume it does
		Variable numLoc = ModIoUtil#GetLastIndex(mWaveStem,mNum)
		// Get the 'template': anything before the number. E.g. 
		//   root:Packages:View_NUG2:Data:Data_AzideB1:Image2452 -- >  root:Packages:View_NUG2:Data:Data_AzideB1:Image
		String mTemplate = mWaveStem[0,numLoc-1]
		Variable numberID = str2num(mNum)
		// POST: have the template and the number for this ID
		// In order to get a high time resolution version of the wave, we need
		// to find the slow version. For file "foo:bar:ImageX", the slow version is
		// "foo:bar:Image(X-1)". For example :
		// if     root:Packages:View_NUG2:Data:Data_AzideB1:Image2401DeflV is the fast version
		// then root:Packages:View_NUG2:Data:Data_AzideB1:Image2400Defl is the slow version
		// Check if the files with the necessary suffixes exist
		// Put together the low resolution file stem. E.g.: foo:bar:Image(X-1)
		String mLowResStem = mTemplate + ModCypherUtil#ReturnAsylumID(numberID-1)
		Wave /T mExt = CreateRecquiredExtensions()
		Variable j,nExt=DimSize(mExt,0)
		Variable allExist = ModDefine#True()
		Variable MinSize = 5e5 // we need at least half a million points for the high-resolution data (total: 11 million, but in separate pieces)
		// ensure all the needed waves exist
		String mWave
		for (j=0; j<nExt; j+=1)
			mWave = mLowResStem + mExt[j]
			if (!WaveExists($mWave))
				allExist=ModDefine#False()
				break
			EndIf
		EndFor
		// POST: all the low resolution waves exists is allExist is true.
		// How about the high resolution
		if (!allExist)
			continue
		else
			// Check that the high-resolution time wave also exists, and is above the minimum size.
			Wave mHighY = $(mWaveStem+ DEFLV_HIGH_RES_SUFFIX)
			// For the NUG2 model, we have 5MHZ data, so the high bandwidth files
			// (what we are looking for) should be very large.
			if (!WaveExists(mHighY))
				allExist=ModDefine#False()
				break
			endIf
			// POST: high wave exists. 
			// ... but is it the right size?
			if (DimSize(mHighY,0) < MinSize)
				allExist=ModDefine#False()
				break
			EndIf
			// POST: both low and high resolution waves (seem to) exist
			// XXX check for ZSNSR?
			// /D: double
			// Low resolution 
			// Note: we are saving these all as  the high-resolution stem, to avoid confusion later on
			String fullZsnsrLow = mWaveStem + ZSNSR_FULL_LOWRES
			String fullDeflLow = mWaveStem + DEFLV_LOW_RES_SUFFIX_FULL
			// Create the 'full' low resolution waves we need (including approach)
			CreateLowResDeflVFromDefl(mLowResStem,fullDeflLow)
			CreateLowResZSnsr(mLowResStem,fullZsnsrLow)
			// High deflection and Zsnsr are in the normal  folder (mWaveStem)
			String fullDeflHigh = mWaveStem + DEFLV_HIGH_RES_SUFFIX			
			String fullZsnsrHigh = mWaveStem + ZSNSR_FULL_HIGHRES
			Duplicate /O $fullDeflHigh,$fullZsnsrHigh
			ModPreprocess#AddStringToWaves(mProc,fullZsnsrLow,fullZsnsrHigh,fullDeflLow,fullDeflHigh)
		Endif
	EndFor
	// Set the suffixes we used
	mProc.xLowResSuffix = ZSNSR_FULL_LOWRES
	mProc.xHighResSuffix= ZSNSR_FULL_HIGHRES
	mProc.yLowResSuffix = DEFLV_LOW_RES_SUFFIX_FULL
	mProc.yHighResSuffix= DEFLV_HIGH_RES_SUFFIX
End Function

// Save the four ruptures and the final rupture of a given wave
Function SaveRupture(srcWave,ruptureIdx,offsetIdx,mStruct,[windowAround])
	Wave ruptureIdx,offsetIdx,srcWave
	Struct ViewModelStruct & mStruct
	Variable windowAround
	String mFolder = mStruct.modelBaseOutputFolder
	windowAround = ParamIsDefault(windowAround) ? DEF_NUG2_WINDOW : windowAround
	Variable nRupt = DimSize(ruptureIdx,0)
	Variable nPointsPerRupt = WindowAround*2
	// Add an underscore to prevent evil name conflicts
	// XXX fix? Just use uniquename?
	String mWaveName = NameOfWave(srcWave) + "_"
	Make /O/N=(nPointsPerRupt,nRupt) $mWaveName
	Wave /D allRupt = $mWaveName
	Variable i
	For (i=0; i<nRupt; i+=1)
		Variable mIdxRupt = ruptureIdx[i]
		Variable mIdxOff = offsetIdx[i] // XXX work this in later. may need variable sizes...
		Duplicate /O/R=[mIdxRupt-WindowAround,mIdxRupt+WindowAround-1] srcWave tmpSaveRupt
		allRupt[0,nPointsPerRupt-1][i] = tmpSaveRupt[p]
	EndFor
	// relative to the start of the slice, where is the end of the rupture (ie: the offset for the next WLC)
	offsetIdx -= ruptureIdx
	offsetIdx += WindowAround
	Make /O/N=(1,nRupt) mRuptIdxToFile
	mRuptIdxToFile[][] = WindowAround 
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

Function InitNUG2Model(ToInit)
	Struct ModelObject & ToInit
	Struct Global GlobalDef
	ModGlobal#InitGlobalObj(GlobalDef)
	// Create the functions this object will use
	Struct ModelFunctions mFuncs
	ModModelDefines#InitModelFunctions(mFuncs,NUG2Fit)
	FuncRef ProtoGetInputNames mGetWaves = GetInputNamesNUG2
	Struct ProcessStruct mProc
	// make a path, just for this file.
	String mName = "NUG2"
	// Get the directory for the view
	ModPreprocess#InitProcStruct(mProc,mName,mGetWaves)	
	// Actually add the functions, parameters, and description to the model object
	// initialize our model-specific pre-processing
	// Note: this model cares about plotting versus *time*, to get the rupture force (after pre-processing)
	InitModelGen(ToInit,mName,mFuncs,"DNA WLC And Overstretching Fitter",TIME_HIGH_RES_SUFFIX,DEFLV_HIGH_RES_SUFFIX,mPreProc=mProc,mPlotType=PLOT_TYPE_X_VS_TIME)
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
