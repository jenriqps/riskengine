/*****************************************************************************

   NAME: createRDanalysis.sas

   PURPOSE: To create the Risk Dimensions analysis

   INPUTS: -

   NOTES: -

 *****************************************************************************/


proc risk;
	env open="&rdenv.";
		simulation HistSim 
			method=historical 
			data=historic_prices 
			interval=weekday 
			startdate="&startdate."d 
			enddate="&enddate."d;
		deltanormal delta_sim 
			data = covar
			interval = weekday;
		simulation cov_sim
			method = covariance
			interval = weekday
			seed = 54321
			ndraw = 1007
			generator = pseudo
			horizon = &h.;
		simulation model_sim
			method = montecarlo
			data = historic_prices
			interval = weekday
			errmod = normal
			seed = 12345
			ndraw = 1007
			generator = pseudo
			horizon = &h.;
	env save;
run;
