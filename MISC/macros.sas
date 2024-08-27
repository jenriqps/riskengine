
%macro mkt_value(ds_portfolio=,ds_configrf=,ds_mkt_state=,n_mktstate=,valCur=,ds_out=);
/*
ds_portfolio: portfolio data set
ds_configrf: configuration of risk factors data set
ds_mkt_state: market states risk factors data set
n_mktstate: number of market states
valCur: currency valuation of the portfolio
ds_out: output data set
*/
	
	%do i=1 %to &n_mktstate.;
		/* Enrichment of the portfolio data set */
		proc sql noprint;
			create table work.portfolio_1 as
			select 
			&i. as mkt_state label="Market state"
			, a.*
			, b.name as fx
			, c.value&i. as price	
			, d.value&i. as fx_price
			, "&valCur." as valCurrency
			/* Adding the identifier of the foreign exchanges */
			from &ds_portfolio. a left join &ds_configrf. b
			on (a.currency ne "&valCur." and a.currency=b.fromcur)
			/* Adding the risk factor value */
			left join &ds_mkt_state. c
			on (a.insttype = "Stock" and a.ref_price=c._name_)
			/* Adding the value of the foreign exchanges */
			left join &ds_mkt_state. d
			on (a.currency ne "&valCur." and b.name=d._name_)
			;
		quit;
		
		/* Valuation */
		
		/* Computing the market value */
		data work.portfolio_hs&i.;
			set work.portfolio_1;
			format value mkt_value dollar20.2;
			label value="Market value";
			if insttype = "Stock" then
			do;
			value=Stock(Currency,price,valCurrency,FX_price);
			mkt_value=value*holding*ALposition*ifn(shortPosition=0,1,ifn(shortPosition=1,-1,.));
			end;
		run;

		%if &i.=1 %then
			%do;
				data &ds_out.;
					set work.portfolio_hs&i.;
				run;
			%end;
		%else
			%do;
				proc append base=&ds_out. data=work.portfolio_hs&i.;
				run;
			%end;

		/* Deleting temporal data sets */
		proc datasets lib=work nodetails nolist;
			delete portfolio_hs&i.;
		quit;

	%end;

	/* Deleting temporal data sets */
	proc datasets lib=work nodetails nolist;
		delete portfolio_1;
	quit;


%mend;

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
	proc model data=&inputds.(where=(date between "&startdate."d and "&enddate."d)) outparms=work.parms_&rf.;
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
		method=marquardt fiml maxiter=1000 outpredict outactual outcov outs=s outest=work.cov&rf. out=work.res&rf.;		
		solve Ret&rf. &rf. / data=work.toforecast estdata=cov&rf. sdata=s random=&nsim. seed=321 out=monte&rf. forecast time=date;
	quit;

	/* Output data set only with the simulations */
	proc sql;
		create table &outds. as
		select 
		_REP_
		, &rf.
		from work.monte&rf.
		where date = "&basedate."d+&h. and _type_ = "PREDICT" and _mode_="FORECAST"
		;
	quit;



%mend;

