// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = scratchFit

Static Function Main()
	String mY= "root:Packages:View_DNAWLC:MarkedCurves:X150603:LoopDNA_160ng_uL0021Force:DataCopy:LoopDNA_160ng_uL0021Force"
	String mX = "root:Packages:View_DNAWLC:MarkedCurves:X150603:LoopDNA_160ng_uL0021Force:DataCopy:LoopDNA_160ng_uL0021Sep"
	// Go To the root
	SetDataFolder :
	Variable startPoint = 12917
	Variable endPoint = 13380
	Duplicate /O /R=[startPoint,endPoint] $mY, tmpY
	Duplicate /O /R=[startPoint,endPoint]$mX, tmpX
	Variable xOff = tmpX[0]
	Variable yOff = tmpY[0]
	tmpX -= xOff
	tmpY -= yOff
	Variable nPoints=  DImsize(tmpY,0)
	tmpY *= -1  
	// D: double precision
	Make /D/O coeffs = {800e-9}
	FuncFit myFitFunc,coeffs,tmpY /X=tmpX
	Variable L0Ret = coeffs[0]
	Make /O/N=(nPoints) fitted
	WLC(L0Ret,tmpX,fitted)
	Display tmpY vs tmpX
	AppendToGraph  /C=(55000,55000,55000)  fitted vs tmpX
	//KillWaves /Z tmpY,tmpX,coeffs
	SetAxis left -10e-12,120e-12
End Function

Static Function WLC(L0,X,Y)
	Variable L0
	Wave X,Y
	Variable A = (4.1e-21)/(50.e-9)
	Y = A * ( 1/(4 * (1- X/L0)^2) -1/4 + X/L0)
End Function	

Static Function myFitFunc(pw, yw, xw) : FitFunc
	WAVE pw, yw, xw
	Variable L0 = pw[0]
	// XXX pass this into a struct
	WLC(L0,xw,yw)
End Function