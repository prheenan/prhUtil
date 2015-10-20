#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6

#include ":CenteringReport"
#include ":ForceRamp"
#include ":ConstantForceMotion"
#include ":SearchForMolecules"

Menu "Centered Force Pulls"
	"Initialize CFP", InitializeCFP()
	"Start CFP", StartCFP()
	"Stop CFP",StopCFP()
	"Search Grid Controls", Execute "Search_Panel()"

End


// Initialize the centered force pull program
Function InitializeCFP([ShowUserInterface])
	Variable ShowUserInterface
	If(ParamIsDefault(ShowUserInterface))
		ShowUserInterface=1
	EndIf

	//Build Datafolder for CFP and set that as current datafolder
	NewDataFolder/O root:CFP
	SetDataFolder root:CFP
		
	// Make Waves for Force Ramp Settings in real units
	ModForceRamp#MakeForceRampWave(OutputWaveName="FirstRamp_Settings")
	ModForceRamp#MakeForceRampWave(OutputWaveName="CenteredRamp_Settings")
	ModForceRamp#MakeFRWaveNamesCallback(OutputWaveName="FirstRamp_WaveNames")
	ModForceRamp#MakeFRWaveNamesCallback(OutputWaveName="CenteredRamp_WaveNames")
	Wave/T FirstRamp_WaveNames
	Wave/T CenteredRamp_WaveNames
	FirstRamp_WaveNames[%Deflection]="DefV_Ramp1"
	FirstRamp_WaveNames[%ZSensor]="ZSensor_Ramp1"
	FirstRamp_WaveNames[%$"CTFC Settings"]="TriggerInfo_Ramp1"
	FirstRamp_WaveNames[%Callback]="FirstRampCallback()"
	CenteredRamp_WaveNames[%Deflection]="DefV_Ramp2"
	CenteredRamp_WaveNames[%ZSensor]="ZSensor_Ramp2"
	CenteredRamp_WaveNames[%$"CTFC Settings"]="TriggerInfo_Ramp2"
	CenteredRamp_WaveNames[%Callback]="CenteredForcePullCallback()"
	Wave FirstRamp_Settings
	FirstRamp_Settings[%'Engage Second Trigger']=1
	
	Wave CenteredRamp_Settings
	CenteredRamp_Settings[%SamplingRate]=50000
	CenteredRamp_Settings[%'Engage Second Trigger']=0
	
	// Make waves for circle 
	MakeCFCSettingsWave(OutputWaveName="Circle_Settings")
	MakeCFCWaveNamesCallback(OutputWaveName="Circle_WaveNames")
	Wave/T Circle_WaveNames
	Circle_WaveNames[%XSensor]="XSensorCircle"
	Circle_WaveNames[%YSensor]="YSensorCircle"
	Circle_WaveNames[%ZSensor]="ZSensorCircle"
	Circle_WaveNames[%DefV]="DefVCircle"
	Circle_WaveNames[%Callback]="CircleCallback()"

	// Make waves for moving to a point
	MakeMoveToPointCFSettingsWave(OutputWaveName="MoveToPoint_Settings")
	
	// make waves for sampling deflection and zsensor at discrete points.
	MakeSampleZWavesCallback(OutputWaveName="SampleAtPoint_WaveNames")
	MakeSampleZSettingsWave(OutputWaveName="SampleAtPoint_Settings")
	Wave/T SampleAtPoint_WaveNames
	SampleAtPoint_WaveNames[%XSensor]="XSensorPoint"
	SampleAtPoint_WaveNames[%YSensor]="YSensorPoint"
	SampleAtPoint_WaveNames[%ZSensor]="ZSensorPoint"
	SampleAtPoint_WaveNames[%DefV]="DefVPoint"
	SampleAtPoint_WaveNames[%Callback]="SampleZCallback()"

	// Make waves for fine centering cross
	MakeCFCrossSettingsWave(OutputWaveName="FineCentering_Settings")
	MakeCFCrossWaveNamesCallback(OutputWaveName="FineCentering_WaveNames")
	Wave/T FineCentering_WaveNames
	FineCentering_WaveNames[%XSensor]="XSensorFine"
	FineCentering_WaveNames[%YSensor]="YSensorFine"
	FineCentering_WaveNames[%ZSensor]="ZSensorFine"
	FineCentering_WaveNames[%DefV]="DefVFine"
	FineCentering_WaveNames[%Callback]="FineCenteringCallback()"

	// Centering Settings
	Make/N=13/O CFPSettings
 	SetDimLabel 0,0, $"FineCenteringIteration", CFPSettings
 	SetDimLabel 0,1, $"Max Iterations", CFPSettings
 	SetDimLabel 0,2, $"Distance to move from center", CFPSettings
 	SetDimLabel 0,3, $"Center Found?", CFPSettings
  	SetDimLabel 0,4, $"Center X", CFPSettings
   	SetDimLabel 0,5, $"Center Y", CFPSettings
    	SetDimLabel 0,6, $"Critical Fit Difference", CFPSettings
      	SetDimLabel 0,7, $"StepIteration", CFPSettings
      	SetDimLabel 0,8, $"TargetForce", CFPSettings
      	SetDimLabel 0,9,$"CircleRadius", CFPSettings
      	SetDimLabel 0,10,$"DeflectionOffset", CFPSettings
      	SetDimLabel 0,11,$"MasterIteration", CFPSettings
      	SetDimLabel 0,12,$"UseSearchGrid", CFPSettings
      	
      	CFPSettings={0,5,150e-9,0,0,0,10e-9,0,30e-12,150e-9,0,0,1}
      	
	Make/T/O/N=4 CenteringSettings
    	SetDimLabel 0,0, $"State", CenteringSettings
    	SetDimLabel 0,1, $"Molecule", CenteringSettings
    	SetDimLabel 0,2, $"EndProgram", CenteringSettings
    	SetDimLabel 0,3, $"SaveName",CenteringSettings
    	CenteringSettings={"FirstRamp","650 nm DNA","0","CenterSave"}

	Make/N=256/O DeflectionOffsetData

   	DoWindow CFP_Panel
	Variable UserInterfaceVisible=V_flag
	If(ShowUserInterface&&!UserInterfaceVisible)
		Execute "CFP_Panel()"
	EndIf
	
	ResetCurrentDataWaves()
	InitSearch()
	
