// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#pragma ModuleName = ModViewUtil
#include "::Util:IoUtil"
#include "::Model:ModelDefines"

// Default for ListBox
Constant VIEW_DEF_LISTBOX_RESIZE = 1
//m=0: No selection allowed.
//m=1: One or zero selection allowed.
//m=2: One and only one selection allowed.
//m=3: Multiple, but not disjoint, selections allowed.
//m=4: Multiple and disjoint selections allowed.
Constant VIEW_DEF_LISTBOX_SELECT = 1
Constant VIEW_LISTBOX_SINGLE_SEL = 1
// Events for list
Constant EVENT_LIST_DOUBLE_CLICK = 3
Constant EVENT_LIST_SEL = 4
Constant EVENT_LIST_KEYSTROKE = 12
// Events for Button (pp 42 of igor manual)
Constant EVENT_BUTTON_MUP_OVER= 2
// Events for SetVariable
Constant EVENT_SETVAR_ENTER = 2
// Keystrokes
Constant KEYSTROKE_CONTROL_A =  1
Constant KEYSTROKE_SHIFT_ENTER= 13
// For Window handler
Constant EVENT_WINDOW_KEYSTROKE = 11
// If Igor should or should not handle the event
Constant EVENT_HANDLED = 1
Constant EVENT_NOT_HANDLED = 0
// Popup constants. V-503: on mode of 0, title is in popupmenu
Constant EVENT_POPUP_MOUSEUP = 2
Constant POPUP_MENU_TITLE_MODE = 1
Constant LISTBOX_HEIGHT_REL = 0.35, LISTBOX_WIDTH_REL =0.4, graphWidth = 0.4, graphHeight = 0.4
// Relative meta params height and width
Constant META_WIDTH_REL = 0.3
Constant BUTTON_HEIGHT_REL = 0.05
Constant SETVAR_HEIGHT_REL = 0.05
Constant SETTER_HEIGHT_REL = 0.9
Constant SETTER_WIDTH_REL = 0.5
// Constants related to view
// XXX should have a view registry or something, keep tract that way, instead of hard-coding.
Constant NLoadBUttons = 4
Constant nMeta =  4
// Types for setvariable: numeric and string
Constant SETVAR_TYPE_NUMERIC = 1
Constant SETVAR_TYPE_STRING = 2

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
	sprintf toRet,"RP%d_%s_%s",mParam.repeatNumber,GetParamPanelName(mParam.id),mParam.name
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
	Button $ctrlName,font="Helvetica",fsize=(fontsize)
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


Static Function MakeListBox(name,helpText,mWave,posx,posy,width,height,mProc,[AllowResize,mFont,SelectionMode,wAbs,hAbs])
	// Makes a postbox at (posx,posy) with height and width, using the rest of the parameters for the listbox control
	// Note: if hAbs and wAbs are present, x,y,height, and width are assumined between 0 and 1
	Wave /T mWave
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
	ListBox $name,font="Helvetica",fsize=fontToUse.FontSize
End Function


Static Function /S DisplayGen(xAbsI,yAbsI,xAbsF,yAbsF,[hostname,graphName])
	Variable xAbsI,yAbsI,xAbsF,yAbsF
	String hostname,graphName
	// Make sure we have the parameters we need.
	if (ParamIsDefault(graphName))
		// Then get a new graph name
		graphName = ModIoUtil#UniqueGraphName("prhGraph")
	EndIf
	if (ParamISDefault(hostname))
		Display /W=(xAbsI,yAbsI,xAbsF,yAbsF)/N=$(GraphName) 			
	else
		Display /W=(xAbsI,yAbsI,xAbsF,yAbsF)/N=$(GraphName) 	/HOST=$(hostName)
	EndIf
	return graphName
End Function

// Returns the name of the screen displayed
Static Function /S DisplayRelToScreen(xRel,yRel,widthRel,heightRel)
	Variable xRel,yRel,widthRel,heightRel
	Variable width,height
	ModIoUtil#GetScreenHeightWidth(width,height)	
	// POST: we have the screen height, no ahead and get the rest.
	Variable xAbsI,yAbsI,xAbsF,yAbsF
	SetAbsByRelAndAbs(xRel,yRel,widthRel,heightRel,width,height,xAbsI,yAbsI,xAbsF,yAbsF)
	return DisplayGen(xAbsI,yAbsI,xAbsF,yAbsF)
