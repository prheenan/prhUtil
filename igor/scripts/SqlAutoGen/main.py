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

from sqltableread import connInf
from IgorConvert import fileContent

def run(connectInfo = connInf(),
        fileDir="/Users/patrickheenan/utilities/igor/SQL/",
        fileExt =".ipf"):
    connectInfo.connect()
    mTableInfo = connectInfo.getAllTableInfo()
    # POST: mTableInfo has everything we need 
    # go ahead and determine all of the table types.
    mTableInfo.generateTableDict()
    # get the string, based on the table dictionary created
    fileContent= mTableInfo.getDBString()
    for fileName,(fileStr,preambleFunc) in fileContent.files.items():
        mFilePath = fileDir + fileName+fileExt
        mStr= preambleFunc(fileName)+fileStr
        # add the preamble
        with open(mFilePath,"w+") as mFile:
            mFile.write(mStr)
        connectInfo.close()

if __name__ == '__main__':
    run()

