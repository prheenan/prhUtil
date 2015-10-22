// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#include ":SurfaceDefines"
#include "::View:ViewUtil"

#pragma ModuleName = ModSurfaceView
StrConstant ViewName = "SurfaceDetector"
Static StrConstant FILTER_CTRL = "FilterTimeControl"
Static StrConstant CORRECT_INTER = "CorrectInter"

Static Function InitView()
	Variable width = 0.3
	Variable height = 0.7
	String mWin = ModViewUtil#CreateNewWindow(width,height,windowName=ViewName)
	Variable currentY = 0 
	Variable eleWidth = 0.8
	Variable eleHeight = 0.1
	String mPopFunc = "ModSurfaceDefines#GetFitters"
	ModViewUtil#AddViewEle("FilterTimeConstant  ",eleWidth,eleHeight,VIEW_SETVAR,mProc="surfaceSetVar",startYRel=currentY,yUpdated=currentY,mOptNum=0.01,panelName=FILTER_CTRL);
	ModViewUtil#AddViewEle("Correct Interference",eleWidth,eleHeight,VIEW_CHECK ,mProc="surfaceCheck"   ,startYRel=currentY,yUpdated=currentY,panelName=CORRECT_INTER);
	ModViewUtil#AddViewEle("Detect Surface       ",eleWidth,eleHeight,VIEW_BUTTON ,mProc="surfaceButton",startYRel=currentY,yUpdated=currentY);
End Function

// Function which, given a control name and a value, updates the state
Static Function UpdateDetectorState(Control,dVal,[sVal])
	String Control,sVal
	Variable dVal
	// load the options
	Struct SurfaceDetectionOptions mViewOpt 
	ModSurfaceDefines#LoadViewOpt(mViewOpt)
	strswitch (Control)
		case FILTER_CTRL:
			// update the filtering time constant
			mViewOpt.savitskyTimeConstantArtifact = dVal
			Print("Setting filter to " + num2str(dVal));
			break
		case CORRECT_INTER:
			mViewOpt.correctInterference = dVal
			Print("Setting artifact to " + num2str(dVal));
			break
		default:
			ModErrorUtil#DevelopmentError(description="Bad Option")
	EndSwitch
	// Write the view options back
	 ModSurfaceDefines#SaveViewOpt(mViewOpt)
End Function 

Function surfaceSetVar(SV_Struct) : SetVariableControl 
	STRUCT WMSetVariableAction &SV_Struct
		switch (SV_Struct.eventCode)
		case EVENT_SETVAR_ENTER:
		case EVENT_SETVAR_MOUSEUP:
			Variable dVal = SV_Struct.dval
			String sVal = SV_Struct.sval
			String mPanel = SV_Struct.ctrlName
			UpdateDetectorState(mPanel,dVal,sVal=sVal)
		break
	EndSwitch
End Function

Function surfaceCheck(CB_Struct) : CheckBoxControl 
	struct WMCheckboxAction &CB_Struct
	switch (CB_Struct.eventCode)
		case EVENT_BUTTON_MUP_OVER:
			Variable on = CB_Struct.checked
			String mPanel = CB_Struct.ctrlName
			UpdateDetectorState(mPanel,on)			
		break
	EndSwitch
End Function

Function surfaceButton(LB_Struct) : ButtonControl 
	STRUCT WMButtonAction &LB_Struct

End Function

