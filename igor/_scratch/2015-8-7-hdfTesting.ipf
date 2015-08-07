// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ScratchHdfTesting
#include "::Util:IoUtilHDF5"
#include "::Util:IoUtil"
#include "::Util:DataStructures"


// Idea here is to write a big, 3 column wave to mimic time/sep/force curves

Static Function makeGZip(mWave,mFolder)
	// Loop through, get the times for each gzip (this is fairly realistic data)
	Wave mWave
	String mFolder
	Variable i,gzipMax = 10
	for (i=0; i<gzipMax; i+=1)
		String mPath = mFolder + "hdfSaveWithGzipOf_" + num2str(i) + "_.hdf"
		ModIoUtilHDF5#Write2DWaveToFile(mWave,mPath,gzip=i)
	EndFor
End Function

Static Function readWriteTest(mWave,mFolder)
	Wave mWave
	String mFolder
	String mPath = mFolder +"RW"
	// Save the wave
	ModIoUtilHDF5#Write2DWaveToFile(mWave,mPath)
	// 	Read the wave back
	String mOutName = "mWaveRead"
	ModIoUtilHDF5#Read2DWaveFromFile(mOutName,mPath)
	Wave toCheck = $mOutName
	if (!ModDataStruct#WavesAreEqual(mWave,toCheck))
		print("RW didn't work so well..")
	EndIf
End Function	

Static Function Main([testGzip,testReadWrite])
	Variable testGzip ,testReadWrite
	testGZip = ParamisDefault(testGzip) ? ModDefine#False() : testGZip
	testReadWrite = ParamIsDefault(testReadWrite) ?  ModDefine#True() : testReadWrite
	// 11 million by 3 
	Variable nRows = 11e6
	Variable nCols = 3
	Make /O/N=(nRows,nCols) mTmpBig
	Wave mWave1 = root:Packages:View_NUG2:MarkedCurves:Data_AzideB1:Image2449Force:DataCopy:Image2449Sep
	Wave mWave2 = root:Packages:View_NUG2:MarkedCurves:Data_AzideB1:Image2449Force:DataCopy:Image2449Force
	mTmpBig[][0] = p/(5.e6)
	mTmpBig[][1] = mWave1[p]
	mTmpBig[][2] = mWave2[p]
	// Get a folder
	String mFolder
	if (!ModIoUTil#GetFolderInteractive(mFolder))
		Return ModDefine#False()
	EndIf
	// POST: have a folder
	if (testGzip)
		makeGZip(mTmpBig,mFolder)
	EndIf
	if (testReadWrite)
		readWriteTest(mTmpBig,mFolder)
	EndIf
End Function
