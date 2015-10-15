// Use modern global access method, strict compilation
#pragma rtGlobals=3	
#include "::Util:DataStructures"
#include "::Util:ErrorUtil"
#pragma ModuleName = SafeWaveStruct
// This module allows for safer 1-D setting waves to have 'safe' dimensional labelling
// Unfortunately, it is a runtime-only check.. 
// Our default dimension label
Static Constant DEF_DIM_LABEL = 0 
Static StrConstant DEF_DICT_STR = ""
// See Igor API, V-568, "SetDimLabel"
Static Constant MAX_DIMLABEL_KEYSIZE = 31 

// Returns the index of the label for the 0-th dimension or -2 if not found
Static Function GetIndexOfLabel(mWave,mLabel,dimension)
	Wave mWave
	String mLabel
	Variable dimension
	Variable mIndex = FindDimLabel(mWave,dimension,mLabel)
	return mIndex
End Function

Static function KeyExists(mWave,mLabel,[dimension])
	Wave mWave
	String mLabel
	Variable Dimension
	if (ParamIsDefault(dimension))
		dimension = DEF_DIM_LABEL
	EndIf
	return GetIndexOfLabel(mWave,mLabel,Dimension) >= 0 
End Function

Static Function AddKey(mWave,Key,dimNumber,IndexInit)
	Wave /T mWave
	String Key
	Variable IndexInit,dimNumber
	Variable mIndex = GetIndexOfLabel(mWave,Key,dimNumber)
	if (mIndex < 0)
		// Then we need to add this Key
		// Check that the key is in the proper size
		if (strlen(Key) > MAX_DIMLABEL_KEYSIZE)
			String mStr
			sprintf mStr,"Key [%s] used for labelling cannot be more than [%d] characters",Key,MAX_DIMLABEL_KEYSIZE
			ModErrorUTil#OutOfRangeError(description=mStr)
		EndIf
		// POST: We can add this key correctly
		SetDimLabel dimNumber,IndexInit,$Key,mWave
	EndIf
End Function

// Assuming a key exists, sets it to a value. 
Static Function SetKeyValue(mWave,Key,Value,[dimNumber])
	Wave mWave
	String Key
	Variable Value
	Variable dimNumber
	if (ParamIsDefault(dimNumber))
		dimNumber= DEF_DIM_LABEL
	EndIf
	if (!KeyExists(mWave,Key,dimension=dimNumber))
		// Throw an error; we assume the key exists
		String mStr
		sprintf mStr,"Key [%s] does not exists as a dimensional label",Key
		ModErrorUTil#OutOfRangeError(description=mStr)
	EndIF
	// POST: the label  exists; don't need to add it
	// Go ahead and set the key equal to this value 
	mWave[%$Key] = Value
End Function

// Returns a new wave with the specified strings
Static Function /Wave InitializeDict(mWave,mKeys,[values,dimension])
	Wave mWave
	Wave /T mKeys
	Wave values // what to populate (optional)
	Variable dimension // which dimension to put the labels on 
	if (ParamIsDefault(dimension))
		dimension = DEF_DIM_LABEL
	EndIf
	// We dynamically create 'valsToUse'. If the user doesn't
	// give anything, then we use the default string
	Variable n = DimSize(mKeys,0)
	Variable nDataWave = Dimsize(mWave,dimension)
	if (n != nDataWave)
		// wrong number of keys
		String mStr
		sprintf mStr,"Dimensional label wave (N=%d) and data wave (M=%d) do not have matching sizes",n,nDataWave
		ModErrorUtil#OutOfRangeError(description=mStr)
	EndIf
	// If the user doesn't specify any values, then we 
	// just use the default string to populate the dictionary
	Wave valsToUse
	if (paramIsDefault(values))
		Make /O/N=(n) valsToUse
		valsToUse[] = DEF_DIM_LABEL
	Else
		valsToUse = values
	Endif
	// POST: know the values. Go ahead and populate the dictionary
	Variable i
	For (i=0;  i<n; i+=1)
		// Add the key at index i, so were know it is there
		AddKey(mWave,mKeys[i],dimension,i)
		// Set the key's value
		SetKeyValue(mWave,mKeys[i],valsToUse[i],dimNumber=dimension)
	EndFor
	// POST: all keys are set up 
	KillWaves /Z valsToUseInitDict
End Function

// returns valToGet, or an error if they key wasn't right
Static Function GetKeyValue(mWave,Key,[dimension])
	Wave mWave
	String Key
	Variable dimension
	if (ParamIsDefault(dimension))
		dimension= DEF_DIM_LABEL
	EndIf 
	// First, check that the key exists
	if (!KeyExists(mWave,key,dimension=dimension))
		// throw an error
		String mStr
		sprintf mStr,"Key %d does not exist",key
		ModErrorUtil#OutOfRangeError(description=mStr)
	EndIf	
	// POST: the key exists
	return mWave[%$Key]
End Function

// Simple unit test
Static Function Main()
	Make /O/T mKeys = {"Foo","Bar","baz"}
	Make /O/T/N=(DimSize(mKeys,0)) fooBar
	InitializeDict(fooBar,mKeys)
	// POST: should be initialized. 
	// Check that the indices are there
	// Note: apparently finddimlabel is *not* case sensitive... 
	Variable toRet = KeyExists(fooBar,"Foo") && KeyExists(fooBar,"Bar") && KeyExists(fooBar,"baz")
	toRet = toRet && (!KeyExists(fooBar,"foo1") && !KeyExists(fooBar,"blahblah"))
	// Set the value; check that it works out
	SetKeyValue(fooBar,"Foo",1)
	Variable mFoo = GetKeyValue(fooBar,"Foo") 
	toRet = toRet && (mFoo ==1)
	KillWaves /Z fooBar,mKeys
End Function