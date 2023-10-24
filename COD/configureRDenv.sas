
/*****************************************************************************

   NAME: configureRDenv_aim.sas

   PURPOSE: To configure the Risk Dimensions environment i.e.  define instrument variables, risk factors, reference variables and valuation formulas

   INPUTS: toRD.instvars, toRD.riskfactors, toRD.refvars

   NOTES: 

 *****************************************************************************/

* We add the macro that contains the includes to the macro valuation methods and functions;
%include "&rootcod./macros/interpo.sas";
%include "&rootcod./macros/interpolar.sas";
%include "&rootcod./macros/LstMthsDy.sas";
%include "&rootcod./macros/FWD_Rate.sas";
%include "&rootcod./macros/NoLabUS.sas";
%include "&rootcod./macros/NoLabMX.sas";
%include "&rootcod./macros/JSanto.sas";
%include "&rootcod./macros/VSanto.sas";
%include "&rootcod./macros/plunes.sas";
%include "&rootcod./macros/tlunes.sas";
%include "&rootcod./macros/DiasHab_entre_dos_fechas.sas";
%include "&rootcod./macros/DiaHabil.sas";
%include "&rootcod./macros/Fecha_masmenos_dias_habiles.sas";
%include "&rootcod./macros/Stock_PricingM.sas";
%include "&rootcod./macros/static_parameter.sas";
%include "&rootcod./macros/Bond_Price.sas";
/* (19MAY2023,EP) */
%include "&rootcod./macros/Mort_Price.sas";
%include "&rootcod./macros/Mortcf_Price.sas";
%include "&rootcod./macros/cfdiscount.sas";

