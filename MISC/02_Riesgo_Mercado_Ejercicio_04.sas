/**********************************************************************
 * Notas de Riesgos Financieros;
 * Jose Enrique Perez ;
 * Licenciatura en Actuaría;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/

options cmplib=work.myfunc;


/*
Valuation parameters
*/
/* Valuation date */
%let basedate=15AUG2022;
/* Valuation currency */
%let valCurrency=MXN;
/* Start and end date to estimate the covariance matrix */
%let startdate=15AUG2018;
%let enddate=15AUG2022;
/* Horizon of the VaR*/
%let h=1;
/* Confidence of the VaR*/
%let alpha=0.95;
/* Confidence of the VaR (%)*/
%let alpha_pts=95;
/* Percentile definition */
%let perc_def=4;
/* Number of stochastic simulations */
%let nsim=5000;
/*
Current risk factors data
*/

proc sql;
	create table work.currentdata as
	select *
	from work.transform_t
	where date="&basedate."d
	;
quit;

/* Transposing the current risk factors data */
proc transpose data=WORK.CURRENTDATA out=work.CURRENTDATA_t prefix=value;
run;

/*
Enrichment of the portfolio data
*/

proc sql;
	create table work.portfolio_1 as
	select 
	a.*
	, b.name as fx
	, c.value1 as price	
	, d.value1 as fx_price
	, "&valCurrency." as valCurrency
	/* Adding the identifier of the foreign exchanges */
	from work.portfolio a left join work.configuration_rf b
	on (a.currency ne "&valCurrency" and a.currency=b.fromcur)
	/* Adding the risk factor value */
	left join work.currentdata_t c
	on (a.insttype = "Stock" and a.ref_price=c._name_)
	/* Adding the value of the foreign exchanges */
	left join work.currentdata_t d
	on (a.currency ne "&valCurrency" and b.name=d._name_)
	;
quit;

/* Validation: Looking for duplicates */
proc datasets library=work nolist nodetails;
	modify portfolio_1;
	index create mykey=(instid shortposition alposition) / nomiss unique;
quit;

/* Valuation */

/* Computing the market value */
data work.portfolio_mkt_value;
	set work.portfolio_1;
	format value mkt_value dollar20.2;
	label value="Market value";
	if insttype = "Stock" then
		do;
			value=Stock(Currency,price,valCurrency,FX_price);
			mkt_value=value*holding*ALposition*ifn(shortPosition=0,1,ifn(shortPosition=1,-1,.));
		end;
run;

proc print data=work.portfolio_mkt_value;
run;

title "Portfolio market value";
proc sql;
	select sum(mkt_value) format=dollar20.2
	from work.portfolio_mkt_value
	;

quit;
title;

proc sql noprint;
	select sum(mkt_value) format=20.6 into: W
	from work.portfolio_mkt_value
	;
quit;

%put &=W.;

/* Computing the weight of each position */
proc sql;
	create table work.weights_port as
	select 
	instid
	, mkt_value/sum(mkt_value) as weight
	from work.portfolio_mkt_value
	;
quit;

proc print data=work.weights_port;
run;


/* Computing the value of each risk factor to the valuation currency and only between the start and end date */
data work.transform_t2;
	set work.transform_t(where=(date between "&startdate."d and "&enddate."d));
	AMXL=AMXL;
	AAPL=AAPL*USDMXN;
	JPM=JPM*USDMXN;
run;

/* Computing the daily returns */
data work.returns(keep=date AAPL AMXL JPM);
	format AAPL AMXL JPM USDMXN percentn16.3;
	label AAPL="Daily Return of AAPL" AMXL="Daily Return of AMXL" JPM="Daily Return of JPM";
	set work.transform_t2;
	AAPL=log(AAPL/lag&h.(AAPL));
	AMXL=log(AMXL/lag&h.(AMXL));
	JPM=log(JPM/lag&h.(JPM));
run;	

/* Computing the covariances */
proc corr data=WORK.RETURNS(drop=date) nocorr cov vardef=n nosimple noprob outp=work.cov_matrix	plots=none noprint;
run;

/* Sorting the weights in the order of the covariances */
proc sql;
	create table work.weights_port_sort as
	select 
	b.instid
	, b.weight
	from work.cov_matrix(where=(_type_="COV")) a left join work.weights_port b
	on (a._NAME_=b.instid)
	;
quit;


proc iml;
	use work.cov_matrix(where=(_TYPE_="COV"));
	read all var _NUM_ into Sigma[colname=numVars];
	close work.cov_matrix; 	
	
	print "Covariance matrix";
	print Sigma ;

	use work.weights_port_sort;
	read all var _NUM_ into w[colname=numVars];
	close work.weights_port_sort; 	
	
	print "Portfolio weights";
	print w;

	
	VaR=sqrt(t(w)*Sigma*w)*quantile("NORMAL",&alpha)*&W.;
	print "Monto del VaR al &alpha 100% de confianza y horizonte de 1 día"; 
	print VaR;

	VaR_p=VaR/&W.;
	print "VaR porcentual al &alpha 100% de confianza y horizonte de 1 día"; 
	print VaR_p;

	/* (EP,06SEP2022) Computing the Conditional VaR */
	CVaR=sqrt(t(w)*Sigma*w)*pdf("NORMAL",quantile("NORMAL",&alpha.),0,1)*&W./(1-&alpha.);
	print "Monto del CVaR al &alpha 100% de confianza y horizonte de 1 día"; 
	print CVaR;

quit;

