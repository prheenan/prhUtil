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

import mysql.connector as sqlcon
from IgorConvert import IgorConvert,fileContent
from SqlDefine import SqlDefine


class tableInfo:
    def __init__(self):
        self._data = []
        self._keyName = "fieldname"
        self._keyType = "type"
        self._keyTable= "table"
        self._allFields = []
        pass
    def add(self,mType,mName,mTable):
        self._data.append( {self._keyType: mType,
                            self._keyName : mName,
                            self._keyTable :mTable})
    def generateTableDict(self):
        # first, determine the set of tables
        tableSet = set( [ ele[self._keyTable] for ele in self._data] )
        # make a dictionary for each element belonging to the tables
        toRet = dict()
        for tableName in tableSet:
            toRet[tableName] = []
            for row in self._data:
                if (row[self._keyTable] == tableName):
                    # this row belongs to the table
                    fieldName = row[self._keyName]
                    toRet[tableName].append({self._keyType :row[self._keyType],
                                             self._keyName :fieldName})
                    # add every field at first, set-ify later
                    self._allFields.append(fieldName)
            # POST: looked through all the rows
        self._mDict = toRet
    def getDBString(self,strBetweenTables="\n",
                    funcTableToConst=IgorConvert.getTableConst,
                    funcTableToStruct=IgorConvert.getStructs,
                    funcTableToInsert=IgorConvert.getInsertFuncs,
                    funcColNames=IgorConvert.getColNameWaveFunc,
                    funcFieldConstants=IgorConvert.getFieldConstants,
                    funcInitStructs=IgorConvert.InitStructs,
                    funcAllTables=IgorConvert.getAllTables,
                    funcConversions=IgorConvert.getConverts,
                    funcSelect=IgorConvert.getSelectFuncs,
                    funcHandlers=IgorConvert.getHandlers,
                    funcId=IgorConvert.getTableIdMethods,
                    funcHandleGlobal=IgorConvert.getHandleGlobal):
        # must have called 
        tableDict = self._mDict
        allFields = self._allFields
        structString = ""
        constString = ""
        insertString = ""
        colNameString = ""
        fieldNameString =""
        initStructString = ""
        selectString = ""
        convertString = ""
        # add each element of the tables
        mKeys = sorted(tableDict.keys())
        mTableString = funcAllTables(tableDict)
        fieldNameString += funcFieldConstants(allFields)
        idTableString = funcId(tableDict)
        handlerString = funcHandleGlobal(tableDict)
        for table in mKeys:
            mTableField = tableDict[table]
            # look through each element, corresponding to a separate field.
            namesTmp,typeTmp = SqlDefine.getNameType(mTableField)
            # POST: all elements accounted for... 
            # XXX make more efficient, store this way?
            constString += funcTableToConst(table)
            colNameString += funcColNames(table,typeTmp,namesTmp) + \
                             strBetweenTables
            structString += funcTableToStruct(table,typeTmp,namesTmp) + \
                            strBetweenTables
            insertString += funcTableToInsert(table,typeTmp,namesTmp) + \
                            strBetweenTables
            initStructString += funcInitStructs(table,typeTmp,namesTmp) + \
                                strBetweenTables
            selectString += funcSelect(table,typeTmp,namesTmp) + \
                            strBetweenTables
            convertString += funcConversions(table,typeTmp,namesTmp) + \
                             strBetweenTables
            handlerString += funcHandlers(table,typeTmp,namesTmp) + \
                             strBetweenTables
        globalDef = (
            "// Defined table names\n{:s}\n"+\
            "// Defined table field names\n{:s}\n"+\
            "// All Table function\n{:s}\n"+\
            "// Defined structures\n{:s}\n"+\
            "// Defined id structure\n{:s}\n"
            ).format(constString,fieldNameString,mTableString,structString,
            idTableString)
        globalFunc = (
            "// Defined insert functions\n{:s}\n"+\
            "// Initialization for structures\n{:s}\n"
            "// Conversion functions\n{:s}\n" + \
            "// Select functions\n{:s}\n"
            ).format(insertString,initStructString,
                     convertString,selectString)
        globalHandle = ("//Defined Handlers\n{:s}\n").format(handlerString)
        utilFuncs = ("//Column names and types\n{:s}\n").format(colNameString)
        toRet = fileContent(globalDef,globalFunc,globalHandle,utilFuncs)
        return toRet

class connInf:
    def __init__(self,user="root",pwd="",host="127.0.0.1",database="CypherAFM"):
        self._user = user
        self._pwd = pwd
        self._host = host
        self._database = database
    def connect(self):
        self._cnx = sqlcon.connect(user=self._user,password=self._pwd,
                                   host = self._host,
                                   database = self._database,
                                   raise_on_warnings=True)
        print(self._cnx)
        self._cur = self._cnx.cursor()
    def safeExec(self,mStr):
        try:
            self._cur.execute(mStr)
        except mysql.connector.Error as err:
            print(mStr)
            print("Execution failed: {}".format(err))
            exit(-1)
    def getAllTableInfo(self):
        mStr = ("SELECT DATA_TYPE,COLUMN_NAME,TABLE_NAME FROM "+\
                "INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='{:s}'").\
            format(self._database)
        idxType = 0
        idxName = 1
        idxTable = 2
        self.safeExec(mStr)
        # make a 'tableinfo' struct to save everything as.
        toRet = tableInfo()
        for r in self._cur:
            toRet.add(r[idxType],r[idxName],r[idxTable])
        return toRet
            
    def close(self):
        self._cur.close()
        self._cnx.close()

