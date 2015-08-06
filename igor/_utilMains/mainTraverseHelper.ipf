// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#include "..:ViewTraverse"
#pragma ModuleName = MainUtilTraverse

StrConstant mRoot = "root:packages:View_DNAWLC:"
StrConstant mModel = "DNA_WLC"
StrConstant mGlobalName = "ViewGlobal"

Function TraverseSaveDir(folderName)
	String folderName
	printf "%s\r",folderName
End Function

Function TraverseExpDir(folderName)
	String folderName
	printf  "---%s\r",folderName
End Function

Function TraverseTraceDir(folderName)
	String folderName
	printf "------%s\r",folderName

End Function

Static Function Main()
	// This function goies through and uses the default traversals
	// XXX should really move defaults 
	// create a dummy global data variable, with a model name.
	Struct ViewGlobalDat mGlobal
	// Get the global data object
	ModViewGlobal#GetGlobalDataStr(mGlobal,mGlobalName)
	// Get the default traverse object.
	Struct TraverseObj mObj
	ModViewTraverse#InitDefTraverseObj(mGlobal,mObj)
	ModViewTraverse#TraverseSaveDataFolder(mRoot,mObj)
End Function
