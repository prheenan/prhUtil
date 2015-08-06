// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchStatic

Static Structure Foo
	Variable a
EndStructure

Static Function Main()
	ScratchStatic#Foo bar
	bar.a = 12345
End Function
