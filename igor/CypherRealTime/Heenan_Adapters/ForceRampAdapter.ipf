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
Static Constant DefSampleFreq = 5000
Static Constant MAX_WAVENAME = 32


Static Function InitRampWaves(ToInit,Callback,[DeflName,ZName,CTFC])
	Wave /T ToInit
	String Callback,DeflName,ZName,CTFC
	if (ParamIsDefault(DeflName))
		DeflName = DefDeflName
	Endif
	if (ParamIsDefault(ZName))
		ZName = DefZname
	Endif
	if (ParamIsDefault(CTFC))
		CTFC = DefCFTC
	Endif
	ModForceRamp#SetDimLabelForceRampCallback(ToInit)
	// Copy the output waves
	ToInit[%Deflection]		=DeflName
	ToInit[%ZSensor]			=ZName
	ToInit[%$"CTFC Settings"]	=CTFC
	ToInit[%Callback]			=Callback
End Function

Static Function GetRampSettingsNames(toInit)
	Wave /T toInit
	Redimension /N=8 ToInit
	ToInit = {"Surface Trigger","Molecule Trigger","Approach Velocity","Retract Velocity","Surface Dwell Time","No Trigger Distance","Extension Distance","Sampling Rate"}
End Function

Static Function InitRampSettings(ToInit,[SurfTrigForce,MolTrigForce,ApprVel,RetrVel,DwellTime,NoTrigDist,ExtDist,SampleFreq])
	Wave toInit
	Variable SurfTrigForce,MolTrigForce,ApprVel,RetrVel,DwellTime,NoTrigDist,ExtDist,SampleFreq
	SurfTrigForce=  ParamIsDefault(SurfTrigForce) ? DefSurfTrigForce : SurfTrigForce
	MolTrigForce =  ParamIsDefault(MolTrigForce) ? DefMolTrigForce : MolTrigForce
	ApprVel		=  ParamIsDefault(ApprVel) 	   ? DefApprVel        : ApprVel
	RetrVel		=  ParamIsDefault(RetrVel) 	   ? DefRetrVel         : RetrVel
	DwellTime	=  ParamIsDefault(DwellTime) 	   ? DefDwellTime     : DwellTime
	NoTrigDist 	=  ParamIsDefault(NoTrigDist)     ? DefNoTrigDist    : NoTrigDist
	ExtDist		=  ParamIsDefault(ExtDist) 	   ? DefExtDist        : ExtDist
	SampleFreq	=  ParamIsDefault(SampleFreq)   ? DefSampleFreq : SampleFreq
	ModForceRamp#SetDimLabelsRampSettings(ToInit)
	// Set the value we want.
	toInit[%$"Surface Trigger"] 		= SurfTrigForce
	toInit[%$"Molecule Trigger"]		= MolTrigForce 
	toInit[%$"Approach Velocity"]		= ApprVel
	toInit[%$"Retract Velocity"]		= RetrVel
	toInit[%$"Surface Dwell Time"]		= DwellTime
	toInit[%$"No Trigger Distance"]		= NoTrigDist
	toInit[%$"Extension Distance"]		= ExtDist
	toInit[%$"Sampling Rate"]			= SampleFreq
End Function

Static Function DoRamp(mRampSettings,mRampWaves)
	Wave mRampSettings
	Wave mRampWaves
	// create the lower level waves to hold everything
	String SettingsWave = "ForceRampSettings"
	String OutputWave = "ForceRampWaves"
	ModForceRamp#MakeForceRampWave(OutputWaveName=SettingsWave)
	ModForceRamp#MakeFRWaveNamesCallback(OutputWavename=OutputWave)
	Wave Ramp_Settings = $SettingsWave
	Wave/T Ramp_WaveName  = $OutputWave
	// copy the settings

	// Do the ramp
	ModForceRamp#DoForceRamp(Ramp_Settings,Ramp_WaveName)
End Function