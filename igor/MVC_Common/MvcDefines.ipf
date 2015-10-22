// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModMvcDefines

// what to plot against
// Important, since a model may be time based (ie: rupture distribution)
// or separation based (ie: WLC) or both
Constant PLOT_TYPE_X_VS_TIME = 1
Constant PLOT_TYPE_X_VS_SEP = 2
// Global Experiment Data Folder Strings
StrConstant BASEFOLDER = "root:Packages"
StrConstant WINDOWNAME = "ViewPRH"
// struct for communication between view and model
Structure ViewModelStruct
	String modelBaseOutputFolder
	String mExp
EndStructure

Static Function /S GetViewWindowName()
	return WINDOWNAME
End Function

// Get just the view name
Static Function /S GetViewName(ModelName)
	String ModelName
	return "View_" +ModelName
End Function

// get hte absolute view base direcrtory
Static Function /S GetViewBase(ModelName)
	String ModelName
	return GetRelToBase(GetViewName(ModelName))
End Function

// Get anything, relative to the packages directory we work in
Static Function /S GetRelToBase(extra)	
	String Extra
	return ModIoUtil#AppendedPath(BASEFOLDER,extra)
End Function

// Defined model types, for switching between views.
// note: 1 offset.
Constant MVC_MODEL_NONE = 1
Constant MVC_MODEL_DNA = 2
Constant MVC_MODEL_NUG2 = 3
Constant MVC_MOODEL_SURF_DETECT = 4

// Function to get the names of the models. *must* match constants given above.
Static Function /S GetModelOptions()
	String toRet= "None Selected;Worm-Like DNA;NUG Rupture Times;Surface Detector"
	return toRet
End Function