proc risk;
	env open = "&rdenv.";
		* We declare variables of instruments;
		readvars data = toRD.instvars; 		
		* We declare risk factors (prices);
		readvars data = toRD.riskfactors;
		* We declare the reference variables;
		declare references = (PRICE num var);
		declare references = (REF_DIVISAS num var);
		* We declare references to risk factors (prices);
		readrefs data = toRD.refvars;
      /* (11MAY2023, EP) Time Grids */
      TIMEGRID One_month (1 month);

      TIMEGRID TimeGrid1 (1 month, 2 month, 3 month, 4 month, 5 month, 6 month,
                     7 month, 8 month, 9 month, 10 month, 11 month, 12 month);
      TIMEGRID TimeGrid2 (3 month, 6 month, 9 month, 12 month);


      /* (27MAR2023,EP) Static Parameter matrices */
      MARKETDATA  static_param_mat 
               file = toRD.parammat_static 
               type = parameters;

      PARAMETER   StaticSpreads
               data = static_param_mat;

		/* (27MAR2023,EP) RDARRAYS and RDREFS*/
		/* (04SEP2023,EP) New curves */
		array CETES ir currency = MXN
		label = "Curva CETES" group = "Interest Rate"
		ELEMENTS =(CETES_1 CETES_7 CETES_14 CETES_28 CETES_91 CETES_182 CETES_364 CETES_728 CETES_1092 
		CETES_1456 CETES_1820 CETES_2180 CETES_2548 CETES_2912 CETES_3276 CETES_3640 CETES_4004 CETES_4368 
		CETES_4732 CETES_5096 CETES_5460 CETES_5824 CETES_6188 CETES_6552 CETES_6916 CETES_7280 CETES_7644
		CETES_8008 CETES_8372 CETES_8736 CETES_9020 CETES_9464 CETES_9828 CETES_10192 CETES_10556 CETES_10800 CETES_10920)
		refmap=(ir_ref="CETES");
		
		array MX_AAA ir currency = MXN
		label = "MX Curve - AAA" group = "Interest Rate"
		ELEMENTS =(
		MX_AAA_1 MX_AAA_7 MX_AAA_14 MX_AAA_28 MX_AAA_91 MX_AAA_182 MX_AAA_364 MX_AAA_728 MX_AAA_1092 
		MX_AAA_1456 MX_AAA_1820 MX_AAA_2180 MX_AAA_2548 MX_AAA_2912 MX_AAA_3276 MX_AAA_3640 MX_AAA_4004 MX_AAA_4368 
		MX_AAA_4732 MX_AAA_5096 MX_AAA_5460 MX_AAA_5824 MX_AAA_6188 MX_AAA_6552 MX_AAA_6916 MX_AAA_7280 MX_AAA_7644
		MX_AAA_8008 MX_AAA_8372 MX_AAA_8736 MX_AAA_9020 MX_AAA_9464 MX_AAA_9828 MX_AAA_10192 MX_AAA_10556 MX_AAA_10800 MX_AAA_10920
		)
		refmap=(cred_ir_ref="MX_AAA");
		
		array MX_AA ir currency = MXN
		label = "MX Curve - AA" group = "Interest Rate"
		ELEMENTS =(
		MX_AA_1 MX_AA_7 MX_AA_14 MX_AA_28 MX_AA_91 MX_AA_182 MX_AA_364 MX_AA_728 MX_AA_1092 
		MX_AA_1456 MX_AA_1820 MX_AA_2180 MX_AA_2548 MX_AA_2912 MX_AA_3276 MX_AA_3640 MX_AA_4004 MX_AA_4368 
		MX_AA_4732 MX_AA_5096 MX_AA_5460 MX_AA_5824 MX_AA_6188 MX_AA_6552 MX_AA_6916 MX_AA_7280 MX_AA_7644
		MX_AA_8008 MX_AA_8372 MX_AA_8736 MX_AA_9020 MX_AA_9464 MX_AA_9828 MX_AA_10192 MX_AA_10556 MX_AA_10800 MX_AA_10920
		)
		refmap=(cred_ir_ref="MX_AA");
		
		array MX_A ir currency = MXN
		label = "MX Curve - A" group = "Interest Rate"
		ELEMENTS =(
		MX_A_1 MX_A_7 MX_A_14 MX_A_28 MX_A_91 MX_A_182 MX_A_364 MX_A_728 MX_A_1092 
		MX_A_1456 MX_A_1820 MX_A_2180 MX_A_2548 MX_A_2912 MX_A_3276 MX_A_3640 MX_A_4004 MX_A_4368 
		MX_A_4732 MX_A_5096 MX_A_5460 MX_A_5824 MX_A_6188 MX_A_6552 MX_A_6916 MX_A_7280 MX_A_7644
		MX_A_8008 MX_A_8372 MX_A_8736 MX_A_9020 MX_A_9464 MX_A_9828 MX_A_10192 MX_A_10556 MX_A_10800 MX_A_10920
		)
		refmap=(cred_ir_ref="MX_A");
		
		array MX_BBB ir currency = MXN
		label = "MX Curve - BBB" group = "Interest Rate"
		ELEMENTS =(
		MX_BBB_1 MX_BBB_7 MX_BBB_14 MX_BBB_28 MX_BBB_91 MX_BBB_182 MX_BBB_364 MX_BBB_728 MX_BBB_1092 
		MX_BBB_1456 MX_BBB_1820 MX_BBB_2180 MX_BBB_2548 MX_BBB_2912 MX_BBB_3276 MX_BBB_3640 MX_BBB_4004 MX_BBB_4368 
		MX_BBB_4732 MX_BBB_5096 MX_BBB_5460 MX_BBB_5824 MX_BBB_6188 MX_BBB_6552 MX_BBB_6916 MX_BBB_7280 MX_BBB_7644
		MX_BBB_8008 MX_BBB_8372 MX_BBB_8736 MX_BBB_9020 MX_BBB_9464 MX_BBB_9828 MX_BBB_10192 MX_BBB_10556 MX_BBB_10800 MX_BBB_10920
		)
		refmap=(cred_ir_ref="MX_BBB");
		
		array MX_BB ir currency = MXN
		label = "MX Curve - BB" group = "Interest Rate"
		ELEMENTS =(
		MX_BB_1 MX_BB_7 MX_BB_14 MX_BB_28 MX_BB_91 MX_BB_182 MX_BB_364 MX_BB_728 MX_BB_1092 
		MX_BB_1456 MX_BB_1820 MX_BB_2180 MX_BB_2548 MX_BB_2912 MX_BB_3276 MX_BB_3640 MX_BB_4004 MX_BB_4368 
		MX_BB_4732 MX_BB_5096 MX_BB_5460 MX_BB_5824 MX_BB_6188 MX_BB_6552 MX_BB_6916 MX_BB_7280 MX_BB_7644
		MX_BB_8008 MX_BB_8372 MX_BB_8736 MX_BB_9020 MX_BB_9464 MX_BB_9828 MX_BB_10192 MX_BB_10556 MX_BB_10800 MX_BB_10920
		)
		refmap=(cred_ir_ref="MX_BB");
		
		array MX_B ir currency = MXN
		label = "MX Curve - B" group = "Interest Rate"
		ELEMENTS =(
		MX_B_1 MX_B_7 MX_B_14 MX_B_28 MX_B_91 MX_B_182 MX_B_364 MX_B_728 MX_B_1092 
		MX_B_1456 MX_B_1820 MX_B_2180 MX_B_2548 MX_B_2912 MX_B_3276 MX_B_3640 MX_B_4004 MX_B_4368 
		MX_B_4732 MX_B_5096 MX_B_5460 MX_B_5824 MX_B_6188 MX_B_6552 MX_B_6916 MX_B_7280 MX_B_7644
		MX_B_8008 MX_B_8372 MX_B_8736 MX_B_9020 MX_B_9464 MX_B_9828 MX_B_10192 MX_B_10556 MX_B_10800 MX_B_10920		
		)
		refmap=(cred_ir_ref="MX_B");
		
		array MX_CCC ir currency = MXN
		label = "MX Curve - CCC" group = "Interest Rate"
		ELEMENTS =(
		MX_CCC_1 MX_CCC_7 MX_CCC_14 MX_CCC_28 MX_CCC_91 MX_CCC_182 MX_CCC_364 MX_CCC_728 MX_CCC_1092 
		MX_CCC_1456 MX_CCC_1820 MX_CCC_2180 MX_CCC_2548 MX_CCC_2912 MX_CCC_3276 MX_CCC_3640 MX_CCC_4004 MX_CCC_4368 
		MX_CCC_4732 MX_CCC_5096 MX_CCC_5460 MX_CCC_5824 MX_CCC_6188 MX_CCC_6552 MX_CCC_6916 MX_CCC_7280 MX_CCC_7644
		MX_CCC_8008 MX_CCC_8372 MX_CCC_8736 MX_CCC_9020 MX_CCC_9464 MX_CCC_9828 MX_CCC_10192 MX_CCC_10556 MX_CCC_10800 MX_CCC_10920
		)
		refmap=(cred_ir_ref="MX_CCC");


		array IRS ir currency = MXN
		label = "Curva IRS" group = "Interest Rate"
		ELEMENTS =(
		IRS_1 IRS_7 IRS_14 IRS_28 IRS_91 IRS_182 IRS_364 IRS_728 IRS_1092 IRS_1456 IRS_1820 IRS_2180 IRS_2548 IRS_2912 
		IRS_3276 IRS_3640 IRS_4004 IRS_4368 IRS_4732 IRS_5096 IRS_5460 IRS_5824 IRS_6188 IRS_6552 IRS_6916 IRS_7280 
		IRS_7644 IRS_8008 IRS_8372 IRS_8736 IRS_9020 IRS_9464)
		refmap=(cred_ir_ref="IRS");

		array LIBOR ir currency = USD
		label = "Curva LIBOR" group = "Interest Rate"
		ELEMENTS =(
		LIBOR_1 LIBOR_7 LIBOR_14 LIBOR_28 LIBOR_91 LIBOR_182 LIBOR_364 LIBOR_728 LIBOR_1092 LIBOR_1456 LIBOR_1820 LIBOR_2180 
		LIBOR_2548 LIBOR_2912 LIBOR_3276 LIBOR_3640 LIBOR_4004 LIBOR_4368 LIBOR_4732 LIBOR_5096 LIBOR_5460 LIBOR_5824 LIBOR_6188 
		LIBOR_6552 LIBOR_6916 LIBOR_7280 LIBOR_7644 LIBOR_8008 LIBOR_8372 LIBOR_8736 LIBOR_9020 LIBOR_9464 LIBOR_9828 LIBOR_10192 
		LIBOR_10556 LIBOR_10800 LIBOR_10920
		)
		refmap=(cred_ir_ref="LIBOR");

	env save;
