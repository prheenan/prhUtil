# force floating point division. Can still use integer with //
from __future__ import division
# This file is used for importing the common utilities classes.
import numpy as np
import matplotlib.pyplot as plt
# need to add the utilities class. Want 'home' to be platform independent
from os.path import expanduser
home = expanduser("~")
# get the utilties directory (assume it lives in ~/utilities/python)
# but simple to change
path= home +"/utilities/python"
import sys
sys.path.append(path)
# import the patrick-specific utilities
import GenUtilities  as pGenUtil
import PlotUtilities as pPlotUtil
import CheckpointUtilities as pCheckUtil
# import 
from collections import defaultdict

from SqlDefine import SqlDefine
# pre-defined constant types we can use in the functions.
class HandlerTypes:
    Datetime = "SQL_PTYPE_DATE"
    Name = "SQL_PTYPE_NAME"
    Description = "SQL_PTYPE_DESCR"
    GeneralVarchar = "SQL_PTYPE_GENSTR"
    Int= "SQL_PTYPE_INT"
    Double = "SQL_PTYPE_DOUBLE"
    Foreignkey = "SQL_PTYPE_FK"
    ID = "SQL_PTYPE_ID"

# global definitions for the igor programming...
VARCHAR_DESC_LENGTH = "MAX_DESCRIPTION_LEN"
VARCHAR_NAME_LENGTH = "MAX_NAME_LEN"
DefinedConstants = {VARCHAR_DESC_LENGTH:200,
                    VARCHAR_NAME_LENGTH:100}
SqlUtilInclude = "SqlUtil"
DefineInclude = "::Util:Defines"
GLOBALDEF_NAME = "SqlCypherAutoDefines"
UTILFUNCS_NAME = "SqlCypherUtilFuncs"
DEFFUNC_NAME = "SqlCypherAutoFuncs"
GUI_HANDLE_FUNC = "SqlCypherGuiHandle"
ERROR_MOD_PATH = "::Util:ErrorUtil"
# we need to get the table directory from this file
FuncInclude = "SqlCypherInterface"
IgorTrue = "ModDefine#True()"
IgorFalse = "ModDefine#False()"

IGOR_STRING_TYPE = "String"
IGOR_NUMERIC_TYPE = "Variable"

# general preamble
def igorInclude(toinclude):
    if (not toinclude.startswith(":")):
        # add a colon
        return '''#include ":{:s}"'''.format(toinclude)
    else:
        # dont add a colon
        return '''#include "{:s}"'''.format(toinclude)        

def igorPreambleGen(mName,isIndependent=False):
    # get a general preamble
    if (isIndependent):
        modName = "IndependentModuleName"
    else:
        modName = "ModuleName"
    toRet = ("// Use modern global access method, strict compilation\n"+
            "#pragma rtGlobals=3\n"+
             "#pragma {:s}=Mod{:s}\n"+
             "{:s}\n" + 
             "{:s}\n" + 
             "{:s}\n").\
             format(modName,mName,
                    igorInclude(SqlUtilInclude),
                    igorInclude(DefineInclude),
                    igorInclude(ERROR_MOD_PATH))
    return toRet 

# function to get the string for a default *Variable* parameter
def getDefParamStr(param,defVal,isVar=True,indent=""):
    if (isVar):
        return "{:s}{:s} = ParamIsDefault({:s}) ? {:s} : {:s}\n".\
            format(indent,param,param,defVal,param)
    else:
        toRet  ="{:s}if (ParamIsDefault({:s}))\n".format(indent,param)
        toRet +="{:s}{:s}={:s}\n".format(indent+indent,param,defVal)
        toRet +="{:s}EndIf\n".format(indent)
        return toRet

def igorPreambleFunc(mName,**kwargs):
    # function to return the preamble for the general funciton file
    return igorPreambleUtil(mName,**kwargs) +\
        "{:s}\n".format(igorInclude(FuncInclude)) +\
        "{:s}\n".format(igorInclude(UTILFUNCS_NAME))

def igorPreambleGlobal(mName,**kwargs):
    # funciton to return th preamble for the defines file
    toRet = igorPreambleGen(mName,**kwargs)
    ConstantFmt = "Constant {:s}={:d}\n"
    for key,value in DefinedConstants.items():
        toRet += ConstantFmt.format(key,value)
    return toRet

def igorPreambleHandler(mName,**kwargs):
    # preambler for the handler function
    return igorPreambleFunc(mName,**kwargs) + \
        "{:s}\n".format(igorInclude(DEFFUNC_NAME))

def igorPreambleUtil(mName,**kwargs):
    return igorPreambleGen(mName,**kwargs) +\
        "{:s}\n".format(igorInclude(GLOBALDEF_NAME))

def getStructDecl(typeStr,mName,endStr=""):
    mStr = "\t{:s} {:s}{:s}\n".\
           format(typeStr,mName,endStr)
    return mStr

def igorStr(mStr):
    return '''"{:s}"'''.format(mStr)

def IgorStrConst(name,val):
    fmt = '''StrConstant {:s}="{:s}"\n'''
    return fmt.format(name,val)

class fileContent:
    def __init__(self,defineFileStr,funcFileStr,handleStr,utilStr):
        self.files = {GLOBALDEF_NAME:[defineFileStr,igorPreambleGlobal],
                      DEFFUNC_NAME:[funcFileStr,igorPreambleFunc],
                      GUI_HANDLE_FUNC:[handleStr,igorPreambleHandler],
                      UTILFUNCS_NAME:[utilStr,igorPreambleUtil]}

