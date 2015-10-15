// Use modern global access method, strict compilation
#pragma rtGlobals=3	
// this file has functions for creating setters for the various sql tables
// needed (ie: can't be auto-generated, like sample) and functions for pushing a single trace

#pragma ModuleName = ModViewSetter
#include ":ViewUtil"
#include "::Sql:SqlCypherInterface"
#include "::Sql:SqlCypherUtilFuncs"
#include "::Sql:SqlCypherGuiHandle"
#include "::Sql:SqlCypherAutoFuncs"
#include "::Util:DataStructures"
// Include the model, so we can set all of the parameters.
#include "::Model:ModelDefines"
// Include the cypher util, so we can include the force information
#include "::Util:CypherUtil"

Constant SETTER_DEF_HEIGHT = 0.4
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
	// XXX check one or the toehr is default?
	if (ParamIsDefault(defaultsStr) && ParamIsDefault(defaultsNum))
		Make /O/N=(nFields)/T defaultsStr
		Make /O/N=(nFields) defaultsNum
		// Get the defaults for all the fields
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

Static Function /S GetSetVarName(mTable,mName)
	String mTable,mName
	return mTable + "_" + mName
End Function

// Get the set variable username
Static Function /S GetSetVarUserDataName(mTable,fieldName,fieldNum)
	String mTable,fieldName
	Variable fieldNum
	// table / field / num
	return GetSetVarName(mTable,fieldName) + "_" + num2str(fieldNum)
End Function

Static Function NewSetterPanel(mTable)
	String mTable
	// Make the setter object
	Wave /T fieldNames = ModSqlCypherAutoDefines#GetColByTable(mTable)
	Wave fieldTypes = ModSqlCypherAutoDefines#GetTypesByTable(mTable)
	Struct SetterObj mObj
	// Initialize the fields, types, and defaults for this object
	InitSetter(mObj,fieldNames,fieldTypes,mTable)
	// Get all the fields we need	
	Wave mFieldTypes =  mObj.fieldTypes
	Wave /T fieldNames = mObj.fieldNames
	Variable nFields = DimSize(mFieldTypes,0)
	// Get  a proper name
	ModIoUtil#SafeKillWindow(mTable)
	String mPanelName = mTable
	// Get the screen size
	Variable wAbsScreen,hAbsScreen
	ModViewUtil#GetScreenWidthHeight(wAbsScreen,hAbsScreen)
	// POST: wAbs and hAbs are set
	// Get the size for the setter
	Variable wAbsSetter = wAbsScreen * SETTER_WIDTH_REL
	Variable nButtons = 2 // number of buttons below the fields (Submit and cancel)
	// for the height, we add some
	Variable hAbsSetter = hAbsScreen * SETTER_HEIGHT_REL
	NewPanel /W=(0,0,wAbsSetter,hAbsSetter) /N=$(mPanelName)
	// POST: we have our panel, we can go ahead and add to it.
	// auto-generate the help strings
	Make /O/N=(nFields)/T setterTmpHelp,setterTmpPanel,userData
	setterTmpHelp[] = GetHelpString(mTable,fieldNames[p],mFieldTypes[p])
	// Make the height strings (all the same)
	Make /O/N=(nFields) setterTmpHeight
	setterTmpHeight[] = SETVAR_HEIGHT_REL
	setterTmpPanel[] = GetSetVarName(mTable,fieldNames[p])
	userdata[] = GetSetVarUserDataName(mTable,fieldNames[p],p)
	// Set up a simple field column
	Variable startXRel = 0, startYRel =0, widthRel = 0.8, heightRel = SETVAR_HEIGHT_REL
	ModViewUtil#SetVariableColumn(setterTmpPanel,fieldNames,setterTmpHelp,startXRel,startyRel,widthRel,setterTmpHeight,SetHandle,wAbsSetter,hAbsSetter,userdata,mFieldTypes)
	// Make buttons for submit and cancel
	Variable startYRelButtons = startYRel + heightRel * nFields
	ModViewUtil#MakeButton(mTable + "Cancel","Cancel","Cancel Add",startXRel,startYRelButtons,widthRel,heightRel,HandleSetCancel,wabs=wAbsSetter,hAbs=wAbsSetter)
	ModViewUtil#MakeButton(mTable + "Submit","Submit","Confirm Submission",startXRel,startYRelButtons+heightRel,widthRel,heightRel,HandleSetSubmit,wabs=wAbsSetter,hAbs=wAbsSetter)
	// Loop through, modify all the fields according to
	// (1) all the default values
	// (2) if they are editable
	Variable i
	String tmpPanel,mStrVal
	Variable isStr,mType,mNumVal
	for (i=0; i<nFIelds; i+=1)
		tmpPanel = GetSetVarName(mTable,fieldNames[i])
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

