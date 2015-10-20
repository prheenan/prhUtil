// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#pragma ModuleName = ModViewUtil
#include "::Util:IoUtil"
#include "::Util:PlotUtil"
#include "::Model:ModelDefines"

// Name of the listbox control
StrConstant WAVE_SELECTOR_LISTBOX_NAME = "AllWaveSel"
// MOdel control name
StrConstant MODEL_CONTROL_NAME = "LoadModel"
// Default for ListBox
Constant VIEW_DEF_LISTBOX_RESIZE = 1
// Checkbox: default to checkbox on right
Constant DEF_SIDE_CHECK = 1
//m=0: No selection allowed.
//m=1: One or zero selection allowed.
//m=2: One and only one selection allowed.
//m=3: Multiple, but not disjoint, selections allowed.
//m=4: Multiple and disjoint selections allowed.
Constant VIEW_DEF_LISTBOX_SELECT = 1
Constant VIEW_LISTBOX_MULTIPLE_SELECTS = 4
//Bit 0 (0x01): Cell is selected.
Constant SELWAVE_ENABLE_SELECTION = 1
Constant LISTBOX_SELWAVE_SELECTED = 1
Constant LISTBOX_SELWAVE_NOT_SELECTED  = 0 
// Events for list
Constant EVENT_LIST_MOUSE_UP = 2
Constant EVENT_LIST_SEL = 4
Constant EVENT_LIST_KEYSTROKE = 12
Constant EVENT_SHIFT_SELECT = 5
// Events for Button (pp 42 of igor manual)
Constant EVENT_BUTTON_MUP_OVER= 2
// Events for SetVariable
Constant EVENT_SETVAR_ENTER = 2
Constant EVENT_SETVAR_MOUSEUP = 1
// Keystrokes
Constant KEYSTROKE_CONTROL_A =  1
Constant KEYSTROKE_SHIFT_A = 65
Constant KEYSTROKE_SHIFT_ENTER= 13
// For Window handler
Constant EVENT_WINDOW_KEYSTROKE = 11
// If Igor should or should not handle the event
Constant EVENT_HANDLED = 1
Constant EVENT_NOT_HANDLED = 0
// Popup constants. V-503: on mode of 0, title is in popupmenu
Constant EVENT_POPUP_MOUSEUP = 2
Constant POPUP_MENU_TITLE_MODE = 1 
Constant CONTROL_ENABLE = 0 // Editability Normal.
Constant CONTROL_DISABLE = 2 // Draw in gray state; disable control action
Constant LISTBOX_HEIGHT_REL = 0.35, LISTBOX_WIDTH_REL =0.4, graphWidth = 0.4, graphHeight = 0.4
// Relative meta params height and width
Constant META_WIDTH_REL = 0.3
Constant BUTTON_HEIGHT_REL = 0.05
Constant SETVAR_HEIGHT_REL = 0.05
Constant SETVAR_WIDTH_REL = 0.05
Constant SETTER_HEIGHT_REL = 0.9
Constant SETTER_WIDTH_REL = 0.5
// Constants related to view
// XXX should have a view registry or something, keep tract that way, instead of hard-coding.
Constant NLoadBUttons = 4
Constant nMeta =  4
// Types for setvariable: numeric and string
Constant SETVAR_TYPE_NUMERIC = 1
Constant SETVAR_TYPE_STRING = 2
Constant SETVAR_TYPE_NONE_GIVEN = 3
Constant SETVAR_BY_WAVE = 4
// LISTBOX_SEP 
StrConstant VIEW_PARAM_FMT = "Param%d"
StrConstant VIEW_SETVAR_STR = "_STR:tmp"
StrConstant VIEW_SETVAR_NUM = "_NUM:tmp"
// The formatting for the saved parameter objects, in the top level.
StrConstant VIEW_PARAMPROTO_FMT = "Param%dProtoStruct"
// SetVariable can't have a format string for string variables
// V-582 of the igor manual
StrConstant SETVARIABLE_STR_FORMAT = ""
StrConstant DEF_FMT_NUM = "%.8g"
StrConstant DEF_FMT_STR = "%s"
// The Proto function *cannot* be static
Function ListBoxProto(LB_Struct) : ListboxControl 
	STRUCT WMListboxAction &LB_Struct
	// XXX throw error  if we are here
