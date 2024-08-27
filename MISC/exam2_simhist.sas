
options cmplib=work.myfunc;


/*
Valuation parameters
*/
/* Valuation date */
%let basedate=15AUG2022;
/* Valuation currency */
%let valCurrency=MXN;
/* Start and end date to estimate the covariance matrix */
%let startdate=15AUG2018;
%let enddate=15AUG2022;
/* Horizon of the VaR*/
%let h=1;
/* Confidence of the VaR*/
%let alpha=0.95;
/* Confidence of the VaR (%)*/
%let alpha_pts=95;
/* Percentile definition */
%let perc_def=4;
/* Number of stochastic simulations */
%let nsim=5000;
/*
Current risk factors data
*/

proc sql;
	create table work.currentdata as
	select *
	from work.transform_t
	where date="&basedate."d
	;
quit;

/* Transposing the current risk factors data */
proc transpose data=WORK.CURRENTDATA out=work.CURRENTDATA_t prefix=value;
run;

/*
Enrichment of the portfolio data
*/

proc sql;
	create table work.portfolio_1 as
	select 
	a.*
	, b.name as fx
	, c.value1 as price	
	, d.value1 as fx_price
	, "&valCurrency." as valCurrency
	/* Adding the identifier of the foreign exchanges */
	from work.portfolio a left join work.configuration_rf b
	on (a.currency ne "&valCurrency" and a.currency=b.fromcur)
	/* Adding the risk factor value */
	left join work.currentdata_t c
	on (a.insttype = "Stock" and a.ref_price=c._name_)
	/* Adding the value of the foreign exchanges */
	left join work.currentdata_t d
	on (a.currency ne "&valCurrency" and b.name=d._name_)
	;
quit;

/* Validation: Looking for duplicates */
proc datasets library=work nolist nodetails;
	modify portfolio_1;
	index create mykey=(instid shortposition alposition) / nomiss unique;
quit;

/* Valuation */

proc fcmp outlib=work.myfunc.trial;

	function Stock(Currency$,price,valCurrency$,FX_price);
	/*
	Purpose: To compute the value of a stock
	Currency$: code of the native currency of the stock
	price: price of the stock on its native currency
	valCurrency$: code of the valuation currency of the stock
	FX_price: foreign exchange from native currency to the valuation currency
	*/

		value=0;

		if compress(upcase(Currency))  = valCurrency then value = price;	
		else value = price * FX_price;
		return(value);

	endsub;

run;



/* Computing the market value */
data work.portfolio_mkt_value;
	set work.portfolio_1;
	format value mkt_value dollar20.2;
	label value="Market value";
	if insttype = "Stock" then
		do;
			value=Stock(Currency,price,valCurrency,FX_price);
			mkt_value=value*holding*ALposition*ifn(shortPosition=0,1,ifn(shortPosition=1,-1,.));
		end;
run;

proc print data=work.portfolio_mkt_value;
run;

title "Portfolio market value";
proc sql;
	select sum(mkt_value) format=dollar20.2
	from work.portfolio_mkt_value
	;

quit;
title;

proc sql noprint;
	select sum(mkt_value) format=20.6 into: W
	from work.portfolio_mkt_value
	;
quit;

%put &=W.;

/* Identiying the risk factors measured with ratio */
proc sql;
	select NAME into: rf_ratio separated by " "
	from work.configuration_rf 
	where mlevel="RATIO"
	;
	select catx("",NAME,"=",NAME,"/lag&h.(",NAME,");") into: rf_ratio_form separated by " "
	from work.configuration_rf 
	where mlevel="RATIO"
	;
quit;


/* Computing the changes of the risk factors */
data work.rf_changes_ratio;
	set work.transform_t(keep=date &rf_ratio. where=(date between "&startdate."d and "&enddate."d));
	&rf_ratio_form.;
run;

/* Copying current data */
data work.currentdata_ratio;
	set work.currentdata;