Static Function /S GetSetterPopupName(tabName)
	String tabName
	return "List0" + tabName
End Function

Static Function /S GetSetterAddName(tabName)
	String tabName
	return "Add0" + tabName
End Function

Static Function /S GetTableNameFromSetterOrAddName(panelName)
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
	String mListName = GetSetterPopupName(tabName)
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
	// If the table dependencies are cleared, enable it. otherwise, disable
	Struct SqlIdTable mIds
	ModSqlCypherInterface#LoadGlobalIdStruct(mIds)
	UpdatePopupByClear(tabName,mIds)
End Function

// Function to, given a row in a listbox, give the zero-based index
// it refers to. This is *not* the same as the SQL ID (usually), 
// but it *Does* allow you to index and find the ID using 'SqlCypherInterface#GetFieldWaveName'
Static Function GetListBoxIndex(mTable,row)
	String mTable
	Variable Row
	// Get the 'defaults', which are invalid choices
	String mDefaults = ModSqlCypherInterface#GetMenuDefaults(mTable)
	// Get the number of defaults, based on the listbox separator
	Variable nDef = ItemsInList(mDefaults,LISTBOX_SEP_ITEMS)
	// need to subtract one, since we are one based, and we want to index
	// into what we really care about
	return row-nDef-1
End Function

Static Function ListBoxRowIsValid(mTable,row)
	String mTable
	Variable row
	// Listbox is one indexed, so row-nDef should be strictly greater than / equal to 0
	return (GetListBoxIndex(mTable,row) >= 0)
End Function

