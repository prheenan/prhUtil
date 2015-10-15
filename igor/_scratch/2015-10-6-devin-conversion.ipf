// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchDevinConv
#include "::Converters:DevinHighResConvert"
#include "::Util:IoUtil"
#include "::Util:DataStructures"

Static Function Main()	
	// Assume we have waves with this stem already loaded in this pxp file.  For example, the wave
	// might be: 
	//root:Image2448DeflV_Ext,
	//root:Image2448DeflV_Ret
	// root:Image2448DeflV_Towd
	// root:Image2448ZSnsr_Ext
	// root:Image2448ZSnsr_Ret
	 // root:Image2448ZSnsr_Towd
	 // (etc)
	 // Also, need the 2449 ('next' number up is the high res: 
	//root:Image2449DeflV_Ext
	//root:Image2449DeflV_Ret
	//root:Image2449DeflV_Towd
	String mDataDir = "root:Packages:View_NUG2:Data"
	Make /T/O/N=0 mStems 
	String suffixNeeded= "Time_Ext,DeflV_Ext"
	ModIoUtil# GetUniqueStems(mStems,mDataDir,suffixNeeded)
	Variable nStems = DimSize(mStems,0)
	Variable i;
	String mFolder
	ModioUtil#GetFolderInteractive(mFolder)
	for (i=0; i<nStems; i+=1)
		String mWaveStem = mStems[i]
		// Go ahead and create the low resolution Defl and Zsnsr by stitching them together.
		String  fullZsnsrLow, fullDeflLow, fullDeflHigh, fullZsnsrHigh
		if(!ModDevinHighResConvert#CreateZsnsrAndDefl(mWaveStem,fullZsnsrLow, fullZsnsrHigh,fullDeflLow,fullDeflHigh))
			// This wave wasn't right. Throw error?
			continue
		EndIf
		// Save the (low resolution) Z and defl in an hdf5 file. 
		// we can save as 'force extension'.
		String mFileName = ModIoUtil#GetFileName(mWaveStem)
		ModIoUtilHDF5#SaveForceExtensionFromStub(fullZsnsrLow,fullDeflLow,mFolder,"NUG2LowRes" + mFileName)
	EndFor
End Function