%let mu=1;
%let sigma=1.5;
data tstudent;
	/* Formatos de las variables */
	format x pdf cdf 10.6;
	/* Etiquetas de las variables */
	label x ="Valor" pdf="Función de densidad" cdf="Función de distribución";
	/* Ciclos para calcular las probabilidades  */
		do x=-3.5 to 10 by 0.1;
		pdf=pdf('T',x,2); 
		cdf=cdf('T',x,2); 
		output;
		end;		
run;

data tstudent_var;
	/* Formatos de las variables */
	format alpha var comma10.6;
	/* Etiquetas de las variables */
	label alpha ="Nivel de confianza 𝛼" var="Valor en Riesgo";
	alpha=0.95;
	var=quantile('T',alpha,2); output;
	alpha=0.975;
	var=quantile('T',alpha,2); output;
	alpha=0.99;
	var=quantile('T',alpha,2); output;
	alpha=0.995;
	var=quantile('T',alpha,2); output;
run;

proc sql noprint;
	select alpha into: alpha_95
	from tstudent_var
	where alpha=0.95
	;
	select var into: var_95
	from tstudent_var
	where alpha=0.95
	;
	select alpha into: alpha_975
	from tstudent_var
	where alpha=0.975
	;
	select var into: var_975
	from tstudent_var
	where alpha=0.975
	;
	select alpha into: alpha_99
	from tstudent_var
	where alpha=0.99
	;
	select var into: var_99
	from tstudent_var
	where alpha=0.99
	;
	select alpha into: alpha_995
	from tstudent_var
	where alpha=0.995
	;
	select var into: var_995
	from tstudent_var
	where alpha=0.995
	;
quit;

%put &=alpha_95. &=alpha_975. &=alpha_99. &=alpha_995.;
%put &=var_95. &=var_975. &=var_99. &=var_995.;

/* Graficando las probabilidades */

ods graphics / reset width=6.4in height=4.8in imagemap noborder;

proc sort data=WORK.tstudent out=_SeriesPlotTaskData;
	by x;
run;

proc sgplot data=_SeriesPlotTaskData;
	title height=14pt "Función de densidad de la Distribución T";
	series x=x y=pdf;
	xaxis grid;
	yaxis grid;
	refline &var_95./axis=x label="VaR(95)=&var_95." lineattrs=(pattern=shortdash color=red);
	refline &var_975./axis=x label="VaR(97.5)=&var_975." lineattrs=(pattern=shortdash color=orange);
	refline &var_99./axis=x label="VaR(99)=&var_99." lineattrs=(pattern=shortdash color=green);
	refline &var_995./axis=x label="VaR(99.5)=&var_995." lineattrs=(pattern=shortdash color=blue);
run;

proc sgplot data=_SeriesPlotTaskData;
	title height=14pt "Función de Distribución T";
	series x=x y=cdf;
	xaxis grid;
	yaxis grid min=0.90;
	refline &var_95./axis=x label="VaR(95)=&var_95." lineattrs=(pattern=shortdash color=red);
	refline &var_975./axis=x label="VaR(97.5)=&var_975." lineattrs=(pattern=shortdash color=orange);
	refline &var_99./axis=x label="VaR(99)=&var_99." lineattrs=(pattern=shortdash color=green);
	refline &var_995./axis=x label="VaR(99.5)=&var_995." lineattrs=(pattern=shortdash color=blue);
	refline &alpha_95./axis=y label="&alpha_95." lineattrs=(pattern=shortdash color=red);
	refline &alpha_975./axis=y label="&alpha_975." lineattrs=(pattern=shortdash color=orange);
	refline &alpha_99./axis=y label="&alpha_99." lineattrs=(pattern=shortdash color=green);
	refline &alpha_995./axis=y label="&alpha_995." lineattrs=(pattern=shortdash color=blue);
run;


ods graphics / reset;
title;

proc datasets library=WORK noprint;
	delete _SeriesPlotTaskData;
run;

proc print data=work.tstudent_var;
run;
