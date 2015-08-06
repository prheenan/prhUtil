// Use modern global access method, strict compilation
#pragma rtGlobals=3
#pragma ModuleName=ModSqlCypherUtilFuncs
#include ".:SqlUtil"
#include ".:..:Util:Defines"
#include ".:..:Util:ErrorUtil"
#include ".:SqlCypherAutoDefines"
//Column names and types
Static Function /Wave GetColsOfExpMeta([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T ExpMeta = {FIELD_idExpUserData,FIELD_TimeStarted,FIELD_NAttemptedPulls,FIELD_SourceFile}
	else
		Make /O/T ExpMeta = {FIELD_TimeStarted,FIELD_NAttemptedPulls,FIELD_SourceFile}
	endif
	return ExpMeta
End Function


Static Function /Wave GetColsOfExpUserData([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T ExpUserData = {FIELD_idExpUserData,FIELD_Name,FIELD_Description,FIELD_idUser}
	else
		Make /O/T ExpUserData = {FIELD_Name,FIELD_Description,FIELD_idUser}
	endif
	return ExpUserData
End Function


Static Function /Wave GetColsOfLinkDataMeta([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T LinkDataMeta = {FIELD_idLinkDataMeta,FIELD_idTraceMeta,FIELD_idTraceData}
	else
		Make /O/T LinkDataMeta = {FIELD_idTraceMeta,FIELD_idTraceData}
	endif
	return LinkDataMeta
End Function


Static Function /Wave GetColsOfLinkExpModel([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T LinkExpModel = {FIELD_idLinkExpModel,FIELD_idModel,FIELD_idExpUserData}
	else
		Make /O/T LinkExpModel = {FIELD_idModel,FIELD_idExpUserData}
	endif
	return LinkExpModel
End Function


Static Function /Wave GetColsOfLinkModelParams([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T LinkModelParams = {FIELD_idLinkModelParams,FIELD_idModel,FIELD_idParamMeta}
	else
		Make /O/T LinkModelParams = {FIELD_idModel,FIELD_idParamMeta}
	endif
	return LinkModelParams
End Function


Static Function /Wave GetColsOfLinkModelTrace([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T LinkModelTrace = {FIELD_idLinkModelTrace,FIELD_idModel,FIELD_idTraceModel}
	else
		Make /O/T LinkModelTrace = {FIELD_idModel,FIELD_idTraceModel}
	endif
	return LinkModelTrace
End Function


Static Function /Wave GetColsOfLinkMoleTrace([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T LinkMoleTrace = {FIELD_idLinkMoleTrace,FIELD_idMolType,FIELD_idTraceMeta}
	else
		Make /O/T LinkMoleTrace = {FIELD_idMolType,FIELD_idTraceMeta}
	endif
	return LinkMoleTrace
End Function


Static Function /Wave GetColsOfLinkTipTrace([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T LinkTipTrace = {FIELD_idLinkTipTrace,FIELD_idTipType,FIELD_idTraceMeta}
	else
		Make /O/T LinkTipTrace = {FIELD_idTipType,FIELD_idTraceMeta}
	endif
	return LinkTipTrace
End Function


Static Function /Wave GetColsOfLinkTraceParam([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T LinkTraceParam = {FIELD_idLinkTraceParam,FIELD_idParameterValue,FIELD_idTraceModel}
	else
		Make /O/T LinkTraceParam = {FIELD_idParameterValue,FIELD_idTraceModel}
	endif
	return LinkTraceParam
End Function


Static Function /Wave GetColsOfModel([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T Model = {FIELD_idModel,FIELD_ModelName,FIELD_ModelDescription}
	else
		Make /O/T Model = {FIELD_ModelName,FIELD_ModelDescription}
	endif
	return Model
End Function


Static Function /Wave GetColsOfMolType([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T MolType = {FIELD_idMolType,FIELD_Name,FIELD_Description,FIELD_MolMass,FIELD_idMoleculeFamily}
	else
		Make /O/T MolType = {FIELD_Name,FIELD_Description,FIELD_MolMass,FIELD_idMoleculeFamily}
	endif
	return MolType
End Function


Static Function /Wave GetColsOfMoleculeFamily([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T MoleculeFamily = {FIELD_idMoleculeFamily,FIELD_Name,FIELD_Description}
	else
		Make /O/T MoleculeFamily = {FIELD_Name,FIELD_Description}
	endif
	return MoleculeFamily
End Function


Static Function /Wave GetColsOfParamMeta([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T ParamMeta = {FIELD_idParamMeta,FIELD_Name,FIELD_Description,FIELD_UnitName,FIELD_UnitAbbr,FIELD_LeadStr,FIELD_Prefix,FIELD_IsRepeatable,FIELD_IsPreProccess,FIELD_ParameterNumber}
	else
		Make /O/T ParamMeta = {FIELD_Name,FIELD_Description,FIELD_UnitName,FIELD_UnitAbbr,FIELD_LeadStr,FIELD_Prefix,FIELD_IsRepeatable,FIELD_IsPreProccess,FIELD_ParameterNumber}
	endif
	return ParamMeta
End Function


Static Function /Wave GetColsOfParameterValue([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T ParameterValue = {FIELD_idParameterValue,FIELD_DataIndex,FIELD_StrValues,FIELD_DataValues,FIELD_RepeatNumber,FIELD_idTraceDataIndex,FIELD_idParamMeta}
	else
		Make /O/T ParameterValue = {FIELD_DataIndex,FIELD_StrValues,FIELD_DataValues,FIELD_RepeatNumber,FIELD_idTraceDataIndex,FIELD_idParamMeta}
	endif
	return ParameterValue
End Function


Static Function /Wave GetColsOfSample([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T Sample = {FIELD_idSample,FIELD_Name,FIELD_Description,FIELD_ConcNanogMuL,FIELD_VolLoadedMuL,FIELD_DateDeposited,FIELD_DateCreated,FIELD_DateRinsed,FIELD_idSamplePrep,FIELD_idMolType}
	else
		Make /O/T Sample = {FIELD_Name,FIELD_Description,FIELD_ConcNanogMuL,FIELD_VolLoadedMuL,FIELD_DateDeposited,FIELD_DateCreated,FIELD_DateRinsed,FIELD_idSamplePrep,FIELD_idMolType}
	endif
	return Sample
End Function


Static Function /Wave GetColsOfSamplePrep([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T SamplePrep = {FIELD_idSamplePrep,FIELD_Name,FIELD_Description}
	else
		Make /O/T SamplePrep = {FIELD_Name,FIELD_Description}
	endif
	return SamplePrep
End Function


Static Function /Wave GetColsOfSourceFileDirectory([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T SourceFileDirectory = {FIELD_idSourceDir,FIELD_DirectoryName}
	else
		Make /O/T SourceFileDirectory = {FIELD_DirectoryName}
	endif
	return SourceFileDirectory
End Function


Static Function /Wave GetColsOfTipManifest([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T TipManifest = {FIELD_idTipManifest,FIELD_Name,FIELD_Description,FIELD_PackPosition,FIELD_TimeMade,FIELD_TimeRinsed,FIELD_idTipPrep,FIELD_idTipType,FIELD_idTipPack}
	else
		Make /O/T TipManifest = {FIELD_Name,FIELD_Description,FIELD_PackPosition,FIELD_TimeMade,FIELD_TimeRinsed,FIELD_idTipPrep,FIELD_idTipType,FIELD_idTipPack}
	endif
	return TipManifest
End Function


Static Function /Wave GetColsOfTipPack([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T TipPack = {FIELD_idTipPack,FIELD_Name,FIELD_Description}
	else
		Make /O/T TipPack = {FIELD_Name,FIELD_Description}
	endif
	return TipPack
End Function


Static Function /Wave GetColsOfTipPrep([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T TipPrep = {FIELD_idTipPrep,FIELD_Name,FIELD_Description,FIELD_SecondsEtchGold,FIELD_SecondsEtchChromium}
	else
		Make /O/T TipPrep = {FIELD_Name,FIELD_Description,FIELD_SecondsEtchGold,FIELD_SecondsEtchChromium}
	endif
	return TipPrep
End Function


Static Function /Wave GetColsOfTipType([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T TipType = {FIELD_idTipTypes,FIELD_Name,FIELD_Description}
	else
		Make /O/T TipType = {FIELD_Name,FIELD_Description}
	endif
	return TipType
End Function


Static Function /Wave GetColsOfTraceData([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T TraceData = {FIELD_idTraceData,FIELD_FileName,FIELD_idExpUserData}
	else
		Make /O/T TraceData = {FIELD_FileName,FIELD_idExpUserData}
	endif
	return TraceData
End Function


Static Function /Wave GetColsOfTraceDataIndex([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T TraceDataIndex = {FIELD_idParameterValue,FIELD_StartIndex,FIELD_EndIndex,FIELD_idTraceData}
	else
		Make /O/T TraceDataIndex = {FIELD_StartIndex,FIELD_EndIndex,FIELD_idTraceData}
	endif
	return TraceDataIndex
End Function


Static Function /Wave GetColsOfTraceExpLink([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T TraceExpLink = {FIELD_idTraceExpLink,FIELD_idTraceMeta,FIELD_idExpUserData}
	else
		Make /O/T TraceExpLink = {FIELD_idTraceMeta,FIELD_idExpUserData}
	endif
	return TraceExpLink
End Function


Static Function /Wave GetColsOfTraceMeta([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T TraceMeta = {FIELD_idTraceMeta,FIELD_Description,FIELD_ApproachVel,FIELD_RetractVel,FIELD_TimeStarted,FIELD_TimeEnded,FIELD_DwellTowards,FIELD_DwellAway,FIELD_SampleRate,FIELD_FilteredSampleRate,FIELD_DeflInvols,FIELD_Temperature,FIELD_SpringConstant,FIELD_FirstResRef,FIELD_ThermalQ,FIELD_LocationX,FIELD_LocationY,FIELD_OffsetX,FIELD_OffsetY,FIELD_Spot,FIELD_idTipManifest,FIELD_idUser,FIELD_idTraceRating,FIELD_idSample}
	else
		Make /O/T TraceMeta = {FIELD_Description,FIELD_ApproachVel,FIELD_RetractVel,FIELD_TimeStarted,FIELD_TimeEnded,FIELD_DwellTowards,FIELD_DwellAway,FIELD_SampleRate,FIELD_FilteredSampleRate,FIELD_DeflInvols,FIELD_Temperature,FIELD_SpringConstant,FIELD_FirstResRef,FIELD_ThermalQ,FIELD_LocationX,FIELD_LocationY,FIELD_OffsetX,FIELD_OffsetY,FIELD_Spot,FIELD_idTipManifest,FIELD_idUser,FIELD_idTraceRating,FIELD_idSample}
	endif
	return TraceMeta
End Function


Static Function /Wave GetColsOfTraceModel([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T TraceModel = {FIELD_idTraceModel,FIELD_idTraceMeta,FIELD_idTraceData}
	else
		Make /O/T TraceModel = {FIELD_idTraceMeta,FIELD_idTraceData}
	endif
	return TraceModel
End Function


Static Function /Wave GetColsOfTraceRating([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T TraceRating = {FIELD_idTraceRating,FIELD_RatingValue,FIELD_Name,FIELD_Description}
	else
		Make /O/T TraceRating = {FIELD_RatingValue,FIELD_Name,FIELD_Description}
	endif
	return TraceRating
End Function


Static Function /Wave GetColsOfUser([IncludeId])
	Variable IncludeId
	IncludeId = ParamIsDefault(IncludeId) ? ModDefine#False() : IncludeId
	if (IncludeId)
		Make /O/T User = {FIELD_idUser,FIELD_Name}
	else
		Make /O/T User = {FIELD_Name}
	endif
	return User
End Function



