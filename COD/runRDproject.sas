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
						options=(alpha = &conf. instvals simstates allstates allprice simstat simvalue) 
						models=(RetAAPL RetAMXL RetJPM RetUSDMXN)
						portfolio=all_deals_list
						rundate="&baseDate."d ;
	runproject marketrisk out=mktrisk;
	/* (30MAR2023,EP) */
	PROJECT 	Potential_Exposure
				data = CurrentData
				rftrans = (static_parameter_matrix)
				portfolio = Bond_Data_file
				analysis = Potential_Exposure_Sim
				currency = USD
				options = (alpha =&conf. outall) 
				rundate = "&baseDate."d;

	RUNPROJECT Potential_Exposure outlib = potexp;


	env save;
run;