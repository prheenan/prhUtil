#pragma rtGlobals=1		// Use modern global access method.

// Initialize the centered force pull program
Function InitializeCFP()

	//Build Datafolder for CFP and set that as current datafolder
	NewDataFolder/O root:CFP
	NewDataFolder/O root:CFP:SavedData
	
	SetDataFolder root:CFP
	
	ResetCurrentDataWaves()
	
	// Make Waves for Force Ramp Settings in real units
	Make/O/T/N=12 ForceRampSettings_InitialRamp,ForceRampSettings_Units, ForceRampSettings_Centered, CenteringSettings,CenteringSettings_Units,MasterLoopSettings,MasterLoopSettings_Units
	ForceRampSettings_InitialRamp= {"50","15","2","2","1","0","50","1","FirstRampCallback()",""}
 	ForceRampSettings_Units= {"pN","pN","micron/s","micron/s","s","s","nm","1 = Yes, 0 = No","Function to execute after ramp",""}
 	
 	SetDimLabel 0,0, $"Surface Trigger", ForceRampSettings_InitialRamp,ForceRampSettings_Units
 	SetDimLabel 0,1, $"Molecule Trigger", ForceRampSettings_InitialRamp,ForceRampSettings_Units
 	SetDimLabel 0,2, $"Approach Velocity", ForceRampSettings_InitialRamp,ForceRampSettings_Units
 	SetDimLabel 0,3, $"Retract Velocity", ForceRampSettings_InitialRamp,ForceRampSettings_Units
 	SetDimLabel 0,4, $"Surface Dwell Time", ForceRampSettings_InitialRamp,ForceRampSettings_Units
  	SetDimLabel 0,5, $"Retract Dwell Time", ForceRampSettings_InitialRamp,ForceRampSettings_Units
   	SetDimLabel 0,6, $"No Trigger Distance", ForceRampSettings_InitialRamp,ForceRampSettings_Units
    	SetDimLabel 0,7, $"Engage Second Trigger", ForceRampSettings_InitialRamp,ForceRampSettings_Units
 	SetDimLabel 0,8, $"CTFC Callback", ForceRampSettings_InitialRamp,ForceRampSettings_Units
 	
	// Make waves for force ramp once we have determined the center location of the molecule
	Duplicate/O/T ForceRampSettings_InitialRamp, ForceRampSettings_Centered,ForceRampSettings_TipBias
	ForceRampSettings_Centered = {"50","50","5","5","0","0","30","0","CenteredForcePullCallback()",""}
	ForceRampSettings_TipBias = {"50","50","5","5","0","0","30","0","TipBiasForceRampCallback()",""}

	// Make Waves for Centering Settings
	CenteringSettings= {"1","5","150","650 nm DNA","0","0","0","10","InitialRamp","0","0.2","50"}
	CenteringSettings_Units= {"None","None","nm","None","0= No, 1 = Yes","V","V","nm","None","None","Volts","nm"}
	
 	SetDimLabel 0,0, $"Number of Iterations", CenteringSettings,CenteringSettings_Units
 	SetDimLabel 0,1, $"Max Iterations", CenteringSettings,CenteringSettings_Units
 	SetDimLabel 0,2, $"Distance to move from center", CenteringSettings,CenteringSettings_Units
 	SetDimLabel 0,3, $"Molecule", CenteringSettings,CenteringSettings_Units
 	SetDimLabel 0,4, $"Center Found?", CenteringSettings,CenteringSettings_Units
  	SetDimLabel 0,5, $"Center X", CenteringSettings,CenteringSettings_Units
   	SetDimLabel 0,6, $"Center Y", CenteringSettings,CenteringSettings_Units
    	SetDimLabel 0,7, $"Critical Fit Difference", CenteringSettings,CenteringSettings_Units
     	SetDimLabel 0,8, $"State", CenteringSettings,CenteringSettings_Units
      	SetDimLabel 0,9, $"DiscreteIteration", CenteringSettings,CenteringSettings_Units
      	SetDimLabel 0,10, $"TargetDeflection", CenteringSettings,CenteringSettings_Units
      	SetDimLabel 0,11,$"CircleRadius", CenteringSettings,CenteringSettings_Units
   	
	// Mave Wave for Master Loop. 
	MasterLoopSettings= {"1","1000","10","10","10","0","4","0","4","0","0","0"}
 	MasterLoopSettings_Units= {"None","None","None","None","None","V","V","V","V","V","V","1=Yes or 0=No"}
 	
	SetDimLabel 0,0, $"Current Iteration", MasterLoopSettings,MasterLoopSettings_Units
 	SetDimLabel 0,1, $"Max Iterations", MasterLoopSettings,MasterLoopSettings_Units
 	SetDimLabel 0,2, $"Iterations per Surface Location", MasterLoopSettings,MasterLoopSettings_Units
 	SetDimLabel 0,3, $"Number Of X Surface Locations", MasterLoopSettings,MasterLoopSettings_Units
 	SetDimLabel 0,4, $"Number Of Y Surface Locations", MasterLoopSettings,MasterLoopSettings_Units
  	SetDimLabel 0,5, $"X Piezo Start", MasterLoopSettings,MasterLoopSettings_Units
   	SetDimLabel 0,6, $"X Piezo Finish", MasterLoopSettings,MasterLoopSettings_Units
    	SetDimLabel 0,7, $"Y Piezo Start", MasterLoopSettings,MasterLoopSettings_Units
    	SetDimLabel 0,8, $"Y Piezo Finish", MasterLoopSettings,MasterLoopSettings_Units
    	SetDimLabel 0,9, $"Target X Piezo", MasterLoopSettings,MasterLoopSettings_Units
    	SetDimLabel 0,10, $"Target Y Piezo", MasterLoopSettings,MasterLoopSettings_Units
    	SetDimLabel 0,11, $"End Master Loop", MasterLoopSettings,MasterLoopSettings_Units
    	
	DisplayCFPInfo("ForceRampTable")	
	DisplayCFPInfo("CenteringTable")
	DisplayCFPInfo( "MasterLoopTable")
	DisplayCFPInfo("XYSensor_nm")
	DisplayCFPInfo("XCenteringFit")
	DisplayCFPInfo("YCenteringFit")
	DisplayCFPInfo("ForceVsExt")
	DisplayCFPInfo("ZSensorGraph")
		
	ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",0,0, -5.616e4, 0,"ARC.Output.X",-10,150)
	ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",0,0, 5.768e4, 0,"ARC.Output.Y",-10,150)
	
	Execute "CFP_Panel()"
	
End // InitializeCTFC


Function ResetCurrentDataWaves()
	SetDataFolder root:CFP
	
	// Make Waves for Force Triggering
	Make/N=(1024)/O ZSensor,DefV, ZPos, DefForce
	Make/N=(1024)/O ZSensor_Ramp1,DefV_Ramp1, ZPos_Ramp1, DefForce_Ramp1
	Make/N=(1024)/O ZSensor_Ramp2,DefV_Ramp2, ZPos_Ramp2, DefForce_Ramp2	

	// Make waves for centering
	Make/N=(10,3)/O CenterXY
	SetDimLabel 1,0,x,CenterXY
	SetDimLabel 1,1,y,CenterXY
	SetDimLabel 1,2,z,CenterXY

	Make/O/N=13 XTargets,YTargets,ZTargets,DefTargets
	
	Make/O/N=3 Circles_X,Circles_Y,Circles_Z
	
	Make/N=(1024)/O XVoltage, YVoltage, XSensor, YSensor,Center_DefV,XSensor_nm,YSensor_nm
	Make/N=(512)/O XPos,YPos,XDef,YDef, XFit, YFit, XPos_nm,YPos_nm,XDef_pN,YDef_pN,XFit_pN,YFit_pN
	
End // ResetCurrentDataWaves

Function DisplayCFPInfo(TargetDisplay)
	String TargetDisplay
	DoWindow/F $TargetDisplay
	
	If (V_flag==0)		
		strswitch(TargetDisplay)
			case "ForceRampTable":
				Edit/W=(7.5,92.75,508.5,288.5)/N=$"ForceRampTable"  ForceRampSettings_Units.ld,ForceRampSettings_InitialRamp, ForceRampSettings_Centered,ForceRampSettings_TipBias
			break
			case "CenteringTable": 
				Edit/W=(5.25,323,336,535.25)/N=$"CenteringTable" CenteringSettings.ld,CenteringSettings_Units
			break	
			case "MasterLoopTable":
				Edit/W=(3.75,564.5,338.25,810.5)/N=$"MasterLoopTable" MasterLoopSettings.ld,MasterLoopSettings_Units
			break			
			case "XYVoltage":
				Display/K=1/N=$"XYVoltage"/W=(5.25,41.75,399.75,250.25) XVoltage
				Appendtograph/R YVoltage
				Label left "X (V)"
				Label bottom "Time (ms)"
				Label right "Y(V)"
			break			
			case "XYSensor":
				Display/K=1/N=$"XYSensor" /W=(1452,137,1846.5,345.5) XSensor
				Appendtograph/R YSensor
				Label left "X Sensor (V)"
				Label bottom "Time (ms)"
				Label right "Y Sensor (V)"
			break			
			case "XYSensor_nm":
				Display/K=1/N=$"XYSensor_nm"/W=(1452,137,1846.5,345.5)  XSensor_nm
				Appendtograph/R YSensor_nm
				Label left "X Sensor (nm)"
				Label bottom "Time (s)"
				Label right "Y Sensor (nm)"
			break			
			case "XCenteringFit":
				Display/W=(1452.75,377.75,1847.25,586.25)/K=1/N=$"XCenteringFit" XDef vs XPos 
				AppendToGraph XFit vs XPos
				ModifyGraph rgb(XFit) = (0,65535,0)
				ModifyGraph mode(XDef) = 4
				ModifyGraph lSize(XFit)=3
				Label left "Z Sensor (V)"
				Label bottom "X Sensor (V)"
			break			
			case "YCenteringFit":
				Display/W=(1860.75,375.5,2255.25,584)/K=1/N=$"YCenteringFit" YDef vs YPos
				AppendToGraph YFit vs YPos
				ModifyGraph rgb(YFit) = (0,65535,0)
				ModifyGraph mode(YDef) = 4
				ModifyGraph lSize(YFit)=3
				Label left "Z Sensor (V)"
				Label bottom "Y Sensor (V)"
			break			
			case "DefVsZSensor":
				Display/K=1/N=$"DefVsZSensor" DefV vs ZSensor
				SetAxis/A/R bottom
				Label left "Deflection (V)"
				Label bottom "Z Sensor (V)"
			break			
			case "ForceVsExt":
				Display/W=(1860,618.5,2254.5,827)/K=1/N=$"ForceVsExt" DefForce vs ZPos
				SetAxis/A/R bottom
				Label left "Force (pN)"
				Label bottom "Z Sensor (nm)"
			break		
			case "XYZD_Targets":
				Edit/W=(435,90.5,851.25,332.75)/N=$"XYZD_Targets" XTargets,YTargets,ZTargets,DefTargets
			break		
			case "ZSensorGraph":
				Display/W=(1449,620,1843.5,828.5)/K=1/N=$"ZSensorGraph" ZSensor
				Label left "Z Sensor (V)"
				Label bottom "Time (s)"
			break		

		endswitch  // TargetDisplay
	EndIf		
	
