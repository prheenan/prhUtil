// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModSave2D

Static Function Main()
	String mX = "root:Packages:View_DNAWLC:MarkedCurves:X150615:X150615_circ1600154Force:DataCopy:X150615_circ1600154Sep"
	String mY = "root:Packages:View_DNAWLC:MarkedCurves:X150615:X150615_circ1600154Force:DataCopy:X150615_circ1600154Force"
	// O: overwrite
	// DL: dimension labels
	Concatenate /O/DL {$mX,$mY}, dest
	print("foo")
	// /D : opens dialog
	// /Q: quiet
	GetFileFolderInfo /D/Q 
	// I: interactive save
	// J: tab-delimited save
	// W: save wave names
	// /U={1,1,0,0}: write a positon column based on the scaling (time)
	Save /W/I/O/J/U={1,1,0,0} dest
	print("Saved!")
End Function