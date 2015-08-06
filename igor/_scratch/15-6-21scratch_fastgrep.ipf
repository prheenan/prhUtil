// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchGrep


Static Function Main()
	String mWave = "Blah1,Blah,Blah2,Blah3,Foo,Nope,Nada,"
	String mRegex = "(Blah)+"
	String out,out2
	SplitString /E=(mRegex) mWave,out,out2
	printf "[%s,%s]\r",out,out2
	// Grep can't actually match against the strings
	KillWaves /Z mWave,matches
End Function


//http://www.igorexchange.com/node/6569
static Function Select(str)
	String str
	String tmp = str[0,2]
	if (CmpStr(tmp,"foo") == 0)
		return 1
	endif
	return 0
End
 
Function Demo()
	Make /O/T mWave = {"foo24","bar","foo","foo35"}
	Wave/T mWave = root:mWave
	Extract /O mWave, destWave, Select(mWave)
End