/**********************************************************************
 * Notas de Riesgos Financieros;
 * Jose Enrique Perez ;
 * Licenciatura en Actuaría;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/

%let basedate=01JAN2022;
%let dp=0.00022;
%put &=basedate;

proc loan start="31DEC2018"d;
	fixed amount=1000 rate=8 life=4 schedule interval=year out=work.schedule;
run;

title "Pérdida esperada";
proc sql;
	select endprin*&dp.
	from work.schedule
	where year <"&basedate."d
	having max(year)=year
	;
quit;
title;


ods graphics / reset width=6.4in height=4.8in imagemap noborder;

proc sort data=WORK.SCHEDULE(where=(year>"01JAN2018"d)) out=_SeriesPlotTaskData;
	by YEAR;
run;

title "Amortización del Crédito";
proc sgplot data=_SeriesPlotTaskData;
	series x=YEAR y=BEGPRIN /;
	series x=YEAR y=ENDPRIN /;
	series x=YEAR y=PRIN /;
	series x=YEAR y=PAYMENT /;
	series x=YEAR y=INTEREST /;
	xaxis grid;
	yaxis grid label="Monto";
run;
title;

ods graphics / reset;

proc datasets library=WORK noprint;
	delete _SeriesPlotTaskData;
run;

