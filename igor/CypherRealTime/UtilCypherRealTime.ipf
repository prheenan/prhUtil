#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#pragma ModuleName = ModUtilCypherRealTime
// Maximum interpolation factor (see td_xSetOutWavePair in MFP3DHelp.ihf"
Static Constant InterpolationMax = 50e3

// Function to intialize eveyrthing to a safe state
Static Function ResetController()
	// See "ARRealTimeProgrammingHelp"
	// stops 'fast collection' thermal data capture (out of 5MHz)
	td_StopThermal()
	// stop controller activity (must call after td_stopThermal)
	td_stop()
	// Call the main tab stop 
	DoScanFunc("StopScan_0")
End Function

// Functions to get various channels on the cypher
Static Function /S ChannelZ()
	return "Cypher.LVDT.Z"
End Function	

Static Function /S ChannelAdcA()
	return "ARC.Input.A"
End Function

Static Function /S ChannelAdcB()
	return "ARC.Input.B"
End Function

// Below, some simple functions to get useful system constants
// note that any function using td_rv will to a real time call..
// XXX TODO: will GV functions do the same?

// Get the current SpringConstant
Static Function GetSpringConstant()
	return GV("SpringConstant")
End Function

// Get the current Invols
Static Function GetInvols()
	return GV("InvOLS")
End Function

// Get the current Z piezo sensitivity (m/V)
Static Function GetZSensorSensitivity()
	return GV("ZPiezoSens")
End Function

// Last known ramp trigger
Static Function LastSurfaceLocation()
       return td_rv("CTFC.RampTrigger")
End Function

Static Function GetCurrentXVolts()
	return td_rv("Cypher.LVDT.X")
End Function

Static Function GetCurrentYVolts()
	return td_rv("Cypher.LVDT.Y")
End Function

Static Function GetCurrentZVolts()
	return td_rv("Cypher.LVDT.Z")
End Function

Static Function GetCurrentZPiezo()
	return td_rv("Output.Z")
End Function

Static Function /S EventString(number)
	Variable number
	return "Event." + num2str(number)
End Function

// Function which clears an event with a given number.
// Returns the error number (as a string), if any, followed by a comma
Static Function /S ClearEvent(WhichEvent)
	Variable WhichEvent
	String mEvent = EventString(WhichEvent)
	// Return the error string
	return num2str(td_WriteString(mEvent,"Clear")) + ","
End Function
