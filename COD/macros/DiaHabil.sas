%macro DiaHabil(tr=);
	
	/*Entrada: Fecha , Salida: Fecha hábil con la convención correspondiente*/	
	function DiaHabil(Fecha, HOLIDAY_LIST_ID $, BusinessDay)
   	kind = "Utility functions"
   	label = "Business Days between 2 dates";
		if BusinessDay = 1 or BusinessDay = -1 then 
			do;
				* Mexican calendar;
				if HOLIDAY_LIST_ID='MX' then
					do while (NoLabMX(Fecha)=1);
						Fecha = sum(Fecha, BusinessDay);
					end;
				* USA calendar;
				else if HOLIDAY_LIST_ID='US' then 
					do while (NoLabUS(Fecha)=1);
						Fecha = sum(Fecha, BusinessDay);
					end;
					
				* Mexican and USA calendar;
				else if HOLIDAY_LIST_ID='MXUS' then 
					do while (NoLabMX(Fecha)=1 or NoLabUS(Fecha)=1);
						Fecha = sum(Fecha, BusinessDay);
					end;
			end;
		else
			Fecha=Fecha;
		return(Fecha);
	endsub;

%mend;