run;

* We compile the valuation methods and functions;
proc compile outlib = "&rdenv." environment = "&rdenv." package = valuation_funcs;
/* Functions for general use: */
	%interpo(tr=*);	
	%LstMthsDy(tr=*);
	%FWD_Rate(tr=*);	
	%JSanto(tr=*);
	%VSanto(tr=*);
	%plunes(tr=*);
	%tlunes(tr=*);
	%NoLabUS(tr=*);
	%NoLabMx(tr=*);
	%interpolar(tr=*);
	%DiasHab_entre_dos_fechas(tr=*);
	%DiaHabil(tr=*);
	%Fecha_masmenos_dias_habiles(tr=*);
	%Stock_PricingM();

	/* (27MAR2023,EP) */
	%static_parameter();
	%Bond_Price();
	/* (19MAY2023,EP) */
	%cfdiscount();
	%Mort_Price();
	%Mortcf_Price();
run;


* We load the type of instruments;
proc risk;
	env open = "&rdenv.";
		Instrument Stock 
		variables = (ref_price LocalCurrency ReferenceCurrency Holding ShortPosition ALPosition TypeOfIndustry Employee Company Currency)
		methods = (price Stock_PricingM);
	    /* (27MAR2023,EP) Defines RF transformation using static parameter matrix */
		Instrument CorpBond
		variables=(ALType ALPosition ShortPosition MaturityDate holding Currency Par_LC Coup_Freq Coupon 
		Company Rates CRRates cred_rate Employee TypeOfIndustry tradeGroupID )
		methods = (price Bond_Price);
		/* (19MAY2023,EP) */
		/*MORTGAGE_TYPE*/
		instrument mortgage
		   variables = (rate_type, holding, principal, term_mos, cpn_rate, guar_entity, jumbo, credit_scr, Rates, monthly_cf, 
						MaturityDate,RemainingBal,LoanOfficer,TypeOfIndustry, Company, Employee)
		   methods= (price Mort_price);
		
		/*MORTGAGE_CF_TYPE*/
		instrument mortcf
		   valrecord = CASHFLOWS
		   variables = (rate_type, holding, principal, term_mos, cpn_rate, guar_entity, jumbo, credit_scr, Rates, CFMatDate, RemainingBal, 
						LoanOfficer,TypeOfIndustry, Company, Employee)
		   methods = (price Mortcf_Price);

	    /* (27MAR2023,EP) Defines RF transformation using static parameter matrix */
	    RFTRANS static_parameter_matrix static_parameter;
		/* (06SEP2023,EP) Variables to aggregate the results */
		crossclass mrcc (instSource TypeOfIndustry Company Employee InstID);
		crossclass LoanOffByGuar (LoanOfficer guar_entity);
	env save;
run;


