// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchConversionSaver
#include "::Util:IoUtil"
#include "::Util:IoUtilHDF5"

Static Function Main()
	// This function goes Saves:
	// Time 
	// Sep 
	// ZSnsr
	// Defl
	// DeflV
	// Force 
	// For a single File/Subfolder, for use in testing validity of the converter. 
	String Subfolder = "root:ForceCurves:SubFolders:X150603:"
	String fileBase = "LoopDNA_160ng_uL0020"
	Make /O/T extensions = {"Time","Sep","Zsnsr","Defl","DeflV","Force"}
	// Get a wave to put the copies of the waves into
	String mFolder
	ModIoUtil#GetFolderInteractive(mFolder)
	// Save each wave as a separate file into the given folder
	Variable i, nWaves = DimSize(extensions,0)
	for (i=0; i<nWaves; i += 1)
		String fileName =  fileBase + extensions[i]
		Wave mWave  = $(Subfolder + fileName)
		String fullPath = ModIoUtil#AppendedPath(mFolder,fileName)
		// Write out the wave to the path specified
		ModIoUtilHDF5#Write2DWaveToFile(mWave,fullPath)
	EndFor
End Function