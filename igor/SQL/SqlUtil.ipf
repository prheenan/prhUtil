// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#pragma ModuleName = ModSqlUtil

#include <SQLUtils>
#include "::Util:Defines"
#include "::Util:IoUtil"
#Include ":SqlCypherAutoDefines"
// XXX remove these, just here for compilation
Static StrConstant DB_NAME = "CypherAFM"
StrConstant SCHEMA_NAME = "INFORMATION_SCHEMA"
StrConstant CONNECT_STR = "DSN=localhost;UID=root"
StrConstant SQL_EMPTY_APPEND = ""
// Connection specified by SqlConnect.
// If connectionRefNum is -1, it acts as if the /CONN flag were omitted.
Constant SQL_NO_CONN_SPECIFIED = -1

//  Simple select statement: http://www.tutorialspoint.com/mysql/mysql-select-query.htm
Static StrConstant SimpleSelectRegex = "Select %s from %s.%s"
// A simple insert statement: "Insert into <db>.<table> (<columns>) VALUES (<vals>) <appended>"
Static StrConstant InsertValueRegex = "INSERT INTO %s.%s (%s) VALUES (%s) %s"
// A remove *all rows* from table statement: "DELETE from <db>.<table>
// http://stackoverflow.com/questions/5673013/how-to-delete-all-data-in-a-table-in-sql-ce
Static StrConstant RemoveAllRegex = "DELETE FROM %s.%s"
//  Reset the auto intcrement: http://stackoverflow.com/questions/5452760/truncate-foreign-key-constrained-table
Static StrConstant ResetAutoIncrement = "ALTER TABLE %s.%s  AUTO_INCREMENT = 1"
// Get all the table names: Select table_name from <schema name>.tables where table_schema='<db>'
Static StrConstant GetTableRegex = "SELECT table_name from %s.tables where table_schema='%s'"
// Field Types
Constant SQL_PTYPE_DATE = 1
Constant SQL_PTYPE_NAME = 2
Constant SQL_PTYPE_DESCR = 3
Constant SQL_PTYPE_GENSTR = 4 // A general string, not a name of description
Constant SQL_PTYPE_INT = 5
Constant SQL_PTYPE_DOUBLE = 6
Constant SQL_PTYPE_FK = 7
Constant SQL_PTYPE_ID = 8

// Types of the query
Constant QUERY_TYPE_VAR = 0
Constant QUERY_TYPE_WAVE = 1
// Types of the data. These will be negatve, to avoid conflict with the query types
Constant QUERY_DATA_NUM = -1
Constant QUERY_DATA_STR = -2
// Sql items (e.g. colums) are separated by a comma
StrConstant SQL_QUERY_SEP = ","
// Wavenames used (e.g. "table_name") are separated by a semicolon
StrConstant SQL_WAVE_SEP = ";"
// Verbosity / Debugging
Static Constant SQL_DEBUG = 0
// See :https://msdn.microsoft.com/en-us/library/ms187819.aspx
// YYYY<sep>MM<sep>DD
StrConstant DATETIME_ISO_8601_DAY_SEP = "-"
StrConstant DATETIME_ISO_8601_TIME_SEP = "T"
StrConstant DATETIME_ISO_REGEX = "%d-%d-%dT%d:%d:%d.%d"

// Structure for easily generating (simple) queries
Structure QueryInf
	String Database,Table,ColumnStr
	// Type of query: Wave (must match column size) or parameter
	Variable QueryType
	// DataType of the query:
	Variable DataType
	// Different data types for the query. Wasteful, but very useful
	String StrValue
	Variable NumValue
	Wave WaveValue
	// What we append to the query
	String AppendToQuery
EndStructure

Static Function /S GetDb()
	return DB_NAME
End Function

Static Function SqlStmtSimple(mStatement)
	String mStatement
	SqlStmtGenericWaves(mStatement)
End Function

Static Function SqlStmtComposite(mStatement,mWaves)
	String mStatement
	String mWaves
	// Used for the 'pList' option, useful for tables with composite types (e.g. strings and ints)
	// mWaves mus be a semicolon-separated list of wave names. See the Sql Help File
	SqlStmtGenericWaves(mStatement,InWaves=mWaves)
End Function