End // InitializeCTFC

//  This function controls the sequence of events for the centering protocol
//  It also checks to make sure the molecule didn't detach.  If it detached, then start a new iteration.  
Function CFP_MainLoop()
	
	
	Wave CFPSettings = root:CFP:CFPSettings
	Wave/T Centering = root:CFP:CenteringSettings
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

	Variable XCurrentPosition_Volts = td_rv("Cypher.LVDT.X")
	Variable YCurrentPosition_Volts = td_rv("Cypher.LVDT.Y")
	Variable ZCurrentPosition_Volts= td_rv("Cypher.LVDT.Z")
	
	// Check to see if zsensor has railed.  Probably means the molecule has disconnected.	
	
	If ((ZCurrentPosition_Volts < 0.28)&&!(StringMatch(Centering[%State],"FirstRamp")))
		Centering[%State] = "Railed"
	EndIf
	
	If (str2num(Centering[%$"EndProgram"])== 1)
		Centering[%State] = "EndProgram"
	EndIf

		
	Strswitch (Centering[%State])
		case "FirstRamp":
			Wave FirstRamp_Settings=root:CFP:FirstRamp_Settings
			Wave/T FirstRamp_WaveNames=root:CFP:FirstRamp_WaveNames
			FirstRamp_Settings[%DefVOffset]=CFPSettings[%DeflectionOffset]
			DoForceRamp(FirstRamp_Settings,FirstRamp_WaveNames)
			
		break
		case "Circle":
			Wave Circle_Settings=root:CFP:Circle_Settings
			Wave/T Circle_WaveNames=root:CFP:Circle_WaveNames
			Circle_Settings[%Force_N]=CFPSettings[%TargetForce]
			Circle_Settings[%DefVOffset]=CFPSettings[%DeflectionOffset]
			Circle_Settings[%Radius_m]=CFPSettings[%CircleRadius]
			Circle_Settings[%CenterX_V]=XCurrentPosition_Volts
			Circle_Settings[%CenterY_V]=YCurrentPosition_Volts
			
			Circles_X[0]= XCurrentPosition_Volts
			Circles_Y[0]= YCurrentPosition_Volts
			Circles_Z[0]= ZCurrentPosition_Volts

			CFCircle(Circle_Settings,Circle_WaveNames)
		break
		case "DiscreteMoves":
			Wave MoveToPoint_Settings=root:CFP:MoveToPoint_Settings
			
			Variable Iteration = CFPSettings[%StepIteration]
			MoveToPoint_Settings[%XPosition_V]=XTargets[Iteration]
			MoveToPoint_Settings[%YPosition_V]=YTargets[Iteration]
			MoveToPoint_Settings[%Force_N]=CFPSettings[%TargetForce]
			MoveToPoint_Settings[%DefVOffset]=CFPSettings[%DeflectionOffset]

			// If more than one discrete point recorded, then test them to see if we have passed the point of maximum extension
			// If not, then move to the next point
			If (Iteration == 1)
				MoveToPointCF(MoveToPoint_Settings,Callback="StepsCallback()")			
			ElseIf ((Iteration>=2)&&(Iteration<=13))
				Variable Increasing1=ZTargets[Iteration-1]>ZTargets[Iteration-2]
				Variable Increasing2=ZTargets[Iteration-2]>ZTargets[Iteration-3]
				Variable MovingAwayFromCenter = Increasing1&&Increasing2
				
				If(MovingAwayFromCenter)
					Centering[%State] = "FineTuneCenter"
	
					MoveToPoint_Settings[%XPosition_V]=XTargets[Iteration-3]
					MoveToPoint_Settings[%YPosition_V]=YTargets[Iteration-3]
					
					Wave FineCentering_Settings=root:CFP:FineCentering_Settings
					FineCentering_Settings[%CenterX_V]=XTargets[Iteration-3]
					FineCentering_Settings[%CenterY_V]=YTargets[Iteration-3]
						
					MoveToPointCF(MoveToPoint_Settings,Callback="CFP_MainLoop()")
				Else
					MoveToPointCF(MoveToPoint_Settings,Callback="StepsCallback()")
				EndIf
			
			EndIf // iteration >1
			If (Iteration>13)
				StopZFeedbackLoop()			
				FinishCFP()
			Endif						
		break
		case "FineTuneCenter":
			Wave FineCentering_Settings=root:CFP:FineCentering_Settings
			Wave/T FineCentering_WaveNames=root:CFP:FineCentering_WaveNames
			FineCentering_Settings[%Force_N]=CFPSettings[%TargetForce]
			FineCentering_Settings[%DefVOffset]=CFPSettings[%DeflectionOffset]

			If(CFPSettings[%FineCenteringIteration]<=CFPSettings[%$"Max Iterations"])
				CFCross(FineCentering_Settings,FineCentering_WaveNames)
			Else
				StopZFeedbackLoop()			
				FinishCFP()
			EndIf
		break
		case "Railed":
			StopZFeedbackLoop()			
			FinishCFP()
		break
		case "EndProgram":
			print "Centering Program Ended"
			StopZFeedbackLoop()			

		break
		default:	
			print "Error, in default state.  Check your program for problems."
	EndSwitch
	
