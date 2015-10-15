// Use modern global access method, strict compilation
#pragma rtGlobals=3
#pragma ModuleName=ModSqlCypherGuiHandle
#include ":SqlUtil"
#include "::Util:Defines"
#include "::Util:ErrorUtil"
#include ":SqlCypherAutoDefines"
#include ":SqlCypherInterface"
#include ":SqlCypherUtilFuncs"
#include ":SqlCypherAutoFuncs"
//Defined Handlers
Static Function /S GetMenuByTable(mTab)
	String mTab
	strswitch(mTab)
		case TAB_ExpMeta:
			return "GetMenuExpMeta"
			break
		case TAB_LinkExpModel:
			return "GetMenuLinkExpModel"
			break
		case TAB_LinkModelParams:
			return "GetMenuLinkModelParams"
			break
		case TAB_LinkMoleTrace:
			return "GetMenuLinkMoleTrace"
			break
		case TAB_LinkTipTrace:
			return "GetMenuLinkTipTrace"
			break
		case TAB_LinkTraceParam:
			return "GetMenuLinkTraceParam"
			break
		case TAB_Model:
			return "GetMenuModel"
			break
		case TAB_MolType:
			return "GetMenuMolType"
			break
		case TAB_MoleculeFamily:
			return "GetMenuMoleculeFamily"
			break
		case TAB_ParamMeta:
			return "GetMenuParamMeta"
			break
		case TAB_ParameterValue:
			return "GetMenuParameterValue"
			break
		case TAB_Sample:
			return "GetMenuSample"
			break
		case TAB_SamplePrep:
			return "GetMenuSamplePrep"
			break
		case TAB_SourceFileDirectory:
			return "GetMenuSourceFileDirectory"
			break
		case TAB_TipManifest:
			return "GetMenuTipManifest"
			break
		case TAB_TipPack:
			return "GetMenuTipPack"
			break
		case TAB_TipPrep:
			return "GetMenuTipPrep"
			break
		case TAB_TipType:
			return "GetMenuTipType"
			break
		case TAB_TraceData:
			return "GetMenuTraceData"
			break
		case TAB_TraceDataIndex:
			return "GetMenuTraceDataIndex"
			break
		case TAB_TraceExpLink:
			return "GetMenuTraceExpLink"
			break
		case TAB_TraceMeta:
			return "GetMenuTraceMeta"
			break
		case TAB_TraceModel:
			return "GetMenuTraceModel"
			break
		case TAB_TraceRating:
			return "GetMenuTraceRating"
			break
		case TAB_User:
			return "GetMenuUser"
			break
		default:
			String mErr
			sprintf mErr, "No table found for %s\r",mTab
			ModErrorUtil#DevelopmentError(description=mErr)
	EndSwitch
End Function

Static Function InitHandleExpMeta(mTab,mStr,mNum)
	Struct ExpMeta & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idExpMeta=mNum[0]
	mTab.Name=mStr[1]
	mTab.Description=mStr[2]
	mTab.SourceFile=mStr[3]
End Function

Static Function InitWavesExpMeta(mTab,mStr,mNum)
	Struct ExpMeta & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 4
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idExpMeta
	mStr[1]=mTab.Name
	mStr[2]=mTab.Description
	mStr[3]=mTab.SourceFile
End Function

Function SqlHandleExpMeta(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct ExpMeta mTabStruct
	InitHandleExpMeta(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of ExpMeta
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_ExpMeta
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idExpMeta),mTabStruct.idExpMeta)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_SourceFile),mTabStruct.SourceFile)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuExpMeta()
	String mTab=TAB_ExpMeta
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleLinkExpModel(mTab,mStr,mNum)
	Struct LinkExpModel & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idLinkExpModel=mNum[0]
	mTab.idModel=mNum[1]
	mTab.idExpMeta=mNum[2]
End Function

