// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModDictionary
#include "..:Util:IoUtil"
#include "..:Util:DataStructures"

//  Adapted from:
// http://www.igorexchange.com/node/5066

StrConstant DICT_EMPTY = ""
StrConstant DICT_KEY_SEP = "="
StrConstant DICT_LIST_SEP = "\r"

Structure Dictionary 
	String mKeys
	String mKeyVals
	Variable nKeys
	// Separators
	String KeySep
	String ListSep
EndStructure

Static Function InitDict(mDict)
	Struct Dictionary & mDict
	mDict.mKeys = ""
	mDict.mKeyVals = ""
	// Start with no keys
	mDict.nKeys = 0
	// Record the key separators
	mDict.KeySep = DICT_KEY_SEP
	mDIct.ListSep = DICT_LIST_SEP
End Function

Static Function KeyExists(mDict,noteKey)
	Struct Dictionary & mDict
	String noteKey
	String mMatch 
	sprintf mMatch"*%s*",noteKey
	return StringMatch(mDict.mKeys,mMatch)
End Function

Static Function SetKeyValWave(mDict,noteKey,newValueWave)
	Struct Dictionary & mDict
	String noteKey	
	Wave /T newValueWave
	String mVal =ModDataStruct#GetListFromWave(newValueWave)
	SetKeyVal(mDict,noteKey,mVal)
End Function

Static Function SetKeyVal(mDict, noteKey, newValueStr)
	Struct Dictionary & mDict
	string noteKey
	string newValueStr
	// POST: we know what we are putting in.
	mDict.mKeyVals = replacestringbykey(noteKey,mDict.mKeyVals," "+newValueStr,mDict.KeySep,mDict.ListSep)
	if (!KeyExists(mDict,noteKey))
		// then add to the number of keys and key string
		mDict.mKeys +=  noteKey + mDict.ListSep
		mDict.nKeys += 1
	EndIf
end
 
Static Function/S GetKeyVal(mDict,noteKey)
	Struct Dictionary & mDict
	String noteKey
	return stringbykey(noteKey,mDict.mKeyVals,mDict.KeySep,mDict.ListSep)[1,inf]
end

Static Function RemoveKey(mDict,noteKey)
	Struct Dictionary &mDict
	String noteKey
	// remove the key we are interested in removing
	mDict.mKeyVals = Removebykey(noteKey,mDict.mKeyVals ,mDict.KeySep,mDict.ListSep)
End Function

Static Function /Wave CreateKeyWave(mDict)
	Struct Dictionary &mDict
	// XXX make this a uniquename thing?
	Make /O/T/N=(mDict.nKeys) tmpKeyWave
	 ModDataStruct#ListToTextWave(tmpKeyWave,mDict.mKeys,mDict.keySep)
	 return tmpKeyWave
End Function

Static Function Main()
	Struct Dictionary mDict
	InitDict(mDict)
	SetKeyVal(mDict,"foo","bar")
	SetKeyVal(mDict,"bart","baz")
	Make /O/T mWave = {"first","second","third"}
	SetKeyValWave(mDict,"mNum",mWave)
	KillWaves /Z mWave
End Function
