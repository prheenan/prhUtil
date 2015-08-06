// Use modern global access method, strict compilation
#pragma rtGlobals=3
#pragma ModuleName=ModSqlCypherAutoDefines
#include ":SqlUtil"
#include "::Util:Defines"
#include "::Util:ErrorUtil"
Constant MAX_NAME_LEN=100
Constant MAX_DESCRIPTION_LEN=200
// Defined table names
StrConstant TAB_ExpMeta="ExpMeta"
StrConstant TAB_ExpUserData="ExpUserData"
StrConstant TAB_LinkDataMeta="LinkDataMeta"
StrConstant TAB_LinkExpModel="LinkExpModel"
StrConstant TAB_LinkModelParams="LinkModelParams"
StrConstant TAB_LinkModelTrace="LinkModelTrace"
StrConstant TAB_LinkMoleTrace="LinkMoleTrace"
StrConstant TAB_LinkTipTrace="LinkTipTrace"
StrConstant TAB_LinkTraceParam="LinkTraceParam"
StrConstant TAB_Model="Model"
StrConstant TAB_MolType="MolType"
StrConstant TAB_MoleculeFamily="MoleculeFamily"
StrConstant TAB_ParamMeta="ParamMeta"
StrConstant TAB_ParameterValue="ParameterValue"
StrConstant TAB_Sample="Sample"
StrConstant TAB_SamplePrep="SamplePrep"
StrConstant TAB_SourceFileDirectory="SourceFileDirectory"
StrConstant TAB_TipManifest="TipManifest"
StrConstant TAB_TipPack="TipPack"
StrConstant TAB_TipPrep="TipPrep"
StrConstant TAB_TipType="TipType"
StrConstant TAB_TraceData="TraceData"
StrConstant TAB_TraceDataIndex="TraceDataIndex"
StrConstant TAB_TraceExpLink="TraceExpLink"
StrConstant TAB_TraceMeta="TraceMeta"
StrConstant TAB_TraceModel="TraceModel"
StrConstant TAB_TraceRating="TraceRating"
StrConstant TAB_User="User"

// Defined table field names
StrConstant FIELD_ApproachVel="ApproachVel"
StrConstant FIELD_ConcNanogMuL="ConcNanogMuL"
StrConstant FIELD_DataIndex="DataIndex"
StrConstant FIELD_DataValues="DataValues"
StrConstant FIELD_DateCreated="DateCreated"
StrConstant FIELD_DateDeposited="DateDeposited"
StrConstant FIELD_DateRinsed="DateRinsed"
StrConstant FIELD_DeflInvols="DeflInvols"
StrConstant FIELD_Description="Description"
StrConstant FIELD_DirectoryName="DirectoryName"
StrConstant FIELD_DwellAway="DwellAway"
StrConstant FIELD_DwellTowards="DwellTowards"
StrConstant FIELD_EndIndex="EndIndex"
StrConstant FIELD_FileName="FileName"
StrConstant FIELD_FilteredSampleRate="FilteredSampleRate"
StrConstant FIELD_FirstResRef="FirstResRef"
StrConstant FIELD_idExpUserData="idExpUserData"
StrConstant FIELD_idLinkDataMeta="idLinkDataMeta"
StrConstant FIELD_idLinkExpModel="idLinkExpModel"
StrConstant FIELD_idLinkModelParams="idLinkModelParams"
StrConstant FIELD_idLinkModelTrace="idLinkModelTrace"
StrConstant FIELD_idLinkMoleTrace="idLinkMoleTrace"
StrConstant FIELD_idLinkTipTrace="idLinkTipTrace"
StrConstant FIELD_idLinkTraceParam="idLinkTraceParam"
StrConstant FIELD_idModel="idModel"
StrConstant FIELD_idMoleculeFamily="idMoleculeFamily"
StrConstant FIELD_idMolType="idMolType"
StrConstant FIELD_idParameterValue="idParameterValue"
StrConstant FIELD_idParamMeta="idParamMeta"
StrConstant FIELD_idSample="idSample"
StrConstant FIELD_idSamplePrep="idSamplePrep"
StrConstant FIELD_idSourceDir="idSourceDir"
StrConstant FIELD_idTipManifest="idTipManifest"
StrConstant FIELD_idTipPack="idTipPack"
StrConstant FIELD_idTipPrep="idTipPrep"
StrConstant FIELD_idTipType="idTipType"
StrConstant FIELD_idTipTypes="idTipTypes"
StrConstant FIELD_idTraceData="idTraceData"
StrConstant FIELD_idTraceDataIndex="idTraceDataIndex"
StrConstant FIELD_idTraceExpLink="idTraceExpLink"
StrConstant FIELD_idTraceMeta="idTraceMeta"
StrConstant FIELD_idTraceModel="idTraceModel"
StrConstant FIELD_idTraceRating="idTraceRating"
StrConstant FIELD_idUser="idUser"
StrConstant FIELD_IsPreProccess="IsPreProccess"
StrConstant FIELD_IsRepeatable="IsRepeatable"
StrConstant FIELD_LeadStr="LeadStr"
StrConstant FIELD_LocationX="LocationX"
StrConstant FIELD_LocationY="LocationY"
StrConstant FIELD_ModelDescription="ModelDescription"
StrConstant FIELD_ModelName="ModelName"
StrConstant FIELD_MolMass="MolMass"
StrConstant FIELD_Name="Name"
StrConstant FIELD_NAttemptedPulls="NAttemptedPulls"
StrConstant FIELD_OffsetX="OffsetX"
StrConstant FIELD_OffsetY="OffsetY"
StrConstant FIELD_PackPosition="PackPosition"
StrConstant FIELD_ParameterNumber="ParameterNumber"
StrConstant FIELD_Prefix="Prefix"
StrConstant FIELD_RatingValue="RatingValue"
StrConstant FIELD_RepeatNumber="RepeatNumber"
StrConstant FIELD_RetractVel="RetractVel"
StrConstant FIELD_SampleRate="SampleRate"
StrConstant FIELD_SecondsEtchChromium="SecondsEtchChromium"
StrConstant FIELD_SecondsEtchGold="SecondsEtchGold"
StrConstant FIELD_SourceFile="SourceFile"
StrConstant FIELD_Spot="Spot"
StrConstant FIELD_SpringConstant="SpringConstant"
StrConstant FIELD_StartIndex="StartIndex"
StrConstant FIELD_StrValues="StrValues"
StrConstant FIELD_Temperature="Temperature"
StrConstant FIELD_ThermalQ="ThermalQ"
StrConstant FIELD_TimeEnded="TimeEnded"
StrConstant FIELD_TimeMade="TimeMade"
StrConstant FIELD_TimeRinsed="TimeRinsed"
StrConstant FIELD_TimeStarted="TimeStarted"
StrConstant FIELD_UnitAbbr="UnitAbbr"
StrConstant FIELD_UnitName="UnitName"
StrConstant FIELD_VolLoadedMuL="VolLoadedMuL"

