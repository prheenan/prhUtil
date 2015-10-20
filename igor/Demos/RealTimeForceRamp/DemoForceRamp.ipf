#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma ModuleName=ModDemoForceRamp

#include ":::Util:IoUtil"
#include ":::CypherRealTime:Heenan_Adapters:ForceRampAdapter"
#include ":::View:ViewUtil"

Variable CurrentIter 
Static StrConstant workingDir = "Root:ForceRampDemo"
Static StrConstant settingsWave = "rampSettings"

Function DemoForceRampCB()
	print("Hello world!")
End Function

Static Function Main()
	// make sure the working directory exists
	ModIoUtil#EnsurePathExists(workingDir)
	SetDataFolder $workingDir
	// Initialize a default wave for settings
	Make /O/N=(0) $settingsWave
	Wave rampSettings = $settingsWave
	ModForceRampAdapter#InitRampSettings(rampSettings)
	// Make a window to control all the wave bits...
	String mWin = ModViewUtil#CreateNewWindow(0.4,0.4,windowName="ForceRampDemo")
	// Get the elements we will play with
	Make /T/O/N=(0) elements 
	ModForceRampAdapter#GetRampSettingsNames(elements)
	Variable i=0
	Variable nEle = Dimsize(elements,0)
	Variable heightEach = 0.15
	Variable widthEach = 0.9
	Variable startX=0,startY=0
	for (i=0; i<nEle; i+=1)
		String mName = elements[i]
		ModViewUtil#AddViewEle(mName,widthEach,heightEach,VIEW_SETVAR,startXRel=startX,startYRel=startY,yUpdated=startY,waveSetVar=rampSettings,labelSetVar=mName,PadByList=elements)
	Endfor
	ModViewUtil#AddViewEle("Do CTFC",widthEach,heightEach,VIEW_BUTTON,startXRel=startX,startYRel=startY,yUpdated=startY,mProc="DemoForceRampExeButton")
	// Create a view for  the settings

End Function

Static Function DoCTFC()
	Variable nTrials = 1
	String DeflPrefix = "DeflDemo"
	String ZPrefix = "ZDemo"
	Variable i
	Wave rampSettings = $(ModIoUtil#AppendedPath(workingDir,settingsWave))
	for (i=0; i<nTrials; i+=1)
		// Initialize a wave for output
		Make /O /T RampWaves
		String DeflName = DeflPrefix + num2str(i)
		String ZName = ZPrefix + num2str(i)
		ModForceRampAdapter#InitRampWaves(RampWaves,"DemoForceRampCB",DeflName=DeflName,ZName=ZName)
		// Do the ramp
		ModForceRampAdapter#DoRamp(rampSettings,rampWaves)
	EndFor		
End Function

Function DemoForceRampExeButton(LB_Struct) :ButtonControl
	STRUCT WMButtonAction &LB_Struct
	switch (LB_Struct.eventcode)
		case EVENT_BUTTON_MUP_OVER:
		print("The belly button!")
		DoCTFC()
		break
	EndSwitch
End Function