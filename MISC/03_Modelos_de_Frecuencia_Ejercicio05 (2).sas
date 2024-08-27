/**********************************************************************
 * Notas de Distribuciones de Pérdida;
 * Jose Enrique Perez ;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/

options mprint mlogic minoperator fullstimer;


/*
Example 13.8
Klugman, S. et al (2012). Loss Models: From data to decisions. EUA: John Wiley & Sons. 
*/


/* Data set*/
data work.ds13_8(label="Data set for Example 13.8");
	label k="Number of accidents" f_k="Number of drivers";
	format k f_k comma6.;
	input k f_k;
	datalines;
0 81714
1 11306
2 1618
3 250
4 40
5 7
;

/* Maximum likelihood */

/* 1st way */

/*
The parameters m and q will be estimated with the maximum likelihood method
*/


%macro max_ver(m_min=,m_max=);
/*
This macro computes the maximum likelihood estimator for q for each value of m between m_min and m_max, for a binomial distribution.
The result is a data set with the estimators and the maximum loglikelihood.
m_min: minimum value for m
m_max: maximum value for m
*/
	/* Deleting old data sets */
	proc datasets lib=work nodetails nolist;
		delete result_:;
	quit;

	%do m=&m_min. %to &m_max.;
		proc iml;
			/* Función de logverosimilitud  */
			start Binomial_LL(q) global(k,f_k);		
			   LL = sum(logpdf("BINOMIAL",k,q,&m.)#f_k);
			   return(LL);
			finish;
			/* Leemos el data set */	 
			use ds13_8; read all var _ALL_; close;
			 
			/* Restricciones */ 
			con = { 0 ,
					1 };    
			/* Opciones */
			/* Check https://documentation.sas.com/doc/en/pgmsascdc/v_026/imlug/imlug_nonlinearoptexpls_sect018.htm  */
			opt = {1,       /* encontrar el máximo de la función */
			       2};      /* imprimir salidas */
			/* Valores iniciales para la optimización */
			q0  = 0.5;
	
			/* Maximizamos la logverosimilitud */
			call nlpnra(rc, q_MLE, "Binomial_LL", q0, opt, con);
			print q_MLE;
			LL=Binomial_LL(q_MLE);
	
			/* Saving the main results to an output data set */
			result={&m.}||q_MLE[1]||LL[1];
	 		print result;
	
			create work.result_&m. from result;
			append from result;
			close work.result_&m.;
		quit;
	%end;

	/* Appending the results in one data set */
	data work.result;
		set work.result_:(rename=(col1=m col2=q col3=LL));
	run;

	/* Deleting unuseful data sets */
	proc datasets lib=work nodetails nolist;
		delete result_:;
	quit;

%mend;

%max_ver(m_min=1,m_max=50);

/* Selecting the value of m where the loglikelihood is maximum */
proc sql;
	select *
	from work.result
	having max(LL)=LL
	;
quit;




/* 2nd way*/

/* Expanding the data set to a transactional level */

data work.ds13_8_k0;
	do i=1 to 81714;
	f_k=81714;
	output;
	end;
run;

data work.ds13_8_k1;
	do i=1 to 11306;
	f_k=11306;
	output;
	end;
run;

data work.ds13_8_k2;
	do i=1 to 1618;
	f_k=1618;
	output;
	end;
run;

data work.ds13_8_k3;
	do i=1 to 250;
	f_k=250;
	output;
	end;
run;

data work.ds13_8_k4;
	do i=1 to 40;
	f_k=40;
	output;
	end;
run;

data work.ds13_8_k5;
	do i=1 to 7;
	f_k=7;
	output;
	end;
run;


data work.ds13_8_detail;
	set work.ds13_8_k:;
run;

proc sql;
	create table ds13_8_detail2 as
	select a.k
	from ds13_8 a inner join ds13_8_detail b
	on (a.f_k=b.f_k)
	;
quit;

/* Checking that the frequencies are the same as the originals */
proc freq data=ds13_8_detail2;
	table k;
run;

/*
NLMIXED procedure
https://documentation.sas.com/doc/en/statug/15.2/statug_nlmixed_overview.htm
*/


/* Estimating the parameters of the Binomial distribution */
proc nlmixed data=ds13_8_detail2;
	/* Valores iniciales en una red */
   parms q = 0.01 to 0.99 by 0.05 m = 1 to 50 by 1;   
	/* Límites para los parámetros */           
   bounds 0 < q < 1, 1<= m <= 50;
   model k ~ binomial(m,q);
   ods output FitStatistics=work.fs_b ParameterEstimates=work.BINOMIAL;
run;

/* Estimating the parameters of the Poisson distribution */
proc nlmixed data=ds13_8_detail2;
   parms l=0.5;   
   bounds 0 < l < 100;
   model k ~ poisson(l);
   ods output FitStatistics=work.fs_p ParameterEstimates=work.POISSON;
run;

* How to code it with PROC COUNTREG?;
proc countreg data=ds13_8_detail2 corrb;
	model k= / dist=poisson;
	store countStoreP;
	performance details;
run;

* Si coincide el AIC;

/* Estimating the parameters of the Negative Binomial distribution (generalized version) */

proc nlmixed data=ds13_8_detail2;
   parms p=0.01 to 0.99 by 0.05 n=1 to 50 by 1;   
   bounds 0 < p < 1, n>0;
   model k ~ negbin(n,p);
   ods output FitStatistics=work.fs_nb ParameterEstimates=work.NEGBINOMIAL;
run;

* How to code it with PROC COUNTREG?;
ods output FitSummary=work.fs_nb1;
proc countreg data=ds13_8_detail2 corrb outest=work.outest;
	model k= / dist=negbin(p=1);
	store countStoreNB1;
	performance details;
run;

* Si coincide el AIC;

* The NEGBIN2 model, with p=2, is the standard formulation of the negative binomial model.;
* https://documentation.sas.com/doc/es/pgmsascdc/9.4_3.4/etsug/etsug_countreg_details10.htm ;
ods output FitSummary=work.fs_nb2;
proc countreg data=ds13_8_detail2 corrb;
	model k= / dist=negbin(p=2);
	store countStoreNB2;
	performance details;
run;



proc sql;
	create table work.fs as
	select
	'BINOMIAL' as model
	, *
	from work.fs_b
	union
	select
	'POISSON' as model
	, *
	from work.fs_p
	union
	select
	'NEGBINOMIAL' as model
	, *
	from work.fs_nb
	;
	select model into: champ
	from work.fs 
	where descr like "%AICC%"
	having value=min(value)
	;
	select estimate into: pars separated by ','
	from &champ.
	;
quit;

%put &champ. &pars.;

data work.simulation_n;
	call streaminit(2024);
	do i=1 to 1000;
   	n = rand("&champ.",&pars.); 
   	output;
   end;
run;

proc freq data=work.simulation_n;
	table n;
run;

