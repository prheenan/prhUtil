// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#include <SQLUtils>
#pragma ModuleName = ScratchSQL
//Shaemlessly stolen from SQL emo 

Static Function PrintSQLDiag(testTitle, flag, SQLResult, rowCount, numWaves, waveNames, diagnostics)
	String testTitle
	Variable flag, SQLResult, rowCount, numWaves
	String waveNames, diagnostics

	// Print output variables
	Printf "%s: V_flag=%d, V_SQLResult=%d, V_SQLRowCount=%d, V_numWaves=%d, S_waveNames=\"%s\"\r", testTitle, flag, SQLResult, rowCount, numWaves, waveNames
	if (strlen(diagnostics) > 0)
		Printf "Diagnostics: %s\r", diagnostics
	endif
End

Static Function Main()
	String connectionStr = "DSN=localHost;UID=root"
	String statement = "SELECT * FROM information_schema.tables;"
	SQLHighLevelOp /CSTR={connectionStr,SQL_DRIVER_NOPROMPT} /O /E=1 statement
	PrintSQLDiag(statement, V_flag, V_SQLResult, V_SQLRowCount, V_numWaves, S_waveNames, S_diagnostics)
End Function
