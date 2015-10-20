// Use modern global access method, strict compilation
#pragma rtGlobals=3
#pragma ModuleName=ModPIDSLoop


Function InitPIDSLoop(toInit,DGain,DynamicSetpoint,IGain,InputChannel,OutputChannel,OutputMax,OutputMin,PGain,SGain,Setpoint,SetpointOffset,StartEvent,Status,StopEvent)
	Wave /T toInit
	Variable DGain
	Variable DynamicSetpoint
	Variable IGain
	String InputChannel
	String OutputChannel
	Variable OutputMax
	Variable OutputMin
	Variable PGain
	Variable SGain
	Variable Setpoint
	Variable SetpointOffset
	Variable StartEvent
	Variable Status
	Variable StopEvent
	Redimension /N=14 toInit
	SetDimLabel 0,0, $"DGain",toInit
	SetDimLabel 0,1, $"DynamicSetpoint",toInit
	SetDimLabel 0,2, $"IGain",toInit
	SetDimLabel 0,3, $"InputChannel",toInit
	SetDimLabel 0,4, $"OutputChannel",toInit
	SetDimLabel 0,5, $"OutputMax",toInit
	SetDimLabel 0,6, $"OutputMin",toInit
	SetDimLabel 0,7, $"PGain",toInit
	SetDimLabel 0,8, $"SGain",toInit
	SetDimLabel 0,9, $"Setpoint",toInit
	SetDimLabel 0,10, $"SetpointOffset",toInit
	SetDimLabel 0,11, $"StartEvent",toInit
	SetDimLabel 0,12, $"Status",toInit
	SetDimLabel 0,13, $"StopEvent",toInit
	toInit[%DGain] = num2str(DGain)
	toInit[%DynamicSetpoint] = num2str(DynamicSetpoint)
	toInit[%IGain] = num2str(IGain)
	toInit[%InputChannel] = InputChannel
	toInit[%OutputChannel] = OutputChannel
	toInit[%OutputMax] = num2str(OutputMax)
	toInit[%OutputMin] = num2str(OutputMin)
	toInit[%PGain] = num2str(PGain)
	toInit[%SGain] = num2str(SGain)
	toInit[%Setpoint] = num2str(Setpoint)
	toInit[%SetpointOffset] = num2str(SetpointOffset)
	toInit[%StartEvent] = num2str(StartEvent)
	toInit[%Status] = num2str(Status)
	toInit[%StopEvent] = num2str(StopEvent)

End Function