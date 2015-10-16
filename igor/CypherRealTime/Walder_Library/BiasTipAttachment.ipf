#pragma rtGlobals=3		// Use modern global access method and strict wave access.
Function TB_HoldAtHeight(TargetHeight,HoldTime)
	Variable TargetHeight, HoldTime

	Wave/T CenteringSettings = root:CFP:CenteringSettings
	Variable CurrentDefSetpoint_Volts =str2num(CenteringSettings[%$"TargetDeflection"])
	Variable XCurrentPosition_Volts = td_rv("Cypher.LVDT.X")
	Variable YCurrentPosition_Volts = td_rv("Cypher.LVDT.Y")
	Variable TargetHeight_Volts = TargetHeight

	Variable Error
	Variable WaveSize = floor(1024*HoldTime)
		
	Make/N=(WaveSize)/O XSensor, YSensor, XCommand, YCommand, ZSensor,Defl_Volts

	XCommand = XCurrentPosition_Volts
	YCommand = YCurrentPosition_Volts

	Error += td_stop()

	Error +=	ir_SetPISLoop(2,"Always,Never","Cypher.LVDT.Z",TargetHeight_Volts,0, 50000, 0,"Output.Z",-10,150)	
	Error +=	ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",XCurrentPosition_Volts,0, -5.616e4, 0,"ARC.Output.X",-10,150)
	Error +=	ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",YCurrentPosition_Volts,0, 5.768e4, 0,"ARC.Output.Y",-10,150)

	Error += td_xSetInWavePair(0, "0,0", "Cypher.LVDT.Z", ZSensor, "Deflection", Defl_Volts, "", 50)
	Error += td_xSetInWavePair(1, "0,0", "Cypher.LVDT.X", XSensor, "Cypher.LVDT.Y", YSensor, "TB_RampToConstantForce()", 50)
	
	Error +=td_WriteString("Event.0", "once")

	if (Error>0)
		print "Error in one of the td_ functions in sample pos and def ", Error
	endif
	
End

Function TB_RampToConstantForce()

	Wave/T CenteringSettings = root:CFP:CenteringSettings

	Variable XCurrentPosition_Volts = td_rv("Cypher.LVDT.X")
	Variable YCurrentPosition_Volts = td_rv("Cypher.LVDT.Y")
	Variable Error
	Variable Force_Volts = str2num(CenteringSettings[%$"TargetDeflection"]) // Need to add parameters to make this a real conversion.
	
	Error += td_stop()
	Error +=	ir_SetPISLoop(2,"Always,Never","Deflection",Force_Volts,0, 2999.999, 0,"Output.Z",-10,150)	
	Error +=	ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",XCurrentPosition_Volts,0, -5.616e4, 0,"ARC.Output.X",-10,150)
	Error +=	ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",YCurrentPosition_Volts,0, 5.768e4, 0,"ARC.Output.Y",-10,150)
	
	Variable WaveSize = 2048
	Make/N=(WaveSize)/O XSensor, YSensor, XCommand, YCommand, ZSensor,Defl_Volts
	Error += td_xSetInWavePair(0, "0,0", "Cypher.LVDT.Z", ZSensor, "Deflection", Defl_Volts, "", 50)
	Error += td_xSetInWavePair(1, "0,0", "Cypher.LVDT.X", XSensor, "Cypher.LVDT.Y", YSensor, "TB_CheckMoleculeAttachment()", 50)
	
	Error +=td_WriteString("Event.0", "once")

	
	if (Error>0)
		print "Error in one of the td_ functions in ramp to point: ", Error
	endif

End

Function TB_CheckMoleculeAttachment()
	Variable ZCurrentPosition_Volts= td_rv("Cypher.LVDT.Z")

	If(ZCurrentPosition_Volts > -0.1)
		TB_ForceRamp()
	Else
		Print "Railed, try again"
	Endif

End

Function TB_ForceRamp()	// Force Ramp After holding above the surface to try to bias the molecule to bind at the apex of the AFM tip
		Variable Error
		// Load CTFC Ramp Parameters into controller
		Wave/T TipBiasRamp = root:CFP:ForceRampSettings_TipBias
		SetDataFolder root:CFP

		StopLoop(2)
		Error+=td_stop()
		LoadCTFCParms(TipBiasRamp)
		Make/N=(65536)/O ZSensor_3,DefV_3
		IR_XSetInWavePair(0,"2","Deflection",DefV_3,"Cypher.LVDT.Z",ZSensor_3,"",1)
		ir_SetPISLoop(2,"2,3","ZSensor",0.,0, 75858, 0,"Output.Z",-10,150)// New stuff here and next line
		td_ws("PIDSLoop.DynamicSetpoint","Yes")
		StopLoop(2)
		 // Execute CTFC ramp
		Error+= td_WS("Event.2","Once")	
		If (Error > 0)
			Print "Error in Tip Bias Force Ramp"
		Endif
		print "Tip Bias Done"

End

Function TB_ForceRampCallback()	
	SetDataFolder root:CFP
	Wave/T MasterLoop = root:CFP:MasterLoopSettings
	Wave ZPos_m,ZPos = root:CFP:ZSensor_3
	Wave Def_N,Def = root:CFP:DefV_3
	
	ZPos_m = ZPos * GV("ZLVDTSens")
	Def_N = Def * GV("Invols")*GV("SpringConstant")
	
	String ZPosName = "root:CFP:SavedData:ZPos_Ramp3_"+MasterLoop[%$"Current Iteration"]
	String DefName = "root:CFP:SavedData:DefForce_Ramp3_"+MasterLoop[%$"Current Iteration"]
	
	Duplicate ZPos_m, $ZPosName
	Duplicate Def_N, $DefName
	
	

End
