// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#include "::MVC_Common:MvcDefines"

#pragma ModuleName = ModModelDefines

// // 
// // 
// Unit and Types Defines below
// // 
// // 

// Make the unit string for the predefined prefixes
StrConstant PICO_UNITS = "pico"
StrConstant NANO_UNITS = "nano"
StrConstant MICRO_UNITS = "mu"
StrConstant MILLI_UNITS = "milli"
// Make the lead string for the predefined prefixes
StrConstant PICO_LEAD = "p"
StrConstant NANO_LEAD = "n"
StrConstant MICRO_LEAD =  num2char(0xB5)
StrConstant MILLI_LEAD = "m"
// Make the exponents for the predefined prefixes
Constant PICO_EXP = -12
Constant NANO_EXP = -9
Constant MICRO_EXP = -6
Constant MILLI_EXP = -3
// Make the names and abbreviations for the predefined units
StrConstant NEWTON_STR = "Newtons"
StrConstant METER_STR = "Meters"
// Abbreviaitions below
StrConstant NEWTON_ABBR = "N"
StrConstant METER_ABBR = "m"
// Paramer types defined below
Constant PTYPE_XOFFSET = 0
Constant PTYPE_YOFFSET = 1
Constant PTYPE_X_Y_OFFSET = 2
Constant PTYPE_LINEFIT  = 3
Constant PTYPE_NUMBER = 4
Constant PTYPE_STR = 5
Constant PTYPE_LIST = 6
// Index into array for offsets
static Constant ARR_INDEX_X = 0
static Constant ARR_INDEX_Y = 1
// Maximum model Parameters
Constant MAX_MOD_PARAMS = 25

// Structure Definitions

Constant MAX_STRLEN_UNIT = 10
Constant MAX_STRLEN_LEAD = 3
Constant MAX_STRLEN_UNITNAME = 20
Constant MAX_STRLEN_ABBR = 5
Constant MAX_STRLEN_HELPTXT = 120
Constant MAX_STRLEN_VALUE = 120

// Fit Function Definitions

Static Constant MODELFUNC_FIT_IDX = 0
Static Constant MODELFUNC_PLOT_IDX =1
// Number of modelfuncs
Static Constant MODELFUNC_NUM = 2


Structure Prefix
	// The String for the unit (ie: Nano for Nano)
	String PrefStr
	// The prefix, if any. E.g.: 'nN' has 'n' for the lead string
	String  LeadStr
	// The exponent, to go to standard units
	Variable ExponentIfNumeric
EndStructure

Structure Unit
	// The long name of the unit (e.g. Newton)
	String BaseName
	// The abbreviated name of the unit
	String Abbr
EndStructure

Structure PrefixUnit
	// The unit of measurement
	Struct Unit Unit
	// Its SI prefix
	Struct Prefix Prefix
EndStructure

Structure PredefTypes
	// The type, as defined above
	Variable XOFF,YOFF,XYOFF,LINE,NUM,LIST,STR
EndStructure

Structure PredefPrefix
	Struct Prefix Nano
	Struct Prefix Pico
	Struct Prefix Micro
	Struct Prefix Milli
	Struct Prefix Standard
EndStructure

Structure PredefUnits
	Struct Unit Newtons
	Struct Unit Meters
EndStructure

Static Function MakePrefix(ToMake,UnitStr,LeadString,ExponentIfNumeric)
	Struct Prefix &ToMake
	String UnitStr,LeadString
	Variable ExponentIfNumeric
	ToMake.PrefStr = UnitStr
	ToMake.LeadStr = LeadString
	ToMake.ExponentIfNumeric = ExponentIfNumeric
End Function

Static Function MakeUnit(ToMake, BaseName,Abbr)
	Struct Unit &ToMake
	String BaseName,Abbr
	ToMake.BaseName = BaseName
	ToMake.Abbr = Abbr
End Function

Static Function InitDefPrefix(ToInit)
	Struct PredefPrefix &ToInit
	MakePrefix(ToInit.Nano,NANO_UNITS, NANO_LEAD,NANO_EXP)
	MakePrefix(ToInit.Pico,PICO_UNITS, PICO_LEAD,PICO_EXP)
	MakePrefix(ToInit.Micro,MICRO_UNITS, MICRO_LEAD,MICRO_EXP)
	// XXX add the rest
	// XXX make this into a loop?
End Function

Static Function InitDefUnits(ToInit)
	Struct PredefUnits &ToInit
	MakeUnit(ToInit.Newtons,NEWTON_STR,NEWTON_ABBR)
	MakeUnit(ToInit.Meters,METER_STR,METER_ABBR)
End Function

