// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModPlotUtil
#include ":IoUtil"
#include ":ErrorUtil"
#include ":FitUtil"

Constant  ColorMax = 65535
Constant PredefinedColors = 7
// Constants for making the figure
Constant DEF_DISP_H_HIDE = 1 // Don't show the window by default; assume we are saving
Constant DEF_DISP_DPI = 400 // Dots per Inch
Constant DEF_DISP_HEIGHT_IN = 12 // Inches
Constant DEF_DISP_WIDTH_IN = 10 // Inches
// Based on 10-8-2015, ModfiyGraph --> Width(Left) --> 1, looks like command is based on 1 -> 72
Constant DEF_MODGRAPH_WIDTH=72
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
Constant DEF_FONT_TITLE = 24
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
Static StrConstant COLOR_ABBR_GREY = "grey"

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
// Window separator
Static StrConstant WINDOW_SEP = "#"
// Default Alpha 
Static Constant DEF_ALPHA = 0.8
// For setDrawEnv, we have dash and solid patterns 
// V-567,  ' SetDashPattern'
Static Constant DEF_LINE_PATTERN_DASHED = 8 // Pattern looks like "- - - -"
Static Constant DEF_LINE_PATTERN_SOLID = 0      // Pattern looks like "_____"
Static StrConstant DEF_AX_V_OR_H_LINE = "--" // default to dotted for dashed line 
// The default decimation factor to filter data with, relative to the bandwith of the data. 
// If "N" is the number of datapoints, then we use "N*factor" for smoothing (ceiling to the minimum size)
Static Constant DEF_SMOOTH_FACTOR =0.01
// Locations for text box anchor points
StrConstant ANCHOR_TOP_RIGHT = "RT"
StrConstant ANCHOR_BOTTOM_RIGHT = "RB"
StrConstant ANCHOR_BOTTOM_MIDDLE = "MB"
StrConstant ANCHOR_TOP_MIDDLE = "MT"
// Constant for separating legend labels
StrConstant PLOT_UTIL_DEF_LABEL_SEP = ","

Constant DEF_LABEL_MARGIN = 17
Constant DEF_LABEL_MODE = 2 // This is margin sclaled

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
	Variable alpha
	Variable hasX
	Variable hasY
EndStructure

Static Function InitPlotObj(toInit,[X,Y,mColor,marker,linewidth,markersize,mLabel,mXLabel,mYLabel,mTitle,mGraphName,alpha])
	Struct PlotObj & ToInit
	// all the arguments for the plotting object
	Wave X
	Wave Y
	String mColor
	String marker 
	Variable linewidth 
	Variable markersize
	String mLabel
	String mXLabel
	String mYLabel
	String mTitle
	String mGraphName
	Variable alpha
	// Initialize the structure
	if (ParamIsDefault(X))
		ToInit.hasX = ModDefine#False()
	else
		ToInit.hasX = ModDefine#True()
		ToInit.X = X
	EndIf
	if (ParamIsDefault(Y))
		ToInit.hasY = ModDefine#False()
	else
		ToInit.hasY = ModDefine#True()
		ToInit.Y = Y
	EndIf
	ToInit.mColor = mColor
	ToInit.linewidth  = linewidth
	ToInit.markersize = markersize
	ToInit.alpha = alpha
	if (!ParamIsDefault(mColor))
		ToInit.mColor  = mColor
	EndIf
	if (!ParamIsDefault(marker))
		ToInit.formatMarker  = marker
	EndIf
	if (!ParamIsDefault(mLabel))
		ToInit.mLabel = mLabel
	EndIf
	if (!ParamIsDefault(mXLabel))
		ToInit.mXLabel = mXLabel
	EndIf
	if (!ParamIsDefault(mYLabel))
		ToInit.mYLabel = mYLabel
	EndIf
	if (!ParamIsDefault(mTitle))
		ToInit.mTitle = mTitle
	EndIf
	if (!ParamIsDefault(mGraphName))
		ToInit.mGraphName = mGraphName
	EndIf	
	// XXX add in structure noting if things are default?
End Function

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
		case COLOR_ABBR_GREY:
			initGrey(mRgb)
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
	if (mObj.hasX)
		AppendToGraph /W=$(mWinName) /C=(r,g,b) mObj.Y vs mObj.X 
	Else
		AppendToGraph /W=$(mWinName) /C=(r,g,b) mObj.Y	
	EndIf
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
	Variable rawAlpha = mObj.alpha
	// Get alpha in the appropriate bounds
	Variable safeAlpha = max(rawAlpha,0)
	safeAlpha = min(safeAlpha,1)
	ModifyGraph /W=$(mWInNAme) opaque($mTraceName)=(safeAlpha)
	// Make the plot easier to look at; igor's default formatting sucks.
	PlotBeautify()