End // DisplayInfo

// GrabExistingCTFCparms imports the existing CTFC parameter group.  Makes it easier to write CTFC parameters without errors
Function GrabExistingCTFCparms()

	Make/O/T root:CFP:TriggerInfo
	Variable error=0
	
	error+=td_ReadGroup("ARC.CTFC",root:CFP:TriggerInfo)
	
	return error

End //GrabExistingCTFCparms()

// LoadCTFCparms function sets up the CTFC ramp parameters
Function LoadCTFCparms(RampSettings)
	Wave/T RampSettings
	Variable SurfaceTrigger,MoleculeTrigger, ApproachSpeed, RetractSpeed, NoTriggerTime,EngageSecondTrigger
	String RetractTriggerChannel
	Wave/T TriggerInfo=root:CFP:TriggerInfo
	
	String ErrorStr = ""
	Variable Scale = 1
	String RampChannel = ""

	// Calculate Ramp Settings from physical units (pN,microns, etc) into Voltages for Piezo and Deflection
	SurfaceTrigger = str2num(RampSettings[%'Surface Trigger'])*1e-12/GV("InvOLS")/GV("SpringConstant")
	MoleculeTrigger = -1*str2num(RampSettings[%'Molecule Trigger'])*1e-12/GV("InvOLS")/GV("SpringConstant")
	ApproachSpeed = str2num(RampSettings[%'Approach Velocity'])*1e-6/GV("ZPiezoSens")
	RetractSpeed = -1*str2num(RampSettings[%'Retract Velocity'])*1e-6/GV("ZPiezoSens")
	NoTriggerTime = str2num(RampSettings[%'No Trigger Distance'])*1e-9/(str2num(RampSettings[%'Retract Velocity'])*1e-6)
	
	// He we set up the retracting ramp.  If we are trying to detect a molecule, set ramp to $Deflection
	// If we are just trying to get a full force pull, then use output.Dummy.  This disables the second trigger.
	If (str2num(RampSettings[%'Engage Second Trigger'])==1)
		RetractTriggerChannel="Deflection"
	Else
		RetractTriggerChannel="output.Dummy"
	EndIf
	
	//  Setting up all the CTFC ramp info here. 
	RampChannel = "Output.Z"

	TriggerInfo[%RampChannel] = RampChannel
	TriggerInfo[%RampOffset1] = "160"  //Z Piezo volts
	TriggerInfo[%RampSlope1] = num2str(ApproachSpeed)  //Z Piezo Volts/s

	TriggerInfo[%RampOffset2] = "-100"
	TriggerInfo[%RampSlope2] = num2str(RetractSpeed) 
	
	TriggerInfo[%TriggerChannel1] = "Deflection"
	TriggerInfo[%TriggerValue1] = num2str(SurfaceTrigger) //Deflection Volts
	TriggerInfo[%TriggerCompare1] = ">="
	
	TriggerInfo[%TriggerChannel2] = RetractTriggerChannel
	TriggerInfo[%TriggerValue2] = num2str(MoleculeTrigger) 
	TriggerInfo[%TriggerCompare2] = "<="
	
	TriggerInfo[%TriggerHoldoff2] = num2str(NoTriggerTime)
	
	TriggerInfo[%DwellTime1] = RampSettings[%$"Surface Dwell Time"]
	TriggerInfo[%DwellTime2] = RampSettings[%$"Retract Dwell Time"]
	TriggerInfo[%EventDwell] = "3"
	TriggerInfo[%EventRamp] = "5"
	TriggerInfo[%EventEnable] = "2"
	TriggerInfo[%CallBack] = RampSettings[%'CTFC Callback']
	if (FindDimLabel(TriggerInfo,0,"TriggerType1") >= 0)
		TriggerInfo[%TriggerType1] = "Relative Start"
		TriggerInfo[%TriggerType2] = "Relative Start"
	endif

	ErrorStr += num2str(td_WriteString("Event.5","Clear"))+","
	ErrorStr += num2str(td_WriteString("Event.3","Clear"))+","
	ErrorStr += IR_StopInWaveBank(-1)
	ErrorStr += IR_StopOutWaveBank(-1)

	ErrorStr += num2str(td_writeGroup("ARC.CTFC",TriggerInfo))+","
	ARReportError(ErrorStr)	

End //LoadCTFCparms

Function SetInWavesFromCTFC()
	
	// Setup Inwaves for Force Ramp.  I'm using bank 0 for deflection and z sensor waves.  This is set to event 2	
	Make/N=(1536)/O ZSensor,DefV
	IR_XSetInWavePair(0,"2","Deflection",DefV,"Cypher.LVDT.Z",ZSensor,"",100)

End // SetInWavesFromCTFC

Function StartCFP()

	Wave/T InitialRamp = root:CFP:ForceRampSettings_InitialRamp
	Variable Error = 0
	// Clear event 2 (ramp) and event 0 (centering)
	Error += td_stop()
	Error += td_WS("Event.2","Clear")
	Error += td_WS("Event.0","Clear")
	// print td_WV("Output.Z",88)

	// Setup ramp
	SetDataFolder root:CFP
	GrabExistingCTFCParms()
	LoadCTFCParms(InitialRamp)
	SetInWavesFromCTFC()
	
	//	ir_StopPISLoop(NaN,LoopName="HeightLoop")

	// The one that works but with no feedback loop
	ir_SetPISLoop(2,"2,3","ZSensor",0.,0, 75858, 0,"Output.Z",-10,150)// New stuff here and next line
	//ir_SetPISLoop(5,"3,5","Deflection",NaN,0, 75858, 0,"Output.Z",-10,150)// New stuff here and next line
		ir_StopPISLoop(naN,LoopName="outputZLoop")
		ir_StopPISLoop(naN,LoopName="HeightLoop")
		CheckYourZ(1)

	
	// Fix the feedback loops so the CTFC will work.
	//	ir_SetPISLoop(2,"3,5","Deflection",NaN,0, 3000, 0,"Height",-10,150)// New stuff here and next line
		//td_ws("PIDSLoop.DynamicSetpoint","Yes")
			//ir_SetPISLoop(3,"3,5","Deflection",0.2,0, 75858, 0,"Output.Z",-10,150)// New stuff here and next line


	//Struct ARFeedbackStruct FB
	//ARGetFeedbackParms(FB,"CustomDwellLoop")
	//FB.DynamicSetpoint=NaN
	//String ErrorStr=""
	//ErrorStr+=ir_writePIDSLoop(FB)
	//Print ErrorStr
	StopLoop(2)
	//StopLoop(3)
	
	// Execute CTFC ramp
	Print "Executing First Force Ramp"
	Error += td_WS("Event.2","Once")

	
	If (Error > 0)
		print "Error in StartCFP"
	Endif

End //StartCFP()

// This callback exectues when the CTFC is done
Function FirstRampCallback() 
	
	print "FirstRampCallback()"
	Make/N=(1536)/O ZPos,DefForce
	Wave/T TriggerInfo=root:CFP:TriggerInfo
	Wave/T InitialRamp = root:CFP:ForceRampSettings_InitialRamp
	Wave/T CenteringSettings=root:CFP:CenteringSettings
	Wave DefVolts=root:CFP:DefV
	Wave ZSensorVolts = root:CFP:ZSensor
	Duplicate/O DefVolts, DefForce
	Duplicate/O ZSensorVolts, ZPos
	variable Error = 0
	variable MoleculeAttached =1  // Change this back to =1 when you do real tests with molecules
	
	td_ReadGroup("ARC.CTFC",TriggerInfo)
	
	// Calculate the target force in deflection volts
	Variable TargetDefV = DefVolts[0] - str2num(InitialRamp[%$"Molecule Trigger"])*1e-12/GV("InvOLS")/GV("SpringConstant")
	Variable CircleRadius = str2num(CenteringSettings[%$"CircleRadius"])
	CenteringSettings[%$"TargetDeflection"] = num2str(TargetDefV)
	
	//  Write a wave for deflection in newtons and Z Position in meters
	DefForce= DefVolts*GV("InvOLS")*GV("SpringConstant")
	ZPos = ZSensorVolts*GV("ZLVDTSens")
	
	Duplicate/O DefVolts, DefV_Ramp1
	Duplicate/O DefForce, DefForce_Ramp1
	Duplicate/O ZSensorVolts, ZSensor_Ramp1
	Duplicate/O ZPos, ZPos_Ramp1

	// Check to see if molecule is attached.  If Triggertime2 is greater than 400,000, then molecule did NOT attach
	if (str2num(TriggerInfo[%TriggerTime2])> 400000)
		MoleculeAttached=0
	endif
	
	// Execute Centering Routine if molecule is attachedf
	if (MoleculeAttached==1)  // Temporarily making this execute when a molecule isn't attached.  Just for testing.  Change this back to ==1 to fix.

		print "Execute Centering Routine"
		InitCentering()
		ConstantForceCircle( td_rv("Cypher.LVDT.X"), td_rv("Cypher.LVDT.Y"),CircleRadius,TargetDefV)
		
	endif
	
	If (Error>0)
		Print "Error in FirstRampCallback"
	EndIf
	
	// If no molecule attached, then finish this
	If (MoleculeAttached==0)
		CenteredForcePullCallback()
	endif

End //FirstRampCallback

function FineCenteringRoutineSetup()
	
	Variable XCurrentPosition = td_rv("PIDSLoop.0.Setpoint")	
	Variable YCurrentPosition = td_rv("PIDSLoop.1.Setpoint")
	variable CenterX = XCurrentPosition
	variable CenterY = YCurrentPosition
	
	Wave/T CenteringSettings = root:CFP:CenteringSettings
	Variable MaxDistance = str2num(CenteringSettings[%'Distance to move from center'])
	
	// For accumulating errors to make sure process is error free
	variable Error = 0
	
	// Set up callback 
	String CallbackString = "Beep"

	// Setup waves
	Make/N=(1024)/O XSensor, YSensor,ZSensor,Center_DefV
	Make/N=(1024)/O XVoltage, YVoltage
	
	variable MaxXDistance_Volts = MaxDistance*1e-9 / GV("XLVDTSens")
	variable MaxYDistance_Volts = MaxDistance*1e-9 / GV("YLVDTSens")
	
	// Calculate slope for triangle wave, in terms of volts for piezo stage
	Variable TriangleSlope_X = MaxXDistance_Volts/128
	Variable TriangleSlope_Y = MaxYDistance_Volts/128
	
	// Make XVoltage Triangle Wave with second sitting at origin
	XVoltage[0,128]= TriangleSlope_X*x
	XVoltage[129,384] = MaxXDistance_Volts - TriangleSlope_X*(x-128)
	XVoltage[385,512] = -MaxXDistance_Volts+TriangleSlope_X*(x-385)
	XVoltage[513,1024] = 0

	// Make YVoltage Triangle Wave with first half sitting at origin
	YVoltage[0,512] = 0
	YVoltage[513,640]= TriangleSlope_Y*(x-512)
	YVoltage[641,896] = MaxYDistance_Volts - TriangleSlope_Y*(x-641)
	YVoltage[897,1024] = -MaxYDistance_Volts+TriangleSlope_Y*(x-897)

	// Now offset to center position
	XVoltage+=CenterX
	YVoltage+=CenterY
	
	
	// Setup PIDS loop for closed loop XY Motion
	Variable Force_Volts = str2num(CenteringSettings[%$"TargetDeflection"])
		
	Error += td_stop()
	// Start Feedback Loops 
	Error +=	ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",XCurrentPosition,0, -5.616e4, 0,"ARC.Output.X",-10,150)
	Error +=	ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",YCurrentPosition,0, 5.768e4, 0,"ARC.Output.Y",-10,150)
	Error +=	ir_SetPISLoop(2,"Always,Never","Deflection",Force_Volts,0, 2999.999, 0,"Output.Z",-10,150)	

	// Put drive waves into the controller.  Centering is event 0
	Error += td_xSetOutWavePair(0, "0,0", "PIDSLoop.0.Setpoint", XVoltage, "PIDSLoop.1.Setpoint",YVoltage,100)

	// set up bank 1 to get deflection information and bank 2 to get x, y sensor data
	// After this finishes, it executes the FineCenteringCallback() function

	Error += td_xSetInWavePair(0, "0,0", "Cypher.LVDT.Z", ZSensor, "Deflection", Center_DefV, "", 100)
	Error += td_xSetInWavePair(1, "0,0", "Cypher.LVDT.X", XSensor, "Cypher.LVDT.Y", YSensor, "FineCenteringCallback()", 100)

	// Message if errors occurs
	if (Error)
		print "Error in Centering routine: ", Error
	endif
	
