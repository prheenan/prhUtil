// Use modern global access method, strict compilation
#pragma rtGlobals=3
#pragma ModuleName=ModSqlCypherAutoFuncs
#include ".\SqlUtil"
#include ".\..\Util\Defines"
#include ".\..\Util\ErrorUtil"
#include ".\SqlCypherAutoDefines"
#include ".\SqlCypherInterface"
#include ".\SqlCypherUtilFuncs"
// Defined insert functions
Static Function InsertFmtExpMeta(mTab)
	Struct ExpMeta & mTab
	String fmtStr = "'%s',%d,'%s'"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfExpMeta()
	sprintf final,fmtStr,mTab.TimeStarted,mTab.NAttemptedPulls,mTab.SourceFile
	return ModSqlUtil#InsertFormatted(TAB_ExpMeta,mCols,final)
End Function

Static Function InsertExpMeta(TimeStarted,NAttemptedPulls,SourceFile)
	Wave /T TimeStarted
	Wave  NAttemptedPulls
	Wave /T SourceFile
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfExpMeta()
	Make /O/T mWave = { NameOfWave(TimeStarted),NameOfWave(NAttemptedPulls),NameOfWave(SourceFile)} 
	return ModSqlUtil#InsertComposite(TAB_ExpMeta,mCols,mWave)
End Function


Static Function InsertFmtExpUserData(mTab)
	Struct ExpUserData & mTab
	String fmtStr = "'%s','%s',%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfExpUserData()
	sprintf final,fmtStr,mTab.Name,mTab.Description,mTab.idUser
	return ModSqlUtil#InsertFormatted(TAB_ExpUserData,mCols,final)
End Function

Static Function InsertExpUserData(Name,Description,idUser)
	Wave /T Name
	Wave /T Description
	Wave  idUser
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfExpUserData()
	Make /O/T mWave = { NameOfWave(Name),NameOfWave(Description),NameOfWave(idUser)} 
	return ModSqlUtil#InsertComposite(TAB_ExpUserData,mCols,mWave)
End Function


Static Function InsertFmtLinkDataMeta(mTab)
	Struct LinkDataMeta & mTab
	String fmtStr = "%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkDataMeta()
	sprintf final,fmtStr,mTab.idTraceMeta,mTab.idTraceData
	return ModSqlUtil#InsertFormatted(TAB_LinkDataMeta,mCols,final)
End Function

Static Function InsertLinkDataMeta(idTraceMeta,idTraceData)
	Wave  idTraceMeta
	Wave  idTraceData
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfLinkDataMeta()
	Make /O/T mWave = { NameOfWave(idTraceMeta),NameOfWave(idTraceData)} 
	return ModSqlUtil#InsertComposite(TAB_LinkDataMeta,mCols,mWave)
End Function


Static Function InsertFmtLinkExpModel(mTab)
	Struct LinkExpModel & mTab
	String fmtStr = "%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkExpModel()
	sprintf final,fmtStr,mTab.idModel,mTab.idExpUserData
	return ModSqlUtil#InsertFormatted(TAB_LinkExpModel,mCols,final)
End Function

Static Function InsertLinkExpModel(idModel,idExpUserData)
	Wave  idModel
	Wave  idExpUserData
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfLinkExpModel()
	Make /O/T mWave = { NameOfWave(idModel),NameOfWave(idExpUserData)} 
	return ModSqlUtil#InsertComposite(TAB_LinkExpModel,mCols,mWave)
End Function


Static Function InsertFmtLinkModelParams(mTab)
	Struct LinkModelParams & mTab
	String fmtStr = "%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkModelParams()
	sprintf final,fmtStr,mTab.idModel,mTab.idParamMeta
	return ModSqlUtil#InsertFormatted(TAB_LinkModelParams,mCols,final)
End Function

Static Function InsertLinkModelParams(idModel,idParamMeta)
	Wave  idModel
	Wave  idParamMeta
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfLinkModelParams()
	Make /O/T mWave = { NameOfWave(idModel),NameOfWave(idParamMeta)} 
	return ModSqlUtil#InsertComposite(TAB_LinkModelParams,mCols,mWave)
End Function


Static Function InsertFmtLinkModelTrace(mTab)
	Struct LinkModelTrace & mTab
	String fmtStr = "%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkModelTrace()
	sprintf final,fmtStr,mTab.idModel,mTab.idTraceModel
	return ModSqlUtil#InsertFormatted(TAB_LinkModelTrace,mCols,final)
End Function

Static Function InsertLinkModelTrace(idModel,idTraceModel)
	Wave  idModel
	Wave  idTraceModel
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfLinkModelTrace()
	Make /O/T mWave = { NameOfWave(idModel),NameOfWave(idTraceModel)} 
	return ModSqlUtil#InsertComposite(TAB_LinkModelTrace,mCols,mWave)
End Function


Static Function InsertFmtLinkMoleTrace(mTab)
	Struct LinkMoleTrace & mTab
	String fmtStr = "%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkMoleTrace()
	sprintf final,fmtStr,mTab.idMolType,mTab.idTraceMeta
	return ModSqlUtil#InsertFormatted(TAB_LinkMoleTrace,mCols,final)
End Function

Static Function InsertLinkMoleTrace(idMolType,idTraceMeta)
	Wave  idMolType
	Wave  idTraceMeta
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfLinkMoleTrace()
	Make /O/T mWave = { NameOfWave(idMolType),NameOfWave(idTraceMeta)} 
	return ModSqlUtil#InsertComposite(TAB_LinkMoleTrace,mCols,mWave)
End Function


Static Function InsertFmtLinkTipTrace(mTab)
	Struct LinkTipTrace & mTab
	String fmtStr = "%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkTipTrace()
	sprintf final,fmtStr,mTab.idTipType,mTab.idTraceMeta
	return ModSqlUtil#InsertFormatted(TAB_LinkTipTrace,mCols,final)
End Function

Static Function InsertLinkTipTrace(idTipType,idTraceMeta)
	Wave  idTipType
	Wave  idTraceMeta
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfLinkTipTrace()
	Make /O/T mWave = { NameOfWave(idTipType),NameOfWave(idTraceMeta)} 
	return ModSqlUtil#InsertComposite(TAB_LinkTipTrace,mCols,mWave)
End Function


Static Function InsertFmtLinkTraceParam(mTab)
	Struct LinkTraceParam & mTab
	String fmtStr = "%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkTraceParam()
	sprintf final,fmtStr,mTab.idParameterValue,mTab.idTraceModel
	return ModSqlUtil#InsertFormatted(TAB_LinkTraceParam,mCols,final)
End Function

Static Function InsertLinkTraceParam(idParameterValue,idTraceModel)
	Wave  idParameterValue
	Wave  idTraceModel
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfLinkTraceParam()
	Make /O/T mWave = { NameOfWave(idParameterValue),NameOfWave(idTraceModel)} 
	return ModSqlUtil#InsertComposite(TAB_LinkTraceParam,mCols,mWave)
End Function


Static Function InsertFmtModel(mTab)
	Struct Model & mTab
	String fmtStr = "'%s','%s'"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfModel()
	sprintf final,fmtStr,mTab.ModelName,mTab.ModelDescription
	return ModSqlUtil#InsertFormatted(TAB_Model,mCols,final)
End Function

Static Function InsertModel(ModelName,ModelDescription)
	Wave /T ModelName
	Wave /T ModelDescription
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfModel()
	Make /O/T mWave = { NameOfWave(ModelName),NameOfWave(ModelDescription)} 
	return ModSqlUtil#InsertComposite(TAB_Model,mCols,mWave)
End Function


Static Function InsertFmtMolType(mTab)
	Struct MolType & mTab
	String fmtStr = "'%s','%s',%.15g,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfMolType()
	sprintf final,fmtStr,mTab.Name,mTab.Description,mTab.MolMass,mTab.idMoleculeFamily
	return ModSqlUtil#InsertFormatted(TAB_MolType,mCols,final)
End Function

Static Function InsertMolType(Name,Description,MolMass,idMoleculeFamily)
	Wave /T Name
	Wave /T Description
	Wave /D MolMass
	Wave  idMoleculeFamily
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfMolType()
	Make /O/T mWave = { NameOfWave(Name),NameOfWave(Description),NameOfWave(MolMass),NameOfWave(idMoleculeFamily)} 
	return ModSqlUtil#InsertComposite(TAB_MolType,mCols,mWave)
End Function


Static Function InsertFmtMoleculeFamily(mTab)
	Struct MoleculeFamily & mTab
	String fmtStr = "'%s','%s'"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfMoleculeFamily()
	sprintf final,fmtStr,mTab.Name,mTab.Description
	return ModSqlUtil#InsertFormatted(TAB_MoleculeFamily,mCols,final)
End Function

Static Function InsertMoleculeFamily(Name,Description)
	Wave /T Name
	Wave /T Description
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfMoleculeFamily()
	Make /O/T mWave = { NameOfWave(Name),NameOfWave(Description)} 
	return ModSqlUtil#InsertComposite(TAB_MoleculeFamily,mCols,mWave)
End Function


Static Function InsertFmtParamMeta(mTab)
	Struct ParamMeta & mTab
	String fmtStr = "'%s','%s','%s','%s','%s','%s',%d,%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfParamMeta()
	sprintf final,fmtStr,mTab.Name,mTab.Description,mTab.UnitName,mTab.UnitAbbr,mTab.LeadStr,mTab.Prefix,mTab.IsRepeatable,mTab.IsPreProccess,mTab.ParameterNumber
	return ModSqlUtil#InsertFormatted(TAB_ParamMeta,mCols,final)
End Function

Static Function InsertParamMeta(Name,Description,UnitName,UnitAbbr,LeadStr,Prefix,IsRepeatable,IsPreProccess,ParameterNumber)
	Wave /T Name
	Wave /T Description
	Wave /T UnitName
	Wave /T UnitAbbr
	Wave /T LeadStr
	Wave /T Prefix
	Wave  IsRepeatable
	Wave  IsPreProccess
	Wave  ParameterNumber
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfParamMeta()
	Make /O/T mWave = { NameOfWave(Name),NameOfWave(Description),NameOfWave(UnitName),NameOfWave(UnitAbbr),NameOfWave(LeadStr),NameOfWave(Prefix),NameOfWave(IsRepeatable),NameOfWave(IsPreProccess),NameOfWave(ParameterNumber)} 
	return ModSqlUtil#InsertComposite(TAB_ParamMeta,mCols,mWave)
End Function


Static Function InsertFmtParameterValue(mTab)
	Struct ParameterValue & mTab
	String fmtStr = "%.15g,'%s',%.15g,%d,%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfParameterValue()
	sprintf final,fmtStr,mTab.DataIndex,mTab.StrValues,mTab.DataValues,mTab.RepeatNumber,mTab.idTraceDataIndex,mTab.idParamMeta
	return ModSqlUtil#InsertFormatted(TAB_ParameterValue,mCols,final)
End Function

Static Function InsertParameterValue(DataIndex,StrValues,DataValues,RepeatNumber,idTraceDataIndex,idParamMeta)
	Wave /D DataIndex
	Wave /T StrValues
	Wave /D DataValues
	Wave  RepeatNumber
	Wave  idTraceDataIndex
	Wave  idParamMeta
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfParameterValue()
	Make /O/T mWave = { NameOfWave(DataIndex),NameOfWave(StrValues),NameOfWave(DataValues),NameOfWave(RepeatNumber),NameOfWave(idTraceDataIndex),NameOfWave(idParamMeta)} 
	return ModSqlUtil#InsertComposite(TAB_ParameterValue,mCols,mWave)
End Function


Static Function InsertFmtSample(mTab)
	Struct Sample & mTab
	String fmtStr = "'%s','%s',%.15g,%.15g,'%s','%s','%s',%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfSample()
	sprintf final,fmtStr,mTab.Name,mTab.Description,mTab.ConcNanogMuL,mTab.VolLoadedMuL,mTab.DateDeposited,mTab.DateCreated,mTab.DateRinsed,mTab.idSamplePrep,mTab.idMolType
	return ModSqlUtil#InsertFormatted(TAB_Sample,mCols,final)
End Function

Static Function InsertSample(Name,Description,ConcNanogMuL,VolLoadedMuL,DateDeposited,DateCreated,DateRinsed,idSamplePrep,idMolType)
	Wave /T Name
	Wave /T Description
	Wave /D ConcNanogMuL
	Wave /D VolLoadedMuL
	Wave /T DateDeposited
	Wave /T DateCreated
	Wave /T DateRinsed
	Wave  idSamplePrep
	Wave  idMolType
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfSample()
	Make /O/T mWave = { NameOfWave(Name),NameOfWave(Description),NameOfWave(ConcNanogMuL),NameOfWave(VolLoadedMuL),NameOfWave(DateDeposited),NameOfWave(DateCreated),NameOfWave(DateRinsed),NameOfWave(idSamplePrep),NameOfWave(idMolType)} 
	return ModSqlUtil#InsertComposite(TAB_Sample,mCols,mWave)
End Function


Static Function InsertFmtSamplePrep(mTab)
	Struct SamplePrep & mTab
	String fmtStr = "'%s','%s'"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfSamplePrep()
	sprintf final,fmtStr,mTab.Name,mTab.Description
	return ModSqlUtil#InsertFormatted(TAB_SamplePrep,mCols,final)
End Function

