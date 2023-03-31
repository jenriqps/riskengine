/**********************************************************************
 * RISK ENGINE;
 * Jose Enrique Perez ;
 * Licenciatura en Actuaría;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/




* Options for the detail of the log;
options mprint  mlogic mautosource mcompile mlogicnest mprintnest msglevel=n minoperator fullstimer symbolgen source2; 

* Root folder directory;
* Change me in according to your SAS session!;
%let root = /shared/home/perez-jose@lasallistas.org.mx/riesgos_financieros/riskengine;

%global SubFolder;
%let SubFolder=;

* Base date;
%let baseDateTime = 15AUG2022:20:07:00.00;

* Getting the base date from the base date time;
data _null_;
	aux = put(datepart("&baseDateTime."dt),date9.);
	call symputx("baseDate",aux,'G');
run;

%put &baseDateTime.;
%put &baseDate.;

/* Hyperparameters */

/* Start and end date to collect historical data*/
%let startdate=15AUG2018;
%let enddate=15AUG2022;

/* Confidence of the VaR*/
%let conf=0.05;

/* Percentile definition */
%let perc_def=4;

/* Horizon of the VaR*/
%let h=1;

/* Number of simulations */
%let nsim=1000;

* Folders for data, codes and logs;
%let rootdat = &root./DAT;
%let rootcod = &root./COD;
%let rootlog = &root./LOG;

* Macrovariable with the directory of the RD environment;
%let rdenv = &rootdat./rdenv;

* We get the name of the environment;
data _null_;
	c = "&rdenv.";
	l = length(c);
	p = find(c,"/",-l);
	s = substr(c,p+1,32);
	call symputx('rdenvnam',s,'G');
run;

%put &rdenvnam.;

* Libraries to check the input and output data sets;
libname env "&rootdat.";
libname toRD "&rootdat./toRD";
libname portRD "&rdenv./_RD_PORTS/all_deals_list"; 
libname frmRDval "&rdenv./val"; 
libname frmRDrsk "&rdenv./mktrisk";
libname curexp "&rdenv./CurExp";
libname potexp "&rdenv./Potential_Exposure";
libname models "&rootdat./toRD/Models";

* Deleting previous results;
proc datasets lib=tord kill nodetails nolist;
run;

/* As the log is big, we send it to a file */
/* Change the path to adjust it to your user */
filename myoutput "&rootlog./riskengine_&baseDate._&SysDate._%sysfunc(time(),time8.0).txt";
proc printto log=myoutput;
run;

/* Importing the portfolio */
%include "&rootcod./importPort.sas";

/* Importing the market data */
%include "&rootcod./importMktData.sas";

/* Importing the configuration of risk factors and instrument variables */
%include "&rootcod./importRF.sas";

/* Making the risk environment */
%include "&rootcod./createRDenv.sas";

/* Configuring the risk environment */
%include "&rootcod./configureRDenv.sas";

/* Loading the portfolio to the risk environment */
%include "&rootcod./loadPortf2RDenv.sas";

/* Loading the current market data to the risk environment */
%include "&rootcod./loadMktData2RDenv.sas";

/* Loading the historical market data to the risk environment */
%include "&rootcod./loadHistMktData2RDenv.sas";

/* Computing the market value of the portfolio */

* Destination of the valuation log;
filename vallog "&rootlog./vallog_&baseDate._&SysDate._%sysfunc(time(),time8.0).txt";
proc printto print=vallog;
run;

%include "&rootcod./valuateRDenv.sas";

proc printto;
run;


/* Making and running the risk analysis */
%include "&rootcod./createRDanalysis.sas";
%include "&rootcod./runRDproject.sas";


/* We return the log to the usual output */
proc printto;
run;

proc sql;
	select
	resultName
	, MtM
	, N 
	, var
	, var_l
	, var_u
	, varpct
	, varpct_l
	, varpct_u
	, es
	from FRMRDRSK.SIMSTAT
	;
quit;

proc print data=curexp.summary; 
run;

proc print data=curexp.instvals; 
run;


/* Visualization */

ods graphics / reset width=6.4in height=4.8in imagemap noborder;

proc sort data=FRMRDRSK.SIMVALUE out=_HistogramTaskData;
	by AnalysisName;
run;

proc sgplot data=_HistogramTaskData;
	by AnalysisName;
	histogram Value /;
	yaxis grid;
run;

proc sgplot data=_HistogramTaskData;
	by AnalysisName;
	histogram pl /;
	yaxis grid;
run;


ods graphics / reset;

proc datasets library=WORK noprint;
	delete _HistogramTaskData;
	run;
