(* ::Package:: *)

BeginPackage["PhysicsPackage`"];
(* General Functions *)
SphereExpand::usage = "Expand a function up to order l in spherical harmonics, return as grid";
SphericalBesselJZero::usage = "Given [l,k], gets the k-th root of the l-th Spherical Bessel of 1st kind";
SphericalBesselNZero::usage = "Given [l,k], gets the k-th root of the l-th Spherical Bessel of 2nd kind";
(* Classical Mechanics *)
PoissonBracket::usage = "Get the Poissoin bracket for  two variables";
LagrangeSolve::usage = "Solve Lagrangian 'L' for q''[t]";
DiscreteMoment::usage = "Get the discrete moment of intertia matrix for a point mass at a location";
ContinuousMoment::usage= "Given assumptions, a function to do the volume integral, density, and list of symbols, gives the moment of inertia matrix";
GetSecularMatrix::usage ="Given expressions for potential and kinetic energy and associated symbols, gets the secular equation, V-\[Lambda]*T.";
GetVelocitiesByMomenta::usage = "Given a lagrangian and symbols(as well as time and moment symbol), solvesfor the generalized velocities in terms of gen. coords and gen momenta. Assumes coordinates like x[t] x'[t], x''[t], etc ";
GetVelocityRules::usage = "Given a Lagrangian and symbols (as well as time and moment symbol), solves for the velocity rules, \!\(\*SubscriptBox[\(q\), \(i\)]\)' -> \!\(\*SubscriptBox[\(p\), \(i\)]\)";
Hamiltonian::usage = "Get the Hamiltonian representation, given a lagrangian, symbols,  (as well as time and moment symbol) ";
HamiltonsEq::usage = "Given a Hamiltonian and symbols (including time and momenta), gives the equations of motion.";
LegendreExpandTable::usage = "Expand a function in Legendre polynomials";
(*
	Stat Mech functions
*)
Sterling::usage = "Sterling approximation";
CollectByLog::usage = "Helper function which simplifies expressions with logs...";
GetSpecficHeats::usage = "Gets the specific heats.";
GetThermoInfo::usage = "Given entropy and relevant symbols, gets specific heats, other thermo quantities";
GetThermoByHelmHolts::usage = "Given helmtholtz and relevant symbols in cannonical dist, gets useful stuff";
GetDensityOfStates::usage = "Given partition function in the form of \!\(\*SubscriptBox[\(c\), \(0\)]\)*\[Beta]^N, where N<0, gives density of states";
(*
	E & M function
*)
QuadropoleMoments::Usage = "Given an integrand (where the charge is), rVector (for coordinate system), and integration function, gets the Quadropole moments";
DipoleMoments::Usage = "See QuadropoleMoments, but for dipole moments.";
(* Special Relativity *) 
FourVectorLen::Usage= "Length of a 4 vector,assuming components are timelike as \!\(\*SubscriptBox[\(X\), \(0\)]\) then space";
LenInvariant::Usage ="Given two four vectors, sets up the conditions for them being invariant";
LorentzBoostMat::Usage="Gets The Lorentz transformaton matrix for a simple boost along x";
FMuNu::Usage = "Gets the E&M \!\(\*SubscriptBox[\(F\), \(\(\[Mu]\[Nu]\)\(\\\ \)\)]\)Matrix";
(*
	Plotting options
*)
PolarPlotOpt::usage = "PolarOpt";

