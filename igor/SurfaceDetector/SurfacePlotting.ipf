// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModSurfacePlotting

#include "::Util:PlotUtil"
#include "::Util:Defines"
#include "::Util:UnitUtil"
#include ":SurfaceDetectorUtil"
#include ":SurfaceDetector"
#include "::SurfaceDetector:SurfacePreProc"
// For getting the invols and spring constant
#include "::Util:CypherUtil"
// Colors for approach and retract, consistent with Asylum Force panel 10/6/2015
// red: approach
// blue: retract
Static StrConstant COLOR_APPR = "r"
Static StrConstant COLOR_RETR = "b"

Static Function GetApprRetr(x,y,myDetection,xAppr,yAppr,xRetr,yRetr)
	Wave x,y,xAppr,yAppr,xRetr,yRetr
	Struct SurfaceDetector & myDetection
	Variable surfaceIdx = myDetection.surfaceIndex
	// Get the portions of the curve
	Duplicate /O/R=[0,surfaceIdx] x,xAppr
	Duplicate /O/R=[0,surfaceIdx] y,yAppr
	Duplicate /O/R=[surfaceIdx,Inf] x,xRetr
	Duplicate /O/R=[surfaceIdx,Inf] y,yRetr
End Function

// Plots x and y after converting to xUnits and yUnits, breaking up by approach/retract in myDetection. 
// location is the legend location, timeConstant is for smoothing, xAppr,yAppr,xRetr,yRetr are initialized waves for the approaches.
Static Function PlotApprRetract(x,y,xUnits,yUnits,myDetection,xAppr,yAppr,xRetr,yRetr,[location,timeConstant])
	Wave x,y,xAppr,yAppr,xRetr,yRetr
	String location
	String xUnits,yUnits
	Struct SurfaceDetector & myDetection
	Variable timeConstant
	if (ParamIsDefault(location))
		location = ANCHOR_BOTTOM_RIGHT
	EndIF
	// Smooth, based on the time constant
	Variable nFilterPoints
	if (!ParamIsDefault(timeConstant))
		 nFIlterPoints= ModSurfaceDetectorUtil#GetNPointsForSmoothing(x,timeConstant=timeConstant)
	else
		nFilterPoints = ModSurfaceDetectorUtil#GetNPointsForSmoothing(x)
	EndIf
	
	Duplicate /O x,xWorking
	Duplicate /O y,yWorking
	// Convert the x and Y 
	ModUnitUtil#ConvertToUnits(xWorking,xUnits)
	ModUnitUtil#ConvertToUnits(yWorking,yUnits)
	GetApprRetr(xWorking,yWorking,myDetection,xAppr,yAppr,xRetr,yRetr)
	// Plot the approach and retract curves
	ModPlotUtil#PlotWithFiltered(yAppr,X=xAppr,color=COLOR_APPR,nfilterPoints=nFilterPoints)
	ModPlotUtil#PlotWithFiltered(yRetr,X=xRetr,color=COLOR_RETR,nfilterPoints=nFilterPoints)
	Make /O/T mLegend = {"Approach","Approach (Filtered)","Retract","Retract (Filtered)"}
	// plot a legend using the labels in the bottom right.
	ModPlotUtil#pLegend(labels=mLegend,location=location)
	KillWaves /Z xWorking,yWorking
End Function

