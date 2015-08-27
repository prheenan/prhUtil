// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#include ":ViewGlobal"
#include "::Sql:SqlCypherAutoDefines"
#include "::Sql:SqlCypherAutoFuncs"
#include "::Util:IoUtil"
#pragma ModuleName = ModViewSqlInterface

Static Function CopySqlIds(mStruct,WhereToCopy)
	String WhereToCopy
	Struct SqlIdTable & mStruct
	// save the struct wherever we were told
	ModSqlCypherAutoDefines#SetIdTable(mStruct,WhereToCopy)
End Function

Structure SqlTraceInfo
	// All of the meta force information
	Struct ForceMeta mForce
	// All of the Ids relevant to this trace, except for linkers
	Struct SqlIdTable mIds
	// All of the parameter values are are saving
	Struct ParamObj mParams
	// The TimeSepForce file name
	String mFileNameTimeSepForce
EndStructure


// Gets the experiment Id from sql associted with 'sourcename' 
// If the ID doesn't exist, makes it and returns it
Static Function GetExperimentId(mSourceFile,mExpName)
	// if nothing is  there, then insert the new experiment and record the ID.
	String mSourceFile,mExpName
	Variable mIdExp 
	if (!ModSqlUtil#GetUniqueIdWhereColIsVal(TAB_ExpMeta,FIELD_SourceFile,mSourceFile,mIdExp))
		// Nothing found; insert and select our ID. 
		Struct ExpMeta toInsert
		toInsert.Name = mExpName
		toInsert.SourceFile = mSourceFile
		ModSqlCypherAutoFuncs#InsertFmtExpMeta(ToInsert)
		// XXX fill in the remainder of the fields later.
		// Add a description field, get the time started, etc.
		 mIdExp = ModSqlUtil#GetLastInsertedID(TAB_ExpMeta,FIELD_idExpMeta)
	EndIf
	// POST: mIdExp is set by he method or by us
	return mIdExp
End Function

// Gets the model Id, links it to experiment ID
Static Function GetModelId(expId,mModel)
	Variable expId
	String mModel
	// We will return the model ID
	Variable ModelId 
	if (!ModSqlUtil#GetUniqueIdWhereColIsVal(TAB_Model,FIELD_Name,mModel,ModelId))
		Struct Model modToInsert
		modToInsert.Name = mModel
		ModSqlCypherAutoFuncs#InsertFmtModel(modToInsert)
		ModelId = ModSqlUtil#GetLastInsertedId(TAB_MODEL,FIELD_idModel)
		// POST: modelId and expId are populated
		// Add the linker between the experiment and the model
		Struct LinkExpModel mLinkExpModel
		mLinkExpModel.idModel = modelId
		mLinkExpModel.idExpMeta = expId
		ModSqlCypherAutoFuncs#InsertFmtLinkExpModel(mLinkExpModel)
	EndIf
	return ModelId
End Function

// Given a modelId, this sets the sql ids associated with the model parameters in paramObj.
// If the model parameters haven't been pushed, uses the information in paramobj to push them.
// In other words, mObj should have 'real' meta data (helptext, name, units), just missing the sqlID
Static Function SetParamSqlIds(nParams,ModelId,mObj)
	Variable nParams
	Variable ModelId
	Struct ParamObj & mObj
		// Overwrite whatever parameter objects are in the current global folder
	Struct LinkModelParamsWaveStr mLink
	String idPattern = "WHERE %s.%s=%d"
	String appendStmt
	sprintf appendStmt,idPattern,TAB_LinkModelParams,FIELD_idModel,ModelId
	ModSqlCypherAutoFuncs#SimpleSelectLinkModelParams(mLink,saveGlobal=ModDefine#True(),appendStmt=appendStmt,initWaveStr=ModDefine#True())
	// POST: mLink shoud have the ids relevant
	Wave allParamIds = $mLink.idParamMeta
	Variable mIds = Dimsize(allParamIds,0)
	Variable j // need to hoist this here to avoid redeclaration compile error below
	if (mIds == 0)
		// Create a structure to link the parameters to the model.
		// Note that the model will remain the same throughout the params
		Struct LinkModelParams mLinkModelParam
		mLinkModelParam.idModel = modelId
		// then this model hasn't been added
		// PRE: mObj has all the parameter objects.
		// for each, insert individually, add a link.
		for (j=0; j<nParams; j+=1)
			Struct Parameter mParam
			mParam = mObj.params[j]
			Struct ParamMeta mParamToInsert 
			// copy all the information relevant to the parmeter meta information
			mParamToInsert.Name = mParam.Name
			mParamToInsert.Description = mParam.HelpText
			mParamToInsert.UnitName = mParam.BaseUnitName
			mParamToInsert.UnitAbbr = mParam.Abbr
			mParamToInsert.LeadStr = mParam.LeadStr
			mParamToInsert.prefix = mParam.PrefStr
			mParamToInsert.isRepeatable = mParam.repeatable
			mParamToInsert.IsPreProccess = mParam.IsPreProc
			mParamToInsert.ParameterNumber = mParam.ParameterNumber
			// Push the parameter.
			ModSqlCypherAutoFuncs#InsertFmtParamMeta(mParamToInsert)
			// set the objects' parameter ID to whatever was last inserted
			Variable ParamMetaId =  ModSqlUtil#GetLastInsertedID(TAB_ParamMeta,FIELD_idParamMeta)
			mParam.sqlID =ParamMetaId
			// Add a link between the model and this (newly created) parameters
			mLinkModelParam.idParamMeta= ParamMetaId
			ModSqlCypherAutoFuncs#InsertFmtLinkModelParams(mLinkModelParam)
		EndFor
	elseif (NParams > mIds)
		// error: the models exists (not zero), but has
		// not enough parameters defined
		String mErr
		sprintf mErr,"Parameters for model [%d] exists, but found [%d] parameters instead of expected [%d]\r",ModelId,mIds,nParams
		ModErrorUtil#DevelopmentError(description=mErr)
	else
		// then this model has been set with the appropriate parameters.
		// get the parmeter object from all these Ids
		for (j=0; j<mIds; j+= 1)
			// Get the parameter.corredponding to this ID
			Variable mParamIdTmp = allParamIds[j]
			String appendStmtParamMeta
			sprintf appendStmtParamMeta,idPattern,TAB_ParamMeta,FIELD_idParamMeta,mParamIdTmp
			// XXX select, apply all the parameters
			Struct ParamMetaWaveStr mParamWave
			ModSqlCypherAutoFuncs#SimpleSelectParamMeta(mParamWave,saveGlobal=ModDefine#True(),appendStmt=appendStmtParamMeta,initWaveStr=ModDefine#True())			
			// get the id of this parameter.
			// XXX check that we just found one?
			Wave mIdParamMetaWave = $(mParamWave.idParamMeta)
			Wave mParamNum = $(mParamWave.ParameterNumber)// the actual order within the local array
			Variable paramNum = mParamNum[0]
			Variable mIdParamMeta = mIdParamMetaWave[0]
			// XXX save just the ID for now, all we really care about for pushing a new trace
			// Note: a little bit of weirdness; we index using the value from the sql database, since they may be out of order.
			// XXX use an order by, check that they are in range?
			mObj.params[paramNum].sqlId = mIdParamMeta
			mObj.params[paramNum].ParameterNumber = paramNum
		EndFor
	EndIf
	// POST: mObj has the sqlIds and parameter Ids set.
End Function

Static Function GetParamMeta(modelId,mPrototypeObj)
	Variable modelId
	Struct ParamObj & mPrototypeObj
	 SetParamSqlIds(mPrototypeObj.NParams,modelId,mPrototypeObj)
End Function

// Function to add the model and experiment, and return
// a set of parameter *prototypes* with their actual Ids
// Note: this sets the model and experiment ID as references. Does *not* alter global state
// but the parmaeter Ids are stored in mPrototypeObj.params[i].SqlId
Static Function AddExperimentAndModel(mSourceFile,mExpName,modelName,mPrototypeObj,mIdExp,modelId)
	String mSourceFile,mExpName,modelName
	Variable & mIdExp
	Variable &modelId
	Struct ParamObj & mPrototypeObj
	// Determine the ID of the experiment with this source
	mIdExp =  GetExperimentId(mSourceFile,mExpName)
	// POST: mIdExp has the ID for this experiment.
	// Next, ensure the model also exists.
	modelId = GetModelId(mIdExp,modelName)
	// POST: model and experiment are linked.
	// set 'mObj' to the prototypes, by default.
	// We will use this object *exclusively* for 
	// getting the sql ID, but we need to have the meta info 
	// (help text, etc) in case we have to push it.
	GetParamMeta(modelId,mPrototypeObj)
	// TODO Set the IDs for relevant links in the global ID object. 
	// Shoud break this up: add new model, add new experiment. each should set their approopriate IDs.
End Function
// Given the current state of mData (Model, Source, Experiment name)
// Gets the Ids associated with the values in SQL. If the values don't exist,
// creates them and returns the Ids.
Static Function AddCurrentExpAndModelSetIds(mData,mIds)
	Struct ViewGlobalDat & mData	
	Struct SqlIdTable & mIds
	// Set them all based on the current prototypes
	Struct ParamObj mPrototypeObj
	ModViewGlobal#GetAllParamProtos(mData,mPrototypeObj)
	String mModelName  = mData.ModelName
	String mSourceFile = mData.SourceFileName
	String mExpName = mData.ExpFileName
	// Add the experiment and the model, set the IDs by reference
	Variable mIdExp,Modelld
	AddExperimentAndModel(mSourceFile,mExpName,mModelName,mPrototypeObj,mIdExp,Modelld)
	// Set the id and model ids in the global state
	ModSqlCypherAutoDefines#SetId(mIds,TAB_EXPMETA,mIdExp)
	ModSqlCypherAutoDefines#SetId(mIds,TAB_MODEL,Modelld)
	// POST: the model and experiment files are set, the global ID reflects this
End Function

Static Function AddTraceMetaAndLinkers(mMeta,mIds,traceDataId)
	Struct forceMeta & mMeta
	Struct SqlIdTable & mIds
	Variable traceDataId
	// get the TraceMeta struct
	Struct TraceMeta sqlMeta
	mMeta.ApproachVel = mMeta.ApproachVel 
	sqlMeta.RetractVel =  mMeta.RetractVel
	sqlMeta.TimeStarted=  ModSqlUtil#ToSqlDate(mMeta.TimeStart)
	sqlMeta.TimeEnded =  ModSqlUtil#ToSqlDate(mMeta.TimeEnd)
	sqlMeta.DwellTowards =  mMeta.DwellSurface
	sqlMeta.DwellAway =  mMeta.DwellAWay
	sqlMeta.SampleRate =  mMeta.SampleRate
	sqlMeta.FilteredSampleRate =  mMeta.ForceBandwidth
	sqlMeta.DeflInvols =  mMeta.Invols
	sqlMeta.Temperature =  mMeta.Temperature
	sqlMeta.SpringConstant =  mMeta.Springconstant
	sqlMeta.FirstResRef =  mMeta.ResFreq
	sqlMeta.ThermalQ =  mMeta.ThermalQ
	sqlMeta.LocationX =  mMeta.PosX
	sqlMeta.LocationY =  mMeta.PosY
	sqlMeta.LocationZ = mMeta.PosZ
	sqlMeta.OffsetX =  mMeta.OffsetX
	sqlMeta.OffsetY =  mMeta.OffsetY
	sqlMeta.Spot =  mMeta.Spot
	sqlMeta.idTipManifest  = mIds.idTipManifest
	sqlMeta.idUser = mIds.idUser
	sqlMeta.idTraceRating = mIds.idTraceRating
	sqlMeta.idSample = mIds.idSample
	// POST: tracemeta is set, go ahead and push it.
	ModSqlCypherAutoFuncs#InsertFmtTraceMeta(sqlMeta)
	// Get the ID of the trace meta object we just pushed.
	Variable traceID = ModSqlUtil#GetLastInsertedID(TAB_TraceMeta,FIELD_idTraceMeta)
	// Add links between the traceData and TraceModel,TraceMeta, and 
	//
	//Push all the linking tables
	//
	// Push the link trace
	Struct LinkTipTrace mLinkTipTrace
	mLinkTipTrace.idTraceMeta = traceID
	mLinkTipTrace.idTipType = mIds.idTipType
	ModSqlCypherAutoFuncs#InsertFmtLinkTipTrace(mLinkTipTrace)
	// Push the Molecule trace
	Struct LinkMoleTrace mMolTrace
	mMOlTrace.idTraceMeta = traceId
	mMolTrace.idMolType = mIds.idMolType
	ModSqlCypherAutoFuncs#InsertFmtLinkMoleTrace(mMolTrace)
	// Push the experiment-traceMeta link
	Struct TraceExpLink mExpLink
	mExpLink.idTraceMeta = traceID
	mExpLink.idExpMeta = mIds.idExpMeta
	ModSqlCypherAutoFuncs#InsertFmtTraceExpLink(mExpLink)
	// Make a linker between the data and the tracemeta
	Struct LinkDataMeta mDataMetaLink
	mDataMetaLink.idTraceMeta = traceID
	mDataMetaLink.idTraceData = traceDataID
	ModSqlCypherAutoFuncs#InsertFmtLinkDataMeta(mDataMetaLink)	
	// Make the TraceModel table
	Struct Tracemodel mTraceModel
	mTraceModel.idTraceMeta = traceID
	mTraceModel.idTraceData = traceDataID
	mTraceModel.idModel = mIds.idModel
	ModSqlCypherAutoFuncs#InsertFmtTraceModel(mTraceModel)	
	// Get the id of the tracemodel we just sent off.
	Variable traceModelId = ModSqlUtil#GetLastInsertedID(TAB_TraceModel,FIELD_idTraceModel)
	// return the trace model ID
	return traceModelId
End function

Static Function AddNewTrace(mInf)
	// PRE: all Ids are assumed to be OK. In other words, all 
	// ids refer to real entries in the table, *except for*
	// (1) TraceMeta (it makes this)
	// (2) TraceModel (also makes this) 
	// (3) Any linking table
	// (4) The parameter value table (also makes this) 
	// Does *not* make the link from experiment to model or model to params.
	// Assumes that the model and data already exist
	// *will* make all the linking tables.
	Struct SqlTraceInfo & mInf
	// get local copies for each of use
	Struct forceMeta mMeta
	mMeta  = mInf.mForce
	Struct SqlIdTable mIds
	mIds=  mInf.mIds
	// Check if we have already pushed this data.
	Variable traceDataID
	String mFileName =mInf.mFileNameTimeSepForce
	Variable traceModelID // set in either branch of the for loop, below.
	// Trace is new if it is *not* in the table already
	Variable traceIsNew = !ModSqlUtil#GetUniqueIdWhereColIsVal(TAB_TraceData,FIELD_FileTimSepFor,mFileName,traceDataID)
	if (traceIsNew)
	// This data isn't already in the repository; Add in the trace data
		Struct TraceData mTraceData
		mTraceData.FIleTimSepFor = mFileName
		mTraceData.idExpMeta = mIds.idExpMeta
		ModSqlCypherAutoFuncs#InsertFmtTraceData(mTraceData)		
		traceDataID= ModSqlUtil#GetLastInsertedID(TAB_TraceDATA,FIELD_idTraceData)
		// XXX for now, assume we *just* update the parameters values
		// returns the tace model ID
		traceModelId = AddTraceMetaAndLinkers(mMeta,mIds,traceDataId)
	else
		// This model *does* exists
		// traceDataId was set by 'getUniqueId'
		// We need to get the id of the tracemodel, then update each parameter...
		String AppendStmtRegex = " WHERE %s=%d"
		String AppendStmtTraceModel
		// Pick out the trace model where we have the tracedata (ie source file) correct, *and* the model
		// correct. XXX could also get tracemeta?
		sprintf AppendStmtTraceModel,(AppendStmtRegex + " AND %s=%d") ,FIELD_idTraceData,traceDataId,FIELD_idModel,mIds.idModel
		Struct TraceModelWaveStr mTraceModelWave
		ModSqlCypherAutoFuncs#SimpleSelectTraceModel(mTraceModelWave,saveGlobal=ModDefine#True(),appendStmt=AppendStmtTraceModel,initWaveStr=ModDefine#True())
		// XXX check that dimsize == 1?
		Wave TraceModelIdWave = $mTraceModelWave.idTraceModel
		Variable n = Dimsize(TraceModelIdWave,0)
		ModErrorUtil#AssertEq(n,1)
		// POST: exactly one trace model matches, as we would expect.
		 TraceModelId = TraceModelIdWave[0]
		 // Delete all of the parameter values associated with this wave
		 // XXX could just update, if we wanted...
		Struct LinkTraceParamWaveStr mLinkTraceParamDel
		String AppendStmtTraceParam
		sprintf AppendStmtTraceParam,appendStmtRegex,FIELD_idTracemodel,traceModelId
		ModSqlCypherAutoFuncs#SimpleSelectLinkTraceParam(mLinkTraceParamDel,saveGlobal=ModDefine#True(),appendStmt=AppendStmtTraceParam,initWaveStr=ModDefine#True())
		 // Get all of the Ids
		 Wave mParamIds = $(mLinkTraceParamDel.idParameterValue)
		 // Delete all of the Ids from the parameter value table
		 ModSqlUtil#DeleteById(TAB_ParameterValue,FIELD_idParameterValue,mParamIds)
		 // Delete all of the ids from the parameter linking table
		 ModSqlUtil#DeleteById(TAB_LinkTraceParam,FIELD_idParameterValue,mParamIds)
		 // POST: 'fresh slate', we can go ahead and add them
	EndIf
	Variable nParams = mInf.mParams.NParams
	Variable i
	Struct Parameter tmp
	Struct ParameterValue mInsertParam
	Struct LinkTraceParam mLinkTraceParam
	// Note that the following doesn't change, for different parameters.
	mLinkTraceParam.idTraceModel= traceModelId
	for (i=0; i<nParams; i+=1)
		// Get the id of this parameter
		Variable mParamMetaId = mInf.mParams.params[i].SqlId
		// Get the actual parameter 
		tmp = mInf.mParams.params[i]
		// get the values to insert
		String strVal = tmp.StringValue
		Variable numVal = tmp.NumericValue
		Variable index = tmp.pointIndex
		// POST: have all the informaton we need to set up a new parameter value
		mInsertParam.dataIndex = index
		mInsertParam.StrValues = strVal
		mInsertParam.DataValues = numVal
		mInsertParam.idParamMEta = mParamMetaId
		ModSqlCypherAutoFuncs#InsertFmtParameterValue(mInsertParam)		
		// get the ID of the parameter we just inserted
		Variable paramValId = ModSqlUtil#GetLastInsertedID(TAB_ParameterValue,FIELD_idParameterValue)
		// Insert a link between the trace and this parameter
		mLinkTraceParam.idParameterValue = paramValId
		ModSqlCypherAutoFuncs#InsertFmtLinkTraceParam(mLinkTraceParam)		
		// XXX for now, ignore trace data index.
	EndFor
	return traceIsNew
End Function


Static Function SaveAllStubsAsFEC(mData,Stubs)
	// mData is the global data, for the suffixes (e.g. Force/Sep) of the stubs and savedir
	// Stubs is the wave of stubs we will save out
	Struct ViewGlobalDat &mData
	Wave /T Stubs
	Variable nWaves = DimSize(Stubs,0)
	Variable i=0
	String sepSuffix = mData.SuffixSepPlot
	String forceSuffix =  mData.SuffixForcePlot
	String mStub,sepWaveName,forceWaveName,nameOfSavedFile
	String mFolder = mData.CachedSaveDir
	// Get the prototypes
	Struct ParamObj mTmpParams
	// Get their IDs
	// XXX we assume that all saved items have the same model.
	Struct SqlIdTable globalIdStruct 
	ModSqlCypherInterface#LoadGlobalIdStruct(globalIdStruct)
	for (i=0; i< nWaves; i+=1)
		mStub =  Stubs[i]
		sepWaveName = mStub+ sepSuffix
		forceWaveName = mStub+ forceSuffix
		nameOfSavedFile = MOdVIewGlobal#GetCacheName(forceWaveName)
		// Get the current directory
		String expFolder
		MOdVIewGlobal#FindExpIfExists(forceWaveName,expFolder)
		// Pre-pend where the experiment is saved
		String mBase = MOdVIewGlobal#GetBaseDir(mData)
		String mTraceSaving = MOdVIewGlobal#TraceSavingFolder(mBase)
		expFolder = ModIOUTil#AppendedPath(mTraceSaving,expFolder)
		String mDataFolder = MOdVIewGlobal#CurrentDataFolderByString(mData,expFolder,forceWaveName)
		// Get the Id stucture saved with this object
		String pathToSqlId = MOdVIewGlobal#GetSqlIdInf(mDataFolder)
		// Get the actual Id object
		Struct SqlIdTable mIdStruct
		MOdSqlCypherAutoDefines#GetIdTable(mIdStruct,pathToSqlId)
		Variable modelId = MOdSqlCypherAutoDefines#GetId(mIdStruct,TAB_Model)
		// Push the information to SQL
		String parameterPath = MOdVIewGlobal#GetCurrentTraceParamPath(mDataFolder)
		// Get the parameter values here
		MOdVIewGlobal#GetParameters(parameterPath,mTmpParams)
		// Set their SQL Ids.
		ModViewSqlInterface#GetParamMeta(modelId,mTmpParams)
		// set up the struct to push this trace.
		Struct SqlTraceInfo myMetaInf 
		ModCypherUtil#GetForceMeta(myMetaInf.mForce,$forceWaveName)
		myMetaInf.mIds=mIdStruct
		myMetaInf.mParams = mTmpParams
		myMetaInf.mFileNameTimeSepForce = nameOfSavedFile
		// Upload  the trace information
		// This method returns true if this was a *new* file (ie: 
		// we need to re-save the data)
		Variable traceIsNew = AddNewTrace(myMetaInf)
		// Save the data
		if (traceIsNew)
			ModIoUtilHDF5#SaveForceExtensionFromStub(sepWaveName,forceWaveName,mFolder,nameOfSavedFile)
		EndIf
	EndFor
End Function	
