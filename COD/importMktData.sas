/*****************************************************************************
   NAME: importMktData.sas
   PURPOSE: To import the market data file
   INPUTS: market_data.xlsx
   NOTES: -
 *****************************************************************************/


/* Cambia la siguiente ruta para que coincida con la de tu usuario */
%include "&rootcod./macros/inhabilMX.sas";
%include "&rootcod./macros/create_garch_1_1.sas";


proc sql;
%if %sysfunc(exist(WORK.IMPORT)) %then %do;
    drop table WORK.IMPORT;
%end;
%if %sysfunc(exist(WORK.IMPORT,VIEW)) %then %do;
    drop view WORK.IMPORT;
%end;
quit;

FILENAME REFFILE DISK "&rootdat./input/market_data.xlsx";

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.IMPORT;
	SHEET=stock;
	GETNAMES=YES;
RUN;

/* (27MAR2023,EP) */

FILENAME REFFILE DISK "&rootdat./input/parammat_static.xlsx";

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=toRD.parammat_static;
	GETNAMES=YES;
RUN;


options cmplib=work.myfunc;

/*
Identificación de las fechas en que se calcularán los rendimientos
*/

%let n_sim_mx = 100000;
%let start_mx = 01JAN2007;


proc fcmp outlib=work.myfunc.trial;
	%set_InhabilMX();
run;

data work.Holiday_LIST_MX(drop=i);
	length holiday_list_id $ 32 holiday_dt 8 holiday_desc $ 100;
	format holiday_dt date9.;
	do i=0 to &n_sim_mx.;
		holiday_list_id = "MX";
		holiday_dt = "&start_mx."d + i;
		holiday_desc = "";
		if NoLabMX(holiday_dt) = 1 or weekday(holiday_dt) = 1 or weekday(holiday_dt) = 7 then
		output;
	end;
run;

data work.dates;
	format date date9.;
	do date="&startdate."d to "&enddate."d by 1;
		output;
	end;
run;

proc sql;
	create table work.dates_2 as
		select *
		from work.dates
		where date not in  (select holiday_dt from work.Holiday_LIST_MX)
		;
quit;


/*
Procesamiento de las series históricas de precios
*/

proc sql;
	create table work.transform_t as
		select *		
		from work.dates_2 a left join  work.import b on (a.date=b.date)
		;
quit;

/* (EP,05SEP2022) Identifying missing values */
title "Looking for missing values in the historial series of the risk factors (original data)";
ods select MissingValues;
proc  univariate data=work.transform_t;
run;
title;

/* (EP,05SEP2022) Completing missing values */

proc expand data=work.transform_t out=toRD.histMatrix method=step;
	id date;	
run;


/* (EP,05SEP2022) Identifying missing values */
title "Looking for missing values in the historial series of the risk factors (transformed data)";
ods select MissingValues;
proc  univariate data=toRD.histMatrix;
run;
title;

/* (03SEP2023,EP) */
proc contents data=toRD.histMatrix out=work.contents noprint;
run;

proc sql noprint;
	select compress(name)||"=log("||compress(name)||"/lag&h.("||compress(name)||")); " into: logret separated by " "
	from work.contents
	where compress(name) ne "date" 
	;
quit;

* Computing the daily returns;
data work.transform;
	set toRD.histMatrix;
	if date >= "01AUG1986"d then 
	do;
	&logret.;
	end;
run;	


/*
Current risk factors data
*/

proc sql;
	create table toRD.currentdata as
	select *
	from work.transform_t
	where date="&basedate."d
	;
quit;

/* Covariance matrix */

/* Computing the covariances */
proc corr data=WORK.transform(drop=date) nocorr cov vardef=n nosimple noprob outp=work.cov_matrix	plots=none noprint;
run;

proc sql;
	create table tord.market_covar as
		select *
		from work.cov_matrix
		where _type_ = "COV"
		;
quit;

/* (04SEP2023,EP) */

proc sql noprint;
	select "Ret"||compress(name)||"="||compress(name)||"; " into: logret2 separated by " "
	from work.contents
	where compress(name) ne "date" 
	;
quit;

data work.transform;
	set work.transform;
	&logret2.;
run;



/* Estimation an simulation of a GARCH(p=1,q=1) model por each risk factor */
* Data set with the risk factors to be modelled with a GARCH(1,1);
proc sql;
	create table work.rf_garch as
	select name
	from tord.riskfactors
	where compress(upcase(role)) in ("VAR","FX_SPOT")
	;
quit;

data _null_;
	set work.rf_garch;
	call execute('%create_garch_1_1(inputds=work.transform,cd=tord.currentdata,rf='||compress(name)||',outds=mktstat_'||compress(name)||')');
run;

