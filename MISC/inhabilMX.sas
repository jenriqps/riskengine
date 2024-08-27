
%macro set_InhabilMX();

		/*Funcion que nos dice si 'Fecha' cae en jueves santo*/
	function JSanto(Fecha);
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
	
	/*Funcion que nos dice si 'Fecha' cae en viernes santo*/
	function VSanto(Fecha);
		if JSanto(Fecha - 1) = 1 then VSanto = 1;
		return(Vsanto);
	endsub;

	/*Funcion que verifica si la fecha cae en el primer lunes del mes*/
	function plunes(Fecha);
		anio = Year(Fecha);
		mes = Month(Fecha);
		dia = Day(Fecha);
		primerdia = (mdy(mes,1,anio));
		primerdiasem = Weekday(primerdia);

		If primerdiasem = 1 Then
			fechan = primerdia + 1;
		Else If primerdiasem = 2 Then
			fechan = primerdia;
		Else If primerdiasem = 3 Then
			fechan = primerdia + 6;
		Else If primerdiasem = 4 Then
			fechan = primerdia + 5;
		Else If primerdiasem = 5 Then
			fechan = primerdia + 4;
		Else If primerdiasem = 6 Then
			fechan = primerdia + 3;
		Else If primerdiasem = 7 Then
			fechan = primerdia + 2;
		plunes = Day(fechan);
		return(plunes);
	endsub;

	/*Funcion que verifica si la fecha cae en el tercer lunes del mes*/
	function tlunes(Fecha);
		anio = Year(Fecha);
		mes = Month(Fecha);
		dia = Day(Fecha);
		primerdia = (mdy(mes,1,anio));
		primerdiasem = Weekday(primerdia);

		If primerdiasem = 1 Then
			fechan = primerdia + 15;
		Else If primerdiasem = 2 Then
			fechan = primerdia + 14;
		Else If primerdiasem = 3 Then
			fechan = primerdia + 20;
		Else If primerdiasem = 4 Then
			fechan = primerdia + 19;
		Else If primerdiasem = 5 Then
			fechan = primerdia + 18;
		Else If primerdiasem = 6 Then
			fechan = primerdia + 17;
		Else If primerdiasem = 7 Then
			fechan = primerdia + 16;
		tlunes = Day(fechan);
		return(tlunes);
	endsub;

	/*Funcion que verifica si la fecha de entrada es di­a inhabil*/
	function NoLabMX(Fecha);
		a = Weekday(Fecha);

		If a = 1 Or a = 7 Then do;
			NoLabMX = 1;
			return(NoLabMX);
		end;
		else do;
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
run;

%mend;




