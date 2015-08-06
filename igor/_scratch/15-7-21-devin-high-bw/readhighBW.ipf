// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchReadHighBW
#include "..:..:Util:IoUtil"

Static Function Main()
	String mFolder
	Variable GetInteractive = 1
	if (GetInteractive)
		// Get the folder interactively (with a dialog)
		if(!ModIoUtil#GetFolderInteractive(mFolder))
			print("User Cancelled")
			return 0
		EndIf
	Else
		// Just use a canned directory
		mFolder = "Macintosh HD:Users:patrickheenan:Documents:education:boulder_files:rotations_year_1:3_perkins:code:5_2015_devin_transition_time:playData:20150417_NuG2:Data_AzideB1:"
	EndIf
	// POST: mfolder is set with the folder.
	// Load all the waves in this folder
	Make /O/T/N=(0) mFiles
	Make /O/T mExt = {".pxp",".ibw"}
	String whereToLoad = "root:foobar"
	ModIoUtil#LoadIgorFilesInFolder(mFolder,locToLoadInto=whereToLoad,validExtensions=mExt)
	KillWaves /Z mFiles,mExt
End Function