end

Function FineCenteringCallback()

	// Load Trigger Info
	Wave/T TriggerInfo=root:CFP:TriggerInfo
	Wave/T CenteringSettings = root:CFP:CenteringSettings
	Wave/T MasterLoopSettings = root:CFP:MasterLoopSettings
	
	Variable Error = 0
	variable test = 0
	variable CurrentX = td_rv("Cypher.LVDT.X")
	variable CurrentY = td_rv("Cypher.LVDT.Y")	
	variable CenterX =CurrentX
	variable CenterY = CurrentY
	String CurrentIterationStr = CenteringSettings[%$"Number Of Iterations"]+"_"+MasterLoopSettings[%$"Current Iteration"]
	Variable CenterIteration = str2num(CurrentIterationStr)
	
	// Load Centering Settings
	Wave/T CenteredRamp = root:CFP:ForceRampSettings_Centered
	
	Variable MaxIterations = str2num(CenteringSettings[%$"Max Iterations"])
	Variable CriticalFitDifference = str2num(CenteringSettings[%'Critical Fit Difference'])*1e-9
	
	Variable XCriticalFitDifference = Abs(CriticalFitDifference/GV("XLVDTSens")) // X Critical difference in LVDT volts
	Variable YCriticalFitDifference = Abs(CriticalFitDifference/GV("YLVDTSens")) // Y Critical difference in LVDT volts
	
	Duplicate/O root:CFP:XSensor, XSensor_nm
	Duplicate/O root:CFP:YSensor, YSensor_nm
	Duplicate/O root:CFP:ZSensor, ZSensor_nm
	
	XSensor_nm =  XSensor_nm*GV("XLVDTSens")
	YSensor_nm =  YSensor_nm*GV("YLVDTSens")

	// Split the raw waves into data for centering calculation
	Duplicate/O/R=[128,384] XSensor, XPos
	Duplicate/O/R=[128,384] ZSensor, XDef 
	Duplicate/O/R=[640,896] YSensor, YPos
	Duplicate/O/R=[640,896] ZSensor, YDef
	
	// Save this itetration data
	String XPosName =  "root:CFP:SavedData:XPos_"+ CurrentIterationStr
	String YPosName =  "root:CFP:SavedData:YPos_"+ CurrentIterationStr
	String XDefName =  "root:CFP:SavedData:XDef_"+ CurrentIterationStr
	String YDefName =  "root:CFP:SavedData:YDef_"+ CurrentIterationStr
		
	Duplicate/O XPos, $XPosName
	Duplicate/O YPos, $YPosName
	Duplicate/O XDef, $XDefName
	Duplicate/O YDef, $YDefName	
		
	// Calculate Center Positions
	CenterX = CalculateCenterPosition(XPos,XDef)
	Duplicate/O Quadratic_Fit, XFit
	String XFitName =  "root:CFP:SavedData:XFit_"+ CurrentIterationStr
	Duplicate/O Quadratic_Fit, $XFitName
	
	CenterY = CalculateCenterPosition(YPos,YDef)
	Duplicate/O Quadratic_Fit, YFit
	String YFitName =  "root:CFP:SavedData:YFit_"+ CurrentIterationStr
	Duplicate/O Quadratic_Fit, $YFitName
	
	Wave CenterXY=root:CFP:CenterXY
	CenterXY[CenterIteration][0] = CenterX
	CenterXY[CenterIteration][1] = CenterY

	CenteringSettings[%$"Center Found?"] = "0"
	CenteringSettings[%'Center X'] = num2str(CenterX)
	CenteringSettings[%'Center Y'] = num2str(CenterY)
	
	// Ramp to new center position at constant force and then execute MoveToNewCenterCallback()
	Variable Force_Volts = str2num(CenteringSettings[%$"TargetDeflection"])
	
	Error += td_stop()
	Error +=	ir_SetPISLoop(2,"Always,Never","Deflection",Force_Volts,0, 2999.999, 0,"Output.Z",-10,150)	
	Error +=	ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",CurrentX,0, -5.616e4, 0,"ARC.Output.X",-10,150)
	Error +=	ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",CurrentY,0, 5.768e4, 0,"ARC.Output.Y",-10,150)
	
 	Error += td_SetRamp(0.1, "PIDSLoop.0.Setpoint", 0, CenterX, "PIDSLoop.1.Setpoint", 0, CenterY, "", 0, 0, "MoveToNewCenterCallback()")
 	
	If (Error>0)
		Print "Error in Centering Callback"
	EndIf
	
End // Centering Callback

Function MoveToNewCenterCallback()

	// Load Trigger Info
	Wave/T TriggerInfo=root:CFP:TriggerInfo
	Wave/T CenteringSettings = root:CFP:CenteringSettings
	Wave/T MasterLoopSettings = root:CFP:MasterLoopSettings
	
	Variable Error = 0
	variable test = 0
	variable CurrentX = td_rv("Cypher.LVDT.X")
	variable CurrentY = td_rv("Cypher.LVDT.Y")	
	variable CenterX =CurrentX
	variable CenterY = CurrentY
	String CurrentIterationStr = CenteringSettings[%$"Number Of Iterations"]+"_"+MasterLoopSettings[%$"Current Iteration"]
	Variable CenterIteration = str2num(CurrentIterationStr)
	
	// Load Centering Settings
	Wave/T CenteredRamp = root:CFP:ForceRampSettings_Centered
	
	Wave CenterXY=root:CFP:CenterXY
	CenterXY[CenterIteration][0] = CenterX
	CenterXY[CenterIteration][1] = CenterY
	CenterXY[CenterIteration][2] = td_rv("Cypher.LVDT.z")	


	Variable MaxIterations = str2num(CenteringSettings[%$"Max Iterations"])
	Variable CriticalFitDifference = str2num(CenteringSettings[%'Critical Fit Difference'])*1e-9
	
	Variable XCriticalFitDifference = Abs(CriticalFitDifference/GV("XLVDTSens")) // X Critical difference in LVDT volts
	Variable YCriticalFitDifference = Abs(CriticalFitDifference/GV("YLVDTSens")) // Y Critical difference in LVDT volts
		// Determine if we found the center.  End if center is found, or if we reach the max number of iterations.
	If (CenterIteration==1)  // If this is the first iteration, run a second iteration to be sure we found the center
		test=1
	ElseIf ((CenterIteration<MaxIterations)&&(CenterIteration>1)) // If we are in between 2 iterations and the max iterations, see if we found a good center
		variable XDiff = Abs((CenterXY[CenterIteration-1][%x]-CenterXY[CenterIteration][%x]))
		variable YDiff =  Abs((CenterXY[CenterIteration-1][%y]-CenterXY[CenterIteration][%y]))
		
		
		If ((XDiff<XCriticalFitDifference)&&(YDiff<YCriticalFitDifference) ) 
			test = 0
			CenteringSettings[%$"Center Found?"] = "1" // We found the Center
			
		Else	// If not, try another centering
			test = 1
		Endif
		
	Else   // If we have reached the maximum number of iterations, go to center and ramp
		test=0
	EndIf
	
 	// Now, if center found then execute a ramp to get centered force data
	if (test==0)
		
		// Just a test print to confirm this callback is executing
		print "Centering Finished.  Executing Second Force Ramp"
		
		// Move to the center point
		// Setup PIDS loop for closed loop XY Motion
		ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",CenterX,0, -5.616e4, 0,"ARC.Output.X",-10,150)
		ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",CenterY,0, 5.768e4, 0,"ARC.Output.Y",-10,150)
		
		// Load CTFC Ramp Parameters into controller
		StopLoop(2)
		Error+=td_stop()
		LoadCTFCParms(CenteredRamp)
		Make/N=(120000)/O ZSensor_2,DefV_2
		IR_XSetInWavePair(0,"2","Deflection",DefV_2,"Cypher.LVDT.Z",ZSensor_2,"",1)
		ir_SetPISLoop(2,"2,3","ZSensor",0.,0, 75858, 0,"Output.Z",-10,150)// New stuff here and next line
		td_ws("PIDSLoop.DynamicSetpoint","Yes")
		CenteringSettings[%$"Center Found?"] = "1" 
		StopLoop(2)
		print " Second Force Ramp"
		 // Execute CTFC ramp
		Error+= td_WS("Event.2","Once")	

		
	endif  // test == 0
	
	If (test ==1)  // If we haven't found the center, try again to find the center
		Error += td_stop()
		Variable NewIteration = CenterIteration+1
		String NewIterationString = num2str(NewIteration)

		CenteringSettings[%$"Number Of Iterations"] = NewIterationString
		FineCenteringRoutineSetup()
		Error += td_WriteString("Event.0", "once")
		
	Endif  // test == 1
	
	If (Error>0)
		Print "Error in Centering Callback"
	EndIf
End

// Center calculation happens here. 
// Currently does a quadratic fit but then just returns the current center position.  Will change this when we have a sample with molecules. 
Function CalculateCenterPosition(PosData,DefData)
	Wave DefData, PosData
	Duplicate/O DefData Quadratic_Fit
	Make/D/O/N=4 Quadratic_Coeff
	
	Quadratic_Coeff[0] = WaveMin(DefData)
	Quadratic_Coeff[1] = (WaveMax(DefData)-WaveMin(DefData))/(WaveMax(PosData)-WaveMin(PosData))
	Quadratic_Coeff[2] = (WaveMax(DefData)-WaveMin(DefData))/(WaveMax(PosData)-WaveMin(PosData))
	Quadratic_Coeff[3] = PosData[256]
	FuncFit/Q/N/NTHR=0/W=2 QuadraticFit Quadratic_Coeff DefData /X=PosData /D=Quadratic_Fit
	FuncFit/Q/N/NTHR=0/W=2 QuadraticFit Quadratic_Coeff DefData /X=PosData /D=Quadratic_Fit

	Return Quadratic_Coeff[3]-(Quadratic_Coeff[1]/2/Quadratic_Coeff[2])
	
