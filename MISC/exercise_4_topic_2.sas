proc expand data=mylib.market_data out=mylib.market_data_2 method=step;
	id date;	
run;


proc export data=mylib.market_data_2 outfile="/export/viya/homes/perez-jose@lasallistas.org.mx/market_data_2.xlsx" dbms=xlsx replace;
run;

data MYLIB.MARKET_DATA_2_CH;
	set MYLIB.MARKET_DATA_2;
tr_AMXL=AMXL/lag(AMXL)-1;
tr_AAPL=AAPL/lag(AAPL)-1;
tr_JPM=JPM/lag(JPM)-1;
tr_USDMXN=USDMXN/lag(USDMXN)-1;
tr_CETES_1=CETES_1/lag(CETES_1)-1;
tr_CETES_7=CETES_7/lag(CETES_7)-1;
tr_CETES_14=CETES_14/lag(CETES_14)-1;
tr_CETES_28=CETES_28/lag(CETES_28)-1;
tr_CETES_91=CETES_91/lag(CETES_91)-1;
tr_CETES_182=CETES_182/lag(CETES_182)-1;
tr_CETES_364=CETES_364/lag(CETES_364)-1;
tr_CETES_728=CETES_728/lag(CETES_728)-1;
tr_CETES_1092=CETES_1092/lag(CETES_1092)-1;
tr_CETES_1456=CETES_1456/lag(CETES_1456)-1;
tr_CETES_1820=CETES_1820/lag(CETES_1820)-1;
tr_CETES_2180=CETES_2180/lag(CETES_2180)-1;
tr_CETES_2548=CETES_2548/lag(CETES_2548)-1;
tr_CETES_2912=CETES_2912/lag(CETES_2912)-1;
tr_CETES_3276=CETES_3276/lag(CETES_3276)-1;
tr_CETES_3640=CETES_3640/lag(CETES_3640)-1;
tr_CETES_4004=CETES_4004/lag(CETES_4004)-1;
tr_CETES_4368=CETES_4368/lag(CETES_4368)-1;
tr_CETES_4732=CETES_4732/lag(CETES_4732)-1;
tr_CETES_5096=CETES_5096/lag(CETES_5096)-1;
tr_CETES_5460=CETES_5460/lag(CETES_5460)-1;
tr_CETES_5824=CETES_5824/lag(CETES_5824)-1;
tr_CETES_6188=CETES_6188/lag(CETES_6188)-1;
tr_CETES_6552=CETES_6552/lag(CETES_6552)-1;
tr_CETES_6916=CETES_6916/lag(CETES_6916)-1;
tr_CETES_7280=CETES_7280/lag(CETES_7280)-1;
tr_CETES_7644=CETES_7644/lag(CETES_7644)-1;
tr_CETES_8008=CETES_8008/lag(CETES_8008)-1;
tr_CETES_8372=CETES_8372/lag(CETES_8372)-1;
tr_CETES_8736=CETES_8736/lag(CETES_8736)-1;
tr_CETES_9020=CETES_9020/lag(CETES_9020)-1;
tr_CETES_9464=CETES_9464/lag(CETES_9464)-1;
tr_CETES_9828=CETES_9828/lag(CETES_9828)-1;
tr_CETES_10192=CETES_10192/lag(CETES_10192)-1;
tr_CETES_10556=CETES_10556/lag(CETES_10556)-1;
tr_CETES_10800=CETES_10800/lag(CETES_10800)-1;
tr_CETES_10920=CETES_10920/lag(CETES_10920)-1;
tr_LIBOR_1=LIBOR_1-lag(LIBOR_1);
tr_LIBOR_7=LIBOR_7-lag(LIBOR_7);
tr_LIBOR_14=LIBOR_14-lag(LIBOR_14);
tr_LIBOR_28=LIBOR_28-lag(LIBOR_28);
tr_LIBOR_91=LIBOR_91-lag(LIBOR_91);
tr_LIBOR_182=LIBOR_182-lag(LIBOR_182);
tr_LIBOR_364=LIBOR_364-lag(LIBOR_364);
tr_LIBOR_728=LIBOR_728-lag(LIBOR_728);
tr_LIBOR_1092=LIBOR_1092-lag(LIBOR_1092);
tr_LIBOR_1456=LIBOR_1456-lag(LIBOR_1456);
tr_LIBOR_1820=LIBOR_1820-lag(LIBOR_1820);
tr_LIBOR_2180=LIBOR_2180-lag(LIBOR_2180);
tr_LIBOR_2548=LIBOR_2548-lag(LIBOR_2548);
tr_LIBOR_2912=LIBOR_2912-lag(LIBOR_2912);
tr_LIBOR_3276=LIBOR_3276-lag(LIBOR_3276);
tr_LIBOR_3640=LIBOR_3640-lag(LIBOR_3640);
tr_LIBOR_4004=LIBOR_4004-lag(LIBOR_4004);
tr_LIBOR_4368=LIBOR_4368-lag(LIBOR_4368);
tr_LIBOR_4732=LIBOR_4732-lag(LIBOR_4732);
tr_LIBOR_5096=LIBOR_5096-lag(LIBOR_5096);
tr_LIBOR_5460=LIBOR_5460-lag(LIBOR_5460);
tr_LIBOR_5824=LIBOR_5824-lag(LIBOR_5824);
tr_LIBOR_6188=LIBOR_6188-lag(LIBOR_6188);
tr_LIBOR_6552=LIBOR_6552-lag(LIBOR_6552);
tr_LIBOR_6916=LIBOR_6916-lag(LIBOR_6916);
tr_LIBOR_7280=LIBOR_7280-lag(LIBOR_7280);
tr_LIBOR_7644=LIBOR_7644-lag(LIBOR_7644);
tr_LIBOR_8008=LIBOR_8008-lag(LIBOR_8008);
tr_LIBOR_8372=LIBOR_8372-lag(LIBOR_8372);
tr_LIBOR_8736=LIBOR_8736-lag(LIBOR_8736);
tr_LIBOR_9020=LIBOR_9020-lag(LIBOR_9020);
tr_LIBOR_9464=LIBOR_9464-lag(LIBOR_9464);
tr_LIBOR_9828=LIBOR_9828-lag(LIBOR_9828);
tr_LIBOR_10192=LIBOR_10192-lag(LIBOR_10192);
tr_LIBOR_10556=LIBOR_10556-lag(LIBOR_10556);
tr_LIBOR_10800=LIBOR_10800-lag(LIBOR_10800);
tr_LIBOR_10920=LIBOR_10920-lag(LIBOR_10920);