End Function

Static Function ColorTableIsValid(mColor)
	String mColor
	String mList = CTabList()
	// Is the color table in the color table list?
	return (strsearch(mList,mColor,0) >=0)
End Function

Static StrConstant NANO = "n"
Static StrConstant PICO = "p"
Static StrConstant MICRO = "u"

Static Function SwapAxis([graphName])
	String graphNAme
	if (ParamIsDefault(graphName))
		graphName = gcf()
	EndIf
	ModifyGraph /W=$(graphName) swapXY=(ModDefine#True())
End Function
// Y: y to plot
// Everything else is optional
// mX: what to plot against; defaults to X of Y
// graphName: which graph
// ...
// alpha: transparency. 0 --> transparent, 1 --> opaque
Static Function Plot(Y,[mX,alpha,graphName,color,marker,linestyle,linewidth,markersize])
	Wave mX,Y
	String graphName,color,marker,linestyle
	Variable  linewidth,markersize,alpha
	Variable nPoints = DimSize(Y,0)
	if (ParamIsDefault(color))
		color = COLOR_ABBR_BLUE
	EndIf
	if (ParamIsDefault(graphName))
		graphName = gcf()
	EndIf
	if (ParamIsDefault(alpha))
		alpha = DEF_ALPHA
	EndIF
	if (ParamIsDefault(marker))
		marker = MARKER_LINE
	EndIF
	if (PAramIsDefault(linestyle))
		linestyle =MARKER_LINE
	EndIf
	markersize = ParamIsDefault(markersize) ? DEF_MARKER_SIZE  : markersize
	linewidth = ParamIsDefault(linewidth) ? DEF_LINE_WIDTH : linewidth	
	Struct PlotObj mObj
	// If no x was given, note it. Otherwise, save the X..
	if (!ParamIsDefault(mX))
		Wave mObj.X = mX
		mObj.hasX = MOdDefine#True()
	Else
		mObj.hasX = MOdDefine#False()
	EndIf
	// POST: all parameters are set
	// Wrap up everything in the object that plotGen expects
	Wave mObj.Y = Y
	mObj.mColor = color
	mObj.mGraphName = graphName
	mObj.formatMarker = marker + linestyle
	mObj.linewidth = linewidth
	mObj.markersize = markersize
	mObj.alpha = alpha
	PlotGen(mObj)
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
	InitRGB_Dec(mColor,0.05,0.95,0.05)
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

Static Function InitGrey(mColor)
	Struct RGBColor & mColor
	InitRGB_Dec(mColor,0.8,0.8,0.8)
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

Static Function Title(TitleStr,[xOffset,yOffset,graphName,Location,fontSize,frameOpt])
	String TitleStr,graphName,Location
	Variable fontSize,frameOpt,xOffset,yOffset
	xOffset= ParamIsDefault(xOffset) ? 0 : xOffset
	yOffset= ParamIsDefault(yOffset) ? 0 : yOffset
	fontSize = ParamIsDefault(fontSize) ? DEF_FONT_TITLE : fontSize
	//frameOpt = ParamIsDefault(frameOpt) ? DEF_TBOX_FRAME : frameOpt
	//if (ParamIsDefault(graphName))
	//	graphName = gcf()
	//EndIf
	// Add the font size to the title string
	sprintf titleStr,"\\Z%d%s",fontSize,TitleStr
	// Textbox: V-711, pp 711 of igormanual
	// F=0: no frame
	// /B: background is transparent
	// C: Overwrite existing
	// N: name
	// A: location (MT: middle top)
	TextBox /Y=(yoffset)/E=2/B=1/C/N=text1/F=0/A=MT(titleStr)
End Function

Static Function BeautifyAxisLabels(WindowName,WhichAxis,[FontSize])
	String WindowName,WhichAxis
	Variable FontSize
	FontSize = ParamIsDefault(FontSize)? DEF_FONT_AXIS : FontSize
	ModifyGraph /W=$(WindowName) fSize($WhichAxis)=fontSize
	// Sets the axes 
	// XXX TODO: I don't think I need this line anymore (previously, axis labels on y were colliding).
	// Leaving it here in case I needto come back to it. 
	//ModifyGraph /W=$(WindowName) margin($X_AXIS_DEFLOC)=(1.7*DEF_MODGRAPH_WIDTH)
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
	BeautifyAxisLabels(WindowName,WhichAxis,FontSize=FontSize)
End Function


// Puts labels for the traces (assumed in same order as plotted) onto graphname
// at location (anchor code). 'labels' is a wave, or labelStr is a string.
Static Function pLegend([graphName,labels,location,labelStr,labelStrSep])
	String graphName,location
	String labelStr,labelStrSep
	Wave /T Labels
	if (paramIsDefault(labelStrSep))
		labelStrSep = PLOT_UTIL_DEF_LABEL_SEP
	EndIf
	If (!ParamIsDefault(labelStr))
		Make /O/N=(0)/T labels
		ModDataStruct#ListToTextWave(labels,labelStr,Sep=labelStrSep)
	EndIf
	if (ParamIsDefault(location))
		location = ANCHOR_BOTTOM_MIDDLE
	EndIf
	if (ParamIsDefault(graphName))
		graphName = gcf()
	EndIf
	// Create a default legend (empty legendStr), or add all the labels, if we need them
	// Note that if either labels or labelStr isn't empty, then we should have a viable labels
	String mLegendStr = ""
	if (!ParamIsDefault(labels) || !ParamIsDefault(labelStr) )
		// Get all the waves
		Make /O/N=0/T mTraces
		GetTracesAsWave(graphName,mTraces)
		// Get all the trace identifiers (see V-341, Legend)
		// "
		// You can put a legend in a page layout with a command such as:
		//Legend "\s(Graph0.wave0) this is wave0"
		// "
		Duplicate /O/T mTraces,mTraceLabels
		Variable n = min(DimSize(mTraces,0),DimSize(labels,0))
		mTraceLabels[0,n-1] = "\s(" + graphName + "." + (mTraces[p]) + ")" + labels[p]
		Variable i 
		for (i=0; i<n; i += 1)
			mLegendStr += mTraceLabels[i]
			if (i < n-1)
				// add a newline
				mLegendStr += "\r"
			endIf
		EndFor
	EndIf
	// "If legendStr is missing or is an empty string (""), the text needed for a default legend is automatically generated. "
	// Textbox (711)
	// /C:  changes existing (XXX need name?)
	// /A: anchor code
	Legend /W=$(graphName) /A=$(location) (mLegendStr)
End Function

// adds units to labelStr (assuming units isn't empty)
Static Function /S AddUnitsToLabel(LabelStr,Units)
	String LabelStr,Units
	return LabelStr + " [" + units + "]" 
End Function

Static Function XLabel(LabelStr,[graphName,fontSize,topOrBottom,units])
	// graph name is the window
	// fontsize is the font size
	// topOrBottom is where to put this x axis.
	String labelStr, graphName,topOrBottom,units
	Variable fontsize
	fontsize = ParamIsDefault(fontSize) ? DEF_FONT_AXIS : fontSize
	if (ParamIsDefault(graphName))
		// If no graph supplied, assume it is the top graph, get it.
		graphName = gcf()
	EndIf
	if (ParamISDefault(topOrBottom))
		topOrBottom = X_AXIS_DEFLOC
	EndIf
	if (!ParamIsDefault(units))
		labelStr = AddUnitsToLabel(labelStr,units)
	EndIf
	GenLabel(LabelStr,graphName,DEF_FONT_NAME,topOrBottom,FontSize)
End Function

Static Function YLabel(LabelStr,[graphName,fontSize,leftOrRight,units])
	// See xLabel, same thing except leftOrRight
	String labelStr, graphName,leftOrRight,units
	Variable fontsize
	fontsize = ParamIsDefault(fontSize) ? DEF_FONT_AXIS : fontSize
	if (ParamIsDefault(graphName))
		// If no graph supplied, assume it is the top graph, get it.
		graphName = gcf()
	EndIf
	if (ParamIsDefault(leftOrRight))
		leftOrRight = Y_AXIS_DEFLOC
	EndIf
	if (!ParamIsDefault(units))
		labelStr = AddUnitsToLabel(labelStr,units)
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
	// beautify the axis ticks
	BeautifyAxisLabels(graphName,X_AXIS_DEFLOC,FontSize=(DEF_FONT_AXIS))
	BeautifyAxisLabels(graphName,Y_AXIS_DEFLOC,FontSize=(DEF_FONT_AXIS))

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
	// autoscale the other axis
	String axisToScale
	strswitch (name)
		case X_AXIS_DEFLOC:
			// also adjust y to be in the range
			axisToScale = Y_AXIS_DEFLOC
			break
		case Y_AXIS_DEFLOC:
			// also adjust x to be in the range
			axisToScale = X_AXIS_DEFLOC
			break
	EndSwitch
	// '/A' flag autoscales
	SetAxis /A/W=$windowName $Y_AXIS_DEFLOC
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

// Gets the axis limits for the axis 'mwindow'
Static Function GetAxisLimits(mWindow,lowerX,upperX,lowerY,upperY)
	String mWindow
	Variable & lowerX, &upperX, &lowerY, & upperY
	// Get the X limits
	GetAxis /W=$mWindow/Q $X_AXIS_DEFLOC
	lowerX = V_Min
	upperX = V_Max
	// Get the Y Limes
	GetAxis /W=$mWindow/Q $Y_AXIS_DEFLOC
	lowerY = V_Min
	upperY = V_Max
End Function

Static Function AxGenLine(mWin,axisName,value,mPlotObj,mDoUpdate)	
	// Get the axis for this graph (mWin is the name)
	// Q: don't print anything
	String mWin,axisName
	Variable value,mDoUpdate
	Struct PlotObj & mPlotObj
	// Make a 'DoUpdate', so that getAxis is working with updated information
	if (mDoUpdate)
		DoUpdate
	EndIf
	Variable lowerX,upperx,lowerY,upperY
	GetAxisLimits(mWin,lowerX,upperX,lowerY,upperY)
	// figure out what we will plot
	Variable x0,y0,x1,y1
	strswitch (axisName)
		case X_AXIS_DEFLOC:
			// horizontal line
			// constant y at value
			x0 = lowerX
			x1 = upperX
			// Note that we do MAXy-y to get the coordinates, since
			// y=0 is at the top, y=1 is the bottom (in normalized)
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
	// Get the RGB type stuff we want
	Variable r,g,b
	GetRGBFromString(mPlotObj.mColor,r,g,b)
	Variable thick = mPlotObj.linewidth
	// get the dash patterning
	Variable dash
	// solid or dashed? Default to dashed. 
	if (IsDottedFormat(mPlotObj.formatMarker))
		dash = DEF_LINE_PATTERN_DASHED 
	else
		dash = DEF_LINE_PATTERN_SOLID
	endIf
	// POST: 
	// Set the coordinate system to relativ, thickness, line color, and dask style.
	// The 'setDrawEnv' call *must* all be done in one line, include 'save'... 
	SetDrawEnv /W=$mWin xcoord=$X_AXIS_DEFLOC,ycoord=$Y_AXIS_DEFLOC, linefgc=(r,g,b), dash=(dash),linethick=(thick), save
	// Get the ranged x and y. note that we *dont* use prel, since that adjusts
	// the axes inappropriately when we rescale. 
	Variable x0Norm = x0
	Variable x1Norm = x1
	Variable y0Norm = y0
	Variable y1Norm = y1
	DrawLine /W=$mWin x0Norm,y0Norm,x1Norm,y1Norm
End Function

Static Function AxVLine(xValue,[GraphName,color,mDoUpdate])
	// 'xValue' is the x location we want the vertical line to pass through
	Variable xValue
	Variable mDoUpdate 
	String GraphName
	String color
	Struct PlotFormat toUse
	if (ParamIsDefault(color))
		color = COLOR_ABBR_RED
	EndIf
	// POST: color is not default
	mDoUpdate = ParamIsDefault(mDoUpdate) ? ModDefine#True() : mDoUpdate
	// Get the current, if the graph wasn't given
	if (ParamIsDefault(GraphName))
		GraphName = gcf()
	EndIF
	Struct PlotObj mPlotObj
	// XXX add these as default parameters
	Variable linewidth = 2.5
	String mMarker = DEF_AX_V_OR_H_LINE
	InitPlotObj(mPlotObj,mColor=color,linewidth=linewidth,marker=mMarker)
	 AxGenLine(GraphName,Y_AXIS_DEFLOC,xValue,mPlotObj,mDoUpdate)	
End Function

Static Function AxHLine(yValue,[GraphName,color,mDoUpdate])
	// 'yValue' is the y location we want the vertical line to pass through
	Variable yValue
	Variable mDoUpdate 
	String GraphName
	String color
	Struct PlotFormat toUse
	if (ParamIsDefault(color))
		color = COLOR_ABBR_RED
	EndIf
	// POST: color is not default
	mDoUpdate = ParamIsDefault(mDoUpdate) ? ModDefine#True() : mDoUpdate
	// Get the current, if the graph wasn't given
	if (ParamIsDefault(GraphName))
		GraphName = gcf()
	EndIF
	Struct PlotObj mPlotObj
	// XXX add these as default parameters
	Variable linewidth = 2.5
	String mMarker = DEF_AX_V_OR_H_LINE
	InitPlotObj(mPlotObj,mColor=color,linewidth=linewidth,marker=mMarker)
	 AxGenLine(GraphName,X_AXIS_DEFLOC,yValue,mPlotObj,mDoUpdate)	
End Function

Static Function GetTracesAsWave(GraphName,mWave)
	Wave /T mWave
	String GraphName
	String Sep = ModDefine#DefListSep()
	String Traces = TraceNameList(GraphName,Sep,TRACENAME_INCLUDE_ALL)
	Variable nItems = ItemsInList(Traces,Sep)
	// Resize the wave to the appropriate number of items
	Redimension /N=(nItems) mWave
	// Add all the items
	mWave[] =  StringFromList(p,Traces,Sep)
End Function

Static Function ClearFig([GraphName])
	String GraphName
	// See if we were given a real window name
	if (ParamIsDefault(GraphName))
		GraphName = gcf()
	EndIf
	// Get all the traces
	Make /O/N=0/T mTracesClearFig
	GetTracesAsWave(GraphName,mTracesClearFig)
	// Kill Each of th trace in this window
	Variable nItems = DimSize(mTracesClearFig,0)
	Variable i
	String tmp
	for (i=0; i< nItems;  i+= 1)
		tmp = mTracesClearFig[i]
		// remove this trace
		// /Z : silence, in the case of NANs
		RemoveFromGraph /Z/W=$(GraphName) $tmp
	EndFor
	// kill anything drawn
	SetDrawLayer /K/W=$GraphName $DRAW_LAYER_GRAPH
	KillWaves /Z mTracesClearFig
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
	Variable mCol = mod(number-1,nCols)
	Variable mRow = floor((number-1)/nCols)
	// Check and make sure we are in range
	if (number > nRows*nCols)
		ModErrorUtil#OutOfRangeError(description="Subplot number out of range")
	EndIf
	if (mRow > nRows || mCol > nCols)
		ModErrorUtil#OutOfRangeError(description="Subplot number out of range")
	EndIf
	// POST: we are in bounds, get where this plot should actually start and end
	// Note: these are *relative* coordinates, to the host
	// See: display, /W flag, pp 120
	Variable width = 1/(nCols)
	Variable height = 1/(nRows)
	// mCol has range [1,nCols], so it has a max of one
	left = (mCol) * width
	top  = (mRow) * height
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
// XXX TODO: known bug: doesn't work quite right with non-column plots
Static Function /S Subplot(nRows,nCols,Current,[windowName,displayName])
	Variable nRows,nCols,Current
	String windowName,displayName
	if (ParamIsDefault(windowName))
		// Get the name of the current figure or graph
		windowName = gcf()
		// Remove everything after the last "#" (window separator)
		windowName = ModIoUtil#RemoveAfterLast(windowName,WINDOW_SEP)
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

// Plot rawdata as grey, then filter it and plot the filtiered using 'color'
Static Function PlotWithFiltered(RawData,[X,color,nFilterPoints])
	// Plot the raw data as a grey line
	Wave RawData,X
	Variable nFilterPoints
	String color
	Variable nDataPoints = DimSize(RawData,0)
	// Get some reasonable number for the filtering factor if we dont have one (
	nFilterPoints = ParamIsDefault(nFilterPoints) ? ceil(nDataPoints*DEF_SMOOTH_FACTOR) :  nFIlterPoints
	String rawColor = "grey"
	String rawMarker = ""
	if (!ParamIsDefault(X))
		ModPlotUtil#Plot(RawData,marker=rawMarker,color=rawColor,mX=X)
	Else
		ModPlotUtil#Plot(RawData,marker=rawMarker,color=rawColor)		
	EndIf
	// Get a filtered version of the raw data
	String filterName = NameOfWave(RawData) + "filtered"
	Duplicate /O RawData, $filterName
	Wave Smoothed = $filterName
	ModFitUtil#SavitskySmooth(Smoothed,nPoints=nFIlterPoints)
	// Plot the filtered version of the data
	// Use the same marker (just a line) 
	if (!ParamIsDefault(X))
		ModPlotUtil#Plot(Smoothed,marker=rawMarker,color=color,mX=X)
	Else
		ModPlotUtil#Plot(Smoothed,marker=rawMarker,color=color)		
	EndIf
End Function

