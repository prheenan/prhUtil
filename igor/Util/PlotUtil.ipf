// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModPlotUtil
#include ":IoUtil"
#include ":ErrorUtil"

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
// See AppendToGraph V-28 and 'Notebooks as Subwindows in Control Panels' in III-96:
// This is the delimiter to separator a subwindow from its parent
Static StrConstant DELIM_SUBWINDOW = "#"
// Defined color strings
// For the major colors, we also allow 
Static StrConstant COLOR_ABBR_RED = "r"
Static StrConstant COLOR_ABBR_GREEN = "g"
Static StrConstant COLOR_ABBR_BLUE = "b"
Static StrConstant COLOR_ABBR_BLACK = "k"
Static StrConstant COLOR_ABBR_PURPLE = "m"
Static StrConstant COLOR_ABBR_ORANGE = "o"
// See: ModifyGraph, V-415:
Static StrConstant  MARKER_DOTTED_LINE = "--"
Static StrConstant MARKER_NO_LINE = ""
Static StrConstant MARKER_LINE = "-"
Static StrConstant MARKER_POINTS = "."
Static StrConstant MARKER_SCATTER_CIRCLE = "o"
Static StrConstant MARKER_SCATTER_PLUS = "+"
Static StrConstant MARKER_SCATTER_SQUARE = "s"
Static StrConstant MARKER_SCATTER_DIAMOND = "d"
Static StrConstant MARKER_SCATTER_TRIANGLE = "^"
Static StrConstant MARKER_NONE= ""
// Seee II-253 for defintiion of shapes
Static Constant MARKERMODE_PLUS = 0
Static Constant MARKERMODE_SQUARE = 5
Static Constant MARKERMODE_TRIANGLE = 6
Static Constant MARKERMODE_DIAMOND = 7
Static Constant MARKERMODE_CIRCLE = 8
Static Constant MARKERMODE_NONE_SPECIFIED = 63 // greater than the maximum number
// Anything else (besides above markers) is a combination
Static Constant GRAPHMODE_LINES_BETWEEN_POINTS = 0 
Static Constant GRAPHMODE_DOTS_AT_POINTS = 2
Static Constant GRAPHMODE_MARKERS = 3
Static Constant GRAPHMODE_LINES_AND_MARKERS = 4
// Default line width, in pixells
Static Constant DEF_LINE_WIDTH = 2
Static Constant DEF_MARKER_SIZE = 4
// Color mapping.
Static StrConstant DEF_CMAP = "Greys"

Structure PlotObj
	Wave X
	Wave Y
	String mColor
	String formatMarker 
	Variable linewidth 
	Variable markersize
	String mLabel
	String mXLabel
	String mYLabel
	String mTitle
	String mGraphName
	// If we want, we can color on a per-point basis
	Variable useColorWave
	Wave colorWave
	String colorMap
EndStructure

Static Function GetRGBFromString(mStr,r,g,b)
	String mStr
	Variable &r,&g,&b
	Struct RgbColor mRgb
	strSwitch (mStr)
		case COLOR_ABBR_RED:
			initRed(mRgb)
			break
		case COLOR_ABBR_GREEN: 
			initGreen(mRgb)
			break
		case COLOR_ABBR_BLUE:
			initBlue(mRgb)
			break
		case COLOR_ABBR_BLACK:
			initBlack(mRgb)
			break
		case COLOR_ABBR_PURPLE :
			initPurple(mRgb)
			break
		case COLOR_ABBR_ORANGE:
			initOrange(mRgb)
			break
		default:
			String mErr
			sprintf mErr,"Color code [%s] wasn't recognized",mStr
			ModErrorUtil#DevelopmentError(description=mErr)
	EndSwitch
	// POST: have the proper colors in RGB
	// set the colors (by reference)
	r = mRgb.red
	b = mRgb.blue
	g = mRgb.green
End Function