class IgorConvert:
    # function to get a field name (constant, not a raw string)
    @staticmethod
    def getFieldName(fieldName):
        return "FIELD_{:s}".format(fieldName)
    @staticmethod
    def getTableConstName(tableName):
        # get the tbale name as a constant
        return "TAB_{:s}".format(tableName)
    @staticmethod
    def getTableConst(table):
        return IgorStrConst(IgorConvert.getTableConstName(table),table)
    @staticmethod
    def getTableFieldConst(table,field):
        shortField = field
        mName = IgorConvert.getFieldName(shortField)
        return IgorStrConst(mName,field)
    @staticmethod
    def GetSqlFmtInsertFunc(table,columns,strVal):
        return "Mod{:s}#InsertFormatted({:s},{:s},{:s})".\
            format(SqlUtilInclude,IgorConvert.getTableConstName(table),columns,
                   strVal)
    @staticmethod
    def GetSqlWaveInsertFunc(table,columns,waveVal):
        return "Mod{:s}#InsertComposite({:s},{:s},{:s})".\
            format(SqlUtilInclude,IgorConvert.getTableConstName(table),columns,
                   waveVal)
    @staticmethod
    def isPrimaryKey(mName,fieldNames):
        return mName == fieldNames[0]
    @staticmethod
    def getContentCols(colNames):
        # return all the nonprimary keys. We asssume by convention that these
        # are the first key
        if (len(colNames) > 1):
            return colNames[1:]
        else:
            # empty list.
            return []
    @staticmethod
    def getNameOfColFunc(tabName,includeFile=True):
        if (includeFile):
            return "Mod{:s}#GetColsOf{:s}".format(UTILFUNCS_NAME,tabName)
        else:
            return "GetColsOf{:s}".format(tabName)
    @staticmethod
    def getMakeFromList(waveName,mList,singleFmt="{:s}",flags=""):
        # if nothing there, just declare te wave
        if (len(mList) > 0):
            return "Make /O{:s} {:s} = {{".format(flags,waveName) +\
                ",".join(singleFmt.format(mFile) for mFile in mList) + "}"
        else:
            return "Make /O{:s}/N=0 {:s}".format(flags,waveName)
    @staticmethod
    def getMakeTextFromList(waveName,mList,quote=True):
        # make a text wave from a list
        if (quote):
            singleFmt = '''"{:s}"'''
        else:
            singleFmt = "{:s}"
        return IgorConvert.\
            getMakeFromList(waveName,mList,singleFmt=singleFmt,flags="/T")
    # function to get the name of the default field for columns.
    # if true, we get the ID as well.
    @staticmethod
    def getColNameIncludeID():
        return "IncludeId"
    # function to get all the column names as a wave
    @staticmethod
    def getPrimaryKeyConst(tabName,fieldType,fieldNames):
        return getFieldName(fieldNames[0])
    @staticmethod
    def getColNameWave(tabName,fieldTypes,fieldNames):
        localInclude = IgorConvert.getColNameIncludeID()
        contentCol = IgorConvert.getContentCols(fieldNames)
        # *dont* include the mod where we define this.
        toRet = "Static Function /Wave {:s}([{:s}])\n".\
                format(IgorConvert.getNameOfColFunc(tabName,False),localInclude)
        toRet += "\tVariable {:s}\n".format(localInclude)
        toRet += "\t{:s}".format(getDefParamStr(localInclude,IgorFalse))
        # if the columns are different, then dont include the ID
        # function to get the field names. *dont* include quotes.
        getFieldWave = lambda names : \
        IgorConvert.getMakeTextFromList(tabName,[IgorConvert.getFieldName(tmp) 
                                                 for tmp in names],False)
        allFields = getFieldWave(fieldNames)
        if (set(contentCol) != set(fieldNames)):
            # then there is an ID here
            toRet += "\tif ({:s})\n".format(localInclude)
            toRet += "\t\t{:s}\n".format(allFields)
            toRet += "\telse\n"
            # include the non-ID columns
            toRet += "\t\t{:s}\n".format(getFieldWave(contentCol))
            toRet += "\tendif\n"
            toRet += "\treturn {:s}\n".format(tabName)
        else:
            # no ID to speak of for this table.
            toRet += "\t{:s}\n".format(allFields)
        toRet += "End Function\n"
        return toRet        
    # gets the (igor) type of the field with sql type 'mSqlType' 
    # and name 'mName', with index i in the fields. index 0 is the ID
    @staticmethod 
    def getIgorType(mName,tmpType,i):
        if (tmpType == SqlDefine.TYPE_VARCHAR):
            # then pick a varchar type
            if ("Name" in mName):
                mType = HandlerTypes.Name
            elif ("Description" in mName):
                mType = HandlerTypes.Description                  
            else:
                # normal varchar
                mType = HandlerTypes.GeneralVarchar
        elif(tmpType == SqlDefine.TYPE_INT):
            # check if we are an ID
            if (i==0):
                # then we are an ID!
                mType = HandlerTypes.ID
            elif ("id" in mName):
                mType = HandlerTypes.Foreignkey
            else:
                # just a normal int
                mType = HandlerTypes.Int
        elif(tmpType == SqlDefine.TYPE_DATETIME):
            # easy peasy
            mType = HandlerTypes.Datetime
        elif (tmpType == SqlDefine.TYPE_DOUBLE):
            mType = HandlerTypes.Double
        else:
            print("couldn't identify type " + tmpType)
            exit(1)
        return mType
    @staticmethod 
    def getSqlTypes(tabName,fieldNames,fieldTypes):
        nTypes = len(fieldNames)
        mArr = np.array(nTypes)
        # we asssume:
        # (1) first index is primary key
        # (2) anything after that with 'id' in the name is a foreign key
        # (3) any varchar with name is a name
        # (4) any varchar with description is a desciption
        mTypes = np.zeros(nTypes,dtype=np.object)
        for i,(tmpType,mName) in enumerate(zip(fieldTypes,fieldNames)):
            mTypes[i] = IgorConvert.getIgorType(mName,tmpType,i)
        return mTypes
    @staticmethod 
    def getColTypeFunc(tabName,fieldTypes,fieldNames):
        return ""
    @staticmethod
    # function to get the names *and* types of the columns
    def getColNameWaveFunc(tabName,fieldTypes,fieldNames):
        toRet = IgorConvert.getColNameWave(tabName,fieldTypes,
                                           fieldNames) + "\n"
        toRet +=IgorConvert.getColTypeFunc(tabName,fieldTypes,
                                           fieldNames)
        return toRet
        # function to get every table name
    @staticmethod
    def getAllTables(tableDict):
        tables = sorted(tableDict.keys())
        toRet = "Static Function /Wave getAllTables()\n"
        localTabName = "AllSqlTables"
        tabConst = [IgorConvert.getTableConstName(tab) for tab in tables]
        # false: dont add quotes, since we are using variables
        mList = IgorConvert.getMakeTextFromList(localTabName,tabConst,False)
        toRet += "\t{:s}\n".format(mList)
        toRet += "\treturn {:s}\n".format(localTabName)
        toRet += "End Function\n"
        return toRet
    # function to insert into the table by waves.    
    @staticmethod
    def getInsertFunctionByWaves(tabName,fieldTypes,fieldNames):
        contentFields = IgorConvert.getContentCols(fieldNames)
        paramNames = [name for name in contentFields]
        waveName = lambda x: "{:s}".format(x)
        # get the function name and wave parameters...
        toRet = "Static Function Insert{:s}({:s})\n".\
                format(tabName,",".join(paramNames))
        # create all the incoming wave parameters
        for mType,mName in zip(fieldTypes,fieldNames):
            if (IgorConvert.isPrimaryKey(mName,fieldNames)):
                continue
            flags = ""
            if (mType == SqlDefine.TYPE_DATETIME or 
                mType == SqlDefine.TYPE_VARCHAR):
                flags += "/T"
            elif (mType == SqlDefine.TYPE_DOUBLE):
                flags += "/D"
            toRet += "\tWave {:s} {:s}\n".format(flags,mName)
        # POST: all parameters are declared.
        # make the waveholding all of the wave names
        localWaveName = "mWave"
        localColName = "mCols"
        # make the thing to hold the columns
        toRet += "\tWave /T {:s}= ".format(localColName) +\
                 IgorConvert.getNameOfColFunc(tabName) + "()\n"
        # make the thing to hold the wave names
        toRet += ("\tMake /O/T {:s} = {{ ".format(localWaveName) + \
                  ",".join("NameOfWave({:s})".format(col) 
                           for col in paramNames) + "} \n")
        toRet += "\treturn " + IgorConvert.GetSqlWaveInsertFunc(tabName,
                                                                localColName,
                                                                localWaveName)
        toRet += "\nEnd Function\n"
        return toRet
    # method to create an insert function (simple string format) for a table,
    # given its field names etc.
    @staticmethod
    def GetInsertFunctionStrFormatted(tabName,fieldTypes,fieldNames):
        # function to auto-generate the fields needed for inserting into 
        # the given table
        localTab = "mTab"
        localFmtStr = "fmtStr"
        localString = "final"
        localCols = "mCols"
        # start a new function, given an input table
        toRet = "Static Function InsertFmt{:s}({:s})\n".format(tabName,localTab)
        # locally defined struct
        toRet += "\tStruct {:s} & {:s}\n".format(tabName,localTab)
        fmtList = []
        valStr = ""
        # find the columns we need to push for an insert (*not* the ID, assumed
        # auto-increment
        contentCols = IgorConvert.getContentCols(fieldNames)
        # get the short names of the fields
        mCols = ",".join( ['''"{:s}"'''.format(name) for name in contentCols])
        for mType,mName in zip(fieldTypes,fieldNames):
            endStr =""
            if (IgorConvert.isPrimaryKey(mName,fieldNames)):
                # primary keys
                continue
            # POST: not a primary key
            if (mType == SqlDefine.TYPE_VARCHAR or 
                mType == SqlDefine.TYPE_DATETIME):
                endStr = "'%s'"
            elif (mType == SqlDefine.TYPE_INT):
                endStr = "%d"
            else:
                endStr = "%.15g"
            # post: endStr 
            fmtList.append(endStr)
        # format the string like "<fmt>"
        fmtStr = '''"''' + ",".join(fmtList) + '''"'''
        # the values are stored in th epass-by-eference struct
        mVals = ["{:s}.{:s}".format(localTab,tmpName) 
                 for tmpName in contentCols]
        # get th estring for the values
        valStr = ",".join( mStr for mStr in mVals ) 
        # declar a local string for the formatting
        toRet += "\tString {:s} = {:s}\n".format(localFmtStr,fmtStr)
        # delcare a local string for the value
        toRet += "\tString {:s}\n".format(localString)
        # Make a wave for the columns
        toRet += "\tWave /T {:s} = {:s}()\n".\
                 format(localCols,IgorConvert.getNameOfColFunc(tabName))
        # print the values using the formatting string
        toRet += "\tsprintf {:s},{:s},{:s}\n".\
                 format(localString,localFmtStr,valStr)
        # get the name of the actual function used
        toRet += "\treturn "+IgorConvert.GetSqlFmtInsertFunc(tabName,localCols,
                                                             localString) +"\n"
        # closing statement
        toRet += "End Function\n"
        return toRet 
    @staticmethod
    def getStrLen(mName):
        if ("Description" in mName):
            endStr= "[{:s}]".format(VARCHAR_DESC_LENGTH)
        else:
            endStr="[{:s}]".format(VARCHAR_NAME_LENGTH) 
        return endStr
    @staticmethod
    def getInsertFuncs(tabName,fieldTypes,fieldNames):
        formatInsert = IgorConvert.GetInsertFunctionStrFormatted(tabName,
                                                                 fieldTypes,
                                                                 fieldNames)
        waveInsert =  IgorConvert.getInsertFunctionByWaves(tabName,
                                                           fieldTypes,
                                                           fieldNames)
        return formatInsert + "\n" + waveInsert + "\n"
    # get a struct for a single table
    @staticmethod
    def tableStructGen(name,fieldTypes,fieldNames,
                       onInt,onVarCharOrDateTime,
                       onDouble):
        mStr = "Structure {:s}\n".format(name)
        for mType,mName in zip(fieldTypes,fieldNames):
            if (mType == SqlDefine.TYPE_INT):
                toAdd = onInt(mName)
            elif (mType == SqlDefine.TYPE_VARCHAR or
                  mType == SqlDefine.TYPE_DATETIME):
                toAdd = onVarCharOrDateTime(mName)
            elif (mType == SqlDefine.TYPE_DOUBLE):
                toAdd = onDouble(mName)
            else:
                raise ValueError("An unexpected SQL type {:s} was found".\
                                 format(mType))
            mStr += toAdd
        # POST: all fields made, add structure ending
        mStr += "EndStructure\n"
        return mStr
    # get an id from a table name
    @staticmethod
    def getTableId(tabName):
        return "id" + tabName
    @staticmethod
    def getAllTableIds(tabDict):
        mTables = sorted(tabDict.keys())
        idNames = [ IgorConvert.getTableId(tab) for tab in mTables]
        return mTables,idNames
    # get the name of the table structure
    @staticmethod
    def getTableStructName():
        return "SqlIdTable"
    # get a struct for all the ids
    # get the 
    @staticmethod
    def idTable(tabDict):
        mTables,idNames = IgorConvert.getAllTableIds(tabDict)
        types = [SqlDefine.TYPE_INT for tab in mTables]
        onAll = lambda x: getStructDecl("uint32",x)
        # use the same declaration for everything (should probably just
        # use defaults for the others XXX TODO? )
        mName = IgorConvert.getTableStructName()
        mStr = IgorConvert.tableStructGen(mName,types,idNames,onAll,onAll,onAll)
        return mStr
    @staticmethod
    def getTypeByTable(tableDict):
        mTables,_ = IgorConvert.getAllTableIds(tableDict)
        tabName = "mTab"
        toRet = "Static Function /Wave GetTypesByTable({:s})\n".\
                format(tabName)
        toRet += "\tString {:s}\n".format(tabName)
        mSwitch = IgorConvert.getTableSwitchStr(tabName,mTables)
        switchFmt = []
        localToRet = "toRetColType"
        for tab in mTables:
            fieldNames,fieldTypes = SqlDefine.getNameType(tableDict[tab])
            mSqlTypeList = IgorConvert.getSqlTypes(tabName,fieldNames,
                                                   fieldTypes)
            mList = IgorConvert.getMakeFromList(localToRet,mSqlTypeList)
            switchFmt.append( "{:s}".format(mList))
        finalSwitch = mSwitch.format(*switchFmt)
        toRet += finalSwitch
        toRet += "\treturn {:s}\n".format(localToRet)
        toRet += "End Function\n"
        return toRet
    @staticmethod
    def getStructPutGetId():
        localPath = "mPath"
        localStruct = "mStruct"
        mStructName = IgorConvert.getTableStructName()
        defStructFmt = "ModDefine#StructFmt()"
        declarations = "\tStruct {:s} & {:s}\n".format(mStructName,localStruct)
        declarations += "\tString {:s}\n".format(localPath)
        mStr = "Static Function SetIdTable({:s},{:s})\n".\
               format(localStruct,localPath)
        mStr += declarations
        mStr += ("\tif (!WaveExists(${:s}))\n"+
                 "\t\tMake /O/N=(0) $({:s})\n"+
                 "\tEndIf\n").format(localPath,localPath)
        mStr += "\t// POST: wave exists\n"
        mStr += "\tStructPut /B=({:s})  {:s}, $({:s})\n".\
                format(defStructFmt,localStruct,localPath)
        mStr += "End Function\n\n"
        # add in the getter
        mStr += "Static Function GetIdTable({:s},{:s})\n".\
                format(localStruct,localPath)
        mStr += declarations
        mStr += "\tStructGet /B=({:s}) {:s},$({:s})\n".\
                format(defStructFmt,localStruct,localPath)
        mStr += "End Function\n"
        return mStr
    @staticmethod
    def getTableSwitchStr(localTabName,mTables):
        mSwitch =  "\tstrswitch({:s})\n".format(localTabName)
        for mTab in mTables:
            mTabName = IgorConvert.getTableConstName(mTab)
            mSwitch += "\t\tcase {:s}:\n".format(mTabName)
            mSwitch += "\t\t\t{:s}\n" # left this way on purpose, for set/get
            mSwitch += "\t\t\tbreak\n"
        defStr = "\t\t\tString mErr\n"
        defStr += "\t\t\tsprintf mErr, \"No table found for %s\\r\",{:s}\n".\
                  format(localTabName)
        defStr += "\t\t\tModErrorUtil#DevelopmentError(description=mErr)\n"
        mSwitch += "\t\tdefault:\n"
        mSwitch += "{:s}".format(defStr)
        mSwitch += "\tEndSwitch\n"
        return mSwitch
    # function to return all the column strings, based on the table ID.
    @staticmethod
    def getColByTableID(tableDict):
        localTabName = "mTab"
        mTables,_ = IgorConvert.getAllTableIds(tableDict)
        mSwitch = IgorConvert.getTableSwitchStr(localTabName,mTables)
        toRet = "Static Function /Wave GetColByTable({:s})\n".\
                format(localTabName)
        toRet += "\tString {:s}\n".format(localTabName)
        switchFmt = []
        mRet = "toRetColTab"
        for tmpTable in mTables:
            tableFieldsDict = tableDict[tmpTable]
            # get all of ou field names
            names,_ = SqlDefine.getNameType(tableFieldsDict)
            mList = [IgorConvert.getFieldName(f) for f in names]
            # False: dont add quotes
            switchFmt.append(IgorConvert.getMakeTextFromList(mRet,mList,False))
        # POST: switchFmt is done
        finalSwitch = mSwitch.format(*switchFmt)
        toRet += finalSwitch
        toRet += "\treturn {:s}\n".format(mRet)
        toRet += "End Function\n"
        return toRet
    @staticmethod
    def getTableIdSetAndGetById(tableDict):
        localTab = "mTab"
        localStruct = "mStruct"
        localSetVal = "mId"
        toRet = "Static Function GetId({:s},{:s})\n".\
                format(localStruct,localTab)
        mStructName = IgorConvert.getTableStructName()
        # save the declarations for the getter and the setter.
        declarations = "\tStruct {:s} & {:s}\n".\
                       format(mStructName,localStruct)
        declarations += "\tString {:s}\n".format(localTab)
        mTables,ids = IgorConvert.getAllTableIds(tableDict)
        toRet += declarations
        # do the switch separately, so we can use for both get and set
        mSwitch= IgorConvert.getTableSwitchStr(localTab,mTables)
        # POST: switch is set up for whatever we want.
        # for the getter, fill the string in with "return" and the field
        getSwitch = mSwitch.format(*["return {:s}.{:s}".format(localStruct,mId)\
                                     for mId in ids])
        # for the setter, fill in the strings with *setting* the field
        setSwitch = mSwitch.format(*["{:s}.{:s} = {:s}".\
                                     format(localStruct,mId,localSetVal)
                                     for mId in ids])
        # continue adding the getter.
        toRet += getSwitch
        toRet += "End Function\n\n"
        # start on the setter
        toRet += "Static Function SetId({:s},{:s},{:s})\n".\
                 format(localStruct,localTab,localSetVal)
        toRet += declarations
        toRet += "\tVariable {:s}\n".format(localSetVal)
        toRet += setSwitch
        toRet += "End Function\n"
        return toRet
    @staticmethod
    def foreignKeyToTableName(fk):
        # first two digits are 'id'
        return fk[2:]
    @staticmethod
    def getTableDependencies(tabDict):
        localTab = "mTab"
        toRet = "Static Function /Wave GetDependencies({:s})\n".format(localTab)
        mTables,ids = IgorConvert.getAllTableIds(tabDict)
        mSwitch = IgorConvert.getTableSwitchStr(localTab,mTables)
        switchFmt = []
        toRet += "\tString {:s}\n".format(localTab)
        mRet = "toRetTabDep"
        for tab in mTables:
            tableField = tabDict[tab]
            names,fields = SqlDefine.getNameType(tableField)
            sqlTypes = IgorConvert.getSqlTypes(tab,names,fields)
            mList = []
            for fieldName,fieldType in zip(names,sqlTypes):
                if (fieldType == HandlerTypes.Foreignkey):
                    mKey = IgorConvert.foreignKeyToTableName(fieldName)
                    # make sure we are consistent

                    assert mKey in mTables
                    # POST: table exists
                    mList.append(IgorConvert.getTableConstName(mKey))
            # POST: mList is populated with 0 or more elements.
            # create a wave for this. False: don't add quoates
            nEle = len(mList)
            myMake = IgorConvert.getMakeTextFromList(mRet,mList,False)
            switchFmt.append(myMake)
        # format all the items we have made
        formatted = mSwitch.format(*switchFmt)
        # return the relevant wavt
        toRet += formatted
        toRet += "\tReturn {:s}\n".format(mRet)
        toRet += "End Function\n"
        return toRet
    @staticmethod
    def getDependenciesOnTable(tabDict):
        localTab = "mTab"
        toRet = "Static Function /Wave GetWhatDependsOnTable({:s})\n".\
                format(localTab)
        toRet += "\tString {:s}\n".format(localTab)
        mTables,ids = IgorConvert.getAllTableIds(tabDict)
        mSwitch = IgorConvert.getTableSwitchStr(localTab,mTables)
        mDependencies = defaultdict(list)
        for mTab in mTables:
            # get the types
            tableField  = tabDict[mTab]
            names,fields = SqlDefine.getNameType(tableField)
            sqlTypes = IgorConvert.getSqlTypes(mTab,names,fields)
            mList = []
            for name,mType in zip(names,sqlTypes):
                if (mType == HandlerTypes.Foreignkey):
                    # them 'mTab' references whatever table is here
                    sourceTable = IgorConvert.foreignKeyToTableName(name)
                    mDependencies[sourceTable].append(mTab)
        # POST: mDependencies[<name>] has all of the tables depending on 
        # <name>. 
        finalList = []
        # which tables (keys) have dependencies?
        keys = sorted(mDependencies.keys())
        localRet = "toRetDependencies"
        for mTab in mTables:
            # get the (possibly empty) list of dependencies
            mList = sorted(mDependencies[mTab]) if mTab in keys else []
            # get the contsants associated with this name
            mTabConstList = [IgorConvert.getTableConstName(t) for t in mList]
            # convert to a make text. False: dont add quotes
            mStr = IgorConvert.getMakeTextFromList(localRet,mTabConstList,False)
            finalList.append(mStr)
        # post: fill in mSwitch
        toRet += mSwitch.format(*finalList)
        toRet += "\treturn {:s}\n".format(localRet)
        toRet += "End Function\n"
        return toRet
    @staticmethod
    def getTableIdMethods(tabDict):
        # get the struct declaration
        mStr = IgorConvert.idTable(tabDict) + "\n"
        # set and get methods ('freeze drying')
        mStr += IgorConvert.getStructPutGetId() + "\n"
        # set and get by table.
        mStr += IgorConvert.getTableIdSetAndGetById(tabDict) + "\n"
        # get each tables dependencies, in terms of foreign keys
        mStr += IgorConvert.getTableDependencies(tabDict) + "\n"
        # get the columns based on the table
        mStr += IgorConvert.getColByTableID(tabDict) + "\n"
        # get the types based on the table
        mStr += IgorConvert.getTypeByTable(tabDict) + "\n"
        # get what depends on this table
        mStr += IgorConvert.getDependenciesOnTable(tabDict) + "\n"
        return mStr
    # method to turn a table from Mysql into an igor struct
    @staticmethod
    def getTableStruct(name,fieldTypes,fieldNames):
        onInt = lambda x: getStructDecl("uint32",x)
        onDouble = lambda x: getStructDecl("double",x)
        getLen = lambda x: VARCHAR_DESC_LENGTH if ("Description" in name) else\
                 VARCHAR_NAME_LENGTH  
        onVarCharOrDateTime = lambda x : \
                    getStructDecl("char",x,IgorConvert.getStrLen(x))
        mStr =  IgorConvert.tableStructGen(name,fieldTypes,fieldNames,
                                           onInt,onVarCharOrDateTime,
                                           onDouble)
        return mStr
    # a structure composed of string references to waves (serializable)
    @staticmethod
    def getStructStringName(name):
        return name + "WaveStr"
    # a structure composed of wave references (*not* serializable)
    @staticmethod
    def getStructWaveName(name):
        return name +"WaveRef"
    # method to make a field for each string
    @staticmethod
    def getTableStrStruct(name,fieldTypes,fieldNames):
        forAll = lambda x: getStructDecl("char",x,
                                         "[{:s}]".format(VARCHAR_NAME_LENGTH))
        mStructName =  IgorConvert.getStructStringName(name)
        mStr =  IgorConvert.tableStructGen(mStructName,fieldTypes,fieldNames,
                                           forAll,forAll,forAll)
        return mStr
    # make a wave field for each field
    @staticmethod
    def GetTableWaveStruct(name,fieldTypes,fieldNames):
        onNum = lambda x: getStructDecl("Wave /D",x)
        onStr = lambda x: getStructDecl("Wave /T",x)
        mStructName = IgorConvert.getStructWaveName(name)
        mStr = IgorConvert.tableStructGen(mStructName,fieldTypes,fieldNames,
                                          onNum,onStr,onNum)
        return mStr
    @staticmethod
    def getStructs(name,fieldtypes,fieldNames):
        mWaveStr = IgorConvert.GetTableWaveStruct(name,fieldtypes,fieldNames)
        toRet= "{:s}\n{:s}\n{:s}\n".\
               format(IgorConvert.getTableStruct(name,fieldtypes,fieldNames),
                      IgorConvert.getTableStrStruct(name,fieldtypes,fieldNames),
                      mWaveStr)
        return toRet
    @staticmethod
    def getInitWaveStructFuncName(tab,arg):
        mStructName = IgorConvert.getStructStringName(tab)
        return "Init{:s}({:s})".format(mStructName,arg)
    #funciton to initialize the simple field name struct
    @staticmethod
    def getInitSimpleStructFuncName(tab,tabArgName,paramNames):
        mParams = ",".join(paramNames)
        return "Init{:s}Struct({:s},{:s})".format(tab,tabArgName,
                                                  mParams)
    @staticmethod
    def initSimpleStruct(tab,fieldtypes,fieldnames):
        mLocalTab = "mTab"
        mFunc = IgorConvert.getInitSimpleStructFuncName(tab,mLocalTab,
                                                        fieldnames)
        toRet = "Static Function {:s}\n".format(mFunc)
        # add in the local struct
        toRet += "Struct {:s} & {:s}\n".format(tab,mLocalTab)
        fields = ""
        for name,fieldType in zip(fieldnames,fieldtypes):
            if (fieldType == SqlDefine.TYPE_INT or
                fieldType == SqlDefine.TYPE_DOUBLE):
                mDecl = IGOR_NUMERIC_TYPE
            else:
                mDecl = IGOR_STRING_TYPE
            toRet += "\t{:s} {:s}\n".format(mDecl,name)
            fields += "\t{:s}.{:s} = {:s}\n".format(mLocalTab,name,name)
        # POST: everything is initialized
        # set up all the fields
        toRet += fields+"\n"
        toRet += "End Function\n"
        return toRet
    @staticmethod
    def initWaveStructFunc(tabName,fieldtypes,fieldnames):
        mStructName = IgorConvert.getStructStringName(tabName)
        localVar = "mStruct"
        localUseGlobal = "useGlobal"
        mArgs = "{:s},[{:s}]".format(localVar,localUseGlobal)
        mFunc = IgorConvert.getInitWaveStructFuncName(tabName,mArgs)
        toRet = "Static Function {:s}\n".format(mFunc)
        toRet += "\tStruct {:s} & {:s}\n".format(mStructName,localVar)
        toRet += "\tVariable {:s}\n".format(localUseGlobal)
        localTabName = "mTab"
        toRet += "\tString {:s} = {:s}\n".\
                 format(localTabName,IgorConvert.getTableConstName(tabName))
        toRet += "\t{:s}".format(getDefParamStr(localUseGlobal,IgorTrue))
        # loop through the local or global directories.
        toRet += "\tif({:s})\n".format(localUseGlobal)
        for fieldName in fieldnames:
            # get the constant definition
            constFieldName = IgorConvert.getFieldName(fieldName)
            toRet += "\t\t{:s}.{:s} =Mod{:s}#GetFieldWaveName({:s},{:s})\n".\
                     format(localVar,fieldName,FuncInclude,localTabName,
                            constFieldName)
        toRet += "\telse\n"
        for fieldName in fieldnames:
            # get the constant definition
            constFieldName = IgorConvert.getFieldName(fieldName)
            toRet += "\t\t{:s}.{:s} ={:s}\n".\
                     format(localVar,fieldName,constFieldName)
        toRet += "\tEndif\n"
        toRet += "End Function\n\n"
        # XXX change name, also create initsimple and initbywave (generic)
        simpleInit = IgorConvert.initSimpleStruct(tabName,fieldtypes,fieldnames)
        return toRet + simpleInit
    # function to get the constants for each field name...
    @staticmethod
    def getFieldConstants(allFields):
        toRet = ""
        # get the set of all the fields
        uniqueFields = list(set(allFields))
        # sort by the lower case
        uniqueFields.sort(key=lambda x: x.lower())
        for field in uniqueFields:
            # add this field in, so we dont deal in raw strings.
            toRet += IgorStrConst(IgorConvert.getFieldName(field),field)
        return toRet
    # methods to initialize the structs
    @staticmethod
    def InitStructs(name,fieldtypes,fieldnames):
        return IgorConvert.initWaveStructFunc(name,fieldtypes,fieldnames)
    @staticmethod
    def getSimpleSelectName(tabName):
        return "SimpleSelect{:s}".format(tabName)
    # simple select statement; select *everything*
    @staticmethod
    def getSimpleSelect(tabName,fieldTypes,fieldnames):
        inWave = tabName
        localSave = "saveGlobal"
        localStruct = "mTab"
        localWhereStmt = "appendStmt"
        localInit = "initWaveStr"
        mStructName = IgorConvert.getStructStringName(tabName)
        mFuncName = IgorConvert.getSimpleSelectName(tabName)
        toRet = "Static Function {:s}({:s},[{:s},{:s},{:s}])\n".\
                    format(mFuncName,localStruct,localSave,localWhereStmt,
                           localInit)
        toRet += "\t// Note: if saveInGlobalTab is true, saves to SqlDir\n"
        toRet += "\t// otherwise waves to CWD (current working directory)\n"
        toRet += "\tStruct {:s} & {:s} \n".format(mStructName,localStruct)
        toRet += "\tVariable {:s},{:s}\n".format(localSave,localInit)
        toRet += "\tString {:s}\n".format(localWhereStmt)
        toRet += "\t{:s}".format(getDefParamStr(localSave,IgorFalse))
        mWhere = getDefParamStr(localWhereStmt,igorStr(""),isVar=False,
                                indent="\t")
        toRet += "{:s}".format(mWhere)
        toRet += "\t{:s}".format(getDefParamStr(localInit,IgorTrue))
        # initialize the structure, if we need to
        origDir = "originalDir"
        tabConst = IgorConvert.getTableConstName(tabName)
        toRet += "\tif({:s})\n".format(localInit)
        toRet += "\t\t//Init the wave structure for holding the names.\n"
        toRet += "\t\t{:s}\n".\
                 format(IgorConvert.getInitWaveStructFuncName(tabName,
                                                              localStruct))
        toRet += "\tEndIf\n"
        # POST: the struct has been created. Get all of the columns to read 
        localCols = "mCols"
        # get all the columns, including the ID
        mColStr = "{:s}({:s}={:s})".\
                  format(IgorConvert.getNameOfColFunc(tabName),
                         IgorConvert.getColNameIncludeID(),IgorTrue)
        toRet += "\t// Get all of the columns, *including* the ID\n"
        toRet += "\tWave /T {:s} = {:s}\n".format(localCols,mColStr)
        # create the 'input' wave, based on this structure.
        mList = ["{:s}.{:s}".format(localStruct,name)
                 for name in fieldnames]
        localInput = "mFields"
        # false : dont add quotes.
        toRet += "\t//Add all the fields we will select into\n"
        toRet += "\t{:s}\n".\
                 format(IgorConvert.getMakeTextFromList(localInput,mList,False))
        toRet += "\tMod{:s}#SelectIntoWaves({:s},{:s},{:s},{:s},{:s})\n".\
                 format(FuncInclude,tabConst,localCols,localInput,localSave,
                        localWhereStmt)
        toRet += "End Function\n"
        return toRet 
    # method to add wave selectors (just a wrapper/convenience function)
    @staticmethod
    def getWaveSelect(tabName,fieldTypes,fieldnames):
        localTab = "mTab"
        localTextTab = "mTextTab"
        toRet = "Static Function WaveSelect{:s}({:s})\n".\
                 format(tabName,localTab)
        inputType = IgorConvert.getStructWaveName(tabName)
        textStructType = IgorConvert.getStructStringName(tabName)
        toRet += "\tStruct {:s} & {:s}\n".format(inputType,localTab)
        toRet += "\tStruct {:s} {:s}\n".format(textStructType,localTextTab)
        convertFunc = IgorConvert.\
                      getWaveStructToTextStructFuncName(tabName,localTab,
                                                        localTextTab)
        toRet += "\t{:s}\n".format(convertFunc)
        mFunc = IgorConvert.getSimpleSelectName(tabName)
        toRet += "\t{:s}({:s})\n".format(mFunc,localTextTab)
        toRet += "End Function\n"
        return toRet
    # method to add select statements
    @staticmethod
    def getSelectFuncs(tabName,fieldtypes,fieldnames):
        simpleSel = IgorConvert.getSimpleSelect(tabName,fieldtypes,fieldnames)
        waveSel = IgorConvert.getWaveSelect(tabName,fieldtypes,fieldnames)
        toRet = "{:s}\n{:s}\n".format(simpleSel,waveSel)
        return toRet
    @staticmethod
    def getTextStructToWaveStructFuncName(tabName,textStruct,waveStruct):
        return "{:s}ToWaveStruct({:s},{:s})".\
            format(tabName,textStruct,waveStruct)
    @staticmethod
    def getWaveStructToTextStructFuncName(tabName,textStruct,waveStruct):
        return "{:s}ToTextStruct({:s},{:s})".\
            format(tabName,textStruct,waveStruct)
    @staticmethod
    def GenConversion(tabName,fieldTypes,fieldNames,mFuncName,inType,inName,
                      outType,outName,mFunc,
                      fieldFunc = lambda name,mtype : name):
        toRet = "Static Function {:s}\n".format(mFuncName)
        toRet += "\tStruct {:s} & {:}\n".format(inType,inName)
        toRet += "\tStruct {:s} & {:}\n".format(outType,outName)
        # convert each field
        for mFieldName,mType in zip(fieldNames,fieldTypes):
            # copy the data in the wave struct to the text struct
            inField = "{:s}.{:s}".format(inName,mFieldName)
            outField  = "{:s}.{:s}".format(outName,mFieldName)
            # add each text field
            mFieldDecl = fieldFunc(outField,mType)
            toRet += "\t{:s}=Mod{:s}#{:s}({:s})\n".\
                     format(mFieldDecl,FuncInclude,mFunc,inField)
        toRet += "End Function\n"
        return toRet
    @staticmethod
    def getWaveToTextStruct(tabName,fieldTypes,fieldNames):
        inType = IgorConvert.getStructWaveName(tabName)
        outType = IgorConvert.getStructStringName(tabName)
        inName = "refWave"
        outName = "strWave"
        mFuncName = IgorConvert.getWaveStructToTextStructFuncName(tabName,
                                                                  inName,
                                                                  outName)
        mFunc = "GetPathFromWave"
        return IgorConvert.GenConversion(tabName,fieldTypes,fieldNames,
                                         mFuncName,inType,inName,outType,
                                         outName,mFunc)
    @staticmethod
    def getTextToWaveStruct(tabName,fieldTypes,fieldNames):
        inType = IgorConvert.getStructStringName(tabName)
        inName = "strWave"
        outType = IgorConvert.getStructWaveName(tabName)
        outName = "refWave"
        mFuncName = IgorConvert.getTextStructToWaveStructFuncName(tabName,
                                                                  inName,
                                                                  outName)
        mFunc = "SqlWaveRef"
        strTypes = [SqlDefine.TYPE_DATETIME,SqlDefine.TYPE_VARCHAR]
        strTxtWave = "Wave /T "
        strNumWave = "Wave /D "
        fieldFunc = lambda name,mType: strTxtWave + name \
                                   if mType in strTypes else strNumWave + name
        return IgorConvert.GenConversion(tabName,fieldTypes,fieldNames,
                                         mFuncName,inType,inName,outType,
                                         outName,mFunc,fieldFunc)
    @staticmethod
    def getConverts(tabName,mTypes,mNames):
        waveToText = IgorConvert.getWaveToTextStruct(tabName,mTypes,mNames)
        textToWave = IgorConvert.getTextToWaveStruct(tabName,mTypes,mNames)
        toRet = "{:s}\n{:s}\n".\
                format(waveToText,textToWave)
        return toRet
    # code for generating the GUI handlers below.
    @staticmethod
    def getInitByWaveFuncName(tabName,structName,waveStr,waveNum):
        return "InitHandle{:s}({:s},{:s},{:s})".\
            format(tabName,structName,waveStr,waveNum)
    # function to initialize a struct by two waves (numeric and string)
    # and to initialize the waves by a string
    @staticmethod
    def getInitByWave(tabName,mTypes,mNames):
        localStrWave = "mStr"
        localNumWave = "mNum"
        localStruct = "mTab"
        toRet = "Static Function {:s}\n".\
                format(IgorConvert.getInitByWaveFuncName(tabName,localStruct,
                                                         localStrWave,
                                                         localNumWave))
        declaration = "\tStruct {:s} & {:s}\n".format(tabName,localStruct)+\
                      "\tWave/T {:s}\n".format(localStrWave)+\
                      "\tWave/D {:s}\n".format(localNumWave)
        toRet += declaration
        # Create out structure, using all of the fields we need to
        # call the relevant function.
        # save the structure and wave, since we an re-use this for 
        # converting a struct to a wave
        mStruct = []
        mWave = []
        for i,(fieldName,fieldType) in enumerate(zip(mNames,mTypes)):
            # determine where the data is coming from
            if (fieldType == SqlDefine.TYPE_INT or
                fieldType == SqlDefine.TYPE_DOUBLE):
                tmpSrcWave = localNumWave
            else:
                tmpSrcWave = localStrWave
            mWave.append("{:s}[{:d}]".format(tmpSrcWave,i))
            mStruct.append("{:s}.{:s}".format(localStruct,fieldName))
        toRet += "\n".join("\t{:s}={:s}".format(tmpStruct,tmpWave)
                           for tmpStruct,tmpWave in zip(mStruct,mWave))
        toRet += "\nEnd Function\n\n"
        # next, initialize the waves based on an incoming struct
        toRet += "Static Function InitWaves{:s}({:s},{:s},{:s})\n".\
                 format(tabName,localStruct,localStrWave,localNumWave)
        # add in the common declaration
        toRet += declaration
        localSize = "mSize"
        toRet += "\tVariable {:s} = {:d}\n".format(localSize,len(mTypes))
        toRet += "\tRedimension /N=({:s}) {:s}\n".format(localSize,localStrWave)
        toRet += "\tRedimension /N=({:s}) {:s}\n".format(localSize,localNumWave)
        # add in the assignment to the waves
        # wave = structs
        toRet += "\n".join("\t{:s}={:s}".format(tmpWave,tmpStruct)
                           for tmpStruct,tmpWave in zip(mStruct,mWave))
        toRet += "\nEnd Function\n"
        return toRet
        # set the parameters on the struct
    @staticmethod
    def getSqlHandler(tabName,mTypes,mNames):
        localTab = "mTab" 
        localStruct = "mTabStruct"
        localStrWave = "mStr"
        localNumWave = "mNum"
        localSetter = "mHandler"
        # get the handler function
        mStr = ("Function SqlHandle{:s}({:s},{:s},{:s})\n".\
                format(tabName,localStrWave,localNumWave,localSetter))
        mStr += "\tWave /T {:s}\n".format(localStrWave)
        mStr += "\tWave /D {:s}\n".format(localNumWave)
        mStr += "\tStruct SqlHandleObj & {:s}\n".format(localSetter)
        mStr += "\tStruct {:s} {:s}\n".format(tabName,localStruct)
        mFunc = IgorConvert.getInitByWaveFuncName(tabName,localStruct,
                                                  localStrWave,localNumWave)
        mStr += "\t{:s}\n".format(mFunc)
        # POST: localtab is populated with everything we want. 
        mStr += "\t//POST: {:s} is populated with all fields of {:s}\n".\
                format(localTab,tabName)
        mStr += "\t//Add to the global object pointed to by our setter\n"
        mStr += "\t//*Note*: ID should be set by lower methods.\n"
        localTabName = "tabName"
        mStr += "\tString {:s} = {:s}\n".\
                format(localTabName,IgorConvert.getTableConstName(tabName))
        # loop through, add proper parameters to each field
        for name,mType in zip(mNames,mTypes):
            mFieldName =  IgorConvert.getFieldName(name)
            mNameOfWave = "Mod{:s}#GetFieldWaveName({:s},{:s})".\
                           format(FuncInclude,localTabName,mFieldName)
            # have the name of the wave, append to it, depending on our type
            if (mType == SqlDefine.TYPE_INT or
                mType == SqlDefine.TYPE_DOUBLE):
                mFunc = "AddToFIeldWaveNum"
            else:
                mFunc = "AddToFIeldWaveTxt"
            mStructField = "{:s}.{:s}".format(localStruct,name)
            mStr += "\tMod{:s}#{:s}({:s},{:s})\n".\
                    format(FuncInclude,mFunc,mNameOfWave,mStructField)
        mStr += "\t//Call the routine to push this to Sql.\n"
        mStr += "End Function\n"
        return mStr
    @staticmethod
    def getMenuName(tabName):
        return "GetMenu{:s}".format(tabName)
    # get the menu function
    @staticmethod
    def getTableHandler(tabName):
        localTab = "mTab"
        toRet = "Static Function /S {:s}()\n".\
                format(IgorConvert.getMenuName(tabName))
        toRet += "\tString {:s}={:s}\n".\
                 format(localTab,IgorConvert.getTableConstName(tabName))
        toRet += "\treturn Mod{:s}#HandleMenu({:s})\n".\
                 format(FuncInclude,localTab)
        toRet += "End Function \t"
        return toRet
    # get the table 
    @staticmethod
    def getMenuFunctionByTable(tableDict):
        localTab = "mTab"
        mTables,ids = IgorConvert.getAllTableIds(tableDict)
        mSwitch= IgorConvert.getTableSwitchStr(localTab,mTables)
        toFormat = ["return \"{:s}\"".\
                    format(IgorConvert.getMenuName(tabName)) 
                    for tabName in mTables]
        toRet = "Static Function /S GetMenuByTable({:s})\n".format(localTab)
        toRet += "\tString {:s}\n".format(localTab)
        toRet += mSwitch.format(*toFormat)
        toRet += "End Function\n"
        return toRet
    @staticmethod
    def getHandlers(tabName,mTypes,mNames):
        # general flow:
        # (1) Get Struct From Input Waves (switch on type)
        # (2) Insert into database from struct
        # (3) Insert into global object from struct using tabname, Interface
        # get the wave initializer function
        toRet = "{:s}\n".\
                format(IgorConvert.getInitByWave(tabName,mTypes,mNames))
        toRet += "{:s}\n".\
                 format(IgorConvert.getSqlHandler(tabName,mTypes,mNames))
        toRet += "{:s}\n".\
                 format(IgorConvert.getTableHandler(tabName))   
        return toRet
    @staticmethod
    def getHandleGlobal(tableDict):
        toRet = "{:s}\n".\
                format(IgorConvert.getMenuFunctionByTable(tableDict))
        return toRet

