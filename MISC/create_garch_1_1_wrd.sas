%macro create_garch_1_1_wrd(inputds=,cd=,rf=,outds=);

/*
inputds: input data set with log returns of the risk factor
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

	/* Estimation and simulation of the GARCH(1,1) model */
	proc model data=&inputds.(where=(date between "&startdate."d and "&enddate."d)) outparms=models.parms_&rf.;
		parameters arch0 arch1 garch1;
		Ret&rf. = intercept;
		h.Ret&rf. = arch0 + arch1 * xlag(resid.Ret&rf.**2,mse.Ret&rf.)+garch1*xlag(h.Ret&rf.,mse.Ret&rf.);
		label 
		arch0 = "Constant part of the conditional volatility"
		arch1 = "Coefficient of the lagged squared residuals"
		garch1 = "Coefficient of lagged conditional volatility";
		&rf. = zlag(&rf.)*exp(Ret&rf.);
		id date;
		fit ret&rf. / method=marquardt fiml 
		maxiter=1000 outpredict outactual outcov outs=models.s&rf. outest=models.cov&rf. out=models.res&rf.;	
		solve Ret&rf. &rf. / data=work.toforecast estdata=models.cov&rf. sdata=models.s&rf. random=&nsim. seed=321 out=&outds. forecast time=date; 		
	quit;




%mend;