Static Function InitWavesLinkExpModel(mTab,mStr,mNum)
	Struct LinkExpModel & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idLinkExpModel
	mNum[1]=mTab.idModel
	mNum[2]=mTab.idExpMeta
End Function

Function SqlHandleLinkExpModel(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct LinkExpModel mTabStruct
	InitHandleLinkExpModel(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of LinkExpModel
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_LinkExpModel
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idLinkExpModel),mTabStruct.idLinkExpModel)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idModel),mTabStruct.idModel)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idExpMeta),mTabStruct.idExpMeta)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuLinkExpModel()
	String mTab=TAB_LinkExpModel
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleLinkModelParams(mTab,mStr,mNum)
	Struct LinkModelParams & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idLinkModelParams=mNum[0]
	mTab.idModel=mNum[1]
	mTab.idParamMeta=mNum[2]
End Function

Static Function InitWavesLinkModelParams(mTab,mStr,mNum)
	Struct LinkModelParams & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idLinkModelParams
	mNum[1]=mTab.idModel
	mNum[2]=mTab.idParamMeta
End Function

Function SqlHandleLinkModelParams(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct LinkModelParams mTabStruct
	InitHandleLinkModelParams(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of LinkModelParams
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_LinkModelParams
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idLinkModelParams),mTabStruct.idLinkModelParams)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idModel),mTabStruct.idModel)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idParamMeta),mTabStruct.idParamMeta)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuLinkModelParams()
	String mTab=TAB_LinkModelParams
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleLinkMoleTrace(mTab,mStr,mNum)
	Struct LinkMoleTrace & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idLinkMoleTrace=mNum[0]
	mTab.idMolType=mNum[1]
	mTab.idTraceMeta=mNum[2]
End Function

Static Function InitWavesLinkMoleTrace(mTab,mStr,mNum)
	Struct LinkMoleTrace & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idLinkMoleTrace
	mNum[1]=mTab.idMolType
	mNum[2]=mTab.idTraceMeta
End Function

Function SqlHandleLinkMoleTrace(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct LinkMoleTrace mTabStruct
	InitHandleLinkMoleTrace(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of LinkMoleTrace
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_LinkMoleTrace
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idLinkMoleTrace),mTabStruct.idLinkMoleTrace)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idMolType),mTabStruct.idMolType)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceMeta),mTabStruct.idTraceMeta)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuLinkMoleTrace()
	String mTab=TAB_LinkMoleTrace
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleLinkTipTrace(mTab,mStr,mNum)
	Struct LinkTipTrace & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idLinkTipTrace=mNum[0]
	mTab.idTipType=mNum[1]
	mTab.idTraceMeta=mNum[2]
End Function

Static Function InitWavesLinkTipTrace(mTab,mStr,mNum)
	Struct LinkTipTrace & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idLinkTipTrace
	mNum[1]=mTab.idTipType
	mNum[2]=mTab.idTraceMeta
End Function

Function SqlHandleLinkTipTrace(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct LinkTipTrace mTabStruct
	InitHandleLinkTipTrace(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of LinkTipTrace
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_LinkTipTrace
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idLinkTipTrace),mTabStruct.idLinkTipTrace)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTipType),mTabStruct.idTipType)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceMeta),mTabStruct.idTraceMeta)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuLinkTipTrace()
	String mTab=TAB_LinkTipTrace
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleLinkTraceParam(mTab,mStr,mNum)
	Struct LinkTraceParam & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idLinkTraceParam=mNum[0]
	mTab.idParameterValue=mNum[1]
	mTab.idTraceModel=mNum[2]
End Function

Static Function InitWavesLinkTraceParam(mTab,mStr,mNum)
	Struct LinkTraceParam & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idLinkTraceParam
	mNum[1]=mTab.idParameterValue
	mNum[2]=mTab.idTraceModel
End Function

