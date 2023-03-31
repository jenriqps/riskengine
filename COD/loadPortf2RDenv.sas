/*****************************************************************************

   NAME: loadPortf2RDenv.sas

   PURPOSE: To load the portfolios to the Risk Dimensions environment

   INPUTS: toRD.portfolio

   NOTES: 

 *****************************************************************************/


proc risk;
	env open="&rdenv.";
		instdata equity file=toRD.portfolio format=simple;
		/* (27MAR2023,EP) */
		instdata Corp_Bond file=toRD.corp_bond_portfolio format=simple;
		* We list the portfolio and read them;
		sources all_deals_list equity;
		read sources=all_deals_list out=all_deals_list;
		/* (27MAR2023,EP) */
		sources Bond_Data_File Corp_Bond;
		read sources=Bond_Data_File out=Bond_Data_File;
	env save;
run;