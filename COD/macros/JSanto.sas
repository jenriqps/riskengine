%macro JSanto(tr=*);

	function JSanto(Fecha)
   	kind = "Utility functions"
   	label = "Indicates if a date is a Holy Thursday";

		anio = year(Fecha);
		a = mod(anio,19);
		b = mod(anio,4);
		c = mod(anio,7);
		d = mod((19 * a + 24),30);
		e = mod((2 * b + 4 * c + 6 * d + 5),7);

		if d+e < 10 then do;
			dia = d + e + 22;
			mes = 3;
		end;
		else do;
			dia = d + e - 9;
			mes = 4;
		end;

		if dia = 26  and mes = 4 then dia = 19;

		if dia = 25 and mes = 4 and d = 28 and e = 6 and a > 10 then dia = 18;

		if mdy(mes, dia, anio) - 3 = Fecha then JSanto = 1;
		return(Jsanto);
	endsub;

%mend;
