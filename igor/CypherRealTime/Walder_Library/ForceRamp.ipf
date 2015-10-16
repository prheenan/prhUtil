#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.0
#include ":SaveAsAsylumForceRamp"

// Here's my hack to do the CTFC force ramp, but have the CTFC trigger off a filtered deflection channel.
Function DoForceRampFiltered(RampSettings,WaveNameCallbackSettings,FilterFrequency)
	Wave RampSettings
	Wave/T WaveNameCallbackSettings
	Variable FilterFrequency
	
	Variable Error=0
	//td_stop()
	String EventString="Event."+num2str(RampSettings[%$"Event Enable"])

	Error += td_WS(EventString,"Clear")
	
	SetupForceRamp(RampSettings,CallBack=WaveNameCallbackSettings[%Callback],TriggerWaveName=WaveNameCallbackSettings[%$"CTFC Settings"])
	SetupForceRampData(RampSettings,DeflectionWaveName=WaveNameCallbackSettings[%Deflection],ZSensorWaveName=WaveNameCallbackSettings[%ZSensor],Filtered=1)
	
	// Setup up normal deflection channel on InA with appropriate filter settings
	Error += td_WS("ARC.Crosspoint.InA", "Defl")	
	Variable SamplingFilter=Round(RampSettings[%$"Sampling Rate"]/2)
	Error += td_WV("ARC.Input.A.Filter.Freq", SamplingFilter)
	
	// Setup up "cloned" deflection channel on InB with the user provided filter frequency
	Error += td_WS("ARC.Crosspoint.InB", "Defl")	
	Error += td_WV("ARC.Input.B.Filter.Freq", FilterFrequency)
	
	Wave/T CTFCWave= $WaveNameCallbackSettings[%$"CTFC Settings"]
	CTFCWave[%TriggerChannel1] = "Input.B"
	
	// Here we just set the "molecule trigger" to Input.B if we are using it.
	If (RampSettings[%'Engage Second Trigger']==1)
		CTFCWave[%TriggerChannel2]="Input.B"
	Else
		CTFCWave[%TriggerChannel2]="output.Dummy"
	EndIf

	// Copy the new settings to the CTFC
	Error += td_writeGroup("ARC.CTFC",CTFCWave)
	
	// Do the ramp
	ExecuteForceRamp(RampSettings)
End

// This is the normal force ramp function.  No filtering.
Function DoForceRamp(RampSettings,WaveNameCallbackSettings)
	Wave RampSettings
	Wave/T WaveNameCallbackSettings

	Variable Error=0
	//td_stop()
	String EventString="Event."+num2str(RampSettings[%$"Event Enable"])

	Error += td_WS(EventString,"Clear")
	
	SetupForceRamp(RampSettings,CallBack=WaveNameCallbackSettings[%Callback],TriggerWaveName=WaveNameCallbackSettings[%$"CTFC Settings"])
	SetupForceRampData(RampSettings,DeflectionWaveName=WaveNameCallbackSettings[%Deflection],ZSensorWaveName=WaveNameCallbackSettings[%ZSensor])
	
	ExecuteForceRamp(RampSettings)
End



Function ExecuteForceRamp(RampSettings)
	Wave RampSettings
	String EventString="Event."+num2str(RampSettings[%$"Event Enable"])
	td_WS(EventString,"Once")	

End

Function SetupForceRampData(RampSettings,[DeflectionWaveName,ZSensorWaveName,Filtered])
	Wave RampSettings
	String DeflectionWaveName,ZSensorWaveName
	Variable Filtered
	
	If(ParamIsDefault(ZSensorWaveName))
		ZSensorWaveName="ZSensor"
	EndIf
	If(ParamIsDefault(DeflectionWaveName))
		DeflectionWaveName="DefV"
	EndIf
	
	If(ParamIsDefault(Filtered))
		Filtered=0
	EndIf

	// Import Existing CTFC Parms
	Variable SurfaceLocation=td_rv("CTFC.RampTrigger")
	Variable CurrentLocation=td_rv("Output.Z")
	Variable DistanceToSurface=Abs((CurrentLocation-SurfaceLocation)*GV("ZPiezoSens"))

	// Figure out the estimated time for the force ramp to complete
	Variable RampTime=DistanceToSurface/RampSettings[%'Approach Velocity']+RampSettings[%'Extension Distance']/RampSettings[%'Retract Velocity']
	RampTime+=RampSettings[%$"Surface Dwell Time"]+RampSettings[%$"Retract Dwell Time"]
	
	// Now figure out the decimation factor to give the closest sampling rate possible
	Variable DecimationFactor=Round(50000/RampSettings[%$"Sampling Rate"])
	Variable EffectiveSamplingRate=50000/DecimationFactor
	// How many points should we make these waves
	Variable NumPoints=Floor(RampTime*EffectiveSamplingRate)
	
	Make/O/N=(NumPoints) $ZSensorWaveName,$DeflectionWaveName
	
	Wave ZSensor=$ZSensorWaveName
	Wave DefV=$DeflectionWaveName
	
	FastOp ZSensor=0
	FastOp DefV=0
	
	String EventString=num2str(RampSettings[%$"Event Enable"])
	// If we are using a filtered, cloned deflection channel, setup to sample on the raw channel (A) and Zsensor.  Also save a copy of the filtered channel, just for debugging purposes.
	If(Filtered)
		Duplicate/O DefV, DefVFiltered
		td_XSetInWavePair(0,EventString,"ARC.Input.A",DefV,"Cypher.LVDT.Z",ZSensor,"",DecimationFactor)
		td_xSetInWave(1,EventString,"ARC.Input.B",DefVFiltered,"",DecimationFactor)
	Else
		// Otherwise, just use the usual channels
		IR_XSetInWavePair(0,EventString,"Deflection",DefV,"Cypher.LVDT.Z",ZSensor,"",DecimationFactor)
	EndIf

