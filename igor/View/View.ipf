
#pragma rtGlobals=3        // Use strict wave reference mode
#pragma ModuleName = ModView
#include "..:Util:GlobalObject"
#include "..:Util:Defines"
#include "..:Util:IoUtil"
#include "..:Util:PlotUtil"
#include  "..:Util:CypherUtil"
#include "..:Model:ModelDefines"
#include "..:ModelInstances:DnaWlc"
#include "..:ModelInstances:Nug2"
#include "..:MVC_Common:MvcDefines"
#include "..:Model:Model"		
#include ".:ViewUtil"
#include ".:ViewGlobal"
// Constants for the common handler of meta information
Static Constant HANDLE_META_REGEX = 0
Static Constant HANDLE_META_SET_X = 1
Static Constant HANDLE_META_SET_Y = 2
// Meta information about the tips and sample
Static Constant HANDLE_META_SAMPLETYPE = 3
Static Constant HANDLE_META_SAMPLEID= 4
Static Constant HANDLE_META_TIPTYPE = 5
Static Constant HANDLE_META_TIPID = 6
Static Constant HANDLE_META_REG_EXP = 7

// Analysis functions
// XXX TODO: clean this up
// Add in objects for saving information about everything 
// (parameters and wave IDs...)
Static Function AnalyzeSingle(dataFolder,FitFunc,mStruct)
	// Datafolder is the name of a folder having the meta information,
	// parameter folder, and data folder for a single trace
	Struct ViewModelStruct & mStruct
	String dataFolder
	FuncRef ModelFitProto FitFunc
	// Data folder has the meta data we care about within this folder
	// paramFOlder has the actual parameters
	String paramFolder = ModViewGlobal#GetCurrentTraceParamPath(dataFolder)
	// XXX check that paramFolder exists
	// Get all the parameters
	Struct ParamObj mObj
	ModViewGlobal#GetParameters(paramFolder,mObj)
	// POST: mObj is populated approproately
	Struct FileSaveInfo meta
	String metaLoc = ModIoUtil#AppendedPath(Datafolder,"META")
	// XXX check metaLoc exists
	 ModViewGlobal#GetFileSaveInfo(metaLoc,meta)
	 // Get the cache folder
	 String mCache = ModVIewGlobal#GetDataFolderLocalCache(dataFolder)
	 // get the *file* name (should be the same as the cached)
	 String xFIle = ModIoUtil#GetFileName(meta.XName)
	 String yFile= ModIoUtil#GetFileName(meta.YName)
	 // Get the full path to the caches file
	 String xRef = ModIoUtil#AppendedPath(mCache,xFile)
	 String yRef
	 if (strlen(yFile) == 0)
	 	// TODO / fix
	 	// Then guess that yRef is xRef with Sep replaced by force
	 	yRef = ReplaceString("Sep",xRef,"Force") 
	 else
	 	 yRef = ModIoUtil#AppendedPath(mCache,yFile)
	 EndIf
	 // XXX make this less kludgey wrt parameter passing
	FitFunc(xRef,yRef,mObj,mStruct)
//	return L0Ret
End Function

Static Function AnalyzeAll(dataFolder,analysisFuncs,mStruct)
	// XXX Data folder exists (should check this everywhere
	// PRE: mStruct has the folder where we should output
	String dataFolder
	Struct ModelFunctions & analysisFuncs
	Struct ViewModelStruct & mStruct
	Variable nObjects =  ModIoUtil#CountDataFolders(Datafolder)
	String tmpFolder
	// /O : Overrride, new L0 of length N 
	// hurts my soul, this weird string object reference stuff
	Make /O/N=(nObjects) L0Arr
	Variable i=0
	FuncRef ModelFitProto mFitter = analysisFuncs.FitFunc
	For (i=0; i< nObjects; i+= 1)
		tmpFolder =  ModIoUtil#GetDataFolderAtIndex(Datafolder,i)
		// Get the full name of this 'sub' folder
		String mName = ModIoUtil#AppendedPath(DataFolder,tmpFolder)
		L0Arr[i] = AnalyzeSingle(mName,mFitter,mStruct)
	EndFor
End Function

Static Function /S GetGraphName(mData)
	Struct ViewGlobalDat &mData
	// XXX maake a hash utility funciton
	return mData.WindowName + "#" + mData.PlotName
End Function

Static Function SetCursor(traceName,[xValue])
	// Sets the cursor on the main plot
	// XXX make the plot for the cursor specifiable asa default param?
	String TraceName
	Variable xValue
	if (ParamIsDefault(xValue))
		xValue = leftx($traceName) 
	EndIf
	// Get the Global data for all the plotting
	Struct ViewGlobalDat mData
	ModViewGlobal#GetGlobalData(mData)
	String mGraphName = GetGraphName(mData)
	// get everything after the colon (or everything ,if no colon)
	traceName = ModIoUtil#GetFilename(traceName)
	 // A=1: activates
 	// N=1: Don't kill if dragged off
 	// P: care about the points
 	Cursor /P /A=1 /N=1 /W=$(mGraphName) A,$traceName, (xValue)
 	// Always use cursor X 	
End Function

Static Function GetCursorPoint()
	Struct ViewGlobalDat mData
	ModViewGlobal#GetGlobalData(mData)
	String mGraphName = GetGraphName(mData)
	// XXX make this not a string
	Variable curPoint  = pcsr ($("A"))
	return curPoint
End Function

// Append Y vs X to the current window, unless we want to plot against time
// in which case we just plot Y (assuming that it has the time as its scale)
Static Function mAppend(mData,X,Y,[red,green,blue])
	Struct ViewGlobalDat &mData
	Wave X,Y
	Variable red,green,blue // default colors to black?
	 	String GraphID = ModViewGlobal#GetGraphID(mData)
	if (mData.PlotXType == PLOT_TYPE_X_VS_TIME)
		 AppendToGraph /W=$(GraphID) /C = (red,green,blue) Y
	else
		 AppendToGraph /W=$(GraphID) /C = (red,green,blue) Y vs X
	EndIf
