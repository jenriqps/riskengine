/**********************************************************************
 * Notas de Riesgos Financieros;
 * Jose Enrique Perez ;
 * Licenciatura en Actuaría;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/

/* Estimation an simulation of a GARCH(p=1,q=1) model por each risk factor */
%create_garch_1_1(inputds=work.transform,cd=work.currentdata,rf=AAPL,outds=mktstat_AAPL);
%create_garch_1_1(inputds=work.transform,cd=work.currentdata,rf=AMXL,outds=mktstat_AMXL);
%create_garch_1_1(inputds=work.transform,cd=work.currentdata,rf=JPM,outds=mktstat_JPM);
%create_garch_1_1(inputds=work.transform,cd=work.currentdata,rf=USDMXN,outds=mktstat_USDMXN);

/* Joining all simulations in one data set */
proc sql;
	create table work.mktstat as
	select 
	a._rep_
	, a.AAPL
	, b.AMXL
	, c.JPM
	, d.USDMXN
	from mktstat_AAPL a inner join mktstat_AMXL b
	on (a._rep_=b._rep_) inner join mktstat_JPM c
	on (a._rep_=c._rep_) inner join mktstat_USDMXN d
	on (a._rep_=d._rep_)
	;
quit;

/* Computing the number of market states */
proc sql noprint;
	select count(*) into: n_states
	from work.mktstat
	;
quit;

%put &=n_states;

/* Transposing the market states matrix */
proc transpose data=WORK.mktstat out=work.mktstat_t prefix=value;
run;

/* As the log is big, we send it to a file */
/* Change the path to adjust it to your user */
filename myoutput "/shared/home/perez-jose@lasallistas.org.mx/riesgos_financieros/mylogMC_&SysDate._%sysfunc(time(),time8.0).txt";
proc printto log=myoutput;
run;

%mkt_value(ds_portfolio=work.portfolio,ds_configrf=work.configuration_rf,ds_mkt_state=work.mktstat_t,n_mktstate=&n_states.,valCur=&valCurrency.,ds_out=work.allprice);

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

proc sql noprint;
	select * into: var
	from work.percentiles
	;
quit;

%put &=var.;

/* Computing the conditional value at risk */
proc sql noprint;
	select mean(p_l) into: cvar
	from work.p_l_summ
	where p_l > &var.
	;
quit;


/* Plot of the distribution */
title 'Distribución de P&L con Simulación Monte Carlo';
proc sgplot data=work.p_l_summ;
 	histogram p_l / fillattrs=(color=blue transparency=0.97);
 	density p_l / lineattrs=(color=red);
 	refline &var. / axis=x lineattrs=(color=green pattern=15) label = ("VaR=&VaR.");
 	refline &cvar. / axis=x lineattrs=(color=brown pattern=15) label = ("CVaR=&CVaR.");
	xaxis grid;
	yaxis grid;
run;
title;


