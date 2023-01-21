%macro 	interpo(tr=);
	function interpo(t,Rate[*],Mat[*])
   	kind = "Utility functions"
   	label = "Interpolates rates";
			
		/* OUPS, 14FEB2020 */
		/*n = Dim(Rate);*/
		n = Dim(Mat);
		fact=365.25;

	   	array tasas2[1]/nosymbols;
	   	call dynamic_array(tasas2,n);

		*  We update this function in order to extrapolate (with the last rate) in case that the market data provides missing values ;
		
		* We get the first non missing rate;
		do i = 1 to n;
			if Rate{i} ne . then 
				do;
					lastRate = Rate{i};
					lastNode = i;
					&tr. put lastRate= lastNode=;
				end;
		end;
		
		* We impute the last known rate for far terms with missing values ;
		do i = n to lastNode by -1;
			if Rate{i} eq . then tasas2{i} = lastRate; 
		end;
		
		do i = lastNode to 1 by -1;
			tasas2{i} = Rate{i}; 
		end;

		if t=0 then interpo=0;
		else if t <= Mat[1]*fact then interpo = tasas2[1]; 
		else if t >= Mat[n]*fact then interpo = tasas2[n]; 
		else do;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
        	do i=2 to n; 
				If Mat[i-1]*fact<=t<=Mat[i]*fact then do;
					t2=Mat[i-1]*fact;
					t1=Mat[i]*fact;
					interpo = tasas2[i-1]+((tasas2[i]-tasas2[i-1])/((Mat[i]-Mat[i-1])*fact)*(t-Mat[i-1]*fact));
				end;
			end;
		end; 
       	return(interpo);
	endsub;
%mend;