Static Function SqlStmtGenericWaves(mStatement,[InWaves,OutWaves])
	String mStatement
	String InWaves,OutWaves
	Variable conn
	// SQLHighLevelOp Flags (see Sql Help.ihf in the help menu):
	// /O: overwrites if it exists
	// /PLST=<semicolon list>, specifies input waves matching in-order the "?" in the statemet
	// /Name=<semicolon list> specifies output waves from the columns
	if (!ParamIsDefault(InWaves))
		If (!ParamIsDefault(OutWaves))
			// both in and out waves
			SQLHighLevelOp /CSTR={CONNECT_STR,SQL_DRIVER_NOPROMPT} /O  /PLST=(InWaves) /Name=(OutWaves)mStatement
		else
			// just in waves
			SQLHighLevelOp /CSTR={CONNECT_STR,SQL_DRIVER_NOPROMPT} /O /PLST=(InWaves) mStatement 
		EndIf
	elseif (!ParamISDefault(OutWaves))
		SQLHighLevelOp /CSTR={CONNECT_STR,SQL_DRIVER_NOPROMPT} /O  /Name=(OutWaves) mStatement
	else
		// just a 'simple' statement: no ins or outs
		SQLHighLevelOp /CSTR={CONNECT_STR,SQL_DRIVER_NOPROMPT} /O mStatement	
	EndIf
	PrintSQLDiag(mStatement, V_flag, V_SQLResult, V_SQLRowCount, V_numWaves, S_waveNames, S_diagnostics)
End Function

Static Function GetTableNames(dbName,resultWave)
	String dbName
	Wave /T resultWave
	String stmt
	sprintf stmt,GetTableRegex,SCHEMA_NAME,dbName
	// /Q: quiet
	SQLHighLevelOp /CSTR={CONNECT_STR,SQL_DRIVER_NOPROMPT} /O stmt
	PrintSQLDiag(stmt, V_flag, V_SQLResult, V_SQLRowCount, V_numWaves, S_waveNames, S_diagnostics)
	// POST: S_Wavesnames should have (a single) tables. Copy it into th result value
	// index 0 is the first item. XXX check that it exists?
	String resultName = StringFromList(0,S_waveNames,SQL_WAVE_SEP)
	Wave /T mTmp = $resultName
	Duplicate /T/O mTmp,resultWave
	// Kill the old wave
	KillWaves /Z $resultName
End Function

Static Function /S ToSqlStr(mWave,AddQuotes,[sep])
	Wave /T mWave
	Variable addQuotes
	String sep
	if (ParamIsDefault(Sep))
		sep = SQL_QUERY_SEP
	EndIf
	Variable nItems = DImSize(mWave,0)
	Variable i=0
	String toRet = "", regex
	if (addQuotes)
		// add quotes, like for a literal string value
		regex ="'%s'"
	else
		regex = "%s"
	EndIf
	String tmp
	for (i=0; i< nItems; i+=1)
		sprintf tmp,regex,mWave[i]
		toRet += tmp
		// add a separator if we aren't at the end
		if (i < nItems-1)
			toRet += sep
		endIf
	EndFor
	return toRet
End Function

Static Function PrintSQLDiag(testTitle, flag, SQLResult, rowCount, numWaves, waveNames, diagnostics,[verbose])
	String testTitle
	Variable flag, SQLResult, rowCount, numWaves, verbose
	String waveNames, diagnostics
	// Print output variables
	verbose = ParamIsDefault(verbose) ? SQL_DEBUG : verbose
	If (verbose)
		Printf "%s: V_flag=%d, V_SQLResult=%d, V_SQLRowCount=%d, V_numWaves=%d, S_waveNames=\"%s\"\r", testTitle, flag, SQLResult, rowCount, numWaves, waveNames
	EndIf;
	if (strlen(diagnostics) > 0)
		Printf "Diagnostics: %s\r", diagnostics
	endif
End

Static Function ClearTable(mQuery)
	Struct QueryInf &mQuery
	String removeRowsStmt
	String db=mQuery.Database,table=mQuery.table
	sprintf removeRowsStmt,RemoveAllRegex,db,table
	SqlStmtSimple(removeRowsStmt)
	// POST: all rows are gone, reset the primary key
	String primaryKeyStmt
	sprintf primaryKeyStmt,ResetAutoIncrement,db,table
	SqlStmtSimple(primaryKeyStmt)
End Function

Static Function /S GetInsertString(mQuery,dataStr)
	Struct QueryInf &mQuery
	String dataStr
	sprintf dataStr,InsertValueRegex,mQuery.Database,mQuery.table,mQuery.ColumnStr,dataStr,mQuery.AppendToQuery
	return DataStr
End Function

