// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchWoodsideDisplay
#include "..\Util\IoUtil"
#include "..\Util\ErrorUtil"
#include "..\Util\PlotUtil"
#include "..\View\ViewUtil"

Constant DEF_SMOOTH_NPOINTS = 33
Constant DEF_SMOOTH_ORDER = 2
Constant FILTERED_LINE_WIDTH = 2
Constant DEF_LIMIT_PLOTS  = 4


// Function to plot 'mWave', given that it is the 'mFileIdx' number to plot out of 'nPlots',
// where nPointsSmooth and Degreesmooth are passed to the igor function 'smooth' (see below)
Static Function PlotSingle(mWave,mFileIdx,nPlots,[nPointsSmooth,degreeSmooth])
	String mWave
	Variable mFileIdx,nPointsSmooth,nPlots,degreeSmooth
	nPointsSmooth = ParamIsDefault(nPointsSmooth) ? DEF_SMOOTH_NPOINTS : nPointsSmooth
	degreeSmooth = ParamIsDefault(degreeSmooth) ? DEF_SMOOTH_ORDER : degreeSmooth
	// POST: all parameters are set
	// MAke a copy... because reasons.
	Wave dontUse = $(mWave)
	DUplicate /O dontUse allRuptures
	// Get the constants known for plotting all the unfolds/ruptures
	Variable N_UNFOLDS = 5
	Variable IDX_RUPTURE = 4 // last index is the rupture force
	Variable DELTA_TIME = 1./(5e6) // 200ns; 5Mhz
	Variable TO_MICROSECS = 1e6 // from seconds
	// Plot each rupture
	Variable i
	// Extra height and width between graphs
	Variable fudgeX = 0.02 
	Variable fudgeY = 0.09
	// Determine the height from what we are plotting
	// Height must be one less (ie: +2 instead of +1), since we get the starting location from the heights.
	Variable mHeight = 1/(nPlots*(1+fudgeX)+1)
	Variable mWidth = 1/(N_UNFOLDS*(1+fudgeY)+1)
	// Other parameters
	Variable mFont = 16
	// Get the times (assumed constant for all)
	Variable nRows = DimSize(allRuptures,0) // 1: columns
	Make /O/N=(nRows) mTime
	mTime[] = DELTA_TIME * p * TO_MICROSECS
	Variable nAvg = nRows/10
	Make /O mRed = { 0,0,0,50000,50000}
	Make /O mblue = {0,50000,50000,50000,0}
	Make /O mGreen = {50000,0,50000,0,50000,0}
	for (i=0; i<N_UNFOLDS; I+=1)
		// Get the rupture force we care about 
		// Need to add the rupture number, since God hates Igor programers.
		String mName = (mWave + num2str(i))
		Make /O/D/N=(nRows) $mName
		Wave mForce = $mName
		// Convert to pN, and offset to the last nAvg points (ie: local zero, only
		// care about change in force at rupture)
		mForce[] = allRuptures[p][i] * 1e12
		Variable Offset = Mean(mForce,nRows-nAvg,Inf)
		mForce -= Offset
		// Make a smoothed copy of the wave
		// POST: shouldn't modify mForce
		String mSmooth = mName + "SG"
		Duplicate /O mForce $mSmooth
		Wave filteredForce = $mSmooth
		// Use the smooth function to do te filtering
		// V=592 of igor manual
		// /S: polynomial order (ie: degree) of sanitsky golay
		Smooth /S=(degreeSmooth) (nPointsSmooth), filteredForce
		/// Get a new display
		String mDisp = ModViewUtil#DisplayRelToScreen(i*(mWidth+fudgeX),mFileIdx*(mHeight+fudgeY),mWidth,mHeight)
		// Plot the filtered force as colored, the normal as grey
		Variable greyIntensity = 45000
		AppendToGraph /W=$(mDisp) /C=(greyIntensity,greyIntensity,greyIntensity) mForce vs mTime
		AppendToGraph /W=$(mDisp) /C=(mRed[i],mGreen[i],mBlue[i]) filteredForce vs mTime	
		// Modify the filtered force to be better
		ModifyGraph /W=$(mDisp) lSize($mSmooth)=(FILTERED_LINE_WIDTH)
		String mu = ModPlotUtil#mu()
		ModPlotUtil#XLabel("Time (" + mu + "s)",graphname=mDisp,fontsize=mFont)
		ModPlotUtil#YLabel("Force (pN)",graphname=mDIsp,fontsize=mFont)
		String mTitle
		sprintf mTitle,"%s, %d", mWave,(i+1)
		ModPlotUtil#Title(mTitle)
		ModPlotUtil#PlotBeautify()
	EndFor
End Function

Static Function Main([interactive,limitGraphs])
	Variable interactive, limitGraphs
	interactive = ParamIsDefault(Interactive) ? ModDefine#False(): interactive
	limitGraphs = ParamIsDefault(limitGraphs) ? DEF_LIMIT_PLOTS : limitGraphs
	String mFolder
	if (interactive) 
		// Get the folder where the data lies
		if (!ModIoUtil#GetFolderInteractive(mFolder))
			ModErrorUtil#AlertUser("Couldn't find the folder you were looking for.")
			return ModDefine#False()
		EndIf
	else
		// Get the folder we usually use
		mFolder = "Macintosh HD:Users:patrickheenan:Documents:education:boulder_files:rotations_year_1:3_perkins:code:2015-7-27-nug2_ruptures:mData150Window:"
	EndIf
	// POST: folder is OK
	// Load all the files, if we need to
	String cwd = ModIoUtil#cwd()
	if (interactive || ModIoUtil#CountWaves(cwd) == 0)
		// then we need to load
		ModIoUtil#LoadIgorFilesInFolder(mFolder)
	EndIf
	// POST: files all loaded. display them all as individual ruptures
	Variable nWavesLoaded = ModIoUtil#CountWaves(cwd)
	Variable nWaveGraph = min(nWavesLoaded,limitGraphs)
	Variable i
	for (i=0; i<nWaveGraph; i+=1)
		PlotSingle(ModIoUtil#GetWaveAtIndex(cwd,i),i,nWaveGraph)
	EndFor
End Function
