#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function ConvertAllCFP()
	SetDataFolder root:CFP:SavedData
	Wave CFPIndexes = CFPIndexes
	Variable NumCFP = DimSize(CFPIndexes,0)
	Variable Counter = 0	


	for(Counter=0;Counter <NumCFP;Counter+=1)	
		String ForceWaveName = "DefV_Ramp2_"+num2str(CFPIndexes[Counter])
		String ExtensionWaveName = "ZSensor_Ramp2_"+num2str(CFPIndexes[Counter])
		
		Wave ForceWave = $ForceWaveName
		Wave ExtensionWave = $ExtensionWaveName
		ConvertCFPToAsylumDataFormat(ForceWave,ExtensionWave)
		
	EndFor
ENd




Function ConvertCFPToAsylumDataFormat(DefVolts,ZSensorVolts)
	
	
	wave DefVolts
	Wave ZSensorVolts
	Wave/T TriggerInfo
	Wave/t RepeatInfo
	Wave/t RampInfo
	
	
	Wave/T CenteredRamp = root:CFP:ForceRampSettings_Centered
	//LoadCTFCparms(CenteredRamp)
	Wave/T RampSettings=CenteredRamp
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
	NoTriggerTime = 0
	
	// He we set up the retracting ramp.  If we are trying to detect a molecule, set ramp to $Deflection
	// If we are just trying to get a full force pull, then use output.Dummy.  This disables the second trigger.
	If (str2num(RampSettings[%'Engage Second Trigger'])==1)
		RetractTriggerChannel="Deflection"
	Else
		RetractTriggerChannel="output.Dummy"
	EndIf
	
	WaveStats/Q DefVolts
	Variable MaxForceLoc=V_minrowloc
	Variable EndTime=V_minloc+0.1
	WaveStats/Q/R=[0,MaxForceLoc] DefVolts
	Variable Trigger1Time=V_maxloc
	Variable Trigger1Volts=V_max

	
	//  Setting up all the CTFC ramp info here. 
	RampChannel = "Output.Z"
	TriggerInfo[%TriggerTime1]=num2str(Trigger1Time)
	TriggerInfo[%TriggerTime2]=num2str(EndTime)
	TriggerInfo[%TriggerPoint1]=num2str(0)

	TriggerInfo[%RampChannel] = RampChannel
	TriggerInfo[%RampOffset1] = "160"  //Z Piezo volts
	TriggerInfo[%RampSlope1] = num2str(ApproachSpeed)  //Z Piezo Volts/s

	TriggerInfo[%RampOffset2] = "-50"
	TriggerInfo[%RampSlope2] = num2str(RetractSpeed) 
	
	TriggerInfo[%TriggerChannel1] = "Deflection"
	TriggerInfo[%TriggerValue1] = num2str(SurfaceTrigger) //Deflection Volts
	TriggerInfo[%TriggerCompare1] = ">="
	
	TriggerInfo[%TriggerChannel2] = RetractTriggerChannel
	TriggerInfo[%TriggerValue2] = num2str(MoleculeTrigger) 
	TriggerInfo[%TriggerCompare2] = "<="
	
	TriggerInfo[%TriggerHoldoff2] = num2str(NoTriggerTime)
	TriggerInfo[%DwellTime1] = "0"
	TriggerInfo[%DwellTime2] = "0"
	
	TriggerInfo[%EventDwell] = "3"
	TriggerInfo[%EventRamp] = "5"
	TriggerInfo[%EventEnable] = "2"
	TriggerInfo[%CallBack] = RampSettings[%'CTFC Callback']
	if (FindDimLabel(TriggerInfo,0,"TriggerType1") >= 0)
		TriggerInfo[%TriggerType1] = "Relative Start"
		TriggerInfo[%TriggerType2] = "Relative Start"
	endif

	
	DE_SaveFC(DefVolts,ZSensorVolts,TriggerInfo)
	
	
End