Static Function /S WaveToColStr(mWave)
	Wave /T mWave
	return ModSqlUtil#ToSqlStr(mWave,ModDefine#False())
End Function

Static Function  GetLastInsertedID(mTab,mIdFieldNAme)
	// make a single-wave to get the ID
	// False: don't add quotes
	String mTab
	String mIdFieldNAme
	// first column is ID
	String mCol = "MAX(" + mIdFieldNAme + ")"
	// Select the maximum if from <db>.<tablename>
	// Note: this does *not* account for race conditions. should/could
	// come up with a smarter way of dealing with this.
	String mStatement
	sprintf mStatement,SimpleSelectRegex,mCol,GetDb(),mTab
	String mOutWave = "tmpID" + mTab 
	SqlStmtGenericWaves(mStatement,outWaves=mOutWave + SQL_WAVE_SEP)
	Wave mWave = $mOutWave
	Variable toRet = mWave[0]
	KillWaves /Z mWave
	return toRet
End 

Static Function InsertValue(mQuery)
	Struct QueryInf &mQuery
	String mStatement
	// XXX check if wave or not, then put in question marks if so.
	// For now, just assume parameters...
	String mDataStr
	Switch (mQuery.DataType)
		case QUERY_DATA_NUM:
			mDataStr = num2str(mQuery.NumValue)
			break
		case QUERY_DATA_STR:
			mDataStr = mQuery.StrValue
			break
	EndSwitch
	 mStatement = GetInsertString(mQuery,mDataStr)
	// POST: mData has the string we want.
	// POST: mStatement is formatted correctly
	 return SqlStmtSimple(mStatement)
End Function

Static Function InsertStringRow(mTab,mCols,mVals)
	// inserts each of mCols, assuming it is a literal string.
	String mTab
	Wave /T mCols
	Wave /T mVals
	// add the literal quotes
	String strValue= ModSqlUtil#ToSqlStr(mVals,ModDefine#True())
	// Kill the waves we made. This is against passing is ownership, but extremely useful
	InsertFormatted(mTab,mCols,strValue)
End Function

Static Function InsertFormatted(mTab,mCols,strVal,[appendString])
	String mTab
	Wave /T mCols
	String strVal
	String appendString
	if (ParamIsDefault(appendString))
		appendString = SQL_EMPTY_APPEND
	EndIf
	// sets up the query, makes the insert. *kills whatever is in mCols or mVals*
	Struct QueryInf mQuery
	ModSqlUtil#InitQueryWithKnownStr(mQuery,mTab,mCols,strVal,appendString=appendString)
	// POST: mQuery is set up, exeute it 
	Variable toRet = ModSqlUtil#InsertValue(mQuery)
	return toRet
End Function

Static Function InitQuery(mQuery,mTab,[appendString])
	Struct QueryInf &mQuery
	String mTab
	String appendString
	if (ParamIsDefault(appendString))
		appendString = SQL_EMPTY_APPEND // append nothing
	EndIf
	// Assuming the Database is the standard one.
	mQuery.Table = mTab
	mQuery.Database = ModSqlUtil#GetDb()
	mQuery.AppendToQuery = appendString
End Function

Static Function InitQueryWithKnownStr(mQuery,mTab,mCols,mVals,[appendString])
	Wave /T mCols
	String mTab,mVals
	Struct QueryInf &mQuery
	String appendString
	if (ParamIsDefault(appendString))
		appendString = SQL_EMPTY_APPEND
	EndIf
	InitQuery(mQuery,mTab,appendString=appendString)
	// Next, we make the actual column strings.
	// Dont add quotes to the column
	mQuery.ColumnStr = ModSqlUtil#ToSqlStr(mCols,MOdDefine#False())
	mQuery.StrValue = mVals
	// This is a string query
	mQuery.DataType = QUERY_DATA_STR	
End Function

Static Function ColIsDate(col)
	String col
	// lieraal (?i) means case insensitive ( V-244, GrepString)
	// after that, match maybe anyting (.*), followed by time or date, followed by anything
	return GrepString(col,"(?i).*(?:Time|Date).*")
End Function

