#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma ModuleName=ModDemoForceRamp

#include ":::Util:IoUtil"
#include ":::Util:Defines"
#include ":::Util:ErrorUtil"
#include ":::CypherRealTime:Heenan_Adapters:ForceRampAdapter"
#include ":::View:ViewUtil"
#include ":::SurfaceDetector:SurfaceDetector"
#include ":::Util:TimerUtil"

Static StrConstant workingDir = "Root:ForceRampDemo"
Static StrConstant settingsWave = "rampSettings"

// Save a buffer of the last 'N' surface detections...
Static Constant N_SURF_DETECT = 50
Static Constant IterPerClick = 1
// States of the force ramping machine
Static Constant STATE_FEC_IDLE = 0 
Static Constant STATE_FEC_SURF_DWELL = 1
Static Constant STATE_FEC_SINGLE_ITER_DONE = 2
Static Constant STATE_FEC_ALL_ITERS_DONE = 3

Structure StateMachine
	uint32 CurrentState
	// CurrentNIters is within a single click (ie: between 1 and N=IterPerClick)
	uint32 CurrentNIters
	// CurrentTrial is between 0 and Infinity, capturing every trial we did
	uint32 CurrentTrial
	double pastNSurfaceLoc[N_SURF_DETECT]
	double pastNRuntimes[N_SURF_DETECT]
EndStructure

// Given an index for the iteration, get the wave names we will user
Static Function GetCurrentWaveNames(Zsnsr,DeflV,index)
	String & Zsnsr, &DeflV
	Variable index
	String DeflPrefix = "DeflDemo"
	String ZPrefix = "ZDemo"
	DeflV = DeflPrefix + num2str(index)
	Zsnsr = ZPrefix + num2str(index)
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
	// Add a control element for each part of the settings wave.
	for (i=0; i<nEle; i+=1)
		String mName = elements[i]
		ModViewUtil#AddViewEle(mName,widthEach,heightEach,VIEW_SETVAR,startXRel=startX,startYRel=startY,yUpdated=startY,waveSetVar=rampSettings,labelSetVar=mName,PadByList=elements)
	Endfor
	ModViewUtil#AddViewEle("Do CTFC",widthEach,heightEach,VIEW_BUTTON,startXRel=startX,startYRel=startY,yUpdated=startY,mProc="DemoForceRampExeButton")
	// Set up all the timers, for testing how long detection takes.
	ModTImerUtil#ResetTimers()
	// Make a wave for the state machine (current iteration, etc... ) 
	Struct StateMachine mState
	mState.CurrentTrial = 0
	ResetStateAndSave(mState)
End Function

Static Function /S GetStateWaveName()
	return ModIoUtil#AppendedPath(workingDir,"StateMachine")
End Function

Static Function LoadState(mState)
	Struct StateMachine & mState
	StructGet /B=(ModDefine#StructFmt()) mState, $(GetStateWaveName())
End Function

Static Function SaveState(mState)
	Struct StateMachine & mState
	String mWave = GetStateWaveName()
	if (!WaveExists($mWave))
		Make /O/N=0 $mWave
	EndIF
	// POST: wave exists
	StructPut /B=(ModDefine#StructFmt()) mState, $(mWave)
End Function

Function ForceRampStateMachine()
	Struct StateMachine mState
 	LoadState(mState)
 	// Get the current state
	Variable iterNum = mState.CurrentNIters
 	switch (mState.CurrentState)
		case STATE_FEC_IDLE:	
			// Then we need to start the FEC, if there are still trials to do
			if (iterNum < IterPerClick)
				// Update the state *first*, then do the CTFC (which calls the state machine,async)
				mState.CurrentState = STATE_FEC_SURF_DWELL
				SaveState(mState)				
				DoCTFC(iterNum)
			else
				// how did we get here? WHY THIS LIFE? :-0
				ModErrorUtil#DevelopmentError()
			EndIf
			break
		case STATE_FEC_SURF_DWELL:
			mState.CurrentState = STATE_FEC_SINGLE_ITER_DONE
			SaveState(mState)	
			break;	
		case STATE_FEC_SINGLE_ITER_DONE:	
			// Then we need to get the surface location of the wave
			// First, get the name of the waves, given this *trial* ('absolute' number, 0 to inf).
			String DeflName,ZName
			Variable trialNumber = mState.CurrentTrial
			GetCurrentWaveNames(ZName,DeflName,trialNumber)
			Wave Zsnsr = $ZName
			Wave DeflV = $DeflName
			// Set up a timer, for our performance
			Variable timerRef 
			if (!ModTimerUtil#GetNewTimer(timerRef))
				ModErrorUtil#DevelopmentError(description="Problem getting timer...")
			EndIf
			// Do the actual detection, get where the surface is, according to this Zsensor measurement.
			Variable Invols,surfaceZsnsr
			ModSurfaceDetector#SurfaceDetect(Zsnsr,DeflV,Invols,surfaceZsnsr)
			// Immediately get the elapsed time.
			Variable microSec = ModTimerUtil#GetElapsedTime(timerRef)
			// The surfaceZsnsr minus the minimum Zsnsr should be approximately constant
			//regardless of where  we are on the surface. Save the past 'N', just for kicks and giggles.
			mState.pastNSurfaceLoc[mod(trialNumber,N_SURF_DETECT)] = surfaceZsnsr - WaveMin(Zsnsr)
			mState.pastNRuntimes[mod(trialNumber,N_SURF_DETECT)] = microSec
			// Update the iteration numbers
			mState.CurrentNIters = iterNum+1
			mState.CurrentTrial = trialNumber + 1
			// If we did all the trials, then go to a 'finished' state, where we reset.
			// Otheriwse, go to an Idle state (where we continue getting data.)
			if (mState.CurrentNIters== IterPerClick)
				mState.CurrentState = STATE_FEC_ALL_ITERS_DONE
			else
				mState.CurrentState = STATE_FEC_IDLE
			EndIf
			// Save the state, then call the state machine again
			SaveState(mState)			
			ForceRampStateMachine()
			break
		case STATE_FEC_ALL_ITERS_DONE:
			// Finished with all the iterations (ie: single 'click')
			// Zero everything out for next time.
			ResetStateAndSave(mState)			
			break
		default:
			ModErrorUtil#DevelopmentError(description="Unknown State.")
			break
	endSwitch
End Function

Static Function DoCTFC(i)
	Variable i
	Wave rampSettings = $(ModIoUtil#AppendedPath(workingDir,settingsWave))
	// Initialize a wave for output
	Make /O /T RampWaves
	String DeflName,ZName
	 GetCurrentWaveNames(ZName,DeflName,i)
	ModForceRampAdapter#InitRampWaves(RampWaves,"ForceRampStateMachine()",DeflName=DeflName,ZName=ZName)
	// Do the ramp
	ModForceRampAdapter#DoRamp(rampSettings,rampWaves)
End Function

// Sets the state machine to idle, sets the number of iterations to 0
Static Function ResetStateAndSave(mState)
	Struct StateMachine & mState
	mState.CurrentNIters = 0 
	mState.CurrentState = STATE_FEC_IDLE
	SaveState(mState)	
End Function


Function DemoForceRampExeButton(LB_Struct) :ButtonControl
	STRUCT WMButtonAction &LB_Struct
	switch (LB_Struct.eventcode)
		case EVENT_BUTTON_MUP_OVER:
			// Reset State, just to be safe. (In case we cancelled part of the way through)
			Struct StateMachine mState
 			LoadState(mState)
			ResetStateAndSave(mState)
			ForceRampStateMachine()
			break
	EndSwitch
End Function