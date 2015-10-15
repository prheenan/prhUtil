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

# converts force (Newtons) and separation (meters) into Z Sensor (Location, not V)
def convertToZSensorLocation(Separation,Force,Invols,SpringConst):
    # (verified 9/3)
    # Separation = Deflection - ZSensor
    # Sep = Defl - ZPos 
    # ZPos = Defl - Sep
    # ZPos = (Force/SpringConst - Sep)
    ZSensor = (Force/SpringConst-Separation)
    return ZSensor

def run():
    pass

if __name__ == "__main__":
    run()
