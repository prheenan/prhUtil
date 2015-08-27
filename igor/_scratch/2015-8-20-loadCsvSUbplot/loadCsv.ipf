// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#include ":::Util:IoUtil"
#include ":::Util:PlotUtil"
#include ":::Util:Defines"
#include ":::Util:DataStructures"

#pragma ModuleName = ModLoadCsv

Static Function Main([interactive])
	Variable interactive
	ModPlotUtil#ClearAllGraphs()
	KillWaves /Z/A 
	KillDataFolder root:
	if (ParamIsDefault(interactive))
		interactive  = ModDefine#False()
	EndIf
	String mLoadRateFile = "csv-Load.csv"
	String mRuptFile = "csv-Rupt.csv"
	String mTypesFile = "csv-Types.csv"
	String mFolder
	if (interactive)
		if(!ModIoUtil#GetFolderInteractive(mFolder))
			return ModDefine#False()
		EndIf
	Else
		mFolder = "Macintosh HD:Users:patrickheenan:utilities:igor:_scratch:2015-8-20-loadCsvSUbplot:"
	EndIf
	// POST: have a folder
	String loadDir = "root:load:",ruptDir = "root:rupt:",typeDir ="root:types:"
	Variable ret = ModDefine#True()
	// load each of the three matrices.
	ret = ret & ModIoUtil#LoadFile(mFolder + mLoadRateFile,locToLoadInto=loadDir)
	ret = ret &ModIoUtil#LoadFile(mFolder + mRuptFile,locToLoadInto=ruptDir)
	ret = ret & ModIoUtil#LoadFile(mFolder + mTypesFile,locToLoadInto=typeDIr)
	if (!ret)
		return ModDefine#False()
	EndIf
	// get the waves
	// XXX check that we actually loaded (the correct) something?
	Wave mLogLoadRate = $ModIoUtil#GetWaveAtIndex(loadDir,0,fullPath=ModDefine#True())
	Wave mType = $ModIoUtil#GetWaveAtIndex(typeDir,0,fullPath=ModDefine#True())
	Wave mRuptForce = $ModIoUtil#GetWaveAtIndex(ruptDir,0,fullPath=ModDefine#True())
	// Get the number of objects and ruptures
	Variable nObj = DimSize(mRuptForce,0)
	Variable nRupt = DimSize(mRuptForce,1)
	// get a figure
	String mWindow = ModPlotUtil#Figure(hide=ModDefine#False())
	// make subplots for each rupture
	Variable i
	Variable MinX = WaveMin(mLogLoadRate)
	Variable MaxX = WaveMax(mLogLoadRate)
	Variable MinY = WaveMin(mRuptForce)
	Variable MaxY = WaveMax(mRuptForce)
	// Get the set of the types
	Make /O/T/N=(0) typeSet
	ModIoUtil#GetSet(mType,typeSet)
	// POST: typeSet has one element for each type of cantilever
	for (i=0; i<nRupt; i+=1)
		String mSubplot = ModPlotUtil#Subplot(nRupt,1,(i+1),windowName=mWindow)
		String mNameForce = "Force" + num2str(i)
		String mNameLog = "Log" + num2str(i)
		Make /O/N=(nObj) $mNameForce,$mNameLog
		Wave force = $mNameForce
		Wave Load = $mNameLog
		force[]= mRuptForce[p][i]
		load[]= mLogLoadRate[p][i]
		ModPlotUtil#Plot(load,force,graphName=mSubplot,marker="o")
		Variable fontSize = 15
		ModPlotUtil#Xlabel("Log of Loading Rate (pN/s)",graphName=mSubplot,fontsize=fontSize)
		ModPlotUTil#YLabel("Rupt Force (pN)",graphName=mSubplot,fontsize=fontSize)
		ModPlotUtil#Xlim(minX,maxX,graphName=mSubPlot)
		ModPlotUtil#YLim(minY,maxY,graphName=mSubPlot)
		ModPlotUtil#pLegend()
	EndFor
End Function