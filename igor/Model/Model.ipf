#pragma rtGlobals=3	
#pragma ModuleName = ModModel

#include "..\Util\ErrorUtil"
#include "..\Model\ModelDefines"
#include "..\Util\GlobalObject"
#include "..\Util\StatUtil"
#include ".\PreProcess"

// Model Object
Structure ModelObject
	Struct ParamObj mParams
	// A description of the model
	String ModelDescription
	// All the functions used
	Struct ModelFunctions funcs
	String ModelName
	// The recquired X and Y suffixes
	String mXSuffix
	String mYSuffix
	// hasPreProc: Is there Pre-processing comonent of the model
	Variable hasPreProc
	// The model object (guarenteed non null, if 'hasPreProc' is true)
	Struct ProcessStruct mProc
	// The base directory of the Pre-processor.
	String PreProcBaseDir
	// Initial Plot Type
	char mPlotType
EndStructure

Static Function HasPreprocessor(mObj)
	Struct ModelObject & mObj
	return mObj.hasPreProc
End Function

Static Function GetProProc(mObj,mProc)
	Struct ModelObject & mObj
	Struct ProcessStruct & mProc
  	// XXX check we have a pre-processor?
  	mProc = mObj.mProc
End Function

// Function to get the folder name for this model
Static Function /S GetFolderName(mObj,prefix)
	Struct ModelObject & mObj
	String prefix
	return prefix + mObj.ModelName
End Function


Function InitModelGen(ToInit,name,funcs,Description,xSuff,ySuff,[mPreProc,mPlotType])
	// Initialize a model. Does *not* initizlize the parameters
	Struct ModelObject &toInit
	String Description, name,xSuff,ySuff
	Struct ModelFunctions & funcs
	Struct ProcessStruct &mPreProc
	Variable mPlotType
	mPlotType = ParamIsDefault(mPlotType) ? PLOT_TYPE_X_VS_SEP : mPlotType
	// Start off with 0 parameters
	toInit.mParams.NParams = 0
	toInit.funcs = funcs
	toInit.ModelDescription = Description
	toInit.ModelName = name
	toInit.mXSuffix = xSuff
	toInit.mYSuffix = ySuff
	// Determine if we have a pre-processing structure.
	if (ParamIsDefault(mPreProc))
		toInit.hasPreProc = ModDefine#False()
	else
		toInit.hasPreProc = ModDefine#True()
		toInit.mProc = mPreProc
	EndIf
	ToInit.mPlotType = mPlotType
End Function

Static Function /Wave CreatePreProcWave(ModelToAddTo)
	Struct ModelObject &ModelToAddTo
	Variable n = ModelToAddTo.mParams.NParams
	Make/O/N=(n) toRet
	toRet[0,n-1] = ModelToAddTo.mParams.isPreProc[p]
	return toRet
End Function

Function AddParameter(ModelToAddTo,param)
	Struct ModelObject &ModelToAddTo
	Struct Parameter &param
	// Get the current Index
	Variable i = ModelToAddTo.mParams.NParams
	// Ensure that we aren't full. If we are full, we shouldn't be adding
	String mErrStr
	sprintf mErrStr,"Only %d Parameters allowed in Model", MAX_MOD_PARAMS
	ModErrorUtil#AssertLT(i,MAX_MOD_PARAMS,errorDescr=mErrStr)
	// POST: should be good to go, add the next parameter
	ModelToAddTo.mParams.params[i] = param
	ModelToAddTo.mParams.NParams += 1
	// save whether this parameter is one we can pre-preprocess
	ModelToAddTo.mParams.isPreProc[i] = param.isPreProc
	if (param.isPreProc)
		// record the number and add one to the pre-precessing 
		if (!ModelToAddTo.hasPreProc)
			ModErrorUtil#DevelopmentError(description="Inconsistent definitions for the parameters (preproc) and model (no preproc)\r")
		Endif
		// POST: the model knows about the pre-processing.
		// We need to record the parameter numbers in the pre-processing object
		// (which is later saved)
		Variable idxIntoPreProc = 	ModelToAddTo.mProc.NPreProcParams
		ModelToAddTo.mProc.paramIdx[idxIntoPreProc] = i
		ModelToAddTo.mProc.NPreProcParams += 1
	EndIf
End Function

Function AddParameterFull(ModelToAddTo,newType,newPref,newUnit,HelpText,name,[repeatable,preproc])
	Struct ModelObject &ModelToAddTo
	// repeatable: can this parameter be repeated multiple time, independently?
	// Defaults to false
	Variable  newType ,repeatable,preproc
	Struct Prefix &newPref
	Struct Unit &newUnit
	String HelpText,name
	Struct Parameter param
	repeatable = (ParamIsDefault(repeatable)) ? ModDefine#False(): repeatable
	preproc = (ParamIsDefault(preproc)) ? ModDefine#False(): preproc
	// The number of parameters currently set can be the ID
	Variable id = ModelToAddTo.mParams.NParams
	// We start off with 0 repeats; this is the first
	Variable mRepNum = 0
	ModModelDefines#InitParameter(param,newType,newPref,newUnit,HelpText,name,id,repeatable,mRepNum,preproc)
	// Add the parameter to the model
	AddParameter(ModelToAddTo,param)
End Function
