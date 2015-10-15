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
# this function reads in the MFP3D.ihf help file, then spits
# out Igor psuedo code to allow code to compile which uses it...

TYPE_STRING = 0
TYPE_WAVE = 1
TYPE_NUMBER = 2

TypeDict = {TYPE_STRING : "String", TYPE_WAVE: "Wave", TYPE_NUMBER : "Variable"}

def argPartOfList(arg,mList):
    argL = arg.lower()
    for k in mList:
        if k.lower() in argL:
            return True
    return False

def isStr(arg):
    mKeys = ["string","name","message","tip","callback","text","function"]
    return argPartOfList(arg,mKeys)

def isNumeric(arg):
    mKeys = ["value","icon","rate","dest","position","onOff","bank",
             "decimation","interpolation","max","offset"]
    return argPartOfList(arg,mKeys)

def getParamType(arg):
    if isStr(arg):
        return TYPE_STRING
    elif "wave" in arg.lower():
        return TYPE_WAVE
    elif isNumeric(arg):
        return TYPE_NUMBER
    else:
        print("Whats a {:s}".format(arg))

def getIgorFunc(name,args):
    mArgs = ",".join(args)
    types = ["\t{:s} {:s}".format(TypeDict[getParamType(a)],a) for a in args]
    toRet = ("Function {:s}({:s})\n".format(name,mArgs) + 
             "\n".join(types) + 
             "\nEnd Function")
    return toRet

def getFileStr(funcs,fileName):
    toRet = ("// Use modern global access method, strict compilation\n"+
             "#pragma rtGlobals=3\n"+
             "#pragma ModuleName=Mod{:s}\n\n".format(fileName)+
             "{:s}\n".format("\n\n".join(funcs)))
    return toRet

def run(inFile,outFilePath):
    mFileLines = []
    with open(inFile) as mFile:
        for line in mFile:
            mFileLines.append(line)
    # have the entire string. Parse...
    mFuncPattern = (r'''
    (td_      # the literal 'td_'
    [^\(]+)    # followed by a bunch of non left parens (rest of name)
    \(        # followed by a left paren (start of args)
    ([^\)]+)   # followed by a bunch of non right parents
    \)       # followed by a right paren
    ''')
    pattern = re.compile(mFuncPattern,re.VERBOSE)
    funcs = []
    args = []
    for line in mFileLines:
        myMatch =pattern.match(line)
        if (myMatch is not None):
            funcs.append(myMatch.group(1))
            args.append(myMatch.group(2))
    # have all of the args and funcs
    # sort them alphabetically by function 
    sortedArgs = [arg for (func,arg) in sorted(zip(funcs,args))]
    sortedFuncs = sorted(funcs)
    funcArr = []
    for arg,func in zip(sortedArgs,sortedFuncs):
        # split the arg1uments by commas
        myArgs = [x.strip() for x in arg.split(",")]
        funcArr.append(getIgorFunc(func,myArgs))
    # POST: have all of the functions we want.
    # go ahead and join/print them.
    outFileName = pGenUtil.getFileFromPath(outFilePath)
    mOutFileStr = getFileStr(funcArr,outFileName)
    with open(outFilePath,"w+") as mOut:
        mOut.write(mOutFileStr)

if __name__ == "__main__":
    mFile = "./MFP3D.ihf"
    outFile = "../../CypherRealTimeProgramming/LocalCypherApiLib/TD_API.ipf"
    run(mFile,outFile)
