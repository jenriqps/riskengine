/**********************************************************************
 * Exercise 6;
 * Jose Enrique Perez ;
 * Licenciatura en Actuaría;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/

* Add the module of functions;
%include "/export/viya/homes/perez-jose@lasallistas.org.mx/FinancialRisks/Exercise_6/exercise_6a_topic_2.sas";

* Base date;
%let basedate=20JUN2016;
* Horizon of the VaR;
%let h=1;
* Confidence of the VaR;
* Loss are negatives, multiply by 100 
* e.g. if you want 5% then enter 5;
%let conf=2.5;
* Percentile definition;
%let perc_def=4;
* Configuration of curves;
%let nodes_CETES='CETES_1' 'CETES_7' 'CETES_14' 'CETES_28' 'CETES_91' 'CETES_182' 'CETES_364'
'CETES_728' 'CETES_1092' 'CETES_1456' 'CETES_1820' 'CETES_2180' 'CETES_2548' 'CETES_2912'
 'CETES_3276' 'CETES_3640' 'CETES_4004' 'CETES_4368' 'CETES_4732' 'CETES_5096' 'CETES_5460'
 'CETES_5824' 'CETES_6188' 'CETES_6552' 'CETES_6916' 'CETES_7280' 'CETES_7644' 'CETES_8008'
 'CETES_8372' 'CETES_8736' 'CETES_9020' 'CETES_9464' 'CETES_9828' 'CETES_10192' 'CETES_10556'
 'CETES_10800' 'CETES_10920';
%put &=nodes_CETES.;
%let mat_CETES=1 7 14 28 91 182 364 728 1092 1456 1820 2180 2548 2912 3276 3640 4004 
4368 4732 5096 5460 5824 6188 6552 6916 7280 7644 8008 8372 8736 9020 9464 9828 10192 10556 10800 10920;
%put &=mat_CETES;

* Delete the row of missing values in the historically simulated states;
proc sql;
	delete from mylib.simstate_hs 
	where date = "23JUN2014"d
	;
quit;

* Market value and Simulation;
proc iml;
	*Load the functions;
	load module=_all_;

	* Import the columns of the portfolio data set to vectors;
	use mylib.portfolio;
	read all var _ALL_; 
	close mylib.portfolio; 

	* Configuration of the curves (nodes and names of the rates);
	nodes_CETES={ &nodes_CETES. };
	mat_CETES={&mat_CETES.};
	* Identify the characteristics of the financial instruments;
	idx_pr = loc(insttype="Stock");
	idx_zcb = loc(insttype="ZeroCouponBond");
    NV=Par_LC[idx_zcb];
	mat_dt=MaturityDate[idx_zcb];
	curves=discount_curve_id[idx_zcb];

	/************************/
	/* Current market value */
	/************************/
	* Import the currentdata data set to a matrix;
	use mylib.currentdata;
	read all var _ALL_ into currentdata[colname=NumerNames]; 
	close mylib.currentdata; 
	* Price function;
	vector=currentdata[,ref_price[idx_pr]];
	price=Price(vector);
	* Exchange rates;
	vector=currentdata[,{'USDMXN'}];
	price_fx=Price(vector);
	* Zero coupon bond;	
	* Current curve;
	val_CETES=currentdata[,nodes_CETES];
	CETES=t(mat_CETES)||t(val_CETES);
	zcb = ZeroCouponBond("&basedate."d,mat_dt,NV,CETES,360);
	/******************************************************/
	/* Simulation of the market value in the time horizon */
	/******************************************************/
	* Import the simstate data set to a matrix;
	use mylib.simstate_hs;
	read all var _ALL_ into simstate_s[colname=NumerNames]; 
	close mylib.simstate_s; 
	* Price function;
	vector=simstate_s[,ref_price[idx_pr]];
	price_s=Price(vector);
	* Exchange rates;
	vector=simstate_s[,{'USDMXN'}];
	price_fx_s=Price(vector);
	*print price_fx_s;
	* Zero coupon bond;	
	* Simulated curves in the time horizon;
	val_CETES_s=simstate_s[,nodes_CETES];
	CETES_s=t(mat_CETES)||t(val_CETES_s);
	zcb_s = ZeroCouponBond("&basedate."d+1,mat_dt,NV,CETES_s,360);
	/************************************/
	/* Saving the results to data sets  */
	/************************************/
	* Current market value;
	instID_mkt_pr = repeat(instID[idx_pr],nrow(price));
	StateNumber_pr = repeat(0,nrow(instID_mkt_pr),ncol(instID_mkt_pr));
	ReturnedValue_mkt_pr=shape(price,nrow(instID_mkt_pr),ncol(instID_mkt_pr));
	create mkt_pr var{instID_mkt_pr StateNumber_pr ReturnedValue_mkt_pr};
	append;
	close mkt_pr;

	instID_mkt_zcb = repeat(instID[idx_zcb],nrow(zcb));
	StateNumber_zcb = repeat(0,nrow(instID_mkt_zcb),ncol(instID_mkt_zcb));
	ReturnedValue_mkt_zcb=shape(zcb,nrow(instID_mkt_zcb),ncol(instID_mkt_zcb));

	create mkt_zcb var{instID_mkt_zcb StateNumber_zcb ReturnedValue_mkt_zcb};
	append;
	close mkt_zcb;

	* Simulations;
	instID_ap_pr = repeat(instID[idx_pr],nrow(price_s));
	StateNumber_pr = shape(t(do(1,nrow(price_s),1))||t(do(1,nrow(price_s),1))||t(do(1,nrow(price_s),1))
						,nrow(instID_ap_pr),1);
	ReturnedValue_pr=shape(price_s,nrow(instID_ap_pr),ncol(instID_ap_pr));

	create ap_pr var{instID_ap_pr StateNumber_pr ReturnedValue_pr};
	append;
	close ap_pr;

	instID_ap_zcb = repeat(instID[idx_zcb],nrow(zcb_s));
	StateNumber_zcb = shape(t(do(1,nrow(zcb_s),1))||t(do(1,nrow(zcb_s),1))
						,nrow(instID_ap_zcb),1);
	ReturnedValue_zcb=shape(zcb_s,nrow(instID_ap_zcb),ncol(instID_ap_zcb));

	create ap_zcb var{instID_ap_zcb StateNumber_zcb ReturnedValue_zcb};
	append;
	close ap_zcb;

	* Exchange rates;
	StateNumber_fx=do(0,nrow(price_fx_s),1);
	*print StateNumber_fx;
	ReturnedValue_fx= price_fx // price_fx_s;
	instID_fx=repeat({'USDMXN'},nrow(ReturnedValue_fx),1);
	*print instID_fx;
	create fx var{instID_fx StateNumber_fx ReturnedValue_fx};
	append;
	close fx;

