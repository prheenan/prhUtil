// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModPlotUtil

Constant  ColorMax = 65535
Constant PredefinedColors = 7
// Constants for making the figure
Constant DEF_DISP_H_HIDE = 1 // Don't show the window by default; assume we are saving
Constant DEF_DISP_DPI = 400 // Dots per Inch
Constant DEF_DISP_HEIGHT_IN = 12 // Inches
Constant DEF_DISP_WIDTH_IN = 10 // Inches
StrConstant DEF_FONT_NAME = "Helvetica"
// Constants for saving the figure
// See: SavePICT, pp 558 of igor manual
Constant DEF_FIG_TRANSPARENT = 0
Constant DEF_FIG_GFX_FMT = -5 // uses PNG
Constant DEF_FIG_CLOSE_ON_SAVE =1 // True. XXX wll need to be changed if true changes
StrConstant DEF_FIG_SAVEPATH = "home"
// Default Graph name; Gets the uniqueName
StrConstant DEF_DISP_NAME = "UtilDisp"
// XXX move to util?
//  pp 729 of igor pro, UniqueName object type for graph
Constant DEF_UNINAME_GRAPH = 6 
// Constants for graph font defaults
Constant DEF_FONT_TITLE = 40
Constant DEF_FONT_AXIS = 24
Constant DEF_FONT_LEGEND = 26
// TextBox, p 710 of igor manual
Constant DEF_TBOX_FRAME = 0 // Default, no Frame.
// For identifying the axes / general methods
StrConstant X_AXIS_DEFLOC = "bottom"
StrConstant Y_AXIS_DEFLOC = "left"
// TraceNameList: optionsflag, igor manual V-726
// Include normal graph traces, do *not* omit hidden traces
Constant TRACENAME_INCLUDE_ALL = 3
// Drawlayer graph,, V-571
StrConstant DRAW_LAYER_GRAPH = "UserFront"
// WinList,  V-758
StrConstant WINLIST_GRAPHS = "WIN:1" // kills all graphs

Structure PlotFormat
	// RGB color
	Struct RGBColor rgb
	// transparency
	Variable alpha	
	// Line style
	Variable DashPattern
	// thickness
	Variable Thickness
	// XXX probably want to add in a 'give legend' or something
	// like that.
EndStructure

// Defines for plotting (XXX move to plotUtil?
Structure ColorMapDef
	// Color Maps
	String GREY 
	String TERRAIN 
	String HEAT
EndStructure

Structure ColorDefaults
	// Red, Yellow, Green
	Struct RGBColor Red
	Struct RGBColor Gre
	Struct RGBColor Blu
	Struct RGBColor Yel
	Struct RGBColor Bla
	Struct RGBColor Pur
	Struct RGBColor Ora
	Struct RGBColor AllColors[PredefinedColors]
EndStructure

Static Function InitCmap(cmap)
	Struct ColorMapDef &cmap
	cmap.GREY = "Grays256"
	cmap.TERRAIN = "Terrain256"
	cmap.HEAT = "YellowHot256"
End Function

Static Function InitDefColors(colors)
	Struct ColorDefaults & colors
	InitRGB_Dec(colors.Red,1.0,0,0)
	InitRGB_Dec(colors.Gre,0,1.0,0)
	InitRGB_Dec(colors.Blu,0,0,1.0)
	// these values from http://www.december.com/html/spec/colorcodes.html
	// Sign Yellow
	InitRGB_Dec(colors.Yel,0.99,0.82,0.9)
	InitRGB_Dec(colors.Bla,0,0,0)
	// indigo
	InitRGB_Dec(colors.Pur,0.5,0.0,0.5) 
	// Orange Crush
	InitRGB_Dec(colors.Ora,0.97,0.46,0.19)
	// save all the predefined colors, for looping
	// Note: i gets passed by reference and incremented
	Variable i=0
	AddColor(colors,colors.Red,i)
	AddColor(colors,colors.Gre,i)
	AddColor(colors,colors.Blu,i)
	AddColor(colors,colors.Pur,i)
	AddColor(colors,colors.Bla,i)
	AddColor(colors,colors.Yel,i)
	AddColor(colors,colors.Ora,i)
End Function

Static Function Grey(toGet,[transparency])
	Struct RGBColor &toGet
	Variable transparency
	transparency = ParamIsDefault(transparency) ? 0.8 : transparency
	InitRGB_Dec(toGet,transparency,transparency,transparency)
End Function

Static Function Red(toGet)
	Struct RGBColor &toGet
	InitRGB_Dec(toGet,1.0,0,0)
End Function

