/*****************************************************************************

   NAME: runRDproject.sas

   PURPOSE: To run the Risk Dimensions analysis

   INPUTS: -

   NOTES: -

 *****************************************************************************/


proc risk;
	env open="&rdenv.";
	project marketrisk
						analysis=(HistSim delta_sim cov_sim model_sim) 
						currency=MXN 
						data = (currentData historic_prices covar)
						options=(alpha = &conf. instvals simstates allstates allprice simstat) 
						models=(RetAAPL RetAMXL RetJPM RetUSDMXN)
						portfolio=all_deals_list
						rundate="&baseDate."d ;
	runproject marketrisk out=mktrisk;
	env save;
run;