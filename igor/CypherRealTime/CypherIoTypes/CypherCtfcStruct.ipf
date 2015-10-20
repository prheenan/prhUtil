#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#pragma ModuleName = CypherCtfcStruct

// Following definitions from MFP3D, 10/20/2015
//RampChannel ($) - The channel to be ramped.  This can be any channel addressable by td_xSetOutWave.  You must set this parameter before setting any of the other ramp parameters.  If you change this parameter, you must update all the other ramp parameters as well.
//RampOffset1 - The maximum offset from the original position of the ramp channel we can move without a trigger before turning around.  This value cannot be zero.
//RampSlope1 - The attack speed of the first ramp, in units of the native units of the ramp channel per second.  Must be the same sign as RampOffset1.  This value cannot be zero.
//RampOffset2 - The offset from the triggered position of the ramp channel, applied after the dwell period.  If the trigger does not occur, this offset will be ramped from RampOffset1.  If this value is zero, no turn around will occur.  If this value is NaN, the ramp channel will be returned to its starting point.  Typically, the sign of this offset will be the opposite of RampOffset1, unless your goal is to ram the tip into the surface.
//RampSlope2 - The retreat speed of the return ramp, in units of the native units of the ramp channel per second.  Must be the same sign as RampOffset2, unless that is NaN.  Then the value must be the opposite sign of RampSlope1.  This value can only be zero if RampOffset2 is zero.
//RampTrigger (RO) - The value of the RampChannel at the point of triggering.    This value only makes sense if read from inside a callback.
//TriggerChannel1 ($) - The Channel which will be read for the first trigger.  This can be any channel addressable by td_xSetInWave.  You must set this parameter before setting TriggerValue.  If you change this parameter, you must update TriggerValue1 as well.
//TriggerType1 - The type of the first trigger.
		//0	Absolute
		//1	Relative Start
		//2	Relative Min
		//3	Relative Max
Static StrConstant CTFC_TRIG_ABS = 0 
Static StrConstant CTFC_TRIG_REL_START = 1 
Static StrConstant CTFC_TRIG_REL_MIN = 2
Static StrConstant CTFC_TRIG_REL_MAX = 3
//TriggerValue1 - The first trigger will occur at (baseValue + TriggerValue1) where the baseValue is 0 for Absolute trigger, value of the TriggerChannel1 at the start of CTFC for Relative Start, minimum/maximum value of the TriggerChannel1 during the first ramp for Relative Min/Relative Max triggers.
//TriggerCompare1  - The type of comparision for the first trigger.
		//0	>=
		//1	<=
Static StrConstant CTFC_TRIG_LTEQ = "<="
Static StrConstant CTFC_TRIG_GTED = ">="
//TriggerPoint1 (RO) - The value of the TriggerChannel1 at the point of the first trigger. This parameter is updated at the end of the CTFC and only makes sense if read from inside a callback.
//TriggerChannel2 ($) - The Channel which will be read for the second trigger.  This can be any channel addressable by td_xSetInWave.  You must set this parameter before setting TriggerValue.  If you change this parameter, you must update TriggerValue2 as well.
//TriggerType2 - The type of the second trigger.
		//0	Absolute
		//1	Relative Start
		//2	Relative Min
		//3	Relative Max
//TriggerValue2 - The second trigger will occur at (baseValue + TriggerValue2) where the baseValue is 0 for Absolute trigger, value of the TriggerChannel2 at the start of CTFC for Relative Start, minimum/maximum value of the TriggerChannel2 during the second ramp for Relative Min/Relative Max triggers.
//TriggerCompare2  - The type of comparision for the second trigger.
		//0	>=
		//1	<=
//TriggerPoint2 (RO) - The value of the TriggerChannel2 at the point of the second trigger. This parameter is updated at the end of the CTFC and only makes sense if read from inside a callback.
//TriggerHoldoff2 - After the first dwell, the second ramp will continue for this amount of time (in seconds) before the trigger value will be obeyed.
//StartTime (RO) - The time at which the last CTFC cycle began, in seconds.  This value only makes sense if read from inside a callback.
//TriggerTime1 (RO) - The time at which the first trigger occurred, in seconds, relative to StartTime.  Will return a number greater than 400,000 if trigger did not occur.  This value only makes sense if read from inside a callback.
//TriggerTime2 (RO) - The time at which the second trigger occurred, in seconds, relative to the beginning of the second ramp.  Therefore, you must add TriggerTime1 plus DwellTime1 (if dwell occurred) to this time in order to get the time relative to StartTime.  Will return a number greater than 400,000 if trigger did not occur.  This value only makes sense if read from inside a callback.
//DwellTime1 - If the first trigger occurs, this parameter specifies the time before the second ramp begins, in seconds.
//DwellTime2 - If the second trigger occurs, this parameter specifies the time (in seconds) before the callback will be called, or before the entire CTFC process will repeat.
//Callback ($) - An Igor function to execute once the CTFC has completed.  This callback will be called whether or not the trigger occured.
//EventDwell ($) - This event is set during the dwell portions of the CTFC.  It will be cleared during the ramps.  Must be a User Event.  Never or Always cannot be used here.  You can set one or two events, ie "3" or "3,4".  In the first case, Event 3 will be set during both dwells.  In the second case, Event 3 will be set during the first dwell, and Event 4 will be set during the second dwell.
//EventRamp ($) - This event is set during the ramp portions of the CTFC.  It will be cleared during the dwells.  Must be a User Event.  Never or Always cannot be used here.  You can set one or two events, ie "3" or "3,4".  In the first case, Event 3 will be set during both ramps.  In the second case, Event 3 will be set during the first ramp, and Event 4 will be set during the second ramp.
//EventEnable ($) - This event is checked at the beginning and end of the CTFC ramping.  If this event is set and a CTFC is not currently running, the CTFC will begin.  If this event is set at the end of a CTFC, another CTFC will repeat immediately.  This should be the last parameter you set before running a CTFC.  Note - an in-progress CTFC can be completely halted by setting this parameter to Never or calling td_Stop.

