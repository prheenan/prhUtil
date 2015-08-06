// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchTestCorrectionPipeline

#include "..:View:ViewGlobal"
#Include "..\Model\ModelDefines"
#include "..:Util:CypherUtil"
Static Function Main()
	// hand-picked values for the times
	Variable t0Fast =0.6332784
	Variable t0Slow =0.6255432
	Variable tfFast = 1.6242664
	Variable tfSlow  = 1.6174406
	// Save them all 
	Struct ViewGlobalDat mData 
 	ModViewGlobal#GetGlobalData(mData)
	// Get the pre-processor
	String mSepName,mForceName
	ModViewGlobal#RunPreprocAndGetSepForce(mData,mSepName,mForceName)
	// As a sanity check, display the graph and its source
	Wave DeflVSrc= $("root:Packages:View_NUG2:Data:Data_AzideB1:Image2449Full_DeflV")
	// Convert the source to force..
	Variable nDeflV = DimSize(DeflVSrc,0)
	Make /O/N=(nDeflV) ForceSrc
	ModCypherUtil#ConvertY(DeflVSrc,MOD_Y_TYPE_DEFL_VOLTS,ForceSrc,MOD_Y_TYPE_FORCE_NEWTONS)
	Display 
	AppendToGraph /C=(10000,0,0)$mForceName vs $mSepName
	//AppendToGraph /C=(50000,50000,50000)  ForceSrc
End Function