Static Function SelectComposite(mTab,mCols,mWaves,appendStmt)
	String mTab
	Wave /T mCols
	Wave /T mWaves
	String appendStmt
	// get the proper lists for the columns and waves. *dont* include literal quotes (hence, false)
	// Need to convert datetimes, because igor SUCKS and will get a string datetime as a double,
	// but it must be inserted as a string. converting to a string here.
	Variable n=Dimsize(mCols,0)
	Make /O/T/N=(n) tmpWaves
	tmpWaves[] = "w" + num2str(p)
	String columnStr = ModSqlUtil#ToSqlStr(mCols,ModDefine#False())
	String waves= ModSqlUtil#ToSqlStr(tmpWaves,ModDefine#False(),sep=SQL_WAVE_SEP) + SQL_WAVE_SEP
	String mStatement
	sprintf mStatement,SimpleSelectRegex,columnStr,GetDb(),mTab
	mStatement += " " + appendStmt
	SqlStmtGenericWaves(mStatement,Outwaves=waves)
	// POST: need to duplicate back al the waves
	Variable i
	for (i=0; i<n; i+=1)
		String mWaveDest = mWaves[i]
		Wave mWaveData = $(tmpWaves[i])
		if (ColIsDate(mCols[i]))
			Wave /T mTextWave = $mWaveDest
			Variable nTmpWave =DimSize(mWaveData,0)
			Redimension /N=(nTmpWave) mTextWave	
			// index using the p notaiton along all of mTextWave
			if (nTmpWave > 0)
				mTextWave[]  = ToSqlDate(mWaveData[p])
			EndIf
		else
			Duplicate /O mWaveData,$mWaveDest
		EndIf
		KillWaves mWaveData
	EndFor
End Function

// Selects columnStr from mTab, conditioned on mColWhere having value mValWhere
// Note: assumes variable are doubles.
Static Function SelectSimpleWhereStmt(mTab,columnStr,mColWhere,mWaveList,[mValWhere,mStrWhere])
	String mTab,columnStr,mColWhere,mStrWhere
	String mWaveList // Where the columns will go. Must be semi colon separated
	Variable mValWhere
	if (ParamIsDefault(mValWhere) && ParamIsDefault(mStrWhere))
		// Cant have both be null
		MOdErrorUtil#DevelopmentError()
	EndIf
	// POST: only one is null
	String mStatement
	sprintf mStatement,SimpleSelectRegex,columnStr,GetDb(),mTab
	String toAdd
	String mFmt
	// ValEq is the -stringified- version of whatever we are adding
	String ValEq
	if (ParamIsDefault(mValWhere))
		// then use the string
		// add quotes on the %s
		ValEq = "'" + mStrWhere + "'"
	Else
		// use the number
		ValEq = num2str(mValWhere)
	EndIf
	mFmt=" WHERE %s=%s"
	sprintf toAdd,mFmt,mColWhere,ValEq
	mStatement += toAdd
	// Execute the statement
	SqlStmtGenericWaves(mStatement,Outwaves=mWaveList)
End Function

Static Function DeleteById(mTab,mColId,mIdVals)
	String mTab,mColId
	Wave mIdVals
	String StmtRegex = "Delete from %s.%s where %s in %s"
	Variable n=DimSize(mIdVals,0)
	Variable i
	if (n ==0)	
		// no Ids specified, good to go
		return ModDefine#True()
	EndIF
	// POST: something to delete
	// Pattern is a comma sepearated list of Ids, enclosed in parentehsis
	String idRegex = "("
	for (i=0; i<n; i+=1)
		IdRegex  += num2str(mIdVals[i])
		// add a comma to everything except the end
		if (i != n-1)
			idRegex += ","
		EndIf
	EndFor
	idRegex += ")"
	// POST: idRegex has the string we want
	String mStmt
	// Pattern is <database>.<tab> where <idCol> in <list>
	sprintf mStmt,StmtRegex,getDb(),mTab,mColId,idRegex
	// Execute the sttement
	SqlStmtGenericWaves(mStmt)
End Function

Static Function InsertComposite(mTab,mCols,mWaves,[mVals])
	String mTab
	Wave /T mWaves
	Wave /T mCols
	Wave /T mVals
	Struct QueryInf mQuery
	InitQuery(mQuery,mTab)
	// XXX check all the same size
	if (ParamIsDefault(mVals))
		// Then assume we are all question marks
		Variable n = DimSIze(mCols,0)
		Make /O/N=(n)/T mVals
		mVals[0,n-1] = "?"
	EndIf
	// POST: mVals exists
	String strVal = ModSqlUtil#ToSqlStr(mVals,ModDefine#False())
	mQuery.ColumnStr = ModSqlUtil#WaveToColStr(mCols)
	String stmt = ModSqlUtil#GetInsertString(mQuery,strVal)
	String waves= ModSqlUtil#ToSqlStr(mWaves,ModDefine#False(),sep=SQL_WAVE_SEP)
	ModSqlUtil#SqlStmtComposite(stmt,waves)
	// kill all the waves, clean up after ourselves
	Variable i
	for (i=0; i<n; i+= 1)
		// mWaves[i] referes to a wave with the i-th parameter.
		KillWaves /Z $mWaves[i]
	EndFor
	KillWaves /Z mWaves,mCols,mVals
