/*****************************************************************************

   NAME: importRF.sas

   PURPOSE: To import the risk factors file

   INPUTS: configuration.xlsx

   NOTES: -

 *****************************************************************************/



proc sql;
%if %sysfunc(exist(WORK.IMPORT)) %then %do;
    drop table WORK.IMPORT;
%end;
%if %sysfunc(exist(WORK.IMPORT,VIEW)) %then %do;
    drop view WORK.IMPORT;
%end;
quit;



FILENAME REFFILE DISK "&rootdat./input/configuration.xlsx";

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=toRD.riskfactors replace;
	sheet=config_rf;
	GETNAMES=YES;
RUN;

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=toRD.instvars replace;
	sheet=instvars;
	GETNAMES=YES;
RUN;

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=toRD.refvars replace;
	sheet=refvars;
	GETNAMES=YES;
RUN;