// Function to plot the pre-processing and surface detection steps. Returns its figure handle (for saving, probably)
Static Function /S PlotArtifactCorrectionCurve(Zsnsr,mDeflV,mDeflVCorrected,mDetector,preProc)
	Wave Zsnsr,mDeflV,mDeflVCorrected
	Struct SurfaceDetector & mDetector
	Struct SurfacePreProcInfo & preProc
	// basic stats
	Variable numPoints = DimSize(mDeflV,0)
	Variable del = deltax(mDeflV)
	Wave mCoeffs = preProc.mCoeffs
	// Plot everything
	Duplicate /O/R=[0, preProc.fitIdxAppr] mDeflV,mToFit
	if ( preProc.hasFitIdxRetr)
		Duplicate /O/R=[ preProc.fitIdxRetr,Inf] mDeflV,mToFitRetr
	else
		Duplicate /O/R=[Inf] mDeflV,mToFitRetr
	endIf
	// get the corrected approach 
	Duplicate /O/R=[0,preProc.fitIdxAppr] mDeflVCorrected,correctedAppr,fitCorrectedAppr
	// Get the corrected retract
	Duplicate /O/R=[preProc.fitIdxRetr,Inf] mDeflVCorrected,correctedRetr
	// get the polynomial fit of approach
	ModFitUtil#polyval(mCoeffs,fitCorrectedAppr)
	Duplicate /O fitCorrectedAppr,fitCorrectedRetr
	// Reverse the fit for the retract, offset it by its index
	// (/P prevents x scale from being reversed )
	Setscale /P x, (preProc.fitIdxRetr*del),del,fitCorrectedRetr
	Reverse /P fitCorrectedRetr
	Redimension /N=(DimSize(correctedRetr,0)-1) fitCorrectedRetr
	// re-zero the retracted, so it is aligned correctly
	if (preProc.hasFitIdxRetr)
		fitCorrectedRetr[] -=  mDeflV[preProc.fitIdxAppr] - mDeflV[preProc.fitIdxRetr]
	endIf
	// Get the fit for the retract
	Duplicate /O mDeflV,mTime
	mTime[] = DimOffset(mDeflV,0) + DimDelta(mDeflV,0) * p
	// Convert Zsnsr and DeflV to Sep and Force
	Duplicate /O Zsnsr,Sep,Force,ForceCorrected
	ModCypherUtil#ConvertZsnsrDeflVToSepForce(Zsnsr,mDeflV,Sep,Force)
	ModCypherUtil#ConvertY(mDeflVCorrected,MOD_Y_TYPE_DEFL_VOLTS,ForceCorrected,MOD_Y_TYPE_FORCE_NEWTONS)
	Variable surfaceIndex = mDetector.surfaceIndex
	Variable surfaceTime = pnt2x(mDeflV,surfaceIndex)
	// zero the separation and force
	// Look at the 'last' intersection to get the zero index
	Variable zeroIdx = ModStatUtil#FindIdxLevelCrossing(Sep,Sep[surfaceIndex],numPoints/2,Inf,ModDefine#False())
	Variable xOff =  Sep[zeroIdx]
	Variable yOff  = Force[zeroIdx]
	Variable yOffCorr =  ForceCorrected[zeroIdx]
	// time constant for smoothing.
	Variable timeConst = 0.0002 * deltax(ForceCorrected) * numPoints
	Sep[] = Sep[p] - xOff
	Force[] = -1 * (Force[p] - yOff)
	ForceCorrected = -1 * (ForceCorrected[p] -yOffCorr)
	// Get a copy of Zsnsr in nm
	Duplicate /O Sep,toPlotX
	Duplicate /O Force,toPlotY
	Duplicate /O ForceCorrected,toPlotYCorrected
	String xUnits = "nm"
	String yUnits = "pN"
	ModUnitUtil#ConvertToUnits(toPlotX,xUnits)
	ModUnitUtil#ConvertToUnits(toPlotY,yUnits)
	ModUnitUtil#ConvertToUnits(toPlotYCorrected,yUnits)
	// Plot everything
	Variable nRows = 2
	Variable nCols = 2
	String mFig= ModPlotUtil#Figure(hide=ModDefine#True(),heightIn=14,widthIn=18)
	// Plot showing DeflV versus time with fits
	ModPlotUtil#Subplot(nRows,nCols,1)
	ModPlotUtil#Plot(mDeflV,color="grey")
	ModPlotUtil#Plot(mToFit,color="k")
	// Only plot retract if we have it
	if ( preProc.hasFitIdxRetr)
		ModPlotUtil#Plot(mToFitRetr,color="k")
	endIf
	ModPlotUtil#Xlabel("Time",units="s")
	ModPlotUtil#YLabel("DeflV",units="V")
	ModPlotUtil#Title("Raw Approach/Retract vs Time")
	ModPlotUtil#pLegend(labelStr="Raw Data,Approach/Retract Raw Data")
	// Plot showing correction steps
	ModPlotUtil#Subplot(nRows,nCols,3)
	// raw data
	ModPlotUtil#Plot(mDeflV,color="grey")
	// plot the corrected and fits for the approach/retract
	ModPlotUtil#Plot(correctedAppr,color="k")
	ModPlotUtil#Plot(correctedRetr,color="k")
	ModPlotUtil#Plot(fitCorrectedAppr,color="r")
	// only plot retract if we have it
	if ( preProc.hasFitIdxRetr)
		ModPlotUtil#Plot(fitCorrectedRetr,color="r")
	endIf
	ModPlotUtil#axvline(surfaceTime,color="g")
	ModPlotUtil#Xlabel("Time",units="s")
	ModPlotUtil#YLabel("DeflV",units="V")
	ModPlotUtil#Title("Fitting (red) to interference artifact")
	// Plot of corrected /raw curve
	ModPlotUtil#Subplot(nRows,nCols,2)
	Make /O/N=0 xAppr,yAppr,xRetr,yRetr
	ModSurfacePlotting#PlotApprRetract(Sep,Force,xUnits,yUnits,mDetector,xAppr,yAppr,xRetr,yRetr,location=ANCHOR_BOTTOM_MIDDLE,timeConstant=timeConst)
	ModPlotUtil#Xlabel("Separation",units=xUnits)
	ModPlotUtil#YLabel("Force",units=yUnits)
	ModPlotUtil#Title("Raw FEC")
	Variable maxY = WaveMax(toPlotY)
	Variable minY = WaveMin(toPlotY)
	ModPlotUtil#Ylim(minY,maxY)
	// Plot of final curve
	ModPlotUtil#Subplot(nRows,nCols,4)
	Make /O xApprCorr,yApprCorr,xRetrCorr,yRetrCorr
	ModSurfacePlotting#PlotApprRetract(Sep,ForceCorrected,xUnits,yUnits,mDetector,xApprCorr,yApprCorr,xRetrCorr,yRetrCorr,location=ANCHOR_BOTTOM_MIDDLE,timeConstant=timeConst)
	ModPlotUtil#Title("Corrected FEC (Dotted line is Surface Sep)")
	ModPlotUtil#Xlabel("Separatio",units=xUnits)
	ModPlotUtil#YLabel("Force",units=yUnits)
	ModPlotUtil#axvline(toPlotX[zeroIdx],color="g")
	ModPlotUtil#Ylim(minY,maxY)
	// Get the median of the last N points
	Variable N  = 1000
	Duplicate /O/R=[numPoints-(N+1),numPoints-1] toPlotYCorrected,DeflVMedian
	ModPlotUtil#axhline(StatsMedian(DeflVMedian),color="g")
	return mFig
