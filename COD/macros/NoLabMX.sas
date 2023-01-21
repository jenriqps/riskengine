%macro NoLabMX(tr=*);

	function NoLabMX(Fecha)
   	kind = "Utility functions"
   	label = "Indicates if a date is a Mexican holiday";

	
		a = Weekday(Fecha);

		If a = 1 Or a = 7 Then 
			do;
				NoLabMX = 1;
				return(NoLabMX);
			end;
		else 
			do;
				dia = Day(Fecha);
				mes = Month(Fecha);
				anio = Year(Fecha);
				NoLabMX = 0;
	
				if mes = 1 and dia = 1 Then NoLabMX = 1;
	
				if mes = 2 and dia = plunes(Fecha) Then NoLabMX = 1;
	
				if mes = 3 then do;
					if dia = 21 and anio <= 2006 Then NoLabMX = 1;
					if dia = tlunes(Fecha) and anio > 2006 then NoLabMX = 1;
					if JSanto(Fecha) = 1 Then NoLabMX = 1;
					If VSanto(Fecha) = 1 Then NoLabMX = 1;
				end;
	
				if mes = 4 then do;
					If JSanto(Fecha) = 1 Then NoLabMX = 1;
					If VSanto(Fecha) = 1 Then NoLabMX = 1;
				end;
	
				if mes = 5 and dia = 1 Then NoLabMX = 1;
	
				if mes = 9 then do;
					If dia = 16 Then NoLabMX = 1;
					If dia = 17 And anio = 2010 Then NoLabMX = 1;
				end;
	
				if mes = 11 then do;
					If dia = 2 Then NoLabMX = 1;
					If dia = tlunes(Fecha) Then	NoLabMX = 1;
				end;
	
				if mes = 12 then do;
					If dia = 12 or dia = 25 Then NoLabMX = 1;
					else if dia = 1 and mod((anio - 2000),6) = 0 then NoLabMX = 1;
				end;
	
				return(NoLabMX);
			end;
			
	endsub;


%mend;
