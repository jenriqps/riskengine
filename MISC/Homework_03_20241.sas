/* Import */

proc sql;
%if %sysfunc(exist(WORK.IMPORT)) %then %do;
    drop table WORK.IMPORT;
%end;
%if %sysfunc(exist(WORK.IMPORT,VIEW)) %then %do;
    drop view WORK.IMPORT;
%end;
quit;



FILENAME REFFILE DISK '/shared/home/perez-jose@lasallistas.org.mx/riesgos_financieros/Homework_03_20241.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.IMPORT;
	GETNAMES=YES;
	sheet=sheet2;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;

/* Log return */

data work.logreturn;
	set work.import;
	logret=log(close/lag(close));
run;	

title "Daily Returns";
proc sgplot data=work.logreturn;
	series x=Date y=logret;
	xaxis grid;
	yaxis grid label="Daily return";
	keylegend / location=inside;
run;
title;

/* GARCH models */

ods output FitSummary=FIT_SUMMARY ParameterEstimates = PARAMETER_ESTIMATES ;
proc autoreg data=work.logreturn maxit=200 optimizer=nlp;
	"ARCH(p=1)": model logret=/ garch=(q=1) noint;
	output out=results_arch1 cev=v;
	"ARCH(p=2)": model logret=/ garch=(q=2) noint;
	output out=results_arch2 cev=v;
	"GARCH(p=1,q=1)": model logret=/ garch=(q=1,p=1) noint;
	output out=results_garch_1_1 cev=v;
	"GARCH(p=1,q=2)": model logret=/ garch=(q=1,p=2) noint;
	output out=results_garch_1_2 cev=v;
	"GARCH(p=2,q=1)": model logret=/ garch=(q=2,p=1) noint;
	output out=results_garch_2_1 cev=v;
	"GARCH(p=2,q=2)": model logret=/ garch=(q=2,p=2) noint;
	output out=results_garch_2_2 cev=v;
run;

/* Best model */
proc sql;
	select 
	model
	, label2
	, nvalue2
	from fit_summary
	where label2="AICC"
	;
quit;


proc sql;
	create table work.var_cond as
	select a.date
	, a.v as variance label="Conditional variance with GARCH(1,1)"
	, (252*a.v)**0.5 as vol label="Annual volatility"
	from work.results_garch_1_1 a 
	;
	select *
	from work.var_cond
	where date = "08SEP2023"d
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