End //CalculateCenterPosition

// Custom Quadratic Fit Function.  Allows the center of the quadratic to vary, unlike to the stupid IGOR version
Function QuadraticFit(w,x) : FitFunc
	WAVE w
	Variable x

	return w[0]+w[1]*(x-w[3])+w[2]*(x-w[3])^2
End

// CenteredForcePullCallback()
// This is the function that executes after the centered force ramp is finished, or after the the first ramp when no molecule is attached
// I am iterating the master loop and put the centered force pull data in the appropriate place
// This will end the master loop when the end master loop parameter is set to "Yes" or when we have reached the maximum number of iterations
 
Function CenteredForcePullCallback()
	Variable Error
	// Make/N=(1024)/O ZPos_2,DefForce_2
	Wave DefVolts=root:CFP:DefV_2
	Wave ZSensorVolts = root:CFP:ZSensor_2
	Wave CenterXY = root:CFP:CenterXY
	Wave/T CenteringSettings = root:CFP:CenteringSettings
	Wave/T LoopSettings = root:CFP:MasterLoopSettings
	

	Duplicate/O DefVolts DefV_Ramp2,DefForce_Ramp2
	Duplicate/O DefForce_2 DefForce_Ramp2
	Duplicate/O ZSensorVolts ZSensor_Ramp2,ZPos_Ramp2
	Duplicate/O ZPos_2 ZPos_Ramp2
	
	//  Write a wave for deflection in newtons and Z Position in meters
	Variable ConvertToForce=GV("InvOLS")*GV("SpringConstant")
	FastOp DefForce_Ramp2= (ConvertToForce)*DefVolts
	Variable ConvertToPosition=GV("ZLVDTSens")
	FastOp ZPos_Ramp2 = (ConvertToPosition)*ZSensorVolts
	
	
	Variable NumberofIterations = str2num(CenteringSettings[%$"Number Of Iterations"])
	If (NumberofIterations>1)
		SaveCurrentData()
	EndIf
	
	// Set back to regular folder
	SetDataFolder root:CFP
	print	"Centered force ramp completed"
	
	// Iterate master loop and move to appropriate location
	String CurrentIterationStr = LoopSettings[%'Current Iteration']
	Variable CurrentIteration =str2num(LoopSettings[%'Current Iteration'])
	Variable MaxIterations = str2num(LoopSettings[%$"Max Iterations"])

	LoopSettings[%'Current Iteration'] = num2str(CurrentIteration+1)
	LoopLocation()
	
	// Move to the center point
	Error += td_wv("PIDSLoop.0.Setpoint",str2num(LoopSettings[%'Target X Piezo']))
	Error += td_wv("PIDSLoop.1.Setpoint",str2num(LoopSettings[%'Target Y Piezo']))
	
	// Start New Force Pull if we haven't reached the maximum number of iterations
	// If we have reached max iterations or have manually chosen to end master loop, then end the program.
	If ((CurrentIteration<MaxIterations)&&(str2num(LoopSettings[%$"End Master Loop"])==0))
		StartCFP()
	Else
		Print "Program Completed"
	EndIf
	
End CenteredForcePullCallback

Function SaveCurrentData()
	Wave/T LoopSettings = root:CFP:MasterLoopSettings
	String CurrentIterationStr = LoopSettings[%'Current Iteration']
	Make/T/O/N=25 WavesToSave,WavesToSaveName

	WavesToSave = {"DefForce_Ramp1","ZPos_Ramp1","DefV_Ramp1","ZSensor_Ramp1","DefForce_Ramp2","ZPos_Ramp2","DefV_Ramp2","ZSensor_Ramp2","Circles_X","Circles_Y","Circles_Z","XTargets","YTargets","ZTargets","DefTargets","CenterXY","XSensCircle_1","YSensCircle_1","ZSensCircle_1","DefVCircle_1","XSensCircle_2","YSensCircle_2","ZSensCircle_2","DefVCircle_2"}
	Variable Counter
	SetDataFolder root:CFP
	for(Counter=0;Counter<25;Counter+=1)	// Initialize variables;continue test
		WavesToSaveName[Counter] = "root:CFP:SavedData:"+WavesToSave[Counter] + "_" + CurrentIterationStr	
		Duplicate/O $WavesToSave[Counter] $WavesToSaveName[Counter] 
	endfor												
End SaveCurrentData

Function LoopLocation()
	Wave/T LoopSettings = root:CFP:MasterLoopSettings
	Make/O/N=2 TargetXYLocation
	
	Variable CurrentIteration = str2num(LoopSettings[%'Current Iteration'])
	Variable ForceRampsPerLocation = str2num(LoopSettings[%'Iterations per Surface Location'])
	Variable NumXSurfaceLocations = str2num(LoopSettings[%'Number Of X Surface Locations'])
	Variable NumYSurfaceLocations = str2num(LoopSettings[%'Number Of Y Surface Locations'])
	Variable TotalLocations = NumXSurfaceLocations*NumYSurfaceLocations
	Variable XPiezoStart = str2num(LoopSettings[%'X Piezo Start'])
	Variable XPiezoFinish = str2num(LoopSettings[%'X Piezo Finish'])
	Variable YPiezoStart = str2num(LoopSettings[%'Y Piezo Start'])
	Variable YPiezoFinish = str2num(LoopSettings[%'Y Piezo Finish'])
	
	Variable XDistance = (XPiezoFinish - XPiezoStart)/NumXSurfaceLocations
	Variable YDistance = (YPiezoFinish - YPiezoStart)/NumYSurfaceLocations
	
	Variable CurrentLocation = Floor(CurrentIteration/ForceRampsPerLocation)
	Variable XLocation = Floor(CurrentLocation/NumXSurfaceLocations)
	Variable YLocation = CurrentLocation-XLocation*NumXSurfaceLocations
	
	LoopSettings[%'Target X Piezo'] = num2str(XLocation*XDistance)
	LoopSettings[%'Target Y Piezo'] = num2str(YLocation*YDistance)
	
End  // LoopLocation

Function DisplayFits(SurfaceIteration)
	Variable SurfaceIteration
	
	//DisplayFitSeries("X",SurfaceIteration,"")
	// DisplayFitSeries("Y",SurfaceIteration,"")
	
	CreateUnitSeries("X",SurfaceIteration,"nm")
	CreateUnitSeries("Y",SurfaceIteration,"nm")
	
	DisplayFitSeries("X",SurfaceIteration,"nm")
	DisplayFitSeries("Y",SurfaceIteration,"nm")

End // DisplayAllCurrentFits

Function CreateUnitSeries(XorY,SurfaceIteration,Units)
	String XorY
	Variable SurfaceIteration
	String Units
	Variable Count
	String LVDTString = XorY+"LVDTSens"

	For (Count=1;Count< 11;Count+=1)

		String CurrentIterationStr = num2str(Count)+"_"+num2str(SurfaceIteration)
		
		String XPos_nmName =  XorY+"Pos_"+ CurrentIterationStr+Units
		String XDef_nmName =  XorY+"Def_"+ CurrentIterationStr+Units
		String XFit_nmName = XorY+"Fit_"+CurrentIterationStr+Units
		String XPosName = XorY +  "Pos_"+ CurrentIterationStr
		String XDefName =  XorY + "Def_"+ CurrentIterationStr
		String XFitName = XorY + "Fit_"+CurrentIterationStr
		
		If (WaveExists($XPosName)==1)
			Duplicate/O $XPosName $XPos_nmName
			Duplicate/O $XDefName $XDef_nmName
			Duplicate/O $XFitName $XFit_nmName
			
			Wave XPos = $XPosName
			Wave XPos_nm = $XPos_nmName
			XPos_nm=XPos*GV(LVDTString)*1e9
			Wave XDef = $XDefName
			Wave XDef_nm = $XDef_nmName
			XDef_nm=XDef*GV("ZLVDTSens")*1e9
			Wave XFit = $XFitName
			Wave XFit_nm = $XFit_nmName
			XFit_nm=XFit*GV("ZLVDTSens")*1e9
	EndIf
		
	EndFor
End // DisplayFitSeries

Function DisplayFitSeries(XorY,SurfaceIteration,Units)
	String XorY
	Variable SurfaceIteration
	String Units
	Variable Count, RealCount

	For (Count=1;Count< 11;Count+=1)
		String CurrentIterationStr = num2str(Count)+"_"+num2str(SurfaceIteration)+Units
		String XPosName = XorY +  "Pos_"+ CurrentIterationStr
		String XDefName =  XorY + "Def_"+ CurrentIterationStr
		String XFitName =  XorY + "Fit_"+CurrentIterationStr
		String XFitFullName = "root:CFP:SavedData:"+XFitName
		String XPosFullName = "root:CFP:SavedData:"+XPosName
		String XDefFullName = "root:CFP:SavedData:"+XDefName
		
		Wave XFit = $XFitFullName
		Wave XPos = $XPosFullName
		Wave XDef = $XDefFullName
		
		If (WaveExists($XPosName)==1)
			RealCount+=1
			If (Count==1)
				If (StringMatch(XorY,"X")==1)
					Display /W=(960,59.75,1354.5,268.25)/K=1 $XDefName vs $XPosName
				Else
					Display/W=(957.75,305.75,1352.25,514.25)/K=1 $XDefName vs $XPosName				
				EndIf
			Else	
				AppendToGraph $XDefName vs $XPosName
			EndIf
			AppendToGraph $XFitName vs $XPosName
			ModifyGraph rgb($XFitName) = (0,65535,0)
			ModifyGraph mode($XDefName) = 4
			ModifyGraph lSize($XFitName)=3
		EndIf
	EndFor
	
	String LastIterationStr = num2str(RealCount)+"_"+num2str(SurfaceIteration)+Units
	String XFitStatsName =  XorY + "Fit_"+LastIterationStr
	String XPosStatsName =  XorY + "Pos_"+LastIterationStr

	Wave XFitStats = $XFitStatsName
	Wave XPosStats = $XPosStatsName
	WaveStats/Q XFitStats
	Variable YOffset = -V_min
	Variable XOffset = -XPosStats[V_minRowLoc]
	ModifyGraph offset={XOffset,YOffset}
	Label left "Z Sensor (nm)"
	Label bottom XorY+" Sensor (nm)"
	ModifyGraph tickUnit=1

End // DisplayFitSeries

Function InitCentering()

	Wave/T CenteringSettings = root:CFP:CenteringSettings
	CenteringSettings[%State] = "FirstCircle"
	CenteringSettings[%DiscreteIteration] = "0"
	CenteringSettings[%$"Number of Iterations"] = "1"
	
	
	Make/O/N=3 Circles_X,Circles_Y,Circles_Z
	Circles_X[0]= td_rv("Cypher.LVDT.X")
	Circles_Y[0]= td_rv("Cypher.LVDT.Y")
	Circles_Z[0]= td_rv("Cypher.LVDT.Z")
	
	Make/O/N=13 XTargets,YTargets,ZTargets,DefTargets
	ZTargets = 0
	DefTargets = 0
	
	Make/O/N=(10,3) CenterXY
	SetDimLabel 1,0,x,CenterXY
	SetDimLabel 1,1,y,CenterXY
	SetDimLabel 1,2,z,CenterXY
	CenterXY=0
	
	Make/O/N=(1024) XSensCircle_1,YSensCircle_1,ZSensCircle_1,DefVCircle_1,XSensCircle_2,YSensCircle_2,ZSensCircle_2,DefVCircle_2
