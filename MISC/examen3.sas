%let basedate=01JAN2022;
%let dp=0.00022;
%put &=basedate;



proc loan start="31DEC2018"d;
	fixed amount=1000000 rate=9.5 life=4 schedule interval=year out=work.schedule;
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