Function SqlHandleLinkTraceParam(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct LinkTraceParam mTabStruct
	InitHandleLinkTraceParam(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of LinkTraceParam
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_LinkTraceParam
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idLinkTraceParam),mTabStruct.idLinkTraceParam)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idParameterValue),mTabStruct.idParameterValue)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceModel),mTabStruct.idTraceModel)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuLinkTraceParam()
	String mTab=TAB_LinkTraceParam
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleModel(mTab,mStr,mNum)
	Struct Model & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idModel=mNum[0]
	mTab.Name=mStr[1]
	mTab.Description=mStr[2]
End Function

Static Function InitWavesModel(mTab,mStr,mNum)
	Struct Model & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idModel
	mStr[1]=mTab.Name
	mStr[2]=mTab.Description
End Function

Function SqlHandleModel(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct Model mTabStruct
	InitHandleModel(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of Model
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_Model
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idModel),mTabStruct.idModel)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuModel()
	String mTab=TAB_Model
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleMolType(mTab,mStr,mNum)
	Struct MolType & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idMolType=mNum[0]
	mTab.Name=mStr[1]
	mTab.Description=mStr[2]
	mTab.MolMass=mNum[3]
	mTab.idMoleculeFamily=mNum[4]
End Function

Static Function InitWavesMolType(mTab,mStr,mNum)
	Struct MolType & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 5
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idMolType
	mStr[1]=mTab.Name
	mStr[2]=mTab.Description
	mNum[3]=mTab.MolMass
	mNum[4]=mTab.idMoleculeFamily
End Function

Function SqlHandleMolType(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct MolType mTabStruct
	InitHandleMolType(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of MolType
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_MolType
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idMolType),mTabStruct.idMolType)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_MolMass),mTabStruct.MolMass)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idMoleculeFamily),mTabStruct.idMoleculeFamily)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuMolType()
	String mTab=TAB_MolType
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleMoleculeFamily(mTab,mStr,mNum)
	Struct MoleculeFamily & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idMoleculeFamily=mNum[0]
	mTab.Name=mStr[1]
	mTab.Description=mStr[2]
End Function

Static Function InitWavesMoleculeFamily(mTab,mStr,mNum)
	Struct MoleculeFamily & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idMoleculeFamily
	mStr[1]=mTab.Name
	mStr[2]=mTab.Description
End Function

Function SqlHandleMoleculeFamily(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct MoleculeFamily mTabStruct
	InitHandleMoleculeFamily(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of MoleculeFamily
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_MoleculeFamily
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idMoleculeFamily),mTabStruct.idMoleculeFamily)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuMoleculeFamily()
	String mTab=TAB_MoleculeFamily
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleParamMeta(mTab,mStr,mNum)
	Struct ParamMeta & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idParamMeta=mNum[0]
	mTab.Name=mStr[1]
	mTab.Description=mStr[2]
	mTab.UnitName=mStr[3]
	mTab.UnitAbbr=mStr[4]
	mTab.LeadStr=mStr[5]
	mTab.Prefix=mStr[6]
	mTab.IsRepeatable=mNum[7]
	mTab.IsPreProccess=mNum[8]
	mTab.ParameterNumber=mNum[9]
End Function

Static Function InitWavesParamMeta(mTab,mStr,mNum)
	Struct ParamMeta & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 10
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idParamMeta
	mStr[1]=mTab.Name
	mStr[2]=mTab.Description
	mStr[3]=mTab.UnitName
	mStr[4]=mTab.UnitAbbr
	mStr[5]=mTab.LeadStr
	mStr[6]=mTab.Prefix
	mNum[7]=mTab.IsRepeatable
	mNum[8]=mTab.IsPreProccess
	mNum[9]=mTab.ParameterNumber
End Function