Static Function GetMarker(MarkerString)
	String MarkerString
	Make /O/T mMarkerRegex = {MARKER_SCATTER_CIRCLE ,MARKER_SCATTER_PLUS,MARKER_SCATTER_SQUARE,MARKER_SCATTER_DIAMOND,MARKER_SCATTER_TRIANGLE}
	Variable i,nMarkers=DimSize(mMarkerRegex,0)
	String mMarker = MARKER_NONE
	for (i=0; i<nMarkers; i+=1)
		String tmpMarker = mMarkerRegex[i]
		if (strsearch(MarkerString,tmpMarker,0) >= 0)
			mMarker = tmpMarker
			break
		EndIf
	EndFor
	// POST: mMarker is set by either the method or in the inner loop
	Variable mMarkerToRet
	strswitch (mMarker)
		case MARKER_SCATTER_CIRCLE:
			mMarkerToRet = MARKERMODE_CIRCLE
			break
		case MARKER_SCATTER_PLUS:
			mMarkerToRet = MARKERMODE_PLUS
			break
		case MARKER_SCATTER_SQUARE:
			mMarkerToRet = MARKERMODE_SQUARE
			break
		case MARKER_SCATTER_DIAMOND:
			mMarkerToRet = MARKERMODE_DIAMOND
			break
		case MARKER_SCATTER_TRIANGLE:
			mMarkerToRet = MARKERMODE_TRIANGLE
			break
		default:
			// set to an out-of-bounds marker
			// XXX throw error? OK if just line..
			mMarkerToRet = MARKERMODE_NONE_SPECIFIED
			break
	EndSwitch
	KillWaves /Z mMarkerRegex
	return mMarkerToRet
End Function

Static Function IsDottedFormat(MarkerString)
	String MarkerString
	return GrepString(MarkerString,MARKER_DOTTED_LINE)
End Function

Static Function IsSolidLine(MarkerString)
	String MarkerString
	return GrepString(MarkerString,MARKER_LINE)
End Function

Static Function GetTraceDisplayMode(MarkerString,markerMode)
	String MarkerString
	Variable markerMode
	Variable ModeToRet
	strswitch (MarkerString)
		// dotted lines and marker lines are both lines
		case MARKER_DOTTED_LINE:
		case MARKER_LINE:
			ModeToRet = GRAPHMODE_LINES_BETWEEN_POINTS
			break
		// just points
		case MARKER_POINTS:
			ModeToRet = GRAPHMODE_DOTS_AT_POINTS
			break
		default:
			// first, check and see if we are a line connecting markers
			Variable isDotted =IsDottedFormat(MarkerString)
			Variable isLine =  IsSolidLine(MarkerString)
			Variable validMarker = markerMode !=MARKERMODE_NONE_SPECIFIED
			if ( (isDotted || isLine) && validMarker)
				// then we are dotted or with a line, with a marker
				// This eans we set the mode to markers *and* lines
				ModeToRet = GRAPHMODE_LINES_AND_MARKERS
			elseif (validMarker)
				// NO lines, but a valid marker.
				ModeToRet = GRAPHMODE_MARKERS
			else
				// something bad happended; we either have a weird marker or aren't dotted
				String mErr
				sprintf mErr,"Couldn't find string related to %s\r",MarkerString
				ModErrorUtil#DevelopmentError(description=mErr)
			EndIf	
			break
	EndSwitch
	// POST: ModeToRet has the mode we want
	return ModeToRet
End Function

Static Function PlotGen(mObj)
	Struct PlotObj & mObj
	// XXX switch; could also put in r,g,b default?
	String mColor = mObj.mColor
	// set up the red,green, and blue colors
	Variable r,g,b
	GetRGBFromString(mColor,r,g,b)
	String mWinName = mObj.mGraphName
	AppendToGraph /W=$(mWinName) /C=(r,g,b) mObj.Y vs mObj.X 
	// POST: plotted correctly. Now need to modify the traces accordingly
	// Get the marker we will use (if any)
	Variable mMarker = GetMarker(mObj.formatMarker)
	// Get the trace display mode
	Variable mMode = GetTraceDisplayMode(mObj.formatMarker,mMarker)
	// Set the marker, if we have one
	//ModifyGraph expects trace names, not wave references.
	// See Trace Name Parameters on page IV-72
	String mTraceName  = NameOfWave(mObj.Y)
	if (mMarker != MARKERMODE_NONE_SPECIFIED)
		ModifyGraph /W=$(mWinName) marker($mTraceName)=mMarker
	EndIf
	// Set the display mode
	ModifyGraph /W=$(mWinName) mode($mTraceName)=(mMode)
	// Set the line width
	ModifyGraph /W=$(mWinName) lSize($mTraceName)=(mObj.linewidth)	
	// Set the marker size
	ModifyGraph /W=$(mWInNAme) msize($mTraceName)=(mObj.markersize)
	if (mObj.useColorWave)
		// Two stars: autoscale wave to colormap.
		ModifyGraph /W=$(mWinName) zColor($mTraceName)={mObj.colorwave,*,*,$(mObj.colormap)}
	EndIf
	PlotBeautify()