Static Function InitRGB(RGB,Red,Green,Blue)
	// Initialize RBG From values between 0 and COLORMAX
	// RBG Is the structure to initialize
	// XXX check that values are in the right range?
	Struct RGBColor &RGB
	Variable Red,Green,Blue
	RGB.red = Red
	RGB.green = Green
	RGB.blue = Blue
End Function

Static Function InitRGB_Dec(RGB,Red,Green,Blue)
	// Red,Green,And Blue and between 0 and 1.0
	Struct RGBColor &RGB
	Variable Red,Green,Blue
	InitRGB(RGB,floor(Red*ColorMax),floor(Green*ColorMax),floor(Blue*ColorMax))
End Function

Structure PlotDefines
	Struct ColorDefaults colors
	Struct ColorMapDef cmaps
	//	 The maximum value color can tke (e.g. 65K for 16 bit)
	Variable MaxColor
	// The number of default defined Colors (for 'category' plots)
	Variable NDefColors
EndStructure

Static Function AddColor(def,ToAdd,index)
	// return the thing to add, increment the index
	Struct ColorDefaults & def
	Struct RGBColor &ToAdd
	Variable &Index
	def.AllColors[Index] = toAdd
	Index += 1
End Function

Static Function /S GetUniFigName(name)
	String name
	// 0 is starting index
	return UniqueName(name,DEF_UNINAME_GRAPH,0)
End Function 

Static Function /S Figure([name,heightIn,widthIn,hide])
	// XXX give figure struct?
	String name
	Variable heightIn,widthIn,hide
	heightIn = ParamIsDefault(heightIn) ? DEF_DISP_HEIGHT_IN : heightIn
	widthIn = ParamIsDefault(widthIn) ? DEF_DISP_WIDTH_IN : widthIn
	hide = ParamIsDefault(hide) ?  DEF_DISP_H_HIDE :hide
	if (ParamIsDefault(name))
		// Get a unique version of the default graph
		name = DEF_DISP_NAME
	EndIf
	// POST: name exists
	name = GetUniFigName(name)
	// POST: name is unique
	// I specifies /W (left,top,right,bottom) is in inches
	Display /HIDE=(hide) /I /W=(0,0,widthIn,heightIn) /N=$(name)
	return name
End Function

Static Function Title(TitleStr,[graphName,Location,fontSize,frameOpt])
	String TitleStr,graphName,Location
	Variable fontSize,frameOpt
	fontSize = ParamIsDefault(fontSize) ? DEF_FONT_TITLE : fontSize
	//frameOpt = ParamIsDefault(frameOpt) ? DEF_TBOX_FRAME : frameOpt
	//if (ParamIsDefault(graphName))
	//	graphName = gcf()
	//EndIf
	// Add the font size to the title string
	sprintf titleStr,"\\Z%d%s",fontSize,TitleStr
	// Textbox: V-711, pp 711 of igormanual
	// F=0: no frame
	// C: Overwrite existing
	// N: name
	// A: location (MT: middle top)
	//TextBox /C/N=text0/A=MT/W=$graphName titleString
	TextBox /F=1/C/N=text0/A=MT titleString
	//TextBox/C/N=text/A=MT  titleString
End Function

Static Function GenLabel(LabelStr,WindowName,FontName,WhichAxis,FontSize)
	String LabelStr,WindowName,FontName,WhichAxis
	Variable FontSize
	// pp 333 Label of igor manual
	// Add the font size (\\Z\d{2}) and font type (\F'[A-z]+') to the label string
	// Note: because of side-effect reasons, \F'[A-z]+' should  go *after* 
	// everything ekse. otherwise, greek letters / Unicode stuff can look weird
	sprintf LabelStr, "\\Z%d%s\F'%s'",fontSize,LabelStr,fontName
	Label /W=$(WindowName) $(WhichAxis), (LabelStr) 
End Function

// XXX make these less copy/paste
Static Function XLabel(LabelStr,[graphName,fontSize,topOrBottom])
	// graph name is the window
	// fontsize is the font size
	// topOrBottom is where to put this x axis.
	String labelStr, graphName,topOrBottom
	Variable fontsize
	fontsize = ParamIsDefault(fontSize) ? DEF_FONT_AXIS : fontSize
	if (ParamIsDefault(graphName))
		// If no graph supplied, assume it is the top graph, get it.
		graphName = gcf()
	EndIf
	if (ParamISDefault(topOrBottom))
		topOrBottom = X_AXIS_DEFLOC
	EndIf
	GenLabel(LabelStr,graphName,DEF_FONT_NAME,topOrBottom,FontSize)
End Function

