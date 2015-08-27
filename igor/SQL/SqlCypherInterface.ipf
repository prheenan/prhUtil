// Use modern global access method, strict compilation
#pragma rtGlobals=3	
//
// *note*: you must call "InitSqlModule" for this module to work correctly
//
#pragma ModuleName = ModSqlCypherInterface
// XXX add in connection support? should speed up.
#include ":SqlUtil"
#include "::Util:IoUtil"
#include "::Util:ErrorUtil"
#include "::Util:DataStructures"
#include ":SqlCypherAutoDefines"

// Defaults for each type, for the setters
StrConstant SQL_DEF_NAME = "<Name>"
StrConstant SQL_DEF_DESC = "<Description>"
StrConstant SQL_DEF_STR = "<Default>"
// Defaults for numeric / id 
Constant SQL_DEF_NUMERIC = 0
Constant SQL_DEF_ID = -1
// Bad ID: can't be 0
Constant SQL_BAD_ID  = 0

Static Function /S SQL_DEF_DATE()
	return ModSqlUtil#ToSqlDate(DateTime)
End Function

Structure SqlHandleObj
	String mTableName
EndStructure

Structure SqlDescrObj
	String name
	String description
	// XXX add in date, more information?
EndStructure

Static StrConstant SQL_BASE_DIR = "root:Packages:Sql"
Static StrConstant SQL_TABLE_DIR_FROM_BASE = "Tab"
Static StrConstant SQL_ID_WAVE_FROM_BASE = "Ids"

Static Function /S GetTableGlobalDir()
	String TableDir = ModIoUtil#AppendedPath(SQL_BASE_DIR,SQL_TABLE_DIR_FROM_BASE)
	return TableDir
End Function

Static Function /S GetIdWavePath()
	return ModIoUtil#AppendedPath(GetTableGlobalDir(),SQL_ID_WAVE_FROM_BASE)
End Function

Static Function /S GetTableSpecificDir(mTab)
	String mTab
	return ModIoUtil#appendedPath(GetTableGlobalDir(),mTab)
End Function

Static Function /S GetFieldWaveName(mTab,mField)
	String mTab,mField
	return ModIoUtil#appendedPath(GetTableSpecificDir(mTab),mField)
End Function

Static Function /S GoToTableDirGetOriginal(mTab)
	String mTab
	String toRet = ModIoUtil#cwd()
	String mDir =(GetTableSpecificDir(mTab)) 
	SetDataFolder mDir
	return toRet
End Function

Static Function GetIdOfRowAtIndex(mTab,index)
	String mTab
	Variable index
	// First, get the name of the ID
	Wave /T mFieldsForID = ModSqlCypherAutoDefines#GetColByTable(mTab)
	// Next, get just the ID field (assumed the first)
	// XXX check we are in range?
	String mIDName = mFieldsForID[0]
	// Get the path to the wave
	String mIDRef = GetFieldWaveName(mTab,mIdName)
	ModErrorUtil#WaveExistsOrError(mIDRef)
	// POST: wave exists
	Wave mIdWave = $(mIDRef)	
	Variable n = DimSize(mIdWave,0)
	ModErrorUtil#AssertLT(index,n)
	// POST: index < n
	KillWaves /Z mFieldsForID
	return mIdWave[index]
End Function

Static Function ReturnToOriginal(orig)
	String orig
	SetDataFolder(orig)
End Function

// Get the global id structure
Static Function LoadGlobalIdStruct(mStruct)
	Struct SqlIdTable & mStruct
	String mPath = GetIdWavePath()
	ModSqlCypherAutoDefines#GetIdTable(mStruct,mPath)
End Function

// Set the global Id structure
Static Function SaveGlobalIdStruct(mStruct)
	Struct SqlIdTable & mStruct
	String mPath = GetIdWavePath()
	ModSqlCypherAutoDefines#SetIdTable(mStruct,mPath)
End Function

