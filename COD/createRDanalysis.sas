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
		/*
		simulation cov_sim
			method = covariance
			data = covar
			interval = weekday
			seed = 54321
			ndraw = 1007
			generator = pseudo
			horizon = &h.;
		*/
		simulation model_sim
			method = montecarlo
			data = historic_prices
			interval = weekday
			errmod = normal
			seed = 12345
			ndraw = 250
			generator = pseudo
			horizon = &h.;
		/* (30MAR2023,EP) */
		SIMULATION 	Potential_Exposure_Sim
					method = covariance
					data = covar
					ndraw = 1007
					gen = twister
					seed = 54321
					interval = weekday
					horizon = &h.
					kind = EXPOSURE;
		/* (11MAY2023,EP) Cash flow analysis */
		cashflow	CFAnalysis
					analysis = traditional /*cov_sim*/
					buckettype = simple
					evaldate = "&baseDate."d;


	env save;
run;
