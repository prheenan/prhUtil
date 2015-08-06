// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModViewSetter
#include ".:ViewUtil"
#include ".:..:Sql:SqlCypherInterface"
#include ".:..:Sql:SqlCypherUtilFuncs"
#include ".:..:Sql:SqlCypherGuiHandle"

Static StrConstant SET_DEFAULT_STR = ""
Static Constant SET_DEFAULT_NUM = 0
// location of handlers
Static StrConstant MODULE_NAME_HANDLERS = "ModSqlCypherGuiHandle"

// XXX probably need to make this saveable?
Structure SetterObj
	// fieldTypes follows 
	Wave fieldTypes
	Wave /T fieldNames
	// default values for the fields
	Wave /T defaultsStr
	Wave defaultsNum
	// whether each field is editable (E.g.: ID is not.)
	Wave editable
	String mTable
	// The wave we can turn into this setter's
	// 'WaveStr' Struct (ie: local storage), by using GetStruct
	Wave mStruct
	// Function for fulfilling the setter
	FuncRef ProtoSetHandler MyHandler
EndStructure

Function ProtoSetHandler(StrWave,NumWave,mObj)
	Wave /T StrWave
	Wave /D NumWave
	Struct SetterObj & mObj
	// Function that uses the values in strwave and numwave
	//along with the field information present in SetterObj, to 
	// Save the final state of everything
End Function

Static Function /Wave CreateEditable(mTypes,n)
	Wave mTypes
	Variable n
	Make /O/N=(n) editable
	editable[] = ModDefine#True()
	return editable
End Function

Static Function /Wave CreateDefaultsStr(mTypes,n)
	Wave mTypes
	Variable n
	// XXX eventually, make defaults type-specific
	Make /O/N=(n)/T defaultSetStr
	defaultSetStr[] = SET_DEFAULT_STR
	return defaultSetStr
End Function

Static Function /Wave CreateDefaultsNum(mTypes,n)
	Wave mTypes
	Variable n
	Make /O/N=(n) defaultSetNum
	defaultSetNum[] = SET_DEFAULT_NUM
	return defaultSetNum
End Function

Static Function InitSetter(mObj,fieldNames,fieldTypes,mTab,[defaultsStr,defaultsNum,editable])
	Struct SetterObj & mObj
	Wave /T fieldNames,defaultsStr
	Wave fieldTypes,defaultsNum,editable
	String mTab
	Variable nFields = DImSize(fieldNames,0)
	// Set the defaults, if we want them
	if (ParamIsDefault(defaultsStr) && ParamIsDefault(defaultsNum))
		Make /O/N=(nFields)/T defaultsStr
		Make /O/N=(nFields) defaultsNum
		ModSqlCypherInterface#GetSqlDefaults(fieldNames,fieldTypes,defaultsStr,defaultsNum)
	EndIf
	if (ParamIsDefault(editable))
		Make /O/N=(nFields) editable
		ModSqlCypherInterface#GetSqIEditable(fieldTypes,editable)
	EndIf
	// XXX check that shapes match
	// Set up the field names and  types
	Wave /T mObj.fieldNames = fieldNames
	Wave mObj.fieldTypes = fieldTypes
	// Set up the default values
	Wave /T mObj.defaultsStr = defaultsStr
	Wave /D mObj.defaultsNum = defaultsNum
	Wave mObj.editable = editable
	// Set the remainder of the setterObj
	mObj.mTable = mTab
End Function

Static Function  /S GetHelpString(mTable,mName,mType)
	Variable mType
	String mName,mTable
	String HelpStrFmt = "Field %s.%s (type: %d)"
	String toRet 
	sprintf toRet, HelpStrFmt,mTable,mName,mType
End Function

Static Function /S GetPanelName(mTable,mName)
	String mTable,mName
	return "Panel" + mTable + mName
End Function