// All Table function
Static Function /Wave getAllTables()
	Make /O/T AllSqlTables = {TAB_ExpMeta,TAB_ExpUserData,TAB_LinkDataMeta,TAB_LinkExpModel,TAB_LinkModelParams,TAB_LinkModelTrace,TAB_LinkMoleTrace,TAB_LinkTipTrace,TAB_LinkTraceParam,TAB_Model,TAB_MolType,TAB_MoleculeFamily,TAB_ParamMeta,TAB_ParameterValue,TAB_Sample,TAB_SamplePrep,TAB_SourceFileDirectory,TAB_TipManifest,TAB_TipPack,TAB_TipPrep,TAB_TipType,TAB_TraceData,TAB_TraceDataIndex,TAB_TraceExpLink,TAB_TraceMeta,TAB_TraceModel,TAB_TraceRating,TAB_User}
	return AllSqlTables
End Function

// Defined structures
Structure ExpMeta
	uint32 idExpUserData
	char TimeStarted[MAX_NAME_LEN]
	uint32 NAttemptedPulls
	char SourceFile[MAX_NAME_LEN]
EndStructure

Structure ExpMetaWaveStr
	char idExpUserData[MAX_NAME_LEN]
	char TimeStarted[MAX_NAME_LEN]
	char NAttemptedPulls[MAX_NAME_LEN]
	char SourceFile[MAX_NAME_LEN]
EndStructure

Structure ExpMetaWaveRef
	Wave /D idExpUserData
	Wave /T TimeStarted
	Wave /D NAttemptedPulls
	Wave /T SourceFile
EndStructure


Structure ExpUserData
	uint32 idExpUserData
	char Name[MAX_NAME_LEN]
	char Description[MAX_DESCRIPTION_LEN]
	uint32 idUser
EndStructure

