(* ::Package:: *)

BeginPackage["PhysicsPackage`"];
LagrangeSolve::usage = "Solve Lagrangian 'L' for q''[t]";

Begin["`Private`"];
	LagrangeSolve[L_,q_,t_]:=Solve[D[D[L,q'[t]],t] == D[L,q[t]],q''[t]]
End[];

EndPackage[];



