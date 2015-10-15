// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = TesterDataConverter
#include ":::Util:IoUtil"
#include ":::Util:PlotUtil"
#include ":::Util:DataStructures"
#include ":::Util:CypherUtil"
#include ":::Util:IoUtilHDF5"

// converts thisWave with thisType into 'toType', compares to 'compare to'
Static Function /Wave CheckConversion(ThisWave,ThisType,ToType,CompareTo,IsX,DeflMeters,outWave)
	Wave ThisWave,CompareTo,DeflMeters,outWave
	Variable ThisType,ToType,IsX
	if (isX)
		ModCypherUtil#ConvertX(ThisWave,ThisType,outWave,ToType,DeflMeters)
	Else
		ModCypherUtil#ConvertY(ThisWave,ThisType,outWave,ToType)
	EndIf
	// POST: tmpTest has the conversion
	// Go ahead and compare it to 'CompareTo", using only the data
	// Note: we renormalize everything to the zero and one given by CompareTo,
	// Since equalWaves uses a sum of squares approach, and the errors are likely tiny tiny
	Duplicate /O outWave toCheckConverted
	Duplicate /O CompareTo toCheckBaseLine
	// Get the range of the baseline.
	Variable mMin = WaveMin(toCheckBaseLine)
	Variable mMax = WaveMax(toCheckBaseLine)
	// Normalize toCheckBaseline to between 0 and 1
	toCheckBaseline[] = (toCheckBaseLine[p]-mMin)/(mMax-mMin)
	// Use the same normalizations on toCheckConverted
	toCheckConverted[] = (toCheckConverted[p]-mMin)/(mMax-mMin)
	// Now that both waves are between 0 and 1, we can use reasonable tolerances (part in a billion, etc) for the Sum of squared errors
	if(!ModDataStruct#WavesAreEqual(toCheckBaseline,toCheckConverted,options=EQUALWAVES_DATAONLY,tolerance=1e-9))
		ModErrorUtil#DevelopmentError(description="Waves didn't match")
	EndIf
End Function

// Just a simple plot to display the real and test wave side by side
Static Function DebugPlot(TestWave,RealWave,mYaxisLabel)
	Wave TestWave, RealWave
	String mYaxisLabel
	ModPlotUtil#Figure(hide=0)
	ModPlotUtil#Plot(TestWave,marker="")
	ModPlotUtil#Plot(RealWave,marker="",color="r",linestyle="--",linewidth=0.2,alpha=0.3)
	ModPlotUTil#XLabel("TIme")
	MOdPlotUtil#YLabel(mYaxisLabel)
	ModPlotUtil#pLegend()
End Function

Static Function Main()
	ModPlotUtil#ClearAllGraphs()
	KillDataFolder root:
	// Get the location of the data files. This will need to be changed to wherever the files are located... 
	String mFolder= "Macintosh HD:Users:patrickheenan:utilities:igor:UnitTesters:DataConverter:Data:"
	String fileBase = "LoopDNA_160ng_uL0020"
	// Get the various waves we want
	String basePath = ModIoUtil#AppendedPath(mFolder,fileBase)
	Make /O/T extensions = {"Zsnsr","Sep","Defl","DeflV","Force"}
	Variable i=0
	Variable nExt = DimSize(extensions,0)
	for (i=0; i<nExt; i+=1)
		// which wave we are loading
		String mWave = extensions[i]
		String mFilePath = basePath + mWave
		// load the file into mWave
		ModIoUtilHDF5#Read2DWaveFromFile(mWave,mFilePath)
	EndFor
	// POST: all files loaded
	// Go ahead and start converting things, after we load them
	Wave Sep = $("Sep")
	Wave Zsnsr = $("Zsnsr")
	Wave Defl = $("Defl")
	Wave DeflV = $("DeflV")
	Wave Force = $("Force")
	// For every wave, if we convert it and then convert it back, it should stay the same
	// within some small tolerance. 
	// We will have 'test' version of each, which will be the converted versions
	Duplicate /O Sep testSep,testZsnsr,testDefl,testDeflV,testForce
	// NOte: 1/0 in following plots means is x / is y. Different because X needs DeflMeters...
	// Convert Sep to Zsnsr
	CheckConversion(Sep,MOD_X_TYPE_SEP,MOD_X_TYPE_Z_SENSOR,Zsnsr,1,Defl,testZsnsr)
	// Convert Zsnsr to Sep
	CheckConversion(Zsnsr,MOD_X_TYPE_Z_SENSOR,MOD_X_TYPE_SEP,Sep,1,Defl,testSep)
	// Convert Force to Defl
	CheckConversion(Force,MOD_Y_TYPE_FORCE_NEWTONS,MOD_Y_TYPE_DEFL_METERS,Defl,0,Defl,testDefl)
	// Check Force to DeflV
	CheckConversion(Force,MOD_Y_TYPE_FORCE_NEWTONS,MOD_Y_TYPE_DEFL_VOLTS,DeflV,0,Defl,testDeflV)
	// Convert Defl to Force 
	CheckConversion(Defl,MOD_Y_TYPE_DEFL_METERS,MOD_Y_TYPE_FORCE_NEWTONS,Force,0,Defl,testForce)
	// Check Defl to DeflV
	CheckConversion(Defl,MOD_Y_TYPE_DEFL_METERS,MOD_Y_TYPE_DEFL_VOLTS,DeflV,0,Defl,testDeflV)	
	// Check DeflV to Force
	CheckConversion(DeflV,MOD_Y_TYPE_DEFL_VOLTS,MOD_Y_TYPE_FORCE_NEWTONS,Force,0,Defl,testForce)	
	// Check DeflV to Defl
	CheckConversion(DeflV,MOD_Y_TYPE_DEFL_VOLTS,MOD_Y_TYPE_DEFL_METERS,Defl,0,Defl,testDefl)	
	// Plot the Zsnsr and Test ZSnsr
	DebugPlot(TestZsnsr,Zsnsr,"Zsnsr")
	// Plot Sep 
	DebugPlot(TestSep,Sep,"Sep")
	// Defl
	DebugPlot(testDefl,Defl,"Defl")
	/// Force 
	DebugPlot(testForce,Force,"Force")
	// DeflV 
	DebugPlot(testDeflV,DeflV,"DeflV")
End Function