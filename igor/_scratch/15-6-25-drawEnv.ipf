// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModDraw

Static Function Main()
	DIsplay
	Make /O xTmp = {1,2,3,4,5}
	MAke /O yTmp = {7,5,1,0,-1}
	AppendToGRaph yTmp vs xTmp
	KillWaves /Z xTmp,yTmp
End Function