// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModUnitUtil
#include ":ErrorUtil"

// // 
// // 
// Unit Defines below
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

Static Function GetUnitFactorOrReturnFalse(prefix,factor)
	String prefix
	Variable & factor
	strswitch(prefix)
		case PICO_LEAD:
		case PICO_UNITS:
			factor = 1e12
			break
		case NANO_LEAD:
		case NANO_UNITS:
			factor = 1e9
			break
		case MICRO_LEAD:
		case MICRO_UNITS:
			factor = 1e6
			break		
		case MILLI_LEAD:
		case MILLI_UNITS:
			factor = 1e3
			break	
		default:
			return ModDefine#False()
	EndSwitch
	return ModDefine#True()
End Function

// converts 'inWave' to 'prefix', assuming it is in standard units
// you could type in "n", "nano", or "nanometers", all should work for converting. 
// Dont try to get too cute with it (like "nmicrons" -- it will think you mean nanometers) 
Static Function ConvertToUnits(InWave,prefix)
	Wave InWave
	String prefix
	Variable factor
	// try the entire string first
	If (!GetUnitFactorOrReturnFalse(prefix,factor))
		// try just the first character; throw an error otherwise
		if (!GetUnitFactorOrReturnFalse(prefix[0],factor))
			ModErrorUtil#OutOfRangeError(description=("Didnt understand how to convert " + prefix))
		EndIf
	EndIf
	// POST: have the factor we ned
	// multiply by the factor
	InWave[] *= factor
End Function
