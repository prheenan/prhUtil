// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#include "::Model:ModelDefines"
#include "::Model:Model"
#include "::Util:CypherUtil"
#include ":ViewUtil"
#include "::MVC_Common:MvcDefines"
#include "::Util:DataStructures"
#include"::Model:PreProcess"
#include "::Util:IoUtil"
#include "::Util:PlotUtil"

#pragma ModuleName = ModViewGlobal
//Data folder under base to import all of the experiments
StrConstant VIEW_IMPORT_DATA = "Data"
// Data Folder under base To save 'marked' traces into
StrConstant VIEW_MARKTRACES = "MarkedCurves"
// Data Folder under single trace to save parameters, within <VIEW_BASEFOLDER>:<EXP_NAME>:<thisVar>
StrConstant VIEW_PARAMFOLDER = "ModelParams"
// Ibid, but for saving a local copy of the data
StrConstant VIEW_DATACOPY = "DataCopy"
StrConstant VIEW_CONTROLWAVE = "ViewCtrl"
// Plot Name
StrConstant VIEW_PLOTNAME = "MainPlot"
// The name of the 'meta' information at each trace
StrConstant VIEW_META_TRACE = "META"
// The name of the 'meta' information at each experiment
StrConstant VIEW_META_EXP = "META_EXP"
// The name of the 'meta' information at each data savefolder
StrConstant VIEW_META_SAVE = "META_G"
// The Sql Subfolder underneath a trace
StrConstant VIEW_SQL_SAVE = "SqlInf"
// undernead SqlInf, have SqlIds
StrConstant VIEW_SQL_ID_WAVE ="SqlIds"
// Wave Names
StrConstant VIEW_GLOBALWAVE = "ViewGlobal" // where the gboall wave representation lives
StrConstant VIEW_AllPATHSWAVE = "ViewPath" // where the wave with full paths exists
StrConstant VIEW_USERPATHSWAVE = "ViewUser" // whehre the wave with userfiends paths exists
StrConstant VIEW_SELECTEDWAVE = "ViewSel"
// The PreProcessor
StrConstant VIEW_PREPROC = "ViewPreProc"
// The experiment names
StrConstant VIEW_EXPNAMES = "ViewExpNames"
// the source file names
StrConstant VIEW_EXPSRC = "ViewExpSrc"
// Name of the wave having all of the functions needed to call things.
StrConstant VIEW_MODFUNCWAVE = "ModFun"
// Temporary plotting name 
StrConstant PLOT_X_TMPWAVE = "ViewTmpPlotX"
StrConstant PLOT_Y_TMPWAVE = "ViewTmpPlotY"
// Used for debugging / maintenance. 16 bits, described elsewhere
// TODO: right now, just single bit
Constant FORCE_UPDATE_BITS = 0xffff
// Structure used by structput / struct get to save information
// Between the various widgets. Essentially a file-wide variable
Constant VIEW_STRUCT_STRLEN_LONG = 220
Constant VIEW_STRUCT_STRLEN_SHORT = 25
// Structures for saving 'meta' data about what information is saved
Constant MAX_NUM_PARAMS = 50
// Views are disables when enable = 2 
Constant VIEW_DISABLE =2


Structure ViewGlobalDat
	// The Data Folder (path name) for this view
	char DataFolder[VIEW_STRUCT_STRLEN_LONG]
	// The Window Name For the View
	char WindowName[VIEW_STRUCT_STRLEN_SHORT]
	// The name of the plot
	char PlotName[VIEW_STRUCT_STRLEN_SHORT]
	// The current data directory
	char DataDir[VIEW_STRUCT_STRLEN_LONG]
	// The name of the file currently loaded (ie: how did we populate data directory?)
	// Also the name of the subdirectory of the experiment under 'dataDir'
	char ExpFileName[VIEW_STRUCT_STRLEN_LONG] // XXX rename to ExpName
	// The current regex for determining if something is a wave or not
	char RegexWave[VIEW_STRUCT_STRLEN_SHORT]
	// The regex for determining the experiment name
	char RegexExpN[VIEW_STRUCT_STRLEN_SHORT]
	// The name of the current trace on the plot (should be "PLOT_Y_TMPWAVE", probably)
	char PlotTraceName[VIEW_STRUCT_STRLEN_SHORT]
	// The path to the currently displayed wave (e.g. "Fooo200Force")
	char CurrentTracePathStub[VIEW_STRUCT_STRLEN_LONG]
	// The path to the x value of the currently displayed wave (e.g. "Fooo200Sep")
	char CurrentXPath[VIEW_STRUCT_STRLEN_LONG]
	// The path to the text wave listing every valid wave file
	char AllFileWaveStr[VIEW_STRUCT_STRLEN_SHORT]
	// The path to the text wave listing the 'user friendly' file names
	char UserFileWaveStr[VIEW_STRUCT_STRLEN_SHORT]
	// The path to the wave listing 'selwave' for the listbox commands.
	char SelWaveStr[VIEW_STRUCT_STRLEN_SHORT]
	// The suffix for the Force Plot (ie: Force)
	char SuffixForcePlot[VIEW_STRUCT_STRLEN_SHORT]
	// The suffix for the Sep Plot (ie: Sep)
	char SuffixSepPlot[VIEW_STRUCT_STRLEN_SHORT]
	// Below, the recquired X and Y suffixes for *input*. This could be anything.
	// For example, for high-resolution waves, "Time_Towd' might be the X, and "DeflV_Towd"
	// NOte that the model preprocesses these to be force and sep
	char SuffixXPlot[VIEW_STRUCT_STRLEN_SHORT]
	char SuffixYPlot[VIEW_STRUCT_STRLEN_SHORT]
	// The wave with the (model) function names to call
	char ModelFunctionHook[VIEW_STRUCT_STRLEN_SHORT]
	// The Regex to find the experiment
	char RegexExp[VIEW_STRUCT_STRLEN_SHORT]
	// The number of selected waves. Shouldn't be more than 4 million, I imagine
	uint32 NSelected
	// The number of parameters to set for the model (not including pre-processing)
	uint32 NParamSet
	// The ID of the currently selected parameter
	uint32 SelectedParamID
	// TODO: force update of the parameters
	char ForceUpdate
	// The current experiment used
	char CurrentExpName[VIEW_STRUCT_STRLEN_SHORT]
	// The name of the current model used
	char ModelName[VIEW_STRUCT_STRLEN_SHORT]
	// The experiment names and source
	char AllExpNames[VIEW_STRUCT_STRLEN_SHORT]
	char AllExpSrc[VIEW_STRUCT_STRLEN_SHORT]
	// The name of the source experiment for this file
	char SourceFileName[VIEW_STRUCT_STRLEN_LONG]
	// The index into 'AllFileWaveStr' and 'UserFileWaveStr' of the
	// selected wave
	uint32 selectedWaveIdx
	// The directory where the cached files (tsv of time,sep,force) were saved
	char CachedSaveDir[VIEW_STRUCT_STRLEN_LONG]
	// The name of the current pre-processor
	char PreProcessWave[VIEW_STRUCT_STRLEN_LONG]
	// What to plot against (time, separation)
	char PlotXType 
	// Wave referencing which parameters to disable when we dont have a model.
	char ControlDisableWaves[VIEW_STRUCT_STRLEN_SHORT]