End

Function SetupForceRamp(RampSettings[,CallBack,TriggerWaveName])
	Wave RampSettings
	String CallBack,TriggerWaveName
	
	If(ParamIsDefault(CallBack))
		CallBack=""
	EndIf
	If(ParamIsDefault(TriggerWaveName))
		TriggerWaveName="TriggerInfo"
	EndIf
	
	// Import Existing CTFC Parms
	Make/O/T $TriggerWaveName
	Wave/T TriggerInfo=$TriggerWaveName
	Variable error=0
	error+=td_ReadGroup("ARC.CTFC",TriggerInfo)

	String ErrorStr = ""
	Variable Scale = 1
	String RampChannel = ""

	// Calculate Ramp Settings into Voltages for Piezo and Deflection
	Variable SurfaceTrigger = RampSettings[%'Surface Trigger']/GV("InvOLS")/GV("SpringConstant")
	Variable MoleculeTrigger = -1*RampSettings[%'Molecule Trigger']/GV("InvOLS")/GV("SpringConstant")
	Variable ApproachSpeed = (RampSettings[%'Approach Velocity'])/GV("ZPiezoSens")
	Variable RetractSpeed = -1*(RampSettings[%'Retract Velocity'])/GV("ZPiezoSens")
	Variable NoTriggerTime = (RampSettings[%'No Trigger Distance'])/((RampSettings[%'Retract Velocity']))
	Variable ExtensionDistance=-RampSettings[%'Extension Distance']/GV("ZPiezoSens")
	
	// He we set up the retracting ramp.  If we are trying to detect a molecule, set ramp to $Deflection
	// If we are just trying to get a full force pull, then use output.Dummy.  This disables the second trigger.
	String RetractTriggerChannel
	If (RampSettings[%'Engage Second Trigger']==1)
		RetractTriggerChannel="Deflection"
	Else
		RetractTriggerChannel="output.Dummy"
	EndIf
	
	//  Setting up all the CTFC ramp info here. 
	RampChannel = "Output.Z"

	TriggerInfo[%RampChannel] = RampChannel
	TriggerInfo[%RampOffset1] = "160"  //Z Piezo volts
	TriggerInfo[%RampSlope1] = num2str(ApproachSpeed)  //Z Piezo Volts/s

	TriggerInfo[%RampOffset2] = num2str(ExtensionDistance)
	TriggerInfo[%RampSlope2] = num2str(RetractSpeed) 
	
	TriggerInfo[%TriggerChannel1] = "Deflection"
	TriggerInfo[%TriggerValue1] = num2str(SurfaceTrigger) //Deflection Volts
	TriggerInfo[%TriggerCompare1] = ">="
	
	TriggerInfo[%TriggerChannel2] = RetractTriggerChannel
	TriggerInfo[%TriggerValue2] = num2str(MoleculeTrigger) 
	TriggerInfo[%TriggerCompare2] = "<="
	
	TriggerInfo[%TriggerHoldoff2] = num2str(NoTriggerTime)
	
	TriggerInfo[%DwellTime1] = num2str(RampSettings[%$"Surface Dwell Time"])
	TriggerInfo[%DwellTime2] = num2str(RampSettings[%$"Retract Dwell Time"])
	TriggerInfo[%EventDwell] = num2str(RampSettings[%$"Event Dwell"])

	TriggerInfo[%EventRamp] = num2str(RampSettings[%$"Event Ramp"])

	TriggerInfo[%EventEnable] =num2str(RampSettings[%$"Event Enable"])

	TriggerInfo[%CallBack] = Callback
	
	if (FindDimLabel(TriggerInfo,0,"TriggerType1") >= 0)
		TriggerInfo[%TriggerType1] = "Relative Start"
		TriggerInfo[%TriggerType2] = "Relative Start"
	endif
	String EventDwellString="Event."+num2str(RampSettings[%$"Event Dwell"])
	String EventRampString="Event."+num2str(RampSettings[%$"Event Ramp"])
	ErrorStr += num2str(td_WriteString(EventDwellString,"Clear"))+","
	ErrorStr += num2str(td_WriteString(EventRampString,"Clear"))+","
	ErrorStr += IR_StopInWaveBank(-1)
	ErrorStr += IR_StopOutWaveBank(-1)

	ErrorStr += num2str(td_writeGroup("ARC.CTFC",TriggerInfo))+","
	
	// Setup constant force loop during dwell at surface.  Note: Need a Deflection Offset for the most accurate dwell.
	SetupDwellFB(SurfaceTrigger,DeflectionOffset=RampSettings[%DefVOffset],RampSettings=RampSettings)
	
	ARReportError(ErrorStr)	

