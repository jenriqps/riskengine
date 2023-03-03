%macro tlunes(tr=*);
	
	/*Función que verifica si la fecha cae en el tercer lunes del mes*/
	function tlunes(Fecha)
   	kind = "Utility functions"
   	label = "Indicates if a date is the third Monday of the month";
	
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
	
%mend;
