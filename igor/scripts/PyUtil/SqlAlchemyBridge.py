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

from sqlalchemy.orm.attributes import manager_of_class
from sqlalchemy.orm.properties import ColumnProperty
import argparse as ap

# from: 
#http://stackoverflow.com/questions/7239873/recreate-some-sqlalchemy-object
# essentialy, we want to serialize some class, turn it into a simple dictionary 
def get_state_dict(instance,name="Generic"):
    cls = type(instance)
    mgr = manager_of_class(cls)
    myDict = dict((key, getattr(instance, key))
                  for key, attr in mgr.iteritems()
                  if isinstance(attr.property, ColumnProperty))
    # next, we convert the dictionary to a 'namespace',
    # which allows us to use dot notation
    # XXX used named tuple instead?
    nameSpace = ap.Namespace(**myDict)
    return nameSpace