Function SqlHandleParamMeta(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct ParamMeta mTabStruct
	InitHandleParamMeta(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of ParamMeta
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_ParamMeta
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idParamMeta),mTabStruct.idParamMeta)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_UnitName),mTabStruct.UnitName)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_UnitAbbr),mTabStruct.UnitAbbr)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_LeadStr),mTabStruct.LeadStr)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Prefix),mTabStruct.Prefix)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_IsRepeatable),mTabStruct.IsRepeatable)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_IsPreProccess),mTabStruct.IsPreProccess)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_ParameterNumber),mTabStruct.ParameterNumber)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuParamMeta()
	String mTab=TAB_ParamMeta
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleParameterValue(mTab,mStr,mNum)
	Struct ParameterValue & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idParameterValue=mNum[0]
	mTab.DataIndex=mNum[1]
	mTab.StrValues=mStr[2]
	mTab.DataValues=mNum[3]
	mTab.RepeatNumber=mNum[4]
	mTab.idTraceDataIndex=mNum[5]
	mTab.idParamMeta=mNum[6]
End Function

Static Function InitWavesParameterValue(mTab,mStr,mNum)
	Struct ParameterValue & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 7
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idParameterValue
	mNum[1]=mTab.DataIndex
	mStr[2]=mTab.StrValues
	mNum[3]=mTab.DataValues
	mNum[4]=mTab.RepeatNumber
	mNum[5]=mTab.idTraceDataIndex
	mNum[6]=mTab.idParamMeta
End Function

Function SqlHandleParameterValue(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct ParameterValue mTabStruct
	InitHandleParameterValue(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of ParameterValue
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_ParameterValue
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idParameterValue),mTabStruct.idParameterValue)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_DataIndex),mTabStruct.DataIndex)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_StrValues),mTabStruct.StrValues)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_DataValues),mTabStruct.DataValues)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_RepeatNumber),mTabStruct.RepeatNumber)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceDataIndex),mTabStruct.idTraceDataIndex)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idParamMeta),mTabStruct.idParamMeta)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuParameterValue()
	String mTab=TAB_ParameterValue
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleSample(mTab,mStr,mNum)
	Struct Sample & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idSample=mNum[0]
	mTab.Name=mStr[1]
	mTab.Description=mStr[2]
	mTab.ConcNanogMuL=mNum[3]
	mTab.VolLoadedMuL=mNum[4]
	mTab.DateDeposited=mStr[5]
	mTab.DateCreated=mStr[6]
	mTab.DateRinsed=mStr[7]
	mTab.idSamplePrep=mNum[8]
	mTab.idMolType=mNum[9]
End Function

Static Function InitWavesSample(mTab,mStr,mNum)
	Struct Sample & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 10
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idSample
	mStr[1]=mTab.Name
	mStr[2]=mTab.Description
	mNum[3]=mTab.ConcNanogMuL
	mNum[4]=mTab.VolLoadedMuL
	mStr[5]=mTab.DateDeposited
	mStr[6]=mTab.DateCreated
	mStr[7]=mTab.DateRinsed
	mNum[8]=mTab.idSamplePrep
	mNum[9]=mTab.idMolType
End Function

Function SqlHandleSample(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct Sample mTabStruct
	InitHandleSample(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of Sample
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_Sample
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idSample),mTabStruct.idSample)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_ConcNanogMuL),mTabStruct.ConcNanogMuL)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_VolLoadedMuL),mTabStruct.VolLoadedMuL)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_DateDeposited),mTabStruct.DateDeposited)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_DateCreated),mTabStruct.DateCreated)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_DateRinsed),mTabStruct.DateRinsed)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idSamplePrep),mTabStruct.idSamplePrep)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idMolType),mTabStruct.idMolType)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuSample()
	String mTab=TAB_Sample
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleSamplePrep(mTab,mStr,mNum)
	Struct SamplePrep & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idSamplePrep=mNum[0]
	mTab.Name=mStr[1]
	mTab.Description=mStr[2]
End Function

Static Function InitWavesSamplePrep(mTab,mStr,mNum)
	Struct SamplePrep & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idSamplePrep
	mStr[1]=mTab.Name
	mStr[2]=mTab.Description