run;


proc sql;
	create table mylib.currentdata as
	select *
	from mylib.market_data_2
	where date="20JUN2016"d
	;
quit;

proc sql;
	create table mylib.simstate_hs as
	select 
	b.date
	/* Repeat as many risk factors you have */
, a.AMXL*(b.tr_AMXL+1) as AMXL
, a.AAPL*(b.tr_AAPL+1) as AAPL
, a.JPM*(b.tr_JPM+1) as JPM
, a.USDMXN*(b.tr_USDMXN+1) as USDMXN
, a.CETES_1*(b.tr_CETES_1+1) as CETES_1
, a.CETES_7*(b.tr_CETES_7+1) as CETES_7
, a.CETES_14*(b.tr_CETES_14+1) as CETES_14
, a.CETES_28*(b.tr_CETES_28+1) as CETES_28
, a.CETES_91*(b.tr_CETES_91+1) as CETES_91
, a.CETES_182*(b.tr_CETES_182+1) as CETES_182
, a.CETES_364*(b.tr_CETES_364+1) as CETES_364
, a.CETES_728*(b.tr_CETES_728+1) as CETES_728
, a.CETES_1092*(b.tr_CETES_1092+1) as CETES_1092
, a.CETES_1456*(b.tr_CETES_1456+1) as CETES_1456
, a.CETES_1820*(b.tr_CETES_1820+1) as CETES_1820
, a.CETES_2180*(b.tr_CETES_2180+1) as CETES_2180
, a.CETES_2548*(b.tr_CETES_2548+1) as CETES_2548
, a.CETES_2912*(b.tr_CETES_2912+1) as CETES_2912
, a.CETES_3276*(b.tr_CETES_3276+1) as CETES_3276
, a.CETES_3640*(b.tr_CETES_3640+1) as CETES_3640
, a.CETES_4004*(b.tr_CETES_4004+1) as CETES_4004
, a.CETES_4368*(b.tr_CETES_4368+1) as CETES_4368
, a.CETES_4732*(b.tr_CETES_4732+1) as CETES_4732
, a.CETES_5096*(b.tr_CETES_5096+1) as CETES_5096
, a.CETES_5460*(b.tr_CETES_5460+1) as CETES_5460
, a.CETES_5824*(b.tr_CETES_5824+1) as CETES_5824
, a.CETES_6188*(b.tr_CETES_6188+1) as CETES_6188
, a.CETES_6552*(b.tr_CETES_6552+1) as CETES_6552
, a.CETES_6916*(b.tr_CETES_6916+1) as CETES_6916
, a.CETES_7280*(b.tr_CETES_7280+1) as CETES_7280
, a.CETES_7644*(b.tr_CETES_7644+1) as CETES_7644
, a.CETES_8008*(b.tr_CETES_8008+1) as CETES_8008
, a.CETES_8372*(b.tr_CETES_8372+1) as CETES_8372
, a.CETES_8736*(b.tr_CETES_8736+1) as CETES_8736
, a.CETES_9020*(b.tr_CETES_9020+1) as CETES_9020
, a.CETES_9464*(b.tr_CETES_9464+1) as CETES_9464
, a.CETES_9828*(b.tr_CETES_9828+1) as CETES_9828
, a.CETES_10192*(b.tr_CETES_10192+1) as CETES_10192
, a.CETES_10556*(b.tr_CETES_10556+1) as CETES_10556
, a.CETES_10800*(b.tr_CETES_10800+1) as CETES_10800
, a.CETES_10920*(b.tr_CETES_10920+1) as CETES_10920
, a.LIBOR_1+b.tr_LIBOR_1 as LIBOR_1
, a.LIBOR_7+b.tr_LIBOR_7 as LIBOR_7
, a.LIBOR_14+b.tr_LIBOR_14 as LIBOR_14
, a.LIBOR_28+b.tr_LIBOR_28 as LIBOR_28
, a.LIBOR_91+b.tr_LIBOR_91 as LIBOR_91
, a.LIBOR_182+b.tr_LIBOR_182 as LIBOR_182
, a.LIBOR_364+b.tr_LIBOR_364 as LIBOR_364
, a.LIBOR_728+b.tr_LIBOR_728 as LIBOR_728
, a.LIBOR_1092+b.tr_LIBOR_1092 as LIBOR_1092
, a.LIBOR_1456+b.tr_LIBOR_1456 as LIBOR_1456
, a.LIBOR_1820+b.tr_LIBOR_1820 as LIBOR_1820
, a.LIBOR_2180+b.tr_LIBOR_2180 as LIBOR_2180
, a.LIBOR_2548+b.tr_LIBOR_2548 as LIBOR_2548
, a.LIBOR_2912+b.tr_LIBOR_2912 as LIBOR_2912
, a.LIBOR_3276+b.tr_LIBOR_3276 as LIBOR_3276
, a.LIBOR_3640+b.tr_LIBOR_3640 as LIBOR_3640
, a.LIBOR_4004+b.tr_LIBOR_4004 as LIBOR_4004
, a.LIBOR_4368+b.tr_LIBOR_4368 as LIBOR_4368
, a.LIBOR_4732+b.tr_LIBOR_4732 as LIBOR_4732
, a.LIBOR_5096+b.tr_LIBOR_5096 as LIBOR_5096
, a.LIBOR_5460+b.tr_LIBOR_5460 as LIBOR_5460
, a.LIBOR_5824+b.tr_LIBOR_5824 as LIBOR_5824
, a.LIBOR_6188+b.tr_LIBOR_6188 as LIBOR_6188
, a.LIBOR_6552+b.tr_LIBOR_6552 as LIBOR_6552
, a.LIBOR_6916+b.tr_LIBOR_6916 as LIBOR_6916
, a.LIBOR_7280+b.tr_LIBOR_7280 as LIBOR_7280
, a.LIBOR_7644+b.tr_LIBOR_7644 as LIBOR_7644
, a.LIBOR_8008+b.tr_LIBOR_8008 as LIBOR_8008
, a.LIBOR_8372+b.tr_LIBOR_8372 as LIBOR_8372
, a.LIBOR_8736+b.tr_LIBOR_8736 as LIBOR_8736
, a.LIBOR_9020+b.tr_LIBOR_9020 as LIBOR_9020
, a.LIBOR_9464+b.tr_LIBOR_9464 as LIBOR_9464
, a.LIBOR_9828+b.tr_LIBOR_9828 as LIBOR_9828
, a.LIBOR_10192+b.tr_LIBOR_10192 as LIBOR_10192
, a.LIBOR_10556+b.tr_LIBOR_10556 as LIBOR_10556
, a.LIBOR_10800+b.tr_LIBOR_10800 as LIBOR_10800
, a.LIBOR_10920+b.tr_LIBOR_10920 as LIBOR_10920

	from mylib.currentdata a , mylib.market_data_2_ch b
	;
quit;



proc iml;

/*
	Method Stock_PricingM  desc="Método Acciones" Kind=price;

		_value_=0;

		if compress(upcase(LocalCurrency))  = "MXN" then _VALUE_ = PRICE.ref_price;	
		else _VALUE_ = PRICE.ref_price;

	endmethod;
*/

start StockPrice(ref_price,date);
/*Price of the stock in its native currency*/
	value=0;
   sum = x+y;
   return(value);
finish;

a = {9 2, 5 7};
b = {1 6, 8 10};
c = Add(a,b);
print c;

quit;