Static Function InsertSamplePrep(Name,Description)
	Wave /T Name
	Wave /T Description
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfSamplePrep()
	Make /O/T mWave = { NameOfWave(Name),NameOfWave(Description)} 
	return ModSqlUtil#InsertComposite(TAB_SamplePrep,mCols,mWave)
End Function


Static Function InsertFmtSourceFileDirectory(mTab)
	Struct SourceFileDirectory & mTab
	String fmtStr = "'%s'"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfSourceFileDirectory()
	sprintf final,fmtStr,mTab.DirectoryName
	return ModSqlUtil#InsertFormatted(TAB_SourceFileDirectory,mCols,final)
End Function

Static Function InsertSourceFileDirectory(DirectoryName)
	Wave /T DirectoryName
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfSourceFileDirectory()
	Make /O/T mWave = { NameOfWave(DirectoryName)} 
	return ModSqlUtil#InsertComposite(TAB_SourceFileDirectory,mCols,mWave)
End Function


Static Function InsertFmtTipManifest(mTab)
	Struct TipManifest & mTab
	String fmtStr = "'%s','%s','%s','%s','%s',%d,%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTipManifest()
	sprintf final,fmtStr,mTab.Name,mTab.Description,mTab.PackPosition,mTab.TimeMade,mTab.TimeRinsed,mTab.idTipPrep,mTab.idTipType,mTab.idTipPack
	return ModSqlUtil#InsertFormatted(TAB_TipManifest,mCols,final)
End Function

Static Function InsertTipManifest(Name,Description,PackPosition,TimeMade,TimeRinsed,idTipPrep,idTipType,idTipPack)
	Wave /T Name
	Wave /T Description
	Wave /T PackPosition
	Wave /T TimeMade
	Wave /T TimeRinsed
	Wave  idTipPrep
	Wave  idTipType
	Wave  idTipPack
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfTipManifest()
	Make /O/T mWave = { NameOfWave(Name),NameOfWave(Description),NameOfWave(PackPosition),NameOfWave(TimeMade),NameOfWave(TimeRinsed),NameOfWave(idTipPrep),NameOfWave(idTipType),NameOfWave(idTipPack)} 
	return ModSqlUtil#InsertComposite(TAB_TipManifest,mCols,mWave)
End Function


Static Function InsertFmtTipPack(mTab)
	Struct TipPack & mTab
	String fmtStr = "'%s','%s'"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTipPack()
	sprintf final,fmtStr,mTab.Name,mTab.Description
	return ModSqlUtil#InsertFormatted(TAB_TipPack,mCols,final)
End Function

Static Function InsertTipPack(Name,Description)
	Wave /T Name
	Wave /T Description
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfTipPack()
	Make /O/T mWave = { NameOfWave(Name),NameOfWave(Description)} 
	return ModSqlUtil#InsertComposite(TAB_TipPack,mCols,mWave)
End Function


Static Function InsertFmtTipPrep(mTab)
	Struct TipPrep & mTab
	String fmtStr = "'%s','%s',%.15g,%.15g"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTipPrep()
	sprintf final,fmtStr,mTab.Name,mTab.Description,mTab.SecondsEtchGold,mTab.SecondsEtchChromium
	return ModSqlUtil#InsertFormatted(TAB_TipPrep,mCols,final)
End Function

Static Function InsertTipPrep(Name,Description,SecondsEtchGold,SecondsEtchChromium)
	Wave /T Name
	Wave /T Description
	Wave /D SecondsEtchGold
	Wave /D SecondsEtchChromium
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfTipPrep()
	Make /O/T mWave = { NameOfWave(Name),NameOfWave(Description),NameOfWave(SecondsEtchGold),NameOfWave(SecondsEtchChromium)} 
	return ModSqlUtil#InsertComposite(TAB_TipPrep,mCols,mWave)
End Function


Static Function InsertFmtTipType(mTab)
	Struct TipType & mTab
	String fmtStr = "'%s','%s'"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTipType()
	sprintf final,fmtStr,mTab.Name,mTab.Description
	return ModSqlUtil#InsertFormatted(TAB_TipType,mCols,final)
End Function

Static Function InsertTipType(Name,Description)
	Wave /T Name
	Wave /T Description
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfTipType()
	Make /O/T mWave = { NameOfWave(Name),NameOfWave(Description)} 
	return ModSqlUtil#InsertComposite(TAB_TipType,mCols,mWave)
End Function


Static Function InsertFmtTraceData(mTab)
	Struct TraceData & mTab
	String fmtStr = "'%s',%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceData()
	sprintf final,fmtStr,mTab.FileName,mTab.idExpUserData
	return ModSqlUtil#InsertFormatted(TAB_TraceData,mCols,final)
End Function

Static Function InsertTraceData(FileName,idExpUserData)
	Wave /T FileName
	Wave  idExpUserData
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfTraceData()
	Make /O/T mWave = { NameOfWave(FileName),NameOfWave(idExpUserData)} 
	return ModSqlUtil#InsertComposite(TAB_TraceData,mCols,mWave)
End Function


Static Function InsertFmtTraceDataIndex(mTab)
	Struct TraceDataIndex & mTab
	String fmtStr = "%.15g,%.15g,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceDataIndex()
	sprintf final,fmtStr,mTab.StartIndex,mTab.EndIndex,mTab.idTraceData
	return ModSqlUtil#InsertFormatted(TAB_TraceDataIndex,mCols,final)
End Function

Static Function InsertTraceDataIndex(StartIndex,EndIndex,idTraceData)
	Wave /D StartIndex
	Wave /D EndIndex
	Wave  idTraceData
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfTraceDataIndex()
	Make /O/T mWave = { NameOfWave(StartIndex),NameOfWave(EndIndex),NameOfWave(idTraceData)} 
	return ModSqlUtil#InsertComposite(TAB_TraceDataIndex,mCols,mWave)
End Function


Static Function InsertFmtTraceExpLink(mTab)
	Struct TraceExpLink & mTab
	String fmtStr = "%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceExpLink()
	sprintf final,fmtStr,mTab.idTraceMeta,mTab.idExpUserData
	return ModSqlUtil#InsertFormatted(TAB_TraceExpLink,mCols,final)
End Function

Static Function InsertTraceExpLink(idTraceMeta,idExpUserData)
	Wave  idTraceMeta
	Wave  idExpUserData
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfTraceExpLink()
	Make /O/T mWave = { NameOfWave(idTraceMeta),NameOfWave(idExpUserData)} 
	return ModSqlUtil#InsertComposite(TAB_TraceExpLink,mCols,mWave)
End Function


Static Function InsertFmtTraceMeta(mTab)
	Struct TraceMeta & mTab
	String fmtStr = "'%s',%.15g,%.15g,'%s','%s',%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%.15g,%d,%d,%d,%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceMeta()
	sprintf final,fmtStr,mTab.Description,mTab.ApproachVel,mTab.RetractVel,mTab.TimeStarted,mTab.TimeEnded,mTab.DwellTowards,mTab.DwellAway,mTab.SampleRate,mTab.FilteredSampleRate,mTab.DeflInvols,mTab.Temperature,mTab.SpringConstant,mTab.FirstResRef,mTab.ThermalQ,mTab.LocationX,mTab.LocationY,mTab.OffsetX,mTab.OffsetY,mTab.Spot,mTab.idTipManifest,mTab.idUser,mTab.idTraceRating,mTab.idSample
	return ModSqlUtil#InsertFormatted(TAB_TraceMeta,mCols,final)
End Function

Static Function InsertTraceMeta(Description,ApproachVel,RetractVel,TimeStarted,TimeEnded,DwellTowards,DwellAway,SampleRate,FilteredSampleRate,DeflInvols,Temperature,SpringConstant,FirstResRef,ThermalQ,LocationX,LocationY,OffsetX,OffsetY,Spot,idTipManifest,idUser,idTraceRating,idSample)
	Wave /T Description
	Wave /D ApproachVel
	Wave /D RetractVel
	Wave /T TimeStarted
	Wave /T TimeEnded
	Wave /D DwellTowards
	Wave /D DwellAway
	Wave /D SampleRate
	Wave /D FilteredSampleRate
	Wave /D DeflInvols
	Wave /D Temperature
	Wave /D SpringConstant
	Wave /D FirstResRef
	Wave /D ThermalQ
	Wave /D LocationX
	Wave /D LocationY
	Wave /D OffsetX
	Wave /D OffsetY
	Wave  Spot
	Wave  idTipManifest
	Wave  idUser
	Wave  idTraceRating
	Wave  idSample
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfTraceMeta()
	Make /O/T mWave = { NameOfWave(Description),NameOfWave(ApproachVel),NameOfWave(RetractVel),NameOfWave(TimeStarted),NameOfWave(TimeEnded),NameOfWave(DwellTowards),NameOfWave(DwellAway),NameOfWave(SampleRate),NameOfWave(FilteredSampleRate),NameOfWave(DeflInvols),NameOfWave(Temperature),NameOfWave(SpringConstant),NameOfWave(FirstResRef),NameOfWave(ThermalQ),NameOfWave(LocationX),NameOfWave(LocationY),NameOfWave(OffsetX),NameOfWave(OffsetY),NameOfWave(Spot),NameOfWave(idTipManifest),NameOfWave(idUser),NameOfWave(idTraceRating),NameOfWave(idSample)} 
	return ModSqlUtil#InsertComposite(TAB_TraceMeta,mCols,mWave)
End Function


Static Function InsertFmtTraceModel(mTab)
	Struct TraceModel & mTab
	String fmtStr = "%d,%d"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceModel()
	sprintf final,fmtStr,mTab.idTraceMeta,mTab.idTraceData
	return ModSqlUtil#InsertFormatted(TAB_TraceModel,mCols,final)
End Function

Static Function InsertTraceModel(idTraceMeta,idTraceData)
	Wave  idTraceMeta
	Wave  idTraceData
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfTraceModel()
	Make /O/T mWave = { NameOfWave(idTraceMeta),NameOfWave(idTraceData)} 
	return ModSqlUtil#InsertComposite(TAB_TraceModel,mCols,mWave)
End Function


Static Function InsertFmtTraceRating(mTab)
	Struct TraceRating & mTab
	String fmtStr = "%d,'%s','%s'"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceRating()
	sprintf final,fmtStr,mTab.RatingValue,mTab.Name,mTab.Description
	return ModSqlUtil#InsertFormatted(TAB_TraceRating,mCols,final)
End Function

Static Function InsertTraceRating(RatingValue,Name,Description)
	Wave  RatingValue
	Wave /T Name
	Wave /T Description
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfTraceRating()
	Make /O/T mWave = { NameOfWave(RatingValue),NameOfWave(Name),NameOfWave(Description)} 
	return ModSqlUtil#InsertComposite(TAB_TraceRating,mCols,mWave)
End Function


Static Function InsertFmtUser(mTab)
	Struct User & mTab
	String fmtStr = "'%s'"
	String final
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfUser()
	sprintf final,fmtStr,mTab.Name
	return ModSqlUtil#InsertFormatted(TAB_User,mCols,final)
End Function

Static Function InsertUser(Name)
	Wave /T Name
	Wave /T mCols= ModSqlCypherUtilFuncs#GetColsOfUser()
	Make /O/T mWave = { NameOfWave(Name)} 
	return ModSqlUtil#InsertComposite(TAB_User,mCols,mWave)
End Function



// Initialization for structures
Static Function InitExpMetaWaveStr(mStruct,[useGlobal])
	Struct ExpMetaWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_ExpMeta
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idExpUserData =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idExpUserData)
		mStruct.TimeStarted =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_TimeStarted)
		mStruct.NAttemptedPulls =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_NAttemptedPulls)
		mStruct.SourceFile =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_SourceFile)
	else
		mStruct.idExpUserData =FIELD_idExpUserData
		mStruct.TimeStarted =FIELD_TimeStarted
		mStruct.NAttemptedPulls =FIELD_NAttemptedPulls
		mStruct.SourceFile =FIELD_SourceFile
	Endif
End Function

Static Function InitExpMetaStruct(mTab,idExpUserData,TimeStarted,NAttemptedPulls,SourceFile)
Struct ExpMeta & mTab
	Variable idExpUserData
	String TimeStarted
	Variable NAttemptedPulls
	String SourceFile
	mTab.idExpUserData = idExpUserData
	mTab.TimeStarted = TimeStarted
	mTab.NAttemptedPulls = NAttemptedPulls
	mTab.SourceFile = SourceFile

End Function

Static Function InitExpUserDataWaveStr(mStruct,[useGlobal])
	Struct ExpUserDataWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_ExpUserData
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idExpUserData =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idExpUserData)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
		mStruct.idUser =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idUser)
	else
		mStruct.idExpUserData =FIELD_idExpUserData
		mStruct.Name =FIELD_Name
		mStruct.Description =FIELD_Description
		mStruct.idUser =FIELD_idUser
	Endif
End Function

Static Function InitExpUserDataStruct(mTab,idExpUserData,Name,Description,idUser)
Struct ExpUserData & mTab
	Variable idExpUserData
	String Name
	String Description
	Variable idUser
	mTab.idExpUserData = idExpUserData
	mTab.Name = Name
	mTab.Description = Description
	mTab.idUser = idUser

End Function

Static Function InitLinkDataMetaWaveStr(mStruct,[useGlobal])
	Struct LinkDataMetaWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_LinkDataMeta
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idLinkDataMeta =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idLinkDataMeta)
		mStruct.idTraceMeta =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceMeta)
		mStruct.idTraceData =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceData)
	else
		mStruct.idLinkDataMeta =FIELD_idLinkDataMeta
		mStruct.idTraceMeta =FIELD_idTraceMeta
		mStruct.idTraceData =FIELD_idTraceData
	Endif
