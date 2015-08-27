// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModIoUtilHDF5
#include ":IoUtil"

// See: HDF5 Help.ihf
Static Constant HDF5_SAVEDATA_GZIP  = 1 // An integer from 0 to 9. 0 is no compression, 9 is maximum compression.
// Based on tests using time,sep, and force data from real 5MHZ data, 1 looks like enough
// Igor text file: 512MB
// HDF5 Without GZIP, 126MB
// With GZIP=1, 61MB (48%)
// With GZIP =8, 58MB (46%, but much much slower)
Static Constant HDF5_SAVEDATA_SHUFFLE = 1 // if 1, Do shuffle data prior to compressing. Reorders bytes before compressing so that corresponding bytes of a multi-byte element are contiguous. This can result in higher compression ratios.
Static Constant HDF5_SAVEDATA_ATTRIBUTES = -1 // If attributesMask  is -1, all attributes are written
Static Constant HDF5_SAVEDATA_TRUEWRITE = 1//  ' The dataset is created and the data is  written to it. '
Static Constant HDF5_SAVEDATA_CHUNKED_LAYOUT = 2 // : Chunked layout. For a dataset to be extendible [or gzipped], the layout must be chunked.
Static StrConstant HDF5_DEFAULT_DATASET = "PrhHD5GenericData"

Static Constant HDF5_SUCESSFUL_RET = 0 

Static Function CloseAndReturn(mID)
	Variable mID
	HDF5CloseFile /Z mID
	return (V_FLAG == HDF5_SUCESSFUL_RET)
End Function

// Reads 'mFile' into 'mOutName'. Returns false if it fails.
Static Function Read2DWaveFromFile(mOutName,mFile,[datasetName])
	String mOutName,mFile,datasetName
	if (ParamIsDefault(datasetName))
		datasetName = HDF5_DEFAULT_DATASET
	EndIf
	if (!ModIoUtil#FileExists(mFile))
		return ModDefine#False()
	EndIf
	// POST: file exists
	// Try to open it.
	// /Z: handle errors myself
	// /R: read only
	Variable mID
	HDF5OpenFile /Z /R mId as mFile
	// Did we sucessfully open the file?
	if (V_FLAG != HDF5_SUCESSFUL_RET)
		return ModDefine#False()
	EndIf
	// POST: opened an existing HDF5 file
	// Read in the wave into whatever name we have
	// See: Write2DWaveToFile for flags, except:
	// /N: Name of output wave
	// /Q: QUIET!!!
	// Last two arguments are the file ID and file name
	HDF5LoadData /Z /Q /O /IGOR=(HDF5_SAVEDATA_ATTRIBUTES) /N=$(mOutName) mId, datasetName
	if (V_FLAG != HDF5_SUCESSFUL_RET)
		// close the file before returning falase
		 CloseAndReturn(mID)
		return ModDefine#False()
	EndIf
	 return CloseAndReturn(mID)
End Function

Static Function Write2DWaveToFile(mWave,mFIle,[gzip,datasetName])
	Wave mWave
	String mFile,datasetName
	Variable gzip
	if (ParamIsDefault(datasetName))
		datasetName = HDF5_DEFAULT_DATASET
	EndIf
	gzip = ParamIsDefault(gzip) ? HDF5_SAVEDATA_GZIP : gzip
	Variable shuffle = (gzip > 0) // shufle if we are gzipping.
	Variable mID
	// Get the dimensions to save
	Variable dim1 = DimSize(mWave,0),dim2 = DimSize(mWave,1)
	// XXX check that dimensions are OK, no third dimension, etc.
	// Create the file, set mID by referece 
	// /O: overwrite if it exists
	HDF5CreateFile /O mID as mFile
	// POST: mID is the ID we care about, go ahead and 
	// save the wave
	// GZIP: specifies the degree of compression.
	// /LAYO: In order to use compression you must also specify chunked layout using the /LAYO flag.
	// IGOR: specifies which attributes are written. key to re-loading in IGOR
	// WRIT: specifies if the dataset is  really written or not (seems like it should always be..)
	// the last three arguments are <wave , locationID  , nameStr  >
	// /O: overwrite
	// where locationID and namestr are the file ID and name respectively
	
	// XXX add explicit max size? (dont really need this if we are just saving data for later)
	HDF5SaveData /O /LAYO= {HDF5_SAVEDATA_CHUNKED_LAYOUT,dim1,dim2} /GZIP={gzip,shuffle} /IGOR=(HDF5_SAVEDATA_ATTRIBUTES) /WRIT=(HDF5_SAVEDATA_TRUEWRITE) mWave, mId, datasetName
	// Close the file
	return  CloseAndReturn(mID)
End Function


 Static Function SaveForceExtensionFromStub(StubSep,StubForce,Folder,Name)
 	// Note: Force information natively saved in single point as of 8/13/2015.
 	// If we switch to double, will want to use double here and in duplicate.
	String StubForce,StubSep,Folder,Name
	// XXX make sure wave exists?
	Wave force = $StubForce
	Wave sep = $StubSep
	Variable n=DimSize(force,0)
	Make /O/N=(n) mTime
	Variable dt= DimDelta(force,0)
	Variable t0 = DimOffset(force,0)
	// p notation: mtime[i] = i * dt + t0, where dt is the time delta and t0 is the
	// time offset
	mTime = p*dt + t0
	// /DL: Set dimension labels
	// /O: overwrites
	 Concatenate /O/DL {mTime,sep,force}, combinedWave
	 // get the force note
	String mNote = note(force)
	// Append to the concatenated wave
	Note combinedWave,mNote
	// POST: $combinedName is a wave with columns like [time,x,y]
	// Go ahead and save
	// *dont* save the x scale (time), since we can get that from the x scaling later.
	String filePath = ModIoUtil#AppendedPath(Folder,Name) + ".hdf"
	Write2DWaveToFile(combinedWave,filePath)
	// Kill the wave we make
	KillWaves /Z combinedWave
End Function