// This function should be called before any of the sql functions are used.
Static Function InitSqlModule()	
	// Set up all the datafolders
	InitSqlDataFolders()
	// Set up a blank sql ID table
	// (ie: write the wave)
	Struct SqlIdTable mStruct
	SaveGlobalIdStruct(mStruct)
	InitSqlLocalWaveTables()
	// Determine the 'starting' values for all the non-dependent
	// sql tables
	GetStartingValues()
End Functi


Static Function NumDependencies(tableName)
	String tableName
	Wave /T Dep = ModSqlCypherAutoDefines#getDependencies(tableName)
	Variable size = DimSize(Dep,0)
	Killwaves Dep
	return size
End Function

Static Function NoDependencies(tableName)
	String tableName
	return  NumDependencies(tableName) == 0
End Function


Static Function HasIdSet(SqlIdTable,tableName)
	Struct SqlIdTable & SqlIdTable
	String tableName
	// In Sql, no ID is less  than 0 (XXX TODO: make initialization, set id to -1?)
	return ModSqlCypherAutoDefines#GetId(SqlIdTable,tableName) > 0
End Function

// are *either* there no dependencies, or all the dependencies have
// been set?
Static Function DependenciesCleared(tableName,mStruct)
	String tableName
	Struct SqlIdTable & mStruct
	Wave /T Dep = ModSqlCypherAutoDefines#getDependencies(tableName)
	Variable nPoints = DimSize(Dep,0)
	if (nPoints == 0)
		return ModDefine#True()
	EndIf	
	// POST: at least one thing to check
	// Get the ID structure to see if everything is set
	// determine which of the Ids AreSet (same number of dependencies)
	Make /O/N=(nPoints) mIdsSet
	// Use p notation to slice mIdsSet
	mIdsSet[] = HasIdSet(mStruct,Dep[p])
	// Assuming 1 is true and 0 is false, should
	// sum to nPoints if everything is cleared.
	return (sum(mIdsSet) == nPoints)
End Function

Static Function ClearTable(mTab)
	String mTab
	Wave /T mCols = ModSqlCypherAutoDefines#GetColByTable(mTab)
	Wave mTypes =ModSqlCypherAutoDefines#GetTypesByTable(mTab)
	Variable i,n = DimSize(mCols,0)
	String mName 
	for (i=0; i<n; i+=1)
		mName = GetFieldWaveName(mTab,mCols[i])
		if (WaveExists($mName))
			Wave mWave = $mName
			// Delete all points of the wave
			Deletepoints 0,Inf,mWave
		EndIf
	EndFor
End Function

// Set the id of mTable to the value, then check for dependency updates
// If newId is true, then clears out the dependencies, then updated the vview
// if newId is false, then selecrtss new data for the dependences, then updates the view
// defaults to newID is false ('safer', but slower -- always gets the correct information)
Static Function UpdateDependenciesFromSql(mTable,mIDs,[newID])
	// Check if we are cleared after
	String mTable
	Struct SqlIdTable & mIds
	Variable newID
	newId = ParamIsDefault(newID) ? ModDefine#False(): newId
	Wave /T mDependencies = ModSqlCypherAutoDefines#GetWhatDependsOnTable(mTable)
	Variable i, n=DimSize(mDependencies,0)
	for (i=0; i<n; i+=1)
		String mTmpTable = mDependencies[i]
		if (newID)
			// Clear *all* dependencies
			ClearTable(mTmpTable)		
		else
			// Select into only *cleared* dependencies			
			if (	DependenciesCleared(mTmpTable,mIds))
				SelectIntoLocalWaveStructs(mTmpTable,mIds)	
			EndIf
		endIf
	EndFor
	KillWaves /Z tmpAllTable,clearedBefore,clearedAfter,mDependencies
End Function

Static Function /S GetIdNameOfTable(mTab)
	String mTab
	return "id" + mTab
End Function