End Function

Static Function InitLinkDataMetaStruct(mTab,idLinkDataMeta,idTraceMeta,idTraceData)
Struct LinkDataMeta & mTab
	Variable idLinkDataMeta
	Variable idTraceMeta
	Variable idTraceData
	mTab.idLinkDataMeta = idLinkDataMeta
	mTab.idTraceMeta = idTraceMeta
	mTab.idTraceData = idTraceData

End Function

Static Function InitLinkExpModelWaveStr(mStruct,[useGlobal])
	Struct LinkExpModelWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_LinkExpModel
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idLinkExpModel =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idLinkExpModel)
		mStruct.idModel =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idModel)
		mStruct.idExpUserData =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idExpUserData)
	else
		mStruct.idLinkExpModel =FIELD_idLinkExpModel
		mStruct.idModel =FIELD_idModel
		mStruct.idExpUserData =FIELD_idExpUserData
	Endif
End Function

Static Function InitLinkExpModelStruct(mTab,idLinkExpModel,idModel,idExpUserData)
Struct LinkExpModel & mTab
	Variable idLinkExpModel
	Variable idModel
	Variable idExpUserData
	mTab.idLinkExpModel = idLinkExpModel
	mTab.idModel = idModel
	mTab.idExpUserData = idExpUserData

End Function

Static Function InitLinkModelParamsWaveStr(mStruct,[useGlobal])
	Struct LinkModelParamsWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_LinkModelParams
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idLinkModelParams =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idLinkModelParams)
		mStruct.idModel =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idModel)
		mStruct.idParamMeta =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idParamMeta)
	else
		mStruct.idLinkModelParams =FIELD_idLinkModelParams
		mStruct.idModel =FIELD_idModel
		mStruct.idParamMeta =FIELD_idParamMeta
	Endif
End Function

Static Function InitLinkModelParamsStruct(mTab,idLinkModelParams,idModel,idParamMeta)
Struct LinkModelParams & mTab
	Variable idLinkModelParams
	Variable idModel
	Variable idParamMeta
	mTab.idLinkModelParams = idLinkModelParams
	mTab.idModel = idModel
	mTab.idParamMeta = idParamMeta

End Function

Static Function InitLinkModelTraceWaveStr(mStruct,[useGlobal])
	Struct LinkModelTraceWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_LinkModelTrace
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idLinkModelTrace =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idLinkModelTrace)
		mStruct.idModel =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idModel)
		mStruct.idTraceModel =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceModel)
	else
		mStruct.idLinkModelTrace =FIELD_idLinkModelTrace
		mStruct.idModel =FIELD_idModel
		mStruct.idTraceModel =FIELD_idTraceModel
	Endif
End Function

Static Function InitLinkModelTraceStruct(mTab,idLinkModelTrace,idModel,idTraceModel)
Struct LinkModelTrace & mTab
	Variable idLinkModelTrace
	Variable idModel
	Variable idTraceModel
	mTab.idLinkModelTrace = idLinkModelTrace
	mTab.idModel = idModel
	mTab.idTraceModel = idTraceModel

End Function

Static Function InitLinkMoleTraceWaveStr(mStruct,[useGlobal])
	Struct LinkMoleTraceWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_LinkMoleTrace
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idLinkMoleTrace =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idLinkMoleTrace)
		mStruct.idMolType =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idMolType)
		mStruct.idTraceMeta =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceMeta)
	else
		mStruct.idLinkMoleTrace =FIELD_idLinkMoleTrace
		mStruct.idMolType =FIELD_idMolType
		mStruct.idTraceMeta =FIELD_idTraceMeta
	Endif
End Function

Static Function InitLinkMoleTraceStruct(mTab,idLinkMoleTrace,idMolType,idTraceMeta)
Struct LinkMoleTrace & mTab
	Variable idLinkMoleTrace
	Variable idMolType
	Variable idTraceMeta
	mTab.idLinkMoleTrace = idLinkMoleTrace
	mTab.idMolType = idMolType
	mTab.idTraceMeta = idTraceMeta

End Function

Static Function InitLinkTipTraceWaveStr(mStruct,[useGlobal])
	Struct LinkTipTraceWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_LinkTipTrace
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idLinkTipTrace =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idLinkTipTrace)
		mStruct.idTipType =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTipType)
		mStruct.idTraceMeta =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceMeta)
	else
		mStruct.idLinkTipTrace =FIELD_idLinkTipTrace
		mStruct.idTipType =FIELD_idTipType
		mStruct.idTraceMeta =FIELD_idTraceMeta
	Endif
End Function

Static Function InitLinkTipTraceStruct(mTab,idLinkTipTrace,idTipType,idTraceMeta)
Struct LinkTipTrace & mTab
	Variable idLinkTipTrace
	Variable idTipType
	Variable idTraceMeta
	mTab.idLinkTipTrace = idLinkTipTrace
	mTab.idTipType = idTipType
	mTab.idTraceMeta = idTraceMeta

End Function

Static Function InitLinkTraceParamWaveStr(mStruct,[useGlobal])
	Struct LinkTraceParamWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_LinkTraceParam
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idLinkTraceParam =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idLinkTraceParam)
		mStruct.idParameterValue =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idParameterValue)
		mStruct.idTraceModel =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceModel)
	else
		mStruct.idLinkTraceParam =FIELD_idLinkTraceParam
		mStruct.idParameterValue =FIELD_idParameterValue
		mStruct.idTraceModel =FIELD_idTraceModel
	Endif
End Function

Static Function InitLinkTraceParamStruct(mTab,idLinkTraceParam,idParameterValue,idTraceModel)
Struct LinkTraceParam & mTab
	Variable idLinkTraceParam
	Variable idParameterValue
	Variable idTraceModel
	mTab.idLinkTraceParam = idLinkTraceParam
	mTab.idParameterValue = idParameterValue
	mTab.idTraceModel = idTraceModel

End Function

Static Function InitModelWaveStr(mStruct,[useGlobal])
	Struct ModelWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_Model
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idModel =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idModel)
		mStruct.ModelName =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_ModelName)
		mStruct.ModelDescription =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_ModelDescription)
	else
		mStruct.idModel =FIELD_idModel
		mStruct.ModelName =FIELD_ModelName
		mStruct.ModelDescription =FIELD_ModelDescription
	Endif
End Function

Static Function InitModelStruct(mTab,idModel,ModelName,ModelDescription)
Struct Model & mTab
	Variable idModel
	String ModelName
	String ModelDescription
	mTab.idModel = idModel
	mTab.ModelName = ModelName
	mTab.ModelDescription = ModelDescription

End Function

Static Function InitMolTypeWaveStr(mStruct,[useGlobal])
	Struct MolTypeWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_MolType
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idMolType =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idMolType)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
		mStruct.MolMass =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_MolMass)
		mStruct.idMoleculeFamily =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idMoleculeFamily)
	else
		mStruct.idMolType =FIELD_idMolType
		mStruct.Name =FIELD_Name
		mStruct.Description =FIELD_Description
		mStruct.MolMass =FIELD_MolMass
		mStruct.idMoleculeFamily =FIELD_idMoleculeFamily
	Endif
End Function

Static Function InitMolTypeStruct(mTab,idMolType,Name,Description,MolMass,idMoleculeFamily)
Struct MolType & mTab
	Variable idMolType
	String Name
	String Description
	Variable MolMass
	Variable idMoleculeFamily
	mTab.idMolType = idMolType
	mTab.Name = Name
	mTab.Description = Description
	mTab.MolMass = MolMass
	mTab.idMoleculeFamily = idMoleculeFamily

End Function

Static Function InitMoleculeFamilyWaveStr(mStruct,[useGlobal])
	Struct MoleculeFamilyWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_MoleculeFamily
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idMoleculeFamily =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idMoleculeFamily)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
	else
		mStruct.idMoleculeFamily =FIELD_idMoleculeFamily
		mStruct.Name =FIELD_Name
		mStruct.Description =FIELD_Description
	Endif
End Function

Static Function InitMoleculeFamilyStruct(mTab,idMoleculeFamily,Name,Description)
Struct MoleculeFamily & mTab
	Variable idMoleculeFamily
	String Name
	String Description
	mTab.idMoleculeFamily = idMoleculeFamily
	mTab.Name = Name
	mTab.Description = Description

End Function

Static Function InitParamMetaWaveStr(mStruct,[useGlobal])
	Struct ParamMetaWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_ParamMeta
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idParamMeta =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idParamMeta)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
		mStruct.UnitName =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_UnitName)
		mStruct.UnitAbbr =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_UnitAbbr)
		mStruct.LeadStr =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_LeadStr)
		mStruct.Prefix =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Prefix)
		mStruct.IsRepeatable =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_IsRepeatable)
		mStruct.IsPreProccess =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_IsPreProccess)
		mStruct.ParameterNumber =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_ParameterNumber)
	else
		mStruct.idParamMeta =FIELD_idParamMeta
		mStruct.Name =FIELD_Name
		mStruct.Description =FIELD_Description
		mStruct.UnitName =FIELD_UnitName
		mStruct.UnitAbbr =FIELD_UnitAbbr
		mStruct.LeadStr =FIELD_LeadStr
		mStruct.Prefix =FIELD_Prefix
		mStruct.IsRepeatable =FIELD_IsRepeatable
		mStruct.IsPreProccess =FIELD_IsPreProccess
		mStruct.ParameterNumber =FIELD_ParameterNumber
	Endif
End Function

Static Function InitParamMetaStruct(mTab,idParamMeta,Name,Description,UnitName,UnitAbbr,LeadStr,Prefix,IsRepeatable,IsPreProccess,ParameterNumber)
Struct ParamMeta & mTab
	Variable idParamMeta
	String Name
	String Description
	String UnitName
	String UnitAbbr
	String LeadStr
	String Prefix
	Variable IsRepeatable
	Variable IsPreProccess
	Variable ParameterNumber
	mTab.idParamMeta = idParamMeta
	mTab.Name = Name
	mTab.Description = Description
	mTab.UnitName = UnitName
	mTab.UnitAbbr = UnitAbbr
	mTab.LeadStr = LeadStr
	mTab.Prefix = Prefix
	mTab.IsRepeatable = IsRepeatable
	mTab.IsPreProccess = IsPreProccess
	mTab.ParameterNumber = ParameterNumber

End Function

Static Function InitParameterValueWaveStr(mStruct,[useGlobal])
	Struct ParameterValueWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_ParameterValue
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idParameterValue =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idParameterValue)
		mStruct.DataIndex =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_DataIndex)
		mStruct.StrValues =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_StrValues)
		mStruct.DataValues =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_DataValues)
		mStruct.RepeatNumber =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_RepeatNumber)
		mStruct.idTraceDataIndex =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceDataIndex)
		mStruct.idParamMeta =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idParamMeta)
	else
		mStruct.idParameterValue =FIELD_idParameterValue
		mStruct.DataIndex =FIELD_DataIndex
		mStruct.StrValues =FIELD_StrValues
		mStruct.DataValues =FIELD_DataValues
		mStruct.RepeatNumber =FIELD_RepeatNumber
		mStruct.idTraceDataIndex =FIELD_idTraceDataIndex
		mStruct.idParamMeta =FIELD_idParamMeta
	Endif
End Function

Static Function InitParameterValueStruct(mTab,idParameterValue,DataIndex,StrValues,DataValues,RepeatNumber,idTraceDataIndex,idParamMeta)
Struct ParameterValue & mTab
	Variable idParameterValue
	Variable DataIndex
	String StrValues
	Variable DataValues
	Variable RepeatNumber
	Variable idTraceDataIndex
	Variable idParamMeta
	mTab.idParameterValue = idParameterValue
	mTab.DataIndex = DataIndex
	mTab.StrValues = StrValues
	mTab.DataValues = DataValues
	mTab.RepeatNumber = RepeatNumber
	mTab.idTraceDataIndex = idTraceDataIndex
	mTab.idParamMeta = idParamMeta

End Function

Static Function InitSampleWaveStr(mStruct,[useGlobal])
	Struct SampleWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_Sample
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idSample =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idSample)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
		mStruct.ConcNanogMuL =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_ConcNanogMuL)
		mStruct.VolLoadedMuL =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_VolLoadedMuL)
		mStruct.DateDeposited =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_DateDeposited)
		mStruct.DateCreated =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_DateCreated)
		mStruct.DateRinsed =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_DateRinsed)
		mStruct.idSamplePrep =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idSamplePrep)
		mStruct.idMolType =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idMolType)
	else
		mStruct.idSample =FIELD_idSample
		mStruct.Name =FIELD_Name
		mStruct.Description =FIELD_Description
		mStruct.ConcNanogMuL =FIELD_ConcNanogMuL
		mStruct.VolLoadedMuL =FIELD_VolLoadedMuL
		mStruct.DateDeposited =FIELD_DateDeposited
		mStruct.DateCreated =FIELD_DateCreated
		mStruct.DateRinsed =FIELD_DateRinsed
		mStruct.idSamplePrep =FIELD_idSamplePrep
		mStruct.idMolType =FIELD_idMolType
	Endif
End Function