End Function

// Given a detector object and XSurface and ySurface (assumed DeflV and Zsnsr)
// Produces plots of deflV vrsus Zsnsr and force versus sep
Static Function /S PlotInvolsCurve(myDetection,XSurfaceDetect,ySurfaceDetect,[inTypeX,inTypeY,hide])
	Struct SurfaceDetector & myDetection
	Wave xSurfaceDetect,ySurfaceDetect
	Variable inTypeX,inTypeY,hide
	hide = ParamIsDefault(hide) ? ModDefine#True() : hide
	inTypeX = ParamIsDefault(inTypeX) ? MOD_X_TYPE_Z_SENSOR : inTypeX
	inTypeY = ParamIsDefault(inTypeY) ? MOD_Y_TYPE_DEFL_VOLTS : inTypeY
	Variable surfaceIdx = myDetection.surfaceIndex
	// Get the 'zeroed' waves (these are what we will work with )
	Make /O/N=(0) scaledX,scaledY
	ModSurfaceDetectorUtil#GetScaledWave(XSurfaceDetect,scaledX,ySurfaceDetect,scaledY,surfaceIdx)
	// Plot DeflV vs Zsnsr
	String mFig = ModPlotUtil#Figure(hide=hide)
	ModPlotUtil#Subplot(3,1,1)
	String mXUnits = "nm"
	String mVoltUnits = "mV"
	// plot, reversing the zsnsr axis (true)
	Duplicate /O scaledX,revX
	revX[] = revX[p] * -1
	Make /O/N=0 	xAppr,yAppr,xRetr,yRetr
	PlotApprRetract(revX,scaledY,mXUnits,mVoltUnits,myDetection,xAppr,yAppr,xRetr,yRetr)
	ModPlotUtil#Xlabel("Zsnsr",units=mXUnits)
	ModPlotUtil#YLabel("Defl Volts",units=mVoltUnits)
	// Convert to force and sep 
	ModPlotUtil#Subplot(3,1,2)
	Duplicate /O scaledX,sep
	Duplicate /O scaledY,force,DeflM
	ModCypherUtil#ConvertY(YSurfaceDetect,inTypeY,force,MOD_Y_TYPE_FORCE_NEWTONS,DeflMeters=DeflM)
	ModCypherUtil#ConvertX(XSurfaceDetect,inTypeX,sep,MOD_X_TYPE_SEP,DeflM)
	// We want to re-scale. The surfaceIdx is an *index*, so we need to re-zero based on whatever separation
	// that corresponds to (dependent on deflV, see cypher conversion routines) 
	ModSurfaceDetectorUtil#GetScaledWave(sep,sep,force,force,surfaceIdx)
	// Convert the force to pN
	String mForceUnits = "pN"
	Make /O/N=0 	xApprForce,yApprForce,xRetrForce,yRetrForce
	PlotApprRetract(sep,force,mXUnits,mForceUnits,myDetection,xApprForce,yApprForce,xRetrForce,yRetrForce)
	ModPlotUtil#axvline(0,color="g")
	ModPlotUtil#Xlabel("Separation",units=mXUnits)
	ModPlotUtil#YLabel("Force",units=mForceUnits)
	ModPlotUtil#Subplot(3,1,3)
	// Plot just around zero point.
	// Note: we want to be witin 10nm of correct, for plotting +50,-10 should be ok
	// XXX check for adhesions? 
	Variable nmFromZero = 25, nmBeforeZero = 25
	Make /O/N=0 	xApprForceClose,yApprForceClose,xRetrForceClose,yRetrForceClose
	PlotApprRetract(sep,force,mXUnits,mForceUnits,myDetection,xApprForceClose,yApprForceClose,xRetrForceClose,yRetrForceClose)
	ModPlotUtil#xlim(-1 * nmBeforeZero,nmFromZero)
	ModPlotUtil#axvline(0,color="g")
	ModPlotUtil#Xlabel("Separation",units=mXUnits)
	ModPlotUtil#YLabel("Force",units=mForceUnits)
	return mFig