End


Function ResetCurrentDataWaves()
	SetDataFolder root:CFP
	
	// Make Waves for Force Triggering
	Make/N=(1024)/O ZSensor_Ramp1,DefV_Ramp1,ZSensor_Ramp2,DefV_Ramp2

	// Make waves for centering
	Make/O/N=2 Circles_X,Circles_Y,Circles_Z
	Make/O/N=13 XTargets,YTargets,ZTargets,DefTargets
	Make/O/N=10 FineCenterX,FineCenterY,FineCenterZ
	Make/N=(1024)/O XSensorCircle,YSensorCircle,ZSensorCircle
	FineCenterX=0
	FineCenterY=0
	FineCenterZ=0
	// Fine Centering motion and fit waves
	Make/O/N=(1024) XSensorFine,YSensorFine,ZSensorFine,DefVFine,XFit, YFit,XPos,YPos,ZSensor_X,ZSensor_Y
	
	// Kill Saved Fits to fine centering
	String XFitWaveNames= WaveList("XFit_*", ";" ,"" )
	String YFitWaveNames= WaveList("YFit_*", ";" ,"" )
	String XPosWaveNames= WaveList("XPos_*", ";" ,"" )
	String YPosWaveNames= WaveList("YPos_*", ";" ,"" )
	String ZSensorXWaveNames= WaveList("ZSensorX_*", ";" ,"" )
	String ZSensorYWaveNames= WaveList("ZSensorY_*", ";" ,"" )
	
	Variable NumFitWavestoKill=ItemsInList(XFitWaveNames, ";")
	Variable Counter=0
	For(Counter=0;Counter<NumFitWavesToKill;Counter+=1)
		String XFitWaveName=StringFromList(Counter, XFitWaveNames)
		String YFitWaveName=StringFromList(Counter, YFitWaveNames)
		String XPosWaveName=StringFromList(Counter, XPosWaveNames)
		String YPosWaveName=StringFromList(Counter, YPosWaveNames)
		String ZSensorXWaveName=StringFromList(Counter, ZSensorXWaveNames)
		String ZSensorYWaveName=StringFromList(Counter, ZSensorYWaveNames)
		KillWaves $XFitWaveName,$YFitWaveName,$XPosWaveName,$YPosWaveName,$ZSensorXWaveName,$ZSensorYWaveName
	EndFor
	
	// Reset selected centering settings
	Wave CFPSettings=root:CFP:CFPSettings
	CFPSettings[%$"Center Found?"]=0
	CFPSettings[%$"FineCenteringIteration"]=0
	CFPSettings[%$"StepIteration"]=0
	CFPSettings[%$"Center X"]=0
	CFPSettings[%$"Center Y"]=0
	
End // ResetCurrentDataWaves

Function DisplayCFPInfo(TargetDisplay,[TargetDataFolder])
	String TargetDisplay,TargetDataFolder
	String NamePrefix
	
	If(ParamIsDefault(TargetDataFolder))
		TargetDataFolder="root:CFP"
	EndIf
	
	If(StringMatch(TargetDataFolder,"root:CFP"))
		NamePrefix="Current"
	Else
		NamePrefix=StringFromList(2,TargetDataFolder,":")
	EndIf
	
	SetDataFolder $TargetDataFolder
	String DisplayName=NamePrefix+TargetDisplay
	DoWindow/F $DisplayName

	
	If (V_flag==0)		
		strswitch(TargetDisplay)
			case "FirstRampTable":
				Edit/W=(7.5,92.75,508.5,288.5)/N=$DisplayName  FirstRamp_Settings.ld
			break
			case "CenteringTable": 
				Edit/W=(5.25,323,336,535.25)/N=$DisplayName CenteringSettings.ld
			break	
			case "CFPSettings": 
				Edit/W=(5.25,323,336,535.25)/N=$DisplayName CFPSettings.ld
			break	
			case "CircleSettings":
				Edit/W=(3.75,564.5,338.25,810.5)/N=$DisplayName Circle_Settings.ld
			break	
			case "FineCenteringSettings":
				Edit/W=(3.75,564.5,338.25,810.5)/N=$DisplayName FineCentering_Settings.ld
			break	
			case "SampleAtPointSettings":
				Edit/W=(3.75,564.5,338.25,810.5)/N=$DisplayName SampleAtPoint_Settings.ld
			break	
			case "MoveToPointSettings":
				Edit/W=(3.75,564.5,338.25,810.5)/N=$DisplayName MoveToPoint_Settings.ld
			break	
			case "CenteredRampSettings":
				Edit/W=(3.75,564.5,338.25,810.5)/N=$DisplayName CenteredRamp_Settings.ld
			break	
			
			case "Circles":
				Display/W=(1452.75,377.75,1847.25,586.25)/K=1/N=$DisplayName ZSensorCircle 
				Label left "Z Sensor (V)"
				Label bottom "Time (s)"
				String YDisplayName=DisplayName+"XY"
				Display/W=(1452.75,377.75,1847.25,586.25)/K=1/N=$YDisplayName YSensorCircle vs XSensorCircle 
				Label left "Y Sensor (V)"
				Label bottom "X Sensor (V)"
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
			case "XYZD_Targets":
				Edit/W=(435,90.5,851.25,332.75)/N=$DisplayName XTargets,YTargets,ZTargets,DefTargets
			break		
			case "FineCenter":
				Display/W=(1449,620,1843.5,828.5)/K=1/N=$DisplayName FineCenterY vs FineCenterX
				Label left "X Position"
				Label bottom "Y Position"
			break		

		endswitch  // TargetDisplay
	EndIf		
	SetDataFolder root:CFP