Static Function InitSampleStruct(mTab,idSample,Name,Description,ConcNanogMuL,VolLoadedMuL,DateDeposited,DateCreated,DateRinsed,idSamplePrep,idMolType)
Struct Sample & mTab
	Variable idSample
	String Name
	String Description
	Variable ConcNanogMuL
	Variable VolLoadedMuL
	String DateDeposited
	String DateCreated
	String DateRinsed
	Variable idSamplePrep
	Variable idMolType
	mTab.idSample = idSample
	mTab.Name = Name
	mTab.Description = Description
	mTab.ConcNanogMuL = ConcNanogMuL
	mTab.VolLoadedMuL = VolLoadedMuL
	mTab.DateDeposited = DateDeposited
	mTab.DateCreated = DateCreated
	mTab.DateRinsed = DateRinsed
	mTab.idSamplePrep = idSamplePrep
	mTab.idMolType = idMolType

End Function

Static Function InitSamplePrepWaveStr(mStruct,[useGlobal])
	Struct SamplePrepWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_SamplePrep
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idSamplePrep =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idSamplePrep)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
	else
		mStruct.idSamplePrep =FIELD_idSamplePrep
		mStruct.Name =FIELD_Name
		mStruct.Description =FIELD_Description
	Endif
End Function

Static Function InitSamplePrepStruct(mTab,idSamplePrep,Name,Description)
Struct SamplePrep & mTab
	Variable idSamplePrep
	String Name
	String Description
	mTab.idSamplePrep = idSamplePrep
	mTab.Name = Name
	mTab.Description = Description

End Function

Static Function InitSourceFileDirectoryWaveStr(mStruct,[useGlobal])
	Struct SourceFileDirectoryWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_SourceFileDirectory
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idSourceDir =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idSourceDir)
		mStruct.DirectoryName =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_DirectoryName)
	else
		mStruct.idSourceDir =FIELD_idSourceDir
		mStruct.DirectoryName =FIELD_DirectoryName
	Endif
End Function

Static Function InitSourceFileDirectoryStruct(mTab,idSourceDir,DirectoryName)
Struct SourceFileDirectory & mTab
	Variable idSourceDir
	String DirectoryName
	mTab.idSourceDir = idSourceDir
	mTab.DirectoryName = DirectoryName

End Function

Static Function InitTipManifestWaveStr(mStruct,[useGlobal])
	Struct TipManifestWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_TipManifest
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idTipManifest =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTipManifest)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
		mStruct.PackPosition =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_PackPosition)
		mStruct.TimeMade =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_TimeMade)
		mStruct.TimeRinsed =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_TimeRinsed)
		mStruct.idTipPrep =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTipPrep)
		mStruct.idTipType =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTipType)
		mStruct.idTipPack =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTipPack)
	else
		mStruct.idTipManifest =FIELD_idTipManifest
		mStruct.Name =FIELD_Name
		mStruct.Description =FIELD_Description
		mStruct.PackPosition =FIELD_PackPosition
		mStruct.TimeMade =FIELD_TimeMade
		mStruct.TimeRinsed =FIELD_TimeRinsed
		mStruct.idTipPrep =FIELD_idTipPrep
		mStruct.idTipType =FIELD_idTipType
		mStruct.idTipPack =FIELD_idTipPack
	Endif
End Function

Static Function InitTipManifestStruct(mTab,idTipManifest,Name,Description,PackPosition,TimeMade,TimeRinsed,idTipPrep,idTipType,idTipPack)
Struct TipManifest & mTab
	Variable idTipManifest
	String Name
	String Description
	String PackPosition
	String TimeMade
	String TimeRinsed
	Variable idTipPrep
	Variable idTipType
	Variable idTipPack
	mTab.idTipManifest = idTipManifest
	mTab.Name = Name
	mTab.Description = Description
	mTab.PackPosition = PackPosition
	mTab.TimeMade = TimeMade
	mTab.TimeRinsed = TimeRinsed
	mTab.idTipPrep = idTipPrep
	mTab.idTipType = idTipType
	mTab.idTipPack = idTipPack

End Function

Static Function InitTipPackWaveStr(mStruct,[useGlobal])
	Struct TipPackWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_TipPack
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idTipPack =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTipPack)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
	else
		mStruct.idTipPack =FIELD_idTipPack
		mStruct.Name =FIELD_Name
		mStruct.Description =FIELD_Description
	Endif
End Function

Static Function InitTipPackStruct(mTab,idTipPack,Name,Description)
Struct TipPack & mTab
	Variable idTipPack
	String Name
	String Description
	mTab.idTipPack = idTipPack
	mTab.Name = Name
	mTab.Description = Description

End Function

Static Function InitTipPrepWaveStr(mStruct,[useGlobal])
	Struct TipPrepWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_TipPrep
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idTipPrep =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTipPrep)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
		mStruct.SecondsEtchGold =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_SecondsEtchGold)
		mStruct.SecondsEtchChromium =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_SecondsEtchChromium)
	else
		mStruct.idTipPrep =FIELD_idTipPrep
		mStruct.Name =FIELD_Name
		mStruct.Description =FIELD_Description
		mStruct.SecondsEtchGold =FIELD_SecondsEtchGold
		mStruct.SecondsEtchChromium =FIELD_SecondsEtchChromium
	Endif
End Function

Static Function InitTipPrepStruct(mTab,idTipPrep,Name,Description,SecondsEtchGold,SecondsEtchChromium)
Struct TipPrep & mTab
	Variable idTipPrep
	String Name
	String Description
	Variable SecondsEtchGold
	Variable SecondsEtchChromium
	mTab.idTipPrep = idTipPrep
	mTab.Name = Name
	mTab.Description = Description
	mTab.SecondsEtchGold = SecondsEtchGold
	mTab.SecondsEtchChromium = SecondsEtchChromium

End Function

Static Function InitTipTypeWaveStr(mStruct,[useGlobal])
	Struct TipTypeWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_TipType
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idTipTypes =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTipTypes)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
	else
		mStruct.idTipTypes =FIELD_idTipTypes
		mStruct.Name =FIELD_Name
		mStruct.Description =FIELD_Description
	Endif
End Function

Static Function InitTipTypeStruct(mTab,idTipTypes,Name,Description)
Struct TipType & mTab
	Variable idTipTypes
	String Name
	String Description
	mTab.idTipTypes = idTipTypes
	mTab.Name = Name
	mTab.Description = Description

End Function

Static Function InitTraceDataWaveStr(mStruct,[useGlobal])
	Struct TraceDataWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_TraceData
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idTraceData =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceData)
		mStruct.FileName =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_FileName)
		mStruct.idExpUserData =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idExpUserData)
	else
		mStruct.idTraceData =FIELD_idTraceData
		mStruct.FileName =FIELD_FileName
		mStruct.idExpUserData =FIELD_idExpUserData
	Endif
End Function

Static Function InitTraceDataStruct(mTab,idTraceData,FileName,idExpUserData)
Struct TraceData & mTab
	Variable idTraceData
	String FileName
	Variable idExpUserData
	mTab.idTraceData = idTraceData
	mTab.FileName = FileName
	mTab.idExpUserData = idExpUserData

End Function

Static Function InitTraceDataIndexWaveStr(mStruct,[useGlobal])
	Struct TraceDataIndexWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_TraceDataIndex
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idParameterValue =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idParameterValue)
		mStruct.StartIndex =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_StartIndex)
		mStruct.EndIndex =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_EndIndex)
		mStruct.idTraceData =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceData)
	else
		mStruct.idParameterValue =FIELD_idParameterValue
		mStruct.StartIndex =FIELD_StartIndex
		mStruct.EndIndex =FIELD_EndIndex
		mStruct.idTraceData =FIELD_idTraceData
	Endif
End Function

Static Function InitTraceDataIndexStruct(mTab,idParameterValue,StartIndex,EndIndex,idTraceData)
Struct TraceDataIndex & mTab
	Variable idParameterValue
	Variable StartIndex
	Variable EndIndex
	Variable idTraceData
	mTab.idParameterValue = idParameterValue
	mTab.StartIndex = StartIndex
	mTab.EndIndex = EndIndex
	mTab.idTraceData = idTraceData

End Function

Static Function InitTraceExpLinkWaveStr(mStruct,[useGlobal])
	Struct TraceExpLinkWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_TraceExpLink
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idTraceExpLink =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceExpLink)
		mStruct.idTraceMeta =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceMeta)
		mStruct.idExpUserData =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idExpUserData)
	else
		mStruct.idTraceExpLink =FIELD_idTraceExpLink
		mStruct.idTraceMeta =FIELD_idTraceMeta
		mStruct.idExpUserData =FIELD_idExpUserData
	Endif
End Function

Static Function InitTraceExpLinkStruct(mTab,idTraceExpLink,idTraceMeta,idExpUserData)
Struct TraceExpLink & mTab
	Variable idTraceExpLink
	Variable idTraceMeta
	Variable idExpUserData
	mTab.idTraceExpLink = idTraceExpLink
	mTab.idTraceMeta = idTraceMeta
	mTab.idExpUserData = idExpUserData

End Function

Static Function InitTraceMetaWaveStr(mStruct,[useGlobal])
	Struct TraceMetaWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_TraceMeta
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idTraceMeta =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceMeta)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
		mStruct.ApproachVel =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_ApproachVel)
		mStruct.RetractVel =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_RetractVel)
		mStruct.TimeStarted =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_TimeStarted)
		mStruct.TimeEnded =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_TimeEnded)
		mStruct.DwellTowards =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_DwellTowards)
		mStruct.DwellAway =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_DwellAway)
		mStruct.SampleRate =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_SampleRate)
		mStruct.FilteredSampleRate =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_FilteredSampleRate)
		mStruct.DeflInvols =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_DeflInvols)
		mStruct.Temperature =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Temperature)
		mStruct.SpringConstant =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_SpringConstant)
		mStruct.FirstResRef =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_FirstResRef)
		mStruct.ThermalQ =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_ThermalQ)
		mStruct.LocationX =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_LocationX)
		mStruct.LocationY =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_LocationY)
		mStruct.OffsetX =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_OffsetX)
		mStruct.OffsetY =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_OffsetY)
		mStruct.Spot =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Spot)
		mStruct.idTipManifest =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTipManifest)
		mStruct.idUser =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idUser)
		mStruct.idTraceRating =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceRating)
		mStruct.idSample =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idSample)
	else
		mStruct.idTraceMeta =FIELD_idTraceMeta
		mStruct.Description =FIELD_Description
		mStruct.ApproachVel =FIELD_ApproachVel
		mStruct.RetractVel =FIELD_RetractVel
		mStruct.TimeStarted =FIELD_TimeStarted
		mStruct.TimeEnded =FIELD_TimeEnded
		mStruct.DwellTowards =FIELD_DwellTowards
		mStruct.DwellAway =FIELD_DwellAway
		mStruct.SampleRate =FIELD_SampleRate
		mStruct.FilteredSampleRate =FIELD_FilteredSampleRate
		mStruct.DeflInvols =FIELD_DeflInvols
		mStruct.Temperature =FIELD_Temperature
		mStruct.SpringConstant =FIELD_SpringConstant
		mStruct.FirstResRef =FIELD_FirstResRef
		mStruct.ThermalQ =FIELD_ThermalQ
		mStruct.LocationX =FIELD_LocationX
		mStruct.LocationY =FIELD_LocationY
		mStruct.OffsetX =FIELD_OffsetX
		mStruct.OffsetY =FIELD_OffsetY
		mStruct.Spot =FIELD_Spot
		mStruct.idTipManifest =FIELD_idTipManifest
		mStruct.idUser =FIELD_idUser
		mStruct.idTraceRating =FIELD_idTraceRating
		mStruct.idSample =FIELD_idSample
	Endif
End Function

Static Function InitTraceMetaStruct(mTab,idTraceMeta,Description,ApproachVel,RetractVel,TimeStarted,TimeEnded,DwellTowards,DwellAway,SampleRate,FilteredSampleRate,DeflInvols,Temperature,SpringConstant,FirstResRef,ThermalQ,LocationX,LocationY,OffsetX,OffsetY,Spot,idTipManifest,idUser,idTraceRating,idSample)
Struct TraceMeta & mTab
	Variable idTraceMeta
	String Description
	Variable ApproachVel
	Variable RetractVel
	String TimeStarted
	String TimeEnded
	Variable DwellTowards
	Variable DwellAway
	Variable SampleRate
	Variable FilteredSampleRate
	Variable DeflInvols
	Variable Temperature
	Variable SpringConstant
	Variable FirstResRef
	Variable ThermalQ
	Variable LocationX
	Variable LocationY
	Variable OffsetX
	Variable OffsetY
	Variable Spot
	Variable idTipManifest
	Variable idUser
	Variable idTraceRating
	Variable idSample
	mTab.idTraceMeta = idTraceMeta
	mTab.Description = Description
	mTab.ApproachVel = ApproachVel
	mTab.RetractVel = RetractVel
	mTab.TimeStarted = TimeStarted
	mTab.TimeEnded = TimeEnded
	mTab.DwellTowards = DwellTowards
	mTab.DwellAway = DwellAway
	mTab.SampleRate = SampleRate
	mTab.FilteredSampleRate = FilteredSampleRate
	mTab.DeflInvols = DeflInvols
	mTab.Temperature = Temperature
	mTab.SpringConstant = SpringConstant
	mTab.FirstResRef = FirstResRef
	mTab.ThermalQ = ThermalQ
	mTab.LocationX = LocationX
	mTab.LocationY = LocationY
	mTab.OffsetX = OffsetX
	mTab.OffsetY = OffsetY
	mTab.Spot = Spot
	mTab.idTipManifest = idTipManifest
	mTab.idUser = idUser
	mTab.idTraceRating = idTraceRating
	mTab.idSample = idSample

