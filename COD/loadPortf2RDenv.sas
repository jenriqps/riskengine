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
		/* (19MAY2023,EP) */
        instdata Mortgage_Data file = tord.mortgage format = simple;
       	instdata MortgageCF_Data file = tord.mortgage_cf format = cash_flow;

		* We list the portfolio and read them;
		sources all_deals_list (equity Corp_Bond);
		read sources=all_deals_list out=all_deals_list;
		/* (27MAR2023,EP) */
		sources Bond_Data_File Corp_Bond;
		read sources=Bond_Data_File out=Bond_Data_File;
		/* (19MAY2023,EP) */
		sources Mortgage_Data (Mortgage_Data);
		read sources = Mortgage_Data out = Mortgage_Data_File;
		sources MortgageCF_Data (MortgageCF_Data);
		read sources = MortgageCF_Data out = MortgageCF_Data_File;
	env save;
run;