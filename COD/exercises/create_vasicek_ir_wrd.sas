%MACRO create_vasicek_ir_wrd(inputds=,cd=,rf=,outds=);

/*
inputds: input data set with the interest rates
cd: data set with the current level of the risk factor
rf: name of the risk factor
outds: output data with the simulations of the risk factor
Note: This macro works without sending information to Risk Dimensions
*/
	/* Joining the current level and logreturn of the risk factor */
	data work.toforecast;
		set &inputds.(where=(date="&basedate."d));
		set &cd.;
	run;

	/* Future date to forecast until the horizon */
	data work.toforecast2;
		format date date9.;
		do i=1 to &h.;
		date = "&basedate"d+i; output;
		end;
	run;

	/* Appending the two previous data sets */
	proc append base=work.toforecast data=work.toforecast2 force;
	run;

	/* Estimation and simulation of the Vasicek model */
	proc model data=&inputds.(where=(date between "&startdate."d and "&enddate."d)) outparms=models.parms_&rf.;
		parameters kappa theta;
		&rf. = lag(&rf.) + kappa  * (theta - lag(&rf.));
		label 
		kappa = "Speed of Mean Reversion"
		theta = "Long term Mean";
		id date;
	   	fit &rf. / fiml maxiter=1000 outresid outpredict 
		outactual outcov outs=models.s&rf. outest=models.cov&rf. out=models.res&rf.;
		solve &rf. / data=work.toforecast estdata=models.cov&rf. sdata=models.s&rf. random=&nsim. seed=321 out=&outds. forecast time=date; 		
	quit;

%MEND;
