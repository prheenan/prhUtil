// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModSurfaceDetectorNUG2DemoOff

// Demo is designed to show how surface detection works in the prescence of interference artifacts
// Hint: Pretty much the same, just a pre-processing step where we smooth the interference artifact out.
#include ":::Util:IoUtil"
#include ":::Util:CypherUtil"
#include ":::SurfaceDetector:SurfaceDetectorIo"
#include ":::SurfaceDetector:SurfaceDetector"
#include ":::Util:StartUpUtil"
#include ":::SurfaceDetector:SurfacePlotting"

// "limitNum" limits the number of curves to analyze (between 1 and however many files you have)
Static Function Main([limitNum,startNum])
	Variable limitNum,startNum
	limitNum = ParamIsDefault(limitNum) ? 1 : limitNum
	startNum = ParamIsDefault(startNum) ? 0 : startNum
	// POST: parameters are done
	// Get a fresh slate for this experiment
	ModStartUpUtil#FreshSlate()
	// First, get all the ".hdf" files in the given folder
	String basePath =  "group:4Patrick:DemoData:SurfaceWiggleDemo:"
	String inPath = ModIoUtil#GetIgorPathFromSys(basePath + "Input:")
	String outPath =  ModIoUtil#GetIgorPathFromSys(basePath + "Output:")
	Make /O/N=(0)/T allFiles
	String mExt = ".hdf"
	ModIoUtil#GetFoldersAndFiles(inPath, allFiles,extension=mExt, recurse=ModDefine#False(), level=0)
	Variable nFIles = DimSize(allFiles,0)
	// Make a wave to hold the true invols and measured involts
	Variable nPoints = min(nFiles,limitNum)
	// Next, look through and get the invols and surface location based on the approach of 
	// the Zsnsr vs Separation Curve 
	Variable i
	for (i=startNum; i< nFiles; i+=1)
		if (i >= limitNum)
			break
		EndIF
		// Convert the zsnsr and deflv (what the detector uses) 
		Make /O/N=0  Zsnsr,DeflVolts
		ModSurfaceDetectorIo#GetSepForce(Zsnsr,DeflVolts,allFiles[i])
		ModSurfacePlotting#AnalyzeSensorDefl(Zsnsr,DeflVolts,outPath,i,saveFIle=ModDefine#True())
	EndFor
End Function