End Function 

// Given a surface detection object from 'GetSurfaceLocationAndInvols' and the (raw)
// x and y used to make it, plots the y and x versus time 
Static Function /S PlotVersusTime(myDetection,XSurfaceDetect,ySurfaceDetect,[hide])
	// Get the invols from the note (what the cypher stores when you measure invols )
	Struct SurfaceDetector & myDetection
	Wave xSurfaceDetect,ySurfaceDetect
	Variable hide
	hide = ParamIsDefault(hide) ? ModDefine#True() : hide
	Variable Invols = ModCypherUtil#GetInvols(ySurfaceDetect)
	Variable calInvolsNmPerV = myDetection.invols *1e9
	String mStr
	sprintf mStr, "Invols (Calc/Cypher): \r %.1f / %.1f [nm/V]",calInvolsNmPerV,Invols * 1e9
	Print(mStr)
	// For Plotting, we really only want to look at a small region around the invol location
	// look about 5% around it 
	Variable idxBefore = myDetection.surfaceIndexBefore
	Variable idxAfter = myDetection.surfaceIndexAfter
	Variable minTime = pnt2x(ySurfaceDetect,idxBefore)
	Variable maxTime = pnt2x(ySurfaceDetect,idxAfter)
	// Convert the x to nm 
	Duplicate /O xSurfaceDetect,zsnsrPlot
	string mZUnits= "nm"
	ModUnitUtil#ConvertToUnits(zsnsrPlot,mZUnits)	
	// Get the Zsnsr bounds we care about 
	Variable minZ = zsnsrPlot[idxBefore]
	Variable maxZ = zsnsrPlot[idxAfter]	
	// Plot DeflV and Separation versus time (separately)
	String mFig = ModPlotUtil#Figure(hide=hide,heightIn=24,widthIn=13)
	ModPlotUtil#Subplot(2,2,1)
	ModPlotUtil#Plot(ySurfaceDetect,marker="")
	ModPlotUtil#axvline(minTime,color="k")
	ModPlotUtil#axvline(maxTime,color="g")
	ModPlotUtil#Xlabel("Time (s)")
	ModPlotUtil#YLabel("Defl Volts [V]")
	ModPlotUtil#Subplot(2,2,3)
	ModPlotUtil#Plot(ySurfaceDetect,marker="")
	ModPlotUtil#axvline(minTime,color="k")
	ModPlotUtil#axvline(maxTime,color="g")
	ModPlotUtil#Xlabel("Time (s)")
	ModPlotUtil#YLabel("Defl Volts [V]")
	ModPlotUtil#Xlim(minTime*0.95,maxTime*1.05)
	// Look at the Defl vs Zsnsr, get the true invols
	ModPlotUtil#Subplot(2,2,2)
	ModPlotUtil#Plot(ySurfaceDetect,mX=zsnsrPlot,marker="")
	ModPlotUtil#Xlabel("Zsnsr",units=mZUnits)
	ModPlotUtil#YLabel("Defl Volts [V]")
	ModPlotUtil#axvline(minZ,color="k")
	ModPlotUtil#axvline(maxZ,color="g")
	ModPlotUtil#Subplot(2,2,4)
	// Look at the Defl vs Zsnsr, get the true invols
	ModPlotUtil#Plot(ySurfaceDetect,mX=zsnsrPlot,marker="")
	ModPlotUtil#Xlabel("Zsnsr",units=mZUnits)
	ModPlotUtil#YLabel("Defl Volts [V]")
	// get the appropriate limits
	ModPlotUtil#Xlim(zsnsrPlot[idxBefore],zsnsrPlot[idxAfter])
	ModPlotUtil#SwapAxis()
	ModPlotUtil#Title(mStr,yOffset=-0.05)
	// We swap the axis, to make it easier to see involes (nm/V)
	// make horizontal lines where we want them
	ModPlotUtil#axhline(minZ,color="k")
	ModPlotUtil#axhline(maxZ,color="g")
	return mFig
