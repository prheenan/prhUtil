// Use modern global access method, strict compilation
#pragma rtGlobals=3	

#pragma ModuleName = ModSqlCypherBootstrap
#include ".\SqlCypherAutoFuncs"
#include ".\SqlCypherInterface"
#include ".\SqlUtil"

Constant SQL_BOOT_CYPHER_DEF_SAMPLE_PREP = 1
Constant SQL_BOOT_CYPHER_DEF_SAMPLE_TYPE = 1
Constant SQL_BOOT_CYPHER_LONG = 1
Constant SQL_BOOT_CYPHER_FIBMINI = 4

Static Function Init()
	// initialize all the data folders
	ModSqlCypherInterface#InitSqlDataFolders()
End Function

Static Function AddDefaultTipTypes()
	// Add the tip types
	Make /O/T Names = {"Biolever_Long","Biolever_Mini","BioLever_Fast","FIB_Biolever_Fast","FIB_BioLever_Mini"}
	Make /O/T Descriptions = {"Standard Olympus Biolever Long","Standard Olympus Biolever Mini","Standard Olympus Biolevel Fast","Focused Ion Beam Modified Biolever Fast","Focused Ion Beam Modified Biolevel Mini"}  
	Variable nTypes = DimSize(Names,0)
	Variable i=0
	Struct TipType tmpTip
	for (i=0; i<nTypes; i+= 1)
		tmpTip.Name = Names[i]
		tmpTip.Description = Descriptions[i]
		// POST: tmp is set up with the type and descriptions needed
		ModSqlCypherAutoFuncs#InsertFmtTipType(tmpTip)
	EndFor
End Function

Static Function AddDefaultMolecules()
	// Add the families, molecule types, and samples
	Make /O/T FamilyNames = {"DNA","RNA","Protein"}
	Make /O/T Descriptions = {"Deoxyribonucleic acid","Oxyribonucleic acid","A Polypeptide"}
	Variable dnaIndex = 0
	Variable nFamilies = DimSize(FamilyNames,0)
	Variable i=0 
	Struct MoleculeFamily mTab
	for (i=0; i<nFamilies; i+= 1)
		mTab.Name = FamilyNames[i]
		mTab.Description = Descriptions[i]
		ModSqlCypherAutoFuncs#InsertFmtMoleculeFamily(mTab)
	EndFor
	// POST: all the families are around
	// Add the default molecule Types
	// XXX for now, just circular DNA
	Struct MolType typeTab
	// XXX magic number; 1 is the first thing,
	typeTab.idMoleculeFamily = 1
	typeTab.Name = "CircularDNA"
	typeTab.Description= "Mp13 plasmid with 1607F-DBCO and 3520R-Bio primers with 12 nt complementary overhang: GTG GTC CTA GTG"
	ModSqlCypherAutoFuncs#InsertFmtMolType(typeTab)
	// Add the actual samples we care about
	KillWaves /Z Descriptions,FamilyNames
End Function

Static Function AddDefaultRatings()
	// Ratings is composite (string and variable), so we must use the alternative syntax.
	Make /O Ratings = {-1,1,2,3,4,5}
	Make /O/T Names = {"Unrated","Very Low Quality, very high noise","Low Quality or high noise","Standard","Great","Paper-or Talk-Worthy"}
	Duplicate /O/T Names,Descriptions
	// POST: we have the database an table set up.
	// Make the (special) insert string
	// We have only quesiton marks for the fields
	ModSqlCypherAutoFuncs#InsertTraceRating(Ratings,Names,Descriptions)
	// Composite stmt cleans up after us.
End Function

Static Function AddDefaultUsers()
	Make /O/T Names = {"Patrick_Heenan","William_'John'_Van_Patten","Devin_Edwards","Thomas_Perkins"}
	ModSqlCypherAutoFuncs#InsertUser(Names)
End Function	

Static Function AddDefaultSamplePreps()
	Make /O/T Name ={"Standard_GelPurified"}
	MAke /O/T Description = {"Amplified DNA, purified by gel electrophoresis, Bio-Rad Quantum freeze and squeeze, and (optionally) Amicon 10K 0.5mL"}
	ModSqlCypherAutoFuncs#InsertSamplePrep(Name,Description)
End Function

Static Function AddDefaultTipPreps()
	Make /O/T Description = {"Standard As Of 2015/07"}
	Make /O GoldEtchSec = {30}
	Make /O ChromEtchSec = {30}
	Make /O TipPrepCol = {0}
	ModSqlCypherAutoFuncs#InsertTipPrep(Description,GoldEtchSec,ChromEtchSec,TipPrepCol)
End Function

Static Function AddDefaultTipPack()
	Make /O/T Name = {"Unknown"}
	Make /O/T Description  = {"Unkown Tip Pack"}
	ModSqlCypherAutoFuncs#InsertTipPack(Name,Description)
End Function

// Add the samples already made.
Static Function AddDefaultSamples()		
	Struct Sample mTab
	Make /O/T DateSampleCreated = {"2015/6/04","2015/6/04","2015/6/30"}
	Make /O/T DateSampleDeposited = {"2015/6/16","2015/7/4","2015/7/6"}
	Duplicate /O/T DateSampleDeposited,DateSampleRinsed
	Variable concentration = 130 // ng/muL
	Variable vol = 20 // uL loaded
	String description = "Standard Circular DNA"
	Variable MoleculeName = SQL_BOOT_CYPHER_DEF_SAMPLE_TYPE
	Variable SamplePrep = SQL_BOOT_CYPHER_DEF_SAMPLE_PREP
	Variable n = DimSize(DateSampleCreated,0)
	Variable i
	for (i=0; i< n; i+=1)
		String timeCreated = (DateSampleCreated[i])
		String timeDeposit = (DateSampleDeposited[i])
		String timeRinsed  = (DateSampleRinsed[i])
		mTab.DateCreated= timeCreated
		mTab.DateDeposited= timeDeposit
		mTab.DateRinsed = timeRinsed
		mTab.VolLoadedMuL = vol
		mTab.ConcNanogMuL= concentration
		mTab.idMolType = moleculeName
		mTab.idSamplePrep= samplePrep
		mTab.Description = description
		ModSqlCypherAutoFuncs#InsertFmtSample(mTab)
	EndFor
	KillWaves /Z DateSampleCreated,DateSampleDeposited,DateSampleRinsed
End Function

Static Function AddDefaultTipManifests()
	Make /O/T TimeMade = {ModSqlUtil#ToSqlDateComposite(2015,6,16),ModSqlUtil#ToSqlDateComposite(2015,7,14)}
	Duplicate /O/T TimeMade,TimeRinsed
	Make /O TipProtocol  = {1,1}
	Make /O TipTypes = {SQL_BOOT_CYPHER_LONG,SQL_BOOT_CYPHER_FIBMINI}
	Make /O tipPack = {1,1}
	Make /O/T Descriptions = {"",""}
	Make /O/T Name = {"BioLong6/16","BioMini7/14"}
	Make /O/T PackPosition = {"Unknown","Unknown"}
	ModSqlCypherAutoFuncs#InsertTipManifest(Name,Descriptions,PackPosition,TimeMade,TimeRinsed,TipProtocol,tipTypes,tipPack)
	KillWaves /Z TimeMade,TimeRinsed,TipTypes,TimeRinsed,Descriptions
End Function

//
////
////// Following are for *debugging* only, and not really for bootstrapping.
////
//