Function SetterListHandle(PU_Struct) : PopupMenuControl
   STRUCT WMPopupAction &PU_Struct
	switch (PU_Struct.eventCode)
		case EVENT_POPUP_MOUSEUP:
			// Get the SQL ID we selected, set the current ID to that, 
			// then update all the table dependencies.
			String mTab = GetTableNameFromSetterOrAddName(PU_Struct.ctrlName)
			// Load the ID object.
			Struct SqlIdTable mStruct
			ModSqlCypherInterface#LoadGlobalIdStruct(mStruct)
			Variable mID
			Variable row = PU_Struct.popNum // 1-indexed
			if (ListBoxRowIsValid(mTab,row))
				// This was a fine choice; use the row to get the index
				Variable mIndex = GetListBoxIndex(mTab,row)
				// next, use the index to get the SQL id
				mId = ModSqlCypherInterface#GetIdOfRowAtIndex(mTab,mIndex)
			else
				// This was a bad choice, use thre bad ID
				// Set the ID structure's id to the bad value
				mID = SQL_BAD_ID
			EndIf
			// False: not a New ID: should already be in SQL
			SetTableSqlId(mTab,mID,ModDefine#False())
			break
	EndSwitch
End Function

// PRE: mTab should be a table with a popupmenu
Static Function UpdatePopupChoicesForTable(mTab)
	// Need to update the selection for the original chooser (ie: choose new ID), 
	// Get the name of the listbox to update
	String mTab
	String mPopup = GetSetterPopupName(mTab)
	// Get the updated options for the popup menu
	String MyVals = ModSqlCypherInterface#HandleMenu(mTab)
	ModViewUtil#SetPopupValue(mPopup,MyVals)
End Function

// Loads and updates the current ID structure, updates all the GUI elements
// newID is true if this is a new ID...
Static Function SetTableSqlId(mTab,mID,newID)
	String mTab
	Variable mID,newID
	// POST: we added the field to the global object.
	// Get the global struct, set the ID for this table
	Struct SqlIdTable mIdStruct
	ModSqlCypherInterface#LoadGlobalIdStruct(mIdStruct)
	// set the ID for this table.
	ModSqlCypherAutoDefines#SetId(mIdStruct,mTab,mID)
	// Update all the dependencies for the *data*
	ModSqlCypherInterface#UpdateDependenciesFromSql(mTab,mIdStruct,newId=newID)
	// Update all our dependencies for the *gui*
	UpdateGuiDependenciesOnSet(mTab,mIdStruct)
	// Update the value for this table's popup, if a new ID set
	if (newID)
		UpdatePopupChoicesForTable(mTab)
		// bit of a kludge; get the values in the list again
		String myVals = ModSqlCypherInterface#HandleMenu(mTab)
		Variable row = ItemsInList(MyVals,LISTBOX_SEP_ITEMS)
		String mPopup = GetSetterPopupName(mTab)
		PopupMenu $mPopup mode=(row)
	EndIf
	// Save the ID structure, so we can actually use it..
	ModSqlCypherInterface#SaveGlobalIdStruct(mIdStruct)
End Function

Function SetterAddHandle(LB_Struct) : ButtonControl
	STRUCT WMButtonAction &LB_Struct
	switch (LB_Struct.eventCode)
		case EVENT_BUTTON_MUP_OVER:
			String mTab = GetTableNameFromSetterOrAddName(LB_Struct.ctrlName)
			NewSetterPanel(mTab)
			break
	EndSwitch
End Function

Function SetHandle(SV_Struct):SetVariableControl
	STRUCT WMSetVariableAction &SV_Struct
	switch (SV_Struct.eventCode)
		case EVENT_SETVAR_ENTER:
			String mVal = SV_Struct.sVal
			break
	EndSwitch
End Function

Function HandleSetCancel(LB_Struct) 
	STRUCT WMButtonAction &LB_Struct
	switch (LB_Struct.eventcode)
		case EVENT_BUTTON_MUP_OVER:
			KillWindow $(LB_Struct.win)
		break
	EndSwitch
End Function

// Set the (pass by referece) StrVal and Numval from (Setvariabke) Control
//with ControlName under WindowName
Function GetSetVarValue(WindowName,ControlName,StrVal,NumValue)
	String WindowName,ControlName
	String & StrVal 
	Variable & NumValue
	// Get the control value by setting controlinfo
	ControlInfo /W=$(WindowName) $ControlName
	// XXX check this is truly a set variable?
	// Sets 
	// --V_value Value of the variable. 
	//      If the SetVariable is used with a string variable, then it is the interpretation of the string as a number, which will be NaN if conversion fails.
	// --S_value Name of the variable or, if the value was set using _STR: syntax, the string value itself.
	StrVal = S_Value
	NumValue = V_Value
End Function

Function HandleSetSubmit(LB_Struct) 
	STRUCT WMButtonAction &LB_Struct
	switch (LB_Struct.eventcode)
		case EVENT_BUTTON_MUP_OVER:
			// Get the table name, assumed the window name
			String mTab = LB_Struct.win
			String mWindowName = mTab
			// Get the column names, so we can get the setvariable 
			// controls
			Wave /T fieldNames = ModSqlCypherAutoDefines#GetColByTable(mTab)
			Wave fieldTypes = ModSqlCypherAutoDefines#GetTypesByTable(mTab)
			Variable nFields = DimSize(fieldNames,0)
			// Make arrays to store the numeric and string values.
			Make /O/N=(nFields)/T  mStrs
			Make /O/N=(nFields) mNums
			// Loop through each field names, putting the value in the 
			// appropriate type
			Variable i, tmpNumVal
			String setVarName,tmpStrVal
			for (i=0; i<nFields; i += 1)
				setVarName = GetSetVarName(mTab,fieldNames[i])			
				// Get the string and data value for the setvariable field
				GetSetVarValue(mWindowName,setVarName,tmpStrVal,tmpNumVal)
				// Set mStrs or mNums, depending on the type of this variable
				if (ModSqlCypherInterface#IsNumericType(fieldTypes[i]))
					mNums[i] = tmpNumVal
				else
					mStrs[i] = tmpStrVal
				endIf
			EndFor
			// POST: all values set by the user are obtained
			// Need to add these values to the global state, insert into Sql
			Struct SqlHandleObj forHandler
			forHandler.mTableName = mTab
			ModSqlCypherInterface#AddToSqlHandler(mStrs,mNums,forHandler)
			// POST: added to SQL
			// Go ahead and kill this update window
			KillWindow $(mWindowName)
			// Get the ID table, possibly enable dependencies
			// True: this *is* a new add.
			SetTableSqlId(mTab,mNums[0],ModDefine#True())
			KillWaves /Z fieldNames,fieldTypes,mStrs,mNums
		break
	EndSwitch
End Function

// Updates the gui element for 'mTab' if all the dependencies for it
// are set in mIds
Static Function UpdatePopupByClear(mTab,mIds)
	String mTab
	Struct SqlIdTable & mIds
	String mSetter = GetSetterPopupName(mTab)
	if (ModSqlCypherInterface#DependenciesCleared(mTab,mIds))
		// Then this table can be enabled, since
		// it is a gui element (setwise intersect) 
		// and it is updated.
		// Enable the popup menu and the add button
		ModViewUtil#EnablePopup(mSetter)
		UpdatePopupChoicesForTable(mTab)	
	else
		ModViewUtil#DisablePopup(mSetter)		
	EndIf
End Function

// This function notes that the table is set.
// Check dependencies, and enables them if it needs to
// NOTE: this *must be called* after the ID table is updated.
// since it uses the ID table (read-only)
Static Function UpdateGuiDependenciesOnSet(mTab,mIds)
	String mTab
	Struct SqlIdTable & mIds
	// Get the dependencies for this table
	Wave /T mDep = ModSqlCypherAutoDefines#GetWhatDependsOnTable(mTab)
	// For each table, enable them if all the dependencies are set
	Variable numDep = DImSize(mDep,0)
	Wave /T updateable  = ModSqlCypherInterface# GetGuiTables()
	// only care about things which are both dependencies *and* updateable
	Wave /T toUpdate = ModDataStruct#ExtractSetTextIntersection(updateable,mDep)
	Variable n = DimSize(toUpdate,0)
	Variable i
	for (i=0; i<n; i+=1)
		UpdatePopupByClear(toUpdate[i],mIds)
	EndFor
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
	// XXX sort alphanumerically within the dependencies
	Variable i
	for (i=0; i<nTables; i+=1)
		// add each setter, incrementing the height. assume the same width,
		// note that we use heightRelEach to account for all the buttons
		 AddSetter(mTables[i],Host,xRel,yRel+i*heightRelEach,widthRel,heightRelEach,addWidthRel,wAbs,hAbs)
	EndFor
	KillWaves /Z mTables,mIndex,numDependencies
End Function

// Function for initializing a panel for setting cypher database parameters.
Static Function InitSqlSetter(hostPanel,xRel,yRel,widthRel,heightRel,addWidthRel,wAbs,hAbs)
	// addWidthRel: fraction of wAbs for the field editing
	String hostPanel
	Variable xRel,yRel,widthRel,heightRel,addWidthRel,wAbs,hAbs
	ModSqlCypherInterface#InitSqlModule()
	// Set up all the setters.
	AddAllSetters(hostPanel,xRel,yRel,widthRel,heightRel,addWidthRel,wAbs,hAbs)
End Function

// Function for demoing the setter.
Static Function MainTestSetter()	
	// Get the screen size
	Variable wAbs,hAbs
	ModViewUtil#GetScreenWidthHeight(wAbs,hAbs)
	String mPanel = "tmpSetter"
	NewPanel /W=(0,0,wAbs,hAbs) /N=$(mPanel) 
	Variable xRel=0,yRel=0,widthRel=0.3,heightRel=0.8,addWidthRel=0.04
	InitSqlSetter(mPanel,xRel,yRel,widthRel,heightRel,addWidthRel,wAbs,hAbs)
End Function

// Simple unit test
Static Function Main()
	MainTestSetter()
End Function
