/*****************************************************************************

NAME: valuateRDenv.sas

PURPOSE: To compute the market value of the portfolio

INPUTS: -

NOTES: -

 *****************************************************************************/


proc risk;
	env open="&rdenv.";
	project MtM_project portfolio=all_deals_list
						currency=MXN 
						data=currentData
						rftrans = (static_parameter_matrix)
						options=(outall) 
						rundate="&baseDate."d;
	runproject MtM_project out=val;

	/* (27MAR2023,) */

	CROSSCLASS CountPart (company);

	CUREXPOSURE Current_Exp;

	PROJECT CurExp	portfolio = Bond_Data_File
						analysis = Current_Exp
						data	= (currentData)
						rftrans = (static_parameter_matrix)
						crossclass = CountPart
						options = (outall)
						rundate = "&baseDate."d;

	RUNPROJECT CurExp outlib = C04_A;


	env save;
run;