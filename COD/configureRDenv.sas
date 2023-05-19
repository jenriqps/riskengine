
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
		array US_Curve ir currency= USD 
		label= "US Treasury Rate Curve" group = "Interest Rate"
		ELEMENTS=(US_3M US_6M US_12M US_24M US_36M US_60M US_84M)
		refmap=(ir_ref="UStreas");
		
		array US_Curve_AAA ir currency = USD
		label = "US Treasury Rate Curve - AAA" group = "Interest Rate"
		ELEMENTS =(US_3M_AAA US_6M_AAA US_12M_AAA US_24M_AAA US_36M_AAA US_60M_AAA US_84M_AAA)
		refmap=(cred_ir_ref="UStreas_AAA");
		
		array US_Curve_AA ir currency = USD
		label = "US Treasury Rate Curve - AA" group = "Interest Rate"
		ELEMENTS =(US_3M_AA US_6M_AA US_12M_AA US_24M_AA US_36M_AA US_60M_AA US_84M_AA)
		refmap=(cred_ir_ref="UStreas_AA");
		
		array US_Curve_A ir currency = USD
		label = "US Treasury Rate Curve - A" group = "Interest Rate"
		ELEMENTS =(US_3M_A US_6M_A US_12M_A US_24M_A US_36M_A US_60M_A US_84M_A)
		refmap=(cred_ir_ref="UStreas_A");
		
		array US_Curve_BBB ir currency = USD
		label = "US Treasury Rate Curve - BB" group = "Interest Rate"
		ELEMENTS =(US_3M_BBB US_6M_BBB US_12M_BBB US_24M_BBB US_36M_BBB US_60M_BBB US_84M_BBB)
		refmap=(cred_ir_ref="UStreas_BBB");
		
		array US_Curve_BB ir currency = USD
		label = "US Treasury Rate Curve - AA" group = "Interest Rate"
		ELEMENTS =(US_3M_BB US_6M_BB US_12M_BB US_24M_BB US_36M_BB US_60M_BB US_84M_BB)
		refmap=(cred_ir_ref="UStreas_BB");
		
		array US_Curve_B ir currency = USD
		label = "US Treasury Rate Curve - AA" group = "Interest Rate"
		ELEMENTS =(US_3M_B US_6M_B US_12M_B US_24M_B US_36M_B US_60M_B US_84M_B)
		refmap=(cred_ir_ref="UStreas_B");
		
		array US_Curve_CCC ir currency = USD
		label = "US Treasury Rate Curve - AA" group = "Interest Rate"
		ELEMENTS =(US_3M_CCC US_6M_CCC US_12M_CCC US_24M_CCC US_36M_CCC US_60M_CCC US_84M_CCC)
		refmap=(cred_ir_ref="UStreas_CCC");

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
		variables = (ref_price LocalCurrency ReferenceCurrency Holding ShortPosition ALPosition)
		methods = (price Stock_PricingM);
	    /* (27MAR2023,EP) Defines RF transformation using static parameter matrix */
		Instrument CorpBond
		variables=(ALType ALPosition ShortPosition MaturityDate holding Currency Par_LC Coup_Freq Coupon 
		Company Rates CRRates cred_rate Employee TypeOfIndustry tradeGroupID )
		methods = (price Bond_Price);
		/* (19MAY2023,EP) */
		/*MORTGAGE_TYPE*/
		instrument mortgage
		   variables = (rate_type, holding, principal, term_mos, cpn_rate, guar_entity, jumbo, credit_scr, Rates, monthly_cf, MaturityDate,RemainingBal,LoanOfficer)
		   methods= (price Mort_price);
		
		/*MORTGAGE_CF_TYPE*/
		instrument mortcf
		   valrecord = CASHFLOWS
		   variables = (rate_type, holding, principal, term_mos, cpn_rate, guar_entity, jumbo, credit_scr, Rates, CFMatDate, RemainingBal, LoanOfficer)
		   methods = (price Mortcf_Price);

	    /* (27MAR2023,EP) Defines RF transformation using static parameter matrix */
	    RFTRANS static_parameter_matrix static_parameter;
	env save;
run;


