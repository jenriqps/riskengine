%macro FWD_Rate(tr=);

	/*Tasa Forward*/
	function FWD_Rate(short_term,long_term,Rate_st,Rate_lt,dYear)
   	kind = "Utility functions"
   	label = "Calculates forward rates";
	
		If long_term>0 then do;
		temp1 = 1+Rate_lt*long_term/dYear;
		temp2 = 1+Rate_st*short_term/dYear;
		FWD_Rate = (temp1/temp2-1) * dYear/(long_term-short_term);
		End;
		return(FWD_Rate);
	endsub;

%mend;
