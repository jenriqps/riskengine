/**********************************************************************
 * Notas de Riesgos Financieros;
 * Jose Enrique Perez ;
 * Licenciatura en Actuaría;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/

/*
Exploración de la serie
*/

ods noproctitle;
ods graphics / imagemap=on;

proc sort data=WORK.TRANSFORM(keep=date RetJPM) out=Work.preProcessedData;
	by date;
run;

proc timeseries data=Work.preProcessedData seasonality=7 plots=(series 
		histogram corr);
	id date interval=Day;
	var RetJPM / accumulate=none transform=none;
run;

proc delete data=Work.preProcessedData;
run;

/*
Ajuste de los modelos
*/

ods output FitSummary=FIT_SUMMARY ParameterEstimates = PARAMETER_ESTIMATES ;
proc autoreg data=work.transform(keep=date RetJPM) maxit=200 optimizer=nlp;
	"ARCH(p=1)": model RetJPM=/ garch=(q=1) noint;
	output out=results_arch1 cev=v;
	"ARCH(p=2)": model RetJPM=/ garch=(q=2) noint;
	output out=results_arch2 cev=v;
	"GARCH(p=1,q=1)": model RetJPM=/ garch=(q=1,p=1) noint;
	output out=results_garch_1_1 cev=v;
	"GARCH(p=1,q=2)": model RetJPM=/ garch=(q=1,p=2) noint;
	output out=results_garch_1_2 cev=v;
	"GARCH(p=2,q=1)": model RetJPM=/ garch=(q=2,p=1) noint;
	output out=results_garch_2_1 cev=v;
	"GARCH(p=2,q=2)": model RetJPM=/ garch=(q=2,p=2) noint;
	output out=results_garch_2_2 cev=v;
run;


proc sql;
	create table work.var_cond as
	select a.date
	, a.v as variance label="Conditional variance with GARCH(1,1)"
	, (252*a.v)**0.5 as vol label="Annual volatility"
	from work.results_garch_1_1 a 
	;
quit;


ods graphics / reset width=6.4in height=4.8in imagemap noborder;

proc sort data=work.var_cond out=_SeriesPlotTaskData;
	by date;
run;

proc sgplot data=_SeriesPlotTaskData;
	title height=14pt "Volatilidad";
	series x=date y=vol /;
	xaxis grid;
	yaxis grid;
run;

ods graphics / reset;
title;

proc datasets library=WORK noprint;
	delete _SeriesPlotTaskData;
run;