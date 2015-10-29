// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#include ":IoUtil"
#pragma ModuleName = ModTimerUtil

// Igor Reference.ihf, 6.37 -- timers go from 0 to 9 
Static Constant MAX_N_TIMERS = 10

Static Function ResetTimers()
	// First, Stop them all 
	Variable i=0,foo
	for (i=0; i<MAX_N_TIMERS; i+=1)
		foo = StopMsTimer (i)
	EndFor
	// POST: all free
End Function

// Gets a new timer, assuming one exists
// if one doesnt exist, returns false
Static Function GetNewTimer(timerRef,[ResetAll])
	Variable timerRef
	Variable ResetAll
	ResetAll = ParamIsDefault(ResetAll) ? ModDefine#False() : ResetAll
	// initialize all the timers, if we were told to
	if (ResetAll)
		ResetTimers()
	EndIf
	Variable mHandle = StartMsTimer 
	if (mHandle < 0)
		return ModDefine#False()
	endIf
	return ModDefine#True()
End Function

Static Function GetElapsedTime(timerRef)
	Variable timerRef
	return StopMsTimer(timerRef)
End Function