Static Function InitPredefTypes(ToInit)
	Struct PredefTypes &ToInit
	ToInit.XOFF=  PTYPE_XOFFSET 
	ToInit.YOFF= PTYPE_YOFFSET
	ToInit.XYOFF= PTYPE_X_Y_OFFSET
	ToInit.LINE =  PTYPE_LINEFIT  
	ToInit.NUM = PTYPE_NUMBER
	ToInit.Str = PTYPE_STR
	ToInit.List = PTYPE_LIST
End Function

// The Entire Model Defines...
Structure ModelDefines
	Struct PredefPrefix pref
	Struct PredefUnits unit
	Struct PredefTypes type
EndStructure 

Static Function InitModelDef(ToInit)
	Struct ModelDefines & ToInit
	InitDefPrefix(ToInit.pref)
	InitDefUnits(ToInit.unit)
	InitPredefTypes(ToInit.type)
End Function

// //
// // 
// Definition of the parameter Structure below 
// // 
// //

Structure Parameter
	// Parameter ID. Should be unique among all the parameters
	// XXX how to work in repeated parameters?
	uint32 id
	// Has the parameter value been specifically set or not?
	char beenSet
	// Prefix:
	char PrefStr[MAX_STRLEN_UNIT]
	char LeadStr[MAX_STRLEN_UNIT] 
	char ExponentIfNumeric
	// Unit
	char BaseUnitName[MAX_STRLEN_UNITNAME]
	char Abbr[MAX_STRLEN_ABBR]
	// Type of the parameter
	// The type of this parameter (e.g. Numeric, List, String)
	char mType
	// An Explanation of the parameter
	char HelpText[MAX_STRLEN_HELPTXT]
	// The name of the parameter
	char name[MAX_STRLEN_VALUE]
	// The value of the parameter, if numeric
	double NumericValue
	// The Value of the parameter, if string
	char StringValue[MAX_STRLEN_VALUE]
	// both valus, for an X-Y offset
	double ArrayValue[2]
	// The array index of the point into the X [and Y] arrays
	// 64 bits, since sometimes labmates take 5MHz data
	// for several seconds.
	double pointIndex
	// Can this parameter be repeated?
	// For example, multiple WLC offsets for protein unfolding
	char repeatable
	// Repeat number; which repeat of this parameter is this?
	uint16 repeatNumber
	// TODO What type of 'save' is this?
	uchar SaveType
	// how long of a save (TODO: index? units?)
	double SaveLength
	// is preprocessing
	char isPreProc 
EndStructure

Structure ParamObj
	// All the parameters to be used
	Struct Parameter params[MAX_MOD_PARAMS]
	// The actual parameters
	Variable NParams
	// inde [i] Set to true/false if parameter[i] is related to pre-processing
	// (ie: time offsets, or specially calculated invols/sprint constants)
	char isPreProc[MAX_MOD_PARAMS]
EndStructure

// Functions to create new parameters below
Function InitParameter(newParam,newType,newPref,newUnit,HelpText,name,id,repeat,mRepNum,isPreProc)
	Struct Parameter &newParam 
	Variable newType 
	Struct Prefix &newPref
	Struct Unit &newUnit
	String HelpText,name
	// the id, isRepeatbale boolean, and repeat number. Only used for complex models
	Variable id, repeat,mRepNum,isPreProc
	// Initilize a new until with a prefix
	Struct PrefixUnit mUnit
	mUnit.Prefix = newPref
	mUnit.Unit = newUnit
	// Add in the parameter id
	newParam.id = id
	// Add in the prefix information
	newParam.PrefStr = newPref.PrefStr
	newParam.LeadStr = newPref.LeadStr
	newParam.ExponentIfNumeric = newPref.ExponentIfNumeric
	// Add the unit information
	newParam.BaseUnitName = newUnit.BaseName
	newParam.Abbr = newUnit.abbr
	// Add the help text and name
	newParam.HelpText = HelpText
	newParam.name = name
	// Add the parameter type
	newParam.mType = newType
	// Initialize the value to uninitialized (0)
	// XXX make a utilty function to get things like this?
	// XXX should definitely do this for list separation, if default
	newParam.NumericValue = ModDefine#DefBadRetNum()
	// Set both offsets to 0..
	newParam.ArrayValue[0] = ModDefine#DefBadRetNum()
	newParam.ArrayValue[1] = ModDefine#DefBadRetNum()
	newParam.StringValue = ModDefine#DefBadRetStr()
	// Set the Index to the bad value...
	newParam.pointIndex =ModDefine#DefBadRetNum()
	// Set that the parameter hasnt been set yet 
	newParam.beenSet = ModDefine#False()
	// Set the repeat and repeat number to whatever we were told
	newParam.repeatable = repeat
	newParam.repeatNumber = mRepNum
	newParam.isPreProc = isPreProc
	// TODO: future work on indexing
End Function

Static Function PTypesEq(t1,  t2)
	Variable t1,t2
	return t1 == t2
End

Static Function IsStrParam(Param)
	Struct Parameter &param
	Variable mType = param.mType
	return PTypesEq(PTYPE_STR,mType) ||  PTypesEq(PTYPE_LIST,mType)