Static Function NewSetterPanel(mTable)
	String mTable
	// Make the setter object
	Wave /T fieldNames = ModSqlCypherAutoDefines#GetColByTable(mTable)
	Wave fieldTypes = ModSqlCypherAutoDefines#GetTypesByTable(mTable)
	Struct SetterObj mObj
	InitSetter(mObj,fieldNames,fieldTypes,mTable)
	// Get  a proper name
	String mPanelName = ModIoUtil#UniquePanelWindowName(mTable)
	// Get the screen size
	Variable wAbsScreen,hAbsScreen
	ModViewUtil#GetScreenWidthHeight(wAbsScreen,hAbsScreen)
	// POST: wAbs and hAbs are set
	// Get the size for the setter
	Variable wAbsSetter = wAbsScreen * SETTER_WIDTH_REL
	Variable hAbsSetter = hAbsScreen * SETTER_HEIGHT_REL
	NewPanel /W=(0,0,wAbsSetter,hAbsSetter) /N=$(mPanelName)
	// POST: we have our panel, we can go ahead and add to it.
	// Get all the fields we need	
	Wave mFieldTypes =  mObj.fieldTypes
	Wave /T fieldNames = mObj.fieldNames
	// auto-generate the help strings
	Variable nFields = DimSize(mFieldTypes,0)
	Make /O/N=(nFields)/T setterTmpHelp,setterTmpPanel,userData
	setterTmpHelp[] = GetHelpString(mTable,fieldNames[p],mFieldTypes[p])
	// Make the height strings (all the same)
	Make /O/N=(nFields) setterTmpHeight
	setterTmpHeight[] = SETVAR_HEIGHT_REL
	setterTmpPanel[] = GetPanelName(mTable,fieldNames[p])
	// Set up a simple field column
	Variable startXRel = 0, startYRel =0, widthRel = 0.8, heightRel = SETVAR_HEIGHT_REL
	ModViewUtil#SetVariableColumn(setterTmpPanel,fieldNames,setterTmpHelp,startXRel,startyRel,widthRel,setterTmpHeight,SetHandle,wAbsSetter,hAbsSetter,userdata,mFieldTypes)
	// Loop through, modify all the fields according to
	// (1) all the default values
	// (2) if they are editable
	Variable i
	String tmpPanel,mStrVal
	Variable isStr,mType,mNumVal
	for (i=0; i<nFIelds; i+=1)
		tmpPanel = GetPanelName(mTable,fieldNames[i])
		mType = mFieldTypes[i]
		// if we arent numeric, we are a string
		// Note: we assume that 'mType' is one of the sql types.
		isStr = !ModSqlCypherInterface#isNumericType(mType)
		// POST: isStr has whether or not this is a string. 
		// Get the corresponding values
		mStrVal = mObj.defaultsStr[i]
		mNumVal = mObj.defaultsNum[i]
		// Set the value
		ModViewUtil#SetVariableStrOrNum(tmpPanel,isStr,sVal=mStrVal,dVal=mNumVal)
		// XXX TODO set if it is editable or not
	EndFor
	// POST: everything set.
	// Make handler etc.
End Function

Static Function /S GetSetterListboxName(tabName)
	String tabName
	return "SetList0" + tabName
End Function

Static Function /S GetSetterAddName(tabName)
	String tabName
	return "SetAdd0" + tabName
End Function

Static Function /S GetTableNameFromPanelName(panelName)
	String panelName
	String mRegex = ".+0([a-zA-Z]+)$"
	String toRet
	// XXX check this works?
	SplitString /E=(mRegex) panelName,toRet
	return toRet
End Function