Structure ExpUserDataWaveStr
	char idExpUserData[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
	char idUser[MAX_NAME_LEN]
EndStructure

Structure ExpUserDataWaveRef
	Wave /D idExpUserData
	Wave /T Name
	Wave /T Description
	Wave /D idUser
EndStructure


Structure LinkDataMeta
	uint32 idLinkDataMeta
	uint32 idTraceMeta
	uint32 idTraceData
EndStructure

Structure LinkDataMetaWaveStr
	char idLinkDataMeta[MAX_NAME_LEN]
	char idTraceMeta[MAX_NAME_LEN]
	char idTraceData[MAX_NAME_LEN]
EndStructure

Structure LinkDataMetaWaveRef
	Wave /D idLinkDataMeta
	Wave /D idTraceMeta
	Wave /D idTraceData
EndStructure


Structure LinkExpModel
	uint32 idLinkExpModel
	uint32 idModel
	uint32 idExpUserData
EndStructure

Structure LinkExpModelWaveStr
	char idLinkExpModel[MAX_NAME_LEN]
	char idModel[MAX_NAME_LEN]
	char idExpUserData[MAX_NAME_LEN]
EndStructure

Structure LinkExpModelWaveRef
	Wave /D idLinkExpModel
	Wave /D idModel
	Wave /D idExpUserData
EndStructure


Structure LinkModelParams
	uint32 idLinkModelParams
	uint32 idModel
	uint32 idParamMeta
EndStructure

Structure LinkModelParamsWaveStr
	char idLinkModelParams[MAX_NAME_LEN]
	char idModel[MAX_NAME_LEN]
	char idParamMeta[MAX_NAME_LEN]
EndStructure

Structure LinkModelParamsWaveRef
	Wave /D idLinkModelParams
	Wave /D idModel
	Wave /D idParamMeta
EndStructure


Structure LinkModelTrace
	uint32 idLinkModelTrace
	uint32 idModel
	uint32 idTraceModel
EndStructure

Structure LinkModelTraceWaveStr
	char idLinkModelTrace[MAX_NAME_LEN]
	char idModel[MAX_NAME_LEN]
	char idTraceModel[MAX_NAME_LEN]
EndStructure

Structure LinkModelTraceWaveRef
	Wave /D idLinkModelTrace
	Wave /D idModel
	Wave /D idTraceModel
EndStructure


Structure LinkMoleTrace
	uint32 idLinkMoleTrace
	uint32 idMolType
	uint32 idTraceMeta
EndStructure

Structure LinkMoleTraceWaveStr
	char idLinkMoleTrace[MAX_NAME_LEN]
	char idMolType[MAX_NAME_LEN]
	char idTraceMeta[MAX_NAME_LEN]
EndStructure

Structure LinkMoleTraceWaveRef
	Wave /D idLinkMoleTrace
	Wave /D idMolType
	Wave /D idTraceMeta
EndStructure


Structure LinkTipTrace
	uint32 idLinkTipTrace
	uint32 idTipType
	uint32 idTraceMeta
EndStructure

Structure LinkTipTraceWaveStr
	char idLinkTipTrace[MAX_NAME_LEN]
	char idTipType[MAX_NAME_LEN]
	char idTraceMeta[MAX_NAME_LEN]
EndStructure

Structure LinkTipTraceWaveRef
	Wave /D idLinkTipTrace
	Wave /D idTipType
	Wave /D idTraceMeta
EndStructure


Structure LinkTraceParam
	uint32 idLinkTraceParam
	uint32 idParameterValue
	uint32 idTraceModel
EndStructure

Structure LinkTraceParamWaveStr
	char idLinkTraceParam[MAX_NAME_LEN]
	char idParameterValue[MAX_NAME_LEN]
	char idTraceModel[MAX_NAME_LEN]
EndStructure

Structure LinkTraceParamWaveRef
	Wave /D idLinkTraceParam
	Wave /D idParameterValue
	Wave /D idTraceModel
EndStructure


Structure Model
	uint32 idModel
	char ModelName[MAX_NAME_LEN]
	char ModelDescription[MAX_DESCRIPTION_LEN]
EndStructure

Structure ModelWaveStr
	char idModel[MAX_NAME_LEN]
	char ModelName[MAX_NAME_LEN]
	char ModelDescription[MAX_NAME_LEN]
EndStructure

Structure ModelWaveRef
	Wave /D idModel
	Wave /T ModelName
	Wave /T ModelDescription
EndStructure


Structure MolType
	uint32 idMolType
	char Name[MAX_NAME_LEN]
	char Description[MAX_DESCRIPTION_LEN]
	double MolMass
	uint32 idMoleculeFamily
EndStructure

Structure MolTypeWaveStr
	char idMolType[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
	char MolMass[MAX_NAME_LEN]
	char idMoleculeFamily[MAX_NAME_LEN]
EndStructure

Structure MolTypeWaveRef
	Wave /D idMolType
	Wave /T Name
	Wave /T Description
	Wave /D MolMass
	Wave /D idMoleculeFamily
EndStructure


Structure MoleculeFamily
	uint32 idMoleculeFamily
	char Name[MAX_NAME_LEN]
	char Description[MAX_DESCRIPTION_LEN]
EndStructure

Structure MoleculeFamilyWaveStr
	char idMoleculeFamily[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
EndStructure

Structure MoleculeFamilyWaveRef
	Wave /D idMoleculeFamily
	Wave /T Name
	Wave /T Description
EndStructure


Structure ParamMeta
	uint32 idParamMeta
	char Name[MAX_NAME_LEN]
	char Description[MAX_DESCRIPTION_LEN]
	char UnitName[MAX_NAME_LEN]
	char UnitAbbr[MAX_NAME_LEN]
	char LeadStr[MAX_NAME_LEN]
	char Prefix[MAX_NAME_LEN]
	uint32 IsRepeatable
	uint32 IsPreProccess
	uint32 ParameterNumber
EndStructure

Structure ParamMetaWaveStr
	char idParamMeta[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
	char UnitName[MAX_NAME_LEN]
	char UnitAbbr[MAX_NAME_LEN]
	char LeadStr[MAX_NAME_LEN]
	char Prefix[MAX_NAME_LEN]
	char IsRepeatable[MAX_NAME_LEN]
	char IsPreProccess[MAX_NAME_LEN]
	char ParameterNumber[MAX_NAME_LEN]
EndStructure

Structure ParamMetaWaveRef
	Wave /D idParamMeta
	Wave /T Name
	Wave /T Description
	Wave /T UnitName
	Wave /T UnitAbbr
	Wave /T LeadStr
	Wave /T Prefix
	Wave /D IsRepeatable
	Wave /D IsPreProccess
	Wave /D ParameterNumber
EndStructure


Structure ParameterValue
	uint32 idParameterValue
	double DataIndex
	char StrValues[MAX_NAME_LEN]
	double DataValues
	uint32 RepeatNumber
	uint32 idTraceDataIndex
	uint32 idParamMeta
EndStructure

Structure ParameterValueWaveStr
	char idParameterValue[MAX_NAME_LEN]
	char DataIndex[MAX_NAME_LEN]
	char StrValues[MAX_NAME_LEN]
	char DataValues[MAX_NAME_LEN]
	char RepeatNumber[MAX_NAME_LEN]
	char idTraceDataIndex[MAX_NAME_LEN]
	char idParamMeta[MAX_NAME_LEN]
EndStructure

Structure ParameterValueWaveRef
	Wave /D idParameterValue
	Wave /D DataIndex
	Wave /T StrValues
	Wave /D DataValues
	Wave /D RepeatNumber
	Wave /D idTraceDataIndex
	Wave /D idParamMeta
EndStructure


Structure Sample
	uint32 idSample
	char Name[MAX_NAME_LEN]
	char Description[MAX_DESCRIPTION_LEN]
	double ConcNanogMuL
	double VolLoadedMuL
	char DateDeposited[MAX_NAME_LEN]
	char DateCreated[MAX_NAME_LEN]
	char DateRinsed[MAX_NAME_LEN]
	uint32 idSamplePrep
	uint32 idMolType
EndStructure

Structure SampleWaveStr
	char idSample[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
	char ConcNanogMuL[MAX_NAME_LEN]
	char VolLoadedMuL[MAX_NAME_LEN]
	char DateDeposited[MAX_NAME_LEN]
	char DateCreated[MAX_NAME_LEN]
	char DateRinsed[MAX_NAME_LEN]
	char idSamplePrep[MAX_NAME_LEN]
	char idMolType[MAX_NAME_LEN]
EndStructure

Structure SampleWaveRef
	Wave /D idSample
	Wave /T Name
	Wave /T Description
	Wave /D ConcNanogMuL
	Wave /D VolLoadedMuL
	Wave /T DateDeposited
	Wave /T DateCreated
	Wave /T DateRinsed
	Wave /D idSamplePrep
	Wave /D idMolType
EndStructure


Structure SamplePrep
	uint32 idSamplePrep
	char Name[MAX_NAME_LEN]
	char Description[MAX_DESCRIPTION_LEN]
EndStructure

Structure SamplePrepWaveStr
	char idSamplePrep[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
EndStructure

Structure SamplePrepWaveRef
	Wave /D idSamplePrep
	Wave /T Name
	Wave /T Description
EndStructure


Structure SourceFileDirectory
	uint32 idSourceDir
	char DirectoryName[MAX_NAME_LEN]
EndStructure

Structure SourceFileDirectoryWaveStr
	char idSourceDir[MAX_NAME_LEN]
	char DirectoryName[MAX_NAME_LEN]
EndStructure

Structure SourceFileDirectoryWaveRef
	Wave /D idSourceDir
	Wave /T DirectoryName
EndStructure


Structure TipManifest
	uint32 idTipManifest
	char Name[MAX_NAME_LEN]
	char Description[MAX_DESCRIPTION_LEN]
	char PackPosition[MAX_NAME_LEN]
	char TimeMade[MAX_NAME_LEN]
	char TimeRinsed[MAX_NAME_LEN]
	uint32 idTipPrep
	uint32 idTipType
	uint32 idTipPack
EndStructure

Structure TipManifestWaveStr
	char idTipManifest[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
	char PackPosition[MAX_NAME_LEN]
	char TimeMade[MAX_NAME_LEN]
	char TimeRinsed[MAX_NAME_LEN]
	char idTipPrep[MAX_NAME_LEN]
	char idTipType[MAX_NAME_LEN]
	char idTipPack[MAX_NAME_LEN]
EndStructure

Structure TipManifestWaveRef
	Wave /D idTipManifest
	Wave /T Name
	Wave /T Description
	Wave /T PackPosition
	Wave /T TimeMade
	Wave /T TimeRinsed
	Wave /D idTipPrep
	Wave /D idTipType
	Wave /D idTipPack
EndStructure


Structure TipPack
	uint32 idTipPack
	char Name[MAX_NAME_LEN]
	char Description[MAX_DESCRIPTION_LEN]
EndStructure

Structure TipPackWaveStr
	char idTipPack[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
EndStructure

Structure TipPackWaveRef
	Wave /D idTipPack
	Wave /T Name
	Wave /T Description
EndStructure


Structure TipPrep
	uint32 idTipPrep
	char Name[MAX_NAME_LEN]
	char Description[MAX_DESCRIPTION_LEN]
	double SecondsEtchGold
	double SecondsEtchChromium
EndStructure

Structure TipPrepWaveStr
	char idTipPrep[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
	char SecondsEtchGold[MAX_NAME_LEN]
	char SecondsEtchChromium[MAX_NAME_LEN]
EndStructure

Structure TipPrepWaveRef
	Wave /D idTipPrep
	Wave /T Name
	Wave /T Description
	Wave /D SecondsEtchGold
	Wave /D SecondsEtchChromium
EndStructure


Structure TipType
	uint32 idTipTypes
	char Name[MAX_NAME_LEN]
	char Description[MAX_DESCRIPTION_LEN]
EndStructure

Structure TipTypeWaveStr
	char idTipTypes[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
EndStructure

Structure TipTypeWaveRef
	Wave /D idTipTypes
	Wave /T Name
	Wave /T Description
EndStructure


Structure TraceData
	uint32 idTraceData
	char FileName[MAX_NAME_LEN]
	uint32 idExpUserData
EndStructure

Structure TraceDataWaveStr
	char idTraceData[MAX_NAME_LEN]
	char FileName[MAX_NAME_LEN]
	char idExpUserData[MAX_NAME_LEN]
EndStructure

Structure TraceDataWaveRef
	Wave /D idTraceData
	Wave /T FileName
	Wave /D idExpUserData
EndStructure


Structure TraceDataIndex
	uint32 idParameterValue
	double StartIndex
	double EndIndex
	uint32 idTraceData
EndStructure

Structure TraceDataIndexWaveStr
	char idParameterValue[MAX_NAME_LEN]
	char StartIndex[MAX_NAME_LEN]
	char EndIndex[MAX_NAME_LEN]
	char idTraceData[MAX_NAME_LEN]
EndStructure

Structure TraceDataIndexWaveRef
	Wave /D idParameterValue
	Wave /D StartIndex
	Wave /D EndIndex
	Wave /D idTraceData
EndStructure


Structure TraceExpLink
	uint32 idTraceExpLink
	uint32 idTraceMeta
	uint32 idExpUserData
EndStructure

Structure TraceExpLinkWaveStr
	char idTraceExpLink[MAX_NAME_LEN]
	char idTraceMeta[MAX_NAME_LEN]
	char idExpUserData[MAX_NAME_LEN]
EndStructure

Structure TraceExpLinkWaveRef
	Wave /D idTraceExpLink
	Wave /D idTraceMeta
	Wave /D idExpUserData
EndStructure


Structure TraceMeta
	uint32 idTraceMeta
	char Description[MAX_DESCRIPTION_LEN]
	double ApproachVel
	double RetractVel
	char TimeStarted[MAX_NAME_LEN]
	char TimeEnded[MAX_NAME_LEN]
	double DwellTowards
	double DwellAway
	double SampleRate
	double FilteredSampleRate
	double DeflInvols
	double Temperature
	double SpringConstant
	double FirstResRef
	double ThermalQ
	double LocationX
	double LocationY
	double OffsetX
	double OffsetY
	uint32 Spot
	uint32 idTipManifest
	uint32 idUser
	uint32 idTraceRating
	uint32 idSample
EndStructure

Structure TraceMetaWaveStr
	char idTraceMeta[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
	char ApproachVel[MAX_NAME_LEN]
	char RetractVel[MAX_NAME_LEN]
	char TimeStarted[MAX_NAME_LEN]
	char TimeEnded[MAX_NAME_LEN]
	char DwellTowards[MAX_NAME_LEN]
	char DwellAway[MAX_NAME_LEN]
	char SampleRate[MAX_NAME_LEN]
	char FilteredSampleRate[MAX_NAME_LEN]
	char DeflInvols[MAX_NAME_LEN]
	char Temperature[MAX_NAME_LEN]
	char SpringConstant[MAX_NAME_LEN]
	char FirstResRef[MAX_NAME_LEN]
	char ThermalQ[MAX_NAME_LEN]
	char LocationX[MAX_NAME_LEN]
	char LocationY[MAX_NAME_LEN]
	char OffsetX[MAX_NAME_LEN]
	char OffsetY[MAX_NAME_LEN]
	char Spot[MAX_NAME_LEN]
	char idTipManifest[MAX_NAME_LEN]
	char idUser[MAX_NAME_LEN]
	char idTraceRating[MAX_NAME_LEN]
	char idSample[MAX_NAME_LEN]
EndStructure

Structure TraceMetaWaveRef
	Wave /D idTraceMeta
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
	Wave /D Spot
	Wave /D idTipManifest
	Wave /D idUser
	Wave /D idTraceRating
	Wave /D idSample
EndStructure


Structure TraceModel
	uint32 idTraceModel
	uint32 idTraceMeta
	uint32 idTraceData
EndStructure

Structure TraceModelWaveStr
	char idTraceModel[MAX_NAME_LEN]
	char idTraceMeta[MAX_NAME_LEN]
	char idTraceData[MAX_NAME_LEN]
EndStructure

Structure TraceModelWaveRef
	Wave /D idTraceModel
	Wave /D idTraceMeta
	Wave /D idTraceData
EndStructure


Structure TraceRating
	uint32 idTraceRating
	uint32 RatingValue
	char Name[MAX_NAME_LEN]
	char Description[MAX_DESCRIPTION_LEN]
EndStructure

Structure TraceRatingWaveStr
	char idTraceRating[MAX_NAME_LEN]
	char RatingValue[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
	char Description[MAX_NAME_LEN]
EndStructure

Structure TraceRatingWaveRef
	Wave /D idTraceRating
	Wave /D RatingValue
	Wave /T Name
	Wave /T Description
EndStructure


Structure User
	uint32 idUser
	char Name[MAX_NAME_LEN]
EndStructure

Structure UserWaveStr
	char idUser[MAX_NAME_LEN]
	char Name[MAX_NAME_LEN]
EndStructure

Structure UserWaveRef
	Wave /D idUser
	Wave /T Name
EndStructure



// Defined id structure
Structure SqlIdTable
	uint32 idExpMeta
	uint32 idExpUserData
	uint32 idLinkDataMeta
	uint32 idLinkExpModel
	uint32 idLinkModelParams
	uint32 idLinkModelTrace
	uint32 idLinkMoleTrace
	uint32 idLinkTipTrace
	uint32 idLinkTraceParam
	uint32 idModel
	uint32 idMolType
	uint32 idMoleculeFamily
	uint32 idParamMeta
	uint32 idParameterValue
	uint32 idSample
	uint32 idSamplePrep
	uint32 idSourceFileDirectory
	uint32 idTipManifest
	uint32 idTipPack
	uint32 idTipPrep
	uint32 idTipType
	uint32 idTraceData
	uint32 idTraceDataIndex
	uint32 idTraceExpLink
	uint32 idTraceMeta
	uint32 idTraceModel
	uint32 idTraceRating
	uint32 idUser
EndStructure

Function SetIdTable(mStruct,mPath)
	Struct SqlIdTable & mStruct
	String mPath
	if (!WaveExists($mPath))
		Make /O/N=(0) $(mPath)
	EndIf
	// POST: wave exists
	StructPut /B=(ModDefine#StructFmt())  mStruct, $(mPath)
End Function

Function GetIdTable(mStruct,mPath)
	Struct SqlIdTable & mStruct
	String mPath
	StructGet /B=(ModDefine#StructFmt()) mStruct,$(mPath)
End Function

Static Function GetId(mStruct,mTab)
	Struct SqlIdTable & mStruct
	String mTab
	strswitch(mTab)
		case TAB_ExpMeta:
			return mStruct.idExpMeta
			break
		case TAB_ExpUserData:
			return mStruct.idExpUserData
			break
		case TAB_LinkDataMeta:
			return mStruct.idLinkDataMeta
			break
		case TAB_LinkExpModel:
			return mStruct.idLinkExpModel
			break
		case TAB_LinkModelParams:
			return mStruct.idLinkModelParams
			break
		case TAB_LinkModelTrace:
			return mStruct.idLinkModelTrace
			break
		case TAB_LinkMoleTrace:
			return mStruct.idLinkMoleTrace
			break
		case TAB_LinkTipTrace:
			return mStruct.idLinkTipTrace
			break
		case TAB_LinkTraceParam:
			return mStruct.idLinkTraceParam
			break
		case TAB_Model:
			return mStruct.idModel
			break
		case TAB_MolType:
			return mStruct.idMolType
			break
		case TAB_MoleculeFamily:
			return mStruct.idMoleculeFamily
			break
		case TAB_ParamMeta:
			return mStruct.idParamMeta
			break
		case TAB_ParameterValue:
			return mStruct.idParameterValue
			break
		case TAB_Sample:
			return mStruct.idSample
			break
		case TAB_SamplePrep:
			return mStruct.idSamplePrep
			break
		case TAB_SourceFileDirectory:
			return mStruct.idSourceFileDirectory
			break
		case TAB_TipManifest:
			return mStruct.idTipManifest
			break
		case TAB_TipPack:
			return mStruct.idTipPack
			break
		case TAB_TipPrep:
			return mStruct.idTipPrep
			break
		case TAB_TipType:
			return mStruct.idTipType
			break
		case TAB_TraceData:
			return mStruct.idTraceData
			break
		case TAB_TraceDataIndex:
			return mStruct.idTraceDataIndex
			break
		case TAB_TraceExpLink:
			return mStruct.idTraceExpLink
			break
		case TAB_TraceMeta:
			return mStruct.idTraceMeta
			break
		case TAB_TraceModel:
			return mStruct.idTraceModel
			break
		case TAB_TraceRating:
			return mStruct.idTraceRating
			break
		case TAB_User:
			return mStruct.idUser
			break
		default:
			String mErr
			sprintf mErr, "No table found for %s\r",mTab
			ModErrorUtil#DevelopmentError(description=mErr)
	EndSwitch
End Function

Static Function SetId(mStruct,mTab,mId)
	Struct SqlIdTable & mStruct
	String mTab
	Variable mId
	strswitch(mTab)
		case TAB_ExpMeta:
			mStruct.idExpMeta = mId
			break
		case TAB_ExpUserData:
			mStruct.idExpUserData = mId
			break
		case TAB_LinkDataMeta:
			mStruct.idLinkDataMeta = mId
			break
		case TAB_LinkExpModel:
			mStruct.idLinkExpModel = mId
			break
		case TAB_LinkModelParams:
			mStruct.idLinkModelParams = mId
			break
		case TAB_LinkModelTrace:
			mStruct.idLinkModelTrace = mId
			break
		case TAB_LinkMoleTrace:
			mStruct.idLinkMoleTrace = mId
			break
		case TAB_LinkTipTrace:
			mStruct.idLinkTipTrace = mId
			break
		case TAB_LinkTraceParam:
			mStruct.idLinkTraceParam = mId
			break
		case TAB_Model:
			mStruct.idModel = mId
			break
		case TAB_MolType:
			mStruct.idMolType = mId
			break
		case TAB_MoleculeFamily:
			mStruct.idMoleculeFamily = mId
			break
		case TAB_ParamMeta:
			mStruct.idParamMeta = mId
			break
		case TAB_ParameterValue:
			mStruct.idParameterValue = mId
			break
		case TAB_Sample:
			mStruct.idSample = mId
			break
		case TAB_SamplePrep:
			mStruct.idSamplePrep = mId
			break
		case TAB_SourceFileDirectory:
			mStruct.idSourceFileDirectory = mId
			break
		case TAB_TipManifest:
			mStruct.idTipManifest = mId
			break
		case TAB_TipPack:
			mStruct.idTipPack = mId
			break
		case TAB_TipPrep:
			mStruct.idTipPrep = mId
			break
		case TAB_TipType:
			mStruct.idTipType = mId
			break
		case TAB_TraceData:
			mStruct.idTraceData = mId
			break
		case TAB_TraceDataIndex:
			mStruct.idTraceDataIndex = mId
			break
		case TAB_TraceExpLink:
			mStruct.idTraceExpLink = mId
			break
		case TAB_TraceMeta:
			mStruct.idTraceMeta = mId
			break
		case TAB_TraceModel:
			mStruct.idTraceModel = mId
			break
		case TAB_TraceRating:
			mStruct.idTraceRating = mId
			break
		case TAB_User:
			mStruct.idUser = mId
			break
		default:
			String mErr
			sprintf mErr, "No table found for %s\r",mTab
			ModErrorUtil#DevelopmentError(description=mErr)
	EndSwitch
End Function

Static Function /Wave GetDependencies(mTab)
	String mTab
	strswitch(mTab)
		case TAB_ExpMeta:
			Make /O/T/N=0 toRetTabDep
			break
		case TAB_ExpUserData:
			Make /O/T toRetTabDep = {TAB_User}
			break
		case TAB_LinkDataMeta:
			Make /O/T toRetTabDep = {TAB_TraceMeta,TAB_TraceData}
			break
		case TAB_LinkExpModel:
			Make /O/T toRetTabDep = {TAB_Model,TAB_ExpUserData}
			break
		case TAB_LinkModelParams:
			Make /O/T toRetTabDep = {TAB_Model,TAB_ParamMeta}
			break
		case TAB_LinkModelTrace:
			Make /O/T toRetTabDep = {TAB_Model,TAB_TraceModel}
			break
		case TAB_LinkMoleTrace:
			Make /O/T toRetTabDep = {TAB_MolType,TAB_TraceMeta}
			break
		case TAB_LinkTipTrace:
			Make /O/T toRetTabDep = {TAB_TipType,TAB_TraceMeta}
			break
		case TAB_LinkTraceParam:
			Make /O/T toRetTabDep = {TAB_ParameterValue,TAB_TraceModel}
			break
		case TAB_Model:
			Make /O/T/N=0 toRetTabDep
			break
		case TAB_MolType:
			Make /O/T toRetTabDep = {TAB_MoleculeFamily}
			break
		case TAB_MoleculeFamily:
			Make /O/T/N=0 toRetTabDep
			break
		case TAB_ParamMeta:
			Make /O/T/N=0 toRetTabDep
			break
		case TAB_ParameterValue:
			Make /O/T toRetTabDep = {TAB_TraceDataIndex,TAB_ParamMeta}
			break
		case TAB_Sample:
			Make /O/T toRetTabDep = {TAB_SamplePrep,TAB_MolType}
			break
		case TAB_SamplePrep:
			Make /O/T/N=0 toRetTabDep
			break
		case TAB_SourceFileDirectory:
			Make /O/T/N=0 toRetTabDep
			break
		case TAB_TipManifest:
			Make /O/T toRetTabDep = {TAB_TipPrep,TAB_TipType,TAB_TipPack}
			break
		case TAB_TipPack:
			Make /O/T/N=0 toRetTabDep
			break
		case TAB_TipPrep:
			Make /O/T/N=0 toRetTabDep
			break
		case TAB_TipType:
			Make /O/T/N=0 toRetTabDep
			break
		case TAB_TraceData:
			Make /O/T toRetTabDep = {TAB_ExpUserData}
			break
		case TAB_TraceDataIndex:
			Make /O/T toRetTabDep = {TAB_TraceData}
			break
		case TAB_TraceExpLink:
			Make /O/T toRetTabDep = {TAB_TraceMeta,TAB_ExpUserData}
			break
		case TAB_TraceMeta:
			Make /O/T toRetTabDep = {TAB_TipManifest,TAB_User,TAB_TraceRating,TAB_Sample}
			break
		case TAB_TraceModel:
			Make /O/T toRetTabDep = {TAB_TraceMeta,TAB_TraceData}
			break
		case TAB_TraceRating:
			Make /O/T/N=0 toRetTabDep
			break
		case TAB_User:
			Make /O/T/N=0 toRetTabDep
			break
		default:
			String mErr
			sprintf mErr, "No table found for %s\r",mTab
			ModErrorUtil#DevelopmentError(description=mErr)
	EndSwitch
	Return toRetTabDep
End Function

Static Function /Wave GetColByTable(mTab)
	String mTab
	strswitch(mTab)
		case TAB_ExpMeta:
			Make /O/T toRetColTab = {FIELD_idExpUserData,FIELD_TimeStarted,FIELD_NAttemptedPulls,FIELD_SourceFile}
			break
		case TAB_ExpUserData:
			Make /O/T toRetColTab = {FIELD_idExpUserData,FIELD_Name,FIELD_Description,FIELD_idUser}
			break
		case TAB_LinkDataMeta:
			Make /O/T toRetColTab = {FIELD_idLinkDataMeta,FIELD_idTraceMeta,FIELD_idTraceData}
			break
		case TAB_LinkExpModel:
			Make /O/T toRetColTab = {FIELD_idLinkExpModel,FIELD_idModel,FIELD_idExpUserData}
			break
		case TAB_LinkModelParams:
			Make /O/T toRetColTab = {FIELD_idLinkModelParams,FIELD_idModel,FIELD_idParamMeta}
			break
		case TAB_LinkModelTrace:
			Make /O/T toRetColTab = {FIELD_idLinkModelTrace,FIELD_idModel,FIELD_idTraceModel}
			break
		case TAB_LinkMoleTrace:
			Make /O/T toRetColTab = {FIELD_idLinkMoleTrace,FIELD_idMolType,FIELD_idTraceMeta}
			break
		case TAB_LinkTipTrace:
			Make /O/T toRetColTab = {FIELD_idLinkTipTrace,FIELD_idTipType,FIELD_idTraceMeta}
			break
		case TAB_LinkTraceParam:
			Make /O/T toRetColTab = {FIELD_idLinkTraceParam,FIELD_idParameterValue,FIELD_idTraceModel}
			break
		case TAB_Model:
			Make /O/T toRetColTab = {FIELD_idModel,FIELD_ModelName,FIELD_ModelDescription}
			break
		case TAB_MolType:
			Make /O/T toRetColTab = {FIELD_idMolType,FIELD_Name,FIELD_Description,FIELD_MolMass,FIELD_idMoleculeFamily}
			break
		case TAB_MoleculeFamily:
			Make /O/T toRetColTab = {FIELD_idMoleculeFamily,FIELD_Name,FIELD_Description}
			break
		case TAB_ParamMeta:
			Make /O/T toRetColTab = {FIELD_idParamMeta,FIELD_Name,FIELD_Description,FIELD_UnitName,FIELD_UnitAbbr,FIELD_LeadStr,FIELD_Prefix,FIELD_IsRepeatable,FIELD_IsPreProccess,FIELD_ParameterNumber}
			break
		case TAB_ParameterValue:
			Make /O/T toRetColTab = {FIELD_idParameterValue,FIELD_DataIndex,FIELD_StrValues,FIELD_DataValues,FIELD_RepeatNumber,FIELD_idTraceDataIndex,FIELD_idParamMeta}
			break
		case TAB_Sample:
			Make /O/T toRetColTab = {FIELD_idSample,FIELD_Name,FIELD_Description,FIELD_ConcNanogMuL,FIELD_VolLoadedMuL,FIELD_DateDeposited,FIELD_DateCreated,FIELD_DateRinsed,FIELD_idSamplePrep,FIELD_idMolType}
			break
		case TAB_SamplePrep:
			Make /O/T toRetColTab = {FIELD_idSamplePrep,FIELD_Name,FIELD_Description}
			break
		case TAB_SourceFileDirectory:
			Make /O/T toRetColTab = {FIELD_idSourceDir,FIELD_DirectoryName}
			break
		case TAB_TipManifest:
			Make /O/T toRetColTab = {FIELD_idTipManifest,FIELD_Name,FIELD_Description,FIELD_PackPosition,FIELD_TimeMade,FIELD_TimeRinsed,FIELD_idTipPrep,FIELD_idTipType,FIELD_idTipPack}
			break
		case TAB_TipPack:
			Make /O/T toRetColTab = {FIELD_idTipPack,FIELD_Name,FIELD_Description}
			break
		case TAB_TipPrep:
			Make /O/T toRetColTab = {FIELD_idTipPrep,FIELD_Name,FIELD_Description,FIELD_SecondsEtchGold,FIELD_SecondsEtchChromium}
			break
		case TAB_TipType:
			Make /O/T toRetColTab = {FIELD_idTipTypes,FIELD_Name,FIELD_Description}
			break
		case TAB_TraceData:
			Make /O/T toRetColTab = {FIELD_idTraceData,FIELD_FileName,FIELD_idExpUserData}
			break
		case TAB_TraceDataIndex:
			Make /O/T toRetColTab = {FIELD_idParameterValue,FIELD_StartIndex,FIELD_EndIndex,FIELD_idTraceData}
			break
		case TAB_TraceExpLink:
			Make /O/T toRetColTab = {FIELD_idTraceExpLink,FIELD_idTraceMeta,FIELD_idExpUserData}
			break
		case TAB_TraceMeta:
			Make /O/T toRetColTab = {FIELD_idTraceMeta,FIELD_Description,FIELD_ApproachVel,FIELD_RetractVel,FIELD_TimeStarted,FIELD_TimeEnded,FIELD_DwellTowards,FIELD_DwellAway,FIELD_SampleRate,FIELD_FilteredSampleRate,FIELD_DeflInvols,FIELD_Temperature,FIELD_SpringConstant,FIELD_FirstResRef,FIELD_ThermalQ,FIELD_LocationX,FIELD_LocationY,FIELD_OffsetX,FIELD_OffsetY,FIELD_Spot,FIELD_idTipManifest,FIELD_idUser,FIELD_idTraceRating,FIELD_idSample}
			break
		case TAB_TraceModel:
			Make /O/T toRetColTab = {FIELD_idTraceModel,FIELD_idTraceMeta,FIELD_idTraceData}
			break
		case TAB_TraceRating:
			Make /O/T toRetColTab = {FIELD_idTraceRating,FIELD_RatingValue,FIELD_Name,FIELD_Description}
			break
		case TAB_User:
			Make /O/T toRetColTab = {FIELD_idUser,FIELD_Name}
			break
		default:
			String mErr
			sprintf mErr, "No table found for %s\r",mTab
			ModErrorUtil#DevelopmentError(description=mErr)
	EndSwitch
	return toRetColTab
End Function

Static Function /Wave GetTypesByTable(mTab)
	String mTab
	strswitch(mTab)
		case TAB_ExpMeta:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_DATE,SQL_PTYPE_INT,SQL_PTYPE_GENSTR}
			break
		case TAB_ExpUserData:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_DESCR,SQL_PTYPE_FK}
			break
		case TAB_LinkDataMeta:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_LinkExpModel:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_LinkModelParams:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_LinkModelTrace:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_LinkMoleTrace:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_LinkTipTrace:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_LinkTraceParam:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_Model:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_DESCR}
			break
		case TAB_MolType:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_DESCR,SQL_PTYPE_DOUBLE,SQL_PTYPE_FK}
			break
		case TAB_MoleculeFamily:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_DESCR}
			break
		case TAB_ParamMeta:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_DESCR,SQL_PTYPE_NAME,SQL_PTYPE_GENSTR,SQL_PTYPE_GENSTR,SQL_PTYPE_GENSTR,SQL_PTYPE_INT,SQL_PTYPE_INT,SQL_PTYPE_INT}
			break
		case TAB_ParameterValue:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_DOUBLE,SQL_PTYPE_GENSTR,SQL_PTYPE_DOUBLE,SQL_PTYPE_INT,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_Sample:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_DESCR,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DATE,SQL_PTYPE_DATE,SQL_PTYPE_DATE,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_SamplePrep:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_DESCR}
			break
		case TAB_SourceFileDirectory:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME}
			break
		case TAB_TipManifest:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_DESCR,SQL_PTYPE_GENSTR,SQL_PTYPE_DATE,SQL_PTYPE_DATE,SQL_PTYPE_FK,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_TipPack:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_DESCR}
			break
		case TAB_TipPrep:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_DESCR,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE}
			break
		case TAB_TipType:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_DESCR}
			break
		case TAB_TraceData:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME,SQL_PTYPE_FK}
			break
		case TAB_TraceDataIndex:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_FK}
			break
		case TAB_TraceExpLink:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_TraceMeta:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_DESCR,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DATE,SQL_PTYPE_DATE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_DOUBLE,SQL_PTYPE_INT,SQL_PTYPE_FK,SQL_PTYPE_FK,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_TraceModel:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_FK,SQL_PTYPE_FK}
			break
		case TAB_TraceRating:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_INT,SQL_PTYPE_NAME,SQL_PTYPE_DESCR}
			break
		case TAB_User:
			Make /O toRetColType = {SQL_PTYPE_ID,SQL_PTYPE_NAME}
			break
		default:
			String mErr
			sprintf mErr, "No table found for %s\r",mTab
			ModErrorUtil#DevelopmentError(description=mErr)
	EndSwitch
	return toRetColType
