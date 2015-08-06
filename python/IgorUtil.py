# force floating point division. Can still use integer with //
from __future__ import division
# This file is used for importing the common utilities classes.
import numpy as np
import matplotlib.pyplot as plt
# import the patrick-specific utilities
import GenUtilities  as pGenUtil
import PlotUtilities as pPlotUtil
import CheckpointUtilities as pCheckUtil

# https://pypi.python.org/pypi/igor
import igor
from igor.binarywave import load as loadibw
from igor.packed import load as loadpxp
# types for experiments
from igor.record.base import TextRecord
from igor.record.folder import FolderStartRecord, FolderEndRecord
from igor.record.variables import VariablesRecord
from igor.record.wave import WaveRecord
from pprint import pformat

class IgorObj:
    def __init__(self,loadedData):
        self._ver = loadedData['version']
        waveInfo =  loadedData['wave']
        self._meta = waveInfo['note']
        self._data = waveInfo['wData']
        self._dSize = self._data.size
        # XXX this might be file-specific?
        header = waveInfo['wave_header']
        self._mName = header['bname']
        self._mDate = header['creationDate']
        self._xStart = header['sfB'][0]
        self._xStep = header['sfA'][0]
    @staticmethod
    def downsampleStatic(data,stepsize):
        return data[::stepsize]
    def downsample(self,stepsize):
        self._data = IgorObj.downsampleStatic(self._data,stepsize)
        return self._data
    def getIdxWhere(self,condFunc):
        return np.where(condFunc(self._data))[0]
    def mask(self,idx):
        self._data = self._data[idx]
        return self._data

class WaveGrouper:
    def __init__(self,groupObjFunc,groupIdFunc = lambda x,y: x[:9]):
        #gorupObjFunc: takes a 'group' (object with same ID) and makes
        # a group object.
        #groupIdFunc: takes a name (from the wave) and gives a group ID. 
        # this doesnt have to be unn
        self.txToGroup = groupObjFunc
        self._groupIdFunc = groupIdFunc
    def setNames(self,names):
        self._names = names
    # get the set of Ids
    def getId(self,n):
        return self._groupIdFunc(n,self._names) # first nine characters
    def getGroups(self,ids,names,waves):
        groups = dict()
        for idV in ids:
            tmp = self.txToGroup([ w for i,w in enumerate(waves) 
                                   if idV in w._mName ])
            groups[idV] = tmp
        return groups
    

def pprint(data):
    lines = pformat(data).splitlines()
    print('\n'.join([line.rstrip() for line in lines]))

def loadIBW(dataPath):
    d = loadibw(dataPath)
    mObj = IgorObj(d)
    return mObj

def _loadPxpWaves(filename,debugLimit=None):
    records,filesystem = loadpxp(filename)
    waves = []
    # loop through the whole file, we only care about waves
    for i,record in enumerate(records):
        if isinstance(record, (FolderStartRecord, FolderEndRecord)):
            pass
        elif isinstance(record, TextRecord):
            pass
        elif isinstance(record, VariablesRecord):
            pass
        elif isinstance(record, WaveRecord):
            waves.append(IgorObj(record.wave))
    return waves

def loadPxpByGroup(filename,grouper,debugLimit=None):
    # group by the file names.
    waves = _loadPxpWaves(filename,debugLimit)
    names = [w._mName  for w in waves ]
    grouper.setNames(names)
    # get the set of Ids
    ids = set([grouper.getId(n) for n in names])
    return grouper.getGroups(ids,names,waves)

def loadForceExtPxp(filename,debugLimit = None,forceStr="force_",extStr="ext_"):
    # opens the Igor '.pxp' file, and loads matching force/extension waves
    # (which should be identically named, except replacing 'forceStr' with 
    # 'extStr'
    #Returns: extObj and forceObj, two arrays where 
    # extObj[i] is the extension for forceObj[i], all elements are IgorObj
    # have all the waves. only want ones with forces and extensions
    waves = _loadPxpWaves(filename,debugLimit)
    waves = [w for i,w in enumerate(waves) 
             if forceStr in w._mName or extStr in w._mName]
    # literal file names
    names = [w._mName  for w in waves ]
    # which waves are forces?
    forceIdx = [i for i,n in enumerate(names)  if forceStr in n]
    # which waves are forces and have a matching extension
    forceIdxWithExt = [ i  for i in forceIdx 
                        if names[i].replace(forceStr,extStr) in names]
    # which waves are forces, without a matching extension
    forceIdxWithoutExt = [ i  for i in forceIdx 
                           if names[i].replace(forceStr,extStr) not in names]
    # get the extension waves we want
    extIdxForForce = [ names.index(names[i].replace(forceStr,extStr))
                       for i in forceIdxWithExt]
    # next assertions just check to make sure all this indexing works
    allIdx = forceIdxWithExt+forceIdxWithoutExt+extIdxForForce
    nNames = len(names)
    # make sure the indices dont overlap
    assert set(forceIdxWithExt) & set(extIdxForForce)  == set() ,\
                    "Overlapping force and ext indices"
    assert set(forceIdxWithoutExt) & set(extIdxForForce)  == set() ,\
                    "Overlapping force and ext indices"
    # indices should cover everything exactly once
    allSet = set(allIdx)
    desSet = set(range(nNames))
    missingNames = [names[i] for i in desSet-allSet]
    assert len(allIdx) == nNames,\
        "Didn't have proper indces {:s} for files {:s}".\
        format(sorted(allIdx),missingNames)
    assert allSet == desSet,\
        "Missing files: {:s}".format(missingNames)
    # get the force/extension waves we want, now that we are sure
    # everything matches
    extObj = [waves[i] for i in extIdxForForce]
    forceObj = [waves[i] for i in forceIdxWithExt]
    # POST: extObj[i] is the extension for forceObj[i]
    if (debugLimit is not None):
        extObj = extObj[:debugLimit]
        forceObj = forceObj[:debugLimit]
    return forceObj,extObj

