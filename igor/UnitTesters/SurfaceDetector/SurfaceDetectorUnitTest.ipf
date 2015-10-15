// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#pragma ModuleName = ModSurfaceDetectorUnitTest
// For plotting
#include ":::Util:PlotUtil"
// For error reporting
#include ":::Util:ErrorUtil"
// For testing the utility functions
#include ":::SurfaceDetector:SurfaceDetectorUtil"
// For conversions, etc.
#include ":::Util:CypherUtil"
// For plotting, but more generically / we can use elsewhere
#include ":::SurfaceDetector:SurfacePlotting"

Static StrConstant TestFilePath = "Macintosh HD:Users:patrickheenan:utilities:igor:SurfaceDetector:TestData:X150603-3516181461-LoopDNA_160ng_uL0020Force.hdf"


Static Function MainSmoothing()
	Make /O/N=0 sep,force
	ModSurfaceDetectorUtil#GetSepForce(sep,force,TestFilePath)
	// Make two different smoothers at two different time constants
	Duplicate /O force,mSmooth,mSmoothLowRes
	ModSurfaceDetectorUtil#SurfaceSmooth(force,mSmooth,timeConstant=0.05)
	// make a barely smoothed version
	ModSurfaceDetectorUtil#SurfaceSmooth(force,mSmoothLowRes,timeConstant=deltax(force)*10)
	// Make a graph to display the smoothed results
	String mFig = ModPlotUtil#Figure(hide=0)
	ModPlotUtil#Plot(force,marker="",linestyle="-")
	ModPlotUtil#Plot(mSmoothLowRes,marker="",linestyle="--",color="g")
	ModPlotUtil#Plot(mSmooth,marker="",linestyle="-",color="r")
	ModPlotUtil#XLabel("Seconds")
	ModPlotUtil#YLabel("Force (N)")
End Function

// function to demonstrate how the bounding indices are obtained for the approach and retraction curve
Static Function MainBoundingIdx()
	ModPlotUtil#ClearAllGraphs()	
	Make /O/N=0 sep,RawForce
	ModSurfaceDetectorUtil#GetSepForce(sep,RawForce,TestFilePath)
	// Get a smoothed version of the RawForce
	Duplicate /O RawForce,SgFiltered
	ModSurfaceDetectorUtil#SurfaceSmooth(RawForce,SgFiltered)
	// Get just the approach/retract porton of the smoothed vector (assume symmetric)
	Variable nPoints = DimSize(RawForce,0)
	Variable halfPoint = floor(nPoints/2)
	Duplicate /O /R=[0,halfPoint] SgFiltered,approach
	Duplicate /O /R=[halfPoint,nPoints-1] SgFiltered,retract
	// Get the indices for the approach 
	Variable idxBefore,idxMax,idxAfter
	 ModSurfaceDetectorUtil#GetSurfaceBoundingIndices(approach,idxBefore,idxMax,idxAfter)
	 // Get the indices for the retraction
	 Variable idxBeforeRet,idxMaxRet,idxAfterRet
	 ModSurfaceDetectorUtil#GetSurfaceBoundingIndices(retract,idxBeforeRet,idxMaxRet,idxAfterRet)
	 // add the half point (ie: 'zero index') to the retract indices
	 idxBeforeRet += halfPoint
	 idxMaxRet += halfPoint
	 idxAfterRet += halfPoint
	 // Plot everything
	 ModPlotUtil#Figure(hide=0)
	 ModPlotUtil#Plot(RawForce,marker="",linewidth=0.5,color="k")
	 // plot the approach and retraction separately
	  ModPlotUtil#Plot(SgFiltered,marker="",color="g")
	 // Plot the approach indices
	 ModPlotUtil#Axvline(pnt2x(SgFiltered,idxBefore),color="k")
	 ModPlotUtil#Axvline(pnt2x(SgFiltered,idxMax),color="r")
	 ModPlotUtil#Axvline(pnt2x(SgFiltered,idxAfter),color="b")
	 // Plot the retract indices
	 ModPlotUtil#Axvline(pnt2x(SgFiltered,idxBeforeRet),color="k")
	 ModPlotUtil#Axvline(pnt2x(SgFiltered,idxMaxRet),color="r")
	 ModPlotUtil#Axvline(pnt2x(SgFiltered,idxAfterRet),color="b")
	ModPlotUtil#XLabel("Seconds")
	ModPlotUtil#YLabel("Force (N)")
	ModPlotUtil#pLegend()
End Function

// Tests surface detection on a force extension curve
Static Function MainSurfaceDetection()
	ModPlotUtil#ClearAllGraphs()	
	// get the separation and force from the save files
	Make /O/N=0 Zsnsr,DeflVolts
	ModSurfaceDetectorUtil#GetZsnsrDeflV(Zsnsr,DeflVolts,TestFilePath)
	// We now have converted to the units we want to calculate the invols.
	// Go ahead and make a copy of thwe waves as X and Y, for use in analysis below 
	Variable invols,surfaceX
	Struct SurfaceDetector myDetectionObj
	ModSurfaceDetectorUtil#GetRetractInvols(zsnsr,deflVolts,invols,surfaceX,debugStruct=myDetectionObj)
	ModSurfacePlotting#PlotVersusTime(myDetectionObj,Zsnsr,DeflVolts)
	// TODO: new figure, plot DeflV vs Separation, show how invols are working. 
	ModSurfacePlotting#PlotInvolsCurve(myDetectionObj,Zsnsr,DeflVolts)
End Function

Static Function Main()
	MainSurfaceDetection()
End Function