End Function

Static Function /Wave GetWhatDependsOnTable(mTab)
	String mTab
	strswitch(mTab)
		case TAB_ExpMeta:
			Make /O/T/N=0 toRetDependencies
			break
		case TAB_ExpUserData:
			Make /O/T toRetDependencies = {TAB_LinkExpModel,TAB_TraceData,TAB_TraceExpLink}
			break
		case TAB_LinkDataMeta:
			Make /O/T/N=0 toRetDependencies
			break
		case TAB_LinkExpModel:
			Make /O/T/N=0 toRetDependencies
			break
		case TAB_LinkModelParams:
			Make /O/T/N=0 toRetDependencies
			break
		case TAB_LinkModelTrace:
			Make /O/T/N=0 toRetDependencies
			break
		case TAB_LinkMoleTrace:
			Make /O/T/N=0 toRetDependencies
			break
		case TAB_LinkTipTrace:
			Make /O/T/N=0 toRetDependencies
			break
		case TAB_LinkTraceParam:
			Make /O/T/N=0 toRetDependencies
			break
		case TAB_Model:
			Make /O/T toRetDependencies = {TAB_LinkExpModel,TAB_LinkModelParams,TAB_LinkModelTrace}
			break
		case TAB_MolType:
			Make /O/T toRetDependencies = {TAB_LinkMoleTrace,TAB_Sample}
			break
		case TAB_MoleculeFamily:
			Make /O/T toRetDependencies = {TAB_MolType}
			break
		case TAB_ParamMeta:
			Make /O/T toRetDependencies = {TAB_LinkModelParams,TAB_ParameterValue}
			break
		case TAB_ParameterValue:
			Make /O/T toRetDependencies = {TAB_LinkTraceParam}
			break
		case TAB_Sample:
			Make /O/T toRetDependencies = {TAB_TraceMeta}
			break
		case TAB_SamplePrep:
			Make /O/T toRetDependencies = {TAB_Sample}
			break
		case TAB_SourceFileDirectory:
			Make /O/T/N=0 toRetDependencies
			break
		case TAB_TipManifest:
			Make /O/T toRetDependencies = {TAB_TraceMeta}
			break
		case TAB_TipPack:
			Make /O/T toRetDependencies = {TAB_TipManifest}
			break
		case TAB_TipPrep:
			Make /O/T toRetDependencies = {TAB_TipManifest}
			break
		case TAB_TipType:
			Make /O/T toRetDependencies = {TAB_LinkTipTrace,TAB_TipManifest}
			break
		case TAB_TraceData:
			Make /O/T toRetDependencies = {TAB_LinkDataMeta,TAB_TraceDataIndex,TAB_TraceModel}
			break
		case TAB_TraceDataIndex:
			Make /O/T toRetDependencies = {TAB_ParameterValue}
			break
		case TAB_TraceExpLink:
			Make /O/T/N=0 toRetDependencies
			break
		case TAB_TraceMeta:
			Make /O/T toRetDependencies = {TAB_LinkDataMeta,TAB_LinkMoleTrace,TAB_LinkTipTrace,TAB_TraceExpLink,TAB_TraceModel}
			break
		case TAB_TraceModel:
			Make /O/T toRetDependencies = {TAB_LinkModelTrace,TAB_LinkTraceParam}
			break
		case TAB_TraceRating:
			Make /O/T toRetDependencies = {TAB_TraceMeta}
			break
		case TAB_User:
			Make /O/T toRetDependencies = {TAB_ExpUserData,TAB_TraceMeta}
			break
		default:
			String mErr
			sprintf mErr, "No table found for %s\r",mTab
			ModErrorUtil#DevelopmentError(description=mErr)
	EndSwitch
	return toRetDependencies
End Function


