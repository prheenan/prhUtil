// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchSaveDataMultipleCols


Static Function Main()
	String waveY = "fooY"
	String waveX = "fooX"
	String Folder = "home:"
	String name = "concat"
	SaveForceExtensionFromStub(waveX,waveY,Folder,Name)
End Function

 Static Function SaveForceExtensionFromStub(StubSep,StubForce,Folder,Name)
	String StubForce,StubSep,Folder,Name
	// XXX make sure wave exists?
	Wave force = $StubForce
	Wave sep = $StubSep
	Variable n=DimSize(force,0)
	Make /O/N=(n) mTime
	Variable dt= DimDelta(force,0)
	Variable t0 = DimOffset(force,0)
	mTime = p*dt + t0
	// /DL: Set dimension labels
	// /O: overwrites
	 Concatenate /O/DL {mTime,sep,force}, combinedWave
	 // get the force note
	String mNote = note(force)
	// Append to the concatenated wave
	Note combinedWave,mNote
	// POST: $combinedName is a wave with columns like [time,x,y]
	// Go ahead and save
	// *dont* save the x scale (time), since we can get that from the x scaling later.
	SaveWaveDelimited(combinedWave,Folder,Name=Name)
	// Kill the wave we make
	KillWaves /Z combinedWave
End Function

 Static Function SaveWaveDelimited(ToSave,Folder,[Name])
	Wave ToSave
	// Save the wave "ToSave" to "FilePath:Name"
	// If  Name is null, just uses the wave name
	// XXX make sure wave exists?
	String Folder,Name
	Variable SaveXScale
	If (ParamIsDefault(Name))
		Name = NameOfWave(ToSave)
	EndIf
	String FullPath = Name
	// V-546
	// /O: Overwrites
	// /J: saves as tab-delimited format
	// /T: save as igor text file
	// /W: includes wave name
	Save /O/T/W ToSave as FullPath	
End Function