Static Function YLabel(LabelStr,[graphName,fontSize,leftOrRight])
	// See xLabel, same thing except leftOrRight
	String labelStr, graphName,leftOrRight
	Variable fontsize
	fontsize = ParamIsDefault(fontSize) ? DEF_FONT_AXIS : fontSize
	if (ParamIsDefault(graphName))
		// If no graph supplied, assume it is the top graph, get it.
		graphName = gcf()
	EndIf
	if (ParamIsDefault(leftOrRight))
		leftOrRight = Y_AXIS_DEFLOC
	EndIf
	// Add the font size and font type to the label string
	GenLabel(LabelStr,graphName,DEF_FONT_NAME,leftOrRight,FontSize)
End Function


Static Function SaveFig([saveName,figName,path,closeFig,dpi,transparent,exportFormat])
	//saveName: what to save as
	// figName: which figure to save
	// path: symbolic path to save
	String saveName,figName
	String path
	Variable closeFig,dpi,transparent,exportFormat
	dpi = ParamIsDefault(dpi) ? DEF_DISP_DPI : dpi
	transparent = ParamIsDefault(transparent) ? DEF_FIG_TRANSPARENT : transparent
	exportFormat = ParamIsDefault(exportFormat) ? DEF_FIG_GFX_FMT : exportFormat
	closeFig = ParamISDefault(closeFig) ? DEF_FIG_CLOSE_ON_SAVE : closeFig
	if (ParamIsDefault(figName))
		// Get the current top window
		figName = gcf()
	EndIF
	if (ParamIsDefault(path))
		path = DEF_FIG_SAVEPATH
	EndIF
	// POST: everything is 'filled out', except perhaps savename
	// O: overwrite
	// P: symbolic path (location of this experiment)
	if (ParamIsDefault(saveName))
		// Let Igor work out the save name
		SavePict /P=$path/O/E=(exportFormat)/TRAN=(transparent)/B=(dpi)/WIN=$(figName) /W=(0,0,0,0)
	else
		SavePict /P=$path/O/E=(exportFormat)/TRAN=(transparent)/B=(dpi)/WIN=$(figName) /W=(0,0,0,0) as (saveName)
	EndIf
	if (closeFig)
		KillWindow $figName
	EndIf
End Function

Static Function /S gcf()
	// Get the current FIgure. See: pp 230 or igor manual, GetWindow
	// By side effect, this stores the window 'path' in S_Value
	GetWindow kwTopWin,activeSW
	return S_Value
End Function

Static Function InitPlotDef(ToInit)
	// Initialize the Plot Definitions...
	Struct PlotDefines &ToInit
	// save the maximum color 
	ToInit.MaxColor = ColorMax
	// Number of predefined 'category' colors
	ToInit.NDefColors = PredefinedColors
	// make the color maps and predefined colors
	InitDefColors(ToInit.colors)
	InitCmap(ToInit.cmaps)
End Function

Static Function PlotBeautify([GraphName])
	// Function used to beautify the current plot
	// Use Inside Ticks
	String graphName
	if (ParamIsDefault(graphName))
		graphName = gcf()
	EndIf	
	Variable tickInside = 2
	ModifyGraph /W=$(graphName) tick(left)=tickInside, tick(bottom)=tickInside
	// make the frame a little thick
	ModifyGraph /W=$(graphName)axThick(bottom)=2, axThick(left)=2
	// full frame around the graph
	ModifyGraph /W=$(graphName) mirror(left)=1, mirror(bottom)=1
	// turn off units on the ticks.
	//  for some reason you set this high to turn it off
	ModifyGraph /W=$(graphName) tickunit=1, tickexp=0
End

Static Function DefColorIter(i,RGB,PlotDef,[MaxColors])
	// Uses the 'allColors' to easily iterate through the default colors
	Variable i 
	Struct RGBColor & RGB
	Struct PlotDefines &PlotDef
	Variable MaxColors
	// We mod the variable i (iteraiton number) to MaxColors
	MaxColors = paramIsDefault(MaxColors) ? PlotDef.NDefColors :  MaxColors
	// XXX throw warning or error if the Max Colors is more?...
	MaxColors =  min(MaxColors,PlotDef.NDefColors )
	// POST: MaxColors is the proper thing to modulo by, should be in range
	// Get the index of this color
	Variable index = mod(i,MaxColors)
	RGB = PlotDef.colors.AllColors[index]
End Function

Static Function AxisLim(lower,upper,name,windowName)
	Variable lower,upper
	String name,Windowname
	// XXX check for error? does window exist, etc
	SetAxis /W=$windowName $name,lower,upper
End Function

Static Function XLim(lower,upper,[WindowName])
	Variable lower,upper
	String WindowName
	If (ParamISDefault(WindowName))
		WindowName = gcf()
	EndIf
	// POST: we have a windowname
	AxisLim(lower,upper,X_AXIS_DEFLOC,WindowName)
End Function