End Function

Function SqlHandleSamplePrep(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct SamplePrep mTabStruct
	InitHandleSamplePrep(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of SamplePrep
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_SamplePrep
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idSamplePrep),mTabStruct.idSamplePrep)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuSamplePrep()
	String mTab=TAB_SamplePrep
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleSourceFileDirectory(mTab,mStr,mNum)
	Struct SourceFileDirectory & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idSourceDir=mNum[0]
	mTab.DirectoryName=mStr[1]
End Function

Static Function InitWavesSourceFileDirectory(mTab,mStr,mNum)
	Struct SourceFileDirectory & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 2
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idSourceDir
	mStr[1]=mTab.DirectoryName
End Function

Function SqlHandleSourceFileDirectory(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct SourceFileDirectory mTabStruct
	InitHandleSourceFileDirectory(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of SourceFileDirectory
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_SourceFileDirectory
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idSourceDir),mTabStruct.idSourceDir)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_DirectoryName),mTabStruct.DirectoryName)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuSourceFileDirectory()
	String mTab=TAB_SourceFileDirectory
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleTipManifest(mTab,mStr,mNum)
	Struct TipManifest & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idTipManifest=mNum[0]
	mTab.Name=mStr[1]
	mTab.Description=mStr[2]
	mTab.PackPosition=mStr[3]
	mTab.TimeMade=mStr[4]
	mTab.TimeRinsed=mStr[5]
	mTab.idTipPrep=mNum[6]
	mTab.idTipType=mNum[7]
	mTab.idTipPack=mNum[8]
End Function

Static Function InitWavesTipManifest(mTab,mStr,mNum)
	Struct TipManifest & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 9
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idTipManifest
	mStr[1]=mTab.Name
	mStr[2]=mTab.Description
	mStr[3]=mTab.PackPosition
	mStr[4]=mTab.TimeMade
	mStr[5]=mTab.TimeRinsed
	mNum[6]=mTab.idTipPrep
	mNum[7]=mTab.idTipType
	mNum[8]=mTab.idTipPack
End Function

Function SqlHandleTipManifest(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct TipManifest mTabStruct
	InitHandleTipManifest(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of TipManifest
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_TipManifest
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTipManifest),mTabStruct.idTipManifest)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_PackPosition),mTabStruct.PackPosition)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_TimeMade),mTabStruct.TimeMade)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_TimeRinsed),mTabStruct.TimeRinsed)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTipPrep),mTabStruct.idTipPrep)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTipType),mTabStruct.idTipType)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTipPack),mTabStruct.idTipPack)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuTipManifest()
	String mTab=TAB_TipManifest
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleTipPack(mTab,mStr,mNum)
	Struct TipPack & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idTipPack=mNum[0]
	mTab.Name=mStr[1]
	mTab.Description=mStr[2]
End Function

Static Function InitWavesTipPack(mTab,mStr,mNum)
	Struct TipPack & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idTipPack
	mStr[1]=mTab.Name
	mStr[2]=mTab.Description
End Function

Function SqlHandleTipPack(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct TipPack mTabStruct
	InitHandleTipPack(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of TipPack
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_TipPack
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTipPack),mTabStruct.idTipPack)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuTipPack()
	String mTab=TAB_TipPack
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleTipPrep(mTab,mStr,mNum)
	Struct TipPrep & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idTipPrep=mNum[0]
	mTab.Name=mStr[1]
	mTab.Description=mStr[2]
	mTab.SecondsEtchGold=mNum[3]
	mTab.SecondsEtchChromium=mNum[4]
End Function

Static Function InitWavesTipPrep(mTab,mStr,mNum)
	Struct TipPrep & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 5
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idTipPrep
	mStr[1]=mTab.Name
	mStr[2]=mTab.Description
	mNum[3]=mTab.SecondsEtchGold
	mNum[4]=mTab.SecondsEtchChromium