// Get the where statement based on the current IDs
// PRE: must have set id structure.
Static Function /S GetWhereStmtBasedOnDependencies(mTab,mStruct)
	String mTab
	Struct SqlIdTable & 	mStruct	
	String toRet =""
	Wave /T mDep = ModSqlCypherAutoDefines#GetDependencies(mTab)
	Variable i, n=DimSize(mDep,0)
	String tmp,mFormat = "%s.%s=%d ",tmpDependency
	// get all the tables needed
	for (i=0; i<n; i+=1)
		// start with a "WHERE"
		if (i ==0 )
			toRet += "WHERE "
		EndIf
		tmpDependency= mDep[i]
		sprintf tmp,mFormat,mTab,GetIdNameOfTable(tmpDependency),ModSqlCypherAutoDefines#GetId(mStruct,tmpDependency)
		toRet += tmp
		// add 'and' statements to brige
		if (i != n-1)
			toRet += "AND "
		EndIf
	Endfor
	return toRet
End Function

// populates the local waves for mtab by making a sql call.
Static Function SelectIntoLocalWaveStructs(mTab,toUse)
	String mTab
	Struct SqlIdTable & toUse
	// Get all the columns for this wave
	Wave /T mCols =  ModSqlCypherAutoDefines#GetColByTable(mTab)
	Variable nCols = DimSize(mCols,0)
	// Get all the locations we will output to
	Make /T/O/N=(nCols) mOutWaves
	mOutWaves[] =  GetFieldWaveName(mTab,mCols[p])	
	// Select all of 'mCols' from table 'mTab' into mOutWaves, putting the result in the table
	// specicifc directory. no where statement
	String WhereStmt  = GetWhereStmtBasedOnDependencies(mTab,toUse)
	 SelectIntoWaves(mTab,mCols,mOutWaves,ModDefine#True(),WhereStmt)
	 KillWaves /Z mCols,mOutWaves
End for

// Get all the starting values for waves without dependencies
// PRE: SqlIdTable must exist
Static Function GetStartingValues()
	Wave /T tmpAllTable = ModSqlCypherAutoDefines#getAllTables()
	// determine which tables have no dependencies
	// O: overwrite destination
	Extract /O/T tmpAllTable, tmpNoDependencies,NoDependencies(tmpAllTable)
	// POST: tmpNoDependencies has all of the tables we need to populate using SQL.
	Variable nPreProp = DimSize(tmpNoDependencies,0)
	Variable i
	Wave /T mCols
	String mTab
	// Get the starting sql id table
	Struct SqlIdTable mStruct
	LoadGlobalIdStruct(mStruct)
	// Loop through each pre-populatable table, get all the waves we neeed.
	for (i=0; i<nPreProp;i +=1)
		// Get out table name
		mTab = tmpNoDependencies[i]
		SelectIntoLocalWaveStructs(mTab,mStruct)
	EndFor
	KillWaves tmpAllTable,tmpNoDependencies
End Function

// Function to set up each wave recquired for all the tables
// (ie: local wave copies)
Static Function InitSqlLocalWaveTables()
	Wave /T tmpAllTable = ModSqlCypherAutoDefines#getAllTables()
	// for each table, create all of the recquire waves
	Variable i,j, nTab=DImSize(tmpAllTable,0),nFields
	String mTab,mField, mFieldWaveToInit
	Wave /T mFields
	Wave mTypes
	for (i=0; i<nTab; i+=1)
		mTab = tmpAllTable[i]
		// get the fields and type
		Wave /T mFields =  ModSqlCypherAutoDefines#GetColByTable(mTab)
		Wave mTypes =  ModSqlCypherAutoDefines#GetTypesByTable(mTab)
		nFields = DimSize(mFields,0)
		// Loop through each field, make sure all the wave exist.
		for (j=0; j<nFields; j+=1)
			mField = mFields[j]
			mFieldWaveToInit = GetFieldWaveName(mTab,mField)	
			// initialize the wave, depending on its type (numeric/string)	
			// V-375
			switch (mTypes[j])
				// double
				case SQL_PTYPE_DOUBLE:
				// NOTE: date *cannot* be stored except as a double from queries:
				// see: "Date/Time Data", SQL Help.ihf (pp20)
				// So, we store as double (ugh) immediately convert for user purposes...
					Make /O/D $mFieldWaveToInit
				// unsigned (/U) integers (/I)
				case SQL_PTYPE_INT:
				case SQL_PTYPE_FK:
				case SQL_PTYPE_ID:
					Make /O/I/U $mFieldWaveToInit
					break
				// text
				case SQL_PTYPE_DATE:
				case SQL_PTYPE_NAME:
				case SQL_PTYPE_DESCR:
				case SQL_PTYPE_GENSTR:
					Make /O/T $mFieldWaveToInit
					break
				break
			EndSwitch 
		EndFor
		// Kill the waves we just made
		KillWaves /Z mFields,mTypes
	EndFor
	KillWaves /Z tmpAllTable
End Function

// function to create the folder hierarchy for all the tables
Static Function InitSqlDataFolders()
	ModIoUtil#EnsurePathExists(SQL_BASE_DIR)
	// # POST: the basic direcotry exists
	String TableDir = GetTableGlobalDir()
	ModIoUtil#EnsurePathExists(TableDir)
	// # POST: the tables dir exists
	// Go through each table and create a separate directory for it
	Wave /T mTables = ModSqlCypherAutoDefines#getAllTables()
	Variable nTables = DimSize(mTables,0)
	Variable i
	String tmpDir
	for (i=0;i<nTables; i+=1)
		tmpDir = GetTableSpecificDir(mTables[i])
		ModIoUtil#EnsurePathExists(tmpDir)
	EndFor
	KillWaves /Z mTables
End Function

// Get the user-settable tables
Static Function /Wave GetGuiTables()
	Make /O/T GuiTables = {TAB_MolType,TAB_MoleculeFamily,TAB_Sample,TAB_SamplePrep,TAB_TipManifest,TAB_TipPack,TAB_TipPrep,TAB_TipType,TAB_TraceRating,TAB_User}
	return GuiTables
End Function

// function to select 'mCols' from table 'mTab' into 'mOutWaves'. If 'SaveInTabFolder'
// is true, then switches to the table folder and back. Appends 'WhereStatement' to end
// Note: kills all input waves
Static Function SelectIntoWaves(mTab,mCols,mOutWaves,SaveInTabFolder,WhereStmt)
	String mTab
	Wave /T mCols
	Wave /T mOutWaves
	Variable SaveInTabFolder
	String WhereStmt
	if(SaveInTabFolder)
		// Then we need to move to the table-specific directory
		String originalDir=GoToTableDirGetOriginal(mTab)
	EndIf
	Variable nOut = DimSize(mOutWaves,0)
	Make /O/T/N=(nOut) localOut
	// convert the 'full path' name to a local reference
	localOut[0,nOut-1] = ModIoUtil#GetFileName(mOutWaves[p])
	ModSqlUtil#SelectComposite(mTab,mCols,localOut,WhereStmt)
	if(SaveInTabFolder)
		// Move back to whatever directory
		ModSqlCypherInterface#ReturnToOriginal(originalDir)
		// Change the names 
	EndIf
	KillWaves /Z mCols,mOutWaves,localOut
End Function

// Function to get a list of sql waves (input or output)
// for use in a sql statement.
Static Function /S GetSqlListFromWaves(input,[Sep])
	Wave /T input
	String Sep
	if (ParamIsDefault(Sep))
		Sep = SQL_WAVE_SEP
	EndIf	
	return ModSqlUtil#ToSqlStr(input,ModDefine#False(),Sep=Sep)
End Function

Static Function /S GetPathFromWave(mWave)
	Wave mWave
	return ModIoUtil#GetPathToWave(mWave)
End Function

Static Function /Wave SqlWaveRef(mWave)
	String mWave
	// Get the original dir (for returning), and the directory / wave name
	String original = ModIoUtil#cwd()
	String waveDir = ModIoUtil#GetDirectory(mWave)
	String mWaveName = ModIoUtil#GetFileName(mWave)
	SetDataFolder (waveDir)
	// POST: in the right data folder
	// Ensure the wave exists
	ModErrorUtil#WaveExistsOrError(mWaveName)
	// POST: wave exists
	Wave ToRet = $(mWaveName)
	SetDataFolder (original)
	return toRet
End Function

Static Function ConvertToTextWave(mWave,textWave)
	Struct UserWaveStr & mWave
	Struct UserWaveRef & textWave
	Wave /T textWave.Name = SqlWaveRef(mWave.Name)
	Wave textWave.idUser = SqlWaveRef(mWave.idUser)
End Function

Static Function AddToFIeldWaveGen(mWaveRef,isNum,strToAdd,numToAdd)
	String mWaveRef,strtoAdd
	Variable isNum,numToAdd
	// Get the wave reference to whatever field we are adding to.
	// Ensure the wave exists
	if (!WaveExists($mWaveRef))
		if (!isNum)
			Make /T/O/N=0 $mWaveRef
		else
			Make /D/O/N=0 $mWaveRef
		EndIF
	EndIf
	// POST: wave 'mWaveRef' Exists. Add a single point, which we populate
	Variable nPoints = DimSize($mWaveRef,0) // Add at the very end (before point N+1)
	Variable nToAdd = 1
	// Because even igor's waves cant be typed in a reasonable way,
	// we have to have both breaks in a different loop
	if (!isNum)
		Wave /T tmpRefStr =$mWaveRef 
		Redimension /N=(nPoints+1) tmpRefStr
		// add at index N (point N+1)
		tmpRefStr[nPoints] = strToAdd
	else
		Wave tmpRefNum =$mWaveRef 
		Redimension /N=(nPoints+1) tmpRefNum
		tmpRefNum[nPoints] = numToAdd
	EndIf
	KillWaves /Z tmpNumAdd,tmpStrAdd
End Function

Static Function AddToFIeldWaveTxt(mWave,strtoAdd)
	String mWave,strtoAdd
	// Get the wave reference
	// False: not a num referene
	AddToFIeldWaveGen(mWave,ModDefine#False(),strToAdd,ModDefine#False())
End Function

Static Function AddToFIeldWaveNum(mWave,numToAdd)
	String mWave
	Variable numToAdd
	// True: is numeric
	AddToFIeldWaveGen(mWave,ModDefine#True(),"",numToAdd)
End Function

// Returns if sqlType is in one of the numeric types.
// useful for dynamic GUI generation
Static Function IsNumericType(sqlType)
	Variable SqlType
	return (sqlType == SQL_PTYPE_INT || sqlType == SQL_PTYPE_DOUBLE || sqlType == SQL_PTYPE_FK || sqlType == SQL_PTYPE_ID)
End Function

// Returns true /false if it does /doesnt find a match in mIdNAme
// If true, sets tableName (pass by *reference*
Static Function IdNameToTableName(mIdName,tableName)
	String mIdName
	String & tableName
	String mRegex = "id(\w+)$"
	if (GrepString(mIdName,mRegex))
		SplitString /E=(mRegex) mIdName,tableName
		return ModDefine#True()
	EndIf
	return ModDefine#False()
End Function

Static Function GetCurrentForeignKey(mFieldName)
	// uses 'mFieldName' to get the id for the relevant table.
	// PRE: mFieldName goes like 'id<table>', where table is where the
	// foreign key comes from
	String mFieldName
	String mTabName
	// Get the table from from the foreign key name
	if (IdNameToTableName(mFieldName,mTabName))
		// then mTabNAme is set
		// Get the ID structure
		Struct SqlIdTable mStruct 
		LoadGlobalIdStruct(mStruct)
		// return the current foreign key
		return ModSqlCypherAutoDefines#GetId(mStruct,mTabName)
	Else
		String mErr
		sprintf mErr,"Couldn't find proper id in field [%s]\n",mFIeldName
		ModErrorUtil#DevelopmentError(description=mErr)
	EndIf
End Function

// Gets the default value for a single type. may need the name, in order to 
// reference a foreign key/table. Note: tmpNum and tmpStr are pass by *reference*
Static Function GetDefault(mType,mName,tmpNum,tmpStr)
	Variable mType,&tmpNum
	String mName,&tmpStr
	// pick out the default, depending on the sql type
	// and possible the name (ie: if we are a foreign key)
	switch (mType)
		//
		// String Types
		//
		case SQL_PTYPE_DATE:
			tmpStr = SQL_DEF_DATE()
			break
		case SQL_PTYPE_NAME: 
			tmpStr = SQL_DEF_NAME
			break
		case SQL_PTYPE_DESCR: 
			tmpStr = SQL_DEF_DESC
			break
		case SQL_PTYPE_GENSTR:
			tmpStr = SQL_DEF_STR
			break
		//
		// numeric types
		//
		// Int and double are the same
		case SQL_PTYPE_INT:
		case SQL_PTYPE_DOUBLE:
			tmpNum = SQL_DEF_NUMERIC
			break
		case SQL_PTYPE_FK:
			tmpNum = GetCurrentForeignKey(mName)
			break
		case SQL_PTYPE_ID:
			// Primary key
			tmpNum = SQL_DEF_ID
			break
		default:
			// couldn't identify the types
			String mErr
			sprintf mErr,"Couldn't find SQL type [%d] for field [%s]\n",mType,mName
			ModErrorUtil#DevelopmentError(description=mErr)
	EndSwitch
End Function

Static Function IsEditable(mType)
	Variable mType
	// IDs and foreign keys are *not* editable or specifiable
	return (mType != SQL_PTYPE_ID && mType != SQL_PTYPE_FK)
End Function

Static Function GetSqIEditable(mTypes,mEditable)
	Wave mTypes
	Wave mEditable
	Variable n= DimSize(mTypes,0)
	// XXX check that mEditable is the right size
	// Set each array eleement appropriately
	mEditable[0,n-1] = IsEditable(mTypes[p])
End Function

// Gets the defaults for 'mName' and 'mType', putting the reults for 
// element [i] in either mDefStr or mDefNum, depdending on if 
// the type is a numeric or a string
Static Function GetSqlDefaults(mNames,mTypes,mDefStr,mDefNum)
	Wave /T mNames, mDefStr
	Wave mTypes, mDefnum
	// XXX check that sizes match?
	Variable n=DimSize(mTypes,0)
	Variable i
	Variable tmpNum
	String tmpStr
	for (i=0; i<n; i+=1)
		tmpNum = 0
		tmpStr = ""
		Variable tmpType = mTypes[i]
		// Set (by reference) tmpNUm and tmpStr
		GetDefault(tmpType,mNames[i],tmpNum,tmpStr)
		// POST: tmpNum and tmpStr are set, go ahead and set them
		mDefStr[i] = tmpStr
		mDefNum[i] = tmpNum
	EndFor
End Function


Static Function /S GetDescrIfExists(tabName,index)
	String tabName
	Variable index
	String mDescPath = GetFieldWaveName(tabName,FIELD_Description)
	Wave /T mDescWave = $mDescPath
	if (WaveExists($mDescPath))
		Wave /T mDescWave = $mDescPath
		return mDescWave[index]
	else
		return ""
	EndIf
End Function

// Get the name and description of 'index'-th element of the
// global sql struct. Throws errors if anythin is wrong.
// Note: will *only* work on tables with names and descriptions defined.
Static Function GetNameDescr(tabName,mDesc,index)
	String tabName
	Struct SqlDescrObj & mDesc
	Variable index
	String mNamePath = GetFieldWaveName(tabName,FIELD_Name)
	ModErrorUTil#WaveExistsOrError(mNamePath)
	// POST: name and description exist
	Wave /T mNameWave =$mNamePath
	// Check that they are the same length
	Variable n1 = DimSize(mNameWave,0)
	// POST: n1 == n2. Just use n1.
	// Check that the index is in range
	ModErrorUtil#AssertLT(index,n1)
	// POST: index is in range, wave exists
	String mNameStr = mNameWave[index]
	String mDescStr =  GetDescrIfExists(tabName,index)
	mDesc.name = mNameStr
	mDesc.description = mDescStr
	// POST: mDesc is correct.
End Function

Static Function /S GetFormattedStr(mStr,mNum,mTypes)
	Wave /T mStr
	Wave mNum,mTypes
	Variable i
	Variable n  = DimSize(mNum,0)
	String toRet ="", tmp
	for (i=0; i<n; i +=1)
		if (IsNumericType(mTypes[i]))
			sprintf tmp,"%.15g",mNum[i]
		Else
			sprintf tmp,"'%s'",mStr[i]
		EndIf
		toRet += tmp 
		// Add the separator if there are more.
		if (i < n-1)
			toRet += SQL_QUERY_SEP
		EndIf
	EndFor
	return toRet
End Function

Static Function /S GetMenuDefaults(mTab)
	String mTab
	return "None Selected" + LISTBOX_SEP_ITEMS
End Function

// Handle a general menu (ie: get the things to display in the menu)
Static Function /S HandleMenu(mTab)
	String mTab
	String mSep = LISTBOX_SEP_ITEMS // popupmenu recquires a semicolon
	String mNamePath = GetFieldWaveName(mTab,FIELD_Name)
	// Checking the list population
	Variable mTime = dateTime
	String toRet = GetMenuDefaults(mTab)
	if (!WaveExists($mNamePath))
		return toRet
	EndIF	
	// POST: wave exists. Start toRet over.
	Wave /T mNames = $mNamePath
	Variable n = DimSize(mNames,0)
	Variable i
	Struct SqlDescrObj mDesc
	String tmp
	for (i=0; i<n; i+=1)
		GetNameDescr(mTab,mDesc,i)
		sprintf tmp,"%s:%s%s",mDesc.name,mDesc.description,mSep
		toRet += tmp
	EndFor
	return toRet
End Function

// Handle one of the add functions
// Note: does *not* set the ID, as the downstream functions will do that
Function AddToSqlHandler(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	//POST: mTab is populated with all fields of LinkExpModel
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = mHandler.mTableName
	String pathToField,mField
	// Get the columns
	Wave /T mCols =ModSqlCypherAutoDefines#GetColByTable(tabName)
	Wave mTypes = ModSqlCypherAutoDefines#GetTypesByTable(tabName)
	// For insertion and deletion, just want after the id, which we assume is first
	Variable idxID = 0
	// /O: overwrite
	// /T: text
	// /R: slice indices to copy
	Duplicate /O/T/R=[idxID+1,Inf] mCols, mColsWithoutId
	Duplicate /O/R=[idxID+1,Inf] mTypes,mTypesWithoutId
	Duplicate /O/T/R=[idxID+1,Inf] mStr,mStrWithoutID
	Duplicate /O/R=[idxID+1,Inf] mNum,mNumWithoutID
	// Get the types
	// XXX assert the lengths of mStr and mNum are equal?
	Variable i, n=DimSize(mStr,0), tmpType
	// Get the insert statement
	String mInsert = GetFormattedStr(mStrWithoutId,mNumWithoutId,mTypesWithoutId)
	// Push to Sql, return the ID
	ModSqlUtil#InsertFormatted(tabName,mColsWithoutId,mInsert)
	Variable mID = ModSqlUtil#GetLastInsertedID(tabName,mCols[0])
	// Add the ID to the object
	mNum[idxID] = mID
	// POST: Sql was sucesseful
	// Add to the global object
	for (i=0; i<n; i+=1)
		// get the information about this field
		mField = mCols[i]
		tmpType = mTypes[i]
		pathToField = ModSqlCypherInterface#GetFieldWaveName(tabName,mField)
		// add to the appropriate location
		if (IsNumericType(tmpType))
			ModSqlCypherInterface#AddToFIeldWaveNum(pathToField,mNum[i])
		Else
			ModSqlCypherInterface#AddToFIeldWaveTxt(pathToField,mStr[i])		
		EndIf
	EndFor
	KillWaves /Z mTypes,mTypesWithoutId,mStrWithoutID,mNumWithoutID
End Function

