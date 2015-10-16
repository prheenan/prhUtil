#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma ModuleName = ModForceRampAdapter

#include "::Walder_Library:ForceRamp"

Static StrConstant DefDeflName= "DefV_Ramp"
Static StrConstant DefZname ="ZSensor_Ramp"
Static StrConstant DefCFTC = "TriggerInfo"
// Default settings (for 650nm DNA)
Static Constant DefSurfTrigForce = 75e-12
Static Constant DefMolTrigForce = 40e-12
Static Constant DefApprVel    = 500e-9
Static Constant DefRetrVel     = 500e-9
Static Constant DefDwellTime = 2
Static Constant DefNoTrigDist = 150e-9
Static Constant DefExtDist =1.4e6
Static Constant DefSampleFreq = 1000
Static Constant MAX_WAVENAME = 32

Structure RampSettings
 	double SurfTrigForce,MolTrigForce,ApprVel,RetrVel,DwellTime,NoTrigDist,ExtDist,SampleFreq
EndStructure

Structure RampWaves
	char Deflection[MAX_WAVENAME]
	char Zsensor[MAX_WAVENAME]
	char CftcSettings[MAX_WAVENAME]
	char Callback[MAX_WAVENAME]
EndStructure

Static Function InitRampWaves(ToInit,Callback,[DeflName,ZName,CFTC])
	Struct RampWaves & ToInit
	String Callback,DeflName,ZName,CFTC
	if (ParamIsDefault(DeflName))
		DeflName = DefDeflName
	Endif
	if (ParamIsDefault(ZName))
		ZName = DefZname
	Endif
	if (ParamIsDefault(CFTC))
		CFTC = DefCFTC
	Endif
	ToInit.Deflection = DeflName
	ToInit.Zsensor = ZName
	ToInit.CftcSettings = CFTC
End Function

Static Function InitRampSettings(ToInit,[SurfTrigForce,MolTrigForce,ApprVel,RetrVel,DwellTime,NoTrigDist,ExtDist,SampleFreq])
	Struct RampSettings & ToInit
	Variable SurfTrigForce,MolTrigForce,ApprVel,RetrVel,DwellTime,NoTrigDist,ExtDist,SampleFreq
	SurfTrigForce=  ParamIsDefault(SurfTrigForce) ? DefSurfTrigForce : SurfTrigForce
	MolTrigForce =  ParamIsDefault(MolTrigForce) ? DefMolTrigForce : MolTrigForce
	ApprVel		=  ParamIsDefault(ApprVel) 	   ? DefApprVel        : ApprVel
	RetrVel		=  ParamIsDefault(RetrVel) 	   ? DefRetrVel         : RetrVel
	DwellTime	=  ParamIsDefault(DwellTime) 	   ? DefDwellTime     : DwellTime
	NoTrigDist 	=  ParamIsDefault(NoTrigDist)     ? DefNoTrigDist    : NoTrigDist
	ExtDist		=  ParamIsDefault(ExtDist) 	   ? DefExtDist        : ExtDist
	SampleFreq	=  ParamIsDefault(SampleFreq)   ? DefSampleFreq : SampleFreq
	ToInit.SurfTrigForce = SurfTrigForce
	ToInit.MolTrigForce  = MolTrigForce
	ToInit.ApprVel	   = ApprVel
	ToInit.RetrVel         = RetrVel
	ToInit.DwellTime  	   = DwellTime
	ToInit.NoTrigDist     = NoTrigDist
	ToInit.ExtDist         = ExtDist
	ToInit.SampleFreq  = SampleFreq
End Function