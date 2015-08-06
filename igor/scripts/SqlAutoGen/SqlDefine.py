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

class SqlDefine:
    TYPE_DOUBLE = "double"
    TYPE_VARCHAR = "varchar"
    TYPE_DATETIME = "datetime"
    TYPE_INT = "int"
    @staticmethod
    def getShortFieldName(fieldName):
        # get the field name for this structure.
        if ("_" in fieldName):
            return fieldName.split("_")[-1]
        else:
            return fieldName
    @staticmethod
    def getNameType(mTableField):
        namesTmp = []
        typeTmp = []
        # XXX replace string with something better.
        for element in mTableField:
            typeTmp.append(element['type'])
            namesTmp.append(element['fieldname'])
        return namesTmp,typeTmp
