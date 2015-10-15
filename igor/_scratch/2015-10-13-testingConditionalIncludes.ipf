// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#pragma ModuleName = ScratchTestCondInclude

// Module is just to explore how conditional includes work...

#ifndef DEF_ROOTNAME
// "Def_Rootname" is defined in IoUtil
#include "::Util:IoUtil"
#else
StrConstant DEF_ROOTNAME = "bloo"
#endif

#ifndef ColorMax
Constant ColorMax = 42
#else
#include "::Util:PlotUtil"
#endif

Static Function Main()
	String mRoot = DEF_ROOTNAME
	if (cmpstr(mRoot,"root")!=0)
		print("Wtf!")
	EndIf
	if (ColorMax != 42)
		print("Wtf!")
	EndIf
End Function