End Function

Function SqlHandleTipPrep(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct TipPrep mTabStruct
	InitHandleTipPrep(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of TipPrep
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_TipPrep
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTipPrep),mTabStruct.idTipPrep)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_SecondsEtchGold),mTabStruct.SecondsEtchGold)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_SecondsEtchChromium),mTabStruct.SecondsEtchChromium)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuTipPrep()
	String mTab=TAB_TipPrep
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleTipType(mTab,mStr,mNum)
	Struct TipType & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idTipTypes=mNum[0]
	mTab.Name=mStr[1]
	mTab.Description=mStr[2]
End Function

Static Function InitWavesTipType(mTab,mStr,mNum)
	Struct TipType & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idTipTypes
	mStr[1]=mTab.Name
	mStr[2]=mTab.Description
End Function

Function SqlHandleTipType(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct TipType mTabStruct
	InitHandleTipType(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of TipType
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_TipType
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTipTypes),mTabStruct.idTipTypes)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuTipType()
	String mTab=TAB_TipType
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleTraceData(mTab,mStr,mNum)
	Struct TraceData & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idTraceData=mNum[0]
	mTab.idTraceMeta=mNum[1]
	mTab.FileTimSepFor=mStr[2]
	mTab.FileOriginal=mStr[3]
	mTab.OriginalX=mStr[4]
	mTab.OriginalY=mStr[5]
	mTab.idExpMeta=mNum[6]
End Function

Static Function InitWavesTraceData(mTab,mStr,mNum)
	Struct TraceData & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 7
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idTraceData
	mNum[1]=mTab.idTraceMeta
	mStr[2]=mTab.FileTimSepFor
	mStr[3]=mTab.FileOriginal
	mStr[4]=mTab.OriginalX
	mStr[5]=mTab.OriginalY
	mNum[6]=mTab.idExpMeta
End Function

Function SqlHandleTraceData(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct TraceData mTabStruct
	InitHandleTraceData(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of TraceData
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_TraceData
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceData),mTabStruct.idTraceData)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceMeta),mTabStruct.idTraceMeta)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_FileTimSepFor),mTabStruct.FileTimSepFor)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_FileOriginal),mTabStruct.FileOriginal)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_OriginalX),mTabStruct.OriginalX)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_OriginalY),mTabStruct.OriginalY)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idExpMeta),mTabStruct.idExpMeta)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuTraceData()
	String mTab=TAB_TraceData
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleTraceDataIndex(mTab,mStr,mNum)
	Struct TraceDataIndex & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idParameterValue=mNum[0]
	mTab.StartIndex=mNum[1]
	mTab.EndIndex=mNum[2]
End Function

Static Function InitWavesTraceDataIndex(mTab,mStr,mNum)
	Struct TraceDataIndex & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idParameterValue
	mNum[1]=mTab.StartIndex
	mNum[2]=mTab.EndIndex
End Function

Function SqlHandleTraceDataIndex(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct TraceDataIndex mTabStruct
	InitHandleTraceDataIndex(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of TraceDataIndex
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_TraceDataIndex
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idParameterValue),mTabStruct.idParameterValue)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_StartIndex),mTabStruct.StartIndex)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_EndIndex),mTabStruct.EndIndex)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuTraceDataIndex()
	String mTab=TAB_TraceDataIndex
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleTraceExpLink(mTab,mStr,mNum)
	Struct TraceExpLink & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idTraceExpLink=mNum[0]
	mTab.idTraceMeta=mNum[1]
	mTab.idExpMeta=mNum[2]
End Function

Static Function InitWavesTraceExpLink(mTab,mStr,mNum)
	Struct TraceExpLink & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idTraceExpLink
	mNum[1]=mTab.idTraceMeta
	mNum[2]=mTab.idExpMeta
End Function