End //SetupForceRamp

Function MakeForceRampWave([OutputWaveName])

	String OutputWaveName
	
	If(ParamIsDefault(OutputWaveName))
		OutputWaveName="ForceRampSettings"
	EndIf

	Make/O/N=14 $OutputWaveName
	Wave ForceRampSettings=$OutputWaveName
	
	SetDimLabel 0,0, $"Surface Trigger", ForceRampSettings
 	SetDimLabel 0,1, $"Molecule Trigger", ForceRampSettings
 	SetDimLabel 0,2, $"Approach Velocity", ForceRampSettings
 	SetDimLabel 0,3, $"Retract Velocity", ForceRampSettings
 	SetDimLabel 0,4, $"Surface Dwell Time", ForceRampSettings
  	SetDimLabel 0,5, $"Retract Dwell Time", ForceRampSettings
   	SetDimLabel 0,6, $"No Trigger Distance", ForceRampSettings
    	SetDimLabel 0,7, $"Engage Second Trigger", ForceRampSettings
 	SetDimLabel 0,8, $"Extension Distance", ForceRampSettings
 	SetDimLabel 0,9, $"Event Dwell", ForceRampSettings
 	SetDimLabel 0,10, $"Event Ramp", ForceRampSettings
 	SetDimLabel 0,11, $"Event Enable", ForceRampSettings
 	SetDimLabel 0,12, $"Sampling Rate", ForceRampSettings
 	SetDimLabel 0,13, $"DefVOffset", ForceRampSettings

	ForceRampSettings={100e-12,30e-12,1e-6,1e-6,0,0,50e-9,0,1e-6,5,3,2,1000,0}
End

Function MakeFRWaveNamesCallback([OutputWaveName])
	String OutputWaveName
	
	If(ParamIsDefault(OutputWaveName))
		OutputWaveName="FRWaveNamesCallback"
	EndIf

	Make/O/T/N=4 $OutputWaveName
	Wave/T ForceRampSettings=$OutputWaveName
	
	SetDimLabel 0,0, $"Deflection", ForceRampSettings
 	SetDimLabel 0,1, $"ZSensor", ForceRampSettings
 	SetDimLabel 0,2, $"CTFC Settings", ForceRampSettings
 	SetDimLabel 0,3, $"Callback", ForceRampSettings

	ForceRampSettings={"DefV","ZSensor","TriggerInfo",""}
End


// GrabExistingCTFCparms imports the existing CTFC parameter group.  Makes it easier to write CTFC parameters without errors
Function ImportExistingCTFCparms([OutputWaveName])
	String OutputWaveName
	
	If(ParamIsDefault(OutputWaveName))
		OutputWaveName="TriggerInfo"
	EndIf

	Make/O/T $OutputWaveName
	Wave TriggerInfo=$OutputWaveName
	Variable error=0
	
	error+=td_ReadGroup("ARC.CTFC",TriggerInfo)
	
	return error

End //ImportExistingCTFCparms()

Function SetupDwellFB(SetPoint,[DeflectionOffset,RampSettings])
	Variable SetPoint,DeflectionOffset
	Wave RampSettings
	Variable Error=0
	Variable StartEvent,StopEvent
	
	
	If(ParamIsDefault(DeflectionOffset))
		DeflectionOffset=0
	EndIf
	If(ParamIsDefault(RampSettings))
		StartEvent=5
		StopEvent=3
	Else
		StartEvent=RampSettings[%'Event Dwell']
		StopEvent=RampSettings[%'Event Ramp']
	EndIf
	
	Make/O/T PIDSLoopGroup
	Error+=td_RG("ARC.PIDSLoop.0",PIDSLoopGroup)
	
	PIDSLoopGroup[%Setpoint]=num2str(SetPoint)
	PIDSLoopGroup[%SetpointOffset]=num2str(DeflectionOffset)
	PIDSLoopGroup[%InputChannel]="Deflection"
	PIDSLoopGroup[%OutputChannel]="Output.Z"
	PIDSLoopGroup[%IGain]="3000"
	PIDSLoopGroup[%StartEvent]=num2str(StartEvent)
	PIDSLoopGroup[%StopEvent]=num2str(StopEvent)
	PIDSLoopGroup[%OutputMin]="-10"
	PIDSLoopGroup[%OutputMax]="150"
	PIDSLoopGroup[%Status]="0"
	Error+=td_WG("ARC.PIDSLoop.2",PIDSLoopGroup)
	
	If(Error>0)
		Print "Error code in SetupDwellFB: "+ num2str(Error)
	EndIf
End