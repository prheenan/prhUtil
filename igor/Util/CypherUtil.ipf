// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModCypherUtil
#include ":ErrorUtil"
#include "::Util:IoUtil"


// How to get the Asylum notes values
//// Constants related to approach and positioning
Static StrConstant NOTE_APPROACH_VEL = "Velocity"
Static StrConstant NOTE_RETRACT_VEL = "RetractVelocity"
Static StrConstant NOTE_X_LVDT = "XLVDT"
Static StrConstant NOTE_Y_LVDT = "YLVDT"
Static StrConstant NOTE_Z_LVDT = "ZLVDTSens"
Static StrConstant NOTE_SPOT_POS = "ForceSpotNumber"
Static StrConstant NOTE_DWELL_SURFACE = "DwellTime"
Static StrConstant NOTE_DWELL_ABOVE = "DwellTime1"
Static StrConstant NOTE_FORCE_DIST = "ForceDist"
//// Constants related to calibration
Static StrConstant NOTE_INVOLS = "InvOLS"
Static StrConstant NOTE_SPRING_CONSTANT = "SpringConstant"
Static StrConstant NOTE_THERMAL_Q  = "ThermalQ"
Static StrConstant NOTE_THERMAL_FREQUENCE = "ThermalFrequency"
////Constants of timestamps
Static StrConstant NOTE_TIMESTAMP_START = "StartTempSeconds"
Static StrConstant NOTE_TIMESTAMP_END = "Seconds"
/////Constantes related to triggering
Static StrConstant NOTE_TRIGGER_CHANNEL = "TriggerChannel"
Static StrConstant NOTE_TRIGGER_POINT = "TriggerPoint"
//// Constants related to sampling
Static StrConstant NOTE_SAMPLE_HERTZ = "NumPtsPerSec"
Static StrConstant NOTE_SAMPLE_BW = "ForceFilterBW"
// Other constants
Static StrConstant NOTE_XOFFSET = "XLVDTOffset"
Static StrConstant NOTE_YOFFSET = "YLVDTOffset"
Static StrConstant NOTE_TEMPERATURE = "ThermalTemperature"
// Functions related to  the <name>:<value> part
Static StrConstant NOTE_KEY_SEP_STR = ":"
Static StrConstant NOTE_LIST_SEP_STR = "\r"
// Asylum Experiment Regex
// Matches ForceCurves:Subfolders:X<6 digits>, with *either* a colon or end of string after
StrConstant DEFAULT_REGEX_ASYLUM_EXP = ":(X\d{6})[$:]"
// Any file scheme, followed by a non-digit (guarenteed by Asylum, followed by at least 1 digit
StrConstant DEFAULT_STEM_REGEX = ".+:.+\d+"
// Path from root to start of force cyrves
StrConstant DEFAULT_ASYLUM_PATH = "ForceCurves:SubFolders:"
// When operating on a file name, used to get the (final) file ID
// get all of the last digits
StrConstant DEFAULT_ASYLUM_FILENUM_REGEX = "(\d+)$"

// Adapted from R. Walder, 6-30-2015, "ForceRampUtilities.ipf"
  Structure ForceMeta
 	// Related to triggering
	// XXX add in trigger channel, or just assume force?
 	Variable TriggerPoint
 	Variable SampleRate
 	Variable ForceBandwidth
 	//Related to approach
 	Variable ApproachVel
 	Variable RetractVel
 	Variable DwellSurface
 	Variable DwellAway
 	Variable ForceDist
 	Variable PosX
 	Variable PosY
 	Variable PosZ
 	Variable OffsetX
 	Variable OffsetY
 	Variable Spot
 	// Calibration
 	Variable ThermalQ
 	Variable ResFreq
	Variable Invols
	Variable SpringConstant
	Variable Temperature
 	// TimeStamps
 	Variable TimeStart
 	Variable TimeEnd
 EndStructure
 
 // Returns a zero-filled number, according to the asylum naming convention
 // XXX is ths always 4 digits?
 Static Function /S ReturnAsylumID(num)
 	Variable num
 	String toRet
 	sprintf toRet,"%04d",num
 	return toRet
 End Function
 
 // Returns the default asylum path
