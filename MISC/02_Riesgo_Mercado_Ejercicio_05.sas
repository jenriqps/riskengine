/**********************************************************************
 * Notas de Riesgos Financieros;
 * Jose Enrique Perez ;
 * Licenciatura en Actuaría;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/

ods graphics / reset width=6.4in height=4.8in imagemap noborder;


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

