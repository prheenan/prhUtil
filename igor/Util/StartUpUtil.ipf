// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModStartUpUtil
#include ":PlotUtil"

// Nukes everything in the current experiment, closes all windows and graphs 
Static Function FreshSlate()
	ModPlotUtil# ClearAllGraphs()
	KillDataFolder /Z root:
	// Kill every path
	KillPath /A 
End Function