Static Function /S PathToExpSubfolder()
	return DEFAULT_ASYLUM_PATH
End Function
 
 // Gets the experiment name from the path.
 Static Function /S ExperimentNameFromPath(name,[ExpRegex])
	String name,ExpRegex
	// The literal <Subfolders:>, followed by anything up to the next colon (or to the end)
	if (ParamIsDefault(ExpRegex))
		ExpRegex = DEFAULT_REGEX_ASYLUM_EXP
	EndIf
	String experiment="",Subfolder=""
	// XXX make sure we get a math? throw an error otherwise?
	SplitString /E=(ExpRegex) name, experiment,subfolder
	return experiment
End Function
 
// Getting one of the force ramp settings from the wave note.  
// Should have things like pulling velocity, invols, spring constant, etc.
Static Function /S GetForceRampSettingStr(ForceWave)
	Wave ForceWave
	return Note(ForceWave)
End Function

Static Function GetForceRampSetting(ForceWave,ParmString)
	Wave ForceWave
	// XXX assert wave exists?
	String ParmString
	String NoteStr = GetForceRampSettingStr(ForceWave)
	String Parm = StringByKey(ParmString,NoteStr,NOTE_KEY_SEP_STR,NOTE_LIST_SEP_STR)
	// convert the parameter to a double
	return str2num(Parm)
End 

// funcitons to get the individual parameters
Static Function GetSampleRate(ForceWave)
	Wave ForceWave 
	return GetForceRampSetting(ForceWave,NOTE_SAMPLE_HERTZ)
End Function

Static Function GetFilteredSampleRate(ForceWave)
	Wave ForceWave 
	return GetForceRampSetting(ForceWave,NOTE_SAMPLE_BW)
End Function

Static Function GetTriggerPoint(ForceWave)
	Wave ForceWave 
	return GetForceRampSetting(ForceWave,NOTE_TRIGGER_POINT)
End Function

Static Function GetForceDist(ForceWave)
	Wave ForceWave
	String mStr
	return GetForceRampSetting(ForceWave,NOTE_FORCE_DIST)
End Function

Static Function GetApproachVel(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_APPROACH_VEL)
End

Static Function GetRetractVel(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_RETRACT_VEL)
End

Static Function GetDwellSurface(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_DWELL_SURFACE)
End Function

Static Function GetDwellAbove(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_DWELL_ABOVE)
End Function

Static Function GetLVDT_X(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_X_LVDT)
End

Static Function GetLVDT_Y(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_Y_LVDT)
End

Static Function  GetLVDT_Z(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_Z_LVDT)
End Function

Static Function GetSpotPosition(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_SPOT_POS)
End

// Related to vcalibration
Static Function GetThermalQ(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_THERMAL_Q)	
End Function

Static Function GetThermalResFreq(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_THERMAL_FREQUENCE)	
End Function

Static Function GetInvols(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_INVOLS)
End Function

Static Function GetSpringConstant(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_SPRING_CONSTANT)
End Function

Static Function GetTemperature(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_TEMPERATURE)
End Function 

Static Function GetXOffset(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_XOFFSET)
End Function

Static Function GetYOffset(ForceWave)
	Wave ForceWave
	return GetForceRampSetting(ForceWave,NOTE_YOFFSET)	
End Function

// Time Stamps
Static Function GetTimeStampStart(ForceWave)
	// seconds since Jan 1 1904 (Mac Time / Date Time)
	// This is when the force curve *ends*
	Wave ForceWave 
	return GetForceRampSetting(ForceWave,NOTE_TIMESTAMP_START)
End Function

Static Function GetTimeStampEnd(ForceWave)
	// seconds since Jan 1 1904 (Mac Time / Date Time)
	// This is when the force curve *ends*
	Wave ForceWave 
	return GetForceRampSetting(ForceWave,NOTE_TIMESTAMP_END)
End Function


// Function to get the metaInformation