End Function

Static Function InitTraceModelWaveStr(mStruct,[useGlobal])
	Struct TraceModelWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_TraceModel
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idTraceModel =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceModel)
		mStruct.idTraceMeta =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceMeta)
		mStruct.idTraceData =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceData)
	else
		mStruct.idTraceModel =FIELD_idTraceModel
		mStruct.idTraceMeta =FIELD_idTraceMeta
		mStruct.idTraceData =FIELD_idTraceData
	Endif
End Function

Static Function InitTraceModelStruct(mTab,idTraceModel,idTraceMeta,idTraceData)
Struct TraceModel & mTab
	Variable idTraceModel
	Variable idTraceMeta
	Variable idTraceData
	mTab.idTraceModel = idTraceModel
	mTab.idTraceMeta = idTraceMeta
	mTab.idTraceData = idTraceData

End Function

Static Function InitTraceRatingWaveStr(mStruct,[useGlobal])
	Struct TraceRatingWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_TraceRating
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idTraceRating =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idTraceRating)
		mStruct.RatingValue =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_RatingValue)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
		mStruct.Description =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Description)
	else
		mStruct.idTraceRating =FIELD_idTraceRating
		mStruct.RatingValue =FIELD_RatingValue
		mStruct.Name =FIELD_Name
		mStruct.Description =FIELD_Description
	Endif
End Function

Static Function InitTraceRatingStruct(mTab,idTraceRating,RatingValue,Name,Description)
Struct TraceRating & mTab
	Variable idTraceRating
	Variable RatingValue
	String Name
	String Description
	mTab.idTraceRating = idTraceRating
	mTab.RatingValue = RatingValue
	mTab.Name = Name
	mTab.Description = Description

End Function

Static Function InitUserWaveStr(mStruct,[useGlobal])
	Struct UserWaveStr & mStruct
	Variable useGlobal
	String mTab = TAB_User
	useGlobal = ParamIsDefault(useGlobal) ? ModDefine#True() : useGlobal
	if(useGlobal)
		mStruct.idUser =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_idUser)
		mStruct.Name =ModSqlCypherInterface#GetFieldWaveName(mTab,FIELD_Name)
	else
		mStruct.idUser =FIELD_idUser
		mStruct.Name =FIELD_Name
	Endif
End Function

Static Function InitUserStruct(mTab,idUser,Name)
Struct User & mTab
	Variable idUser
	String Name
	mTab.idUser = idUser
	mTab.Name = Name

End Function


// Conversion functions
Static Function ExpMetaToTextStruct(refWave,strWave)
	Struct ExpMetaWaveRef & refWave
	Struct ExpMetaWaveStr & strWave
	strWave.idExpUserData=ModSqlCypherInterface#GetPathFromWave(refWave.idExpUserData)
	strWave.TimeStarted=ModSqlCypherInterface#GetPathFromWave(refWave.TimeStarted)
	strWave.NAttemptedPulls=ModSqlCypherInterface#GetPathFromWave(refWave.NAttemptedPulls)
	strWave.SourceFile=ModSqlCypherInterface#GetPathFromWave(refWave.SourceFile)
End Function

Static Function ExpMetaToWaveStruct(strWave,refWave)
	Struct ExpMetaWaveStr & strWave
	Struct ExpMetaWaveRef & refWave
	Wave /D refWave.idExpUserData=ModSqlCypherInterface#SqlWaveRef(strWave.idExpUserData)
	Wave /T refWave.TimeStarted=ModSqlCypherInterface#SqlWaveRef(strWave.TimeStarted)
	Wave /D refWave.NAttemptedPulls=ModSqlCypherInterface#SqlWaveRef(strWave.NAttemptedPulls)
	Wave /T refWave.SourceFile=ModSqlCypherInterface#SqlWaveRef(strWave.SourceFile)
End Function


Static Function ExpUserDataToTextStruct(refWave,strWave)
	Struct ExpUserDataWaveRef & refWave
	Struct ExpUserDataWaveStr & strWave
	strWave.idExpUserData=ModSqlCypherInterface#GetPathFromWave(refWave.idExpUserData)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
	strWave.idUser=ModSqlCypherInterface#GetPathFromWave(refWave.idUser)
End Function

Static Function ExpUserDataToWaveStruct(strWave,refWave)
	Struct ExpUserDataWaveStr & strWave
	Struct ExpUserDataWaveRef & refWave
	Wave /D refWave.idExpUserData=ModSqlCypherInterface#SqlWaveRef(strWave.idExpUserData)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
	Wave /D refWave.idUser=ModSqlCypherInterface#SqlWaveRef(strWave.idUser)
End Function


Static Function LinkDataMetaToTextStruct(refWave,strWave)
	Struct LinkDataMetaWaveRef & refWave
	Struct LinkDataMetaWaveStr & strWave
	strWave.idLinkDataMeta=ModSqlCypherInterface#GetPathFromWave(refWave.idLinkDataMeta)
	strWave.idTraceMeta=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceMeta)
	strWave.idTraceData=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceData)
End Function

Static Function LinkDataMetaToWaveStruct(strWave,refWave)
	Struct LinkDataMetaWaveStr & strWave
	Struct LinkDataMetaWaveRef & refWave
	Wave /D refWave.idLinkDataMeta=ModSqlCypherInterface#SqlWaveRef(strWave.idLinkDataMeta)
	Wave /D refWave.idTraceMeta=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceMeta)
	Wave /D refWave.idTraceData=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceData)
End Function


Static Function LinkExpModelToTextStruct(refWave,strWave)
	Struct LinkExpModelWaveRef & refWave
	Struct LinkExpModelWaveStr & strWave
	strWave.idLinkExpModel=ModSqlCypherInterface#GetPathFromWave(refWave.idLinkExpModel)
	strWave.idModel=ModSqlCypherInterface#GetPathFromWave(refWave.idModel)
	strWave.idExpUserData=ModSqlCypherInterface#GetPathFromWave(refWave.idExpUserData)
End Function

Static Function LinkExpModelToWaveStruct(strWave,refWave)
	Struct LinkExpModelWaveStr & strWave
	Struct LinkExpModelWaveRef & refWave
	Wave /D refWave.idLinkExpModel=ModSqlCypherInterface#SqlWaveRef(strWave.idLinkExpModel)
	Wave /D refWave.idModel=ModSqlCypherInterface#SqlWaveRef(strWave.idModel)
	Wave /D refWave.idExpUserData=ModSqlCypherInterface#SqlWaveRef(strWave.idExpUserData)
End Function


Static Function LinkModelParamsToTextStruct(refWave,strWave)
	Struct LinkModelParamsWaveRef & refWave
	Struct LinkModelParamsWaveStr & strWave
	strWave.idLinkModelParams=ModSqlCypherInterface#GetPathFromWave(refWave.idLinkModelParams)
	strWave.idModel=ModSqlCypherInterface#GetPathFromWave(refWave.idModel)
	strWave.idParamMeta=ModSqlCypherInterface#GetPathFromWave(refWave.idParamMeta)
End Function

Static Function LinkModelParamsToWaveStruct(strWave,refWave)
	Struct LinkModelParamsWaveStr & strWave
	Struct LinkModelParamsWaveRef & refWave
	Wave /D refWave.idLinkModelParams=ModSqlCypherInterface#SqlWaveRef(strWave.idLinkModelParams)
	Wave /D refWave.idModel=ModSqlCypherInterface#SqlWaveRef(strWave.idModel)
	Wave /D refWave.idParamMeta=ModSqlCypherInterface#SqlWaveRef(strWave.idParamMeta)
End Function


Static Function LinkModelTraceToTextStruct(refWave,strWave)
	Struct LinkModelTraceWaveRef & refWave
	Struct LinkModelTraceWaveStr & strWave
	strWave.idLinkModelTrace=ModSqlCypherInterface#GetPathFromWave(refWave.idLinkModelTrace)
	strWave.idModel=ModSqlCypherInterface#GetPathFromWave(refWave.idModel)
	strWave.idTraceModel=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceModel)
End Function

Static Function LinkModelTraceToWaveStruct(strWave,refWave)
	Struct LinkModelTraceWaveStr & strWave
	Struct LinkModelTraceWaveRef & refWave
	Wave /D refWave.idLinkModelTrace=ModSqlCypherInterface#SqlWaveRef(strWave.idLinkModelTrace)
	Wave /D refWave.idModel=ModSqlCypherInterface#SqlWaveRef(strWave.idModel)
	Wave /D refWave.idTraceModel=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceModel)
End Function


Static Function LinkMoleTraceToTextStruct(refWave,strWave)
	Struct LinkMoleTraceWaveRef & refWave
	Struct LinkMoleTraceWaveStr & strWave
	strWave.idLinkMoleTrace=ModSqlCypherInterface#GetPathFromWave(refWave.idLinkMoleTrace)
	strWave.idMolType=ModSqlCypherInterface#GetPathFromWave(refWave.idMolType)
	strWave.idTraceMeta=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceMeta)
End Function

Static Function LinkMoleTraceToWaveStruct(strWave,refWave)
	Struct LinkMoleTraceWaveStr & strWave
	Struct LinkMoleTraceWaveRef & refWave
	Wave /D refWave.idLinkMoleTrace=ModSqlCypherInterface#SqlWaveRef(strWave.idLinkMoleTrace)
	Wave /D refWave.idMolType=ModSqlCypherInterface#SqlWaveRef(strWave.idMolType)
	Wave /D refWave.idTraceMeta=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceMeta)
End Function


Static Function LinkTipTraceToTextStruct(refWave,strWave)
	Struct LinkTipTraceWaveRef & refWave
	Struct LinkTipTraceWaveStr & strWave
	strWave.idLinkTipTrace=ModSqlCypherInterface#GetPathFromWave(refWave.idLinkTipTrace)
	strWave.idTipType=ModSqlCypherInterface#GetPathFromWave(refWave.idTipType)
	strWave.idTraceMeta=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceMeta)
End Function

Static Function LinkTipTraceToWaveStruct(strWave,refWave)
	Struct LinkTipTraceWaveStr & strWave
	Struct LinkTipTraceWaveRef & refWave
	Wave /D refWave.idLinkTipTrace=ModSqlCypherInterface#SqlWaveRef(strWave.idLinkTipTrace)
	Wave /D refWave.idTipType=ModSqlCypherInterface#SqlWaveRef(strWave.idTipType)
	Wave /D refWave.idTraceMeta=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceMeta)
End Function


Static Function LinkTraceParamToTextStruct(refWave,strWave)
	Struct LinkTraceParamWaveRef & refWave
	Struct LinkTraceParamWaveStr & strWave
	strWave.idLinkTraceParam=ModSqlCypherInterface#GetPathFromWave(refWave.idLinkTraceParam)
	strWave.idParameterValue=ModSqlCypherInterface#GetPathFromWave(refWave.idParameterValue)
	strWave.idTraceModel=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceModel)
End Function

Static Function LinkTraceParamToWaveStruct(strWave,refWave)
	Struct LinkTraceParamWaveStr & strWave
	Struct LinkTraceParamWaveRef & refWave
	Wave /D refWave.idLinkTraceParam=ModSqlCypherInterface#SqlWaveRef(strWave.idLinkTraceParam)
	Wave /D refWave.idParameterValue=ModSqlCypherInterface#SqlWaveRef(strWave.idParameterValue)
	Wave /D refWave.idTraceModel=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceModel)
End Function


Static Function ModelToTextStruct(refWave,strWave)
	Struct ModelWaveRef & refWave
	Struct ModelWaveStr & strWave
	strWave.idModel=ModSqlCypherInterface#GetPathFromWave(refWave.idModel)
	strWave.ModelName=ModSqlCypherInterface#GetPathFromWave(refWave.ModelName)
	strWave.ModelDescription=ModSqlCypherInterface#GetPathFromWave(refWave.ModelDescription)
End Function

Static Function ModelToWaveStruct(strWave,refWave)
	Struct ModelWaveStr & strWave
	Struct ModelWaveRef & refWave
	Wave /D refWave.idModel=ModSqlCypherInterface#SqlWaveRef(strWave.idModel)
	Wave /T refWave.ModelName=ModSqlCypherInterface#SqlWaveRef(strWave.ModelName)
	Wave /T refWave.ModelDescription=ModSqlCypherInterface#SqlWaveRef(strWave.ModelDescription)
End Function


Static Function MolTypeToTextStruct(refWave,strWave)
	Struct MolTypeWaveRef & refWave
	Struct MolTypeWaveStr & strWave
	strWave.idMolType=ModSqlCypherInterface#GetPathFromWave(refWave.idMolType)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
	strWave.MolMass=ModSqlCypherInterface#GetPathFromWave(refWave.MolMass)
	strWave.idMoleculeFamily=ModSqlCypherInterface#GetPathFromWave(refWave.idMoleculeFamily)
End Function

Static Function MolTypeToWaveStruct(strWave,refWave)
	Struct MolTypeWaveStr & strWave
	Struct MolTypeWaveRef & refWave
	Wave /D refWave.idMolType=ModSqlCypherInterface#SqlWaveRef(strWave.idMolType)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
	Wave /D refWave.MolMass=ModSqlCypherInterface#SqlWaveRef(strWave.MolMass)
	Wave /D refWave.idMoleculeFamily=ModSqlCypherInterface#SqlWaveRef(strWave.idMoleculeFamily)
