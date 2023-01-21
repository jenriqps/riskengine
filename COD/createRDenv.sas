/*****************************************************************************

   NAME: createRDenv.sas

   PURPOSE: To import the risk dimensions environment

   INPUTS: -

   NOTES: -

 *****************************************************************************/


proc risk; 
	* We delete the previous RD environment;
	delete environment = "&rdenv.";
	* Creation of the RD environment;
	setoptions pctldef=&perc_def.;
	env new = "&rdenv." label="Risk Engine";
	env save;
run;
