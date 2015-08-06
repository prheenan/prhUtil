#pragma rtGlobals=3	
#include ".:GlobalObject"	
#include ".:IoUtil"
#include ".:PlotUtil"

Static Function FilterDisplay(rawWaveX,rawWaveY,boxSize,id,RGB)
	// Let Igor know this is a wave
	Wave rawWaveX,rawWaveY
	Struct RGBColor &RGB
	String id
	Variable boxSize
	String filterName = id + "Filtered"
	// duplicated the wave for filtering
	Duplicate /O rawWaveY, $filterName
	Wave filteredWave = $filterName
	// Smooth the data (XXX add in variable for smoothing and filter type)
	// Smoth [flags] size,wave
	// M: median filtering (threshold is zer, everything is median filtered)
	Smooth /M=0 boxSize, filteredWave
	// Display the raw wave and filtered wave
	AppendToGraph /C=(53000,53000,53000) rawWaveY  vs rawWaveX
	AppendToGraph /C=(RGB.red,RGB.green,RGB.blue) filteredWave vs rawWaveX
	ModPlotUtil#PlotBeautify()
	// give left (y axis) and bottom (x axis) labels
	Label left "\\Z24 Force [pN]"
	Label bottom "\\Z24 Tip-Surface Separation [" + num2char(0xB5)  +"m]"
	ModifyGraph fSize(left)=18
	ModifyGraph fSize(bottom)=18
	// get the axes in the right units (geez, lots to do)
	ModifyGraph prescaleExp(left)=12 // to pN
	ModifyGraph prescaleExp(bottom)=6 // to um 
End

Static Function Hackintosh(global)
	// essentially, this function is the brute force version of the MVC.
	// has the raw strings for the files we need
	// and the offsets, so that we can plot them all together.
	// the box size for median filtering
	Struct Global &global
	Variable filterBoxSize = 100;
	// were all the data lives
	String dataDir = "root:ForceCurves:SubFolders:X150603"
	String filePre = "LoopDNA_160ng_uL"
	// the strings to append to the force/separation files.
	String forceAppend = "Force"
	String sepAppend = "Sep"
	// ...why  doesn't IGOR have a line continuation character?...
	// list of files we are interested in.
	String fileList = "1138,1207,1209,1201,1203" 
	// Separators for lists an directories
	String sep = global.def.ListSep
	String dirSep = global.def.DirSep
	// Hand-picked points for the X and Y offset, and rupture X offset
	Make/O  zeroX=        {7.89e-9,-5.49e-9,-9.612e-10,6.58e-10,6.16e-10}
	Make/O zeroY =        {3.84e-13,-5.22e-13,-2.038e-12,1.61e-12,1.099e-12}
	Make /O RuptureX = {8.61e-7,9.552e-7,1.02e-6,8.04e-7,8.8e-7}
	// Lol this is terrible. can't believe people use this language. TODO!
	//Make /O RGB = {(clrs.Red),clrs.Gre,clrs.Blu,clrs.Yel,clrs.Pur}
	Variable nItems = ItemsInList(fileList,sep)
	// get all of the wave names in this experiment...
	String allWaves = ModIoUtil#GetWaveList(dataDir,sep,dirSep)
	Variable i
	Wave tmpX,tmpY,finalX,finalY
	String xName,yName,RegExpr,fullName,fileID,fileNum,fileStem,xWorking,yWorking
	Struct RGBColor color
	// create a new graph
	Display
	for (i=0; i<nItems; i+=1)
		fileNum = StringFromList(i,fileList,sep)
		fileID = filePre + fileNum
		// get the full path
		// XXX error if we can't find it? 
		 fullName = ModDataStruct#GetMatchString("*" + fileID + "*" ,allWaves,sep)
		// POST: fullName is one of the files (eg : foo0001Force) we care about 
		// cut off the suffix, put this in the 'fileStem' (eg foo0001, from above)
		fileStem = ModDataStruct#GetNamePrefix(fileID,fullName)
		// XXX safely name waves?
		// get the X and Y wave names
		xName =  (fileStem + sepAppend)
		yName = (fileStem + forceAppend) 
		// make new string names to hold the temporary waves
		// We will duplicate these, so we don't overwrite
		xWorking = (xName + "_tmp")
		yWorking = (yName + "_tmp")
		Duplicate /O $(xName), $xWorking
		Duplicate /O $(yName), $yWorking
		// Two step process of convering string name to wave and back again
		// XXX probably worth it to put this in a utility funciton somewhere
		Wave tmpX = $xWorking
		Wave tmpY = $yWorking
		// flip and X-Y offset
		tmpY *= -1
		tmpY -= zeroY[i]
		//tmpX -= zeroX[i]
		tmpX -= RuptureX[i]
		// put wave statistics in memory (/Q is for silence)
		WaveStats  /Q tmpY
		Variable nPoints = (V_endRow)-(V_minRowLoc)
		// zero out the approx (from 0 to the lowest)
		// Note: this assumes that the axes have been flipped properly.
		tmpX[0,V_minRowLoc] = Inf
		tmpY[0,V_minRowLoc] = Inf
		// Get the color for this graph (passes color by reference
		ModPlotUtil#DefColorIter(i,color,global.plot,MaxColors=nItems)
		FilterDisplay(tmpX,tmpY,50,fileNum,color)
	endfor
End

Function Main()
	try
		Struct Global global
		ModGlobal#InitGlobalObj(global)
		Hackintosh(global)
	catch
		Print("Error Thrown:")
		// Selector 3 chooses the entire call chain
		Print(GetRTStackInfo(3))
	EndTry
End 

Function MainStratch()

End Function
