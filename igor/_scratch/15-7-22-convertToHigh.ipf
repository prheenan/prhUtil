// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchConvertToHighRes
#include "::ModelInstances:NUG2"

// Function to test the conversion to high time resolution
Static Function Main()
	String preamble = "root:Packages:View_NUG2:Data:Data_AzideB1:Image"
	Make /O/T mWave = {"2400","2401","2448","2449","2451","2452"}
	// use P notation
	Variable n = DImSize(mWave,0)
	mWave[0,n-1] = preamble + mWave[p] 
	Struct ProcessStruct mProc
	FuncRef ProtoGetInputNames mGetWaves = $("ModNUG2#GetInputNames")
	ModPreprocess#InitProcStruct(mProc,ModIoUtil#cwd(),mGetWaves)
	ModNug2#GetInputNames(mWave,mProc)
	return MOdDefine#True()
End Function
