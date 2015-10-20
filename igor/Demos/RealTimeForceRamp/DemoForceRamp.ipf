#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma ModuleName=ModDemoForceRamp

#include ":::Util:IoUtil"
#include ":::CypherRealTime:Heenan_Adapters:ForceRampAdapter"

Variable CurrentIter 

Function DemoForceRampCB()
	print("Hello world!")
End Function

Static Function Main()
	// Initialize a default wave for settings
	Struct RampSettings rampSettings
	ModForceRampAdapter#InitRampSettings(rampSettings)
	// how many CTFC's to do here.
	Variable nTrials = 15
	Variable i
	// make sure the working directory exists
	String workingDir = "Root:ForceRampDemo"
	ModIoUtil#EnsurePathExists(workingDir)
	SetDataFolder $workingDir
	String DeflPrefix = "DeflDemo"
	String ZPrefix = "ZDemo"
	for (i=0; i<nTrials; i+=1)
		// Initialize a wave for output
		Struct RampWaves RampWaves
		String DeflName = DeflPrefix + num2str(i)
		String ZName = ZPrefix + num2str(i)
		ModForceRampAdapter#InitRampWaves(RampWaves,"DemoForceRampCB",DeflName=DeflName,ZName=ZName)
		// Do the ramp
		ModForceRampAdapter#DoRamp(rampSettings,rampWaves)
	EndFor
End Function