run;


/* Appending current data and the changes of the risk factors*/
proc append base=work.currentdata_ratio data=work.rf_changes_ratio force;
run;


/* Computing the market states of the risk factors */
proc iml;
	/* Reading the currentdata_ratio data set */
	use work.currentdata_ratio;
	read all var _NUM_ into currentdata_ratio[colname=numVars];
	close work.currentdata_ratio; 

	rf_names=contents('work','currentdata_ratio');

	/* Number of changes */	
	nchanges=nrow(currentdata_ratio)-1-&h.;

	/* Vector of current data */
	cd=currentdata_ratio[1,];

	/* Making useful matrices to compute the market states of the risk factors */
	cd=repeat(cd,nchanges);
	aux=repeat(1,nchanges);
	cd[,1]=aux;
	changes=currentdata_ratio[(&h.+1+1):(nchanges+1+&h.),];

	/* Computing the market states of the risk factors */
	mktstat=cd#changes;

	/* Computing the market states of the risk factors */
	create work.mktstat_ratio from mktstat[colname=rf_names];
	append from mktstat;
	close work.mktstat_ratio;
quit;

proc datasets lib=work nodetails nolist;
	modify mktstat_ratio;
	format date date9.;
quit;

/* Computing the number of market states */
proc sql noprint;
	select count(*) into: n_states
	from work.mktstat_ratio
	;
quit;

%put &=n_states;

/* Transposing the market states matrix */
proc transpose data=WORK.mktstat_ratio out=work.mktstat_ratio_t prefix=value;
run;

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


/* As the log is big, we send it to a file */
/* Change the path to adjust it to your user */
filename myoutput "/shared/home/perez-jose@lasallistas.org.mx/riesgos_financieros/mylog_&SysDate._%sysfunc(time(),time8.0).txt";
proc printto log=myoutput;
run;

%mkt_value(ds_portfolio=work.portfolio,ds_configrf=work.configuration_rf,ds_mkt_state=work.mktstat_ratio_t,n_mktstate=&n_states.,valCur=&valCurrency.,ds_out=work.allprice);

/* We return the log to the usual output */
proc printto;
run;



/* Computing the profits and losses */
proc sql;
	create table work.p_l as
	select 
	a.*
	, b.mkt_state
	, b.value as value_stat
	, b.mkt_value as mkt_value_stat
	, sum(a.mkt_value,-b.mkt_value) as p_l label='P&L' format=dollar30.2 
	from work.portfolio_mkt_value a left join work.allprice b
	on (a.instid=b.instid and a.shortposition=b.shortposition and a.alposition=b.alposition)
	order by mkt_state, instid, shortposition, alposition
	;
quit;

/* Computing the portfolio P&L for each market state */
proc means data=work.p_l sum noprint;
	var p_l;
	by mkt_state;
	output out=work.p_l_summ sum=p_l;
run;

/* Computing the value at risk */
proc univariate data=work.p_l_summ pctldef=&perc_def. noprint;
	var p_l;
	output out=work.percentiles pctlpts=&alpha_pts. pctlpre=p_;
run;

proc sql;
	select * into: var
	from work.percentiles
	;
quit;

%put &=var.;

/* Computing the conditional value at risk */
proc sql;
	select mean(p_l) into: cvar
	from work.p_l_summ
	where p_l > &var.
	;
quit;


/* Plot of the distribution */
title 'Distribución de P&L con Simulación Histórica';
proc sgplot data=work.p_l_summ;
 	histogram p_l / fillattrs=(color=blue transparency=0.97);
 	density p_l / lineattrs=(color=red);
 	refline &var. / axis=x lineattrs=(color=green pattern=15) label = ("VaR=&VaR.");
 	refline &cvar. / axis=x lineattrs=(color=brown pattern=15) label = ("CVaR=&CVaR.");
	xaxis grid;
	yaxis grid;
run;
title;

