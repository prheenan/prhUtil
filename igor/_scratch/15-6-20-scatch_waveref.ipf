// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#pragma ModuleName = ScratchWaveRef

Static Function foo(change)
	Wave /T change
	Make /O/T tmp = {"foo","bar"}
	Duplicate /O/T tmp,change
	print(change)
End Function

Static Function Main() 
	Wave /T finished
	Make /O/T/N=(0) finished
	foo(finished)
End Function