End Function

Static Function ColorTableIsValid(mColor)
	String mColor
	String mList = CTabList()
	// Is the color table in the color table list?
	return (strsearch(mList,mColor,0) >=0)
End Function

Static Function Plot(X,Y,[graphName,color,marker,linestyle,linewidth,markersize,colormap,colorWave])
	Wave X,Y,colorWave
	String graphName,color,marker,linestyle,colormap
	Variable  linewidth,markersize
	Variable nPoints = DimSize(X,0)
	if (ParamIsDefault(color))
		color = COLOR_ABBR_BLUE
	EndIf
	if (ParamIsDefault(graphName))
		graphName = gcf()
	EndIf
	if (ParamIsDefault(marker))
		marker = MARKER_SCATTER_CIRCLE
	EndIF
	if (PAramIsDefault(linestyle))
		linestyle =MARKER_NO_LINE
	EndIf
	Variable useColor = !ParamIsDefault(colorMap) || !ParamIsDefault(colorWave)
	if (ParamIsDefault(colormap))
		colormap = DEF_CMAP
	EndIf
	Variable killColor = ModDefine#False()
	if (ParamIsDefault(colorWave))
		Make /O/N=(nPoints) colorWave
		colorWave[] = nPoints/p // goes from 0 to 1
		killColor = ModDefine#True()
	EndIf
	markersize = ParamIsDefault(markersize) ? DEF_MARKER_SIZE  : markersize
	linewidth = ParamIsDefault(linewidth) ? DEF_LINE_WIDTH : linewidth	
	// POST: all parameters are set
	// Wrap up everything in the object that plotGen expects
	Struct PlotObj mObj
	Wave mObj.X = X
	Wave mObj.Y = Y
	mObj.mColor = color
	mObj.mGraphName = graphName
	mObj.formatMarker = marker + linestyle
	mObj.linewidth = linewidth
	mObj.markersize = markersize
	mObj.colorwave = colorWave
	mObj.colormap = colormap
	//mObj.useColorWave = useColorWave
	PlotGen(mObj)
	if (killColor)
		KillWaves /Z colorWave
	EndIF
End Function


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

Structure pWindow
	Variable width,height
	Variable Left,Top,Right,Bottom
EndStructure

Static Function InitCmap(cmap)
	Struct ColorMapDef &cmap
	cmap.GREY = "Grays256"
	cmap.TERRAIN = "Terrain256"
	cmap.HEAT = "YellowHot256"
End Function

Static Function InitRed(mColor)
	Struct RGBColor & mColor
	InitRGB_Dec(mColor,1.0,0,0)
End function

Static Function InitBlue(mColor)
	Struct RGBColor & mColor
	InitRGB_Dec(mColor,0,0,1.0)
End function

Static Function InitGreen(mColor)
	Struct RGBColor & mColor
	InitRGB_Dec(mColor,0,1.0,0)
End Function

Static Function InitBlack(mColor)
	Struct RGBColor & mColor
	InitRGB_Dec(mColor,0,0,0)
End Function

//  values for the next from http://www.december.com/html/spec/colorcodes.html
Static Function InitYellow(mColor)
	Struct RGBColor & mColor
	InitRGB_Dec(mColor,0.99,0.82,0.9)
End Functon

Static Function InitPurple(mColor)
	Struct RGBColor & mColor
	InitRGB_Dec(mColor,0.5,0.0,0.5) 
End Function

Static Function InitOrange(mColor)
	Struct RGBColor & mColor
	InitRGB_Dec(mColor,0.97,0.46,0.19)
End Function 