End Function


Static Function MoleculeFamilyToTextStruct(refWave,strWave)
	Struct MoleculeFamilyWaveRef & refWave
	Struct MoleculeFamilyWaveStr & strWave
	strWave.idMoleculeFamily=ModSqlCypherInterface#GetPathFromWave(refWave.idMoleculeFamily)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
End Function

Static Function MoleculeFamilyToWaveStruct(strWave,refWave)
	Struct MoleculeFamilyWaveStr & strWave
	Struct MoleculeFamilyWaveRef & refWave
	Wave /D refWave.idMoleculeFamily=ModSqlCypherInterface#SqlWaveRef(strWave.idMoleculeFamily)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
End Function


Static Function ParamMetaToTextStruct(refWave,strWave)
	Struct ParamMetaWaveRef & refWave
	Struct ParamMetaWaveStr & strWave
	strWave.idParamMeta=ModSqlCypherInterface#GetPathFromWave(refWave.idParamMeta)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
	strWave.UnitName=ModSqlCypherInterface#GetPathFromWave(refWave.UnitName)
	strWave.UnitAbbr=ModSqlCypherInterface#GetPathFromWave(refWave.UnitAbbr)
	strWave.LeadStr=ModSqlCypherInterface#GetPathFromWave(refWave.LeadStr)
	strWave.Prefix=ModSqlCypherInterface#GetPathFromWave(refWave.Prefix)
	strWave.IsRepeatable=ModSqlCypherInterface#GetPathFromWave(refWave.IsRepeatable)
	strWave.IsPreProccess=ModSqlCypherInterface#GetPathFromWave(refWave.IsPreProccess)
	strWave.ParameterNumber=ModSqlCypherInterface#GetPathFromWave(refWave.ParameterNumber)
End Function

Static Function ParamMetaToWaveStruct(strWave,refWave)
	Struct ParamMetaWaveStr & strWave
	Struct ParamMetaWaveRef & refWave
	Wave /D refWave.idParamMeta=ModSqlCypherInterface#SqlWaveRef(strWave.idParamMeta)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
	Wave /T refWave.UnitName=ModSqlCypherInterface#SqlWaveRef(strWave.UnitName)
	Wave /T refWave.UnitAbbr=ModSqlCypherInterface#SqlWaveRef(strWave.UnitAbbr)
	Wave /T refWave.LeadStr=ModSqlCypherInterface#SqlWaveRef(strWave.LeadStr)
	Wave /T refWave.Prefix=ModSqlCypherInterface#SqlWaveRef(strWave.Prefix)
	Wave /D refWave.IsRepeatable=ModSqlCypherInterface#SqlWaveRef(strWave.IsRepeatable)
	Wave /D refWave.IsPreProccess=ModSqlCypherInterface#SqlWaveRef(strWave.IsPreProccess)
	Wave /D refWave.ParameterNumber=ModSqlCypherInterface#SqlWaveRef(strWave.ParameterNumber)
End Function


Static Function ParameterValueToTextStruct(refWave,strWave)
	Struct ParameterValueWaveRef & refWave
	Struct ParameterValueWaveStr & strWave
	strWave.idParameterValue=ModSqlCypherInterface#GetPathFromWave(refWave.idParameterValue)
	strWave.DataIndex=ModSqlCypherInterface#GetPathFromWave(refWave.DataIndex)
	strWave.StrValues=ModSqlCypherInterface#GetPathFromWave(refWave.StrValues)
	strWave.DataValues=ModSqlCypherInterface#GetPathFromWave(refWave.DataValues)
	strWave.RepeatNumber=ModSqlCypherInterface#GetPathFromWave(refWave.RepeatNumber)
	strWave.idTraceDataIndex=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceDataIndex)
	strWave.idParamMeta=ModSqlCypherInterface#GetPathFromWave(refWave.idParamMeta)
End Function

Static Function ParameterValueToWaveStruct(strWave,refWave)
	Struct ParameterValueWaveStr & strWave
	Struct ParameterValueWaveRef & refWave
	Wave /D refWave.idParameterValue=ModSqlCypherInterface#SqlWaveRef(strWave.idParameterValue)
	Wave /D refWave.DataIndex=ModSqlCypherInterface#SqlWaveRef(strWave.DataIndex)
	Wave /T refWave.StrValues=ModSqlCypherInterface#SqlWaveRef(strWave.StrValues)
	Wave /D refWave.DataValues=ModSqlCypherInterface#SqlWaveRef(strWave.DataValues)
	Wave /D refWave.RepeatNumber=ModSqlCypherInterface#SqlWaveRef(strWave.RepeatNumber)
	Wave /D refWave.idTraceDataIndex=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceDataIndex)
	Wave /D refWave.idParamMeta=ModSqlCypherInterface#SqlWaveRef(strWave.idParamMeta)
End Function


Static Function SampleToTextStruct(refWave,strWave)
	Struct SampleWaveRef & refWave
	Struct SampleWaveStr & strWave
	strWave.idSample=ModSqlCypherInterface#GetPathFromWave(refWave.idSample)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
	strWave.ConcNanogMuL=ModSqlCypherInterface#GetPathFromWave(refWave.ConcNanogMuL)
	strWave.VolLoadedMuL=ModSqlCypherInterface#GetPathFromWave(refWave.VolLoadedMuL)
	strWave.DateDeposited=ModSqlCypherInterface#GetPathFromWave(refWave.DateDeposited)
	strWave.DateCreated=ModSqlCypherInterface#GetPathFromWave(refWave.DateCreated)
	strWave.DateRinsed=ModSqlCypherInterface#GetPathFromWave(refWave.DateRinsed)
	strWave.idSamplePrep=ModSqlCypherInterface#GetPathFromWave(refWave.idSamplePrep)
	strWave.idMolType=ModSqlCypherInterface#GetPathFromWave(refWave.idMolType)
End Function

Static Function SampleToWaveStruct(strWave,refWave)
	Struct SampleWaveStr & strWave
	Struct SampleWaveRef & refWave
	Wave /D refWave.idSample=ModSqlCypherInterface#SqlWaveRef(strWave.idSample)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
	Wave /D refWave.ConcNanogMuL=ModSqlCypherInterface#SqlWaveRef(strWave.ConcNanogMuL)
	Wave /D refWave.VolLoadedMuL=ModSqlCypherInterface#SqlWaveRef(strWave.VolLoadedMuL)
	Wave /T refWave.DateDeposited=ModSqlCypherInterface#SqlWaveRef(strWave.DateDeposited)
	Wave /T refWave.DateCreated=ModSqlCypherInterface#SqlWaveRef(strWave.DateCreated)
	Wave /T refWave.DateRinsed=ModSqlCypherInterface#SqlWaveRef(strWave.DateRinsed)
	Wave /D refWave.idSamplePrep=ModSqlCypherInterface#SqlWaveRef(strWave.idSamplePrep)
	Wave /D refWave.idMolType=ModSqlCypherInterface#SqlWaveRef(strWave.idMolType)
End Function


Static Function SamplePrepToTextStruct(refWave,strWave)
	Struct SamplePrepWaveRef & refWave
	Struct SamplePrepWaveStr & strWave
	strWave.idSamplePrep=ModSqlCypherInterface#GetPathFromWave(refWave.idSamplePrep)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
End Function

Static Function SamplePrepToWaveStruct(strWave,refWave)
	Struct SamplePrepWaveStr & strWave
	Struct SamplePrepWaveRef & refWave
	Wave /D refWave.idSamplePrep=ModSqlCypherInterface#SqlWaveRef(strWave.idSamplePrep)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
End Function


Static Function SourceFileDirectoryToTextStruct(refWave,strWave)
	Struct SourceFileDirectoryWaveRef & refWave
	Struct SourceFileDirectoryWaveStr & strWave
	strWave.idSourceDir=ModSqlCypherInterface#GetPathFromWave(refWave.idSourceDir)
	strWave.DirectoryName=ModSqlCypherInterface#GetPathFromWave(refWave.DirectoryName)
End Function

Static Function SourceFileDirectoryToWaveStruct(strWave,refWave)
	Struct SourceFileDirectoryWaveStr & strWave
	Struct SourceFileDirectoryWaveRef & refWave
	Wave /D refWave.idSourceDir=ModSqlCypherInterface#SqlWaveRef(strWave.idSourceDir)
	Wave /T refWave.DirectoryName=ModSqlCypherInterface#SqlWaveRef(strWave.DirectoryName)
End Function


Static Function TipManifestToTextStruct(refWave,strWave)
	Struct TipManifestWaveRef & refWave
	Struct TipManifestWaveStr & strWave
	strWave.idTipManifest=ModSqlCypherInterface#GetPathFromWave(refWave.idTipManifest)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
	strWave.PackPosition=ModSqlCypherInterface#GetPathFromWave(refWave.PackPosition)
	strWave.TimeMade=ModSqlCypherInterface#GetPathFromWave(refWave.TimeMade)
	strWave.TimeRinsed=ModSqlCypherInterface#GetPathFromWave(refWave.TimeRinsed)
	strWave.idTipPrep=ModSqlCypherInterface#GetPathFromWave(refWave.idTipPrep)
	strWave.idTipType=ModSqlCypherInterface#GetPathFromWave(refWave.idTipType)
	strWave.idTipPack=ModSqlCypherInterface#GetPathFromWave(refWave.idTipPack)
End Function

Static Function TipManifestToWaveStruct(strWave,refWave)
	Struct TipManifestWaveStr & strWave
	Struct TipManifestWaveRef & refWave
	Wave /D refWave.idTipManifest=ModSqlCypherInterface#SqlWaveRef(strWave.idTipManifest)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
	Wave /T refWave.PackPosition=ModSqlCypherInterface#SqlWaveRef(strWave.PackPosition)
	Wave /T refWave.TimeMade=ModSqlCypherInterface#SqlWaveRef(strWave.TimeMade)
	Wave /T refWave.TimeRinsed=ModSqlCypherInterface#SqlWaveRef(strWave.TimeRinsed)
	Wave /D refWave.idTipPrep=ModSqlCypherInterface#SqlWaveRef(strWave.idTipPrep)
	Wave /D refWave.idTipType=ModSqlCypherInterface#SqlWaveRef(strWave.idTipType)
	Wave /D refWave.idTipPack=ModSqlCypherInterface#SqlWaveRef(strWave.idTipPack)
End Function


Static Function TipPackToTextStruct(refWave,strWave)
	Struct TipPackWaveRef & refWave
	Struct TipPackWaveStr & strWave
	strWave.idTipPack=ModSqlCypherInterface#GetPathFromWave(refWave.idTipPack)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
End Function

Static Function TipPackToWaveStruct(strWave,refWave)
	Struct TipPackWaveStr & strWave
	Struct TipPackWaveRef & refWave
	Wave /D refWave.idTipPack=ModSqlCypherInterface#SqlWaveRef(strWave.idTipPack)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
End Function


Static Function TipPrepToTextStruct(refWave,strWave)
	Struct TipPrepWaveRef & refWave
	Struct TipPrepWaveStr & strWave
	strWave.idTipPrep=ModSqlCypherInterface#GetPathFromWave(refWave.idTipPrep)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
	strWave.SecondsEtchGold=ModSqlCypherInterface#GetPathFromWave(refWave.SecondsEtchGold)
	strWave.SecondsEtchChromium=ModSqlCypherInterface#GetPathFromWave(refWave.SecondsEtchChromium)
End Function

Static Function TipPrepToWaveStruct(strWave,refWave)
	Struct TipPrepWaveStr & strWave
	Struct TipPrepWaveRef & refWave
	Wave /D refWave.idTipPrep=ModSqlCypherInterface#SqlWaveRef(strWave.idTipPrep)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
	Wave /D refWave.SecondsEtchGold=ModSqlCypherInterface#SqlWaveRef(strWave.SecondsEtchGold)
	Wave /D refWave.SecondsEtchChromium=ModSqlCypherInterface#SqlWaveRef(strWave.SecondsEtchChromium)
End Function


Static Function TipTypeToTextStruct(refWave,strWave)
	Struct TipTypeWaveRef & refWave
	Struct TipTypeWaveStr & strWave
	strWave.idTipTypes=ModSqlCypherInterface#GetPathFromWave(refWave.idTipTypes)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
End Function

Static Function TipTypeToWaveStruct(strWave,refWave)
	Struct TipTypeWaveStr & strWave
	Struct TipTypeWaveRef & refWave
	Wave /D refWave.idTipTypes=ModSqlCypherInterface#SqlWaveRef(strWave.idTipTypes)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
End Function


Static Function TraceDataToTextStruct(refWave,strWave)
	Struct TraceDataWaveRef & refWave
	Struct TraceDataWaveStr & strWave
	strWave.idTraceData=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceData)
	strWave.FileName=ModSqlCypherInterface#GetPathFromWave(refWave.FileName)
	strWave.idExpUserData=ModSqlCypherInterface#GetPathFromWave(refWave.idExpUserData)
End Function

Static Function TraceDataToWaveStruct(strWave,refWave)
	Struct TraceDataWaveStr & strWave
	Struct TraceDataWaveRef & refWave
	Wave /D refWave.idTraceData=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceData)
	Wave /T refWave.FileName=ModSqlCypherInterface#SqlWaveRef(strWave.FileName)
	Wave /D refWave.idExpUserData=ModSqlCypherInterface#SqlWaveRef(strWave.idExpUserData)
