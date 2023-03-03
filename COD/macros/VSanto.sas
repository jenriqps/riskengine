%macro VSanto(tr=*);

	function VSanto(Fecha)

   	kind = "Utility functions"
   	label = "Indicates if a date is a Holy Friday";

	
		if JSanto(Fecha - 1) = 1 then VSanto = 1;
		return(Vsanto);
	endsub;

%mend;	