Static Function Init(RampChannel ($) - The channel to be ramped.  This can be any channel addressable by td_xSetOutWave.  You must set this parameter before setting any of the other ramp parameters.  If you change this parameter, you must update all the other ramp parameters as well.
//RampOffset1 - The maximum offset from the original position of the ramp channel we can move without a trigger before turning around.  This value cannot be zero.
//RampSlope1 - The attack speed of the first ramp, in units of the native units of the ramp channel per second.  Must be the same sign as RampOffset1.  This value cannot be zero.
//RampOffset2 - The offset from the triggered position of the ramp channel, applied after the dwell period.  If the trigger does not occur, this offset will be ramped from RampOffset1.  If this value is zero, no turn around will occur.  If this value is NaN, the ramp channel will be returned to its starting point.  Typically, the sign of this offset will be the opposite of RampOffset1, unless your goal is to ram the tip into the surface.
//RampSlope2 - The retreat speed of the return ramp, in units of the native units of the ramp channel per second.  Must be the same sign as RampOffset2, unless that is NaN.  Then the value must be the opposite sign of RampSlope1.  This value can only be zero if RampOffset2 is zero.
//RampTrigger (RO) - The value of the RampChannel at the point of triggering.    This value only makes sense if read from inside a callback.
//TriggerChannel1 ($) - The Channel which will be read for the first trigger.  This can be any channel addressable by td_xSetInWave.  You must set this parameter before setting TriggerValue.  If you change this parameter, you must update TriggerValue1 as well.
//TriggerType1 - The type of the first trigger.
//TriggerValue1 - The first trigger will occur at (baseValue + TriggerValue1) where the baseValue is 0 for Absolute trigger, value of the TriggerChannel1 at the start of CTFC for Relative Start, minimum/maximum value of the TriggerChannel1 during the first ramp for Relative Min/Relative Max triggers.
//TriggerCompare1  - The type of comparision for the first trigger.
		//0	>=
		//1	<=
Static StrConstant CTFC_TRIG_LTEQ = "<="
Static StrConstant CTFC_TRIG_GTED = ">="
//TriggerPoint1 (RO) - The value of the TriggerChannel1 at the point of the first trigger. This parameter is updated at the end of the CTFC and only makes sense if read from inside a callback.
//TriggerChannel2 ($) - The Channel which will be read for the second trigger.  This can be any channel addressable by td_xSetInWave.  You must set this parameter before setting TriggerValue.  If you change this parameter, you must update TriggerValue2 as well.
//TriggerType2 - The type of the second trigger.
		//0	Absolute
		//1	Relative Start
		//2	Relative Min
		//3	Relative Max
//TriggerValue2 - The second trigger will occur at (baseValue + TriggerValue2) where the baseValue is 0 for Absolute trigger, value of the TriggerChannel2 at the start of CTFC for Relative Start, minimum/maximum value of the TriggerChannel2 during the second ramp for Relative Min/Relative Max triggers.
//TriggerCompare2  - The type of comparision for the second trigger.
		//0	>=
		//1	<=
//TriggerPoint2 (RO) - The value of the TriggerChannel2 at the point of the second trigger. This parameter is updated at the end of the CTFC and only makes sense if read from inside a callback.
//TriggerHoldoff2 - After the first dwell, the second ramp will continue for this amount of time (in seconds) before the trigger value will be obeyed.
//StartTime (RO) - The time at which the last CTFC cycle began, in seconds.  This value only makes sense if read from inside a callback.
//TriggerTime1 (RO) - The time at which the first trigger occurred, in seconds, relative to StartTime.  Will return a number greater than 400,000 if trigger did not occur.  This value only makes sense if read from inside a callback.
//TriggerTime2 (RO) - The time at which the second trigger occurred, in seconds, relative to the beginning of the second ramp.  Therefore, you must add TriggerTime1 plus DwellTime1 (if dwell occurred) to this time in order to get the time relative to StartTime.  Will return a number greater than 400,000 if trigger did not occur.  This value only makes sense if read from inside a callback.
//DwellTime1 - If the first trigger occurs, this parameter specifies the time before the second ramp begins, in seconds.
//DwellTime2 - If the second trigger occurs, this parameter specifies the time (in seconds) before the callback will be called, or before the entire CTFC process will repeat.
//Callback ($) - An Igor function to execute once the CTFC has completed.  This callback will be called whether or not the trigger occured.
//EventDwell ($) - This event is set during the dwell portions of the CTFC.  It will be cleared during the ramps.  Must be a User Event.  Never or Always cannot be used here.  You can set one or two events, ie "3" or "3,4".  In the first case, Event 3 will be set during both dwells.  In the second case, Event 3 will be set during the first dwell, and Event 4 will be set during the second dwell.
//EventRamp ($) - This event is set during the ramp portions of the CTFC.  It will be cleared during the dwells.  Must be a User Event.  Never or Always cannot be used here.  You can set one or two events, ie "3" or "3,4".  In the first case, Event 3 will be set during both ramps.  In the second case, Event 3 will be set during the first ramp, and Event 4 will be set during the second ramp.
//EventEnabl