End Function

Function SetVarProto(SV_Struct) : SetVariableControl 
	STRUCT WMSetVariableAction &SV_Struct
End Function

// The Proto function *cannot* be static
Function ButtonProto(LB_Struct) : ButtonControl 
	STRUCT WMButtonAction &LB_Struct
	// XXX throw error  if we are here
End Function

Function PopupMenuProto(PU_Struct) : PopupMenuControl
   STRUCT WMPopupAction &PU_Struct
End Function

// Options prototype for populating Popup MEnu
Function/S PopupMenuListProto()
	return ""
End Function

Function CheckboxProto(CB_Struct) : CheckBoxControl 
	STRUCT WMCheckboxAction &CB_Struct
End Function

Static Function SetVariableStrOrNum(panelName,isStr,[sVal,dVal])
	String panelName,sVal
	Variable isStr,dVal
	// Initialize the setvariable value..
	if (paramIsDefault(sVal))
		sVal = ModDefine#DefBadRetStr()
	EndIf 
	dVal = ParamIsDefault(dVal) ? ModDefine#DefBadRetNum() : dVal
	// Use the internal "SetVariable" scheme. See: V-582
	if (isStr)
		SetVariable $panelName value=_STR:sVal
	Else
		SetVariable $panelName value=_NUM:dVal
	EndIf
End Function

Static Function SetVariableStrOrNumWave(panelName,mWave,[index,mLabel])
	String panelName,mLabel
	Wave mWave
	Variable index
	if (!ParamIsDefault(mLabel))
		index = FindDimLabel(mWave,0,mLabel)
	EndIf
	if (ParamIsDefault(mLabel) && paramIsDefault(index) || (index < 0))
		ModErrorUtil#DevelopmentError(description="Bad Set variable index...")
	EndIf
	// POST: know the index
	SetVariable $panelName value=mWave[index]
End Function