Static Function InitDefColors(colors)
	Struct ColorDefaults & colors
	InitRed(colors.Red)
	InitGreen(colors.Gre)
	InitBlue(colors.blu)
	// Sign Yellow
	InitBlack(colors.bla)
	InitYellow(colors.Yel)
	// indigo
	InitPurple(colors.Pur)
	// Orange Crush
	InitOrange(colors.Ora)
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

// Returns a new display window, returns the unique name
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
	ModifyGraph /W=$(WindowName) fSize($WhichAxis)=fontSize
End Function

// XXX make these less copy/paste
Static Function pLegend([graphName])
	String graphName
	if (ParamIsDefault(graphName))
		graphName = gcf()
	EndIf
	Legend /W=$(graphName)
End Function

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

Static Function XLim(lower,upper,[graphName])
	Variable lower,upper
	String graphName
	If (ParamISDefault(graphName))
		graphName = gcf()
	EndIf
	// POST: we have a windowname
	AxisLim(lower,upper,X_AXIS_DEFLOC,graphName)
End Function

Static Function YLim(lower,upper,[graphName])
	Variable lower,upper
	String graphName
	If (ParamISDefault(graphName))
		graphName = gcf()
	EndIf
	// POST: we have a windowname
	AxisLim(lower,upper,Y_AXIS_DEFLOC,graphName)
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

Static Function SubplotLoc(nRows,nCols,number,leftWin,topWin,rightWin,bottomWin,left,top,right,bottom)
	Variable nRows,nCols,number,leftWin,topWin,rightWin,bottomWin
	Variable &left,&top,&right,&bottom
	// Determine which column
	// We assume left to right, then top to bottom
	// Assume numbers are one based, just like in python
	ModErrorUtil#AssertGt(number,0)
	ModErrorUtil#AssertGt(nRows,0)
	ModErrorUtil#AssertGt(nCols,0)
	Variable mCol = mod(number,nCols)
	Variable mRow = floor(number/nCols)
	if (mRow > nRows || mCol > nCols)
		ModErrorUtil#DevelopmentError()
	EndIf
	// POST: we are in bounds, get where this plot should actually start and end
	// Note: these are *relative* coordinates, to the host
	// See: display, /W flag, pp 120
	Variable width = 1/(nCols)
	Variable height = 1/(nRows)
	// mCol has range [1,nCols], so it has a max of one
	left = (mCol) * width
	top  = (mRow-1) * height
	right = left + width
	bottom = top + height
End Function

Static Function /S DefDisplayName(windowName,num)
	String windowName
	Variable num
	return windowName + "_" + num2str(num)
End Function

Static Function /S AppendedWindowName(baseWindow,subWindow)
	String baseWindow,subWindow
	return ModIoUtil#AppendedPath(baseWindow,subwindow,mSep=DELIM_SUBWINDOW)
End Function

// makes a display within 'windowname' (defaults to current)
// assuming the entire window has nRows,nCols, and we are at plot 'current'
// (everything is one based, like in python). *returns the name of the display*,
// which should be displayname, if passed
// Should only call this *once* per number, otherwise subplot will get confused
// XXX could just reference the window or kill, if it already exists
Static Function /S Subplot(nRows,nCols,Current,[windowName,displayName])
	Variable nRows,nCols,Current
	String windowName,displayName
	if (ParamIsDefault(windowName))
		windowName = gcf()
	EndIf
	if (ParamIsDefault(displayName))
		displayName = DefDisplayName(windowName,current)
	Endif
	Variable winLeft,winTop,winRight,winBottom
	ModIoUtil#GetWindowLeftTopRightBottom(windowname,winLeft,winTop,winRight,winBottom)
	// POST: have the dimensions. Figure out where to put this one
	Variable left,top,right,bottom
	 SubplotLoc(nRows,nCols,Current,winLeft,winTop,winRight,winBottom,left,top,right,bottom)
	 // POST: know where to put this display
	 // /HOST: the host window we are using
	 // /W: the relative dimensions.
	 // /N: the name to use.
	ModIoUtil#SafeKillWindow(displayName)
	// POST:  displayName isn't being used.
	DIsplay /HOST=$(windowName)/W=(left,top,right,bottom) /N=$(displayName)
	// get the full (unambiguous) path to the display
	return AppendedWindowName(windowName,displayName)
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
