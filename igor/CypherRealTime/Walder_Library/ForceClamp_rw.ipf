#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1

Function ForceClamp(FCSettings,FCWaveNamesCallback)
	Wave FCSettings
	Wave/T FCWaveNamesCallback
	// Now figure out the decimation factor to give the closest sampling rate possible
	Variable DecimationFactor=Round(50000/FCSettings[%$"SamplingRate_Hz"])
	Variable EffectiveSamplingRate=50000/DecimationFactor
	// How many points should we make these waves
	Variable NumPoints=Floor(FCSettings[%$"MaxTime_s"]*EffectiveSamplingRate)

	// Make all waves and setup the wave references.  
	Make/N=(NumPoints)/O $FCWaveNamesCallback[%ZSensor],$FCWaveNamesCallback[%DefV]
	Wave ZSensor= $FCWaveNamesCallback[%ZSensor]
	Wave DefV= $FCWaveNamesCallback[%DefV]
	
	Variable Error = 0
	Variable Force_Volts = ForceToDeflection(FCSettings[%Force_N],Offset=FCSettings[%DefVOffset])

	//  Setup feedback loops
	Error +=	ir_SetPISLoop(2,"Always,Never","Deflection",Force_Volts,FCSettings[%P_Deflection], FCSettings[%I_Deflection], FCSettings[%S_Deflection],"Output.Z",-10,150)	

	// Setup input waves for x,y,z and deflection.  After the motion is done, callback will execute
	Error += td_xSetInWavePair(0, "0,0", "Cypher.LVDT.Z", ZSensor, "Deflection", DefV,FCWaveNamesCallback[%Callback], DecimationFactor)

	DoTipMoleculeMonitor()
	// Execute motion
	Error +=td_WriteString("Event.0", "once")

	if (Error>0)
		print "Error in ForceClamp: ", Error
	endif

End

Function ForceClampFinish()
	Print "Need to insert code here"
	
End

 Function MakeFCSettingsWave([OutputWaveName])
	String OutputWaveName
	
	If(ParamIsDefault(OutputWaveName))
		OutputWaveName="FCSettings"
	EndIf

	Make/O/N=17 $OutputWaveName
	Wave CFCSettings=$OutputWaveName
	
	SetDimLabel 0,0, $"MaxTime_s", CFCSettings
 	SetDimLabel 0,1, $"SamplingRate_Hz", CFCSettings
  	SetDimLabel 0,2, $"Force_N", CFCSettings
   	SetDimLabel 0,3, $"DefVOffset", CFCSettings
   	SetDimLabel 0,4, $"P_x", CFCSettings
   	SetDimLabel 0,5, $"I_x", CFCSettings
   	SetDimLabel 0,6, $"S_x", CFCSettings
   	SetDimLabel 0,7, $"P_y", CFCSettings
   	SetDimLabel 0,8, $"I_y", CFCSettings
   	SetDimLabel 0,9, $"S_y", CFCSettings
   	SetDimLabel 0,10, $"P_Deflection", CFCSettings
   	SetDimLabel 0,11, $"I_Deflection", CFCSettings
   	SetDimLabel 0,12, $"S_Deflection", CFCSettings

	CFCSettings={100,1000,30e-9,0,0, -5.616e4, 0,0, 5.768e4, 0,0, 2999.999, 0}
End

Function MakeFCWaveNamesCallback([OutputWaveName])
	String OutputWaveName
	
	If(ParamIsDefault(OutputWaveName))
		OutputWaveName="FCWaveNamesCallback"
	EndIf

	Make/O/T/N=5 $OutputWaveName
	Wave/T CFCWaveNamesCallback=$OutputWaveName
	
	SetDimLabel 0,0, $"XSensor", CFCWaveNamesCallback
 	SetDimLabel 0,1, $"YSensor", CFCWaveNamesCallback
 	SetDimLabel 0,2, $"ZSensor", CFCWaveNamesCallback
 	SetDimLabel 0,3, $"DefV", CFCWaveNamesCallback
 	SetDimLabel 0,4, $"Callback", CFCWaveNamesCallback

	CFCWaveNamesCallback={"XSensor","YSensor","ZSensor","DefV",""}
End

Function MonitorTipMoleculeConnection()
	Wave HackMeterWave
	Variable DeflOffset=0
	Variable ZPztOffset=0
	
	String DataFolder = GetDF("Meter")
	Wave UpdateMeterUpdate = $DataFolder+"UpdateMeterUpdate"
	Variable Height_V =UpdateMeterUpdate[%Height]
	
	If (Height_V<0) // Zsensor railed, probably because the tip has disconnected from the molecule.
		td_stop()
		ForceClampFinish()
		Return 1  // Forces this background process to stop
	EndIf
	
	Return 0 // Must return 0 to keep background process repeating.

End

Function DoTipMoleculeMonitor()
	ARBackground("MonitorTipMoleculeConnection",10,"")
End