End Function

Static Function DisplayNewTrace(mData,mWaveStub,[MedianSize])
	// Displays the new traces, removes the old, and modifies globalview accordingly
	// *must* write out globaldat (mData) after this, since we modify the current plot
	Struct ViewGlobalDat &mData
	String mWaveStub // The stub to the wave we are interested in
	Variable MedianSize // If this exists, we display a median size appropriate
	String PathToDisplayX,PathToDisplayY
	// The separation should be OK for all the 
	PathToDisplayX = mWaveStub + mData.SuffixSepPlot
	PathToDisplayY = mWaveStub + mData.SuffixForcePlot
	// Remove the previous string, if it exists
 	 String GraphID = ModViewGlobal#GetGraphID(mData)
	// Remove *all* the traces from this plot, if there are any.
	ModPlotUtil#ClearFig(GraphNAme=GraphID)
	// POST: graph is cleared
	 Struct RGBColor red
	ModPlotUtil#Red(red)
	Struct RGBColor grey
	 ModPlotUtil#Grey(grey)
	if (!ModViewGlobal#AllPreProcMade(mData))
		// Instead, we display the low and high resolution Deflections
		// Display the low resolution one here, in red.
	 	String lowResRef, highResRef
	 	ModViewGlobal#GetYRefsForPreProc(mData,mWaveStub,lowResRef,highResRef)
	 	AppendToGraph /W=$(GraphID) /C=(red.red,red.green,red.blue) $highResRef
	 	AppendToGraph /W=$(GraphID) /C=(grey.red,grey.green,grey.blue) $lowResRef
	 	Duplicate /O $highResRef, $PLOT_Y_TMPWAVE
	 	SetCursor(highResRef)
	 else
		// Plot 'normally'
		// XXX make getters and setters for this?
		DUplicate /O $(PathToDisplayX), $(PLOT_X_TMPWAVE)
	 	Duplicate /O $(PathToDisplayY), $(PLOT_Y_TMPWAVE)
		// Smooth the data (XXX add in variable for smoothing and filter type)
		// Smoth [flags] size,wave
		// M: median filtering (threshold is zer, everything is median filtered)
	 	Wave Ytr = $PLOT_Y_TMPWAVE
	 	Wave Xtr = $PLOT_X_TMPWAVE
		// XXX if the user wants, based on global view...
		// Probably can just allow user to do all of the processing. 
		// Need to add this into the global view (ie: all the funcitons?)
		//ModModel#YFlipAndRemoveApproach(Xtr,Ytr)
		 // Get a filtered version of the wave
	 	String filterName = "tmpFilter"
	 	Duplicate /O Ytr, $filterName
		Wave filteredWave = $filterName
		// XXX make this better...
		if (!ParamIsDefault(MedianSize))
			Variable boxSize = MedianSize // 10 point median filtering
			Smooth /M=0 boxSize, filteredWave
		EndIf
	 	// XXX set graph axis (probably need a whole option)
	 	// I imagine: auto, manual, based on all, based on selected.
	 	// Color the normal curve grey
	 	mAppend(mData,Xtr,YTr,red=grey.red,green=grey.green,blue=grey.blue)
	 	if (!ParamIsDefault(MedianSize))
	 		 mAppend(mData,Xtr,filteredWave)
		 EndIf
		 SetCursor(PLOT_Y_TMPWAVE)
	EndIf
 	// Make the graph a little prettier
 	ModPlotUtil#PlotBeautify(GraphName=GraphID) 
 	// XXX make this more general, based on axis units...
 	// get the axes in the right units (geez, lots to do)
	ModifyGraph /W=$GraphID prescaleExp(left)=12 // to pN
	ModifyGraph /W=$GraphID prescaleExp(bottom)=6 // to um 
	// XXX make this dependent?
 	ModPlotUtil#XLabel("Extension [" + ModPlotUtil#Mu() + "m]",graphName=GraphID)
 	ModPlotUtil#YLabel("Force [pN]",graphName=GraphID)	
 	// Write out the global object after
	mData.PlotTraceName = PLOT_Y_TMPWAVE
	mData.CurrentXPath = PathToDisplayX
	DoUpdate
End Function

Static Function PlotParamPreview(mData,toPlot,mDoUpdate)
	// This function plots 'toPlot' on the current graph
	// Using a unique name. It should be called after plotting the rest
	// of the graph, since it *relies on the axis range being set*
	Struct ViewGlobalDat &mData
	Struct Parameter & toPlot 
	Variable mDoUpdate
	// Check if the parameter is set; otherwise, don't plot it.
	if (!toPlot.beenSet)
		Return ModDefine#True()
	EndIf
	Variable numVal = toPlot.NumericValue
	Variable numValX = ModModelDefines#GetXVal(toPlot)
	Variable numValY = ModModelDefines#GetYVal(toPlot)
	String mGraph = ModVIewGlobal#GetGraphID(mData)
	// XXX this is a huge kludge and makes me unhappy,
	// Evidently, you cant reference a constant in the same way you can a function
	// These constants should all have "ModModelDefines#" infront  of them
	Variable xOff = PTYPE_XOFFSET
	// Igor switch statement is not very powerful, 
	// and it doesn't look
	switch (toPlot.mType)
		case PTYPE_XOFFSET:
			// Plot a horizontal line
			break
		case PTYPE_YOFFSET:
			// Plot a vertical line
			ModPlotUtil#AxVLine(numValX,GraphName=mGraph,mDoUpdate=mDoUpdate)
			break
		case PTYPE_X_Y_OFFSET:
			// Plot a verticle *and* horizontal line
			ModPlotUtil#AxVLine(numValX,GraphName=mGraph,mDoUpdate=mDoUpdate)
			break
		case PTYPE_LINEFIT:
			// Plot a crosshair
			break
		default:
			// dont do anything.
			break
	EndSwitch
End Function

Static Function SetSingleParamWidget(mData,idToSet,mDoUpdate)
	// Sets the value of the parameter based on *the current folder*
	// (saved in mData / the global view data)
	// Must be called after graphing the data, if the plot preview is o work correctly.
	Struct ViewGlobalDat &mData
	Variable idToSet
	Variable mDoUpdate
	// Get the prototype parameter, in case we need to over-write
	// And so we know the name
	Struct Parameter proto
	ModViewGlobal#GetParamProtoType(mData,proto,idToSet)
	// Get the path, based on the prototype and the current folder
	// This is OK, shouldn't have a name conflict
	String fullPath = ModViewGlobal#GetParameterPath(mData,proto)
	// TODO: XXX assume numeric values for now
	Variable mValue
	if (WaveExists($fullPath))
		// Then we can load the old values parameters.
		Struct Parameter savedVal 
		ModViewUtil#GetParamStruct(savedVal,fullPath)
		// The numeric value is the value along the value
		// This is what we will show the user.
		mValue = savedVal.NumericValue
		// POST: go ahead and plot whatever the value was.
		// Plot a preview
		 PlotParamPreview(mData,savedVal,mDoUpdate)
	else
		// Load  the "not yet set" value
		// XXX make this based on nan of the parameter?
		mValue = ModDefine#DefBadRetNum()
	EndIf
	// POST: mValue had the value to load
	// XXX TODO: need to account for string varibales etc
	String panelName = ModViewUtil#GetParamPanelName(idToSet)
	SetVariable $panelName value=_NUM:(mValue)
End Function


Static Function SetParamValsIfExist(mData)
	// Sets the values in the parameter gui widget, for 
	// all of the loadable GUI SetVariable Widets
	// Note: This uses the currently plotted object!
	Struct ViewGlobalDat &mData
	Variable nParams= mData.NParamSet
	Variable i
	for (i=0; i< nParams; i+= 1)
		// Set the single value
		// We only update on the first parameter, since 
		// the axvline recquires this to function properly.
		Variable updateGraph = (i==0)
		 SetSingleParamWidget(mData,i,updateGraph)	
	EndFor
	// POST: everything is set to how we want.
End Function

Function CopyCursorToCurrParamMoveNext()
	// When this is called, copies the current value of the cursor
	// to the current parameter widget, and updates the struct
	Struct ViewGlobalDat mData
	// Get the global view state
	ModViewGlobal#GetGlobalData(mData)
	// Determine which widget to change
	Variable paramID = mData.SelectedParamID
	String GetParamPanelName = ModViewUtil#GetParamPanelName(paramID)
	// Get the cursor value (point index)
	Variable pointIdx = GetCursorPoint()
	// Update the parameter accordingly
	UpdateParam(pointIdx,paramID)
	// Move to te next parameter (this one is set)
	MoveToNextParam(mData)
	ModViewGlobal#GetGlobalData(mData)
End Function

Static Function GetXPointNearestVal(X,numVal)
	String X
	Variable numVal
	Variable toRet
	KillWaves /Z Tmp
	Duplicate /O $X Tmp
	Tmp -= NumVal
	Tmp = abs(Tmp)
	WaveStats /Q Tmp
	// the index we care about is the minimum row.
	// Closest to whatever the user wanted.
	toRet = V_MinRowLoc
	return toRet
End Function

Static Function SetParameter(mData,mPar,mIndex,X,Y)
	Struct ViewGlobalDat &mData 
	Struct Parameter &mPar 
	String X,Y
	Variable mIndex
	// XXX assumes only numeric values for now...
	 Variable getTimeFromY = ModViewGlobal#PlotVersusTime(mData)
	ModModelDefines#SetValueFromXY(mPar,num2str(mIndex),mIndex,X,Y,getXFromY=getTimeFromY)
	 // Save the parameter value, based on out id...
	String fullPath = ModViewGlobal#GetParameterPath(mData,mPar)
	 // Write the parameter back, to the full path
	 ModViewUtil#SetParamStruct(mPar,fullPath)
End Function

Function MoveToNextParam(mData)
	Struct ViewGlobalDat &mData
	Variable mID = mData.SelectedParamID
	//  XXX Deactivate the current panel
	//String PrevPanelName = ModViewUtil#GetParamPanelName(mID)
	// Activate the new panel
	Variable newID = mod((mID+1),mData.NParamSet)
	String newPanelName = ModViewUtil#GetParamPanelName(newID)
	mData.SelectedParamID = newID
	SetVariable $newPanelName activate
End Function

Static Function UpdateParam(mPoint,paramID)
	// mPoint is the X-Y offset to updated based on
	// paramID is the parameter to update
	Variable mPoint
	Variable paramID
	Struct ViewGlobalDat mData 
 	ModViewGlobal#GetGlobalData(mData)
 	String mFolder = ModViewGlobal#CurrDataFolder(mData)
 	// We have selected this paramater
 	mData.SelectedParamID = paramID
 	 // Set the value to whatever the user entered, based on the X coordinate
 	String X = mData.CurrentXPath
 	// Note we are using the plottracename, insted of the current Y plot,
 	// since we want to get *exactly* what is on the cursor (enorce this?)
 	String Y = mData.PlotTraceName
 	String mMetaDataPath = ModViewGlobal#GetFileSaveInfoPath(mData)
 	// TODO: check out DuplicateDataFolder, for saving a copy
 	if (!DataFolderExists(mFolder))
 		// Need to make this folder
 		// DO *not* switch to it (no need)
 		NewDataFolder $mFolder
 	endIf
 	 if (!WaveExists($mMetaDataPath))
 		// Create the meta data folder
 		Variable saveCache = ModVIewGlobal#AllPreProcMade(mData)
 		ModViewGlobal#WriteFileSaveInfo(mData,X,Y,saveCache)
 	EndIf
 	// XXX move this until we are sure the pre-processing is one.
 	 // POST: mFolder and meta folder exist
 	// Get the appropriate parameter 'prototype', which we will fill in.
 	Struct Parameter mPar
 	ModViewGlobal#GetParamProtoType(mData,mPar,paramID)
 	// XXX check that we are a numeric value
 	SetParameter(mData,mPar,mPoint,X,Y)
 	// Update the appropriate widget
 	String mPanel = ModViewUtil#GetParamPanelName(paramID)
 	SetVariable $mPanel value=_NUM:(mPar.NumericValue)
 	 // Update the meta data, to reflect that this parameter exists
 	 ModViewGlobal#UpdateFileSaveInfo(mData,mParam=mPar)
 	// Move onto the next parameter. If we are at the end, then
 	// select the next wave (XXX TODO: select next wave?)
 	MoveToNextParam(mData)
	 // Do update to update the widget
	 // Change the Preview for this parameter.
	 Variable mDoUpdate = ModDefine#True()
	  PlotParamPreview(mData,mPar,mDoUpdate)
	  // Get  the meta data
 	 Struct FileSaveInfo mMeta
 	 ModViewGlobal#GetFileSaveInfo(mMetaDataPath,mMeta)
	// if we weren't done making pre-processing parameters before, but we are now,
	// go ahead and run the pre-procesing steps
	// Note: if there are *no* preprocessing steps, this will never happen
	 Variable preProcFinishedAfter = ModVIewGlobal#AllPreProcMade(mData)
	if (!mMeta.beenPreProcessed && preProcFinishedAfter)
		// then run the pre-processor.
		String mSepName,mForceName
		ModViewGlobal#RunPreProcAndGetSepForce(mData,mSepname,mForceName)
		 // Write the meta save info, *and* save mForce and mSep as a copy
		 ModViewGlobal#FileInfoPreProcessed(mData,mMeta,mMetaDataPath,mSepName,mForceName)
		 // Go ahead and display the new Force-Sep curve
		 DisplayNewTrace(mData,mData.CurrentTracePathStub)
	EndIf
 	// Write out the parameter data
 	ModViewGlobal#SetGlobalData(mData)
End Function

Static Function PushMetaPanelDefaults(panelNames,defValues,Ids,mData)
	// panel name allows us to reference the panel (e.g. by $panelName[i])
	// defValues is the list of values to set
	// Ids is whatevr the metadata is, for setMeta.
	Wave /T panelNames
	Wave /T defValues
	Wave Ids
	Struct ViewGlobalDat &mData
	// push the default meta values for each of panelNAmes 
	//ModViewUtil.SetVariableValue
	Variable nValues = DImSize(Ids,0)
	Variable i=0
	String mVal
	for (i=0; i<nValues; i+=1)
		// set the value of this (String) parameter
		// XXX add in whether or not this is a string parameter
		mVal = defValues[i]
		ModViewUtil#SetVariableStrOrNum(panelNames[i],ModDefine#True(),sVal=mVal)
		// Call the SetMeta handle, so everything is consistent.
		SetMetaRef(Ids[i],mVal,ModDefine#False(),mData)
	EndFor
End Function

Static Function ModelSpecificMetaOpts(mData,modelObj,mOpt)
	Struct ViewGlobalDat & mData
	Struct ModelObject & modelObj
	Struct ViewOptions & mOpt
	Make /O/T panels = {"XSuffix","YSuffix","FileRegex","ExpRegex"}
	Make/O/T names ={"File X Suffix","File Y Suffix","FIle Regex","Experiment Regex"}
	Make/O/T helpStr = {"File Suffix for X Values (E.g. 'Sep','Zsnr')","File Suffix for Y Values (E.g. 'Force','Defl')","Regex to determine file ID (E.g. '\d+')","Regex to find the experiment"}
	Make /O panelID = {HANDLE_META_SET_X,HANDLE_META_SET_Y,HANDLE_META_REGEX,HANDLE_META_REG_EXP}
	// Asylum saves their data like foo/bar/.../X<dateAsDigits>/FileName<IdAsDigits><Sep/Force/Defl/Zsnsr>
	 // XXX make the defaults model-dependent.
	 Make /O/T defaults = {modelObj.mXSuffix,modelObj.mYSuffix,DEFAULT_STEM_REGEX,DEFAULT_REGEX_ASYLUM_EXP}
	 PushMetaPanelDefaults(panels,defaults,panelID,mData)
	 Variable hAbs = mOpt.win.height, wAbs = mOpt.win.width
	 ModViewUtil#SetStringVariableColumn(panels,names,helpStr,0,BUTTON_HEIGHT_REL*NLoadBUttons,META_WIDTH_REL,BUTTON_HEIGHT_REL,HandleMetaSet,wabs,habs,panelID)
End Function

// Updates ViewGlobalDat
Static Function SetModel(modelObj)
	Struct ModelObject & modelObj
	Struct ViewGlobalDat mData
 	ModViewGlobal#GetGlobalData(mData)
 	// Kill all of the old parameters.
 	MOdViewGlobal#KillAllParamsPanels(mData)
 	// POST: fresh slate.
	Make /O/T mFuncNames
	ModViewGlobal#SetViewModel(mData,modelObj)
	ModModelDefines#GetFunctionNames(modelObj.funcs,mFuncNames)
	ModViewGlobal#SetViewFunctions(mData,mFuncNames)
	// Get hte view options and global 
	Struct ViewOptions mOpt
	ModViewUtil#InitViewOpt(mOpt)
	Struct Global g
	ModGlobal#InitGlobalObj(g)
	ModViewGlobal#MakeAllParams(modelObj,mData,g,mOpt,META_WIDTH_REL+graphWidth,0,HandleModelParam)
	ModelSpecificMetaOpts(mData,modelObj,mOpt)
	// Write out everything
	// Update the struct containing the global data. This *must* happen at the end of a
	// one-off procedure, so we can save state. poor man's objects...
	// Get the 'nitty-gritty' string. This you can use to actually plot traces.
	Wave /T tmpAllWaves = $(mData.AllFileWaveStr)
	// get a reference to all the waves
	// XXX make safe references for things like this?
	Wave /T tmpUserWaves = $(mData.UserFileWaveStr)
	Variable wAbs,habs
	ModViewUtil#GetScreenWidthHeight(wAbs,hAbs,mOpt=mOpt)
	ModViewUtil#MakeListBox("AllWaves","Choose a wave to view and analyze",tmpUserWaves,META_WIDTH_REL,0,LISTBOX_WIDTH_REL,LISTBOX_HEIGHT_REL,HandleWaveSelect,hAbs=hAbs,wAbs=wAbs)
	// Save the preprocessing object, when we are done
	ModViewGlobal#SavePreProcWave(mData,modelObj.mProc)
	ModViewGlobal#SetGlobalData(mData) 
	KillWaves /Z mFuncNames
End Function

Static Function CreatePanel()
	// Move to the root directory
	SetDataFolder :
	// Get and initialize the global object
	Struct Global g
	ModGlobal#InitGlobalObj(g)
	// Set up the model object object
	// XXX make selectable
	Struct ViewGlobalDat mData
	//Set up the globall view object
	Struct ViewOptions mOpt
	ModViewUtil#InitViewOpt(mOpt)
	ModViewGlobal#SetOptionsGlobalAndFolder(mData)
	// Create the main panel
	NewPanel /N=$(mData.WindowName) /W=(mOpt.win.left,mOpt.win.top,mOpt.win.right,mOpt.win.bottom)
	// XXXX Kill the window, if it currently exists
	SetWindow $(mData.WindowName), hook(foo)=HandleWindow
	// Start adding in buttons and lists
	// Get the user friendly string. *wont* be able to plot these
	// Save the model object functions
	String strAllWaves = mData.UserFileWaveStr
	String strUserWaves = mData.AllFileWaveStr
	// Get the Default font. XXX: make the box defines based on the size?
	Struct Font DefFont
	ModIoUtil#FontDefault(DefFont)
	// Make the list box for all waves
	Variable AllowResize = 1
	Variable SelectionMode = 1 // single selection
	Variable wAbs,hAbs
	ModViewUtil#GetScreenWidthHeight(wAbs,hAbs,mOpt=mOpt)
	// XXX add in space between / separators
	// Maybe make an options struct I pass around for gui grid spacing? Then we could use a generic 
	// function with a funcref, update things in a gridlike manner. XXX TODO, if it won't be
	// too clunky.
	// make the meta information gui
	FuncRef PopupMenuListProto mProc = $("ModMvcDefines#GetModelOptions")
	ModViewUtil#MakePopupMenu("LoadModel","Load A Model","Load a known model.",0,0,META_WIDTH_REL,BUTTON_HEIGHT_REL,HandleModelSelect,mProc)
	ModViewUtil#MakeButton("MarkLoad","Load Previously Analyzed Curves","Loads curves you have previously marked",0,BUTTON_HEIGHT_REL,META_WIDTH_REL,BUTTON_HEIGHT_REL,HandleLoadMarked,hAbs=habs,wAbs=wAbs)
	ModViewUtil#MakeButton("ExpLoad","Load Single PXP file","Load a new Asylum Experimental (.pxp) File",0,2*BUTTON_HEIGHT_REL,META_WIDTH_REL,BUTTON_HEIGHT_REL,HandleLoadExp,habs=hAbs,wAbs=wAbs)
	ModViewUtil#MakeButton("FolderLoad","Load a folder as a single experiment","Loads a series of data files (e.g. ibw,itx,pxp) from a single folder, interpreting it as a single experiment. Useful for post-processing",0,3*BUTTON_HEIGHT_REL,META_WIDTH_REL,BUTTON_HEIGHT_REL,HandleLoadFolder,habs=hAbs,wAbs=wAbs)
	 // XXX make all of this more general, should query SQL
	 // Molecule type determines sample ID
	 // Should be able to add more.
	 // Make a box for the molecule type
	 // Meta information about the tips and sample
	 // Add list box information for the molecule type and ID 
	 // The y has to account for the buttons and the set variables.
	 Variable startYRel = BUTTON_HEIGHT_REL*(NLoadBUttons +nMeta )
	 Make /O/T panels = {"MolType","MolID","TipType","TIpID"}
	 Make /O/T names= {"Molecule Used","Molecule ID","Tip Type","Tip Id"}
	 Make  /O/T helpStr = {"Pick the Molecule you used","Pick the sample you used","Pick the Tip Type (e.g. Long, Mini)","Pick the tip you used"}
	 Make /O/T mOptFuncs = {"ModViewUtil#GetDefinedMolecules","ModViewUtil#GetDefinedSamplesIDs","ModViewUtil#GetDefineTipTypes","ModViewUtil#GetTipID"}
	 Make /O userData = {HANDLE_META_SAMPLETYPE,HANDLE_META_SAMPLEID,HANDLE_META_TIPTYPE,HANDLE_META_TIPID}
	 ModViewUtil#SetPopupColumn(panels,names,helpStr,mOptFuncs,0,startYRel,META_WIDTH_REL,BUTTON_HEIGHT_REL,HandleMetaPopup,wabs,habs,userdata)
	 // update where the Y should start
	 startYRel += BUTTON_HEIGHT_REL * DimSize(Panels,0)
	 ModViewUtil#MakeButton("ToggleX","Toggle X Axis","Toggle X Axis between time and separation",0,startYRel,META_WIDTH_REL,BUTTON_HEIGHT_REL,HandleToggleX,habs=hAbs,wAbs=wAbs)
	 startYRel += BUTTON_HEIGHT_REL 
	ModViewUtil#MakeButton("SetSaveDir","Save Marked Curves","Set where to save marked curves as tsv: [time,sep,force]",0,startYRel,META_WIDTH_REL,BUTTON_HEIGHT_REL,HandleSaveMarked,habs=hAbs,wAbs=wAbs)
	 // POST default regex is set up.
	 //GetUserAndPathWaves(mData,strAllWaves,strUserWaves,baseDir)
	// Create the View for the graph; go ahead and plot a bit.
	String GraphName = mData.PlotName
	// Make a display in this window.
	ModViewUtil#DisplayRel(mData.windowName, GraphName, mOpt.win,META_WIDTH_REL,LISTBOX_HEIGHT_REL,graphWidth,graphHeight)
	// Add a button to analyze everything
	ModViewUtil#MakeButton("Analyze","Analyze","Click To Analyze All Tagged Graphs",META_WIDTH_REL,LISTBOX_HEIGHT_REL+graphHeight,graphWidth,BUTTON_HEIGHT_REL,HandleAnalyzeButton,hAbs=hAbs,wAbs=wAbs)
	// Update the struct containing the global data. This *must* happen at the end of a
	// one-off procedure, so we can save state. poor man's objects...
	ModViewGlobal#SetGlobalData(mData) 
	// POST: done with all the panels, go ahead and kill all the waves we made to avoid clutter
	 // XXX use free waves?
	 KillWaves /Z panels,names,helpStr,panelID,defaults,userData,mOptFuncs,mFuncNames
End Function

// Hooks below
// XXX move these into the controllr?
// Hook for analysis

Function SetMetaRef(toSet,sVal,dVal,GlobalDat)
	// version which just sets the value in the global references
	Variable toSet,dVal
	String sVal
	Struct ViewGlobalDat & GlobalDat
	switch (toSet)
		// Set the variables appropriately
		// XXX programmig error on default?
		case HANDLE_META_REGEX:
			GlobalDat.RegexWave = sVal
			break
		case HANDLE_META_SET_X:
			GlobalDat.SuffixXPlot = sVal
			break
		case HANDLE_META_SET_Y:	
			GlobalDat.SuffixYPlot = sVal
			break
		case HANDLE_META_REG_EXP:
			GlobalDat.RegexExp = sVal
			break
	EndSwitch
End Function

Function SetMeta(toSet,sVal,dVal)
	// PRE: an event has occured to set the meta data 'toSet' with sVal or dVal.
	Variable toSet,dVal
	String sVal
	// get the global variable, so we can set it.
	Struct ViewGlobalDat GlobalDat
	 ModViewGlobal#GetGlobalData(GlobalDat)
	 SetMetaRef(toSet,sVal,dVal,GlobalDat)
	// write out the global data
	ModViewGlobal#SetGlobalData(GlobalDat)
End Function

Function HandleMetaPopup(event) : PopupMenuControl
	   STRUCT WMPopupAction &event
	   switch (event.eventCode)
			case EVENT_POPUP_MOUSEUP:
				// Get the global data on a mouseup (ie: choice)
				Variable mToSet = str2num(event.userdata)
				SetMeta(mToSet,event.popStr,event.popNum)
			break
	   EndSwitch
End Function


Function ToggleXTimeAndSep()
	// Get the global struct
	Struct ViewGlobalDat mData
	ModViewGlobal#GetGlobalData(mData)
	// Switch what we are plotting
	Variable toSet
	Switch (mData.PlotXType)
		// If plotting time, go to sep
		case PLOT_TYPE_X_VS_TIME:
			toSet = PLOT_TYPE_X_VS_SEP
			break
		// If plotting sep, go to time
		case PLOT_TYPE_X_VS_SEP:
			toSet = PLOT_TYPE_X_VS_TIME
			break
		default:
			ModErrorUtil#DevelopmentError()
	EndSwitch
	mData.PlotXType = toSet
	// DIsplay the updated plot
	DisplayNewTrace(mData,mData.CurrentTracePathStub)
	ModViewGlobal#SetGlobalData(mData)
End Function

// Returns true if the model is settable, false otherwise
// Also sets 'mObj' to the appropriate model
Static Function GetModelByNum(mNum,mObj)
	Variable mNum
	Struct ModelObject & mObj
	// Assume we succeed, by default
	Variable toRet = ModDefine#True()
	switch (mNum)
		case MVC_MODEL_DNA:
			ModDnaWLC#InitDNAModel(mObj)
			break
		case MVC_MODEL_NUG2:	
			ModNUG2#InitNUG2Model(mObj)
			break
		case MVC_MODEL_NONE:
			// return false; nothing loaded
			toRet =  MOdDefine#False()
			// Disable all parameters
			Struct ViewGlobalDat mData
			ModViewGlobal#GetGlobalData(mData)
			MOdViewGlobal#KillAllParamsPanels(mData)
			break
		default:
			// whoops!
			toRet = ModDefine#False()
			ModErrorUtil#DevelopmentError(description="Bad Model Number.")
			break
	EndSwitch
	return toRet
End Function

Function HandleModelSelect(event) : PopupMenuControl
	   STRUCT WMPopupAction &event
	  switch (event.eventCode)
		case EVENT_POPUP_MOUSEUP:
			Variable mNum = event.popNum
			Struct MOdelObject mModel
			// Check if we have a real model
			if(GetModelByNum(mNum,mModel))
				// POST: we have the model, update the global view and object
				SetModel(mModel)
			EndIf
		break	
	EndSwitch
End Function

Function HandleToggleX(BTN_Struct) : ButtonControl
	STRUCT WMButtonAction &BTN_Struct
	  switch (BTN_STRUCT.eventCode)
		case EVENT_BUTTON_MUP_OVER:
			ToggleXTimeAndSep()
		break	
	EndSwitch
End Function

Function HandleMetaSet(event) : SetVariableControl
	STRUCT WMSetVariableAction &event
	// event.dval and event.sval are the digit and string values
	// respectively.
	switch (event.eventCode)
		case EVENT_SETVAR_ENTER:
			// Get the global data....
			Variable mToSet = str2num(event.userdata)
			SetMeta(mToSet,event.sVal,event.dVal)
		break
	 EndSwitch
End Function 

Function HandleSaveMarked(BTN_Struct): ListboxControl
	STRUCT WMButtonAction &BTN_Struct
	switch (BTN_STRUCT.eventCode)
		case EVENT_BUTTON_MUP_OVER:
			String WhereToSave
			if (MOdIoUtil#GetFolderInteractive(WhereToSave))
				// Then the user picked somewhere
				// Namely "WhereToSave" (pass by ref)
				Struct ViewGlobalDat mData
				ModViewGlobal#GetGlobalData(mData)
				// Save the directory to save in mData
				mData.CachedSaveDir = WheretoSave
				// Save all the files we have marked out
				// Search for waves here
				Make /O/T/N=0 UserWaves
				Make /O/T/N=0 PathWaves
				ModVIewGlobal#GetAllMarkedStubs(mData,UserWaves,PathWaves)
				// POST: Pathwaves has all the stubs we want
				// Save all the stubs out
				ModViewGlobal#SaveAllStubsAsFEC(mData,PathWaves)
				// We modified GlobalDat, need to update
				ModViewGlobal#SetGlobalData(mData)
				// Done with the waves, we can toss them.
				Killwaves /Z UserWaves,PathWaves
			EndIf
			// POST: saved, if the user wanted.
			break
	EndSwitch
End Function

Function HandleLoadMarked(BTN_Struct): ButtonControl
	STRUCT WMButtonAction &BTN_Struct
	  switch (BTN_STRUCT.eventCode)
		case EVENT_BUTTON_MUP_OVER:
		// Load all of the files in the marked directory
		// Load the global object
		Struct ViewGlobalDat mData
		ModViewGlobal#GetGlobalData(mData)
		// get the marked directory
		// Search for waves here
		Make /O/T/N=0 UserWaves
		Make /O/T/N=0 PathWaves
		ModVIewGlobal#GetAllMarkedStubs(mData,UserWaves,PathWaves)
		// Overwrite whatever is in the current global wavs
		Duplicate /O UserWaves,$(mData.UserFileWaveStr)
		Duplicate /O PathWaves,$(mData.AllFileWaveStr)
		// Kill the temporary waves
		KillWaves UserWaves,PathWaves
		// No need to save back; the global state has not changed.
		break
	EndSwitch
End Function

Function HandleLoadFolder(BTN_Struct): ButtonControl
	STRUCT WMButtonAction &BTN_Struct
 	 switch (BTN_STRUCT.eventCode)
		case EVENT_BUTTON_MUP_OVER:
			// Get the folder to load
			String mFolder
			if (!ModIoUtil#GetFolderInteractive(mFolder))
				return MOdDefine#False()
			EndIF
			// POST: the folder is OK.
			// Get the folder name of the source; we want to group this thing as an experiment.
			String mDir  =ModIoUtil#GetLastDirectory(mFolder)
			// find where data is imported
			String ImportDir = ModViewGlobal#GetDataDirLoadGlobal()
			// pin down exactly where to put it
			String whereToLoad = ModIoUtil#AppendedPath(ImportDir,mDir)
			// Load any of the default file extensions found in mFolder into this directory.
			ModIoUtil#LoadIgorFilesInFolder(mFolder,locToLoadInto=whereToLoad)			
			// save the 'source file' as this folder, and the 
			// This (1) prevents needing to store all the individual files loaded
			// Note that we *dont* have a subfolder (like "root:ForceCurves:Subfolder"),
			// Since all of the data is lumped together.
			ModVIewGlobal#LoadNewExperiment(mFolder,mDir,subfolder="")
		break
	endSwitch
End Function 

Function HandleLoadExp(BTN_Struct) : ButtonControl 
	STRUCT WMButtonAction &BTN_Struct
 	 switch (BTN_STRUCT.eventCode)
		case EVENT_BUTTON_MUP_OVER:
			// Interactively load the data into "ImportDir", setting "fileLoaded" to the 
			// full path name and 'folderName' to the data folder name where we loaded it.
			String fileLoaded
			String folderName
			 // Load the data into the appropriate directory
		 	 String ImportDir = ModViewGlobal#GetDataDirLoadGlobal()
			if(!ModIoUtil#LoadInteractive(fileLoaded,ImportDir,ifPresentLoadIntoFileFolder=folderName))
				// If we didn't load anything (user cancelled), then return
				return ModDefine#False()
			EndIf
			// Use the default naming convention
			ModVIewGlobal#LoadNewExperiment(fileLoaded,folderName)
	EndSwitch
End Function 

Function HandleAnalyzeButton(BTN_Struct) : ListboxControl 
	STRUCT WMButtonAction &BTN_Struct
 	 switch (BTN_STRUCT.eventCode)
		case EVENT_BUTTON_MUP_OVER:
			// Get the global View object
			Struct ViewGlobalDat mData 
		 	 ModViewGlobal#GetGlobalData(mData)
			// Get the model functions needed for analysis.
			Struct ModelFunctions analysisFuncs
			ModViewGlobal#GetViewFunctions(mData,analysisFuncs)
			String mBase = ModViewGlobal#GetBaseDir(mData)
			String allTracePath = ModViewGlobal#TraceSavingFolder(mBase)
			Variable nFolders = ModIoUtil#CountDataFolders(allTracePath)
			Variable i=0
			String mFolderSave
			if (!ModIoUtil#GetFolderInteractive(mFolderSave))
				return ModDefine#False()
			EndIf
			// POST: we have the folder set up
			// Make the global object
			Struct ViewModelStruct mStruct
			mStruct.modelBaseoutputFolder =mFolderSave
			// loop through all the analysis folders
			for (i=0; i< nFolders; i +=1)
				String mFolder  = ModIoUtil#GetDataFolderAtIndex(allTracePath,i)
				String thisPath = ModIoUtil#AppendedPath(allTracePath,mFolder)
				AnalyzeAll(thisPath,analysisFuncs,mStruct)
			EndFor
			// no need to set global data; nothing changed.
			break
	EndSwitch
End

Function HandleWindow(s)
	STRUCT WMWinHookStruct &s
	Variable hookResult = EVENT_NOT_HANDLED
	switch(s.eventCode)
		case EVENT_WINDOW_KEYSTROKE:
		// handle
			Variable mKey = s.keycode
			switch (mKey)
				case KEYSTROKE_SHIFT_ENTER:
					CopyCursorToCurrParamMoveNext()
					break
				case KEYSTROKE_CONTROL_A:
					SetAxis/A
					break
			EndSwitch
			break
	EndSwitch
	return hookResult
End Function

Function HandleWaveSelect(LB_Struct) : ListboxControl
	STRUCT WMListboxAction &LB_Struct
 	Variable mRow = LB_Struct.row
 	Variable eventcode = LB_Struct.eventCode
 	// XXX look into WaveSelectorWidget.ipf
 	// IT have a FilterProc, which allows filtering.
 	Switch (eventCode)
 		// XXX Have a common defined object or function for event codes
 		// Cell Selection with mouse or arrow
 		case EVENT_LIST_SEL:
			// Get the global data
 			Struct ViewGlobalDat mData 
 			ModViewGlobal#GetGlobalData(mData)
 			Wave /T globalPaths = $(mData.AllFileWaveStr)
 			 if (mRow >= DimSize(globalPaths,0))
 			 	return ModDefine#False()
 			 EndIf
 			 // POST: we are in range
 			mData.selectedWaveIdx = mRow
		 	String mWaveStub = globalPaths[mData.selectedWaveIdx]
		 	String WindowName = mData.WindowName
		 	// Check and see if this is stored under the saved curves
		 	// (in which case we set the experiment, etc.)
		 	String mExp 
		 	// Set the current stub.
		 	mData.CurrentTracePathStub = mWaveStub
		 	if (ModViewGlobal#GetExperimentFromMarkedIfExists(mWaveStub,mExp))
		 		// If there is an *experiment* meta file, set the experiment and source from that
		 		// Note: mExp is passed and set by reference. by  GetExperimentFromMarkedIfExists
				mData.CurrentExpName = mExp
		 		 String mMetaDataPath = ModViewGlobal#GetFileSaveInfoPath(mData)
				// Set the experiment, if it just changed
				Struct FileSaveInfo meta
				ModViewGlobal#GetFileSaveInfo(mMetaDataPath,meta)
	 			ModViewGlobal#SetExperimentUnsafe(mData,meta.ExpName,meta.SourceFileName)
	 		EndIf
		 	// Remove the old trace, given its plot name
			 DisplayNewTrace(mData,mWaveStub)
			 // POST: the values for what has been plotted have changed
			 //Go ahead and update the values fir the parameter widgets
			 // Also plot the previews
			 SetParamValsIfExist(mData)
		 	// C: Change
		 	// N: Name
		 	// W: Window
		 	// A=MX: Middle (T=Top,C=Center,B=Bottom) (title) 
		 	String GraphID =  ModViewGlobal#GetGraphID(mData)
		 	String mFileName = ModIoUtil#GetFileName(mWaveStub)
		 	TextBox/W=$(GraphID)/C/N=text0/A=MB "FEC For " + mFileName
		 	// Reset the parameter ID to the beginning
		 	mData.SelectedParamID = 0
		 	ModViewGlobal#SetGlobalData(mData)
	 		break
	 	case EVENT_LIST_KEYSTROKE:
	 		break
	 	case EVENT_LIST_DOUBLE_CLICK:
	 		break
 	EndSwitch
End Function

Function HandleModelParam(event) : SetVariableControl
	STRUCT WMSetVariableAction &event
	// Function used to handle all the ModelParam calls
	String userDat = event.userdata
	Variable mID = str2num(userDat)
	// event.dval and event.sval are the digit and string values
	// respectively.
	switch (event.eventCode)
		case EVENT_SETVAR_ENTER:
		// Get the global data....
			Variable mXValue = event.dVal
			if (ModDefine#isNan(mXValue))
			// XX throw error?
				break
			EndIF			
			Struct ViewGlobalDat mData
			ModViewGlobal#GetGlobalData(mData)
			// Get the closest X index
			Variable mPoint = x2pnt($(mData.PlotTraceName),mXValue)
			UpdateParam(mPoint,mID)
			break
	 EndSwitch
End Function 