EndStructure

// This is the 'meta' info that we are iterested in for a single trace
Structure FileSaveInfo
	char XName[VIEW_STRUCT_STRLEN_LONG]
	char YName[VIEW_STRUCT_STRLEN_LONG]
	// 0 or 1 if defined / not defined. >= 1 if repeated XXX (add repetition support)
	uint16 ParamsDefined[MAX_NUM_PARAMS]
	// XXX add in version
	double DateTimeCreated
	double DateTimeUpdated
	char version
	// The 'short' experiment name which these files are associated to.
	// (e.g., the subfolder name 'X061515")
	char ExpName[VIEW_STRUCT_STRLEN_SHORT]
	// The maximum number of parameters for this model
	uchar MaxParams
	// The model used to generate this information
	char ModelName[VIEW_STRUCT_STRLEN_SHORT]
	// The name of the source experiment for this file
	char SourceFileName[VIEW_STRUCT_STRLEN_LONG]
	//  Has this curve been pre-processed or not?
	// XXX TODO: make this not a binary?
	char beenPreProcessed
EndStructure

// Saved Data Structure, meta data for a single experiment
Structure MetaExpData
	// The paths to all the waves from this experiment
	char AllWaveStubsName[VIEW_STRUCT_STRLEN_LONG]
	// The paths to all the *selected* waves from this experiment
	char SelWaveStubsName[VIEW_STRUCT_STRLEN_LONG]
	// Where all the data is coming from (the actual file name)
	char SourceFileName[VIEW_STRUCT_STRLEN_LONG]
	double DateTimeCreated
	double DateTimeUpdated
	// The total number of waves taken
	uint32 nWavesExp
	// The time the experiment was started
	double DatetimeExpStart
	// The name of the experiment (e.g. "X060031")
	char ExperimentName[VIEW_STRUCT_STRLEN_LONG]
EndStructure

Static Function InitViewGlobal(ToInit)
	// Initialize the 'static' variables
	// NOTE: this does *not* include the experiment and model; these are loaded dynamically.
	// Must initialize *after* the model has been set.
	Struct ViewGlobalDat &ToInit
	// NOthing selected initially
	ToInit.NSelected = 0
	// XXX use appended?
	ToInit.AllFileWaveStr = ModMvcDefines#GetRelToBase(VIEW_AllPATHSWAVE)
	ToInit.UserFileWaveStr =  ModMvcDefines#GetRelToBase(VIEW_USERPATHSWAVE)
	ToInit.ModelFunctionHook =  ModMvcDefines#GetRelToBase(VIEW_MODFUNCWAVE)
	ToInit.AllExpNames = ModMvcDefines#GetRelToBase(VIEW_EXPNAMES)
	ToInit.AllExpSrc =  ModMvcDefines#GetRelToBase(VIEW_EXPSRC)
	ToInit.SelWaveStr = ModMvcDefines#GetRelToBase(VIEW_SELECTEDWAVE)
	// Ensure that the data folder exists
	// Kill the waves, if they already exist:
	// /Z: Silent
	Killwaves /Z $(VIEW_AllPATHSWAVE),$(VIEW_USERPATHSWAVE),$(VIEW_MODFUNCWAVE)
	Killwaves /Z $(ToInit.AllFileWaveStr ),$(ToInit.UserFileWaveStr),$(ToInit.ModelFunctionHook)
	// do *not* kill the experiment and source files, since it is OK if they are already loaded.
	// Make the wave, so we never have a null pointer
	Make /T/O/N=0 $ToInit.AllFileWaveStr
	Make /T/O/N=0 $ToInit.UserFileWaveStr
	Make /T/O/N=0 $ToInit.ModelFunctionHook
	ModDataStruct#EnsureTextWaveExists(ToInit.AllExpNames)
	ModDataStruct#EnsureTextWaveExists(ToInit.AllExpSrc)
	//SelWave is *not* a string wave.
	Make /O/N=0 $ToInit.SelWaveStr
	// Ensure  the paths we need for saving traces actually exist
	ModIoUtil#EnsurePathExists(TraceSavingFolder(GetBaseDir(toInit)))
End Function

Static Function /S GetDataDir(mData)
	Struct ViewGlobalDat &mData
	return mData.DataDir
End Function

Static Function /S GetDataDirLoadGlobal()
	Struct ViewGlobalDat mData 
 	 ModViewGlobal#GetGlobalData(mData)
 	 return GetDataDir(mData)
End Function

Static Function /S GetExperimentDataDirStr(dataDir,expFileName)
	String dataDir,expFileName
	return ModIoUtil#AppendedPath(dataDir,expFileName)
End Function


Static Function /S GetExperimentDataDir(mData)
	Struct ViewGlobalDat &mData
	return GetExperimentDataDirStr(GetDataDir(mData),mData.ExpFileName)
End Function

Static Function ExperimentAlreadyLoaded(mData,experimentSource)
	Struct ViewGlobalDat &mData
	String experimentSource
	// is the source already in the source waves?
	Wave /T mSrc = $(mData.AllExpSrc)
	return ModDataStruct#TextInWave(experimentSource,mSrc)
End Function 

Static Function /S GetExperimentMetaName(mData)
	Struct ViewGlobalDat &mData
	String mPath = ModIoUtil#AppendedPath( GetExperimentFolder(mData),VIEW_META_EXP)
	return mPath
End Function

// XXX should totally remove this, but want to track its use.
Static Function SetExperimentUnsafe(ToAddTo,ExpName,SourceFile)
	Struct ViewGlobalDat &ToAddTo
	String ExpName,SourceFile
	// XXX eveentually use TextInWave, need to initiliaze experiments.
	ToAddTo.CurrentExpName = ExpName
	ToAddTo.ExpFileName = SourceFile
End Function

// PRE: AllFileWaveStr is updated (should usually be called in setWaveList)
Static Function UpdateSelWave(mData)
		Struct ViewGlobalDat & mData
		Variable nWaves = DimSize($mData.AllFileWaveStr,0)
		Wave tmpRef = $(mData.SelWaveStr)
		Redimension /N=(nWaves) tmpRef
		tmpRef[] = LISTBOX_SELWAVE_NOT_SELECTED 
End Function

