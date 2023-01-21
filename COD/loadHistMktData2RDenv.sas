/*****************************************************************************

NAME: loadHistPertMktData2RDenv.sas

PURPOSE: To load the historical market risk factors to the Risk Dimensions environment

INPUTS: tord.histMatrix

NOTES:

 *****************************************************************************/

proc risk;
	env open="&rdenv.";
	marketdata historic_prices file=tord.histMatrix type=timeseries 
		interval=weekday;
	env save;
run;