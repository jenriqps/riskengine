/*****************************************************************************

   NAME: importPort.sas

   PURPOSE: To import the portfolio

   INPUTS: portfolio.xlsx

   NOTES: -

 *****************************************************************************/




%put &=rootdat.;

FILENAME REFFILE DISK "&rootdat./input/portfolio.xlsx";

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=toRD.portfolio replace;
	GETNAMES=YES;
RUN;

/* (27MAR2023,EP) Portfolio of corporate bonds */

FILENAME REFFILE DISK "&rootdat./input/corp_bond_portfolio.xlsx";

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=toRD.corp_bond_portfolio;
	GETNAMES=YES;
RUN;

/* (18MAY2023,EP) Portfolio of mortgages */

FILENAME REFFILE DISK "&rootdat./input/MORTGAGE_CF.xlsx";

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=toRD.mortgage_cf;
	GETNAMES=YES;
RUN;

FILENAME REFFILE DISK "&rootdat./input/MORTGAGE.xlsx";

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=toRD.mortgage;
	GETNAMES=YES;
RUN;


