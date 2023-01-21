%macro create_garch_1_1(inputds=,cd=,rf=,outds=);

/*
inputds: input data set with log returns of the risk factor
cd: data set with the current level of the risk factor
rf: name of the risk factor
outds: output data with the simulations of the risk factor
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
	proc model data=&inputds.(where=(date between "&startdate."d and "&enddate."d)) outparms=models.parms_&rf. 
		outspec=(env.rdenv modname = ret_&rf. modlabel="&rf. return GARCH(1,1)");
		endogenous Ret&rf.;
		parameters p0 arch0 arch1 garch1;
		Ret&rf. = p0;
		h.Ret&rf. = arch0 + arch1 * xlag(resid.Ret&rf.**2,mse.Ret&rf.)+garch1*xlag(h.Ret&rf.,mse.Ret&rf.);
		restrict 
		arch0 >= 0.00001,
		arch1 >= 0.00001,
		garch1 >= 0.00001;			
		/*arch0 + arch1 + garch1 = 1;*/
		label 
		arch0 = "Constant part of the conditional volatility"
		arch1 = "Coefficient of the lagged squared residuals"
		garch1 = "Coefficient of lagged conditional volatility";
		&rf. = zlag(&rf.)*exp(Ret&rf.);
		*Vol_&rf.=sqrt(arch0+arch1*(xlag(Ret&rf.,resid.RetAAPL)-p0)**2+garch1*zlag(Vol_AAPL));
		id date;
		errormodel Ret&rf. ~ normal(1);
		fit ret&rf. / 
			method=marquardt fiml maxiter=1000 outpredict outactual outest=models.cov&rf. out=models.res&rf. 
			outcat=(env.rdenv interval=weekday dim=1 modname=Ret&rf. modlabel="&rf. return and GARCH(1,1)");			
	quit;




%mend;
