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
						options=(outall) 
						rundate="&baseDate."d;
	runproject MtM_project out=val;
	env save;
run;