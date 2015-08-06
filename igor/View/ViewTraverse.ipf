// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#include ".:ViewGlobal"
#include ".:ViewUtil"
#include "..:Util:DataStructures"

#pragma ModuleName =ModViewTraverse
// 
// Below is a debugging suite for traversing all the data
// We have a special struct for traversing the folder
// Essentially, this allows for easy 'maintenance'
// of all the data
//

// Prototype function for acting on a single folder
Function TraverseFolder(folderName,mObj)
	String folderName
	Struct TraverseObj &mObj
End Function

Structure TraverseFuncs
	FuncRef TraverseFolder TopSaveDir
	FuncRef TraverseFolder ExperimentDir
	FuncRef TraverseFolder SingleTraceDir
EndStructure

Structure TraverseObj
	// 'g' is used at your own peril. only
	// the fields of traverseObject are guarenteed to be correct.
	// E.g. "mModel" is the current model
	// 'mExp' is the current experiment
	Struct TraverseFuncs funcs
	// this global object should *not* be assumed unchanged after using
	// a traverse
	Struct ViewGlobalDat global
EndStructure	

// Default functions for traversing
Static Function DefTopSaveDir(folderName,mObj)
	String folderName
	Struct TraverseObj &mObj
End Function

Static Function DefExperimentDir(folderName,mObj)
	String folderName
	Struct TraverseObj &mObj
End Function

Static Function DefSingleTraceDir(folderName,mObj)
	String folderName
	Struct TraverseObj &mObj
	// Update the file save information
	// XXX check that the meta file exists
	ModViewGlobal#UpdateFileSaveInfo(mObj.global)
	// XXX TODO: Save the waves we are interested in looking at
End Function

Static Function InitDefTraverseObj(mObj,toInit)
	Struct ViewGlobalDat &mObj
	Struct TraverseObj &toInit
	// Set up all the needed functions
	FuncRef TraverseFolder toInit.funcs.TopSaveDir = DefTopSaveDir
	FuncRef TraverseFolder toInit.funcs.ExperimentDir=DefExperimentDir
	FuncRef TraverseFolder toInit.funcs.SingleTraceDir = DefSingleTraceDir
	// Set up the global data
	// XXX: make it just the model name?
	toInit.global = mObj
End Function

Static Function TraverseSingleTraceFolder(Folder,mObj)
	String Folder
	Struct TraverseObj & mObj
	// Traverses the folder associated with a single trace
	mObj.funcs.SingleTraceDir(Folder,mObj)
End Function

Static Function TraverseExperimentFolder(Folder,mObj)
	String Folder
	Struct TraverseObj & mObj
	// Traverses the folder associated with a single experiment
	// Pre: assumes folder follows  the conventions fo storing 
	// a single experiment
	// Act on this folder
	// XXX ensure the folder is correct / what we think it is?
	mObj.funcs.ExperimentDir(Folder,mObj)
	// Get the traces assoiated with this experiment
	Make /O/N=0/T mTraces
	ModIoUtil#GetDataFolders(Folder,mTraces)
	Variable nItems = DimSize(mTraces,0)
	Variable i=0
	String tmpFolder
	for (i=0; i< nItems;  i+= 1)
		// Get the name of the single trace
		tmpFolder = ModioUtil#AppendedPath(Folder,mTraces[i])
		// XXX TODO this is broken, tmpFolder has the suffix
		// Just remove the suffix?
		mObj.global.CurrentTracePathStub=tmpFolder
		// XXX TODO kludge for x trace: assume just replace Force with Sep
		mObj.global.CurrentXPath= ReplaceString("Force",tmpFolder,"Sep")
		TraverseSingleTraceFolder(tmpFolder,mObj)
	EndFor
	// kill the local wave created here.
	KillWaves /Z Traces
End Function

Static Function TraverseSaveDataFolder(Folder,mObj)
	// This is essentially a utility function
	// Assumes that the "VIEW_MARKTRACES" folder (see ViewGloal)
	// Exists one below this folder.
	String Folder
	Struct TraverseObj & mObj
	Variable nFolders
	if (DataFolderExists(Folder))
		// Then determine if it is truly a save data folder
		nFolders = ModIoUtil#CountDataFolders(Folder)
	else
		// XXX throw error; this isn't a real folder
		nFolders = -1
		return ModDefine#False()
	EndIf	
	// POST: folder exists. Check that it has a subfolder
	// with the appropriate name for traces
	String traceSave = ModViewGlobal#TraceSavingFolder(Folder)
	if (DataFolderExists(traceSave))
		// shouldExists is the proper trace saving folder. 
		// folder (superificially) has the correct structure.
	else
		// XXX Throw error;  subsfolder structure isn't here.
		return ModDefine#False()
	EndIf
	// POST: shoudExist is a real folder, the start of the data traces.
	// Use the user-defined function on this folder.
	mObj.funcs.TopSaveDir(folder,mObj)
	// Get the experiments rooted here. Initialize to size 0.
	Make /O/T/N=0 experiments
	ModViewGlobal#GetExperimentNames(traceSave,experiments)
	// POST: topop has an element for each experiment
	Variable i=0, nExp = DimSize(experiments,0)
	String expPath = ""
	String expName
	for (i=0; i<nExp; i+=1)
		// Get the path to this specific experiment
		expName = experiments[i]
		mObj.global.CurrentExpName = expName
		expPath= ModIoUtil#appendedPath(traceSave,expName)
		TraverseExperimentFolder(expPath,mObj)
 		// Give the path to the next function down
	EndFor
	// XXX kill waves created.
	KillWaves /Z experiments
End Function