End

// New stuff for constant force movements
// Constant Force Circle Setup Part 1 of 3 needed functions
function ConstantForceCircle(XCenter,YCenter,Radius_nm,Force_pN)
	variable XCenter,YCenter,Radius_nm,Force_pN 
	variable Error = 0
	Wave/T CenteringSettings = root:CFP:CenteringSettings

	Make/N=(1024)/O XVoltage, YVoltage, XSensor, YSensor,XSensor_nm,YSensor_nm, XCommand, YCommand,ForceCommand, ZSensor,Defl_Volts,ZSensor_nm
	
	variable Radius_Volts = Radius_nm*1e-9 / GV("XLVDTSens")
	Variable Force_Volts = str2num(CenteringSettings[%$"TargetDeflection"]) // Need to add parameters to make this a real conversion.  

	XCommand = Radius_Volts*cos(2*pi*p/1024)+XCenter
	YCommand = Radius_Volts*sin(2*pi*p/1024)+YCenter
	ForceCommand = Force_Volts
	
	Variable XCurrentPosition = td_rv("PIDSLoop.0.Setpoint")	
	Variable YCurrentPosition = td_rv("PIDSLoop.1.Setpoint")
	
	Error += td_stop()
	// Start Feedback Loops and move to first point on circle.  The callback function ConstantForceCircleMove() will actually execute the movement 
	Error +=	ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",XCurrentPosition,0, -5.616e4, 0,"ARC.Output.X",-10,150)
	Error +=	ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",YCurrentPosition,0, 5.768e4, 0,"ARC.Output.Y",-10,150)
	Error +=	ir_SetPISLoop(2,"Always,Never","Deflection",Force_Volts,0, 2999.999, 0,"Output.Z",-10,150)	
	Error += td_SetRamp(0.25, "PIDSLoop.0.Setpoint", 0,XCommand[0], "PIDSLoop.1.Setpoint", 0, YCommand[0], "", 0, 0, "ConstantForceCircleMove()") 
	
	If (Error>0)
		print "Error in Constant Force Circle"
	EndIf
	
End
	
// Actually does the movement of a constant force circle
// part 2 of 3 on constant force circle.
Function ConstantForceCircleMove()

	Make/N=(1024)/O XSensor, YSensor,XCommand, YCommand, ZSensor,Defl_Volts
	
	Wave XCommand = root:CFP:XCommand 
	Wave YCommand = root:CFP:YCommand
	
	Variable Error
	//  Setup feedback loops
	Error +=	ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",XCommand[0],0, -5.616e4, 0,"ARC.Output.X",-10,150)
	Error +=	ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",YCommand[0],0, 5.768e4, 0,"ARC.Output.Y",-10,150)

	// Setup motion
	Error += td_xSetOutWavePair(0, "0,0", "PIDSLoop.0.Setpoint", XCommand, "PIDSLoop.1.Setpoint",YCommand,50)
	//Error+= td_xSetOutWave(1, "0,0", "PIDSLoop.2.Setpoint", ForceCommand, 100)
	
	// Setup input waves for x,y,z and deflection.  After the motion is done, ConstantForceCircleCallback() will execute
	Error += td_xSetInWavePair(0, "0,0", "Cypher.LVDT.Z", ZSensor, "Deflection", Defl_Volts, "ConstantForceCircleCallback()", 50)
	Error += td_xSetInWavePair(1, "0,0", "Cypher.LVDT.X", XSensor, "Cypher.LVDT.Y", YSensor, "", 50)

	// Execute motion
	Error +=td_WriteString("Event.0", "once")

	if (Error)
		print "Error in one of the td_ functions in ClosedLoopCircle: ", Error
	endif
	
end

// Callback for the circle movement.  converts positions and deflection to physical values
// Also calculates the maximum extension position and ramps to that point on the circle
// part 3 of 3 on constant force circle
Function ConstantForceCircleCallback()
 	Duplicate/O root:CFP:XSensor XSens,XSensor_nm,XSensorCirc
 	Duplicate/O root:CFP:YSensor YSens,YSensor_nm,YSensorCirc
 	Duplicate/O root:CFP:Defl_Volts DeflV,Defl_pN,Defl_VoltsCirc
 	Duplicate/O root:CFP:ZSensor ZSens,ZSensor_nm,ZSensorCirc
 	
 	// Convert all voltages to physical values
 	Variable XSens_LVDT=GV("XLVDTSens")*1e9
 	FastOp XSensor_nm=(XSens_LVDT)*XSensor_nm
 	YSensor_nm=YSensor_nm*GV("YLVDTSens")*1e9
 	ZSensor_nm = ZSensor_nm*GV("ZLVDTSens")*1e9
 	Defl_pN = DeflV*GV("SpringConstant")*GV("Invols")*1e12
 	
 	// Find Minimum Direction
 	WaveStats/Q ZSens
 	Variable MinDirectionRowLoc = V_minRowLoc
 	
 	// Move to maximium extension position on circle in 0.25 seconds
 	Variable Error = td_SetRamp(0.25, "PIDSLoop.0.Setpoint", 0, XSens[MinDirectionRowLoc], "PIDSLoop.1.Setpoint", 0, YSens[MinDirectionRowLoc], "", 0, 0, "StateChecker()")
 	
 	If (Error >0)
 		print "Error in Constant force callback"
 	Endif
 
 End // Function ConstantForce

// Ramp to an absolute position
Function RampToPointAtConstantForce_nm(XTarget_nm,YTarget_nm,Force_pN)
	Variable XTarget_nm,YTarget_nm,Force_pN //,Velocity_nmps
	Wave/T CenteringSettings = root:CFP:CenteringSettings

	variable XTarget_Volts = XTarget_nm*1e-9 / GV("XLVDTSens")
	variable YTarget_Volts = YTarget_nm*1e-9 / GV("YLVDTSens")
	Variable XCurrentPosition_Volts = td_rv("Cypher.LVDT.X")
	Variable YCurrentPosition_Volts = td_rv("Cypher.LVDT.Y")
	Variable Error
	Variable Force_Volts = str2num(CenteringSettings[%$"TargetDeflection"]) // Need to add parameters to make this a real conversion.
	
	Error += td_stop()
	Error +=	ir_SetPISLoop(2,"Always,Never","Deflection",Force_Volts,0, 2999.999, 0,"Output.Z",-10,150)	
	Error +=	ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",XCurrentPosition_Volts,0, -5.616e4, 0,"ARC.Output.X",-10,150)
	Error +=	ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",YCurrentPosition_Volts,0, 5.768e4, 0,"ARC.Output.Y",-10,150)
	
 	Error += td_SetRamp(0.1, "PIDSLoop.0.Setpoint", 0, XTarget_Volts, "PIDSLoop.1.Setpoint", 0, YTarget_Volts, "", 0, 0, "SamplePosAndDef()")
 	
	if (Error>0)
		print "Error in one of the td_ functions in ramp to point: ", Error
	endif

End  // Function RampToPointAtConstantForce_nm
Function RampToPointAtConstantForce(XTarget_Volts,YTarget_Volts,Force_pN)
	Variable XTarget_Volts,YTarget_Volts,Force_pN //,Velocity_nmps
	Wave/T CenteringSettings = root:CFP:CenteringSettings
//	variable XTarget_Volts = XTarget_nm*1e-9 / GV("XLVDTSens")
//	variable YTarget_Volts = YTarget_nm*1e-9 / GV("YLVDTSens")
	Variable XCurrentPosition_Volts = td_rv("Cypher.LVDT.X")
	Variable YCurrentPosition_Volts = td_rv("Cypher.LVDT.Y")
	Variable Error
	Variable Force_Volts = str2num(CenteringSettings[%$"TargetDeflection"])
	
	Error += td_stop()
	Error +=	ir_SetPISLoop(2,"Always,Never","Deflection",Force_Volts,0, 2999.999, 0,"Output.Z",-10,150)	
	Error +=	ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",XCurrentPosition_Volts,0, -5.616e4, 0,"ARC.Output.X",-10,150)
	Error +=	ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",YCurrentPosition_Volts,0, 5.768e4, 0,"ARC.Output.Y",-10,150)
	
 	Error += td_SetRamp(0.1, "PIDSLoop.0.Setpoint", 0, XTarget_Volts, "PIDSLoop.1.Setpoint", 0, YTarget_Volts, "", 0, 0, "SamplePosAndDef()")
 	
	if (Error>0)
		print "Error in one of the td_ functions in ramp to point: ", Error
	endif

End  // Function RampToPointAtConstantForce_nm

// Ramp to a point relative to the current position
Function RelativePointAtConstantForce(XTarget_nm,YTarget_nm,Force_pN)
	Variable XTarget_nm,YTarget_nm,Force_pN //,Velocity_nmps
	Wave/T CenteringSettings = root:CFP:CenteringSettings
	
	Variable XCurrentPosition_Volts = td_rv("Cypher.LVDT.X")
	Variable YCurrentPosition_Volts = td_rv("Cypher.LVDT.Y")
	variable XTarget_Volts = XTarget_nm*1e-9 / GV("XLVDTSens")+XCurrentPosition_Volts
	variable YTarget_Volts = YTarget_nm*1e-9 / GV("YLVDTSens")+YCurrentPosition_Volts
	Variable Error
	Variable Force_Volts = str2num(CenteringSettings[%$"TargetDeflection"])
	
	Error += td_stop()
	Error +=	ir_SetPISLoop(2,"Always,Never","Deflection",Force_Volts,0, 2999.999, 0,"Output.Z",-10,150)	
	Error +=	ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",XCurrentPosition_Volts,0, -5.616e4, 0,"ARC.Output.X",-10,150)
	Error +=	ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",YCurrentPosition_Volts,0, 5.768e4, 0,"ARC.Output.Y",-10,150)

 	Error += td_SetRamp(0.1, "PIDSLoop.0.Setpoint", 0, XTarget_Volts, "PIDSLoop.1.Setpoint", 0, YTarget_Volts, "", 0, 0, "SamplePosAndDef()")
 	
	if (Error>0)
		print "Error in one of the td_ functions in relative move to point: ", Error
	endif

End  // Function RampToPointAtConstantForce