Static Function GetForceMeta(meta,ForceWave)
	Struct ForceMeta  & meta
	Wave ForceWave
	//meta.TriggerChannel = GetTriggerChannel(ForceWave)
 	meta.TriggerPoint = GetTriggerPoint(ForceWave) 
 	meta.SampleRate = GetSampleRate(ForceWave)
 	meta.ForceBandwidth = GetFilteredSampleRate(ForceWave)
 	//Related to approach
 	meta.ApproachVel = GetApproachVel(ForceWave)
 	meta.RetractVel = GetRetractVel(ForceWave) 
 	meta.DwellSurface = GetDwellSurface(ForceWave)
 	meta.DwellAway = GetDwellAbove(ForceWave)
 	meta.ForceDist = GetForceDist(ForceWave)
 	meta.PosX = GetLVDT_X(ForceWave)
 	meta.PosY = GetLVDT_Y(ForceWave)
 	meta.PosZ = GetLVDT_Z(ForceWave)
 	 // X and Y offsets
	meta.OffsetX = GetXOffset(ForceWave)
	meta.OffsetY = GetYOffset(ForceWave)
 	meta.Spot = GetSpotPosition(ForceWave)
 	// Calibration
 	meta.ThermalQ = GetThermalQ(ForceWave)
 	meta.ResFreq =  GetThermalResFreq(ForceWave)
	meta.Invols =  GetInvols(ForceWave)
	meta.SpringConstant =  GetSpringConstant(ForceWave)
 	// TimeStamps
 	meta.TimeStart =  GetTimeStampStart(ForceWave)
 	meta.TimeEnd = GetTimeStampEnd(ForceWave)
 	// Temperature
 	meta.Temperature = GetTemperature(ForceWave)
 End Function
 
 // XXX move this to a seaprate file from the note stuff?
 
 // Function to convert between X and Y types
// Types available for conversion for Y (E.g. photodiode voltage, force)
Constant MOD_Y_TYPE_FORCE_NEWTONS = 1
Constant MOD_Y_TYPE_DEFL_METERS = 2
Constant MOD_Y_TYPE_DEFL_VOLTS = 3
// The corresponding units
StrConstant MOD_Y_TYPE_FORCE_NEWTONS_UNITS = "N"
StrConstant MOD_Y_TYPE_DEFL_METERS_UNITS = "m"
StrConstant MOD_Y_TYPE_DEFL_VOLTS_UNITS = "V"
// Types available for convertsion for X  (E.G Zsnr, Separation)
Constant MOD_X_TYPE_SEP = -1
Constant MOD_X_TYPE_Z_SENSOR  = -2
// The corresponding units
StrConstant MOD_X_TYPE_SEP_UNITS = "m"
StrConstant MOD_X_TYPE_Z_SENSOR_UNITS = "m"
// Endings for types for Y file types (e.g. force, deflections)
StrConstant FILE_END_Y_DEFL_VOLTS = "DeflV"
Strconstant FILE_END_Y_DEFL_METERS = "Defl"
StrConstant FILE_END_Y_FORCE = "Force"
// Endings for types for X file types (e.g. separation, z sensor)
StrConstant FILE_END_X_SEP = "Sep"
Strconstant FILE_END_X_ZSENSOR = "Zsnsr"

Static Function EndingMatchesFile(Ending,File)
	String File,Ending
	String mMatch
	sprintf mMatch, "*%s*", Ending
	return StringMatch(File,mMatch)
End Function

Static Function GetYType(mWaveName)
	String mWaveName
	String mFileName = modIoUtil#GetfileName(mWaveName)
	if (EndingMatchesFile(FILE_END_Y_DEFL_VOLTS,mFileName))
		return MOD_Y_TYPE_DEFL_VOLTS
	elseif (EndingMatchesFile(FILE_END_Y_DEFL_METERS,mFileName))
		return MOD_Y_TYPE_DEFL_METERS
	elseif (EndingMatchesFile(FILE_END_Y_FORCE,mFileName))
		return MOD_Y_TYPE_FORCE_NEWTONS
	else
		String mErr
		sprintf mErr,"Unknown X Type in file %s\r",mWaveName
		ModErrorUtil#TypeError(Description=mErr)
	EndIf
End Function

Static Function GetXType(mWaveName)
	String mWaveName
	String mFileName = modIoUtil#GetfileName(mWaveName)
	if (EndingMatchesFile(FILE_END_X_SEP,mFileName))
		return MOD_X_TYPE_SEP
	elseif (EndingMatchesFile(FILE_END_X_ZSENSOR,mFileName))
		return MOD_X_TYPE_Z_SENSOR
	else
		String mErr 
		sprintf mErr,"Unknown X Type in file %s\r",mWaveName
		ModErrorUtil#TypeError(Description=mErr)
	EndIf
