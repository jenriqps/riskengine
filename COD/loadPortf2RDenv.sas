/*****************************************************************************

   NAME: loadPortf2RDenv.sas

   PURPOSE: To load the portfolios to the Risk Dimensions environment

   INPUTS: toRD.portfolio

   NOTES: 

 *****************************************************************************/


proc risk;
	env open="&rdenv.";
		instdata equity file=toRD.portfolio format=simple;
		* We list the portfolio and read them;
		sources all_deals_list equity;
		read sources=all_deals_list out=all_deals_list;
	env save;
run;