Static Function SetWaveList(mData,NewWaveFullPath,NewWaveUserStub,Concat)
	Struct ViewGlobalDat & mData
	Wave /T NewWaveFullPath
	Wave /T NewWaveUserStub
	Variable Concat
	Wave /T fileWaves = $mData.AllFileWaveStr
	Wave /T userWaves = $mData.UserFileWaveStr
	if (!Concat)
		// just duplicate the results
		Duplicate /O/T NewWaveFullPath,fileWaves
		Duplicate /O/T NewWaveUserStub,userWaves
	Else
		// /NP: no promotion, keep it 1D
		Concatenate /NP/T {NewWaveFullPath},fileWaves
		Concatenate /NP/T {NewWaveUserStub},userWaves
	EndIf
	// POST: our waves are updated
	// Need to provide a selection wave for the elements
	UpdateSelWave(mData)
End Function

Static Function SetExperiment(ToAddTo,LoadedDataFolder,systemSrcFileName)
	// set the current experiment to 'name'
	Struct ViewGlobalDat &ToAddTo
	String LoadedDataFolder,systemSrcFileName
	// Get just the file name from the data folder path (ie: whatever is under the data directory/Igor Datafolder)
	ToAddTo.ExpFileName = ModIoUtil#GetFileName(LoadedDataFolder)
	// POST: we know the correct source.
	// Determine the root of this experiment
	String rootDir = ModViewGlobal#GetExperimentDataDir(ToAddTo)
	// Find the experiements here
	String experimentPath = rootDir
	String experiment = LoadedDataFolder
	// POST: experiment and experimentPath are set
	ToAddTo.CurrentExpName = experiment
	ToAddTo.SourceFileName= systemSrcFileName
	// Make sure the experimental folder exists, for saving parameters and the like
	String markedFolderForExp = GetExperimentFolder(ToAddTo)
	ModIoUtil#EnsurePathExists(markedFolderForExp)
	// If the experiment already exists, then don't bother loading anything
	// Get all the waves in this experiment we are interested in for this wave...
	Make /O/N=0/T allPathWave
	Make /O/N=0/T allUserWave
	// Try to find waves here
	Variable nTotalWaves = ModViewGlobal#GetUserAndPathWaves(ToAddTo,allUserWave,allPathWave,experimentPath)
	if (nTotalWaves == 0)
		// We didn't actually load anything. quit while we are ahead, before we screw up the state.
		String noWaves
		sprintf noWaves,"Couldn't load waves from file; are your X and Y file suffixes correct?\nFound no waves to load in file %s\n",systemSrcFileName
		ModErrorUtil#AlertUser(noWaves)
		// Kill the directories we just made, prevent switching.
		KillDataFolder /Z (markedFolderForExp)
		KillDataFolder /Z (experimentPath)
		return ModDefine#False()
	EndIf
	// POST: found at least one wave to load.
	// Concat is true: we want to add allPath and UserPath to the end
	SetWaveList(toAddTo,allPathWave,allUserWave,ModDefine#True())
	// If we *haven't* already loaded this experiment,  then we need to add its meta information
	if (!ExperimentAlreadyLoaded(ToAddTo,LoadedDataFolder))
		// we now just need to save a ('local') copy of the meta info for this (new) experiment
		// XXX TODO: add in support for writing to this when we update it, etc
		String metaName = GetExperimentMetaName(ToAddTo)
		Struct MetaExpData toSave
		// Get the wave names
		String expAllWaves = ModIoUtil#AppendedPath(markedFolderForExp,VIEW_AllPATHSWAVE)
		// Save a copy of all the relevant waves just found.
		Duplicate /O allPathWave,$(expAllWaves)
		// Add all the waves we just found
		toSave.AllWaveStubsName =expAllWaves
		toSave.SourceFileName = systemSrcFileName
		//  XXX check that there is at least one wave, we index 0 here
		// We *know* that the suffixyplot should be OK, since getuser and path waves 
		// checks for the suffixes.
		Wave firstPlot = $(allPathWave[0] + toAddTo.SuffixYPlot)
		toSave.DateTimeCreated = ModCypherUtil#GetTimeStampStart(firstPlot)
		toSave.DateTimeUpdated= DateTime
		// The total number of waves taken (unique stems)
		toSave.nWavesExp = nTotalWaves
		// Save out the data structure as a wave. (make sure there is a wave for it)
		Make /O/N=(0) $metaName
		StructPut /B=(ModDefine#StructFmt())  toSave, $metaName
		// POST: everything has been added, go ahead and save this experiment.
		// Push the experiment and source onto the list of known experiments
		// XXX probably a faster way to do this?
		Make /O/T newSrc = {systemSrcFileName }
		Make /O/T newExp = {experiment}
		// NP: keep dimension constant (no promotion)
		Concatenate /NP {newSrc},$(ToAddTo.AllExpSrc)
		Concatenate /NP {newExp},$(ToAddTo.AllExpNames)
	EndIf // end "did we find any waves"
	// Kill all the temporary waves we just made
	KillWaves /Z allUserWave,allPathWave,newSrc,newExp
End Function	

Static Function /S GetGlobalDatPath()
	return ModMvcDefines#GetRelToBase(VIEW_GLOBALWAVE)
End Function	

Static Function SetGlobalData(GlobalDat)
	// This function and the get function are used as a minor kludge to have a file-wide struct
	// This is preferable to serially acessing a bunch of global waves (which still exist)
	// because all the information is centralized.
	Struct ViewGlobalDat &GlobalDat
	// Make sure the wave we want exists
	String mPath = GetGlobalDatPath()
	if (!WaveExists($mPath))
		Make /O/N=0 $mPath
	EndIf
	StructPut /B=(ModDefine#StructFmt())  GlobalDat, $mPath
End Function

Static Function GetGlobalDataStr(GlobalDat,StrPathToWave)
	Struct ViewGlobalDat &GlobalDat
	String StrPathToWave
	StructGet /B=(ModDefine#StructFmt())  GlobalDat, $StrPathToWave
End Function

Static Function GetGlobalData(GlobalDat)
	// Note: Must call SetGlobalData Before	
	// XXX check this? WaveExists
	Struct ViewGlobalDat &GlobalDat
	GetGlobalDataStr(GlobalDat,GetGlobalDatPath())
End Function

Static Function SetViewFunctions(mData,FuncNames)
	// Updates mData with the view functions
	Struct  ViewGlobalDat &mData
	Wave /T FuncNames
	// Push the wave of functions into the global data
	Duplicate /O/T FuncNames,$(mData.ModelFunctionHook)
	// kill the temporary wave, now that we are done with it
End Function

Static Function GetViewFunctions(mData,ModelFunctions)
	Struct  ViewGlobalDat &mData
	Struct ModelFunctions & ModelFunctions
	// XXX add in some way of sanitizing input from model!
	// XXX unsafe currently (assuming tmp[0] is what we want)
	Wave /T tmp = $(mData.ModelFunctionHook)
	ModModelDefines#InitFuncObjFromWave(ModelFunctions,tmp)
End Function

Static Function /S GetBaseDir(mData)
	Struct ViewGlobalDat &mData
	return mData.DataFolder
End Function

Static Function /S GetExpFolder(mData)
	Struct ViewGlobalDat &mData
	return mData.CurrentExpName
End Function

Static Function /S TraceSavingFolder(mFolder)
	// mFolder is the base folder (e.g. root:Packages:WLC_View)
	String mFolder
	// Tack on where the traces should be saved
	String base = ModIoUtil#AppendedPath(mFolder,VIEW_MARKTRACES)
	return base
End Function

// Give a string for the experimental folder. not guarenteed to exist
Static Function /S GetExperimentFolderByString(mData,expFolder)
	Struct ViewGlobalDat &mData
	String expFolder
	String traceFolder = TraceSavingFolder(GetBaseDir(mData))
	// Add on the current experiment name
	 traceFolder = ModIoUtil#AppendedPath(traceFolder,expFolder)
	 return traceFolder
End Function

Static Function /S GetExperimentFolder(mData)
	Struct ViewGlobalDat &mData
	return GetExperimentFolderByString(mData,GetExpFolder(mData))
End Function

// given an experiment name and a full path to a trace, dives its data folder.
Static Function /S CurrentDataFolderByString(mData,expFolder,currentTraceFullPath)
	Struct ViewGlobalDat &mData
	String expFolder,currentTraceFullPath
	 // Get the file name of the current path. Assume we always want the force extension
 	String mGraphFolder = ModIoUtil#GetFileName(currentTraceFullPath)
 	// Get the current Experiment name
 	String mFolder = ModIoUtil#AppendedPath(expFolder,mGraphFolder)
 	return mFolder
End Function

Static Function /S CurrDataFolder(mData)
	Struct ViewGlobalDat &mData
	// Uses the information in the globlaDat struct to determine  the name
	// of the current folder for saving data For now, we assume it is "root:to:experiment:....:<PullName>"
	// Note that this is dependent on whatever is currently plotted.
	String mPath = mData.CurrentTracePathStub + mData.SuffixForcePlot
	String mFolder = CurrentDataFolderByString(mData,GetExperimentFolder(mData),mPath)
	return mFolder
End Function

Static Function SetViewModel(mData,mModel)
	Struct ViewGlobalDat &mData
	Struct ModelObject  &mModel
	mData.DataFolder =   ModMvcDefines#GetViewBase(mModel.ModelName)
	mData.ModelName= mModel.ModelName
	// Set the initial X axis according to the model
	mData.PlotXType = mModel.mPlotType
	// Initialize the data folder
	mData.DataDir = ModIoUtil#AppendedPath(mData.DataFolder,VIEW_IMPORT_DATA)
	ModIoUtil#EnsurePathExists(GetDataDir(mData))
	// Kill anything graph with our window name
	ModIOUtil#SafeKillWindow(mData.DataFolder)
	// XXX save original?
	String original =  ModIoUtil#cwd()
	// ensure that the path exists to our data folder
	String mPath = mData.DataFolder
	ModIoUtil#EnsurePathExists(mPath)
	// POST: the folder we want exists, go there
	SetDataFolder $mPath
	// Below, We initialize the global viewdata
	// Must be done *after* setting the data folder.
	ModViewGlobal#InitViewGlobal(mData)
End Function

// Set global options, independent of the model.
// Must *still* call setViewmodel. Note: this should only be called once,
// as it will kill the window
Static Function SetOptionsGlobalAndFolder(toInit)
	Struct ViewGlobalDat &ToInit
	toInit.WindowName = ModMvcDefines#GetViewWindowName()
	// Kill the window, if it already exists
	ModIoUtil#SafeKillWindow(toInit.WindowName)
	// The preprocessor needs to be saved in order to maintain state in an encapulated manner
	ToInit.PreProcessWave = ModMvcDefines#GetRelToBase(VIEW_PREPROC)
	ToInit.RegexExp = DEFAULT_REGEX_ASYLUM_EXP
	// Plot String doesnt need a path. Kill the window if it exists
	ToInit.PlotName = VIEW_PLOTNAME
	// XXX make this into a regex
	// If we should force an update of an exisiting metavariable
	ToInit.ForceUpdate = ModDefine#True()
	ToInit.SuffixForcePlot = ModCypherUtil#ForceSuffix()
	ToInit.SuffixSepPlot = ModCypherUtil#SepSuffix()
	// Make the list of model-independent controls to kill if we dont select a model.
	String mBaseDir = ModMvcDefines#GetRelToBase("")
	ModIoUtil#EnsurePathExists(mBaseDir)
	ToInit.ControlDisableWaves = ModMvcDefines#GetRelToBase(VIEW_CONTROLWAVE)
	Make /T/O/N=0 $ToInit.ControlDisableWaves 
End Function 

Static Function GetFileSaveInfo(mPath,toReadInto)
	String mPath
	Struct FileSaveInfo & toReadInto
	StructGet /B=(ModDefine#StructFmt())  toReadInto, $mPath
End Function

// Function to cal after everything has been pre-processed. Duplicates the wave appropriately
Static Function FileInfoPreProcessed(mData,mFIleSaveInfo,pathToSave,SepName,forceName)
	Struct ViewGlobalDat &mData
	Struct FileSaveInfo & mFIleSaveInfo
	String pathToSave,SepName,forceName
	SaveToCache(mData,SepName,ForceName,mFIleSaveInfo)
	// Write out the file save info
	SaveFileInfo(mFileSaveInfo,pathToSave)
End Function

Static Function /S GetFileSaveInfoPathStr(mFolder)
	String mFolder 
	// Add the meta file to the appropriate directory
	String toRet = ModIoUtil#AppendedPath(mFolder,VIEW_META_TRACE)
	return toRet
End Function

Static Function /S GetFileSaveInfoPath(mData)
	Struct ViewGlobalDat &mData
	return GetFileSaveInfoPathStr(CurrDataFolder(mData))
End Function

Static Function /S GetDataFolderLocalCache(currentTraceFolder)
	String currentTraceFolder
	return ModIoUtil#AppendedPath(currentTraceFolder,VIEW_DATACOPY)
End Function

// Fuction to save the Sep and Force to a local data cache
// Does *not* save the fileSaveInfo object -- caller must do that
Static Function SaveToCache(mData,Sep,Force,mFIleSaveInfo)
	Struct ViewGlobalDat &mData
	Struct FileSaveInfo & mFIleSaveInfo
	String Sep,Force
	// Get the folder to save a local copy of the data to.
	String currentTraceFolder = CurrDataFolder(mData)
	String mCache = GetDataFolderLocalCache(currentTraceFolder)
	// Make sure the cache directory exists
	ModIoUtil#EnsurePathExists(mCache)
	// Copy the waves into this folder
	String xName = ModIoUtil#GetFileName(Sep)
	String yName = ModIoUtil#GetFileName(Force)
	// Copy the waves into this local folder
	String xCache = ModIoUtil#AppendedPath(mCache,xName)
	String yCache = ModIoUtil#AppendedPath(mCache,yName)
	// Write the x and y data, assume we start with no parameters set
	mFIleSaveInfo.xName = Sep
	mFIleSaveInfo.yName = Force
	// /O flag overwrites
	// XXX throw error if we are overwriting? If this is really 
	// a first time writing, shouldn't have much
	// XXX assume x and y are the same size...
	Duplicate /O $Sep $xCache
	Duplicate /O $Force $yCache
	mFIleSaveInfo.beenPreProcessed=ModDefine#True()
End Function

Static Function WriteFileSaveInfo(mData,X,Y,boolSaveCache)
	// First time we write the file save info (ie: this curve is interesting)
	Struct ViewGlobalDat &mData
	String X,Y
	Variable boolSaveCache
	Struct FileSaveInfo toWrite
	// Get the folder to write out
	String mPath = GetFileSaveInfoPath(mData)
	// /O: Overwrite (or just write) whatever meta data is there already
	// XXX throw error if it is there?
	Make /O/N=0 $mPath
	// XXX add in version support?
	toWrite.version = 0
	toWrite.DateTimeCreated = DateTime
	toWrite.SourceFileName = mData.ExpFileName
	toWrite.ExpName = mData.CurrentExpName // write  the current experiment name
	if (boolSaveCache)	
		// then we have already been pre-processed.
		SaveToCache(mData,X,Y,toWrite)
	EndIf
	Variable i
	for (i=0; i< MAX_NUM_PARAMS; i+= 1)
		toWrite.ParamsDefined[i] = 0
	endFor
	SaveFileInfo(toWrite,mPath)
	// Update the structure accoring to the global view's experiment etc.
	// XXX somewhat inefficient, could probably refactor this method better
	UpdateFileSaveInfo(mData)
End Function

Static Function SaveFileInfo(mInfo,path)
	Struct FileSaveInfo & mInfo
	String path
	StructPut /B=(ModDefine#StructFmt())  mInfo, $path
End Function

Static Function UpdateFileSaveInfo(mData,[mParam])
	// update mPAram
	Struct ViewGlobalDat &mData
	Struct Parameter & mParam
	Struct FileSaveInfo toUpdate
	// Get the path to the meta data structure
	String mPath = GetFileSaveInfoPath(mData)
	// Get the old structure
	// XXX ensure this exists? All StructGets should probably be protected
	GetFileSaveInfo(mPath,toUpdate)
	// update the parameters accordingly
	// XXX add in support for repeated values
	if (!ParamIsDefault(mParam))
		// Write out the parameter info.
		toUpdate.ParamsDefined[mParam.ParameterNumber] = 1
	EndIf
	// Update the date time and current experiment
	toUpdate.DateTimeUpdated = DateTime
	toUpdate.MaxParams =mData.NParamSet // The maximum number of parameters for this model
	toUpdate.ModelName = mData.ModelName	// Write the parameter structure back
	SaveFileInfo(toUpdate,mPath)
End Function

Static Function CopyXYData(metaFileInfo)
	Struct FileSaveInfo &metaFileInfo
End Function

Static Function /S GetCurrentTraceParamPath(mFolder)
	String mFolder 
	// Get the path (datafolder) to the saved parameter, assuming it exists
	// XXX check existence
	// XXX user appended path
	String mSep = ModDefine#DefDirSep()
	return  (mFolder + mSep + VIEW_PARAMFOLDER  + mSep)
End Function

Static Function /S GetParameterPath(mData,mPar)
	// Get the parameter path
	// Can give a 'prototype' parameter, too.
	Struct ViewGlobalDat &mData 
	Struct Parameter & mPar	
	// Get the folder for this parameter
	String mFolder = ModViewGlobal#CurrDataFolder(mData)
	// Get where to save this parameter
	String paramPath = GetCurrentTraceParamPath(mFolder)
	// Get the fileName for this parameter
	String paramName = ModViewUtil#GetParamSaveName(mPar)
	String fullPath =paramPath + paramName
	return fullPath
End Function

Static Function IsPreProc(mData,mPar)
	Struct ViewGlobalDat &mData 
	Struct Parameter & mPar
	// Get the pre-processing object
	Struct ProcessStruct mProc
	LoadPreProcWave(mData,mProc)
	// return if this parametter is in its list, *and* if there are more than one parameters
	Variable n =  mProc.NpreProcParams
	if (n > 0)
		// Then we have something to check. make the wave with all the 'n' pre-processing indices
		Make /O/N=(n) mTmpPreProc
		mTmpPreproc[0,n-1] = mProc.paramIdx[p]
		Variable toRet =  ModIoUtil#InWave(mPar.ParameterNumber,mTmpPreproc)
		// Kill the ewave we made
		KillWaves /Z mTmpPreProc
		return toRet
	else
		return ModDefine#False()
	Endif
End Function

// Load the pre-processing struct, based on the data
Static Function LoadPreProcWave(mData,mProc)
	Struct ViewGlobalDat &mData 
	Struct ProcessStruct & mProc
	String mPreProcName = mData.PreProcessWave
	ModPreProcess#LoadPreProc(mProc,mPreProcName)
End Function

Static Function SavePreProcWave(mData,mProc)
	Struct ViewGlobalDat &mData 
	Struct ProcessStruct & mProc
	String SaveName = mData.PreProcessWave
	ModPreProcess#SavePreProc(mProc,SaveName)
End Function

Static Function FindPreProcIndexForStub(mProc,mStub)
	Struct processStruct &mProc 
	String mStub
	Variable mIndex
	Wave /T mStubsWave = $(mProc.YLowRes)
	String fullYLowRes = mStub + mProc.yLowResSuffix
	if (!ModDataStruct#TextInWave(fullYLowRes,mStubsWave,index=mIndex))
		String mErr
		sprintf mErr,"Couldn't find stub %s\r",mStub
		ModErrorUtil#DevelopmentError(description=mErr)
	EndIf
	return mIndex
End Function

// Function used for calculating offsets
Static Function GetYRefsForPreProc(mData,mStub,outputRefLow,outputRefHigh)
	Struct ViewGlobalDat &mData 
	String mStub
	String & outputRefLow
	String & outputRefHigh
	Struct processStruct mProc 
	LoadPreProcWave(mData,mProc)
	Variable mIndex = FindPreProcIndexForStub(mProc,mStub)
	// POST: have the index
	// Load the pre-processing object to get the name of the
	// Low Resolution Y Reference
	// Note: we *need* to ensure no problems when we 
	// are loading analyzed curvs, since (presummably) they wont
	// have the data loaded
	// Get a reference to the wave names
	Wave /T mLowRes = $(mProc.YLowRes)
	Wave /T mHighRes = $(mProc.YHighRes)
	// XXX check that index is in range?
	// Get the actual wave references we care about
	 outputRefLow = mLowRes[mIndex]
	 outputRefHigh = mHIghRes[mIndex]
End Function

Static Function AllPreProcMade(mData)
	Struct ViewGlobalDat &mData 
	Struct Parameter proto
	// Load the pre-processor
	Struct processStruct mProc 
	LoadPreProcWave(mData,mProc)
	Variable n = mProc.nPreProcParams
	// Loop through each of the parameters, make sure they exist
	Variable i, tmpPreProcIdx
	for (i=0; i<n; i+=1)
		// get the actual index associated with this parameter
		// note: paramIdx[i] stores the parameter number for preproc
		// parameter [i]
		tmpPreProcIdx = mProc.paramIdx[i]
		ModViewGlobal#GetParamProtoType(mData,proto,i)
		String mPath = GetParameterPath(mData,proto)
		// If the path to our parameter doesn't exist, then not all the pre-processing steps have been made
		if (!WaveExists($mPath))
			return ModDefine#False()
		Endif
	EndFor
	// POST: all the parameters are there
	return ModDefine#True()
End Function

Static Function GetExperimentNames(TraceSaveFolder,waveToPop)
	// Get the exeriments (subfolders) rooted under TraceSaveFolder
	// TraceSaveFolder should have something like "VIEW_MARKTRACES"
	// XXX add in case insensitive flag?
	String TraceSaveFolder
	Wave /T waveToPop
	if (!GrepString(TraceSaveFolder,VIEW_MARKTRACES))
		// XXX throw error; doesn't match the file strucure.
	EndIf
	// POST: folder matches the name
	ModIoUtil#GetDataFolders(TraceSaveFolder,waveToPop)
	// POST: waves has all the data folders (or experiments) under this folder
End Function

Static Function GetAllMarkedStubs(mData,UserStubs,PathToStubs)
	// mData is the global structure, assumed already initialized
	// PathToStubs and UserStubs are already initialized (but can be size zero)
	// waves of the full path and user path, respectively.
	// Finds all the paths, places them in the waves passed to it.
	Struct ViewGlobalDat &mData
	Wave /T UserStubs
	Wave /T PathToStubs
	String baseDir = ModViewGlobal#GetBaseDir(mData)
	String traceDir = ModViewGlobal#TraceSavingFolder(baseDir)
	// We assume that everything saved by us ends in Force and Sep
	String mSuffix = mData.SuffixForcePlot+ ModDefine#DefListSep() + mData.SuffixSepPlot
	ModViewGlobal#GetUserAndPathWaves(mData,UserStubs,PathToStubs,traceDir,suffixNeeded=mSuffix,allowPreProc=ModDefine#False())
End Function

Static Function /S GetCacheName(ForceName)
	String ForceName
	// Returns a (unique) filename, e ssentially <Experiment>[-]<File>[-]<TimeStamp>
	// This avoids the (very unlikely) scenario that someone uses the same file names on the same experiment
	// If that happens, the timestamp will distinguish between them.
	// Note that this has effective 'high bits to low' sorting 
	// Get the timestamp (recquired a wave reference)
	Wave mWave = $ForceName
	String mTimeStamp 
	sprintf mTimeStamp,"%d",ModCypherUtil#GetTimeStampEnd(mWave)
	String mExp
	if (!FindExpIfExists(ForceName,mExp))
		ModErrorUtil#DevelopmentError(description="No experiment found")
	EndIf
	String mFormat = "%s-%s-%s"
	String toRet
	String mFIleName = ModIoUtil#GetFileName(ForceName)
	sprintf toRet,mFormat,mExp,mTimeStamp,mFIleName
	return toRet
End Function

Static Function KillAllParamsPanels(mData)
	// Kills all the current panels
	Struct ViewGlobalDat &mData
	String tmpPanelName
	Variable i, n= mData.NParamSet
	// Kill each panel
	for (i=0; i<n; i+=1)	
		// Get the panel name
		tmpPanelName = ModViewUtil#GetParamPanelName(i)
		// /W: window
		KillControl /W=$(mData.WindowName) $(tmpPanelName)
	EndFor
End Function

Static Function MakeAllParams(mModel,mGlobalView,mGlobalDef,viewOpt,startXRel,startYRel,ModelParamHandle,[widRel,HeiRel,font])
	// mModel: model we take in
	// mGlobalView: global structure for storing view-wide info, will be updated
	// mGlobalDef: global defines
	// viewOpt: the options for this view (incl. window x,y,width,height)
	// XXX: make viewopt part of globaldef?
	// startXRel and startYRel: relative X and Y locations to start
	// widRel,HeiRel: relative height for each parameter setting
	Struct ModelObject &mModel	
	Struct ViewGlobalDat &mGlobalView
	Struct Global &mGlobalDef
	Struct ViewOptions &viewOpt
	Variable startXRel,startYRel,widRel,HeiRel
	Struct Font & font
	FuncRef SetVarProto & ModelParamHandle
	Struct Font toUse
	// Make sure the font is OK
	if (paramIsDefault(font))
		ModIoUtil#FontDefault(toUse)
	Else
		toUse = font
	EndiF
	// Get the number parameters we will make
	Variable i=0
	Variable nParams = mModel.mParams.NParams
	// Set the global number of parameters.
	mGlobalView.NParamSet = nParams
	// Get the height and width
	Variable hAbs = viewOpt.win.height
	Variable wAbs = viewOpt.win.width
	// Set the (Relative) width and height to 1/N, if it isn't provided
	// XXX make a smarter height and width relative?
	widRel = ParamIsDefault(widRel) ?  (1.-startXRel) : widRel
	heiRel = ParamIsDefault(heiRel) ? 1/(nParams+1) : heiRel
	// Temporary parameter holder
	Struct Parameter tmpPar
	// Loop through each parameter, creating it as we go.
	Variable width = wAbs * widRel
	Variable height = hAbs * HeiRel
	// Simple control panel name of the parameter 
	// this has *nothing* to do with the content
	// or 'real name/meaning' of the parameter
	String tmpPanelName 
	//  if we have 1 parameter, this will avoid dividing by zero
	// below, when we get the y relative
	Variable div = max(1,nParams-1)
	for (i=0; i<nParams; i+=1)
		tmpPar = mModel.mParams.params[i]
		Variable x=startXRel
		Variable y=(startYRel)+i*heiRel
		String mTitle = tmpPar.name
		String helpStr = tmpPar.helpText
		tmpPanelName = ModViewUtil#GetParamPanelName(i)
		// Set the value to store internally
		ModViewUtil#MakeSetVariable(tmpPanelName,mTitle,helpStr,x,y,widRel,heiRel,ModelParamHandle,wAbs=wAbs,hAbs=hAbs,userdata=num2str(i))
		ModViewUtil#SetVariableValue(tmpPar,tmpPanelName)
		// Save a 'prototype' of this parameter, so we can save them willy-nilly
		SetParamProtoType(mGlobalView,tmpPar,i)
	EndFor
	// POST: activate the first parameter.
	ModViewUtil#ActivateParamByID(0)
End Function

Static Function /S GetParamProtoPath(GlobalData,mId)
	Struct ViewGlobalDat &GlobalData
	Variable mId
	String strID 
	sprintf strID,VIEW_PARAMPROTO_FMT,mId
	String mName = GlobalData.DataFolder + ModDefine#DefDirSep() + strID
	return mNAme
End Function

Static Function SetParamProtoType(GlobalData,paramToSet,id)
	// Set the prototype associated with ID to paramtoSet
	Struct ViewGlobalDat &GlobalData
	Struct Parameter & paramToSet
	Variable id
	String mName = GetParamProtoPath(GlobalData,id)
	ModViewUtil#SetParamStruct(paramToSet,mName)
End Function

Static Function GetParamProtoType(GlobalData,paramToGet,id)
	Struct ViewGlobalDat &GlobalData
	Struct Parameter & paramToGet
	Variable id
	String mName = GetParamProtoPath(GlobalData,id)
	// put '$mName' into 'paramToGet'
	 ModViewUtil#GetParamStruct(paramToGet,mName)
End Function

Static Function LoadNewExperiment(fileLoaded,folderName,[subfolder])
	// fileloaded is the *full path* to whatever file (or directory)
	// foldername is the name of the folder *under* ViewGlobalDat.dataDir where the
	// data was loaded
	String fileLoaded,folderName,subFolder
	// Load the global data
	Struct ViewGlobalDat mData 
 	 ModViewGlobal#GetGlobalData(mData)
	// Set the experiment
	String srcFile = ModIoUtil#GetFileName(fileLoaded)
	ModViewGlobal#SetExperiment(mData,folderName,srcFile)
	// Write the global data back, since we change the experiment
	// in setExperiment (but setExperiment doesn't write or us)
	ModViewGlobal#SetGlobalData(mData)
End Function

// for a given experiment, we may need to move the data into a subfolder,
// if it doesn't have the proper directory substructure.
Static Function EnsureComplianceOfLoadedExp(folderName)
	String folderName
	// Get the global Directory
	String ImportDir = ModViewGlobal#GetDataDirLoadGlobal()

End Function

Static Function /S GetGraphID(mData)
	Struct ViewGlobalDat &mData
	String ToRet=mData.WindowName + "#" + mData.PlotName
	return toRet
End Function

// Function for disabling all model parameters, before the pre-processing takes place
Static Function DisableAllModelParams(mData)
	// Disable every parameter
	Struct ViewGlobalDat &mData
	Variable i
	String mName
	for (i=0; i< mData.NParamSet; i+=1)
		mName = ModViewUtil#GetParamPanelName(i)
		SetVariable $(mName) disable=(VIEW_DISABLE)
	EndFor
End Function

Static Function GetUserAndPathWaves(mData,UserWave,PathWave,baseDir,[listSep,DataSep,suffixNeeded,allowPreProc])
	// Sets UserWave and Pathwave to all possible waves (those matching the regex, and those with 
	// stems having the suffixes. E.g. If we have "foo_ul007Force" and "foo_ul007Sep", and Sep
	// And force are the  suffixes, this will work (assuming something like "*foo_ul*" was the regex)
	// Sets $mData.UserFileWaveStr to user-friendly names of the waves. See above
	Struct ViewGlobalDat &mData
	// Userwave and pathwave are initialized here (!) since there is no way for 
	// the user to know how many in advance.
	// XXX throw error if these aren't waves?
	Wave /T UserWave
	Wave /T PathWave
	String baseDir,listSep,DataSep, suffixNeeded
	// Disable pre-processing for already pre-processed curves
	Variable allowPreProc
	 allowPreProc = ParamIsDefault(allowPreProc) ? ModDefine#True() : ModDefine#False()
	if (ParamIsDefault(ListSep))
		ListSep = ModDefine#DefListSep()
	EndIf
	if (ParamISDefault(DataSep))
		DataSep = ModDefine#DefDirSep()
	EndIf
	// everything up to and including the fileID
	// XXX ensure that the regex is some size?
	String FullPathStemPattern = "(" +  mData.RegexWave + ")"
	// Get the suffixes needed
	// XXX change this -- right now, if no X suffix is given, we don't check for it.
	if (ParamIsDefault(SuffixNeeded))
		if (strlen(mData.SuffixXPlot) > 0)
			SuffixNeeded = mData.SuffixXPlot + listSep + mData.suffixYPlot			
		else
			SuffixNeeded = mData.suffixYPlot + listSep
		EndIf
	EndIf
	Make /T/O/N=(0) tmpUnique
	Variable toRet = ModIoUtil#GetUniqueStems(tmpUnique,baseDir,SuffixNeeded,fullPathStemPattern=fullPathStemPattern,listSep=listSep,DirSep=DataSep)
	// didnt find any 
	if (toRet == 0)
		return toRet
	EndIf
	// Get the stems for the unique ones.
	Variable nUnique = DimSize(tmpUnique,0)
	Make /O/N=(NUnique) /T allStems
	ModIoUtil#GetWaveStems(tmpUnique,allStems,FullPathStemPattern)
	// POST: everything in tmpUnique is a full file path, with a path and suffix
	// Need to get just the file path (past the colon)
	// and just the stem (past the colon, use the regex to cut off extra)
	// Use the FilePathStemPattern for 'tmpAllFiles', allowing us free reference
	String FileRegex = ModIoUtil#DefFileRegex()
	ModIoUtil#GetWaveStems(allStems,PathWave,FullPathStemPattern)
	ModIoUtil#GetWaveStems(allStems,UserWave,FileRegex)
	// After a colon, get everything after
	// Kill the waves we made
	KillWaves /Z tmpUnique,allStems
	// If there is a pre-processing step, performs the steps to turn the waves into force and separation.
	Struct ProcessStruct mProc
	LoadPreProcWave(mData,mProc)
	// Only preprocessi s we need it an it is enabled.
	if (mProc.PreProcessingRecquired && allowPreProc)
		// POST: mProc has the force and separation curves needed.
		ModPreprocess#PopulatePreProc(PathWave,mProc)
		// POST: pathwave has the interpolated value we care about
		// Get hthe Y curves. *note*: we can only convert *after*
		// pre-processing, since otherwise we may have a 'stale' wave
		// stored somewhere.
		Wave /T YCurves = $(mProc.YHighRes)
		toRet = DimSize(yCurves,0)
		// Get the final user stems
		ModIoUtil#GetWaveStems(YCurves,PathWave,FullPathStemPattern)
		ModIoUtil#GetWaveStems(YCurves,UserWave,FileRegex)
		// Save the pre-processor.
		SavePreProcWave(mData,mProc)
	EndIf
	// return the number of unique waves; this can be compared to the total number of sucesses
	// Note that this number does *not* take into account suffixes and the like. It only says
	// "how many unique stems where there" which should be like "how many pulls were made"
	return toRet
End Function


Static Function GetParameters(paramFolder,mObj,[onlyPreProc])
	String paramFolder
	Struct ParamObj & mObj
	Variable onlyPreProc
	onlyPreProc = ParamIsDefault(onlyPreProc) ? ModDefine#False() : ModDefine#True()
	Variable nObjects
	// Get the global object
	Struct ViewGlobalDat mData
	GetGlobalData(mData)
	// Get the preprocessor
	Struct ProcessStruct mProc
	ModViewGlobal#LoadPreProcWave(mData,mProc)
	if (onlyPreProc)
		// XXX: use the global objects to determine how
		// many parmeters
		nObjects= mProc.NPreProcParams
	else
		nObjects = ModIoUtil#CountWaves(paramFolder)
	EndIf
	// POST: we know how many parameters to get.
	Variable i=0
	// Make an array for all of the parameters.
	mObj.NParams = 0
	// XXX work out how to get meta out. For now, just know it is on the end
	// XXX fix meta data problem, need to have separate data folder
	For (i=0; i< nObjects; i+=1)
		Struct Parameter tmpParam
		String mWaveName = ModIoUtil#GetWaveAtIndex(paramFolder,i)
		// Make the wave into a struct 
		String fullPath = ModIoUtil#AppendedPath(paramFolder,mWaveName)
		ModViewUtil#GetParamStruct(tmpParam,fullPath)
		// Save the value (index) of the parameter
		mObj.params[i] = tmpParam
		mObj.Nparams += 1
	EndFor
	// POST: mObj has everything we want
End Function

Static Function GetAllParamProtos(mData,mObj)
	Struct ViewGlobalDat & mData 
	Struct ParamObj & mObj
	Struct Parameter tmpParam
	Variable i
	Variable nObjects = mData.NparamSet
	mObj.nParams = 0
	for (i=0; i<nObjects; i+=1)
		GetParamProtoType(mData,tmpParam,i)
		mObj.params[i] = tmpParam
		mObj.nParams += 1
	Endfor
	// POST: mParams has everything...
End Function 

Static Function RunPreprocAndGetSepForce(mData,mSepName,mForceName)
	Struct ViewGlobalDat & mData 
	String &mSepName,&mForceName
	 String mFolder = ModViewGlobal#CurrDataFolder(mData)
	// First, get all the parameters we will need
	String paramFolder = ModViewGlobal#GetCurrentTraceParamPath(mFolder)
	// XXX check that paramFolder exists
	// Get only the pre-processing parameters
	Struct ParamObj mObj
	ModViewGlobal#GetParameters(paramFolder,mObj,onlyPreProc=ModDefine#True())
	// POST: mObj is populated with all of the pre-processing parameters.
	// Go ahead and call the pre-processing run, with the parameters.
	String mStub = mData.CurrentTracePathStub
	Struct ProcessStruct mProc
	ModViewGlobal#LoadPreProcWave(mData,mProc)
	Variable index  = ModViewGlobal#FindPreProcIndexForStub(mProc,mStub)
	// The force and sep name will be set by reference by 'GetProcessedForceSep"
	 ModPreProcess#GetProcessedSepForce(mProc,mObj,index,mSepName,mForceName)
	 // Save the updated processing wave
	 SavePreProcWave(mData,mProc)
End Function

Static Function PlotVersusTime(mData)
	Struct ViewGlobalDat &mData
	return mData.PlotXType == PLOT_TYPE_X_VS_TIME
End Function

// Looks for an experiment on 'mFilePath' (ie: marked curve) and sets 'toModIfExists' 
// if we find something. returns true/false if we did/didn't find something
Static Function GetExperimentFromMarkedIfExists(mFilePath,toModIfExists)
	String mFilePath
	String & toModIfExists // note: pass by *reference
	// The first directory after *mark traces* is the experiment name.
	String mRegex = ".+:" + VIEW_MARKTRACES + ":([^:]+):"
	return ModIoUtil#SetandReturnIfMatch(mFilePath,mRegex,toModIfExists)
End Function

Static Function GetExperimentFromDataIfExists(mWaveStub,mExp)
	String mWaveStub, & mExp
	String mRegex = ".+:" + VIEW_IMPORT_DATA + ":([^:]+):*"
	return ModIoUtil#SetandReturnIfMatch(mWaveStub,mRegex,mExp)
End Function

// Sets mExp by reference, using fullPath to find the experiment name
Static Function FindExpIfExists(fullPath,mExp)
	String fullPath
	String & mExp
	if (ModViewGlobal#GetExperimentFromMarkedIfExists(fullPath,mExp))
		// then this trace is already in the marked curves
		return ModDefine#True()	
	elseif(ModViewGlobal#GetExperimentFromDataIfExists(fullPath,mExp))
		// then we need to check if this curves is marked.
		// If it isnt' then just skip it.
		return ModDefine#True()
	else
		// just skip it!		
		return ModDefine#False()
	EndIf	
End Function

Static Function FindExpAndTraceIfExists(mData,fullPath,mExp,mTrace)
	Struct ViewGlobalDat & mData	
	String fullPath, &mExp,&mTrace
	mTrace = ModIoUtil#GetFileName(fullPath) + mData.SuffixForcePlot
	return FindExpIfExists(fullPath,mExp)
End Function 

Static Function /S GetSqlSaveFolder(TraceFolder)
	String TraceFolder
	return ModIoUtil#AppendedPath(TraceFolder,VIEW_SQL_SAVE)
End Function

Static Function /S GetSqlIdInf(TraceFolder)
	String TraceFolder
	return ModIoUtil#AppendedPath(GetSqlSaveFolder(TraceFolder),VIEW_SQL_ID_WAVE)
End Function	
