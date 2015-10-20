// Use modern global access method, strict compilation
#pragma rtGlobals=3
#pragma ModuleName=ModCTFC


Function InitCTFC(toInit,Callback,DwellTime1,DwellTime2,EventDwell,EventEnable,EventRamp,RampChannel,RampOffset1,RampOffset2,RampSlope1,RampSlope2,TriggerChannel1,TriggerChannel2,TriggerCompare1,TriggerCompare2,TriggerHoldoff2,TriggerType1,TriggerType2,TriggerValue1,TriggerValue2)
	Wave /T toInit
	Variable Callback
	Variable DwellTime1
	Variable DwellTime2
	Variable EventDwell
	Variable EventEnable
	Variable EventRamp
	String RampChannel
	Variable RampOffset1
	Variable RampOffset2
	Variable RampSlope1
	Variable RampSlope2
	String TriggerChannel1
	String TriggerChannel2
	Variable TriggerCompare1
	Variable TriggerCompare2
	Variable TriggerHoldoff2
	Variable TriggerType1
	Variable TriggerType2
	Variable TriggerValue1
	Variable TriggerValue2
	Redimension /N=26 toInit
	SetDimLabel 0,0, $"Callback",toInit
	SetDimLabel 0,1, $"DwellTime1",toInit
	SetDimLabel 0,2, $"DwellTime2",toInit
	SetDimLabel 0,3, $"EventDwell",toInit
	SetDimLabel 0,4, $"EventEnable",toInit
	SetDimLabel 0,5, $"EventRamp",toInit
	SetDimLabel 0,6, $"RampChannel",toInit
	SetDimLabel 0,7, $"RampOffset1",toInit
	SetDimLabel 0,8, $"RampOffset2",toInit
	SetDimLabel 0,9, $"RampSlope1",toInit
	SetDimLabel 0,10, $"RampSlope2",toInit
	SetDimLabel 0,11, $"RampTrigger",toInit
	SetDimLabel 0,12, $"StartTime",toInit
	SetDimLabel 0,13, $"TriggerChannel1",toInit
	SetDimLabel 0,14, $"TriggerChannel2",toInit
	SetDimLabel 0,15, $"TriggerCompare1",toInit
	SetDimLabel 0,16, $"TriggerCompare2",toInit
	SetDimLabel 0,17, $"TriggerHoldoff2",toInit
	SetDimLabel 0,18, $"TriggerPoint1",toInit
	SetDimLabel 0,19, $"TriggerPoint2",toInit
	SetDimLabel 0,20, $"TriggerTime1",toInit
	SetDimLabel 0,21, $"TriggerTime2",toInit
	SetDimLabel 0,22, $"TriggerType1",toInit
	SetDimLabel 0,23, $"TriggerType2",toInit
	SetDimLabel 0,24, $"TriggerValue1",toInit
	SetDimLabel 0,25, $"TriggerValue2",toInit
	toInit[%Callback] = num2str(Callback)
	toInit[%DwellTime1] = num2str(DwellTime1)
	toInit[%DwellTime2] = num2str(DwellTime2)
	toInit[%EventDwell] = num2str(EventDwell)
	toInit[%EventEnable] = num2str(EventEnable)
	toInit[%EventRamp] = num2str(EventRamp)
	toInit[%RampChannel] = RampChannel
	toInit[%RampOffset1] = num2str(RampOffset1)
	toInit[%RampOffset2] = num2str(RampOffset2)
	toInit[%RampSlope1] = num2str(RampSlope1)
	toInit[%RampSlope2] = num2str(RampSlope2)
	toInit[%TriggerChannel1] = TriggerChannel1
	toInit[%TriggerChannel2] = TriggerChannel2
	toInit[%TriggerCompare1] = num2str(TriggerCompare1)
	toInit[%TriggerCompare2] = num2str(TriggerCompare2)
	toInit[%TriggerHoldoff2] = num2str(TriggerHoldoff2)
	toInit[%TriggerType1] = num2str(TriggerType1)
	toInit[%TriggerType2] = num2str(TriggerType2)
	toInit[%TriggerValue1] = num2str(TriggerValue1)
	toInit[%TriggerValue2] = num2str(TriggerValue2)

End Function