End // DisplayInfo


Function StartCFP()
	Wave/T CenteringSettings = root:CFP:CenteringSettings
	CenteringSettings[%State]="FirstRamp"
	CenteringSettings[%$"EndProgram"]="0"
	
	Variable DeflectionOffset=td_rv("Deflection")
	Wave CFPSettings=root:CFP:CFPSettings
	CFPSettings[%DeflectionOffset]=DeflectionOffset
	CFPSettings[%$"Center Found?"]=0
	DetermineOffset()
End //StartCFP()

Function StopCFP()
	Wave/T CenteringSettings=root:CFP:CenteringSettings
	CenteringSettings[%$"EndProgram"]="1"
End

Function DetermineOffset()
	Wave DeflectionOffsetData=root:CFP:DeflectionOffsetData
	Variable Error=0
	Error+= td_xSetInWave(0, "0,0", "Deflection", DeflectionOffsetData, "DetermineOffsetCallback()",100)

	// Execute motion
	Error +=td_WriteString("Event.0", "once")

	if (Error>0)
		print "Error in DetermineOffset: ", Error
	endif
End

Function DetermineOffsetCallback()
	Wave DeflectionOffsetData=root:CFP:DeflectionOffsetData
	WaveStats/Q DeflectionOffsetData
	Variable DeflectionOffset=V_avg
	
	Wave CFPSettings=root:CFP:CFPSettings
	CFPSettings[%DeflectionOffset]=DeflectionOffset
	ResetCurrentDataWaves()
	CFP_MainLoop()
End

// This callback exectues when the CTFC is done
Function FirstRampCallback() 
	
	//print "FirstRampCallback()"
	Wave/T TriggerInfo=root:CFP:TriggerInfo_Ramp1
	Wave/T CenteringSettings=root:CFP:CenteringSettings
	Wave CFPSettings=root:CFP:CFPSettings
	Wave DefVolts=root:CFP:DefV_Ramp1
	Wave ZSensorVolts = root:CFP:ZSensor_Ramp1
	variable Error = 0
	variable MoleculeAttached =1 // Default assumption is molecule will attach
	
	// Set current state to First Ramp callback
	CenteringSettings[%State]="FirstRampCallback"
	
	// Save initial force ramp with suffix _IFR (stands for initial force ramp)
	String SaveName=CenteringSettings[%SaveName]+"_IFR"
	SaveAsAsylumForceRamp(SaveName,CFPSettings[%MasterIteration],DefVolts,ZSensorVolts)
	
	// Check to see if molecule is attached.  If Triggertime2 is greater than 400,000, then molecule did NOT attach
	Error+=td_ReadGroup("ARC.CTFC",TriggerInfo)
	if (str2num(TriggerInfo[%TriggerTime2])> 400000)
		MoleculeAttached=0
	endif
	
	If (Error>0)
		Print "Error in FirstRampCallback"
	EndIf

	// Execute Centering Routine if molecule is attached
	if (MoleculeAttached==1)  // Temporarily making this execute when a molecule isn't attached.  Just for testing.  Change this back to ==1 to fix.
		CenteringSettings[%State]="Circle"
		CFP_MainLoop()
	endif
	
	// If no molecule attached, then finish this
	If (MoleculeAttached==0)
		FinishCFP()
	endif

End //FirstRampCallback

Function CircleCallback() 
	
	Wave/T CenteringSettings=root:CFP:CenteringSettings
	Wave CFPSettings=root:CFP:CFPSettings
	Wave XSensorCircle=root:CFP:XSensorCircle
	Wave YSensorCircle = root:CFP:YSensorCircle
	Wave ZSensorCircle = root:CFP:ZSensorCircle
	Wave Circles_X=root:CFP:Circles_X
	Wave Circles_Y=root:CFP:Circles_Y
	Wave Circles_Z=root:CFP:Circles_Z
	Wave XTargets = root:CFP:XTargets
	Wave YTargets = root:CFP:YTargets
	Wave ZTargets = root:CFP:ZTargets

	
	CenteringSettings[%State] = "CircleCallback"
	
	WaveStats/Q ZSensorCircle
 	Variable MinDirectionRowLoc = V_minRowLoc

	Circles_X[1]= XSensorCircle[MinDirectionRowLoc]
	Circles_Y[1]= YSensorCircle[MinDirectionRowLoc]
	Circles_Z[1]= ZSensorCircle[MinDirectionRowLoc]
	
	//Variable DistanceIncrement=CFPSettings[%CircleRadius]
	//Variable Angle = atan((Circles_Y[1]-Circles_Y[0])/(Circles_X[1]-Circles_X[0]))
	Variable YIncrement = Circles_Y[1]-Circles_Y[0]
	Variable XIncrement = Circles_X[1]-Circles_X[0]
	
	//Variable YIncrement = DistanceIncrement*sin(Angle)
	//Variable XIncrement = DistanceIncrement*cos(Angle)
	//Variable YIncrement = DistanceIncrement*sin(Angle)

	XTargets = XIncrement*(p-1)+Circles_X[0]
	YTargets = YIncrement*(p-1)+Circles_Y[0]
	ZTargets=0
	
	CFPSettings[%StepIteration] = 1
	CenteringSettings[%State] = "DiscreteMoves"
	CFP_MainLoop()
	
End // CircleCallback

