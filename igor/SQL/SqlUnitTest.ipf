// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#pragma ModuleName = ModSqlUnitTest

#include ":SqlUtil"
#include ":SqlCypherBootstrap"
#include ":SqlCypherAutoFuncs"

Static Function Main([Debugging])
	Variable Debugging
	Debugging = ParamIsDefault(Debugging) ? ModDefine#True() : Debugging
	ModSqlCypherBootStrap#Init()
	// PRE: we must have an open connection of the right name to the database.
	// First, remove everything from the database, so we have a fresh slate
	String mDatabase = ModSqlUtil#GetDb()
	// Need to determine all the table names
	Make /O/N=(0)/T mTables
	ModSqlUtil#GetTableNames(mDatabase,mTables)
	// POST: mTables has all of the tables names.
	// Remove everything from each tables
	Variable nItems = DimSize(mTables,0)
	Variable i=0
	Struct QueryInf mQuery
	mQuery.Database = mDatabase
	for (i=0; i< nItems; i+= 1)
		mQuery.table = mTables[i]
		ModSqlUtil#ClearTable(mQuery)
	EndFor
	// POST: every table is cleared
	// Go ahead an add in the default tip tipes, sample families, etc.
	ModSqlCypherBootstrap#AddDefaultTipPack()
	ModSqlCypherBootstrap#AddDefaultTipTypes()
	ModSqlCypherBootstrap#AddDefaultMolecules()
	ModSqlCypherBootstrap#AddDefaultRatings()
	ModSqlCypherBootstrap#AddDefaultUsers()
	ModSqlCypherBootstrap#AddDefaultTipPreps()
	ModSqlCypherBootstrap#AddDefaultSamplePreps()
	ModSqlCypherBootstrap#AddDefaultSamples()
	ModSqlCypherBootstrap#AddDefaultTipManifests()
	// Kill the waves we made
	KillWaves /Z mTables
End Function
