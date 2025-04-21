* Options for the detail of the log;
options mprint  mlogic mautosource mcompile mlogicnest mprintnest msglevel=n minoperator fullstimer symbolgen source2; 
* https://communities.sas.com/t5/SAS-Code-Examples/Estimating-GARCH-Models/ta-p/905609;

%include "/export/viya/homes/perez-jose@lasallistas.org.mx/FinancialRisks/Exercise_5/create_garch_1_1_wrd.sas";
%include "/export/viya/homes/perez-jose@lasallistas.org.mx/FinancialRisks/Exercise_5/create_vasicek_ir_wrd.sas";


* Base date;
%let basedate=20JUN2016;
* Horizon of the VaR;
%let h=1;

* Start and end date to collect historical data;
data _null_;
	aux = put(intnx('year',"&baseDate."d,-2,'sameday'),date9.);
	call symputx("startdate",aux,'G');
	call symputx("enddate","&baseDate.",'G');
run;

%put &=startdate. &=enddate.;

* Number of simulations;
%let nsim=100000;

* Logreturns;
data MYLIB.MARKET_DATA_2_LR;
	set MYLIB.MARKET_DATA_2;
RetAMXL=log(AMXL/lag(AMXL));
RetAAPL=log(AAPL/lag(AAPL));
RetJPM=log(JPM/lag(JPM));
RetUSDMXN=log(USDMXN/lag(USDMXN));
run;

* Estimation and simulation of a GARCH(1,1) model ;
%create_garch_1_1_wrd(inputds=mylib.MARKET_DATA_2_LR,cd=mylib.currentdata,rf=AMXL,outds=mylib.mc_amxl);
%create_garch_1_1_wrd(inputds=mylib.MARKET_DATA_2_LR,cd=mylib.currentdata,rf=AAPL,outds=mylib.mc_aapl);
%create_garch_1_1_wrd(inputds=mylib.MARKET_DATA_2_LR,cd=mylib.currentdata,rf=JPM,outds=mylib.mc_jpm);
%create_garch_1_1_wrd(inputds=mylib.MARKET_DATA_2_LR,cd=mylib.currentdata,rf=USDMXN,outds=mylib.mc_USDMXN);