Function StepsCallback() 
	
	Wave/T CenteringSettings=root:CFP:CenteringSettings
	Wave CFPSettings=root:CFP:CFPSettings
	Wave XTargets = root:CFP:XTargets
	Wave YTargets = root:CFP:YTargets
	Wave ZTargets = root:CFP:ZTargets
	Wave SampleAtPoint_Settings = root:CFP:SampleAtPoint_Settings
	Wave/T SampleAtPoint_WaveNames = root:CFP:SampleAtPoint_WaveNames

	Variable CurrentIteration=CFPSettings[%StepIteration]

	CenteringSettings[%State] = "SampleZSensor"
	SampleAtPoint_Settings[%Force_N]=CFPSettings[%Targetforce]
	SampleAtPoint_Settings[%DefVOffset]=CFPSettings[%DeflectionOffset]
	
	// Sample X,Y,Z, and Deflection at this point, while maintaining constant force
	SampleZSensorCF(SampleAtPoint_Settings,SampleAtPoint_WaveNames)
	
End // StepsCallback

Function SampleZCallback()
	Wave/T CenteringSettings=root:CFP:CenteringSettings
	Wave CFPSettings=root:CFP:CFPSettings
	Wave XTargets = root:CFP:XTargets
	Wave YTargets = root:CFP:YTargets
	Wave ZTargets = root:CFP:ZTargets
	Wave SampleAtPoint_Settings = root:CFP:SampleAtPoint_Settings
	Wave/T SampleAtPoint_WaveNames = root:CFP:SampleAtPoint_WaveNames
	Wave ZSensor=root:CFP:ZSensorPoint
	Variable CurrentIteration=CFPSettings[%StepIteration]
	
	CenteringSettings[%State] = "SampleZCallback"
	// Average Z Sensor wave for current z sensor position
	WaveStats/Q ZSensor
	ZTargets[CurrentIteration]=V_avg
	
	// Move to next iteration and go back to main program loop
	CFPSettings[%StepIteration] = CurrentIteration+1
	CenteringSettings[%State] = "DiscreteMoves"
	CFP_MainLoop()

End

Function FineCenteringCallback()

	Wave/T CenteringSettings=root:CFP:CenteringSettings
	Wave CFPSettings=root:CFP:CFPSettings
	Variable FineCenterIteration = CFPSettings[%FineCenteringIteration]
	Wave FineCenterX=root:CFP:FineCenterX
	Wave FineCenterY=root:CFP:FineCenterY
	Wave FineCenterZ=root:CFP:FineCenterZ
	Wave XSensorFine=root:CFP:XSensorFine
	Wave YSensorFine=root:CFP:YSensorFine
	Wave ZSensorFine=root:CFP:ZSensorFine
	Wave DefVFine=root:CFP:DefVFine
	Variable MaxIterations = CFPSettings[%$"Max Iterations"]
	Variable CriticalFitDifference = CFPSettings[%$"Critical Fit Difference"]
		
	// Split the raw waves into data for centering calculation
	Variable NumPoints=numpnts(XSensorFine)
	Variable Increment=Floor(NumPoints/8)

	Duplicate/O/R=[Increment+1,3*Increment] XSensorFine, XPos
	Duplicate/O/R=[Increment+1,3*Increment] ZSensorFine, ZSensor_X 
	Duplicate/O/R=[3*Increment+1,4*Increment] YSensorFine, YPos
	Duplicate/O/R=[3*Increment+1,4*Increment] ZSensorFine, ZSensor_Y	
	
	// Save this iteration data
	String CurrentIterationStr=num2str(FineCenterIteration)
	String XPosName =  "root:CFP:XPos_"+ CurrentIterationStr
	String YPosName =  "root:CFP:YPos_"+ CurrentIterationStr
	String ZSensor_XName =  "root:CFP:ZSensorX_"+ CurrentIterationStr
	String ZSensor_YName =  "root:CFP:ZSensorY_"+ CurrentIterationStr
		
	Duplicate/O XPos, $XPosName
	Duplicate/O YPos, $YPosName
	Duplicate/O ZSensor_X, $ZSensor_XName
	Duplicate/O ZSensor_Y, $ZSensor_YName	
		
	// Calculate Center Positions
	Variable CenterX = CalculateCenterPosition(XPos,ZSensor_X)
	Duplicate/O Quadratic_Fit, XFit
	String XFitName =  "root:CFP:XFit_"+ CurrentIterationStr
	Duplicate/O Quadratic_Fit, $XFitName
	
	Variable CenterY = CalculateCenterPosition(YPos,ZSensor_Y)
	Duplicate/O Quadratic_Fit, YFit
	String YFitName =  "root:CFP:YFit_"+ CurrentIterationStr
	Duplicate/O Quadratic_Fit, $YFitName
	
	FineCenterX[FineCenterIteration]=CenterX
	FineCenterY[FineCenterIteration]=CenterY
	
	Wave MoveToPoint_Settings=root:CFP:MoveToPoint_Settings
	
	MoveToPoint_Settings[%XPosition_V]=CenterX
	MoveToPoint_Settings[%YPosition_V]=CenterY
	MoveToPoint_Settings[%Force_N]=CFPSettings[%TargetForce]
	MoveToPoint_Settings[%DefVOffset]=CFPSettings[%DeflectionOffset]
	
	MoveToPointCF(MoveToPoint_Settings,Callback="MoveToNewCenterCallback()")			

End // Centering Callback

