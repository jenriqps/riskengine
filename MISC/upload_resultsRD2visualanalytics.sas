/*
Uploading the data sets to CAS (Cloud Analytic Services)
*/


cas; 
caslib _all_ assign;

proc casutil;
	load data=frmRDrsk.allprice outcaslib="casuser"
	casout="allprice";
	promote casdata="allprice";
run;

proc casutil;
	load data=frmRDrsk.simvalue outcaslib="casuser"
	casout="simvalue";
	promote casdata="simvalue";
run;