End Function


Static Function TraceDataIndexToTextStruct(refWave,strWave)
	Struct TraceDataIndexWaveRef & refWave
	Struct TraceDataIndexWaveStr & strWave
	strWave.idParameterValue=ModSqlCypherInterface#GetPathFromWave(refWave.idParameterValue)
	strWave.StartIndex=ModSqlCypherInterface#GetPathFromWave(refWave.StartIndex)
	strWave.EndIndex=ModSqlCypherInterface#GetPathFromWave(refWave.EndIndex)
	strWave.idTraceData=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceData)
End Function

Static Function TraceDataIndexToWaveStruct(strWave,refWave)
	Struct TraceDataIndexWaveStr & strWave
	Struct TraceDataIndexWaveRef & refWave
	Wave /D refWave.idParameterValue=ModSqlCypherInterface#SqlWaveRef(strWave.idParameterValue)
	Wave /D refWave.StartIndex=ModSqlCypherInterface#SqlWaveRef(strWave.StartIndex)
	Wave /D refWave.EndIndex=ModSqlCypherInterface#SqlWaveRef(strWave.EndIndex)
	Wave /D refWave.idTraceData=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceData)
End Function


Static Function TraceExpLinkToTextStruct(refWave,strWave)
	Struct TraceExpLinkWaveRef & refWave
	Struct TraceExpLinkWaveStr & strWave
	strWave.idTraceExpLink=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceExpLink)
	strWave.idTraceMeta=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceMeta)
	strWave.idExpUserData=ModSqlCypherInterface#GetPathFromWave(refWave.idExpUserData)
End Function

Static Function TraceExpLinkToWaveStruct(strWave,refWave)
	Struct TraceExpLinkWaveStr & strWave
	Struct TraceExpLinkWaveRef & refWave
	Wave /D refWave.idTraceExpLink=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceExpLink)
	Wave /D refWave.idTraceMeta=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceMeta)
	Wave /D refWave.idExpUserData=ModSqlCypherInterface#SqlWaveRef(strWave.idExpUserData)
End Function


Static Function TraceMetaToTextStruct(refWave,strWave)
	Struct TraceMetaWaveRef & refWave
	Struct TraceMetaWaveStr & strWave
	strWave.idTraceMeta=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceMeta)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
	strWave.ApproachVel=ModSqlCypherInterface#GetPathFromWave(refWave.ApproachVel)
	strWave.RetractVel=ModSqlCypherInterface#GetPathFromWave(refWave.RetractVel)
	strWave.TimeStarted=ModSqlCypherInterface#GetPathFromWave(refWave.TimeStarted)
	strWave.TimeEnded=ModSqlCypherInterface#GetPathFromWave(refWave.TimeEnded)
	strWave.DwellTowards=ModSqlCypherInterface#GetPathFromWave(refWave.DwellTowards)
	strWave.DwellAway=ModSqlCypherInterface#GetPathFromWave(refWave.DwellAway)
	strWave.SampleRate=ModSqlCypherInterface#GetPathFromWave(refWave.SampleRate)
	strWave.FilteredSampleRate=ModSqlCypherInterface#GetPathFromWave(refWave.FilteredSampleRate)
	strWave.DeflInvols=ModSqlCypherInterface#GetPathFromWave(refWave.DeflInvols)
	strWave.Temperature=ModSqlCypherInterface#GetPathFromWave(refWave.Temperature)
	strWave.SpringConstant=ModSqlCypherInterface#GetPathFromWave(refWave.SpringConstant)
	strWave.FirstResRef=ModSqlCypherInterface#GetPathFromWave(refWave.FirstResRef)
	strWave.ThermalQ=ModSqlCypherInterface#GetPathFromWave(refWave.ThermalQ)
	strWave.LocationX=ModSqlCypherInterface#GetPathFromWave(refWave.LocationX)
	strWave.LocationY=ModSqlCypherInterface#GetPathFromWave(refWave.LocationY)
	strWave.OffsetX=ModSqlCypherInterface#GetPathFromWave(refWave.OffsetX)
	strWave.OffsetY=ModSqlCypherInterface#GetPathFromWave(refWave.OffsetY)
	strWave.Spot=ModSqlCypherInterface#GetPathFromWave(refWave.Spot)
	strWave.idTipManifest=ModSqlCypherInterface#GetPathFromWave(refWave.idTipManifest)
	strWave.idUser=ModSqlCypherInterface#GetPathFromWave(refWave.idUser)
	strWave.idTraceRating=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceRating)
	strWave.idSample=ModSqlCypherInterface#GetPathFromWave(refWave.idSample)
End Function

Static Function TraceMetaToWaveStruct(strWave,refWave)
	Struct TraceMetaWaveStr & strWave
	Struct TraceMetaWaveRef & refWave
	Wave /D refWave.idTraceMeta=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceMeta)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
	Wave /D refWave.ApproachVel=ModSqlCypherInterface#SqlWaveRef(strWave.ApproachVel)
	Wave /D refWave.RetractVel=ModSqlCypherInterface#SqlWaveRef(strWave.RetractVel)
	Wave /T refWave.TimeStarted=ModSqlCypherInterface#SqlWaveRef(strWave.TimeStarted)
	Wave /T refWave.TimeEnded=ModSqlCypherInterface#SqlWaveRef(strWave.TimeEnded)
	Wave /D refWave.DwellTowards=ModSqlCypherInterface#SqlWaveRef(strWave.DwellTowards)
	Wave /D refWave.DwellAway=ModSqlCypherInterface#SqlWaveRef(strWave.DwellAway)
	Wave /D refWave.SampleRate=ModSqlCypherInterface#SqlWaveRef(strWave.SampleRate)
	Wave /D refWave.FilteredSampleRate=ModSqlCypherInterface#SqlWaveRef(strWave.FilteredSampleRate)
	Wave /D refWave.DeflInvols=ModSqlCypherInterface#SqlWaveRef(strWave.DeflInvols)
	Wave /D refWave.Temperature=ModSqlCypherInterface#SqlWaveRef(strWave.Temperature)
	Wave /D refWave.SpringConstant=ModSqlCypherInterface#SqlWaveRef(strWave.SpringConstant)
	Wave /D refWave.FirstResRef=ModSqlCypherInterface#SqlWaveRef(strWave.FirstResRef)
	Wave /D refWave.ThermalQ=ModSqlCypherInterface#SqlWaveRef(strWave.ThermalQ)
	Wave /D refWave.LocationX=ModSqlCypherInterface#SqlWaveRef(strWave.LocationX)
	Wave /D refWave.LocationY=ModSqlCypherInterface#SqlWaveRef(strWave.LocationY)
	Wave /D refWave.OffsetX=ModSqlCypherInterface#SqlWaveRef(strWave.OffsetX)
	Wave /D refWave.OffsetY=ModSqlCypherInterface#SqlWaveRef(strWave.OffsetY)
	Wave /D refWave.Spot=ModSqlCypherInterface#SqlWaveRef(strWave.Spot)
	Wave /D refWave.idTipManifest=ModSqlCypherInterface#SqlWaveRef(strWave.idTipManifest)
	Wave /D refWave.idUser=ModSqlCypherInterface#SqlWaveRef(strWave.idUser)
	Wave /D refWave.idTraceRating=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceRating)
	Wave /D refWave.idSample=ModSqlCypherInterface#SqlWaveRef(strWave.idSample)
End Function


Static Function TraceModelToTextStruct(refWave,strWave)
	Struct TraceModelWaveRef & refWave
	Struct TraceModelWaveStr & strWave
	strWave.idTraceModel=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceModel)
	strWave.idTraceMeta=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceMeta)
	strWave.idTraceData=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceData)
End Function

Static Function TraceModelToWaveStruct(strWave,refWave)
	Struct TraceModelWaveStr & strWave
	Struct TraceModelWaveRef & refWave
	Wave /D refWave.idTraceModel=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceModel)
	Wave /D refWave.idTraceMeta=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceMeta)
	Wave /D refWave.idTraceData=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceData)
End Function


Static Function TraceRatingToTextStruct(refWave,strWave)
	Struct TraceRatingWaveRef & refWave
	Struct TraceRatingWaveStr & strWave
	strWave.idTraceRating=ModSqlCypherInterface#GetPathFromWave(refWave.idTraceRating)
	strWave.RatingValue=ModSqlCypherInterface#GetPathFromWave(refWave.RatingValue)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
	strWave.Description=ModSqlCypherInterface#GetPathFromWave(refWave.Description)
End Function

Static Function TraceRatingToWaveStruct(strWave,refWave)
	Struct TraceRatingWaveStr & strWave
	Struct TraceRatingWaveRef & refWave
	Wave /D refWave.idTraceRating=ModSqlCypherInterface#SqlWaveRef(strWave.idTraceRating)
	Wave /D refWave.RatingValue=ModSqlCypherInterface#SqlWaveRef(strWave.RatingValue)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
	Wave /T refWave.Description=ModSqlCypherInterface#SqlWaveRef(strWave.Description)
End Function


Static Function UserToTextStruct(refWave,strWave)
	Struct UserWaveRef & refWave
	Struct UserWaveStr & strWave
	strWave.idUser=ModSqlCypherInterface#GetPathFromWave(refWave.idUser)
	strWave.Name=ModSqlCypherInterface#GetPathFromWave(refWave.Name)
End Function

Static Function UserToWaveStruct(strWave,refWave)
	Struct UserWaveStr & strWave
	Struct UserWaveRef & refWave
	Wave /D refWave.idUser=ModSqlCypherInterface#SqlWaveRef(strWave.idUser)
	Wave /T refWave.Name=ModSqlCypherInterface#SqlWaveRef(strWave.Name)
End Function



