#pragma rtGlobals=3		
#pragma version=1.0


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
	String CFPStatsUnitsName = "CFPStatsUnits" + IterationString

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
	Wave CFPStatsUnits = $CFPStatsUnitsName
	
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

	Wave CFPIndexes = CFPIndexes
	Variable NumCFP = DimSize(CFPIndexes,0)
	Variable Counter = 0
	
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
	Wave CFPStatsUnits = CFPStatsUnits
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
	Wave CFPIndexes = CFPIndexes

	SetDataFolder root:CFP:SavedData
	Variable NumCFP = DimSize(CFPIndexes,0)
	Variable Counter = 0
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