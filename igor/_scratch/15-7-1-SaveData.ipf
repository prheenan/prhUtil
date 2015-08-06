// Use modern global access method, strict compilation
#pragma rtGlobals=3	

Function Main()
	String mWavePath = "root:foo;"
	// Saving as a tab delimited file works fine
	Save /O/J/B/P=home mWavePath as "fooDelim.txt"
	Print("Saved the delimited file")
	// Sleep for 5 seconds
	Print("Going to sleep...")
	Sleep /S 5
	Print("Finished sleeping, going to save as text file.")
	// Saving as an igor text file does *not* work
	Save /O/T/B/P=home mWavePath as "fooText.itx"
	Print("Saved the text file")
End Function
