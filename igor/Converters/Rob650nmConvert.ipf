// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModRob650nmConvert
#include "::Util:IoUtil"
#include "::Util:ErrorUtil"
#include "::Util:CypherUtil"

Static Constant ROB_COL_FORCE = 3
Static Constant ROB_COL_SEP = 4
Static Constant ROB_MAX_NCOLS = 5
Static StrConstant DEF_ROB_INPUT = "root:Packages:RobConvert:Output:"

Static Function /S Def_Rob_Output(srcFilePath)
	// use the default asylum path
	String srcFilePath
	String sep = ModDefine#DefDirSep()
	String mSubFolder = ModIoUtil#GetDataLoadFolderName(srcFilePath,isDir=ModDefine#True())
	return DEF_ROOTNAME + sep + DEFAULT_ASYLUM_PATH + mSubFolder + sep
End Function

// InWave is a rob-like archive file (ie: 'X2DayWet2DayTip0000.ibw')
// determines if it is the right shape
Static Function ProperShapeOrError(InFileWave)
	Wave InFileWave
	// XXX make better error message
	// XXX check for >=1 row?
	if (!(DimSIze(InFileWave,1) == ROB_MAX_NCOLS))
		MOdErrorUtil#DevelopmentError()
	EndIf
End Function

// puts the frce and sep in forceOut and sepOut.
// They *must * have been previously allocated
Static Function GetForceSep(InWave,forceOut,sepOut)
	Wave InWave
	Wave forceOut,sepOut
	ProperShapeOrError(InWave)
	// POST: correct number of columns
	// Get wave statistics
	Variable nRows = DimSize(InWave,0)
	Redimension /N=(nRows) forceOut,sepOut
	// Get the force and sep, using duplicate to preseve notes.
	Duplicate /O/R=[][ROB_COL_FORCE] InWave, forceOut
	Duplicate /O/R=[][ROB_COL_SEP] InWave, sepOut
End Function

// Plots the incoming wave
Static Function PlotForceSep(FileInWave)
	Wave FileInWave
	Make /O/N=(0) mForce,mSep
	 GetForceSep(FileInWave,mForce,mSep)
	// Make a display
	Display
	// Add the froce sep curve
	AppendToGraph mForce vs mSep
End Function

// mFolder is the (system) name to load full of inidividual files from rob
// We assume that mFolder is real, and don't check (ie: shouldn't pass garbage path)
// mInput is where to put the data ( see strconst above for default)
// mOutput is where to put the force sep (see strconst above for default)
// if killInputAfterLoad (default), the input waves are destroyed; only force and sep
// are retained in the output directory
// *All paths should be absolute*
Static Function LoadRobDataFolder(mFolder,[mInput,mOutput,killInputAfterLoad])
	String mFolder,mInput,mOutput
	Variable killInputAfterLoad
	killInputAfterLoad = ParamIsDefault(killInputAfterLoad)? ModDefine#True() : killInputAfterLoad
	if (ParamIsDefault(mInput))
		mInput = DEF_ROB_INPUT
	EndIf
	if (ParamIsDefault(mOutput))
		mOutput = DEF_ROB_OUTPUT(mFolder)
	EndIf
	// POST: all parameters are set 
	String locToloadInto = mInput
	String outputDir = mOutput
	KillDataFolder /Z $locToloadInto
	KillDataFolder /Z $outputDir
	MOdIoUtil#EnsurePathExists(locToLoadInto)
	MOdIoUtil#EnsurePathExists(outputDir)
	// POST: we have a path to load into
	// Load all the waves here
	ModIoUtil#LoadIgorFilesInFolder(mFolder,locToLoadInto=locToLoadInto)
	// POST: all the waves loaded
	// Get the force sep for each
	Variable nLoaded = MOdIoUtil#CountWaves(locToLoadInto)
	Variable i
	// get the working directory, to go back later
	String orig = ModIoUtil#cwd() 
	// Set the data folder to the working directory
	SetDataFolder $locToLoadInto
	for (i=0; i<nLoaded ;i+=1)
		String mWaveRef = MOdIoUtil#GetWaveAtIndex(locToLoadInto,i)
		//Get the full (absolute) reference
		mWaveRef = ModIoUtil#AppendedPath(locToLoadInto,mWaveRef)
		Wave mWave = $(mWaveRef)
		// Get the force and the separation (all we care about)
		String mForceOut = NameOfWave(mWave) + ModCypherUtil#ForceSuffix()
		String mSepOut = NameOfWave(mWave) + ModCypherUtil#SepSuffix()
		Make /O/N=(0) $mForceOut,$mSepOut
		GetForceSep(mWave,$mforceOut,$mSepOut)
		// POST: force and sep have been made.
		// Copy them to the outfolder
		Wave forceWave = $mForceOut
		Wave sepWave = $mSepOut
		Duplicate /O forceWave,$ModIoUtil#AppendedPath(outputDir,mForceOut)
		Duplicate /O sepWave,$ModIoUtil#AppendedPath(outputDir,mSepOut)
	EndFor
	SetDataFolder $orig
	// Kill the input data folder, if we need to
	if (killInputAfterLoad)
		KillDataFolder /Z $locToLoadInto	
	EndIf
	// POST: all done!
End Function

Static Function Main()
	// Kill the root; fresh slate
	KillDataFolder root:
	String mFolder 
	if (!ModIoUtil#GetFolderInteractive(mFolder))
		return ModDefine#False()
	EndIf
	LoadRobDataFolder(mFolder)
End Function