// Sample Position and Deflection for 0.25 Seconds
Function SamplePosAndDef()
	Wave/T CenteringSettings = root:CFP:CenteringSettings
	
	Variable CurrentDefSetpoint_Volts =str2num(CenteringSettings[%$"TargetDeflection"])

	Variable XCurrentPosition_Volts = td_rv("Cypher.LVDT.X")
	Variable YCurrentPosition_Volts = td_rv("Cypher.LVDT.Y")

	Variable Error
		
	Make/N=(512)/O XSensor, YSensor, XCommand, YCommand, ZSensor,Defl_Volts

	XCommand = XCurrentPosition_Volts
	YCommand = YCurrentPosition_Volts

	Error += td_stop()
	Error +=	ir_SetPISLoop(2,"Always,Never","Deflection",CurrentDefSetpoint_Volts,0, 2999.999, 0,"Output.Z",-10,150)	
	Error +=	ir_SetPISLoop(0,"Always,Never","Cypher.LVDT.X",XCurrentPosition_Volts,0, -5.616e4, 0,"ARC.Output.X",-10,150)
	Error +=	ir_SetPISLoop(1,"Always,Never","Cypher.LVDT.Y",YCurrentPosition_Volts,0, 5.768e4, 0,"ARC.Output.Y",-10,150)


	Error += td_xSetOutWavePair(0, "0,0", "PIDSLoop.0.Setpoint", XCommand, "PIDSLoop.1.Setpoint",YCommand,25)
	
	Error += td_xSetInWavePair(0, "0,0", "Cypher.LVDT.Z", ZSensor, "Deflection", Defl_Volts, "", 25)
	Error += td_xSetInWavePair(1, "0,0", "Cypher.LVDT.X", XSensor, "Cypher.LVDT.Y", YSensor, "ConvertPosAndDef()", 25)
	
	Error +=td_WriteString("Event.0", "once")

	if (Error>0)
		print "Error in one of the td_ functions in sample pos and def ", Error
	endif
	
End // SamplePosAndDef
// Convert Position and Deflection to physical quantities
Function ConvertPosAndDef()
	// Beep
	Duplicate/O root:CFP:XSensor XSens,XSensor_nm
 	Duplicate/O root:CFP:YSensor YSens,YSensor_nm
 	Duplicate/O root:CFP:Defl_Volts DeflV,Defl_pN
 	Duplicate/O root:CFP:ZSensor ZSens,ZSensor_nm
 	
 	// Convert all voltages to physical values
 	XSensor_nm=XSensor_nm*GV("XLVDTSens")*1e9
 	YSensor_nm=YSensor_nm*GV("YLVDTSens")*1e9
 	ZSensor_nm = ZSensor_nm*GV("ZLVDTSens")*1e9
 	Defl_pN = DeflV*GV("SpringConstant")*GV("Invols")*1e12
 	
 	Make/O RawValues,PhysicalValues

	SetDimLabel 0,0, $"XPos",RawValues,PhysicalValues
 	SetDimLabel 0,1, $"YPos", RawValues,PhysicalValues
 	SetDimLabel 0,2, $"ZPos",RawValues,PhysicalValues
 	SetDimLabel 0,3, $"Defl", RawValues,PhysicalValues
 	
 	RawValues = {Mean(XSens),Mean(YSens),Mean(ZSens),Mean(DeflV)}
 	PhysicalValues = {Mean(XSensor_nm),Mean(YSensor_nm),Mean(ZSensor_nm),Mean(Defl_pN)}
 	StateChecker()
 	
End // ConvertPosAndDef

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

//  This function controls the sequence of events for the centering protocol
//  It also checks to make sure the molecule didn't detach.  If it detached, then start a new iteration.  
Function StateChecker()
	
	Wave/T Centering = root:CFP:CenteringSettings
	Wave/T MasterLoop = root:CFP:MasterLoopSettings
	Wave Circles_X = root:CFP:Circles_X	
	Wave Circles_Y = root:CFP:Circles_Y
	Wave Circles_Z = root:CFP:Circles_Z
	Wave XTargets = root:CFP:XTargets
	Wave YTargets = root:CFP:YTargets
	Wave ZTargets = root:CFP:ZTargets
	Wave DeflTargets = root:CFP:DefTargets
	Wave RawValues = root:CFP:RawValues
	Wave XSensorCirc = root:CFP:XSensorCirc
	Wave YSensorCirc = root:CFP:YSensorCirc
	Wave ZSensorCirc = root:CFP:ZSensorCirc
	Wave Defl_VoltsCirc = root:CFP:Defl_VoltsCirc

	Variable CurrentDefSetpoint_Volts = str2num(Centering[%$"TargetDeflection"])
	Variable XCurrentPosition_Volts = td_rv("Cypher.LVDT.X")
	Variable YCurrentPosition_Volts = td_rv("Cypher.LVDT.Y")
	Variable ZCurrentPosition_Volts= td_rv("Cypher.LVDT.Z")
	Variable CircleRadius = str2num(Centering[%$"CircleRadius"])
	
	// Check to see if zsensor has railed.  Probably means the molecule has disconnected.	
	If (ZCurrentPosition_Volts < 0.28)
		Centering[%State] = "Railed"
	EndIf
	
	If (str2num(MasterLoop[%$"End Master Loop"])== 1)
		Centering[%State] = "EndProgram"
	EndIf

		
	Strswitch (Centering[%State])
		case "FirstCircle":
			print "First Circle"
			Centering[%State] = "SecondCircle"
			Duplicate/O XSensorCirc,XSensCircle_1
			Duplicate/O YSensorCirc,YSensCircle_1
			Duplicate/O ZSensorCirc,ZSensCircle_1
			Duplicate/O Defl_VoltsCirc,DefVCircle_1
			
			Circles_X[1]= td_rv("Cypher.LVDT.X")
			Circles_Y[1]= td_rv("Cypher.LVDT.Y")
			Circles_Z[1]= td_rv("Cypher.LVDT.Z")
			
			ConstantForceCircle(XCurrentPosition_Volts,YCurrentPosition_Volts,CircleRadius,CurrentDefSetpoint_Volts)
		break
		case "SecondCircle":
			print "two circles done"
			Duplicate/O XSensorCirc,XSensCircle_2
			Duplicate/O YSensorCirc,YSensCircle_2
			Duplicate/O ZSensorCirc,ZSensCircle_2
			Duplicate/O Defl_VoltsCirc,DefVCircle_2


			Centering[%State] = "DiscreteMoves"
			Circles_X[2]= td_rv("Cypher.LVDT.X")
			Circles_Y[2]= td_rv("Cypher.LVDT.Y")
			Circles_Z[2]= td_rv("Cypher.LVDT.Z")
			
			// Move in 100nm increments
			Variable DistanceIncrement = 100e-9/GV("XLVDTSens") // convert distance to volts
			// Fit line to determine path to center
			CurveFit/Q/M=2/W=0 line, Circles_Y/X=Circles_X/D
			Wave FitValues = root:CFP:W_coef
			Variable Angle = atan(FitValues[1])
			Variable XIncrement = abs(DistanceIncrement*cos(Angle))
			Variable YIncrement = abs(DistanceIncrement*sin(Angle))
						
			If (Circles_X[2]>Circles_X[0])
				XTargets = XIncrement*p+Circles_X[2]
			ElseIf (Circles_X[2]<Circles_X[0])
				XTargets = -p*XIncrement+Circles_X
			EndIf

			If (Circles_Y[2]>Circles_Y[0])
				YTargets = YIncrement*p+Circles_Y[2]
			ElseIf (Circles_Y[2]<Circles_Y[0])
				YTargets = -p*YIncrement+Circles_Y
			EndIf
			ZTargets[0] = ZCurrentPosition_Volts
			DeflTargets[0] = CurrentDefSetpoint_Volts
			
			Centering[%DiscreteIteration] = "1"
			RampToPointAtConstantForce(XTargets[1],YTargets[1],CurrentDefSetpoint_Volts)
		break
		case "DiscreteMoves":
			Variable Iteration = str2num(Centering[%DiscreteIteration])

			ZTargets[Iteration] = RawValues[%ZPos]
			DeflTargets[Iteration] = RawValues[%Defl]
			// If more than one discrete point recorded, then test them to see if we have passed the point of maximum extension
			// If not, then move to the next point
			If (Iteration == 1)
				Centering[%DiscreteIteration] = "2"
				RampToPointAtConstantForce(XTargets[2],YTargets[2],CurrentDefSetpoint_Volts)
			
			ElseIf ((Iteration>=2)&&(Iteration<=13))
				If ((ZTargets[Iteration]>ZTargets[Iteration-1])&&(ZTargets[Iteration-1]>ZTargets[Iteration-2]))
					Centering[%State] = "FineTuneCenter"
					RampToPointAtConstantForce(XTargets[Iteration-2],YTargets[Iteration-2],CurrentDefSetpoint_Volts)
				Else
					Iteration+=1
					Centering[%DiscreteIteration] = num2str(Iteration)
					RampToPointAtConstantForce(XTargets[Iteration],YTargets[Iteration],CurrentDefSetpoint_Volts)
				EndIf
			
			EndIf // iteration >1
			If (Iteration>13)
				CenteredForcePullCallback()
			Endif
						
		break
		case "FineTuneCenter":
			FineCenteringRoutineSetup()
			print td_WriteString("Event.0", "once")
		break
		case "Railed":
			print "Molecule disconnected."
			CenteredForcePullCallback()

		break
		case "EndProgram":
			print "End Program"
			
		break
		default:	
			print "Error, in default state"
	EndSwitch
	
End
//////////////////////////// Functions to process CFP stats.  

// This batch processes all the CFP stats.  First is generates an index of all CFPs.  Then it generates stats by individual CFP
// Finally is compiles some waves that have specific stats of importance, such as distance from start position to center position

Function InitCenterProcessing()
	AllCFPStats()
	DisplayAllCFPStats()
	DisplayAllFvsExt(20)

End 


