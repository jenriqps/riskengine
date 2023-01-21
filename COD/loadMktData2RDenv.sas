
/*****************************************************************************

   NAME: loadMktData2RDenv.sas

   PURPOSE: Load the current market data to the Risk Dimensions environment

   INPUTS: toRD.CurrentData, tord.market_covar

   NOTES: 

 *****************************************************************************/


* Current data;
proc risk;
	env open = "&rdenv.";
		marketdata currentData file = toRD.CurrentData type = Current;
		marketdata covar file = tord.market_covar type = covariance interval = weekday;
	env save;
run;