Function MoveToNewCenterCallback()

	Wave/T CenteringSettings=root:CFP:CenteringSettings
	Wave CFPSettings=root:CFP:CFPSettings
	Variable FineCenterIteration = CFPSettings[%FineCenteringIteration]
	Wave FineCenterX=root:CFP:FineCenterX
	Wave FineCenterY=root:CFP:FineCenterY
	Wave FineCenterZ=root:CFP:FineCenterZ
	Wave XSensorFine=root:CFP:XSensorFine
	Wave YSensorFine=root:CFP:YSensorFine
	Wave ZSensorFine=root:CFP:ZSensorFine
	Wave DefVFine=root:CFP:DefVFine
	Variable MaxIterations = CFPSettings[%$"Max Iterations"]
	Variable CriticalFitDifference = CFPSettings[%$"Critical Fit Difference"]
	
	Variable XCriticalFitDifference = Abs(CriticalFitDifference/GV("XLVDTSens")) // X Critical difference in LVDT volts
	Variable YCriticalFitDifference = Abs(CriticalFitDifference/GV("YLVDTSens")) // Y Critical difference in LVDT volts
	
	// Determine if we found the center.  End if center is found, or if we reach the max number of iterations.
	Variable FoundCenter=0
	If (FineCenterIteration==1)  // If this is the first iteration, run a second iteration to be sure we found the center
		FoundCenter=0
	ElseIf ((FineCenterIteration<MaxIterations)&&(FineCenterIteration>1)) // If we are in between 2 iterations and the max iterations, see if we found a good center
		variable XDiff = Abs((FineCenterX[FineCenterIteration-1]-FineCenterX[FineCenterIteration]))
		variable YDiff =  Abs((FineCenterY[FineCenterIteration-1]-FineCenterY[FineCenterIteration]))
		
		
		If ((XDiff<XCriticalFitDifference)&&(YDiff<YCriticalFitDifference) ) 
			FoundCenter=1
			CFPSettings[%$"Center Found?"] = 1
			CFPSettings[%$"Center X"] = FineCenterX[FineCenterIteration] 
			CFPSettings[%$"Center Y"] = FineCenterX[FineCenterIteration]
			
		Else	// If not, try another centering
			FoundCenter=0
		Endif
		
	Else   // If we have reached the maximum number of iterations, go to center and ramp
		FoundCenter=0
	EndIf
	
 	// Now, if center found then execute a ramp to get centered force data
	If (FoundCenter)
		Wave CenteredRamp_Settings=root:CFP:CenteredRamp_Settings
		Wave/T CenteredRamp_WaveNames=root:CFP:CenteredRamp_WaveNames
		CenteringSettings[%State] = "CenteredForcePull"

		StopZFeedbackLoop()
		
		// Now do the centered force ramp
		DoForceRamp(CenteredRamp_Settings,CenteredRamp_WaveNames)
		
	endif  // FoundCenter
	
	If (!FoundCenter)  // If we haven't found the center, try again to find the center
		CFPSettings[%FineCenteringIteration]+=1
		CFP_MainLoop()
	Endif  // test == 1
	
End

Function StopZFeedbackLoop()
	// Here we stop the z feedback loop and reset it.  Without this code, our next force ramp will just be stuck.  
	ir_StopPISLoop(-2)
	Struct ARFeedbackStruct FB
	ARGetFeedbackParms(FB,"outputZ")
	FB.StartEvent = "2"
	FB.StopEvent = "3"
	String ErrorStr
	ErrorStr += ir_writePIDSloop(FB)

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
	Wave/T CenteringSettings=root:CFP:CenteringSettings
	Wave CFPSettings=root:CFP:CFPSettings
	Wave DefVolts=root:CFP:DefV_Ramp2
	Wave ZSensorVolts = root:CFP:ZSensor_Ramp2

	CenteringSettings[%State] = "CenteredForcePullCallback"
	
	
	// Save initial force ramp with suffix _IFR (stands for initial force ramp)
	String SaveName=CenteringSettings[%SaveName]+"_CFR"
	SaveAsAsylumForceRamp(SaveName,CFPSettings[%MasterIteration],DefVolts,ZSensorVolts)

	SaveCurrentData()
	
	// Set back to regular folder
	SetDataFolder root:CFP
	FinishCFP()
		
End //CenteredForcePullCallback

Function FinishCFP()
	// This is the code that will officially finish a centered force pull.  I'll add functionality to move around the surface here. 
	// I should also add code to reset all the appropriate wave values for the next centered force pull.
	// For now, it will just stop the program
	Wave/T CenteringSettings=root:CFP:CenteringSettings
	Wave CFPSettings=root:CFP:CFPSettings

	CFPSettings[%MasterIteration]+=1
	// Max index for saving in the asylum format is 9999.  After that, we'll just reset to 0
	If(CFPSettings[%MasterIteration]>9999)
		CFPSettings[%MasterIteration]=0
	EndIf
	
	// If using the search grid, then use it.  If we found the center, then we found a molecule.
	// After moving to next spot, execute StartCFP()
	CenteringSettings[%State] = "FinishCFP"

	Variable EndProgram=StringMatch(CenteringSettings[%$"EndProgram"],"1")
	If((CFPSettings[%UseSearchGrid])&&(!EndProgram))
		SearchForMolecule(FoundMolecule=CFPSettings[%$"Center Found?"],Callback="StartCFP()")
	EndIf
	
End


Function SaveCurrentData()
	Wave/T CenteringSettings=root:CFP:CenteringSettings
	Wave CFPSettings=root:CFP:CFPSettings
	
	String CurrentIterationStr
	sprintf CurrentIterationStr, "%04d", CFPSettings[%MasterIteration]
	
	
	String DataFolderName="root:CFP:"+CenteringSettings[%SaveName]+CurrentIterationStr
	NewDataFolder/O $DataFolderName
	SetDataFolder root:CFP
	
	String WaveNames = WaveList("*", ";" ,"" )
	
	Variable NumWavesToCopy=ItemsInList(WaveNames, ";")
	Variable Counter=0
	For(Counter=0;Counter<NumWavesToCopy;Counter+=1)
		String CurrentWaveName=StringFromList(Counter, WaveNames)
		String NewWaveName=DataFolderName+":"+CurrentWaveName
		Duplicate/O $CurrentWaveName,$NewWaveName
	EndFor
								
