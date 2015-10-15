#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma ModuleName = ModSurfaceDetectorIo

// For reading in test files (offline)
#include "::Util:IoUtilHDF5"

// Get force and extension versus time
Static Function GetSepForce(sep,force,mFileName)
	Wave Sep,Force
	String mFileName
	// POST: this wave has Time,Sep,Force in the first three columns
	ModIoUtilHDF5#GetSepForceFromFile(mFileName,sep,force)
End Function


Static Function GetZsnsrDeflV(Zsnsr,DeflVolts,fileName)
	String fileNAme
	Wave Zsnsr,DeflVolts
	Make /O/N=(0) Sep,RawForce
	GetSepForce(sep,RawForce,fileName)
	ConvertSepForceToZsnsrDeflV(Sep,RawForce,Zsnsr,DeflVolts)
	KillWaves /Z Sep,RawForce
End Function