Begin["`Private`"];
	(*
	Functions related to stat mech
	*)
	Sterling[x_] :=  x*Log[x]-x
	(* 
	Inefficient helper function for logs, see:
	http://mathematica.stackexchange.com/questions/22705/simplify-expressions-with-log
	*)
	CollectByLogHelper[expr_]:=Module[{rule1,rule2,a,b,x},
		rule1=Log[a_]+Log[b_]->Log[a*b];
		rule2=x_*Log[a_]->Log[a^x];
		(expr/.rule1)/.rule2/.rule1/.rule2
	];
	CollectByLog[expr_] := Nest[CollectByLogHelper,expr,Depth[expr]]
	GetSpecficHeats[EnergyByTemp_,PressureByTemp_,VolumeSymbol_,TempSymbol_]:=
		Module[{CPress,CVol},
		(*
		See pp 9, eq 17 and 18 
		*)
		CPress=D[EnergyByTemp+PressureByTemp*VolumeSymbol,TempSymbol];
		CVol=D[EnergyByTemp,TempSymbol];
		{"\!\(\*SubscriptBox[\(C\), \(P\)]\)" -> CPress, "\!\(\*SubscriptBox[\(C\), \(V\)]\)" -> CVol,"RatioPressOverVol"->CPress/CVol }
	];
	(* Function to get all of specific heats and such... *)
	GetThermoInfo[entropy_,PressureEqOfState_,EntropySymbol_:S,EnergySymbol_:Subscript[E, sys],VolumeSymbol_:V,TempSymbol_:T]:=
		Module[
		{SysEnergy,EnergyByTemp,SysE,Pressure,PressureByTemp,CPress,CVol,S},
		SysEnergy = EnergySymbol /. (Solve[entropy == EntropySymbol,EnergySymbol][[1]]);
		(* 
			Solve for energy in terms of temperature, pp 8, 1.3.10 
		*)
		EnergyByTemp = EnergySymbol /. Solve[D[entropy,EnergySymbol] ==1/TempSymbol,EnergySymbol][[1]];
		(* solve for presure, using equation of state (e.g. only V^(2/3) *E^2 appears, cf pp11, 1.4.10, where it is linear in E), only for onlding S and N consant*)
		SysE = EnergySymbol/. Solve[PressureEqOfState,EnergySymbol][[1]];
		(* cf 1.4.25, pp 15, write the pressure in terms of energy and volume *)
		(* 
			Pressure is minus the volume gradient of the energy
		*)
		Pressure = -(D[SysE,VolumeSymbol]/SysE) * EnergySymbol;
		PressureByTemp = Simplify[Pressure /. {EnergySymbol -> EnergyByTemp}];
		(* specific heat at const pressure *)
		Join[GetSpecficHeats[EnergyByTemp,PressureByTemp,VolumeSymbol,TempSymbol],
		{"EnergyFromEntropy" -> SysEnergy,
		"StateEnergy" -> SysE,
		"StatePressure" -> Pressure,
		"PressureByTemp" -> PressureByTemp,
		"EnergyByTemp" -> EnergyByTemp}]
	];
	GetThermoByHelmHolts[HelmHoltzA_,VolSym_,TempV_]:=
		Module[ {Press,EntropyS,InternalE},
		(* Pressure, beale pp56, 3.5.12 *)
		Press = -D[HelmHoltzA,VolSym];
		(* Entropy, ibid 3.5.13 *)
		EntropyS = -D[HelmHoltzA,TempV];
		(* Internal energy *)
		InternalE = FullSimplify[HelmHoltzA+EntropyS*TempV];
		{"Pressure" -> Press, "EntropyS" -> EntropyS,"EnergyU" -> InternalE}
	];
	GetDensityOfStates[CoeffBeta_,BetaPower_,EnergySymbol_:Subscript[E, sys]] := Module[{n},
		(* 
		Assuming Beale pp54, 3.4.7 and 57, 3.5.20-21, given an energy and power for beta,
		assuming the form of 3.5.21, gives the density of states
		Args: 
			CoeffBeta:  the Coefficient in the partition function, assumed like (CoeffBeta*Beta^BetaPower)
			BetaPower: Power of beta, N. Assumed < 0
			EnergySymbol: The symbol to use for the energy
		*) 
		(* assume beta is a negative power, use 3.5.21 to set n+1 = -N \[Rule]  n = -\[Beta]-1*)
		n = (-BetaPower) - 1;
		CoeffBeta*EnergySymbol^n/(Factorial[n])
	];

	(* 


	Functions related to E&M


	*)