// Centering Report
// This generates a bunch of graphs based on the saved centering data.  Should be useful for analysis and debugging
Function CenteringReport(MasterLoopIteration)
	Variable	MasterLoopIteration
	String IterationString = "_"+num2str(MasterLoopIteration)
	SetDataFolder root:CFP:SavedData
	
	// Wave Names for import
	String CirclesXName = "Circles_X"+IterationString
	String CirclesYName = "Circles_Y"+IterationString
	String XTargetsName = "XTargets"+IterationString
	String YTargetsName = "YTargets"+IterationString
	String ZTargetsName = "ZTargets"+IterationString
	String DefTargetsName = "DefTargets"+IterationString
	String CenterXYName = "CenterXY"+IterationString
	String CenterRamp_ForceName = "DefForce_Ramp2"+ IterationString
	String SmoothCenterRamp_ForceName = "DefForce_Ramp2"+ IterationString + "_smth"
	String CenterRamp_ExtName = "ZPos_Ramp2"+ IterationString
	String CFPStatsName = "CFPStats" + IterationString

	// Local Wave References
	Wave CirclesX = $CirclesXName
	Wave CirclesY = $CirclesYName	
	Wave XTargets = $XTargetsName
	Wave YTargets = $YTargetsName
	Wave ZTargets = $ZTargetsName
	Wave DefTargets = $DefTargetsName
	Wave CenterXY = $CenterXYName
	Wave CenterRamp_Force= $CenterRamp_ForceName
	Wave CenterRamp_Ext = $CenterRamp_ExtName
	Wave CenterRamp_ForceSmth = $SmoothCenterRamp_ForceName
	Wave CFPStats = $CFPStatsName
	
	Variable Counter,DiscreteSteps
	Variable ZTargetsSize = DimSize(ZTargets,0)
	// Fine number of discrete steps												
	for(Counter=0;Counter < ZTargetsSize;Counter+=1)	
		If (ZTargets[Counter]!=0)
			DiscreteSteps+=1
		EndIf									
	endfor	
	Duplicate/O/R=[0,DiscreteSteps] ZTargets, ZTargets_nm
	Duplicate/O/R=[0,DiscreteSteps] XTargets, XTargets_nm
	Duplicate/O/R=[0,DiscreteSteps] YTargets, YTargets_nm
	Duplicate/O CirclesX, CirclesX_nm
	Duplicate/O CirclesY, CirclesY_nm
	
	Variable CenterXYRealSize = 0
	Variable CenterXYSize = DimSize(CenterXY,0)
	
	// Detail in waves to handle.  Find the number of fine centering points
	for(Counter=0;Counter < CenterXYSize;Counter+=1)	
		If (CenterXY[Counter]!=0)
			CenterXYRealSize+=1
		EndIf									
	endfor	
	CirclesX_nm = CirclesX*GV("XLVDTSens")*1e9 
	CirclesY_nm = CirclesY*GV("YLVDTSens")*1e9
	Variable XStart_nm = CirclesX_nm[0]
	Variable YStart_nm = CirclesY_nm[0]
	
	CirclesX_nm-=XStart_nm
	CirclesY_nm-=YStart_nm

	YTargets_nm = YTargets*GV("YLVDTSens")*1e9-YStart_nm
	ZTargets_nm = ZTargets*GV("ZLVDTSens")*1e9
	XTargets_nm = XTargets*GV("XLVDTSens")*1e9-XStart_nm

	Duplicate/O/R=[1,CenterXYRealSize][0] CenterXY, FineCenterX_nm,FineCenterX
	Duplicate/O/R=[1,CenterXYRealSize][1] CenterXY, FineCenterY_nm,FineCenterY
	FineCenterX_nm=FineCenterX* GV("XLVDTSens")*1e9-XStart_nm
	FineCenterY_nm=FineCenterY* GV("YLVDTSens")*1e9-YStart_nm

	// Centering pathway display for report
	Display/W=(534,53.75,928.5,262.25)/K=1 CirclesY_nm vs CirclesX_nm
	AppendToGraph YTargets_nm vs XTargets_nm
	AppendToGraph FineCenterY_nm vs FineCenterX_nm
	ModifyGraph rgb(YTargets_nm) = (0,65535,0)
	ModifyGraph rgb(FineCenterY_nm) = (0,0,65535)
	ModifyGraph mode = 3
	ModifyGraph lSize= 2
	ModifyGraph Marker(CirclesY_nm) = 8
	ModifyGraph Marker(FineCenterY_nm) = 1
	Label left "X Sensor (nm)"
	Label bottom "Y Sensor (nm)"
	
	// Display Centering Force vs Extension in physical units
	WaveStats/Q CenterRamp_Force
	Display/W=(537,304.25,931.5,512.75)/K=1 CenterRamp_Force vs CenterRamp_Ext
	AppendToGraph CenterRamp_ForceSmth vs CenterRamp_Ext
	ModifyGraph rgb($CenterRamp_ForceName) = (0,65535,0)
	ModifyGraph rgb($SmoothCenterRamp_ForceName) = (0,0,0)
	Label left "Force (N)"
	Label bottom "Extension (m)"
	ModifyGraph offset={CFPStats[%$"ExtensionOffset"],CFPStats[%$"ForceOffset"]},muloffset={-1,-1}
	ModifyGraph tickUnit=1
	
	// Display Fits
	DisplayFits(MasterLoopIteration)
	
	// Make Table of CFP Stats
	Edit/K=1/W=(145.5,51.5,521.25,380.75) CFPStatsUnits.ld,$CFPStatsName
	ModifyTable format(Point)=1,width(CFPStatsUnits.l)=131

	// More waves to add later
	//Make/N=(1024) XSensCircle_1,YSensCircle_1,ZSensCircle_1,DefVCircle_1,XSensCircle_2,YSensCircle_2,ZSensCircle_2,DefVCircle_2
	SetDataFolder root:CFP

End




Function AllCFPStats()
	GetCFPIndexes()
	SetDataFolder root:CFP:SavedData

	Variable NumCFP = DimSize(CFPIndexes,0)
	Variable Counter = 0
	Wave CFPIndexes = CFPIndexes
	
	for(Counter=0;Counter < NumCFP;Counter+=1)	
		GetCFPStats(CFPIndexes[Counter])			
	endfor
	
	CFPStats("DistanceFromStartToCenter")
	CFPStats("XStandardDevFineCenter")
	CFPStats("YStandardDevFineCenter")
	CFPStats("BreakingForce")
	CFPStats("BreakingExtension")
	CFPStats("TipConnectionHeight")
	CFPStats("EndToEndDistance")


End

Function DisplayAllCFPStats()
	SetDataFolder root:CFP:SavedData
	Wave CFPIndexes = CFPIndexes
	Variable NumCFP = DimSize(CFPIndexes,0)
	Variable Counter = 0
	Edit/K=1/W=(167.25,312.5,1285,545.75) CFPStatsUnits.ld
	
	String StatsName
	for(Counter=0;Counter < NumCFP;Counter+=1)	
		StatsName = "CFPStats_"+num2str(CFPIndexes[Counter])
		AppendToTable $StatsName
	endfor
	ModifyTable format(Point)=1,width(CFPStatsUnits.l)=155

End
Function DisplayAllFvsExt(ForceMatch)
	Variable ForceMatch
	SetDataFolder root:CFP:SavedData
	Wave CFPIndexes = CFPIndexes
	Variable NumCFP = DimSize(CFPIndexes,0)
	Variable Counter = 0	
	String StatsName
	for(Counter=0;Counter < NumCFP;Counter+=1)	
		String ForceWaveName = "DefForce_Ramp2_"+num2str(CFPIndexes[Counter])
		String SmoothForceName = ForceWaveName+"_smth"
		String ExtensionWaveName = "ZPos_Ramp2_"+num2str(CFPIndexes[Counter])
		String CFPStatsName = "CFPStats_"+num2str(CFPIndexes[Counter])

		Wave ForceWave = $ForceWaveName
		Wave SmoothForceWave = $SmoothForceName
		Wave ExtensionWave = $ExtensionWaveName
		Wave CFPStatsWave = $CFPStatsName
		
		WaveStats/Q ForceWave
		Variable ForceGraphOffset = CFPStatsWave[%$"ForceOffset"]
		Variable ForceThreshold = ForceGraphOffset - ForceMatch*1e-12
		FindLevel/Q/P/R=[50,20000] SmoothForceWave, ForceThreshold
		Variable ExtOffset = ExtensionWave[V_LevelX]
		
		If (Counter == 0)
			Display/N=AllFvsXGraphs/W=(537,304.25,931.5,512.75)/K=1 SmoothForceWave vs ExtensionWave
			ModifyGraph offset($SmoothForceName) = {ExtOffset,ForceGraphOffset}

		Else
			AppendToGraph SmoothForceWave vs ExtensionWave
			ModifyGraph offset($SmoothForceName) = {ExtOffset,ForceGraphOffset}
		EndIf
		// WaveStats/Q ForceWave
		//Variable ForceGraphOffset = ForceWave[V_minRowLoc+20]
		//Variable ExtOffset = WaveMax(ExtensionWave)
		// ModifyGraph offset($ForceWaveName) = {ExtOffset,ForceGraphOffset}
	endfor

	Label left "Force (N)"
	Label bottom "Extension (m)"
	ModifyGraph muloffset={-1,-1}
	ModifyGraph tickUnit=1
	
End


// Generate the a wave that contains a list of all the indexed centered force pulls.
Function GetCFPIndexes()
	SetDataFolder root:CFP:SavedData
	String traces= WaveList("CenterXY_*",";","")		// Traces in top graph 
	Variable n= ItemsInList(traces)
	Make/O/T/N=(n) textWave= StringFromList(p,traces)
	Make/O/N=(n) CFPIndexes = str2num(StringFromList(1,textWave[p],"_"))
	KillWaves textWave
	SetDataFolder root:CFP
End

Function CFPStats(StatsProperty)
	String StatsProperty

	SetDataFolder root:CFP:SavedData
	Variable NumCFP = DimSize(CFPIndexes,0)
	Variable Counter = 0
	Wave CFPIndexes = CFPIndexes
	String StatsWaveName = "CFP_"+StatsProperty
	
	Make/O/N=(NumCFP) $StatsWaveName
	Wave StatsWave = $StatsWaveName
	
	for(Counter=0;Counter < NumCFP;Counter+=1)	
		String CFPStatsWaveName = "CFPStats_" + num2str(CFPIndexes[Counter])
		Wave CFPStats = $CFPStatsWaveName
		StatsWave[Counter] = CFPStats[%$StatsProperty]
	 	SetDimLabel 0,Counter, $num2str(CFPIndexes[Counter]), StatsWave
	endfor
	
End

