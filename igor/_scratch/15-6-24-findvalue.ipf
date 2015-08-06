// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = scratchFindVal


Static Function Main()
	Make /O/T mWave = {"hello there","hya","h!"}
	String search = "hi"
	FindValue /TEXT=(search)  mWave
	print(V_VALUE)
End Function