(* Function for getting the quadropole moment, see pp414, 9.41. *)
	Quad[integ_,rVect_,IntegFunc_,\[Alpha]_,\[Beta]_] := Module[{delta,always,integrand},
		delta = Total[rVect^2];
		always=3*rVect[[\[Alpha]]]*rVect[[\[Beta]]];
		integrand = If[\[Alpha] == \[Beta],always-delta,always] * integ;
		IntegFunc[integrand]
	];
	QuadropoleMoments[integ_,rVect_,integFunc_]:=
		Module[{tensor,nV},
			nV = Length[rVect];
			tensor = Table[Quad[integ,rVect,integFunc,i,j],{i,1,nV},{j,1,nV}]
		];
	(* Function For getting dipole moments,  see e.g. 9.17, pp 410 *)
	DipoleMoments[integ_,rVect_,integFunc_]:=
		Module[{nV,Moments},
		nV = Length[rVect];
		Moments = Table[integFunc[rVect[[i]]*integ],{i,1,nV}]
	];
	
	LagrangeSolve[L_,q_,t_]:=Solve[D[D[L,q'[t]],t] == D[L,q[t]],q''[t]]
	(*
	Special Relatibivity
	*)

	FourVectorLen[A_]:=A[[1]]^2 - Total[A[[2;;]]^2]
	LenInvariant[A_,B_] := Module[
		{},
		(* given two four vectors, gets the length invariants ... *)
		FourVectorLen[A] == FourVectorLen[B]
	];
(* use the lorentz tx for a boost in a single direction. follows jacskon conventions
(pp 525)
	Dir: if +1, transforming from proper frame to improper. If -1, from improprt to proper
	\[Gamma],\[Beta]: the boost parameters. Again, assuemd 1-D
 see pp 525, 11.16 *)
	LorentzBoostMat[\[Gamma]_,\[Beta]_,dir_] :=Module[
		{},
		{
 		\[Gamma]*{1,dir*\[Beta],0,0},
		\[Gamma]*{dir*\[Beta],1,0,0},
		{0,0,1,0},
		{0,0,0,1}
		}
	];
	(*
	Jackson, pp 556, Subscript[F, \[Mu]\[Nu]]
	*)
	FMuNu[E_,B_,x_,y_,z_] := Module[{},
		{
			{0,-Subscript[E, x],-Subscript[E, y],-Subscript[E, z]},
			{Subscript[E, x],0,-Subscript[B, z],Subscript[B, y]},
			{Subscript[E, y],Subscript[B, z],0,-Subscript[B, x]},
			{Subscript[E, z],-Subscript[B, y],Subscript[B, x],0}
		}
	];
	(*
	Legendre Functions. Assumes P[cos[x]]
	*)
	LegendreExpand[ToExpand_,l_,Theta_,ThetaMin_:0,ThetaMax_:Pi]:=
	Module[{},
		(* cf Jackson. pp 101, 3.23 - 3.34 *)
		Integrate[ToExpand*Sin[Theta]*LegendreP[l,Cos[Theta]],{Theta,ThetaMin,ThetaMax}]*(2l+1)/2
	];
	LegendreExpandTable[ToExpand_,MaxL_,Theta_,ThetaMin_:0,ThetaMax_:Pi] := Module[
		{toRet},
		toRet = Table[LegendreExpand[ToExpand,i,Theta,ThetaMin,ThetaMax],{i,1,MaxL}];
		toRet
		];
	(* 
		Spherical harmonics functions 
	*)
	SphereExpand[ToExpand_,L_,Theta_,Phi_,ThetaMin_:0,ThetaMax:Pi,PhiMin_:0,PhiMax_:2*Pi] := 
		Module[{integrand,mTab},
	     integrand = ToExpand*SphericalHarmonicY[i,j,Theta,Phi]*Sin[Theta];
	     mTab = Table[Integrate[integrand,{Phi,PhiMin,PhiMax},{Theta,ThetaMin,ThetaMax}],{i,0,L},{j,-i,i}];
	     Grid[mTab]
			];
(* see: http://math.stackexchange.com/questions/105153/spherical-bessel-zeros/1560386#1560386
 and Abramowitz, 1964, Ch9, pp 440,"Zeros and Their Asymptotic Expansions" *)
	SphericalBesselJZero[l_,k_]:=N[BesselJZero[l+1/2,k]]
	SphericalBesselNZero[l_,k_]:=N[BesselYZero[l+1/2,k]]
	(* Function to get the Poisson bracket of two variables:
		http://mathematica.stackexchange.com/questions/41850/how-to-define-the-poisson-bracket-in-mathematica
	 *)
		PoissonBracket[a_, b_, q_, p_] := Simplify[D[a, q]  D[b, p] - D[b, q ] D[a, p] ]
	(* 
		Moment of Intertia Functions
	*)
	(* Private function, get the components of moments of interia for discrete components *)
	MomComponentDiscrete[i_,j_,loc_,mass_]:=If [i==j,Total[loc^2]-loc[[i]]loc[[j]],loc[[i]]loc[[j]]]*mass;
	DiscreteMoment[massLoc_,mass_] := Module[{},
		Table[MomComponentDiscrete[i,j,massLoc,mass],{i,1,Length[massLoc]},{j,1,Length[massLoc]}]
		];
	(* continuous is a litte more complicated *)
	(* Single continuous component *)
	SingleContinuousMoment[mAssumptions_,volIntegral_,density_,symbols_,i_,j_]:=
		Module[{integrand,common},
			(* "common" factor to diagonal and off diagonal *)
			common = -symbols[[i]]*symbols[[j]];
			(* figure out which one we are doing *)
			integrand = density*If[i ==j,Total[symbols^2]+common,common];
			(* do the integral *)
			Assuming[mAssumptions,volIntegral[integrand]]
		];
	ContinuousMoment[mAssumptions_,volIntegral_,density_,mCoords_] := Module[{},
		(* Make the entire moment of inertia matrix (note: is symmetric*)
		Table[SingleContinuousMoment[mAssumptions,volIntegral,density,mCoords,i,j],
				{i,1,Length[mCoords]},{j,1,Length[mCoords]}]
		];
	(*
		Functions related to small oscilllations in mechanics
	*)
		SmallOscCoeff[i_,j_]:= If[i == j,1,1/2];
		SmallOscHelper[expr_,symbols_,i_,j_]:=Coefficient[expr,symbols[[i]]*symbols[[j]]]*SmallOscCoeff[i,j];
		GetOscCoeffArray[expr_,symbols_]:=Module[
			{n},
				n = Length[symbols];
				(* factor of two is pre-bult into it *)
				Table[SmallOscHelper[expr,symbols,i,j]*2,{i,1,n},{j,1,n}]
		];
		GetSecularMatrix[PE_,KE_,symbolsPE_,symbolsKE_,eig_]:=Module[
			{myPotMatrix,myKinMatrix,secular},
			(* Get the kinetic energy and potential energy *)
			myPotMatrix = Simplify[GetOscCoeffArray[PE,symbolsPE]];
			myKinMatrix = Simplify[GetOscCoeffArray[KE,symbolsKE]];
			secular = myPotMatrix - myKinMatrix * eig
		];
	(* 
		Functions for hamiltonian, classical mechanics 
		See especially Goldstein 3rd ed, pp337, eq 8.14 (Subscript[p, i]'), eq 8.36
	*)
	(* Get dL/Subscript[dq, i]'=Subscript[p, i].*) 
	GenMomenta[Lagrangian_,Symbols_,t_]:= Table[D[Lagrangian,Symbols[[i]]'[t]],{i,1,Length[Symbols]}]
	(* Create a matrix from these relations; invert to find the momenta *)
	GetMomentaCoeffs[expr_,symbols_,t_]:=Table[Coefficient[expr,symbols[[i]]'[t]],{i,1,Length[symbols]}]
	(* Solve for Subscript[q, i]' in terms pf Subscript[p, i] *)
	GetVelocitiesByMomenta[Lagrangian_,symbols_,mom_,t_,sol_:defsol,mat_:defMat,invMat_:defInv] := Module[
		{mMomentaVals,mMatrix,mMomentaSymbolic,solution,constMatrix,n,mInv,allVelSymbols},
			mMomentaVals = GenMomenta[Lagrangian,symbols,t];
			mMatrix = GetMomentaCoeffs[mMomentaVals,symbols,t];
			n = Length[symbols];
			(* get all the velocity symbols *)
			allVelSymbols = Table[symbols[[j]]'[t],{j,1,n}];
			(* for each row (momentum), get the constant term; that which isn't any taken care of by velocity *) 
			constMatrix = Table[Simplify[D[Lagrangian,allVelSymbols[[i]]]-mMatrix[[i]].allVelSymbols],{i,1,Length[symbols]}];
			(* get the symbols for the momenta *)
			mMomentaSymbolic = Join[Table[Subscript[mom, symbols[[i]]][t],{i,1,n}]] - constMatrix;
			mInv = Inverse[mMatrix];
			solution = mInv . mMomentaSymbolic ;
			(* Get the actual vector, solving for Subscript[q, i]' in terms of Subscript[p, i] *)
			$toRet = {mat -> mMatrix,invMat -> mInv, momentaSym -> Column[mMomentaSymbolic],sol -> solution }
		];
	GetVelocityRules[Lagrangian_,symbols_,mom_,t_] := Module[{mVec,mRules,solution},
		mVec = solution /. GetVelocitiesByMomenta[Lagrangian,symbols,mom,t,solution];
		(* Make rules for everything... *)
		mRules = Table[symbols[[i]]'[t] -> mVec[[i]],{i,1,Length[mVec]}]
	];
	Hamiltonian[Lagrangian_,symbols_,mom_,t_] := Module[{mRules,H,HamByTerm},
		mRules = GetVelocityRules[Lagrangian,symbols,mom,t];
		(* get the Subscript[p, i]*Subscript[q, i]* part of the hamiltonian, goldstiein 3rd ed, p339,8.20 *)
		HamByTerm = Table[Subscript[mom, symbols[[i]]][t]*symbols[[i]]'[t],{i,1,Length[symbols]}];
		(* use the rules, sum all terms in the hamiltonian *)
		H = (Total[HamByTerm] - Lagrangian) /. mRules
	];
	HamiltonsEq[myHam_,symbols_,mom_,t_] := Module[{myMomentaSym,momentaDerivSym,HEq1,HEq2},
		myMomentaSym = Table[Subscript[mom, symbols[[i]]][t],{i,Length[symbols]}];
		momentaDerivSym = Table[Subscript[mom, symbols[[i]]]'[t],{i,Length[symbols]}];
	(* Goldstein 3rd ed p344, unlablled equation, also https://en.wikipedia.org/wiki/Hamiltonian_mechanics *)
		HEq1 = Table[momentaDerivSym[[i]] == -D[myHam,symbols[[i]][t]],{i,1,Length[symbols]}];
		HEq2 = Table[symbols[[i]]'[t] == D[myHam,myMomentaSym[[i]]],{i,1,Length[symbols]}];
		Join[HEq1,HEq2]
	];
	(*
		Polar plotting options
	*)
	PolarPlotOpt[] := Module[{mRules},
		mRules = {(* Use polar grid lines (most of this is to get rid of frame-clipping stuff *) 
				PolarGridLines->Automatic,
				PolarAxes->Automatic,
				PlotRangeClipping->False,
				Frame->False,
				PlotRange->All
				}
		];
End[];

EndPackage[];
