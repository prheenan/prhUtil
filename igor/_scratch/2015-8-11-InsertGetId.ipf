// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModInsertGetId
#include <SQLUtils>
StrConstant CONNECT_STR = "DSN=localhost;UID=root"

Static Function Main()
 	String mStatement = "INSERT INTO CypherAFM.TraceRating (RatingValue,Name,Description) VALUES (0,'<Name>sadasdasd','<Description>');"
	 SQLHighLevelOp /CSTR={CONNECT_STR,SQL_DRIVER_NOPROMPT} /O mStatement
	 //get the last ID
	 // Usnig 'SELECT LAST_INSERT_ID()' in the same mStatement or the next does not work
	 // If in same, syntax error near SELECT LAST_INSERT_ID();
	 // If in next, returns 0
	 SQLHighLevelOp /CSTR={CONNECT_STR,SQL_DRIVER_NOPROMPT} /O "SELECT MAX(idTraceRating) FROM CypherAFM.TraceRating;"
	 Wave mWave = $"MAX_idTraceRating_"
	 print("foo")
End Function