* Estimation and simulation of a GARCH(1,1) model ;
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_1,outds=mylib.mc_CETES_1);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_7,outds=mylib.mc_CETES_7);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_14,outds=mylib.mc_CETES_14);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_28,outds=mylib.mc_CETES_28);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_91,outds=mylib.mc_CETES_91);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_182,outds=mylib.mc_CETES_182);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_364,outds=mylib.mc_CETES_364);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_728,outds=mylib.mc_CETES_728);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_1092,outds=mylib.mc_CETES_1092);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_1456,outds=mylib.mc_CETES_1456);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_1820,outds=mylib.mc_CETES_1820);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_2180,outds=mylib.mc_CETES_2180);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_2548,outds=mylib.mc_CETES_2548);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_2912,outds=mylib.mc_CETES_2912);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_3276,outds=mylib.mc_CETES_3276);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_3640,outds=mylib.mc_CETES_3640);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_4004,outds=mylib.mc_CETES_4004);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_4368,outds=mylib.mc_CETES_4368);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_4732,outds=mylib.mc_CETES_4732);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_5096,outds=mylib.mc_CETES_5096);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_5460,outds=mylib.mc_CETES_5460);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_5824,outds=mylib.mc_CETES_5824);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_6188,outds=mylib.mc_CETES_6188);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_6552,outds=mylib.mc_CETES_6552);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_6916,outds=mylib.mc_CETES_6916);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_7280,outds=mylib.mc_CETES_7280);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_7644,outds=mylib.mc_CETES_7644);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_8008,outds=mylib.mc_CETES_8008);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_8372,outds=mylib.mc_CETES_8372);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_8736,outds=mylib.mc_CETES_8736);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_9020,outds=mylib.mc_CETES_9020);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_9464,outds=mylib.mc_CETES_9464);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_9828,outds=mylib.mc_CETES_9828);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_10192,outds=mylib.mc_CETES_10192);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_10556,outds=mylib.mc_CETES_10556);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_10800,outds=mylib.mc_CETES_10800);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=CETES_10920,outds=mylib.mc_CETES_10920);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_1,outds=mylib.mc_LIBOR_1);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_7,outds=mylib.mc_LIBOR_7);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_14,outds=mylib.mc_LIBOR_14);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_28,outds=mylib.mc_LIBOR_28);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_91,outds=mylib.mc_LIBOR_91);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_182,outds=mylib.mc_LIBOR_182);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_364,outds=mylib.mc_LIBOR_364);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_728,outds=mylib.mc_LIBOR_728);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_1092,outds=mylib.mc_LIBOR_1092);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_1456,outds=mylib.mc_LIBOR_1456);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_1820,outds=mylib.mc_LIBOR_1820);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_2180,outds=mylib.mc_LIBOR_2180);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_2548,outds=mylib.mc_LIBOR_2548);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_2912,outds=mylib.mc_LIBOR_2912);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_3276,outds=mylib.mc_LIBOR_3276);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_3640,outds=mylib.mc_LIBOR_3640);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_4004,outds=mylib.mc_LIBOR_4004);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_4368,outds=mylib.mc_LIBOR_4368);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_4732,outds=mylib.mc_LIBOR_4732);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_5096,outds=mylib.mc_LIBOR_5096);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_5460,outds=mylib.mc_LIBOR_5460);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_5824,outds=mylib.mc_LIBOR_5824);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_6188,outds=mylib.mc_LIBOR_6188);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_6552,outds=mylib.mc_LIBOR_6552);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_6916,outds=mylib.mc_LIBOR_6916);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_7280,outds=mylib.mc_LIBOR_7280);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_7644,outds=mylib.mc_LIBOR_7644);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_8008,outds=mylib.mc_LIBOR_8008);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_8372,outds=mylib.mc_LIBOR_8372);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_8736,outds=mylib.mc_LIBOR_8736);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_9020,outds=mylib.mc_LIBOR_9020);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_9464,outds=mylib.mc_LIBOR_9464);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_9828,outds=mylib.mc_LIBOR_9828);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_10192,outds=mylib.mc_LIBOR_10192);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_10556,outds=mylib.mc_LIBOR_10556);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_10800,outds=mylib.mc_LIBOR_10800);
%create_vasicek_ir_wrd(inputds=mylib.MARKET_DATA_2,cd=mylib.currentdata,rf=LIBOR_10920,outds=mylib.mc_LIBOR_10920);


* Merging the data sets;
data mylib.simstate_rf(drop=date);
	merge mylib.mc_jpm(where=(date="21JUN2016"d) drop=_type_ _mode_ _rep_ _errors_  RetJPM )
	mylib.mc_aapl(where=(date="21JUN2016"d) drop=_type_ _mode_ _rep_ _errors_  RetAAPL )
	mylib.mc_usdmxn(where=(date="21JUN2016"d) drop=_type_ _mode_ _rep_ _errors_  RetUSDMXN )
	mylib.mc_amxl(where=(date="21JUN2016"d) drop=_type_ _mode_ _rep_ _errors_  RetAMXL )
	;
run;

data mylib.simstate_ir;
	merge mylib.mc_cetes_:(drop=_type_ _mode_ _lag_ _rep_ _errors_ date)
	mylib.mc_libor_:(drop=_type_ _mode_ _lag_ _rep_ _errors_ date);
run;

data mylib.simstate_mc;
	merge mylib.simstate_rf mylib.simstate_ir;
run;

* Delete the useless data sets ;

proc datasets lib=mylib nodetails nolist;
	delete mc_:;
quit;

proc datasets lib=models nodetails nolist kill;
quit;

