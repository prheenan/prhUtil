// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModSurfaceDetectorDemoOffline
#include ":::Util:IoUtil"
#include ":::Util:CypherUtil"
#include ":::SurfaceDetector:SurfaceDetectorIo"
#include ":::SurfaceDetector:SurfacePlotting"
#include ":::Util:StartUpUtil"

// This file reads in hdf5 binary files of force and separation, and
// then detects their surfaces

// "limitNum" limits the number of curves to analyze (between 1 and however many files you have)
Static Function Main([limitNum,startNum])
	Variable limitNum,startNum
	limitNum = ParamIsDefault(limitNum) ? 10 : limitNum
	startNum = ParamIsDefault(startNum) ? 0 : startNum
	// POST: parameters are done
	// Get a fresh slate for this experiment
	ModStartUpUtil#FreshSlate()
	// First, get all the ".hdf" files in the given folder
	String inPath = ModIoUtil#GetIgorPathFromSys("Macintosh HD:Users:patrickheenan:Desktop:DnaBinariesTmp:")
	String outPath = ModIoUtil#GetIgorPathFromSys("Macintosh HD:Users:patrickheenan:Desktop:tmpOut")
	Make /O/N=(0)/T allFiles
	String mExt = ".hdf"
	ModIoUtil#GetFoldersAndFiles(inPath, allFiles,extension=mExt, recurse=ModDefine#False(), level=0)
	Variable nFIles = DimSize(allFiles,0)
	// Make a wave to hold the true invols and measured involts
	Variable nPoints = min(nFiles,limitNum)
	Make /O/N=(nPoints) involsRecorded,involsMeasured
	// Next, look through and get the invols and surface location based on the approach of 
	// the Zsnsr vs Separation Curve 
	Variable i
	for (i=startNum; i< nFiles; i+=1)
		if (i >= limitNum)
			break
		EndIF
		// Convert the zsnsr and deflv (what the detector uses) 
		Make /O/N=0  Zsnsr,DeflVolts
		ModSurfaceDetectorIo#GetZsnsrDeflV(Zsnsr,DeflVolts,(allFiles[i]))
		// For kicks and giggles, try in another folder, leadng to saving the graphics files.
		String mDir = ModIoUtil#Sanitize(ModIoUtil#GetFileName(allFiles[i],removeExt=ModDefine#True()))
		NewDataFolder $mDir
		SetDataFolder  $mDir
		ModSurfacePlotting#AnalyzeSensorDefl(Zsnsr,DeflVolts,outPath,i)
	EndFor
End Function