// Calculate a set of statistics from centered force pull
Function GetCFPStats(Iteration)
	Variable Iteration
	String Units
	
	String IterationString = "_"+num2str(Iteration)
	SetDataFolder root:CFP:SavedData
	String CenterXYName = "CenterXY" + IterationString
	String CirclesXName = "Circles_X"+ IterationString
	String CirclesYName = "Circles_Y" + IterationString
	String ZTargetsName = "ZTargets"+IterationString
	String ForceName = "DefForce_Ramp2" + IterationString
	String ExtensionName = "ZPos_Ramp2" + IterationString
	String SmoothForceName = "DefForce_Ramp2" + IterationString+"_smth"

	Wave CirclesX = $CirclesXName
	Wave CirclesY = $CirclesYName	
	Wave CenterXY = $CenterXYName
	Wave ZTargets = $ZTargetsName
	Wave ForceWave = $ForceName
	Wave ExtensionWave = $ExtensionName
	Duplicate/O ForceWave, $SmoothForceName
	Wave SmoothForceWave = $SmoothForceName	
	Smooth/M=0 1000, SmoothForceWave

	Variable CirclesSize = DimSize(CirclesX,0)
	Variable CenterXYSize = DimSize(CenterXY,0)
	Variable CenterXYRealSize = 0
	Variable DiscreteSteps = 0
	Variable Counter = 0
	
	// Detail in waves to handle.  Find the number of fine centering points
	for(Counter=0;Counter < CenterXYSize;Counter+=1)	
		If (CenterXY[Counter]!=0)
			CenterXYRealSize+=1
		EndIf									
	endfor	
	// Fine number of discrete steps												
	for(Counter=0;Counter < CenterXYSize;Counter+=1)	
		If (ZTargets[Counter]!=0)
			DiscreteSteps+=1
		EndIf									
	endfor												
	
	// Find the distance from the starting point to the center point 
	Variable DiffX = abs(CenterXY[CenterXYRealSize][0] - CirclesX[0])*GV("XLVDTSens")*1e9
	Variable DiffY = abs(CenterXY[CenterXYRealSize][1] - CirclesY[0])*GV("YLVDTSens")*1e9
	Variable DistanceFromStartToCenter =  sqrt((DiffX)^2+(DiffY)^2)
	
	// Find the standard deviation in the fine x,y centering
	Duplicate/O/R=[1,CenterXYRealSize][0] CenterXY, FineCenterX
	Duplicate/O/R=[1,CenterXYRealSize][1] CenterXY, FineCenterY
	WaveStats/Q FineCenterX
	Variable XStdDev = V_sdev*GV("XLVDTSens")*1e9
	WaveStats/Q FineCenterY
	Variable YStdDev = V_sdev*GV("YLVDTSens")*1e9
	
	//Find the peak force and extension of the centered force pull
	SetDataFolder root:CFP:SavedData
	WaveStats/W/Q ForceWave
	Variable ForceMin = V_min
	Variable ForceMinLocation = V_minRowLoc
	Variable NormalizedForceMin = abs(ForceMin - SmoothForceWave[(ForceMinLocation+2000)])*1e12
	Variable ForceMinExtension = abs(ExtensionWave[ForceMinLocation] - ExtensionWave[V_maxRowLoc])*1e9
	
	WaveStats/Q ForceWave
	Variable ForceGraphOffsetP = V_minRowLoc+2000
	Variable PeakForce = V_min 
	WaveStats/Q/R=[ForceGraphOffsetP,ForceGraphOffsetP+2000], SmoothForceWave
	Variable ForceGraphOffset = V_avg
	Variable ForceThreshold = ForceGraphOffset - 20*1e-12
	FindLevel/Q/P/R=[50,500] SmoothForceWave, ForceThreshold
	Variable ExtOffset = ExtensionWave[V_LevelX]
	Variable CriticalExtension = abs(ExtOffset - WaveMax(ExtensionWave)+10e-9)
	Variable TipConnectionHeight = 630 - CriticalExtension*1e9
	
	// End To End Starting Distance
	Variable EndToEndDistance = sqrt(TipConnectionHeight^2+DistanceFromStartToCenter^2)
	
	// Setup up all the details of the CFPStats Wave
	String CFPStatsName = "CFPStats" + IterationString
	Make/O/N=14 $CFPStatsName
	Make/O/T/N=14 CFPStatsUnits
	
	Wave CFPStats = $CFPStatsName
	CFPStatsUnits = {"None","nm","None","None","nm","nm","pN","nm","None","nm","nm","N","m"}
	
 	SetDimLabel 0,0, $"Iteration", CFPStats,CFPStatsUnits
 	SetDimLabel 0,1, $"DistanceFromStartToCenter", CFPStats,CFPStatsUnits
 	SetDimLabel 0,2, $"NumDiscreteSteps", CFPStats,CFPStatsUnits
 	SetDimLabel 0,3, $"FineCenteringIterations", CFPStats,CFPStatsUnits
 	SetDimLabel 0,4, $"XStandardDevFineCenter", CFPStats,CFPStatsUnits
 	SetDimLabel 0,5, $"YStandardDevFineCenter", CFPStats,CFPStatsUnits
  	SetDimLabel 0,6, $"BreakingForce", CFPStats,CFPStatsUnits
   	SetDimLabel 0,7, $"BreakingExtension", CFPStats,CFPStatsUnits
   	SetDimLabel 0,8, $"BreakingRowLoc", CFPStats,CFPStatsUnits
   	SetDimLabel 0,9, $"TipConnectionHeight", CFPStats,CFPStatsUnits
   	SetDimLabel 0,10, $"EndToEndDistance", CFPStats,CFPStatsUnits
   	SetDimLabel 0,11, $"ForceOffset", CFPStats,CFPStatsUnits
   	SetDimLabel 0,12, $"ExtensionOffset", CFPStats,CFPStatsUnits
   	
   	// Put in values for CFP Stats wave
   	CFPStats[%$"Iteration"] = Iteration
   	CFPStats[%$"DistanceFromStartToCenter"] = DistanceFromStartToCenter
   	CFPStats[%$"NumDiscreteSteps"] = DiscreteSteps
   	CFPStats[%$"FineCenteringIterations"] = CenterXYRealSize
   	CFPStats[%$"XStandardDevFineCenter"] = XStdDev
   	CFPStats[%$"YStandardDevFineCenter"] = YStdDev
   	CFPStats[%$"BreakingForce"] = NormalizedForceMin
   	CFPStats[%$"BreakingExtension"] = ForceMinExtension
   	CFPStats[%$"BreakingRowLoc"] = ForceMinLocation
   	CFPStats[%$"TipConnectionHeight"] = TipConnectionHeight
   	CFPStats[%$"EndToEndDistance"] = EndToEndDistance
   	CFPStats[%$"ForceOffset"] = ForceGraphOffset
   	CFPStats[%$"ExtensionOffset"] = ExtOffset   	

End

///////////////////////////////////////////////////////////////////////////////////////
// A few useful functions 
 Function ConstantForce(Setpoint_Volts)
 	Variable Setpoint_Volts
 	Variable Error
//	Sets up a feedback loop that controls z stage to give constant deflection volts.  
 	Error += ir_SetPISLoop(2,"Always,Never","Deflection",Setpoint_Volts,0, 2999.999, 0,"Output.Z",-10,150)
 End // Function ConstantForce

Function WithdrawalStage()
// Sets up a feedback loop that puts z sensor back as far as possible.  Also will disengage constant force.
	ir_SetPISLoop(2,"Always,Never","Output.Z",-0.65,0, 75104, 0,"Output.Z",-10,150)
End // Function WithdrawalStage

Function StopLoop(WhichLoop)
	Variable WhichLoop
	ir_StopPISLoop(WhichLoop)
End // StopLoop


//////////////////////////////////////////////////////////////////////////
// Stuff for the user interface

Function CFPTabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			Variable tab = tca.tab
	
			SetVariable SurfaceTrigger1,disable= (tab!=0)
			SetVariable MoleculeTrigger1,disable= (tab!=0)
			SetVariable ApproachVelocity1,disable= (tab!=0)
			SetVariable RetractVelocity1,disable= (tab!=0)
			SetVariable DwellTime1,disable= (tab!=0)
			SetVariable NoTriggerDistance1,disable= (tab!=0)

			SetVariable SurfaceTrigger2,disable= (tab!=1)
			SetVariable MoleculeTrigger2,disable= (tab!=1)
			SetVariable ApproachVelocity2,disable= (tab!=1)
			SetVariable RetractVelocity2,disable= (tab!=1)
			SetVariable DwellTime2,disable= (tab!=1)
			SetVariable NoTriggerDistance2,disable= (tab!=1)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function CFPButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Wave/T MasterLoopSettings=root:CFP:MasterLoopSettings
			MasterLoopSettings[%$"End Master Loop"] = "0"
			StartCFP()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function StopButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Wave/T MasterLoopSettings=root:CFP:MasterLoopSettings
			MasterLoopSettings[%$"End Master Loop"] = "1"
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Window CFP_Panel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1049,98,1312,498) as "Centered Force Pull"
	ModifyPanel cbRGB=(56576,56576,56576)
	SetDrawLayer UserBack
	Button CFPStartButton,pos={14,318},size={77,36},proc=CFPButtonProc,title="Start"
	Button CFPStartButton,fColor=(61440,61440,61440)
	SetVariable CenteringDistance,pos={13,269},size={171,16},title="Centering Distance (nm)"
	SetVariable CenteringDistance,value= root:CFP:CenteringSettings[%'Distance to move from center']
	SetVariable SurfaceTrigger1,pos={42,39},size={154,16},title="Surface Trigger (pN)"
	SetVariable SurfaceTrigger1,value= root:CFP:ForceRampSettings_InitialRamp[%'Surface Trigger']
	TabControl CFPTab,pos={4,6},size={239,211},proc=CFPTabProc
	TabControl CFPTab,labelBack=(56576,56576,56576),tabLabel(0)="Initial Force Ramp"
	TabControl CFPTab,tabLabel(1)="Centered Force Ramp",value= 0
	SetVariable MoleculeTrigger1,pos={41,67},size={154,16},title="Molecule Trigger (pN)"
	SetVariable MoleculeTrigger1,value= root:CFP:ForceRampSettings_InitialRamp[%'Molecule Trigger']
	SetVariable ApproachVelocity1,pos={41,96},size={157,16},title="Approach Velocity (micron/s)"
	SetVariable ApproachVelocity1,value= root:CFP:ForceRampSettings_InitialRamp[%'Approach Velocity']
	SetVariable RetractVelocity1,pos={43,126},size={154,16},title="Retract Velocity (micron/s)"
	SetVariable RetractVelocity1,value= root:CFP:ForceRampSettings_InitialRamp[%'Retract Velocity']
	SetVariable DwellTime1,pos={43,157},size={154,16},title="Surface Dwell Time (s)"
	SetVariable DwellTime1,value= root:CFP:ForceRampSettings_InitialRamp[%'Surface Dwell Time']
	SetVariable NoTriggerDistance1,pos={46,186},size={154,16},title="No Trigger Distance (nm)"
	SetVariable NoTriggerDistance1,value= root:CFP:ForceRampSettings_InitialRamp[%'No Trigger Distance']
	SetVariable SurfaceTrigger2,pos={38,38},size={154,16},disable=1,title="Surface Trigger (pN)"
	SetVariable SurfaceTrigger2,value= root:CFP:ForceRampSettings_Centered[%'Surface Trigger']
	SetVariable MoleculeTrigger2,pos={37,66},size={154,16},disable=1,title="Molecule Trigger (pN)"
	SetVariable MoleculeTrigger2,value= root:CFP:ForceRampSettings_Centered[%'Molecule Trigger']
	SetVariable ApproachVelocity2,pos={37,95},size={157,16},disable=1,title="Approach Velocity (micron/s)"
	SetVariable ApproachVelocity2,value= root:CFP:ForceRampSettings_Centered[%'Approach Velocity']
	SetVariable RetractVelocity2,pos={39,125},size={154,16},disable=1,title="Retract Velocity (micron/s)"
	SetVariable RetractVelocity2,value= root:CFP:ForceRampSettings_Centered[%'Retract Velocity']
	SetVariable DwellTime2,pos={39,155},size={154,16},disable=1,title="Surface Dwell Time (s)"
	SetVariable DwellTime2,value= root:CFP:ForceRampSettings_Centered[%'Surface Dwell Time']
	SetVariable NoTriggerDistance2,pos={42,184},size={154,16},disable=1,title="No Trigger Distance (nm)"
	SetVariable NoTriggerDistance2,value= root:CFP:ForceRampSettings_Centered[%'No Trigger Distance']
	SetVariable MaxIterations,pos={13,246},size={171,16},title="Fine Centering Max Iterations"
	SetVariable MaxIterations,value= root:CFP:CenteringSettings[%'Max Iterations']
	Button CFPStopButton,pos={110,318},size={77,36},proc=StopButtonProc,title="Stop"
	Button CFPStopButton,fColor=(61440,61440,61440)
	SetVariable CriticalFitDifference,pos={13,293},size={171,16},title="Critical Fit Difference (nm)"
	SetVariable CriticalFitDifference,value= root:CFP:CenteringSettings[%'Critical Fit Difference']
	PopupMenu InfoDisplay,pos={13,364},size={149,22},proc=InfoDisplayPopMenuProc,title="Display Info"
	PopupMenu InfoDisplay,mode=10,popvalue="ForceVsExt",value= #"\"ForceRampTable;CenteringTable;MasterLoopTable;XYVoltage;XYSensor;XYSensor_nm;XCenteringFit;YCenteringFit;DefVsZSensor;ForceVsExt;XYZD_Targets;ZSensorGraph\""
	SetVariable SetCircleRadius,pos={14,224},size={167,16},title="Circle Radius (nm)"
	SetVariable SetCircleRadius,value= root:CFP:CenteringSettings[%CircleRadius]
EndMacro

Function InfoDisplayPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			DisplayCFPInfo(popStr)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
