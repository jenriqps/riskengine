%macro interpolar(tr=*);

	function interpolar(t,dias{*},tasas{*})
   	kind = "Utility functions"
   	label = "Interpolates rates (alternative version)";

	n = dim(dias);	
	fact = 365.25;

   	
   	array tasas2[1]/nosymbols;
   	call dynamic_array(tasas2,n);
		
		* (EP,15JAN2019);
		*  We update this function in order to extrapolate (with the last rate) in case that the market data provides missing values ;
		
		* We get the first non missing rate;
		do i = 1 to n;
			if tasas{i} ne . then 
				do;
					lastRate = tasas{i};
					lastNode = i;
					&tr. put lastRate= lastNode=;
				end;
		end;
		
		* We impute the last known rate for far terms with missing values ;
		do i = n to lastNode by -1;
			if tasas{i} eq . then tasas2{i} = lastRate; 
		end;
		
		do i = lastNode to 1 by -1;
			tasas2{i} = tasas{i}; 
		end;
		
		if t = 0 then interpo = 0;
		else if t >= dias{n}*fact then interpo = tasas2{n};
		else if t <= dias{1}*fact then interpo = tasas2{1};
		else do;
			do i = 2 to n;
				if dias{i-1}*fact <= t <= dias{i}*fact then do;
					interpo = tasas2{i-1} + (tasas2{i} - tasas2{i-1})*(t - dias{i-1}*fact)/((dias{i} - dias{i-1})*fact);
				end;
			end; 
		end;
		return(interpo);
	endsub;
	
%mend;
