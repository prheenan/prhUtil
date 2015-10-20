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
import re 

TYPE_STR = 0
TYPE_NUM = 1
TYPE_WAVE = 2
READ_ONLY = -1

# get the preamble for a cypher function
def getFileStr(fileName):
    toRet = ("// Use modern global access method, strict compilation\n"+
             "#pragma rtGlobals=3\n"+
             "#pragma ModuleName=Mod{:s}\n\n".format(fileName))
    return toRet

def GetTypeStr(typeNum):
    if typeNum == TYPE_STR:
        return "String"
    elif typeNum == TYPE_WAVE:
        # assume text wave...
        return "Wave /T"
    elif typeNum == TYPE_NUM:
        return "Variable"
        

def getIgorFunc(name,args,types,body=""):
    mArgs = ",".join(args)
    mTypeStr = ["\t{:s} {:s}".format(GetTypeStr(t),n) 
                for t,n in zip(types,args)]
    toRet = ("Function {:s}({:s})\n".format(name,mArgs) + 
             "\n".join(mTypeStr) + "\n" +
             body + 
             "\nEnd Function")
    return toRet

# get the lines in a file
def getFileLines(inFile):
    mFileLines = []
    with open(inFile) as mFile:
        for line in mFile:
            mFileLines.append(line)
    return mFileLines


def getType(varName):
    mStringList = ["Channel","Compare","Event","Callback"]
    for s in mStringList:
        if (s.lower() in varName.lower()):
            return TYPE_STR
        else:
            return TYPE_NUM

def isReadOnly(name,flags):
    # all channels are acttually writable...
    return ("RO".lower() in flags.lower() and
            "Channel".lower() not in name.lower())

# get the parameter names, descriptions, and flags in their 'native' format
def GetGroupSignature(fileStr):
    paramPattern = ("" + 
                    r'''
                    //  # comment line
                    (\w+) # name of the parameter, 
                    \s* # at least one space
                    (             # #capture possible flags
                    \(            # # literal open paren
                    [\w\s$]+        # single flag
                    (?:\,[\w\s$]+)* #zero or more (non capturing) inner groups
                    \)            # # closing flag
                    )?            # # optional matchig group
                    [\s-]* # at least one space or a minus
                    ([^/]+)      # followed by description (not a \\)
                    ''')
    mParams = []
    mFlags = re.VERBOSE | re.DOTALL
    for(name, flags,description) in re.findall(paramPattern, fileStr,mFlags):
        mParams.append((name,flags,description))
    return mParams

def convertToIgor(mParams):
    final = []
    for name,flags,descr in mParams:
        mType = getType(name)
        readOnly = isReadOnly(name,flags)
        final.append((name,readOnly,mType))
    # sort final by the names (first element
    final.sort(key = lambda x: x[0])
    return final

def getInitBody(initName,allEleNames,writeEleNames,writeEleTypes):
    n = len(allEleNames)
    body = "\tRedimension /N={:d} {:s}\n".format(n,initName)
    for i in range(n):
        # essentially, set all the dimension labels
        body += "\tSetDimLabel 0,{:d}, $\"{:s}\",{:s}\n".\
                format(i,allEleNames[i],initName)
    # next, set alll the values we want
    for name,typeV in zip(writeEleNames,writeEleTypes):
        # have to convert everything to a string
        initRHS = name if typeV == TYPE_STR else "num2str({:s})".format(name)
        body += "\t{:s}[%{:s}] = {:s}\n".format(initName,name,initRHS)
    return body
        

def MakeInitFunction(funcName,params):
    # second element is read only
    writeableElements = [ p for p in params if not p[1]]
    # get the body (essentially just assignment)
    writeableElements[0]
    initWave = "toInit"
    allNames = [p[0] for p in params]
    writeEleNames = [p[0] for p in writeableElements]
    writeEleTypes = [p[2] for p in writeableElements]
    # get the body, where we initialize all the writeable elements
    body = getInitBody(initWave,allNames,writeEleNames,writeEleTypes)
    writeEleNames.insert(0,initWave)
    writeEleTypes.insert(0,TYPE_WAVE)
    mFunc = getIgorFunc(funcName,writeEleNames,writeEleTypes,body=body)
    return mFunc
        
def run(inPath,outPath):
    # loop through the files and generate their igor structs.
    mFiles = ["PIDSLoop.txt","CTFC.txt"]
    for fileIn in mFiles:
        mStr = "".join(getFileLines(inPath + fileIn))
        structName = fileIn[:-4]
        mParams = GetGroupSignature(mStr)
        igorReady = convertToIgor(mParams)
        funcStr = MakeInitFunction("Init" + structName,igorReady)
        # output an igor pro file
        outFile = outPath + structName + ".ipf"
        header = getFileStr(structName)
        with open(outFile,"w+") as mFile:
            mFile.write(header + "\n" + funcStr)

if __name__ == "__main__":
    mFile = "./"
    outFile = "../../CypherRealTime/CypherIoTypes/"
    run(mFile,outFile)