Function SqlHandleTraceExpLink(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct TraceExpLink mTabStruct
	InitHandleTraceExpLink(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of TraceExpLink
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_TraceExpLink
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceExpLink),mTabStruct.idTraceExpLink)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceMeta),mTabStruct.idTraceMeta)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idExpMeta),mTabStruct.idExpMeta)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuTraceExpLink()
	String mTab=TAB_TraceExpLink
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleTraceMeta(mTab,mStr,mNum)
	Struct TraceMeta & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idTraceMeta=mNum[0]
	mTab.Description=mStr[1]
	mTab.ApproachVel=mNum[2]
	mTab.RetractVel=mNum[3]
	mTab.TimeStarted=mStr[4]
	mTab.TimeEnded=mStr[5]
	mTab.DwellTowards=mNum[6]
	mTab.DwellAway=mNum[7]
	mTab.SampleRate=mNum[8]
	mTab.FilteredSampleRate=mNum[9]
	mTab.DeflInvols=mNum[10]
	mTab.Temperature=mNum[11]
	mTab.SpringConstant=mNum[12]
	mTab.FirstResRef=mNum[13]
	mTab.ThermalQ=mNum[14]
	mTab.LocationX=mNum[15]
	mTab.LocationY=mNum[16]
	mTab.LocationZ=mNum[17]
	mTab.OffsetX=mNum[18]
	mTab.OffsetY=mNum[19]
	mTab.ForceDist=mNum[20]
	mTab.StartDist=mNum[21]
	mTab.Spot=mNum[22]
	mTab.idTipManifest=mNum[23]
	mTab.idUser=mNum[24]
	mTab.idTraceRating=mNum[25]
	mTab.idSample=mNum[26]
End Function

Static Function InitWavesTraceMeta(mTab,mStr,mNum)
	Struct TraceMeta & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 27
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idTraceMeta
	mStr[1]=mTab.Description
	mNum[2]=mTab.ApproachVel
	mNum[3]=mTab.RetractVel
	mStr[4]=mTab.TimeStarted
	mStr[5]=mTab.TimeEnded
	mNum[6]=mTab.DwellTowards
	mNum[7]=mTab.DwellAway
	mNum[8]=mTab.SampleRate
	mNum[9]=mTab.FilteredSampleRate
	mNum[10]=mTab.DeflInvols
	mNum[11]=mTab.Temperature
	mNum[12]=mTab.SpringConstant
	mNum[13]=mTab.FirstResRef
	mNum[14]=mTab.ThermalQ
	mNum[15]=mTab.LocationX
	mNum[16]=mTab.LocationY
	mNum[17]=mTab.LocationZ
	mNum[18]=mTab.OffsetX
	mNum[19]=mTab.OffsetY
	mNum[20]=mTab.ForceDist
	mNum[21]=mTab.StartDist
	mNum[22]=mTab.Spot
	mNum[23]=mTab.idTipManifest
	mNum[24]=mTab.idUser
	mNum[25]=mTab.idTraceRating
	mNum[26]=mTab.idSample
End Function

