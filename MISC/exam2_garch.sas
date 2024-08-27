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

%macro set_InhabilMX();

		/*Funcion que nos dice si 'Fecha' cae en jueves santo*/
	function JSanto(Fecha);
		anio = year(Fecha);
		a = mod(anio,19);
		b = mod(anio,4);
		c = mod(anio,7);
		d = mod((19 * a + 24),30);
		e = mod((2 * b + 4 * c + 6 * d + 5),7);

		if d+e < 10 then do;
			dia = d + e + 22;
			mes = 3;
		end;
		else do;
			dia = d + e - 9;
			mes = 4;
		end;

		if dia = 26  and mes = 4 then dia = 19;

		if dia = 25 and mes = 4 and d = 28 and e = 6 and a > 10 then dia = 18;

		if mdy(mes, dia, anio) - 3 = Fecha then JSanto = 1;
		return(Jsanto);
	endsub;
	
	/*Funcion que nos dice si 'Fecha' cae en viernes santo*/
	function VSanto(Fecha);
		if JSanto(Fecha - 1) = 1 then VSanto = 1;
		return(Vsanto);
	endsub;

	/*Funcion que verifica si la fecha cae en el primer lunes del mes*/
	function plunes(Fecha);
		anio = Year(Fecha);
		mes = Month(Fecha);
		dia = Day(Fecha);
		primerdia = (mdy(mes,1,anio));
		primerdiasem = Weekday(primerdia);

		If primerdiasem = 1 Then
			fechan = primerdia + 1;
		Else If primerdiasem = 2 Then
			fechan = primerdia;
		Else If primerdiasem = 3 Then
			fechan = primerdia + 6;
		Else If primerdiasem = 4 Then
			fechan = primerdia + 5;
		Else If primerdiasem = 5 Then
			fechan = primerdia + 4;
		Else If primerdiasem = 6 Then
			fechan = primerdia + 3;
		Else If primerdiasem = 7 Then
			fechan = primerdia + 2;
		plunes = Day(fechan);
		return(plunes);
	endsub;

	/*Funcion que verifica si la fecha cae en el tercer lunes del mes*/
	function tlunes(Fecha);
		anio = Year(Fecha);
		mes = Month(Fecha);
		dia = Day(Fecha);
		primerdia = (mdy(mes,1,anio));
		primerdiasem = Weekday(primerdia);

		If primerdiasem = 1 Then
			fechan = primerdia + 15;
		Else If primerdiasem = 2 Then
			fechan = primerdia + 14;
		Else If primerdiasem = 3 Then
			fechan = primerdia + 20;
		Else If primerdiasem = 4 Then
			fechan = primerdia + 19;
		Else If primerdiasem = 5 Then
			fechan = primerdia + 18;
		Else If primerdiasem = 6 Then
			fechan = primerdia + 17;
		Else If primerdiasem = 7 Then
			fechan = primerdia + 16;
		tlunes = Day(fechan);
		return(tlunes);
	endsub;

	/*Funcion que verifica si la fecha de entrada es di­a inhabil*/
	function NoLabMX(Fecha);
		a = Weekday(Fecha);

		If a = 1 Or a = 7 Then do;
			NoLabMX = 1;
			return(NoLabMX);
		end;
		else do;
			dia = Day(Fecha);
			mes = Month(Fecha);
			anio = Year(Fecha);
			NoLabMX = 0;

			if mes = 1 and dia = 1 Then NoLabMX = 1;

			if mes = 2 and dia = plunes(Fecha) Then NoLabMX = 1;

			if mes = 3 then do;
				if dia = 21 and anio <= 2006 Then NoLabMX = 1;
				if dia = tlunes(Fecha) and anio > 2006 then NoLabMX = 1;
				if JSanto(Fecha) = 1 Then NoLabMX = 1;
				If VSanto(Fecha) = 1 Then NoLabMX = 1;
			end;

			if mes = 4 then do;
				If JSanto(Fecha) = 1 Then NoLabMX = 1;
				If VSanto(Fecha) = 1 Then NoLabMX = 1;
			end;

			if mes = 5 and dia = 1 Then NoLabMX = 1;

			if mes = 9 then do;
				If dia = 16 Then NoLabMX = 1;
				If dia = 17 And anio = 2010 Then NoLabMX = 1;
			end;

			if mes = 11 then do;
				If dia = 2 Then NoLabMX = 1;
				If dia = tlunes(Fecha) Then	NoLabMX = 1;
			end;

			if mes = 12 then do;
				If dia = 12 or dia = 25 Then NoLabMX = 1;
				else if dia = 1 and mod((anio - 2000),6) = 0 then NoLabMX = 1;
			end;

			return(NoLabMX);
		end;
	endsub;
run;

%mend;





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
%let end=16AUG2022;

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

ods noproctitle;
ods graphics / imagemap=on;

proc sort data=WORK.TRANSFORM(keep=date RetAMXL) out=Work.preProcessedData;
	by date;
run;

proc timeseries data=Work.preProcessedData seasonality=7 plots=(series 
		histogram corr);
	id date interval=Day;
	var RetAMXL / accumulate=none transform=none;
run;

proc delete data=Work.preProcessedData;
run;

/*
Ajuste de los modelos
*/

ods output FitSummary=FIT_SUMMARY ParameterEstimates = PARAMETER_ESTIMATES ;
proc autoreg data=work.transform(keep=date RetAMXL) maxit=200 optimizer=nlp;
	"GARCH(p=1,q=1)": model RetAMXL=/ noint garch=(q=1,p=1);
	output out=results_garch cev=v;
run;


proc sql;
	create table work.var_cond as
	select a.date
	, a.v as variance label="Conditional variance with GARCH(1,1)"
	, (252*a.v)**0.5 as vol label="Annual volatility"
	from work.results_garch a 
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

proc print data=work.var_cond;
run;

