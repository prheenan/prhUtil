// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchDimLabelTest

// Show how dimensional labels work...
Static Function Main()
	Make/O/N=3 mWave
	SetDimLabel 0,0, $"foo", mWave
	SetDimLabel 0,1,bar,mWave
	// following line works
	mWave[%foo] = 1
	mWave[%$"bar"] = 2
	// following line throws an error
	mWave[%notHere] = 1
	// So... this type of dimension labelling isn't safe. 
	// Suggestion: make a struct class with
	// (1) a wave
	// (2) a list of dimensions
	// any time we set, update this accordingly. Methods should be like
	// Set(key,value) 
	// Get(key)  -- for this one, error checking 
	// may need to make everything a string? this can
	// be hidden from the user ... 
End Function