Static Function YLim(lower,upper,[WindowName])
	Variable lower,upper
	String WindowName
	If (ParamISDefault(WindowName))
		WindowName = gcf()
	EndIf
	// POST: we have a windowname
	AxisLim(lower,upper,Y_AXIS_DEFLOC,WindowName)
End Function

Static Function Normed(val,minV,maxV)
	Variable val,minV,maxV
	// returns val between 0 and 1, where minV corresponds to 0 and maxV corresponds to 1
	return (val-minV)/(maxV-minV)
End Function	

Static Function AxGenLine(mWin,axisName,value,fmt,mDoUpdate)	
	// Get the axis for this graph (mWin is the name)
	// Q: don't print anything
	String mWin,axisName
	Variable value,mDoUpdate
	Struct PlotFormat & fmt
	// Make a 'DoUpdate', so that getAxis is working with updated information
	if (mDoUpdate)
		DoUpdate
	EndIf
	// Get the X limits
	GetAxis /W=$mWin/Q $X_AXIS_DEFLOC
	Variable lowerX = V_Min
	Variable upperX = V_Max
	// Get the Y Limes
	GetAxis /W=$mWin/Q $Y_AXIS_DEFLOC
	Variable lowerY = V_Min
	Variable upperY = V_Max
	// figure out what we will plot
	Variable x0,y0,x1,y1
	strswitch (axisName)
		case X_AXIS_DEFLOC:
			// horizontal line
			// constant y at value
			x0 = lowerX
			x1 = upperX
			y0 = value
			y1 = value
			break
		case Y_AXIS_DEFLOC:
			// vertical line
			// constant x at value
			x0 = value
			x1 = value
			y0 = lowerY
			y1 = upperY
			break
	EndSwitch
	// POST: x0,x1,y0,y1 are the values we want
	Variable r = fmt.rgb.red, g = fmt.rgb.green, b = fmt.rgb.blue
	Variable thick = fmt.Thickness
	Variable dash = fmt.DashPattern
	// Set the coordinate system to relativ, thickness, line color, and dask style.
	SetDrawEnv /W=$mWin xcoord=$X_AXIS_DEFLOC,ycoord=$Y_AXIS_DEFLOC, linefgc=(r,g,b), dash=(dash),linethick=(thick), save
	DrawLine /W=$mWin x0,y0,x1,y1
End Function

Static Function AxVLine(xValue,[GraphName,PlotFormat,mDoUpdate])
	// 'xValue' is the x location we want the vertical line to pass through
	Variable xValue
	Variable mDoUpdate 
	String GraphName
	Struct PlotFormat & PlotFormat
	Struct PlotFormat toUse
	mDoUpdate = ParamIsDefault(mDoUpdate) ? ModDefine#True() : mDoUpdate
	// Get the current, if the graph wasn't given
	if (ParamIsDefault(GraphName))
		GraphName = gcf()
	EndIF
	if (ParamIsDefault(PlotFormat))
		Struct RGBColor mRGB
		InitRGB_Dec(mRGB,0.0,0,1.0)
		toUse.rgb = mRGB
		toUse.DashPattern = 3
		toUse.Thickness = 2.5
	Else 
		toUse = PlotFormat
	EndIf
	 AxGenLine(GraphName,Y_AXIS_DEFLOC,xValue,toUse,mDoUpdate)	
End Function

Static Function ClearFig([GraphName])
	String GraphName
	// See if we were given a real window name
	if (ParamIsDefault(GraphName))
		GraphName = gcf()
	EndIf
	// Get all the traces
	String Sep = ModDefine#DefListSep()
	String Traces = TraceNameList(GraphName,Sep,TRACENAME_INCLUDE_ALL)
	// Kill Each of th trace in this window
	Variable nItems = ItemsInList(Traces,Sep)
	Variable i
	String tmp
	for (i=0; i< nItems;  i+= 1)
		tmp = StringFromList(i,Traces,Sep)
		// remove this trace
		// /Z : silence, in the case of NANs
		RemoveFromGraph /Z/W=$(GraphName) $tmp
	EndFor
	// kill anything drawn
	SetDrawLayer /K/W=$GraphName $DRAW_LAYER_GRAPH
End Function

// Functions for getting strings of Greek letters

Static Function /S Mu()
	return num2char(0xB5)
End Function

Static Function ClearAllGraphs()
	// Get every window
	String mSep = ModDefine#DefListSep()
	String mList = WinList("*",mSep,WINLIST_GRAPHS)
	Variable nWIn = ItemsInList(mList,mSep)
	Variable i
	String tmpWindow
	// Kill each window
	for (i=0; i<nWin; i+=1)
		tmpWindow = StringFromList(i,mList,mSep)
		KillWindow $(tmpWindow)
	EndFor
End Function