End Function

Static Function /S ToSqlDate(secs)
	Variable secs
	String TimeStr = ModIoUtil#SecsToTime(secs)
	String DateStr = ModIoUtil#SecsToDate(secs,sep=DATETIME_ISO_8601_DAY_SEP)
	// Follows the ISO8601 format. 
	// https://msdn.microsoft.com/en-us/library/ms187819.aspx
	return DateStr + DATETIME_ISO_8601_TIME_SEP + TimeStr
End Function

Static Function /S ToSqlDateComposite(year,month,day,[hour,minute,second,fraction])
	Variable year,month,day,hour,minute,second,fraction
	hour = ParamIsDefault(hour) ? 0 : hour
	minute = ParamIsDefault(hour) ? 0 : minute
	second = ParamIsDefault(second) ? 0 : second
	fraction = ParamIsDefault(fraction) ? 0 : fraction
	// POST: everything is non-default
	Variable secs = ModIoUtil#DateFmtToSecs(year,month,day,hour,minute,second,fraction)
	return ToSqlDate(secs)
End Function

// Function for easily making columns. Bit of a bandaid. should format like <doubles>,<strings>,<ids>
Static Function /S GetRepeatFmt(Num,Fmt,[Sep])
	Variable Num
	String Fmt,Sep
	if (ParamIsDefault(Sep))
		Sep = SQL_QUERY_SEP
	EndIF
	Variable i
	String toRet = ""
	for (i=0; i<Num; i+= 1)
		toRet += Fmt
		// Add the separator, if there are more
		if (i <Num-1)
			toRet += Sep
		EndIf
	EndFor
	return toRet
End Function

Static Function /S GetWaveListFromSingle(mWave)
	Wave mWave
	return NameOfWave(mWave) + SQL_WAVE_SEP
End Function

// Finds the ID of mTab, conditions where the (unique) column 'colWhere' takes the
// value 'valwhere'. returns true or false if there is such an ID, and sets 'idToSetIfExists'
// if it does exist.
Static Function GetUniqueIdWhereColIsVal(mTab,colWhere,valWhere,idToSetIfExists)
	String mTab,colWhere,valWhere
	Variable & idToSetIfExists // pass by *reference*
	Make /O/N=0 mIds
	Wave /T myCols = ModSqlCypherAutoDefines#GetColByTable(mTab)
	String myIdCol = myCols[0]
	String mWavesForSqlModel = ModSqlUtil#GetWaveListFromSingle(mIds)
	SelectSimpleWhereStmt(mTab,myIdCol,colWhere,mWavesForSqlModel,mStrWhere=valWhere)	
	// POST: mIds should be 
	if (DImSize(mIds,0) == 0)
		// Didn't find anything; fatal error
		return ModDefine#False()
	elseif (DimSize(mIds,0) == 1)
		// exactly one column; set idToSetIfExists
		idToSetIfExists = mIds[0]
		return ModDefine#True()
	Else
		// more than one ID; this should happen, should only be zero or one.
		ModErrorUtil#DevelopmentError(description="Found more than one ID for a column")
		// wont ever reach here..
		return ModDefine#False()
	EndIF
End Function


// Convert from a sql string to an igor format
Static Function ToSecsFromSql(mStr)
	String mStr
	String mRegex = "(\d+)/(\d+)/(\d+)T(\d+):(\d+):(\d+).(\d+)"
	String yearStr,monStr,dayStr,hourStr,minuteStr,secStr,fracStr
	SplitString /E=(mRegex) mStr, yearStr,monStr,dayStr,hourStr,minuteStr,secStr,fracStr
	Variable year=str2num(yearStr),mon=str2num(monStr),day=str2num(dayStr)
	Variable hour=str2num(hourStr),minute=str2num(minuteStr),mSec=str2num(secStr)
	Variable frac = str2num(fracStr)
	Variable secs = ModIoUtil#DateFmtToSecs(year,mon,day,hour,minute,mSec,frac)
	return secs
End Function

