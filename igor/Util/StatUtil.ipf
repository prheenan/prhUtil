// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModStatUtil

Structure WaveStat
	Variable stdev
	Variable average
	Variable rms
EndStructure

Static Function GetWaveStats(mWave,mStats,StartIdx,EndIdx)
	Wave mWave
	Struct WaveStat & mStats
	Variable StartIdx,EndIdx
	// P V-746
	// /Q: quiet 
	// /R=[X,Y]: index from x to Y
	WaveStats /Q/R=[StartIdx,EndIdx] mWave
	// WaveStats (by side effect, ick) creates variabes on  V-747
	mStats.stdev =  V_sdev
	mStats.average = V_avg
	mStats.rms = V_rms
End Function