Static Function AddSetter(tabName,Host,xRel,yRel,widthRel,heightRel,addWidthRel,wAbs,hAbs)
	String tabName,Host
	Variable xRel,yRel,widthRel,heightRel,wAbs,hAbs,addWidthRel
	// Get the names of our panels
	String mListName = GetSetterListboxName(tabName)
	String mAddName = GetSetterAddName(tabName)
	// Kill the panels, if they already exist
	KillControl /W=$(host) $mListName
	KillControl /W=$(host) $mAddName
	// POST: panels don't exist here.
	// Make the panels
	String helpText = "Options for " + tabName
	Variable listWidth = widthRel-addWidthRel
	// Get the name of the table-specific function handle (should feed into
	// general, just uses our table name
	String mFunc = ModSqlCypherGuiHandle#GetMenuByTable(tabName)
	// Add the full module name.
	FuncRef PopupMenuListProto generateOptions = $(MODULE_NAME_HANDLERS + "#" + mFunc)
	FuncRef PopupMenuProto handleChoice= SetterListHandle
	// Make a popup menu box to choose options
	ModViewUtil#MakePopupMenu(mListName,tabName,helpText,xRel,yRel,listWidth,heightRel,handleChoice,generateOptions,wAbs=wAbs,hAbs=hAbs)
	// Make a button to add a new option
	ModViewUtil#MakeButton(mAddName,"Add","Add a new option",xRel+listWidth,yRel,addWidthRel,heightRel,SetterAddHandle,hAbs=hAbs,wAbs=wAbs)
End Function

Function SetterListHandle(PU_Struct) : PopupMenuControl
   STRUCT WMPopupAction &PU_Struct
	switch (PU_Struct.eventCode)
		case EVENT_POPUP_MOUSEUP:
			print(GetTableNameFromPanelName(PU_Struct.ctrlName))
			break
	EndSwitch
End Function

Function SetterAddHandle(LB_Struct) : ButtonControl
	STRUCT WMButtonAction &LB_Struct
	switch (LB_Struct.eventCode)
		case EVENT_BUTTON_MUP_OVER:
			String mTab = GetTableNameFromPanelName(LB_Struct.ctrlName)
			NewSetterPanel(mTab)
			break
	EndSwitch
End Function

Function SetHandle(SV_Struct):SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	switch (SV_Struct.eventCode)
		case EVENT_SETVAR_ENTER:
			String mVal = SV_Struct.sVal
			print(mVal)
			break
	EndSwitch
End Function


Static Function AddAllSetters(Host,xRel,yRel,widthRel,heightRel,addWidthRel,wAbs,hAbs)
	String host
	Variable xRel,yRel,widthRel,heightRel,wAbs,hAbs,addWidthRel
	// Get all the tables we want to add
	Wave /T mTables = ModSqlCypherInterface#GetGuiTables()
	Variable nTables = DimSize(mTables,0)
	Variable heightRelEach = heightRel/nTables
	// Order the tables by dependencies
	Make /O/N=(nTables) numDep ,mIndex
	numDep[] = MOdSqlCypherInterface#NumDependencies(mTables[p])
	// Make an index to sort by number of dependencies
	MakeIndex numDep, mIndex
	// Sort the tables according to their dependnecies
	IndexSort mIndex,mTables
	Variable i
	for (i=0; i<nTables; i+=1)
		// add each setter, incrementing the height. assume the same width,
		// note that we use heightRelEach to account for all the buttons
		 AddSetter(mTables[i],Host,xRel,yRel+i*heightRelEach,widthRel,heightRelEach,addWidthRel,wAbs,hAbs)
	EndFor
	KillWaves /Z mTables,mIndex,numDependencies
End Function


// Simple unit test
Static Function Main()
	ModSqlCypherInterface#InitSqlModule()
	// Get the screen size
	Variable wAbsScreen,hAbsScreen
	ModViewUtil#GetScreenWidthHeight(wAbsScreen,hAbsScreen)
	String mPanel = "tmpSetter"
	NewPanel /W=(0,0,wAbsScreen,hAbsScreen) /N=$(mPanel) 
	// Set up all the setters.
	AddAllSetters(mPanel,0.0,0,0.3,0.6,0.04,wAbsScreen,hAbsScreen)
End Function