End Function


// Given a Zsnsr and DeflV, creates plots showing the approach and retractiong
Static Function AnalyzeSensorDefl(Zsnsr,DeflVolts,outPath,id,[saveFile,correctForInterference])
	Wave Zsnsr,DeflVolts
	Variable id,saveFIle,correctForInterference
	String Outpath
	saveFile = ParamIsDefault(saveFile) ? ModDefine#True() : saveFile
	correctForInterference = ParamIsDefault(correctForInterference) ? ModDefine#True() : correctForInterference
	// Get the ('real') invols
	Variable involsRec =  ModCypherUtil#GetInvols(Zsnsr) 
	Duplicate /O DeflVolts,DeflVoltsWorking
	Make /O/N=(0) DeflVoltsCorr
	Struct SurfaceDetector myDetectionObj
	Struct SurfacePreProcInfo preProc
	Variable  Invols,surfaceZsnsr
	ModSurfaceDetector#SurfaceDetect(Zsnsr,DeflVolts,Invols,surfaceZsnsr,Detector=myDetectionObj,PreProcessor=preProc,CorrectedDeflVolts=DeflVoltsCorr)
	// POST: have all the information we need
	// Start plotting
	String mFig
	 if (correctForInterference)
		mFig = ModSurfacePlotting#PlotArtifactCorrectionCurve(Zsnsr,DeflVolts,DeflVoltsCorr,myDetectionObj,preProc)
		if (saveFile)
			ModPlotUtil#SaveFig(figName=mFig,path=outPath,saveName=  num2str(id)  + "_CorrectCurve")	
		EndIf
	EndIf
	mFig = ModSurfacePlotting#PlotVersusTime(myDetectionObj,Zsnsr,DeflVoltsCorr)
	if (saveFIle)
		ModPlotUtil#SaveFig(figName=mFig,path=outPath,saveName=  num2str(id) + "_InvolsCurve")
	endIf
	// TODO: new figure, plot DeflV vs Separation, show how invols are working. 
	mFig = ModSurfacePlotting#PlotInvolsCurve(myDetectionObj,Zsnsr,DeflVoltsCorr)
	if (saveFIle)
		ModPlotUtil#SaveFig(figname=mFig,path=outPath,saveName= num2str(id) + "ApproachRetrCurve" )
	endIf
End Function
