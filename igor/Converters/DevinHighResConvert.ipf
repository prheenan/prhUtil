// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModDevinHighResConvert
#include "::Util:CypherUtil"
#include "::Util:IoUtil"
#include "::Util:Defines"

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
StrConstant DEFLV_HIGH_RES_SUFFIX =  "DeflV_Towd"

// A function which returns the recquired extensions for making the higher-resolution wave
Static Function /Wave CreateRecquiredExtensions()
	Make /O/T toRet = {ZSNSR_APPROACH,ZSNSR_DWELL,ZSNSR_RET,DEFL_LOW_RES_SUFFIX_APPROACH, DEFL_LOW_RES_SUFFIX_DWELL, DEFL_LOW_RES_SUFFIX_RET  }
	return toRet
End Function


Static Function /S GetLowResStem(mWaveStem)
	String mWaveStem
	String mNum
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
	return mLowResStem
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

// Checks that all the appropriate pieces of the wave (high and low res) exist for a given stem.
// The stem is assumed to be the *high res* stem (ie: if N and N+1 are low and high res, it is N+1)
Static Function AllWavesExistForStem(mWaveStem,[mExt])
	Wave /T mExt
	String mWaveStem
	if (ParamIsDefault(mExt))
		Wave /T mExt = CreateRecquiredExtensions()
	EndIf
	String mFile = ModIoUtil#GetFileName(mWaveStem)
	String mNum
	// XXX check that this matches (*really* need a generic method to do this for us)
	// Find the number of this wave
	Variable j,nExt=DimSize(mExt,0)
	Variable allExist = ModDefine#True()
	String mLowResStem = ModDevinHighResConvert#GetLowResStem(mWaveStem)
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
	if (allExist)
		// Check that the high-resolution time wave also exists, and is above the minimum size.
		Wave mHighY = $(mWaveStem+ DEFLV_HIGH_RES_SUFFIX)
		// For the NUG2 model, we have 5MHZ data, so the high bandwidth files
		// (what we are looking for) should be very large.
		if (!WaveExists(mHighY))
			allExist=ModDefine#False()
		endIf
		// POST: high wave exists. 
		// ... but is it the right size?
		if (DimSize(mHighY,0) < MinSize)
			allExist=ModDefine#False()
		EndIf
	EndIf
	return allExist
End Function

// Given a stem, gets the relevant stems for the low and high resolution X and Y 
// Note: if create is true, creates the (low res) zsnsr and deflv waves in the folders. strings are pass by reference.
Static Function GetRelevantStems(mWaveStem,createLowRes,fullZsnsrLow, fullZsnsrHigh,fullDeflLow,fullDeflHigh)
	Variable createLowRes
	String mWaveStem
	String &fullZsnsrLow, &fullDeflLow,&fullDeflHigh, &fullZsnsrHigh
	String mLowResStem = GetLowResStem(mWaveStem)
	// create all the strings (by reference)
	fullZsnsrLow = mWaveStem + ZSNSR_FULL_LOWRES
	fullDeflLow = mWaveStem + DEFLV_LOW_RES_SUFFIX_FULL
	// High deflection and Zsnsr are in the normal  folder (mWaveStem)
	fullDeflHigh = mWaveStem + DEFLV_HIGH_RES_SUFFIX			
	fullZsnsrHigh = mWaveStem + ZSNSR_FULL_HIGHRES
	// Create the lower resolutuon waves, if we need them
	if (createLowRes)
		ModDevinHighResConvert#CreateLowResDeflVFromDefl(mLowResStem,fullDeflLow)
		ModDevinHighResConvert#CreateLowResZSnsr(mLowResStem,fullZsnsrLow)
	EndIf
End Function

// Creates the high and low resolution waves, given a 'stem' (see 'GetLowResStem' for description of stem)
// Gives the names of the created waves, returns false if it couldn't find anything.
Static Function CreateZsnsrAndDefl(mWaveStem,fullZsnsrLow, fullZsnsrHigh,fullDeflLow,fullDeflHigh)
	String mWaveStem
	String & fullZsnsrLow, &fullDeflLow, &fullDeflHigh, &fullZsnsrHigh
	// If the wave exists, go ahead and create the various resolutions...
	Variable toRet = ModDefine#False()
	if (ModDevinHighResConvert#AllWavesExistForStem(mWaveStem))
		// then (true) create the low and high resolution waves as needed.
		GetRelevantStems(mWaveStem,ModDefine#True(),fullZsnsrLow, fullZsnsrHigh,fullDeflLow,fullDeflHigh)
		toRet = ModDefine#True()
	EndIf
	return toRet
End Function

Static Function Main()

End Function