End Function

// Set the absolute X,Y locations by relative X/Y/Width/Height and absolute width/height.
// Useful for sizing based on a screen. Note that the final 4 parameters (sent to displayGen)
// are pass by reference
Static Function SetAbsByRelAndAbs(xRel,yRel,widthRel,heightRel,abswidth,absHeight,xAbsI,yAbsI,xAbsF,yAbsF)
	Variable xRel,yRel,widthRel,heightRel,abswidth,absHeight
	Variable & xAbsI, &yAbsI,&xAbsF,&yAbsF // Reference!
	 xAbsI = xRel * absWidth
	 yAbsI = yRel*absHeight
	 xAbsF = xAbsI + widthRel * absWidth
	 yAbsF = yAbsI + heightRel * absHeight
End Function

Static Function DisplayRel(hostName, GraphName,mWindow,xRel,yRel,widthRel,heightRel)
	Struct pWindow &mWindow
	String hostName,GraphName
	Variable xRel,yRel,widthRel,heightRel
	// Determine the absolute left top right bottom coordinates
	Variable absHeight = mWindow.height
	Variable absWidth = mWindow.width
	Variable xAbsI,yAbsI,xAbsF,yAbsF
 	SetAbsByRelAndAbs(xRel,yRel,widthRel,heightRel,abswidth,absHeight,xAbsI,yAbsI,xAbsF,yAbsF)
	// Make the display as usual
	DisplayGen(xAbsI,yAbsI,xAbsF,yAbsF,hostname=hostname,graphname=graphName)
End Function

Structure pWindow
	Variable width,height
	Variable Left,Top,Right,Bottom
EndStructure

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
		// XXX make the format specifiable
		// XXX assumes numeric in the format
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
					format = DEF_FMT_STR
					break
			EndSwitch
		EndIF
		// check if x,y,height,width are relative or absolute
		if (!paramIsDefault(hAbs) && !paramIsDefault(wAbs))
		// then multiply all the positions to get absolute weights
			 ConvertRelativeToAbs(x,y,width,height,wAbs,hAbs)
		endif
		SetVariable $(panelName) format=format
		SetVariable $(panelName) font="Helvetica"
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
		String mFontName = "Helvetica"
		Variable bodyWidth = width-FontSizeStringWidth(mFontName,toUse.fontSize,toUse.fontStyle,mTitle)
		PopupMenu $(panelName) format=format
		PopupMenu $(panelName) bodyWidth=(bodyWidth)
		PopupMenu $(panelName) font="Helvetica"
		PopupMenu $(panelName) fsize=toUse.FontSize
		PopupMenu $(panelName) pos={x,y},size={width,height}
		// XXX sanitize string?
		String mVal = mStr()
		// According to V-506, we need this for a function call
		PopupMenu $(panelName) value=#("\"" + mVal + "\"")
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
		ModViewUtil#MakeSetVariable(panels[i],names[i],helpStr[i],xRel,yRel,widthRel,heightRel[i],commonHandle,habs=hAbs,wAbs=wAbs,format=SETVARIABLE_STR_FORMAT,userdata=mData,type=types[i])
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

Static Function /S GetDefinedMolecules()
	// XX use a sql call
	 String Molecules = "CircularDNA;Proteins;"
	 return Molecules
End Function

Static Function /S GetDefinedSamplesIDs()
	String SampleID = "TODO" //Created:2015-06-04,Deposited:2015-06-16,130nguL;Created 2015-06-30,Desposited:2015-07-01,130nguL;"
	return SampleID
End Function

Static Function /S GetDefineTipTypes()
	String TipType = "Long;Mini;"
	return TipType
End Functio

Static Function /S GetTipID()
	 String TipID = "Created:2015-06-04;Created:2016-06-04;"
	return TipID
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
