// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchTxt

Function Main()
	Make /O/T tmpTxt = {"Hello","hithere","a0","a10","Bye","a","b","c","d","e","f","g","h"}
	Make /O/N=13 mIdx
	MakeIndex /A tmpTxt,mIdx
	// Get the numer of row (== number of points in col vector)
	Variable nPoints = DimSize(tmpTxt,0)
	Variable i=0
	for (i=0; i< nPoints; i+= 1)
		printf "Sorted Index %d is textwave %d / %s\r",i,mIdx[i],tmpTxt[i]
	EndFor
	print("Sorting...")
	IndexSort mIdx,tmpTxt
	for (i=0; i< nPoints; i+= 1)
		printf "Sorted Wave, at index %d: %s\r",i,tmpTxt[i]
	EndFor
End Function