End Function

Static Function IsScalarParam(Param)
	Struct Parameter &param
	Variable mType = param.mType
	// Not a string or an xy offset
	return !IsStrParam(Param) && !PTypesEq(PTYPE_X_Y_OFFSET,mType)
End Function

Static Function SetValue(Param,StringVal,NumVal,Point)
	Struct Parameter &param
	String StringVal
	Variable NumVal,Point
	param.NumericValue = NumVal
	param.StringValue = StringVal
	param.pointIndex = Point
	param.beenSet = ModDefine#True()
End Function

Static Function SetValueFromXY(Param,StringVal,NumVal,X,Y,[getXFromY])
	Struct Parameter &param		
	String StringVal
	Variable NumVal
	String X,Y // references to the x and Y
	// getXFromY: if true, determines the numerical x value from the
	// x coordinates of y
	Variable getXFromY 
	getXFromY = ParamIsDefault(getXFromY) ? ModDefine#False() : getXFromY
	// X and Y are the paths / references to the X and Y waves
	if (IsStrParam(Param))
		SetValue(Param,StringVal,NumVal,-1)
	else
		// XXX assume X offset for now
		// Find the minimum location based on the 
		// absolute value difference from the numeric value and X
		// Q: quiet
		Variable mPoint = numVal
		Wave tmpRefY = $Y
		if (getXFromY)
			NumVal = pnt2x(tmpRefY,mPoint)
		else
			// get from x, as normal
			Wave tmpRefX = $X
			NumVal = tmpRefX[mPoint]
		EndIf
		Param.ArrayValue[ARR_INDEX_X] = NumVal
		Param.ArrayValue[ARR_INDEX_Y] = tmpRefY[mPoint]
		SetValue(Param,StringVal,NumVal,mPoint)
	EndIF
End Function

// Utility functions
Static Function GetModMaxParams()
	return MAX_MOD_PARAMS
End Function

Static Function GetXVal(Param)
	Struct Parameter & Param 
	return Param.ArrayValue[ARR_INDEX_X]
End Function 

Static Function GetYVal(Param)
	Struct Parameter & Param 
	return Param.ArrayValue[ARR_INDEX_Y]
End Function


// // 
// //
//  Funtion definitions below 
// //
// // 

// Function to fit to xRef and yRef given fitParameters
Function ModelFitProto(xRef,yRef,fitParameters,mStruct)
	String xRef,yRef
	Struct ParamObj & fitParameters
	Struct ViewModelStruct & mStruct
	// XXX throw error if this ever happens
End Function

//Function to give a list of new waves
Function PreprocessorProto(InputWaves,OutputWaves)
	Wave /T InputWaves
	Wave /T OutputWaves
	// by default, just copy the waves over.
	Duplicate /O/T InputWaves Outputwaves 
End Function

// Sets the first 'approachStartIndex' in X and Y to nan
// if approachStartIndex is default, then uses minimum location
Static Function ProcessFEC(X,Y,[mPoints])
	Wave X,Y
	Variable mPoints
	// Flip y about the y axis
	Y *= -1
	if (ParamIsDefault(mPoints))
		WaveStats  /Q Y
		mPoints = V_minRowLoc	
	EndIf
	// Get rid of the first 'V_minRowLoc' points.
	X[0,mPoints] =nan 
	Y[0,mPoints] = nan
End Function



Structure ModelFunctions
	FuncRef ModelFitProto FitFunc
EndStructure

Function InitModelFunctions(ToInit,FitFunc)
	Struct ModelFunctions & ToInit
	FuncRef ModelFitProto FitFunc
	// XXX Assert functions work? FuncRefInfo ETC
	 FUNCREF ModelFitProto ToInit.FitFunc =FitFunc
End Function


// Function which fills FuncNames with the names of the functions in 
// ModelFunc
Function /S GetFunctionNames(ModelFunc,FuncNames)
	Struct ModelFunctions &ModelFunc
	Wave /T FuncNames
	// XXX need to change this if the module name changes
	// TODO not possiible with static functions?
	String fitName = ModIoUtil#GetFuncName(FuncRefInfo( ModelFunc.FitFunc))
	// set up the relevant wave
	Variable nFuncs = MODELFUNC_NUM
	Make /O/T/N=(nFuncs) tmpFuncNames
	tmpFuncNames[MODELFUNC_FIT_IDX] = fitName
	Duplicate /O/T tmpFuncNames,FuncNames
End Function

Function /S InitFuncObjFromWave(modelFunc,FuncNames)
	Struct ModelFunctions &ModelFunc
	Wave /T FuncNames
	FuncRef  ModelFitProto fitName = $(FuncNames[MODELFUNC_FIT_IDX])
	InitModelFunctions(ModelFunc,fitName)
End Function