End //SaveCurrentData

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
			SetVariable ForceDistanceIFR,disable= (tab!=0)
			SetVariable SamplingRateIFR,disable= (tab!=0)

			SetVariable SurfaceTrigger2,disable= (tab!=1)
			SetVariable MoleculeTrigger2,disable= (tab!=1)
			SetVariable ApproachVelocity2,disable= (tab!=1)
			SetVariable RetractVelocity2,disable= (tab!=1)
			SetVariable DwellTime2,disable= (tab!=1)
			SetVariable NoTriggerDistance2,disable= (tab!=1)
			SetVariable ForceDistanceCFR,disable= (tab!=1)
			SetVariable SamplingRateCFR,disable= (tab!=1)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function CFPButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	String ButtonName=ba.CtrlName

	switch( ba.eventCode )
		case 2: // mouse up
			strswitch(ButtonName)
				case "CFPStartButton":
					StartCFP()
				break
				case "CFPStopButton":
					StopCFP()
				break 
			EndSwitch
		break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function CFPInfoDisplay(pa) : PopupMenuControl
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

Window CFP_Panel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(808,117,1072,734) as "Centered Force Pull"
	ModifyPanel cbRGB=(56576,56576,56576)
	SetDrawLayer UserBack
	DrawLine 8,381,222,381
	DrawLine 8,521,222,521
	Button CFPStartButton,pos={11,534},size={77,36},proc=CFPButtonProc,title="Start"
	Button CFPStartButton,fColor=(61440,61440,61440)
	SetVariable CenteringDistance,pos={8,312},size={171,16},title="Centering Distance"
	SetVariable CenteringDistance,format="%.1W1Pm"
	SetVariable CenteringDistance,limits={-inf,inf,5e-09},value= root:CFP:CFPSettings[%'Distance to move from center']
	SetVariable SurfaceTrigger1,pos={10,40},size={171,16},title="Surface Trigger"
	SetVariable SurfaceTrigger1,format="%.1W1PN"
	SetVariable SurfaceTrigger1,limits={-inf,inf,1e-11},value= root:CFP:FirstRamp_Settings[%'Surface Trigger']
	TabControl CFPTab,pos={4,6},size={250,249},proc=CFPTabProc
	TabControl CFPTab,labelBack=(56576,56576,56576),tabLabel(0)="Initial Force Ramp"
	TabControl CFPTab,tabLabel(1)="Centered Force Ramp",value= 0
	SetVariable MoleculeTrigger1,pos={10,67},size={154,16},title="Molecule Trigger"
	SetVariable MoleculeTrigger1,format="%.1W1PN"
	SetVariable MoleculeTrigger1,limits={-inf,inf,5e-12},value= root:CFP:FirstRamp_Settings[%'Molecule Trigger']
	SetVariable ApproachVelocity1,pos={10,95},size={176,16},title="Approach Velocity"
	SetVariable ApproachVelocity1,format="%.1W1Pm/s"
	SetVariable ApproachVelocity1,limits={-inf,inf,1e-07},value= root:CFP:FirstRamp_Settings[%'Approach Velocity']
	SetVariable RetractVelocity1,pos={10,122},size={186,16},title="Retract Velocity"
	SetVariable RetractVelocity1,format="%.1W1Pm/s"
	SetVariable RetractVelocity1,limits={-inf,inf,1e-07},value= root:CFP:FirstRamp_Settings[%'Retract Velocity']
	SetVariable DwellTime1,pos={10,150},size={154,16},title="Surface Dwell Time"
	SetVariable DwellTime1,format="%.1W1Ps"
	SetVariable DwellTime1,limits={-inf,inf,0.5},value= root:CFP:FirstRamp_Settings[%'Surface Dwell Time']
	SetVariable NoTriggerDistance1,pos={10,177},size={179,16},title="No Trigger Distance"
	SetVariable NoTriggerDistance1,format="%.1W1Pm"
	SetVariable NoTriggerDistance1,limits={-inf,inf,1e-08},value= root:CFP:FirstRamp_Settings[%'No Trigger Distance']
	SetVariable SurfaceTrigger2,pos={90,40},size={154,16},disable=1,title="Surface Trigger"
	SetVariable SurfaceTrigger2,format="\\JR%.1W1PN"
	SetVariable SurfaceTrigger2,limits={-inf,inf,1e-11},value= root:CFP:CenteredRamp_Settings[%'Surface Trigger'],styledText= 1
	SetVariable MoleculeTrigger2,pos={90,67},size={154,16},disable=1,title="Molecule Trigger"
	SetVariable MoleculeTrigger2,format="\\JR%.1W1PN"
	SetVariable MoleculeTrigger2,limits={-inf,inf,5e-12},value= root:CFP:CenteredRamp_Settings[%'Molecule Trigger'],styledText= 1
	SetVariable ApproachVelocity2,pos={87,95},size={157,16},disable=1,title="Approach Velocity"
	SetVariable ApproachVelocity2,format="\\JR%.1W1Pm/s"
	SetVariable ApproachVelocity2,limits={-inf,inf,1e-07},value= root:CFP:CenteredRamp_Settings[%'Approach Velocity'],styledText= 1
	SetVariable RetractVelocity2,pos={90,123},size={154,16},disable=1,title="Retract Velocity"
	SetVariable RetractVelocity2,format="\\JR%.1W1Pm/s"
	SetVariable RetractVelocity2,limits={-inf,inf,1e-07},value= root:CFP:CenteredRamp_Settings[%'Retract Velocity'],styledText= 1
	SetVariable DwellTime2,pos={90,151},size={154,16},disable=1,title="Surface Dwell Time"
	SetVariable DwellTime2,format="\\JR%.1W1Ps"
	SetVariable DwellTime2,limits={-inf,inf,0.5},value= root:CFP:CenteredRamp_Settings[%'Surface Dwell Time'],styledText= 1
	SetVariable NoTriggerDistance2,pos={67,179},size={177,16},disable=1,title="No Trigger Distance"
	SetVariable NoTriggerDistance2,format="\\JR%.1W1Pm"
	SetVariable NoTriggerDistance2,limits={-inf,inf,1e-08},value= root:CFP:CenteredRamp_Settings[%'No Trigger Distance'],styledText= 1
	SetVariable MaxIterations,pos={8,289},size={171,16},title="Fine Centering Max Iterations"
	SetVariable MaxIterations,value= root:CFP:CFPSettings[%'Max Iterations']
	Button CFPStopButton,pos={103,534},size={77,36},proc=CFPButtonProc,title="Stop"
	Button CFPStopButton,fColor=(61440,61440,61440)
	SetVariable CriticalFitDifference,pos={8,336},size={171,16},title="Critical Fit Difference"
	SetVariable CriticalFitDifference,format="%.1W1Pm"
	SetVariable CriticalFitDifference,limits={-inf,inf,1e-09},value= root:CFP:CFPSettings[%'Critical Fit Difference']
	PopupMenu InfoDisplay,pos={11,584},size={171,22},proc=CFPInfoDisplay,title="Display Info"
	PopupMenu InfoDisplay,mode=2,popvalue="CenteringTable",value= #"\"FirstRampTable;CenteringTable;CircleSettings;FineCenteringSettings;XYVoltage;XYSensor;XYSensor_nm;XCenteringFit;YCenteringFit;DefVsZSensor;ForceVsExt;XYZD_Targets;ZSensorGraph\""
	SetVariable SetCircleRadius,pos={8,267},size={167,16},title="Circle Radius"
	SetVariable SetCircleRadius,format="%.1W1Pm"
	SetVariable SetCircleRadius,limits={-inf,inf,5e-09},value= root:CFP:CFPSettings[%CircleRadius]
	SetVariable CurrentState,pos={8,418},size={217,24},title="Current State"
	SetVariable CurrentState,fSize=16,fStyle=1,valueColor=(65280,0,0)
	SetVariable CurrentState,value= root:CFP:CenteringSettings[%State]
	SetVariable TargetForce,pos={8,361},size={174,16},title="Target Force"
	SetVariable TargetForce,format="%.1W1PN"
	SetVariable TargetForce,limits={-inf,inf,5e-12},value= root:CFP:CFPSettings[%TargetForce]
	SetVariable Molecule,pos={8,395},size={196,16},title="Molecule"
	SetVariable Molecule,value= root:CFP:CenteringSettings[%Molecule]
	SetVariable ForceDistanceIFR,pos={10,205},size={179,16},title="Force Distance"
	SetVariable ForceDistanceIFR,format="%.1W1Pm"
	SetVariable ForceDistanceIFR,limits={-inf,inf,1e-07},value= root:CFP:FirstRamp_Settings[%'Extension Distance']
	SetVariable ForceDistanceCFR,pos={65,207},size={179,16},disable=1,title="Force Distance"
	SetVariable ForceDistanceCFR,format="\\JR%.1W1Pm"
	SetVariable ForceDistanceCFR,limits={-inf,inf,1e-07},value= root:CFP:CenteredRamp_Settings[%'Extension Distance'],styledText= 1
	SetVariable SaveName,pos={8,452},size={218,16},proc=CheckSaveName,title="Save Name"
	SetVariable SaveName,value= root:CFP:CenteringSettings[%SaveName]
	SetVariable Iteration,pos={8,473},size={221,16},title="Iteration",format="%04d"
	SetVariable Iteration,limits={0,9999,1},value= root:CFP:CFPSettings[%MasterIteration]
	SetVariable SamplingRateIFR,pos={10,233},size={179,16},title="Sample Rate"
	SetVariable SamplingRateIFR,format="%.1W1PHz"
	SetVariable SamplingRateIFR,limits={500,50000,1000},value= root:CFP:FirstRamp_Settings[%'Sampling Rate']
	SetVariable SamplingRateCFR,pos={65,234},size={179,16},disable=1,title="Sample Rate"
	SetVariable SamplingRateCFR,format="\\JR%.1W1PHz"
	SetVariable SamplingRateCFR,limits={500,50000,1000},value= root:CFP:CenteredRamp_Settings[%'Sampling Rate'],styledText= 1
	CheckBox UseSearchGrid,pos={10,498},size={96,14},proc=CFPCheckProc,title="Use Search Grid"
	CheckBox UseSearchGrid,value= 1
EndMacro


Function CheckSaveName(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
				Variable NameLength=strlen(sval)
				If(NameLength>13)
					Wave/T CenteringSettings= root:CFP:CenteringSettings
					String NewName=sval[0,12]
					CenteringSettings[%SaveName]=NewName
					
				EndIf
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function CFPCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	String CheckBoxName=cba.CtrlName
	Wave CFPSettings=root:CFP:CFPSettings


	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			strswitch(CheckBoxName)
				case "UseSearchGrid":
					CFPSettings[%UseSearchGrid]=Checked
				break
			EndSwitch
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
