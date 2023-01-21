/*****************************************************************************

   NAME: importPort.sas

   PURPOSE: To import the portfolio

   INPUTS: portfolio.xlsx

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


%put &=rootdat.;

FILENAME REFFILE DISK "&rootdat./input/portfolio.xlsx";

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=toRD.portfolio replace;
	GETNAMES=YES;
RUN;