// Select functions
Static Function SimpleSelectExpMeta(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct ExpMetaWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitExpMetaWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfExpMeta(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idExpUserData,mTab.TimeStarted,mTab.NAttemptedPulls,mTab.SourceFile}
	ModSqlCypherInterface#SelectIntoWaves(TAB_ExpMeta,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectExpMeta(mTab)
	Struct ExpMetaWaveRef & mTab
	Struct ExpMetaWaveStr mTextTab
	ExpMetaToTextStruct(mTab,mTextTab)
	SimpleSelectExpMeta(mTextTab)
End Function


Static Function SimpleSelectExpUserData(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct ExpUserDataWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitExpUserDataWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfExpUserData(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idExpUserData,mTab.Name,mTab.Description,mTab.idUser}
	ModSqlCypherInterface#SelectIntoWaves(TAB_ExpUserData,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectExpUserData(mTab)
	Struct ExpUserDataWaveRef & mTab
	Struct ExpUserDataWaveStr mTextTab
	ExpUserDataToTextStruct(mTab,mTextTab)
	SimpleSelectExpUserData(mTextTab)
End Function


Static Function SimpleSelectLinkDataMeta(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct LinkDataMetaWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitLinkDataMetaWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkDataMeta(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idLinkDataMeta,mTab.idTraceMeta,mTab.idTraceData}
	ModSqlCypherInterface#SelectIntoWaves(TAB_LinkDataMeta,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectLinkDataMeta(mTab)
	Struct LinkDataMetaWaveRef & mTab
	Struct LinkDataMetaWaveStr mTextTab
	LinkDataMetaToTextStruct(mTab,mTextTab)
	SimpleSelectLinkDataMeta(mTextTab)
End Function


Static Function SimpleSelectLinkExpModel(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct LinkExpModelWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitLinkExpModelWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkExpModel(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idLinkExpModel,mTab.idModel,mTab.idExpUserData}
	ModSqlCypherInterface#SelectIntoWaves(TAB_LinkExpModel,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectLinkExpModel(mTab)
	Struct LinkExpModelWaveRef & mTab
	Struct LinkExpModelWaveStr mTextTab
	LinkExpModelToTextStruct(mTab,mTextTab)
	SimpleSelectLinkExpModel(mTextTab)
End Function


Static Function SimpleSelectLinkModelParams(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct LinkModelParamsWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitLinkModelParamsWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkModelParams(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idLinkModelParams,mTab.idModel,mTab.idParamMeta}
	ModSqlCypherInterface#SelectIntoWaves(TAB_LinkModelParams,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectLinkModelParams(mTab)
	Struct LinkModelParamsWaveRef & mTab
	Struct LinkModelParamsWaveStr mTextTab
	LinkModelParamsToTextStruct(mTab,mTextTab)
	SimpleSelectLinkModelParams(mTextTab)
End Function


Static Function SimpleSelectLinkModelTrace(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct LinkModelTraceWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitLinkModelTraceWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkModelTrace(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idLinkModelTrace,mTab.idModel,mTab.idTraceModel}
	ModSqlCypherInterface#SelectIntoWaves(TAB_LinkModelTrace,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectLinkModelTrace(mTab)
	Struct LinkModelTraceWaveRef & mTab
	Struct LinkModelTraceWaveStr mTextTab
	LinkModelTraceToTextStruct(mTab,mTextTab)
	SimpleSelectLinkModelTrace(mTextTab)
End Function


Static Function SimpleSelectLinkMoleTrace(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct LinkMoleTraceWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitLinkMoleTraceWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkMoleTrace(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idLinkMoleTrace,mTab.idMolType,mTab.idTraceMeta}
	ModSqlCypherInterface#SelectIntoWaves(TAB_LinkMoleTrace,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectLinkMoleTrace(mTab)
	Struct LinkMoleTraceWaveRef & mTab
	Struct LinkMoleTraceWaveStr mTextTab
	LinkMoleTraceToTextStruct(mTab,mTextTab)
	SimpleSelectLinkMoleTrace(mTextTab)
End Function


Static Function SimpleSelectLinkTipTrace(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct LinkTipTraceWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitLinkTipTraceWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkTipTrace(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idLinkTipTrace,mTab.idTipType,mTab.idTraceMeta}
	ModSqlCypherInterface#SelectIntoWaves(TAB_LinkTipTrace,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectLinkTipTrace(mTab)
	Struct LinkTipTraceWaveRef & mTab
	Struct LinkTipTraceWaveStr mTextTab
	LinkTipTraceToTextStruct(mTab,mTextTab)
	SimpleSelectLinkTipTrace(mTextTab)
End Function


Static Function SimpleSelectLinkTraceParam(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct LinkTraceParamWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitLinkTraceParamWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfLinkTraceParam(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idLinkTraceParam,mTab.idParameterValue,mTab.idTraceModel}
	ModSqlCypherInterface#SelectIntoWaves(TAB_LinkTraceParam,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectLinkTraceParam(mTab)
	Struct LinkTraceParamWaveRef & mTab
	Struct LinkTraceParamWaveStr mTextTab
	LinkTraceParamToTextStruct(mTab,mTextTab)
	SimpleSelectLinkTraceParam(mTextTab)
End Function


Static Function SimpleSelectModel(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct ModelWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitModelWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfModel(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idModel,mTab.ModelName,mTab.ModelDescription}
	ModSqlCypherInterface#SelectIntoWaves(TAB_Model,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectModel(mTab)
	Struct ModelWaveRef & mTab
	Struct ModelWaveStr mTextTab
	ModelToTextStruct(mTab,mTextTab)
	SimpleSelectModel(mTextTab)
End Function


Static Function SimpleSelectMolType(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct MolTypeWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitMolTypeWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfMolType(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idMolType,mTab.Name,mTab.Description,mTab.MolMass,mTab.idMoleculeFamily}
	ModSqlCypherInterface#SelectIntoWaves(TAB_MolType,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectMolType(mTab)
	Struct MolTypeWaveRef & mTab
	Struct MolTypeWaveStr mTextTab
	MolTypeToTextStruct(mTab,mTextTab)
	SimpleSelectMolType(mTextTab)
End Function


Static Function SimpleSelectMoleculeFamily(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct MoleculeFamilyWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitMoleculeFamilyWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfMoleculeFamily(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idMoleculeFamily,mTab.Name,mTab.Description}
	ModSqlCypherInterface#SelectIntoWaves(TAB_MoleculeFamily,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectMoleculeFamily(mTab)
	Struct MoleculeFamilyWaveRef & mTab
	Struct MoleculeFamilyWaveStr mTextTab
	MoleculeFamilyToTextStruct(mTab,mTextTab)
	SimpleSelectMoleculeFamily(mTextTab)
End Function


Static Function SimpleSelectParamMeta(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct ParamMetaWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitParamMetaWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfParamMeta(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idParamMeta,mTab.Name,mTab.Description,mTab.UnitName,mTab.UnitAbbr,mTab.LeadStr,mTab.Prefix,mTab.IsRepeatable,mTab.IsPreProccess,mTab.ParameterNumber}
	ModSqlCypherInterface#SelectIntoWaves(TAB_ParamMeta,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectParamMeta(mTab)
	Struct ParamMetaWaveRef & mTab
	Struct ParamMetaWaveStr mTextTab
	ParamMetaToTextStruct(mTab,mTextTab)
	SimpleSelectParamMeta(mTextTab)
End Function


Static Function SimpleSelectParameterValue(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct ParameterValueWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitParameterValueWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfParameterValue(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idParameterValue,mTab.DataIndex,mTab.StrValues,mTab.DataValues,mTab.RepeatNumber,mTab.idTraceDataIndex,mTab.idParamMeta}
	ModSqlCypherInterface#SelectIntoWaves(TAB_ParameterValue,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectParameterValue(mTab)
	Struct ParameterValueWaveRef & mTab
	Struct ParameterValueWaveStr mTextTab
	ParameterValueToTextStruct(mTab,mTextTab)
	SimpleSelectParameterValue(mTextTab)
End Function


Static Function SimpleSelectSample(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct SampleWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitSampleWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfSample(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idSample,mTab.Name,mTab.Description,mTab.ConcNanogMuL,mTab.VolLoadedMuL,mTab.DateDeposited,mTab.DateCreated,mTab.DateRinsed,mTab.idSamplePrep,mTab.idMolType}
	ModSqlCypherInterface#SelectIntoWaves(TAB_Sample,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectSample(mTab)
	Struct SampleWaveRef & mTab
	Struct SampleWaveStr mTextTab
	SampleToTextStruct(mTab,mTextTab)
	SimpleSelectSample(mTextTab)
End Function


Static Function SimpleSelectSamplePrep(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct SamplePrepWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitSamplePrepWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfSamplePrep(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idSamplePrep,mTab.Name,mTab.Description}
	ModSqlCypherInterface#SelectIntoWaves(TAB_SamplePrep,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectSamplePrep(mTab)
	Struct SamplePrepWaveRef & mTab
	Struct SamplePrepWaveStr mTextTab
	SamplePrepToTextStruct(mTab,mTextTab)
	SimpleSelectSamplePrep(mTextTab)
End Function


Static Function SimpleSelectSourceFileDirectory(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct SourceFileDirectoryWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitSourceFileDirectoryWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfSourceFileDirectory(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idSourceDir,mTab.DirectoryName}
	ModSqlCypherInterface#SelectIntoWaves(TAB_SourceFileDirectory,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectSourceFileDirectory(mTab)
	Struct SourceFileDirectoryWaveRef & mTab
	Struct SourceFileDirectoryWaveStr mTextTab
	SourceFileDirectoryToTextStruct(mTab,mTextTab)
	SimpleSelectSourceFileDirectory(mTextTab)
End Function


Static Function SimpleSelectTipManifest(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct TipManifestWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitTipManifestWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTipManifest(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idTipManifest,mTab.Name,mTab.Description,mTab.PackPosition,mTab.TimeMade,mTab.TimeRinsed,mTab.idTipPrep,mTab.idTipType,mTab.idTipPack}
	ModSqlCypherInterface#SelectIntoWaves(TAB_TipManifest,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectTipManifest(mTab)
	Struct TipManifestWaveRef & mTab
	Struct TipManifestWaveStr mTextTab
	TipManifestToTextStruct(mTab,mTextTab)
	SimpleSelectTipManifest(mTextTab)
End Function


Static Function SimpleSelectTipPack(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct TipPackWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitTipPackWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTipPack(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idTipPack,mTab.Name,mTab.Description}
	ModSqlCypherInterface#SelectIntoWaves(TAB_TipPack,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectTipPack(mTab)
	Struct TipPackWaveRef & mTab
	Struct TipPackWaveStr mTextTab
	TipPackToTextStruct(mTab,mTextTab)
	SimpleSelectTipPack(mTextTab)
End Function


Static Function SimpleSelectTipPrep(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct TipPrepWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitTipPrepWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTipPrep(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idTipPrep,mTab.Name,mTab.Description,mTab.SecondsEtchGold,mTab.SecondsEtchChromium}
	ModSqlCypherInterface#SelectIntoWaves(TAB_TipPrep,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectTipPrep(mTab)
	Struct TipPrepWaveRef & mTab
	Struct TipPrepWaveStr mTextTab
	TipPrepToTextStruct(mTab,mTextTab)
	SimpleSelectTipPrep(mTextTab)
End Function


Static Function SimpleSelectTipType(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct TipTypeWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitTipTypeWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTipType(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idTipTypes,mTab.Name,mTab.Description}
	ModSqlCypherInterface#SelectIntoWaves(TAB_TipType,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectTipType(mTab)
	Struct TipTypeWaveRef & mTab
	Struct TipTypeWaveStr mTextTab
	TipTypeToTextStruct(mTab,mTextTab)
	SimpleSelectTipType(mTextTab)
End Function


Static Function SimpleSelectTraceData(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct TraceDataWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitTraceDataWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceData(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idTraceData,mTab.FileName,mTab.idExpUserData}
	ModSqlCypherInterface#SelectIntoWaves(TAB_TraceData,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectTraceData(mTab)
	Struct TraceDataWaveRef & mTab
	Struct TraceDataWaveStr mTextTab
	TraceDataToTextStruct(mTab,mTextTab)
	SimpleSelectTraceData(mTextTab)
End Function


Static Function SimpleSelectTraceDataIndex(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct TraceDataIndexWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitTraceDataIndexWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceDataIndex(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idParameterValue,mTab.StartIndex,mTab.EndIndex,mTab.idTraceData}
	ModSqlCypherInterface#SelectIntoWaves(TAB_TraceDataIndex,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectTraceDataIndex(mTab)
	Struct TraceDataIndexWaveRef & mTab
	Struct TraceDataIndexWaveStr mTextTab
	TraceDataIndexToTextStruct(mTab,mTextTab)
	SimpleSelectTraceDataIndex(mTextTab)
End Function


Static Function SimpleSelectTraceExpLink(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct TraceExpLinkWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitTraceExpLinkWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceExpLink(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idTraceExpLink,mTab.idTraceMeta,mTab.idExpUserData}
	ModSqlCypherInterface#SelectIntoWaves(TAB_TraceExpLink,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectTraceExpLink(mTab)
	Struct TraceExpLinkWaveRef & mTab
	Struct TraceExpLinkWaveStr mTextTab
	TraceExpLinkToTextStruct(mTab,mTextTab)
	SimpleSelectTraceExpLink(mTextTab)
End Function


Static Function SimpleSelectTraceMeta(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct TraceMetaWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitTraceMetaWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceMeta(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idTraceMeta,mTab.Description,mTab.ApproachVel,mTab.RetractVel,mTab.TimeStarted,mTab.TimeEnded,mTab.DwellTowards,mTab.DwellAway,mTab.SampleRate,mTab.FilteredSampleRate,mTab.DeflInvols,mTab.Temperature,mTab.SpringConstant,mTab.FirstResRef,mTab.ThermalQ,mTab.LocationX,mTab.LocationY,mTab.OffsetX,mTab.OffsetY,mTab.Spot,mTab.idTipManifest,mTab.idUser,mTab.idTraceRating,mTab.idSample}
	ModSqlCypherInterface#SelectIntoWaves(TAB_TraceMeta,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectTraceMeta(mTab)
	Struct TraceMetaWaveRef & mTab
	Struct TraceMetaWaveStr mTextTab
	TraceMetaToTextStruct(mTab,mTextTab)
	SimpleSelectTraceMeta(mTextTab)
End Function


Static Function SimpleSelectTraceModel(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct TraceModelWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitTraceModelWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceModel(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idTraceModel,mTab.idTraceMeta,mTab.idTraceData}
	ModSqlCypherInterface#SelectIntoWaves(TAB_TraceModel,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectTraceModel(mTab)
	Struct TraceModelWaveRef & mTab
	Struct TraceModelWaveStr mTextTab
	TraceModelToTextStruct(mTab,mTextTab)
	SimpleSelectTraceModel(mTextTab)
End Function


Static Function SimpleSelectTraceRating(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct TraceRatingWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitTraceRatingWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfTraceRating(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idTraceRating,mTab.RatingValue,mTab.Name,mTab.Description}
	ModSqlCypherInterface#SelectIntoWaves(TAB_TraceRating,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectTraceRating(mTab)
	Struct TraceRatingWaveRef & mTab
	Struct TraceRatingWaveStr mTextTab
	TraceRatingToTextStruct(mTab,mTextTab)
	SimpleSelectTraceRating(mTextTab)
End Function


Static Function SimpleSelectUser(mTab,[saveGlobal,appendStmt,initWaveStr])
	// Note: if saveInGlobalTab is true, saves to SqlDir
	// otherwise waves to CWD (current working directory)
	Struct UserWaveStr & mTab 
	Variable saveGlobal,initWaveStr
	String appendStmt
	saveGlobal = ParamIsDefault(saveGlobal) ? ModDefine#False() : saveGlobal
	if (ParamIsDefault(appendStmt))
		appendStmt=""
	EndIf
	initWaveStr = ParamIsDefault(initWaveStr) ? ModDefine#True() : initWaveStr
	if(initWaveStr)
		//Init the wave structure for holding the names.
		InitUserWaveStr(mTab)
	EndIf
	// Get all of the columns, *including* the ID
	Wave /T mCols = ModSqlCypherUtilFuncs#GetColsOfUser(IncludeId=ModDefine#True())
	//Add all the fields we will select into
	Make /O/T mFields = {mTab.idUser,mTab.Name}
	ModSqlCypherInterface#SelectIntoWaves(TAB_User,mCols,mFields,saveGlobal,appendStmt)
End Function

Static Function WaveSelectUser(mTab)
	Struct UserWaveRef & mTab
	Struct UserWaveStr mTextTab
	UserToTextStruct(mTab,mTextTab)
	SimpleSelectUser(mTextTab)
End Function