End Function

Static Function GetForceInferType(InWaveY,Force,[DeflMeters])
	Wave InWaveY,Force,DeflMeters
	Variable inTypeY = GetYType(ModIoUtil#GetPathToWave(InWaveY))
	if (!ParamIsDefault(DeflMeters))
		GetForce(InWaveY,InTypeY,Force,DeflMeters=DeflMeters)
	Else
		GetForce(InWaveY,InTypeY,Force)
	EndIf
End Function

Static Function GetForce(InWaveY,InTypeY,Force,[DeflMeters])
	Wave InWaveY,Force,DeflMeters
	Variable InTypeY
	Variable outTypeY = MOD_Y_TYPE_FORCE_NEWTONS
	// Get the deflection in meters, so we can use the convertX method
	if (!ParamIsDefault(DeflMeters))
		ConvertY(InWaveY,InTypeY,Force,outTypeY,DeflMeters=DeflMeters)
	else
		ConvertY(InWaveY,InTypeY,Force,outTypeY)
	EndIf
End Function

Static Function GetForceSepInferTypes(InWaveX,InWaveY,Force,Sep)
	Wave InWaveX,InWaveY
	String Force,Sep
	Variable mTypeX = GetXType(ModIoUtil#GetPathToWave(InWaveX))
	Variable mTypeY = GetYType(ModIoUtil#GetPathToWave(InWaveY))
	// POST: have all the types we need
	// XXX check that the waves exist?
	Make /O/N=(DimSize(InWaveX,0)) $Sep
	Make /O/N=(DimSize(InWaveY,0)) $Force
	GetForceSep(inWaveX,inWaveY,mTypeX,mTypeY,$Force,$Sep)
End Function

// Function to get the force and separaton from whatever type they are currently in.
Static Function GetForceSep(InWaveX,InWaveY,InTypeX,InTypeY,Force,Sep)
	Wave InWaveX,InWaveY,Force,Sep
	Variable InTypeX,inTypeY
	Variable outTypeX = MOD_X_TYPE_SEP
	Variable nPointsForce = DimSize(Force,0)
	Make /O/N=(nPointsForce) DeflMeters
	GetForce(InWaveY,InTypeY,Force,DeflMeters=DeflMeters)
	// POST: force is populated. Get Sep
	ConvertX(InWaveX,InTypeX,Sep,outTypeX,DeflMeters)
	// POST: sep is also populated.
End Function

// A function to convert a Y data type to another Y data type
// Note: If Present, DeflMeters is set with the deflection in meters
// This is useful, since any X conversion needs the deflection in meters
Static Function ConvertY(InWave,InType,OutWave,OutType,[DeflMeters])
	Wave InWave,OutWave,DeflMeters
	Variable InType,OutType
	Variable ToDeflMeters
	// Switched based on the input type,  to get the conversion
	// We will always convert to DeflMeters, then back to Volts
	// Note: We assume invols and springconstant are in V/nm and N/m respectively
	Variable InVols = GetInvols(InWave) 
	Variable SpringConstant = GetSpringConstant(InWave)
	ModErrorUtil#AssertNeq(InType,outType,errorDescr="Programming error, Y Conversions were the same")
	// POST: we have a real conversion to make
	switch (InType)
		case MOD_Y_TYPE_DEFL_VOLTS:
			// To convert from Volts to meters, multiply by invols
			ToDeflMeters = InVols
			break
		case MOD_Y_TYPE_DEFL_METERS:
			// To convert from meters to meters, multiply by 1
			ToDeflMeters = 1
			break
		case MOD_Y_TYPE_FORCE_NEWTONS:
			// To convert from newtons to meters, multiply by 
			// (1/k)
			ToDeflMeters = 1/SpringConstant
			break
		Default:
			ModErrorUtil#TypeError(description="Don't recognize Y Input Type")
			break
	endswitch
	// POST: we know how to convert the y type into deflection meters
	// Detrermine how to convert the y type into the desired output type.
	Variable fromDeflMeters 
	switch (outType)
		case MOD_Y_TYPE_DEFL_VOLTS:
			// To convert from meters to volts, multiply by 1/invols
			fromDeflMeters = 1/InVols
			break
		case MOD_Y_TYPE_DEFL_METERS:
			// To convert from meters to meters, multiply by 1
			fromDeflMeters = 1
			break
		case MOD_Y_TYPE_FORCE_NEWTONS:
			// To convert from meters to newtons, multiply by 
			// (k)
			fromDeflMeters = SpringConstant
			break
		Default:
			ModErrorUtil#TypeError(description="Don't recognize Y Output Type")
			break
	endswitch
	// POST: we can convert Y to meters, and then to whatever
	// Output type we want
	Duplicate /O/D InWave,OutWave
	// If we also wanted to get the deflection in meters, we set that here.
	if (!ParamIsDefault(DeflMeters))
		Duplicate /O/D InWave,DeflMeters
		DeflMeters = toDeflMeters * InWave 
	EndIf
	FastOp OutWave = (ToDeflMeters * fromDeflMeters) * InWave 
	// POSt: FastOp is properly converted
End Function

// Function to convert between X values. Note that it *requires* 
// having "DeflMeters", which is the cantilever deflection (this can be obtained 
// From the ConverY function, above). This could probably be easily accomplished
// with a much smaller function, but the machinery is here for more complicated 
// conversions, if they become necessary.
Static Function ConvertX(InWave,InType,OutWave,OutType,DeflMeters)
	Wave InWave,OutWave,DeflMeters
	Variable InType,OutType
	ModErrorUtil#AssertNeq(InType,outType,errorDescr="Programming error, X Conversions were the same")
	// Determine how to convert to ZSnsr; a factor infront of Deflection
	// In other words, we will calculate: Out = In + (toZSnr+ fromZSnr)*Deflection
	Variable coeffDefl =0
	Variable coeffDeflToZ  = 0
	Variable coeffInputToZ = 0
	Variable coeffZSnsr = 0
	// First, we convert from the input and Defl to ZSnsr
	// According to asylum, http://mmrc.caltech.edu/Asylum/Asylum%20MRP-3D%20manual.pdf
	// MFP-3D Manual, Version 04_08 (assumed similar to cypher), pp 222
	// "Tip-Sample Separation" -- 
	// "[the] distance between the tip and the surface ... [is calculated by]  ... subtract[ing]"
	// the tip deflection from the Piezo position. "
	Switch (InType)
		case MOD_X_TYPE_SEP:
			// Sep = Z - Defl
			// It follows that ZSnsr = Sep + Deflection
			// Input: Sep (-1)
			// Deflection +1
			coeffInputToZ = 1
			coeffDeflToZ = 1
			break
		case MOD_X_TYPE_Z_SENSOR:
			// ZSnsr = ZSnsr
			coeffInputToZ = 1
			coeffDeflToZ = 0
			break
	EndSwitch
	// POST: we know how to convert to ZSnsr
	// Determine the conversion From ZSnsr to the output Type
	Switch (OutType)
		case MOD_X_TYPE_SEP:
			// Sep =  (ZSnsr - Deflection)
			coeffDefl = -1
			coeffZSnsr = 1
			break
		case MOD_X_TYPE_Z_SENSOR:
			// Nothing to change
			// ZSnsr = ZSnsr
			coeffZSnsr  =1
			break
	EndSwitch
	// Make the conversions. Essentially, we just add up the factors above.
	Duplicate /O InWave,OutWave
	// Note that we are precluded form having OutWave=0 for non-zero inwave.
	// Since the types cannot be equal
	// For our purposes, we multiply by -1, since it is more convenient  to have the approach increase
	 OutWave =  (-1) * (DeflMeters *coeffDefl + (CoeffZSnsr) * ( (coeffInputToZ) * InWave + (coeffDeflToZ)*DeflMeters ))
End Function

Static Function /S ForceSuffix()
	return FILE_END_Y_FORCE
End function

Static Function /S SepSuffix()
	// Endings for types for X file types (e.g. separation, z sensor)
	return FILE_END_X_SEP
End Function
