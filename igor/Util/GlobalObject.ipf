#pragma rtGlobals=3        // Use strict wave reference mode
#pragma ModuleName=ModGlobal
#include ":Defines"
#include ":DataStructures"
#include ":ErrorUtil"
#include ":PlotUtil"
#include "::Model:ModelDefines"

Structure Global
	Struct Defines def
	Struct ErrorObj err
	Struct PlotDefines plot
	Struct ModelDefines modV
	// XXX Plot utility (colors, etc)
EndStructure

Static Function InitGlobalObj(ToInit)
	Struct Global &ToInit
	// initialize global defines
	ModDefine#InitDefines(ToInit.def)
	// Initialize all the defines
	ModErrorUtil#InitErrorObj(ToInit.err,ToInit.def)
	// Initialize the plotting defines and color maps
	ModPlotUtil#InitPlotDef(ToInit.plot)
	// Initilalize the model defines
	ModModelDefines#InitModelDef(ToInit.modV)
End Function
