/**********************************************************************
 * Notas de Riesgos Financieros;
 * Jose Enrique Perez ;
 * Licenciatura en Actuaría;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/

/*
Ejercicio 1
*/

%let mu=1;
%let sigma=1.5;
data normal;
	/* Formatos de las variables */
	format x pdf cdf 10.6;
	/* Etiquetas de las variables */
	label x ="Valor" pdf="Función de densidad" cdf="Función de distribución";
	/* Ciclos para calcular las probabilidades  */
		do x=-3.5 to 5.5 by 0.1;
		pdf=pdf('NORMAL',x,&mu.,&sigma.); 
		cdf=cdf('NORMAL',x,&mu.,&sigma.); 
		output;
		end;		
run;

data normal_var;
	/* Formatos de las variables */
	format alpha var comma10.6;
	/* Etiquetas de las variables */
	label alpha ="Nivel de confianza 𝛼" var="Valor en Riesgo";
	alpha=0.95;
	var=quantile('NORMAL',alpha,&mu.,&sigma.); output;
	alpha=0.975;
	var=quantile('NORMAL',alpha,&mu.,&sigma.); output;
	alpha=0.99;
	var=quantile('NORMAL',alpha,&mu.,&sigma.); output;
	alpha=0.995;
	var=quantile('NORMAL',alpha,&mu.,&sigma.); output;
run;

proc sql noprint;
	select alpha into: alpha_95
	from normal_var
	where alpha=0.95
	;
	select var into: var_95
	from normal_var
	where alpha=0.95
	;
	select alpha into: alpha_975
	from normal_var
	where alpha=0.975
	;
	select var into: var_975
	from normal_var
	where alpha=0.975
	;
	select alpha into: alpha_99
	from normal_var
	where alpha=0.99
	;
	select var into: var_99
	from normal_var
	where alpha=0.99
	;
	select alpha into: alpha_995
	from normal_var
	where alpha=0.995
	;
	select var into: var_995
	from normal_var
	where alpha=0.995
	;
quit;

%put &=alpha_95. &=alpha_975. &=alpha_99. &=alpha_995.;
%put &=var_95. &=var_975. &=var_99. &=var_995.;

/* Graficando las probabilidades */

ods graphics / reset width=6.4in height=4.8in imagemap noborder;

proc sort data=WORK.normal out=_SeriesPlotTaskData;
	by x;
run;

proc sgplot data=_SeriesPlotTaskData;
	title height=14pt "Función de densidad de la Distribución Normal μ=&mu., σ=1.5";
	series x=x y=pdf;
	xaxis grid;
	yaxis grid;
	refline &var_95./axis=x label="VaR(95)=&var_95." lineattrs=(pattern=shortdash color=red);
	refline &var_975./axis=x label="VaR(97.5)=&var_975." lineattrs=(pattern=shortdash color=orange);
	refline &var_99./axis=x label="VaR(99)=&var_99." lineattrs=(pattern=shortdash color=green);
	refline &var_995./axis=x label="VaR(99.5)=&var_995." lineattrs=(pattern=shortdash color=blue);
run;

proc sgplot data=_SeriesPlotTaskData;
	title height=14pt "Función de Distribución Normal μ=&mu., σ=1.5";
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

/*
Ejercicio 2
*/


data normal_cvar;
	/* Formatos de las variables */
	format cvar comma10.6;
	/* Etiquetas de las variables */
	label cvar="Valor en Riesgo Condicional";
	set normal_var;
	cvar=&mu.+&sigma.*pdf('NORMAL',quantile('NORMAL',alpha,0,1),0,1)/(1-alpha); 
run;

proc sql noprint;
	select cvar into: cvar_95
	from normal_cvar
	where alpha=0.95
	;
	select cvar into: cvar_975
	from normal_cvar
	where alpha=0.975
	;
	select cvar into: cvar_99
	from normal_cvar
	where alpha=0.99
	;
	select cvar into: cvar_995
	from normal_cvar
	where alpha=0.995
	;
quit;



/* Graficando las probabilidades */

ods graphics / reset width=6.4in height=4.8in imagemap noborder;

proc sort data=WORK.normal out=_SeriesPlotTaskData;
	by x;
run;

proc sgplot data=_SeriesPlotTaskData;
	title height=14pt "Función de densidad de la Distribución Normal μ=&mu., σ=1.5";
	series x=x y=pdf;
	xaxis grid min=0;
	yaxis grid;
	refline &var_95./axis=x label="VaR(95)=&var_95." lineattrs=(pattern=shortdash color=red);
	refline &cvar_95./axis=x label="CVaR(95)=&cvar_95." lineattrs=(pattern=shortdash color=red);
	refline &var_975./axis=x label="VaR(97.5)=&var_975." lineattrs=(pattern=shortdash color=orange);
	refline &cvar_975./axis=x label="CVaR(97.5)=&cvar_975." lineattrs=(pattern=shortdash color=orange);
	refline &var_99./axis=x label="VaR(99)=&var_99." lineattrs=(pattern=shortdash color=green);
	refline &cvar_99./axis=x label="CVaR(99)=&cvar_99." lineattrs=(pattern=shortdash color=green);
	refline &var_995./axis=x label="VaR(99.5)=&var_995." lineattrs=(pattern=shortdash color=blue);
	refline &cvar_995./axis=x label="CVaR(99.5)=&cvar_995." lineattrs=(pattern=shortdash color=blue);
run;

ods graphics / reset;
title;

proc datasets library=WORK noprint;
	delete _SeriesPlotTaskData;
run;

