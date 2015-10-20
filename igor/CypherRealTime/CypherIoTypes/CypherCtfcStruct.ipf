#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#pragma ModuleName = CypherCtfcStruct


Static Function Init(toInit,RampChannel,RampOffset1,RampSlope1,RampOffset2,RampSlope2,TriggerChannel1,TriggerType1,TriggerValue1,TriggerCompare1,TriggerChannel2,TriggerType2 ,TriggerValue2,TriggerCompare2,TriggerHoldoff2,DwellTime1,DwellTime2,Callback,EventDwell,EventRamp,EventEnable)
	Wave toInit
String RampChannel
String TriggerChannel1
String TriggerCompare1
String TriggerChannel2 
String TriggerCompare2
String Callback
Variable TriggerHoldoff2
Variable RampOffset1 
Variable RampSlope1 
Variable RampOffset2
Variable RampSlope2
Variable TriggerType1
Variable TriggerValue1
Variable TriggerType2 
Variable TriggerValue2
Variable DwellTime1
Variable DwellTime2
Variable EventDwell
Variable EventRamp
Variable EventEnable
End Function