//DE_SaveFC() Taskes the DefVolts and ZsensorVolts waves, along with the parameters from TriggerInfo, RampInfo and RepeatInfo.
//This assumes that TriggerInfo already exists (it should), but does doublecheck that it's up-to-date by reloading the
//triggering parameters from the CTFC. this is built to be called when there's data you Have, and wish to save it out. As it is currently
//written it will BOTH generate a series of waves into the saved folder with iterated names, as well as save some of these
//to the Asylum file system. The former can be ignored in general, but were kept from trouble shooting. 
function DE_SaveFC(DefVolts,ZSensorVolts,TriggerInfo,[AdditionalNote])
	wave DefVolts
	Wave ZSensorVolts
	Wave/T TriggerInfo
	//Wave/t RampInfo
	string AdditionalNote
	
	wavetransform/o zapNaNs DefVolts
	wavetransform/o zapNaNs ZSensorVolts
	
	duplicate/o ZSensorVolts Z_raw_save
	Fastop Z_raw_save=(GV("ZLVDTSens"))*ZSensorVolts
	SetScale d -10, 10, "m", Z_raw_save
	duplicate/o Z_raw_save Z_snsr_save
	duplicate/o DefVolts Def_save
	fastop Def_save=(GV("Invols"))*DefVolts
	SetScale d -10, 10, "m", Def_save
	
	variable ApproachVelocity=str2num(TriggerInfo[%RampSlope1])
	string TriggerChannel=TriggerInfo[%TriggerChannel1]
	variable TriggerSet1=str2num(TriggerInfo[%TriggerValue1])  
	variable RetractVelocity=str2num(TriggerInfo[%RampSlope2])
	string TriggerChannel2=TriggerInfo[%TriggerChannel2]
	variable TriggerSet2=str2num(TriggerInfo[%TriggerValue2])
	variable NoTrigSet=str2num(TriggerInfo[%TriggerHoldoff2])         //Fix
	string Callback=TriggerInfo[%CallBack]
	variable TriggerSetVolt1=str2num(TriggerInfo[%TriggerValue1])	 //Fix
	variable TriggerSetVolt2=str2num(TriggerInfo[%TriggerValue2])	  //Fix
	variable TriggerValue1=str2num(TriggerInfo[%TriggerPoint1])
	variable TriggerValue2=str2num(TriggerInfo[%TriggerPoint2])
	variable TriggerTime1=str2num(TriggerInfo[%TriggerTime1])
	variable TriggerTime2=str2num(TriggerInfo[%TriggerTime2])
	variable DwellTime1=str2num(TriggerInfo[%DwellTime1])
	variable DwellTime2=str2num(TriggerInfo[%DwellTime2])
	variable NoTrigTime=str2num(TriggerInfo[%TriggerHoldoff2 ])      //Fix
	variable sampleRate=50000   //This has to be updated to adapt to inputs.
	
	variable TriggerDeflection=0
		
	strswitch(TriggerChannel)  //A switch to properly define the trigger levels (in voltage) based on the channel used for the second trigger.
			
		case "Deflection":

			TriggerDeflection=TriggerValue1/1e-12*GV("InvOLS")*GV("SpringConstant") //Deflection to reach
			break
		
		default:
		
	endswitch
	
	
	
	variable dwellPoints0 = round(DwellTime1*sampleRate)   
	variable dwellpoints1=round(DwellTime2*sampleRate) 
	variable ramp2pts= round((TriggerTime2)*sampleRate)-1
	
	String Indexes = "0," //Start the index and directions 
	String Directions = "Inf,"
	variable Index = round(TriggerTime1*sampleRate)-1      //Counts out to one point less than where it triggered
	Indexes += num2istr(Index)+","
	Directions += num2str(1)+","
	
	if (DwellPoints0)

		Index += DwellPoints0
		Indexes += num2istr(Index)+","
		Directions += "0,"
	
	endif
	
	Index += ramp2pts
	Indexes += num2istr(Index)+","
	Directions += num2str(-1)+","
	
	//This just lists the rest of the wave (from where the trigger fired through to the end of the wave) as a dwell. In general, this isn't a true dwell, but
	//rather the time it takes to interact with Igor, decide whether we found a molecule, and then do whatever else it is we want to do (for instance,
	//ramp toward the surface etc.
	
	Index=dimsize(Def_save,0)
	Indexes += num2istr(Index)+","
	Directions += "0,"
	
	string CNote="" //This is a correction note for the string that the ARSaveAsForce() function is going to write when we save this as a force.
	CNote = ReplaceStringbyKey("Indexes",CNote,Indexes,":","\r")
	CNote = ReplaceStringbyKey("Direction",CNote,Directions,":","\r")
	CNote = ReplaceStringbyKey("ApproachVelocity",CNote,num2str(ApproachVelocity),":","\r")
	CNote = ReplaceStringbyKey("RetractVelocity",CNote,num2str(RetractVelocity),":","\r")
	CNote = ReplaceStringbyKey("DwellTime",CNote,num2str(DwellTime1),":","\r")
	CNote = ReplaceStringbyKey("DwellTime2",CNote,num2str(DwellTime2),":","\r")
	CNote = ReplaceStringbyKey("NumPtsPerSec",CNote,num2str(sampleRate),":","\r")
	CNote = ReplaceStringbyKey("TriggerDeflection",CNote,num2str(TriggerDeflection),":","\r")
	CNote = ReplaceStringbyKey("TriggerChannel",CNote,TriggerChannel,":","\r")
	CNote = ReplaceStringbyKey("TriggerChannel2",CNote,TriggerChannel2,":","\r")
	CNote = ReplaceStringbyKey("TriggerTime1",CNote,num2str(TriggerTime1),":","\r")
	CNote = ReplaceStringbyKey("TriggerTime2",CNote,num2str(TriggerTime2),":","\r")
	CNote = ReplaceStringbyKey("TriggerSet1",CNote,num2str(TriggerSet1),":","\r")
	CNote = ReplaceStringbyKey("TriggerSet2",CNote,num2str(TriggerSet2),":","\r")
	CNote = ReplaceStringbyKey("TriggerValue1",CNote,num2str(TriggerValue1),":","\r")
	CNote = ReplaceStringbyKey("TriggerValue2",CNote,num2str(TriggerValue2),":","\r")

	if (!ParamIsDefault(AdditionalNote) && Strlen(AdditionalNote))

		variable nop
		nop = ItemsInList(AdditionalNote,"\r")
		String CustomItem
		Variable n,A

		for (A = 0;A < nop;A += 1)

			CustomItem = StringFromList(A,AdditionalNote,"\r")
			//print customitem
			n = strsearch(CustomItem,":",0,2)
	
			if (n < 0)
	
				Continue
	
			endif
	
			CNote = ReplaceStringByKey(CustomItem[0,n-1],CNote,Customitem[n+1,Strlen(CustomItem)-1],":","\r",0)
		
		endfor
	
	endif
		
	MakeZPositionFinal(Z_Snsr_save,ForceDist=TriggerSet2,indexes=indexes,DirInfo=Directions)	
	ARSaveAsForce(3,"SaveForce","Defl;ZSnsr",Z_raw_save,Def_save,Z_snsr_save,$"",$"",$"",$"",CustomNote=CNote)
	
	killwaves Z_raw_save, Z_snsr_save,Def_save
			
end // TestingSaving()
