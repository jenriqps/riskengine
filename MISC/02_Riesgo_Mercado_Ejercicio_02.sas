/**********************************************************************
 * Notas de Riesgos Financieros;
 * Jose Enrique Perez ;
 * Licenciatura en Actuaría;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/

options cmplib=work.myfunc;

/*
Identificación de las fechas en que se calcularán los rendimientos
*/

%let n_sim_mx = 100000;
%let start_mx = 01JAN2007;

/* Cambia la siguiente ruta para que coincida con la de tu usuario */
%include "/shared/home/perez-jose@lasallistas.org.mx/riesgos_financieros/inhabilMX.sas";

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

%let start=16AUG2017;
%let end=01FEB2023;

data work.dates;
	format date date9.;
	do date="&start."d to "&end."d by 1;
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
		select 
		a.date
		, b.aapl_1 as AAPL
		, c.amxl_1 as AMXL
		, d.jpm_1 as JPM
		, e.USDMXN_1 as USDMXN
		from work.dates_2 a left join  work.import b on (a.date=b.aapl)
		left join work.import c on (a.date=c.amxl)
		left join work.import d on (a.date=d.jpm)
		left join work.import e on (a.date=e.usdmxn)
		;
quit;

/* (EP,05SEP2022) Identifying missing values */
proc  univariate data=work.transform_t;
run;

/* (EP,05SEP2022) Completing missing values */

proc expand data=work.transform_t out=work.transform_t method=step;
	id date;	
run;


/* (EP,05SEP2022) Identifying missing values */
proc  univariate data=work.transform_t;
run;


* Computing the daily returns;
data work.transform(keep=date RetAAPL RetAMXL RetJPM RetUSDMXN);
	format RetAAPL RetAMXL RetJPM RetUSDMXN percentn16.3;
	label RetAAPL="Daily Return of AAPL" RetAMXL="Daily Return of AMXL" RetJPM="Daily Return of JPM" RetUSDMXN="Daily Return of USDMXN";
	set work.transform_t;
	if date >= "01AUG1986"d then 
	do;
	RetAAPL=log(AAPL/lag(AAPL));
	RetAMXL=log(AMXL/lag(AMXL));
	RetJPM=log(JPM/lag(JPM));
	RetUSDMXN=log(USDMXN/lag(USDMXN));
	end;
run;	

* Exploring the daily returns;
title "Daily Returns";
proc sgplot data=work.transform;
	series x=Date y=RetAAPL;
	series x=Date y=RetAMXL;	
	series x=Date y=RetJPM;		
	series x=Date y=RetUSDMXN;		
	xaxis grid;
	yaxis grid label="Daily return";
	keylegend / location=inside;
run;
title;