quit;

* Change names of the columns to append the data sets;
proc datasets lib=work nodetails nolist;
	modify ap_zcb;
	rename
	instID_ap_zcb=instID 
	StateNumber_zcb=StateNumber 
	ReturnedValue_zcb=ReturnedValue;
	modify ap_pr;
	rename
	instID_ap_pr=instID
 	StateNumber_pr=StateNumber
	ReturnedValue_pr=ReturnedValue;
	modify mkt_pr;
	rename
	instID_mkt_pr=instID
 	StateNumber_pr=StateNumber
	ReturnedValue_mkt_pr=ReturnedValue;
	modify mkt_zcb;
	rename
	instID_mkt_zcb=instID
 	StateNumber_zcb=StateNumber
	ReturnedValue_mkt_zcb=ReturnedValue;
	modify fx;
	rename
	instID_fx=instID
 	StateNumber_fx=StateNumber
	ReturnedValue_fx=ReturnedValue;
quit;

* Append the data sets;
proc append base= ap_zcb data=ap_pr force;
run; 
proc append base= ap_zcb data=mkt_pr force;
run; 
proc append base= ap_zcb data=mkt_zcb force;
run; 

* Create the allprice data set;
proc sql;
	create table mylib.allprice as
		select a.instid as InstID
		, a.statenumber as StateNumber
		, a.ReturnedValue as ReturnedValue format=nlnum16.2
		, case a.statenumber
			when 0 then "&basedate"d 
			when a.statenumber > 0 then "&basedate"d+1 end as _date_ format = date9.
		, b.holding
		, b.ShortPosition
		, b.LocalCurrency as Currency
		, case b.ShortPosition
			when 0 then a.ReturnedValue*b.holding
			when 1 then -1*a.ReturnedValue*b.holding else 0 
			end as NativeValue format=nlnum16.2
		, case ReferenceCurrency
			when 'USDMXN' then c.ReturnedValue
			else 1 end as FX_Rate format=nlnum16.2
		, (calculated NativeValue)*(calculated FX_Rate) as Value format=nlnum16.2
		from ap_zcb a inner join mylib.portfolio b 
		on (a.instid=b.instid) inner join fx c 
		on (a.statenumber=c.statenumber)
		order by a.statenumber, a.instid
		;
quit;

* Compute the value of the portfolio for every simulated state;
proc means data=mylib.allprice noprint;
	var value;
	by statenumber;
	output out=work.simvalue sum(value)=Value;
run;

* Create the simvalue data set;
proc sql;
	create table mylib.simvalue as
	select 
	a.statenumber
	, a.Value
	, a.Value - b.Value as PL format=nlnum16.2
	, (calculated PL)/b.Value as PLPct format=percentn16.2
	from work.simvalue(where=(statenumber>0)) a, work.simvalue(where=(statenumber=0)) b
	;
quit;

* Calculate the VaR;
proc univariate data=mylib.simvalue noprint pctldef=&perc_def.;
	var PL;
	output out=work.simstat pctlpts=&conf. pctlpre=VaR_;
run;

* Create the simstat data set;
proc sql noprint;
	select * into: VaR  
	from work.simstat;
	create table work.simstat2 as
		select 
		&VaR. as VaR format=nlnum16.2
		, mean(b.PL) as ES format=nlnum16.2
		from mylib.simvalue b		
		where b.PL< &VaR.
		; 
	select ES format=16.2 into: ES  
	from work.simstat2;
	create table mylib.simstat as
		select 
		"&basedate."d as BaseDate format=date9.
		, a.value as MtM format=nlnum16.2
		, &conf./100 as ConfidenceLevel
		, b.VaR
		, b.VaR/a.value as VaRPct format=percentn16.2
		, b.ES
		from work.simvalue a, work.simstat2 b
		where statenumber=0
		;
quit;

title "Simulation Statistics";
proc print data=mylib.simstat;
run;

ods graphics / reset width=6.4in height=6in imagemap noborder;
title 'Profit & losses distribution';
proc sgplot data=mylib.simvalue;
 	histogram PL / fillattrs=(color=blue transparency=0.75);
 	refline &VaR. / axis=x lineattrs=(color=red pattern=15) label = ("VaR &VaR.");
 	refline &ES. / axis=x lineattrs=(color=orange pattern=15) label = ("ES &ES.");
	xaxis grid;
	yaxis grid;
run;