Function SqlHandleTraceMeta(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct TraceMeta mTabStruct
	InitHandleTraceMeta(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of TraceMeta
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_TraceMeta
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceMeta),mTabStruct.idTraceMeta)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_ApproachVel),mTabStruct.ApproachVel)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_RetractVel),mTabStruct.RetractVel)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_TimeStarted),mTabStruct.TimeStarted)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_TimeEnded),mTabStruct.TimeEnded)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_DwellTowards),mTabStruct.DwellTowards)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_DwellAway),mTabStruct.DwellAway)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_SampleRate),mTabStruct.SampleRate)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_FilteredSampleRate),mTabStruct.FilteredSampleRate)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_DeflInvols),mTabStruct.DeflInvols)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Temperature),mTabStruct.Temperature)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_SpringConstant),mTabStruct.SpringConstant)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_FirstResRef),mTabStruct.FirstResRef)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_ThermalQ),mTabStruct.ThermalQ)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_LocationX),mTabStruct.LocationX)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_LocationY),mTabStruct.LocationY)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_LocationZ),mTabStruct.LocationZ)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_OffsetX),mTabStruct.OffsetX)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_OffsetY),mTabStruct.OffsetY)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_ForceDist),mTabStruct.ForceDist)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_StartDist),mTabStruct.StartDist)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Spot),mTabStruct.Spot)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTipManifest),mTabStruct.idTipManifest)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idUser),mTabStruct.idUser)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceRating),mTabStruct.idTraceRating)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idSample),mTabStruct.idSample)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuTraceMeta()
	String mTab=TAB_TraceMeta
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleTraceModel(mTab,mStr,mNum)
	Struct TraceModel & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idTraceModel=mNum[0]
	mTab.idTraceMeta=mNum[1]
	mTab.idModel=mNum[2]
End Function

Static Function InitWavesTraceModel(mTab,mStr,mNum)
	Struct TraceModel & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 3
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idTraceModel
	mNum[1]=mTab.idTraceMeta
	mNum[2]=mTab.idModel
End Function

Function SqlHandleTraceModel(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct TraceModel mTabStruct
	InitHandleTraceModel(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of TraceModel
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_TraceModel
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceModel),mTabStruct.idTraceModel)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceMeta),mTabStruct.idTraceMeta)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idModel),mTabStruct.idModel)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuTraceModel()
	String mTab=TAB_TraceModel
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleTraceRating(mTab,mStr,mNum)
	Struct TraceRating & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idTraceRating=mNum[0]
	mTab.RatingValue=mNum[1]
	mTab.Name=mStr[2]
	mTab.Description=mStr[3]
End Function

Static Function InitWavesTraceRating(mTab,mStr,mNum)
	Struct TraceRating & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 4
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idTraceRating
	mNum[1]=mTab.RatingValue
	mStr[2]=mTab.Name
	mStr[3]=mTab.Description
End Function

Function SqlHandleTraceRating(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct TraceRating mTabStruct
	InitHandleTraceRating(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of TraceRating
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_TraceRating
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idTraceRating),mTabStruct.idTraceRating)
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_RatingValue),mTabStruct.RatingValue)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Description),mTabStruct.Description)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuTraceRating()
	String mTab=TAB_TraceRating
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	

Static Function InitHandleUser(mTab,mStr,mNum)
	Struct User & mTab
	Wave/T mStr
	Wave/D mNum
	mTab.idUser=mNum[0]
	mTab.Name=mStr[1]
End Function

Static Function InitWavesUser(mTab,mStr,mNum)
	Struct User & mTab
	Wave/T mStr
	Wave/D mNum
	Variable mSize = 2
	Redimension /N=(mSize) mStr
	Redimension /N=(mSize) mNum
	mNum[0]=mTab.idUser
	mStr[1]=mTab.Name
End Function

Function SqlHandleUser(mStr,mNum,mHandler)
	Wave /T mStr
	Wave /D mNum
	Struct SqlHandleObj & mHandler
	Struct User mTabStruct
	InitHandleUser(mTabStruct,mStr,mNum)
	//POST: mTab is populated with all fields of User
	//Add to the global object pointed to by our setter
	//*Note*: ID should be set by lower methods.
	String tabName = TAB_User
	ModSqlCypherInterface#AddToFIeldWaveNum(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_idUser),mTabStruct.idUser)
	ModSqlCypherInterface#AddToFIeldWaveTxt(ModSqlCypherInterface#GetFieldWaveName(tabName,FIELD_Name),mTabStruct.Name)
	//Call the routine to push this to Sql.
End Function

Static Function /S GetMenuUser()
	String mTab=TAB_User
	return ModSqlCypherInterface#HandleMenu(mTab)
End Function 	


