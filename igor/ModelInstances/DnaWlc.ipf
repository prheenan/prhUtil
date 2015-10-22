// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#pragma ModuleName = ModDnaWlc
// DNA / WLC fit model below. XXX move to its own file
Static Constant MODEL_WLC_IDX_XYOFF = 0
Static Constant MODEL_WLC_IDX_END_WLC = 2
Static Constant MODEL_WLC_IDX_OSTR_START = 3
Static Constant MODEL_WLC_IDX_OSTR_END = 4

#include "::Util:ErrorUtil"
#include "::Model:ModelDefines"
#include "::Util:GlobalObject"
#include "::Util:StatUtil"
#include "::Util:IoUtil"
#include "::Model:Model"
#include "::MVC_Common:MvcDefines"


Function InitDNAModel(ToInit)
	Struct ModelObject & ToInit
	Struct Global GlobalDef
	ModGlobal#InitGlobalObj(GlobalDef)
	// Create the functions this object will use
	Struct ModelFunctions mFuncs
	ModModelDefines#InitModelFunctions(mFuncs,FitWLC)
	// Actually add the functions, parameters, and description to the model object
	ModModel#InitModelGen(ToInit,"DNAWLC",mFuncs,"DNA WLC And Overstretching Fitter","Sep","Force")
	// Load the predefined model stuff
	Struct ModelDefines modDef 
	modDef = GlobalDef.modV
	// Make the units and prefix for the parameters
	Struct Unit meter
	Struct Prefix nano
	nano = modDef.pref.nano
	meter = modDef.unit.meters
	// Add an XY offset for touching off
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Surface Touchoff Location","XyOffset")
	// Add a line parameter for the first WLC linear region
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Start of  WLC Linear Region1","WlcLinfit1I")
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"End of  WLC Linear Region1","WlcLinfit1F")
	// Add a line parameter for the overstretching region
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Overstretching Start","OStretchTx1")
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Overstretching End","OStretchTx2")
	// Add a line parameter for the second WLC linear region
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Start of  WLC Linear Region2","WlcLinfit2I")
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"End of  WLC Linear Region2","WlcLinfit2F")
	// Add parameters for the rupture location
	AddParameterFull(ToInit,modDef.type.XYOFF,nano,meter,"Rupture Force, final WLC","RuptureForce")
End Function

Function FitWLC(xRef,yRef,fitParameters,mStruct)
	String xRef,yRef
	Struct ParamObj & fitParameters
	Struct ViewModelStruct & mStruct
	Variable saveFitParameters
	// First parameter is X-Y offset. this point should be one (meta is first)
	// Next two parameters are WLC linear area. Fit from xOffIdx to the third (second WLC)
	// Make a new wave with just the right size for the y wave
	 Variable xOffIdx = fitParameters.params[MODEL_WLC_IDX_XYOFF].pointIndex
	Variable WLCFitIdx =  fitParameters.params[MODEL_WLC_IDX_END_WLC].pointIndex
	String tmpXName = xRef + "mod"
	String tmpYName = yRef + "mod"
	Duplicate /O /R=[xOffIdx,WLCFitIdx] $xRef $tmpXName
	Duplicate /O /R=[xOffIdx,WLCFitIdx] $yRef $tmpYName
	// Copy a local wave reference
	Wave/D xFit= $tmpXName
	Wave/D yFit= $tmpYName
	// do some basic processing
	// Flip about the y axis, so stretching is positive
	yFit *= -1
	// Get the x and y offsets
	Variable xOff = xFit[0]
	Variable yOff = yFit[0]
	//subtractt them
	xFit -= xOff
	yFit -= yOff
	// initial guess for the contour length is the entire curve
	Variable NPoints = DimSize(xFit,0)
	Make /D/O/N=1 coeffs = {xFit[NPoints-1]}
	// pp V-89 of the igor manual
	// W=2 supresses window
	// /N surpresses screen updates during fitting
	// Q is quiet
	FuncFit/Q/W=2 /N PRH_wlc,coeffs,yFit /X=xFit
	Variable L0Ret = coeffs[0]
	// Get the actual WLC fit
	String WLCFitName =  "wlcFit"
	Make /O/N=(nPoints) $WLCFitName
	WLC(L0Ret,xFit,$WLCFitName)
	// Create a figure. By default, won't display it.
	String mFig = ModPlotUtil#Figure()
	// Add the data
	AppendToGraph yFit vs xFit
	AppendtoGraph /C=(55000,55000,55000) $WLCFitName vs xFit
	ModPlotUtil#PlotBeautify()
	String mName = tmpYName + "'.png"
	String titleString
	sprintf titleString,"FEC, Circular DNA Experiment \r L0=%.0f[nm]",L0Ret*1e9
	// XXX fix title
	// XXX fix greek 'mu'
	ModPlotUtil#YLabel("Force [pN]")
	ModPlotUtil#XLabel("Tip-Surface Separation [" + ModPlotUtil#Mu()  +"m], offset to tip contact")
	// Add in the limits
	ModPlotUtil#Xlim(0,1.3e-6)
	ModPlotUtil#Ylim(-10e-12,100e-12)
	// get the axes in the right units (geez, lots to do)
	ModifyGraph prescaleExp(left)=12 // to pN
	ModifyGraph prescaleExp(bottom)=6 // to um 
	//ModPlotUtil#XLim(-10e-9,1.3e-6) // 2um
	//ModPlotUtil#YLim(-20e-12,200e-12) // 200pN
	// Get the name to save this figure as
	String mFile = ModIoUtil#GetFileName(yRef) + ".png"
	ModPlotUtil#SaveFig(saveName = mFile)
	// If the OstretchTx1 and OStretchTX2 are defined, 
	// then make a quick calculation of the force
	if ( fitParameters.params[MODEL_WLC_IDX_OSTR_START].beenSet && fitParameters.params[MODEL_WLC_IDX_OSTR_END].beenSet)
		// Get the mean and standard deviation
		Variable startIdx = fitParameters.params[MODEL_WLC_IDX_OSTR_START].pointIndex
		Variable endIdx = fitParameters.params[MODEL_WLC_IDX_OSTR_END].pointIndex
		Struct WaveStat mStats
		Wave tmpY = $yRef
		ModStatUtil#GetWaveStats(tmpY,mStats,startIdx=startIdx,endIdx=endIdx)
		// post: mStats has the standard deviation and mean
		// Subtract the y offset from the average (stdev unaffected)
		Variable actualAvg = -1*(mStats.average-yOff)
		printf "%.7g,%.7g,%.7g\r",L0Ret,actualAvg,mStats.stdev
	else
		printf "%.7g,,\r",L0Ret
	Endif
	// XXX pass in parameter object to fit to...
	// Kill all the temporary waves we made 
	KillWaves $tmpXName,$tmpYName
End Function	

Static Function WLC(L0,X,Y)
	Variable L0
	Wave X,Y
	Variable A = (4.1e-21)/(50.e-9)
	Y = A * ( 1/(4 * (1- X/L0)^2) -1/4 + X/L0)
	// replace nans and infs with zeros
	Y = (NumType(Y) == NUMTYPE_NORMAL) ? Y : 0
End Function	

 Function PRH_wlc(pw, yw, xw) : FitFunc
	WAVE pw, yw, xw
	Variable L0 = pw[0]
	// XXX pass this into a struct
	WLC(L0,xw,yw)
End Function
