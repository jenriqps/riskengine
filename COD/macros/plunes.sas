%macro plunes(tr=*);

	/*Función que verifica si la fecha cae en el primer lunes del mes*/
	function plunes(Fecha)
   	kind = "Utility functions"
   	label = "Indicates if a date is the first Monday of the month";
	
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
	
%mend;
