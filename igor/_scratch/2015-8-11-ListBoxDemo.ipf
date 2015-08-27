// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModListBoxDemo
#include "::View:ViewUtil"

Static Function Main()
	Make /O/T mTmpOpt = {"bloo","bloo2","blootutu"}
	NewPanel /W=(0,0,100,100)
	Make /O/N=(DimSize(mTmpOpt,0)) mSel
	ModViewUtil#MakeListBox("tmp","",mTmpOpt,0,0,100,100,mProto,selWave=mSel)
End Function

Function mProto(LB_Struct) : ListboxControl 
	STRUCT WMListboxAction &LB_Struct
	switch (LB_Struct.eventCode)
		case EVENT_LIST_SEL:
		case EVENT_LIST_MOUSE_UP:
			print("foo")
			break
	EndSwitch
End Function