Static Function /S SetVariableValue(param,panelName)
	Struct Parameter &param
	String panelName
	SetVariableStrOrNum(panelName,ModModelDefines#IsStrParam(param))
End Function

Static Function /S GetParamPanelName(i)
	Variable i
	// i is the parameter index, between 0 and (N-1), where N is the number of panels
	// XXX throw error, add in N?
	String toRet
	sprintf toRet,VIEW_PARAM_FMT,i
	return toRet
End Function

Static Function /S GetParamSaveName(mParam)
	Struct Parameter & mParam	
	String toRet
	sprintf toRet,"RP%d_%s_%s",mParam.repeatNumber,GetParamPanelName(mParam.ParameterNumber),mParam.name
	return toRet
End Function

Static Function  /S ActivateParamByID(i)
	Variable i
	String id = GetParamPanelName(i)
	// Activate the specific panel
	SetVariable $id activate
End Function

Static Function MakeButton(ctrlName,titleStr,helpStr,posx,posy,width,height,mProc,[hAbs,wAbs,fontSize,fontName])
	String ctrlName,helpStr,titleStr,fontName
	Variable posx,posy,width,height,hAbs,wAbs,fontsize
	FuncRef ButtonProto mProc
	fontSize = ParamIsDefault(fontSize) ? ModIoUtil#DefFontSize() : fontSize
	if (ParamIsDefault(FontName))
		FontName = ModIoUtil#DefFontName()
	EndIf
	if (!paramIsDefault(hAbs) && !paramIsDefault(wAbs))
		// then multiply all the positions to get absolute weights
		 ConvertRelativeToAbs(posX,posY,width,height,wAbs,hAbs)
	endif
	String mFuncName = ModIoUtil#GetFuncName(FuncRefInfo(mProc))
	Button $ctrlName,pos={posx,posy},size={width,height},proc=$(mFuncName)
	Button $ctrlName,font="Monaco",fsize=(fontsize)
	Button $ctrlName title=titleStr,help={(helpStr)}
End Function

Static Function ConvertRelativeToAbs(posxRel,posyRel,widthRel,HeightRel,absX,absY)
	Variable &posXRel, &posYRel,&widthRel,&heightRel
	Variable absX,absY
	// multiply the [0,1] x values by the absolute width
	posxRel *= AbsX
	widthRel *= AbsX
	// multiplty rhe [0,1] y values by the absolute height
	posyRel *= AbsY
	heightRel *= AbsY
End Function


Static Function MakeListBox(name,helpText,mWave,posx,posy,width,height,mProc,[selWave,AllowResize,mFont,SelectionMode,wAbs,hAbs])
	// Makes a postbox at (posx,posy) with height and width, using the rest of the parameters for the listbox control
	// Note: if hAbs and wAbs are present, x,y,height, and width are assumined between 0 and 1
	Wave /T mWave
	Wave selWave
	FuncRef ListBoxProto mProc
	Struct Font &mFont
	String name,helpText
	Variable posx,posy,width,height,AllowResize,SelectionMode,hAbs,wAbs
	// Make a local variable, in case no font is passed in
	// XXX fix this, somehow? have to pass it in by reference, cnt pass null reference to function...
	Struct Font fontToUse
	if (!paramIsDefault(hAbs) && !paramIsDefault(wAbs))
		// then multiply all the positions to get absolute weights
		 ConvertRelativeToAbs(posX,posY,width,height,wAbs,hAbs)
	endif
	// Make the font, if they need if
	if (ParamIsDefault(mFont))
		ModIoUtil#FontDefault(fontToUse)
	Else 
		fontToUse = mFont
	EndIf
	if (ParamIsDefault(AllowResize))
		AllowResize = VIEW_DEF_LISTBOX_RESIZE
	EndIf
	if (ParamIsDefault(SelectionMode))
		SelectionMode = VIEW_DEF_LISTBOX_SELECT
	EndIf
	String mFuncName = ModIoUtil#GetFuncName(FuncRefInfo(mProc))
	ListBox $name,pos={posx,posy},size={width,height},proc=$mFuncName,listWave=mWave
	ListBox $name,userColumnResize=AllowResize,mode=SelectionMode
	ListBox $name,font="Monaco",fsize=fontToUse.FontSize
	// record the selection wave, if we need to.
	if (!ParamIsDefault(selWave))
		ListBox $name, selWave=selWave
	EndIf
End Function

Structure ViewOptions
	Struct pWindow Win
EndStructure

Static Function InitViewOpt(ToInit,[WidthRatio,HeightRatio])
	// WidthRatio is the fraction of the screen width to take up
	// HEight ratio is the fracton of the screen height to take up
	Struct ViewOptions &ToInit
	Variable WidthRatio,HeightRatio
	// Get the width and height (pass by reference)
	WidthRatio = ParamIsDefault(WidthRatio) ? 0.8: WidthRatio
	HeightRatio = ParamIsDefault(HeightRatio) ? 0.8 : HeightRatio
	Variable width,height
	ModIoUtil#GetScreenHeightWidth(width,height)	
	ModViewUtil#InitWindow(ToInit.win,width,height,WidthRatio,HeightRatio)
End Function	

Static Function InitWindowFull(Win,left,top,right,bottom)
	Struct pWindow &Win
	Variable left,top,right,bottom
	Win.width = right-left
	Win.height = bottom-top
	Win.left = left
	Win.top = top
	Win.right = right
	Win.bottom = bottom
End Function

Static Function InitWindowFrac(Win,Width,Height,Left,Top,Right,Bottom)
	Struct pWindow &Win
	Variable Width,Height,left,top,right,bottom
	InitWindowFull(Win,floor(left*width),floor(top*height),floor(right*width),floor(bottom*height))
End Function

Static Function InitWindow(Win,width,height,WidthRatio,HeightRatio)
	// Win: The new window
	// width/height: the absolute width and height
	// widthRatio/HeightRatio : the fraction of the width and height to take up
	// Top/Left: the fraction to offset the top and left into
	Struct pWindow &Win
	Variable width,height,WidthRatio,HeightRatio
	Variable Left,Top,Right,Bottom
	// XXX add in ratios as default?
	// XXX check that we are below 1
	// Figure out the left,top,right, and bottom of the Win
	Variable HorizontalEdge = (1.-WidthRatio)/2.
	Variable VerticalEdge = (1.-HeightRatio)/2.
	Left = (HorizontalEdge)
	Top = (VerticalEdge)
	Right = (1-HorizontalEdge)
	Bottom = (1-VerticalEdge)
	InitWindowFrac(Win,Width,Height,Left,Top,Right,Bottom)
End Function

Static Function MakeSetVariable(panelName,mTitle,helpStr,x,y,width,height,mProc,[wAbs,hAbs,format,font,userdata,type])
		// Set the font and XY
		String panelName,mTitle,helpStr,format,userdata
		Variable x,y,width,height,wAbs,hAbs,type
		FuncRef SetVarProto mProc
		Struct Font & font
		Struct Font toUse
		// Make sure the font is OK
		if (paramIsDefault(font))
			ModIoUtil#FontDefault(toUse)
		Else
			toUse = font
		Endif
		// Ensure we have a proper type
		type = ParamIsDefault(type)?  SETVAR_TYPE_NUMERIC : type
		// make sure the format is OK
		if (paramIsDefault(format))
			// get the true type
			switch (type)
				case SETVAR_TYPE_NUMERIC:
					format = DEF_FMT_NUM
					break
				case SETVAR_TYPE_STRING:
					format = SETVARIABLE_STR_FORMAT
					break
				default: 
					ModErrorUtil#DevelopmentError(description="Bad setVariable type")
					break
			EndSwitch
		EndIF
		// check if x,y,height,width are relative or absolute
		if (!paramIsDefault(hAbs) && !paramIsDefault(wAbs))
		// then multiply all the positions to get absolute weights
			 ConvertRelativeToAbs(x,y,width,height,wAbs,hAbs)
		endif
		SetVariable $(panelName) format=format
		SetVariable $(panelName) font="Monaco"
		SetVariable $(panelName) fsize=toUse.FontSize
		SetVariable $(panelName) pos={x,y},size={width,height}
		// Set the userdata to the parameter number, if it exists
		if (!ParamIsDefault(userdata))
			SetVariable $(panelName) userdata=userdata
		endIf
		// Set the title and help
		SetVariable $(panelName) title=mTitle, help={helpStr}
		// Set the handler function. For the parameters, this is 
		// All the same
		String mFuncName = ModIoUtil#GetFuncName(FuncRefInfo(mProc))
		SetVariable $(panelName) proc=$(mFuncName)
End Function

Static Function SetPopupValue(popupName,mVal)
	String popupName,mVal
	// According to V-506, we need this for a function call
	PopupMenu $(popupName) value=#("\"" + mVal + "\"")
End Function

Static Function EnablePopup(popupName)
	String popupName
	PopupMenu $(popupName) disable=(CONTROL_ENABLE)
End Function

Static Function DisablePopup(popupName)
	String popupName
	PopupMenu $(popupName) disable=(CONTROL_DISABLE)
End Function

Static Function MakeCheckBox(panelName,mTitle,helpStr,x,y,width,height,mProc,[wAbs,hAbs,userdata])
		String panelName,mTitle,helpStr,userdata
		Variable x,y,width,height,wAbs,hAbs
		FuncRef CheckboxProto mProc
		// check if x,y,height,width are relative or absolute
		if (!paramIsDefault(hAbs) && !paramIsDefault(wAbs))
		// then multiply all the positions to get absolute weights
			 ConvertRelativeToAbs(x,y,width,height,wAbs,hAbs)
		endif
		String mFontName = "Monaco"
		CheckBox $(panelName) side=(DEF_SIDE_CHECK)
		CheckBox $(panelName) pos={x,y}
		CheckBox $(panelName) size={width,height}		
		// Set the userdata to the parameter number, if it exists
		if (!ParamIsDefault(userdata))
			CheckBox $(panelName) userdata=userdata
		endIf
		// Set the title and help
		CheckBox $(panelName) title=mTitle, help={helpStr}
		CheckBox $(panelName) font="Monaco"
		CheckBox $(panelName) fsize=(DEF_FONTSIZE)
		// Set the handler function. For the parameters, this is 
		// All the same
		String mFuncHandlerName = ModIoUtil#GetFuncName(FuncRefInfo(mProc))
		CheckBox $(panelName) proc=$(mFuncHandlerName)
End Function

Static Function MakePopupMenu(panelName,mTitle,helpStr,x,y,width,height,mProc,mStr,[wAbs,hAbs,format,font,userdata])
		// NOte: mStr is a *function* returning a list of semi-colon separated list
		// See: MAkeSetVariable
		String panelName,mTitle,helpStr,format
		Variable x,y,width,height,wAbs,hAbs,userdata
		FuncRef PopupMenuProto mProc
		FuncRef PopupMenuListProto mStr
		Struct Font & font
		Struct Font toUse
		// Make sure the font is OK
		if (paramIsDefault(font))
			ModIoUtil#FontDefault(toUse)
		Else
			toUse = font
		Endif
		// make sure the format is OK
		if (paramIsDefault(format))
			format = ""
		EndIF
		String mFuncListName
		// check if x,y,height,width are relative or absolute
		if (!paramIsDefault(hAbs) && !paramIsDefault(wAbs))
		// then multiply all the positions to get absolute weights
			 ConvertRelativeToAbs(x,y,width,height,wAbs,hAbs)
		endif
		String mFontName = "Monaco"
		Variable bodyWidth = width-FontSizeStringWidth(mFontName,toUse.fontSize,toUse.fontStyle,mTitle)
		PopupMenu $(panelName) format=format
		PopupMenu $(panelName) bodyWidth=(bodyWidth)
		PopupMenu $(panelName) font="Monaco"
		PopupMenu $(panelName) fsize=toUse.FontSize
		PopupMenu $(panelName) pos={x,y},size={width,height}
		// XXX sanitize string?
		String mVal = mStr()
		SetPopupValue(panelName,mVal)
		// Set the userdata to the parameter number, if it exists
		if (!ParamIsDefault(userdata))
			PopupMenu $(panelName) userdata=num2str(userdata)
		endIf
		// Set the title and help
		PopupMenu $(panelName) title=mTitle, help={helpStr}
		// Set the handler function. For the parameters, this is 
		// All the same
		String mFuncHandlerName = ModIoUtil#GetFuncName(FuncRefInfo(mProc))
		PopupMenu $(panelName) proc=$(mFuncHandlerName)
End Function


Static Function SetParamStruct(paramToSet,pathToParam)
	// Set the parameter located at "pathToParam" to "ParamToSet"
	Struct Parameter & paramToSet
	String  pathToParam
	// XXX make save directory setting default?
	// Ensure the path we want exists
	String fullPath = ModIoUtil#GetDirPathFromFilePath(pathToParam)
	ModIoUtil#EnsurePathExists(fullPath)
	// POST: the path we are saving to exists.
	if (!WaveExists($pathToParam))
		Make /O/N=0 $pathToParam
	EndIf
	// POST: mName is an existing wave
	// put 'paramtoSet' into $mName
	StructPut /B=(ModDefine#StructFmt()) paramToSet, $pathToParam
End Function

Static Function GetParamStruct(paramToGet,mName)
	Struct Parameter & paramToGet
	String mName
	// XXX throw error if mName isn't a wave
	// put '$mName' into 'paramToGet'
	StructGet /B=(ModDefine#StructFmt()) paramToGet, $mName
End Function

Static Function SetStringVariableColumn(panels,names,helpStr,startXRel,startyRel,widthRel,heightRel,commonHandle,wabs,habs,userdata)
	// Panels: the names of the controls
	// Names:  the names to show the users
	// Helpstr: what to show the user
	// All else related to geometry, same as MakeSetVariable, 
	// except commonahndle, which is a handle for a setvariable interface
	//Call SetVariable Column, with same Strings
	Wave /T panels
	Wave /T names
	Wave /T helpStr
	Wave userdata
	Variable startXRel,startyRel,heightRel,widthRel,habs,wabs
	FuncRef SetVarProto & commonHandle
	// Need to make the type and height/width waves
	Variable nPanels = DimSize(panels,0)
	Make /O/N=(nPanels) mTypes,mHeight
	// MAke the type
	mTypes[0,nPanels-1] = SETVAR_TYPE_STRING
	mHeight[0,nPanels-1] = heightRel
	SetVariableColumn(panels,names,helpStr,startXRel,startyRel,widthRel,mHeight,commonHandle,wabs,habs,userdata,mTypes)
	KillWaves /Z mTypes,mHeight
End Function

// function which creates a new window, returns its name
Static Function /S CreateNewWindow(width,height,[windowName])
	Variable width,height
	String windowName
	if (ParamIsDefault(windowName))
		windowName = ModIoUtil#UniquePanelWindowName("pWin")
	EndIf
	// Get  a proper name
	ModIoUtil#SafeKillWindow(windowName)
	// Get the screen size
	Variable wAbsScreen,hAbsScreen
	ModViewUtil#GetScreenWidthHeight(wAbsScreen,hAbsScreen)
	Variable wAbsSetter = width * wAbsScreen
	Variable hAbsSetter = height * hAbsScreen
	NewPanel /W=(0,0,wAbsSetter,hAbsSetter) /N=$(windowName)
	return windowName
End Function

Static Function SetVariableColumn(panels,names,helpStr,startXRel,startyRel,widthRel,heightRel,commonHandle,wabs,habs,userdata,types)
	// See SetStringVariableColumn, except:
	// type is a wave of string/numvals
	// heightRel is a wave, so we can have variable sized fields
	// Note that width is a constant (this is just a column!)
	Wave /T panels
	Wave /T names
	Wave /T helpStr
	Wave userdata,heightRel,types
	Variable startXRel,startyRel,widthRel,habs,wabs
	FuncRef SetVarProto & commonHandle
	Variable i=0
	Variable nVariables = DimSize(names,0)
	Variable xRel = startXRel
	Variable yRel = startYRel
	for (i=0; i <nVariables; i+= 1)
		String mData = num2str(userdata[i])
		String fmt
		if (types[i] == SETVAR_TYPE_NUMERIC)
			fmt = DEF_FMT_NUM
		else
			fmt = SETVARIABLE_STR_FORMAT
		endIf
		ModViewUtil#MakeSetVariable(panels[i],names[i],helpStr[i],xRel,yRel,widthRel,heightRel[i],commonHandle,habs=hAbs,wAbs=wAbs,format=fmt,userdata=mData,type=types[i])
		yRel += heightRel[i]
	EndFor
End Function

Static Function SetPopupColumn(panels,names,helpStr,mOptFuncs,startXRel,startyRel,widthRel,heightRel,commonHandle,wabs,habs,userdata)
	// All Like Set StringVariableColumn
	// Except "mOptFuncs", the functions giving the options for the Molecule types and IDs.
	Wave /T panels
	Wave /T names
	Wave /T helpStr
	Wave /T mOptFuncs 
	Wave userdata
	Variable startXRel,startyRel,heightRel,widthRel,habs,wabs
	FuncRef PopupMenuProto & commonHandle
	Variable i=0
	Variable nVariables = DimSize(names,0)
	for (i=0; i <nVariables; i+= 1)
		Variable xRel = startXRel
		Variable yRel = startyRel + i*heightRel
		FuncRef PopupMenuListProto mFunc = $(mOptFuncs[i])
		ModViewUtil#MakePopupMenu(panels[i],names[i],helpStr[i],xRel,yRel,widthRel,heightRel,commonHandle,mFunc,wAbs=wabs,hAbs=habs,userdata=userdata[i])
	EndFor
End Function

Static Function GetScreenWidthHeight(width,height,[mOpt])
	Variable & width 
	Variable & height
	Struct ViewOptions & mOpt
	Struct ViewOptions toUse
	if (ParamIsDefault(mOpt))
		ModViewUtil#InitViewOpt(toUse)
	else
		toUse = mOpt
	EndIf
	height = toUse.win.height
	width = toUse.win.width
End Function

// Populates mWaveRef with all controls in mWindow
Static Function GetAllControlsInWindow(mWaveRef,MWindow)
	String mWaveRef,mWindow
	String mSep = ModDefine#DefListSep()
	String mControls = ControlNameList(mWindow,mSep)
	Variable nControls = ItemsInList(mControls,mSep)
	Redimension /N=(nControls) $mWaveRef 
	Wave /T toPop = $mWaveRef
	ModDataStruct#ListToTextWave(toPop,mControls,sep=mSep)
End Function

Static Function UpdateAllControls(ListToDisable,Enable)
	Wave /T ListToDisable
	Variable enable
	Variable nToDisable = DimSize(ListToDisable,0)
	Variable i
	For (i=0; i<nToDisable;i+=1)
		ModifyControl $(ListToDisable[i]) disable=(enable)
	EndFor
End Function

Constant VIEW_SETVAR = 0
Constant VIEW_CHECK= 1
Constant VIEW_POPUP= 2
Constant VIEW_BUTTON = 3

// viewTitle: the title for this view
//widthRel,heightRel : width and height, relative to the host window
// viewType: one of supported types (see above)
// (optional belpw)
//mProc,: callbak on actions
// mOptStr: What string to initially set a setvar to
// mOptNum: What num to intiially set a setvar tro 
// setVarType: string, number
//startXRel,startYRel: where to start this view. defaults to 0,0 (relative to host
//yUpdated,xUpdated: the ending coordinates, given the start and height. useful for looping
//panelName: name of the control panel that will be madde
//helpStr: text user sees on hover
//windowName: where to put the panel. defaults to current / top window
//userData: userdata gets passed along on callbacks
//waveSetVar,labelSetVar: for a setvariable, rather than using a number or string, sets a wave value directly, using the given label
// padbyList: a list of titles; this title is padded with spaces at the end so things are right aligned
Static Function AddViewEle(viewTitle,widthRel,heightRel,viewType,[mProc,mOptStr,mOptNum,setVarType,startXRel,startYRel,yUpdated,xUpdated,panelName,helpStr,windowName,userData,waveSetVar,labelSetVar,padByList])
	String viewTitle,panelName,helpStr,windowName,userData
	Variable widthRel,heightRel,startXRel,startYRel
	Variable &yUpdated,&xUpdated
	Variable viewType,setVarType,mOptNum
	Wave WaveSetVar
	Wave /T PadByList
	String mOptStr,mProc,labelSetVar
	// Determine the optional values for everything given
	if (ParamIsDefault(mProc))
		mProc = ""
	EndIf
	if (ParamIsDefault(startYRel))
		startYRel = 0 
	EndIf
	if (ParamIsDefault(startXRel))
		startXRel = 0 
	EndIf
	if (ParamIsDefault(windowName))
		windowName = ModPlotUtil#gcf()
	EndIf
	if (ParamIsDefault(	panelName))
		panelName = ModIoUtil#UniqueControlName("Panel")
	EndIf
	if (ParamIsDefault(helpStr))
		helpStr = ""
	EndIf
	if (ParamIsDefault(userData))
		userData = panelName
	EndIf
	if(!ParamIsDefault(PadByList))
		Make /O/N=(DimSize(PadByList,0)) ViewUtilPadLengths
		ViewUtilPadLengths[] = strlen(PadByList[p])
		Variable maxLen = WaveMax(ViewUtilPadLengths)
		Variable thisLen = strlen(viewTitle)
		Variable nToAdd = max(maxLen-thisLen,0)
		Variable i =0
		// add spaces to match everything 
		// XXX assume monospaced font
		for (i=0; i< nToAdd; i+=1)
			viewTitle += " "
		Endfor
		// Kill the wave
		KillWaves /Z ViewUtilPadLengths
	EndIf
	// get the window (absolute) dimensions
	Variable left,top,right,bottom
	ModIoUtil#GetWindowLeftTopRightBottom(windowName,left,top,right,bottom)
	Variable wAbs = abs(right-left)
	Variable hAbs = abs(top-bottom)
	Variable xRel = startXRel
	Variable yRel = startYRel
	Variable type
	// XXX check if string and num are both set?
	Variable setByWave = ModDefine#False()
	if (!ParamIsDefault(mOptStr))
		type = SETVAR_TYPE_STRING
	elseif (!ParamIsDefault(mOptNum))
		type = SETVAR_TYPE_NUMERIC
	elseif (!ParamIsDefault(WaveSetVar) && !ParamIsDefault(labelSetVar))
		// XXX assume wave is numeric for now
		type = SETVAR_TYPE_NUMERIC
		setByWave = ModDefine#True()
	else
		// both are default
		type = SETVAR_TYPE_NONE_GIVEN
	endIf
	// Make the actual view element, depending on what type it is
	switch (viewType)
		case VIEW_SETVAR:
			// Set variable!  For this, we also may need to put something in the box.
			FuncRef SetVarProto mProcRef = $mProc
			MakeSetVariable(panelName,viewTitle,helpStr,xRel,yRel,widthRel,heightRel,mProcRef,wAbs=wAbs,hAbs=hAbs,userdata=userData,type=type)
			// put the optional value in the set variable
			if (type != SETVAR_TYPE_NONE_GIVEN)
				if (setByWave)
					// then set by wave!
					SetVariableStrOrNumWave(panelName,WaveSetVar,mLabel=labelSetVar)
					break
				EndIf
				// POST: setting either a string or a number (not to a wave)
				Variable isStr = (type == SETVAR_TYPE_STRING)
				if (isStr)
					SetVariableStrOrNum(panelName,isStr,sVal=mOptStr)
				else 
					SetVariableStrOrNum(panelName,isStr,dVal=mOptNum)				
				endIf
			endIf
			break
		case VIEW_CHECK:
			// Checkbox. Pretty simple...
			FuncRef CheckboxProto mProcCheck = $mProc
			MakeCheckBox(panelName,viewTitle,helpStr,xRel,yRel,widthRel,heightRel,mProcCheck,wAbs=wAbs,hAbs=hAbs,userdata=userdata)
			break
		case VIEW_POPUP:
			// *must* be given mOptStr, otherwise popup can't go!
			if (ParamIsDefault(mOptStr))
				ModErrorUtil#DevelopmentError(description="Popup recquires mOptStr to be function giving semi-colon delimited list")
			EndIF
			FuncRef PopupMenuProto funcRefPop = $mProc
			FuncRef PopupMenuListProto mStr = $mOptStr
			MakePopupMenu(panelName,viewTitle,helpStr,xRel,yRel,widthRel,heightRel,funcRefPop,mStr,wAbs=wAbs,hAbs=hAbs,userdata=str2num(userData))
			break
		case VIEW_BUTTON:
			// Button element. also pretty straightforward
			FuncRef ButtonProto mProcButton = $mProc
			MakeButton(panelName,viewTitle,helpStr,xRel,yRel,widthRel,heightRel,mProcButton,hAbs=hAbs,wAbs=wAbs)
			break
		default:
			ModErrorUtil#OutOfRangeError(description="Unknown View Type.")
			break
	endSwitch
	// POST: view element was made
	// update the ending x and y, if the user wanted to 
	if (!ParamIsDefault(yUpdated))
		yUpdated = startyRel + heightRel
	endIf
	if (!ParamIsDefault(xUpdated))
		xUpdated =  startXRel + widthRel
	EndIf
	// That's all!
End Function