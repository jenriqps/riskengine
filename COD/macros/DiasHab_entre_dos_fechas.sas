%macro DiasHab_entre_dos_fechas(tr=);

	/*Si se tiene una fecha y se quiere sumar o restar x días hábiles. Resultado fecha*/
	function DiasHab_entre_dos_fechas(Fecha_Mayor,Fecha_Menor,HOLIDAY_LIST_ID $)
   	kind = "Utility functions"
   	label = "Business Days between 2 dates";
		diascon1=0;
		auxfecha1=Fecha_Mayor;
		if Fecha_Mayor>Fecha_Menor then
			if compress(upcase(HOLIDAY_LIST_ID))='MX' then
				do while(auxfecha1>Fecha_Menor);
					auxfecha1=sum(auxfecha1,-1);
					if (NoLabMX(auxfecha1)=1) then
						do;
							diascon1=diascon1;
						end;
					else if (NoLabMX(auxfecha1)=0) then
						do;
							diascon1=sum(diascon1,1);
						end;
				end;

			else if compress(upcase(HOLIDAY_LIST_ID))='US' then
				do while(auxfecha1>Fecha_Menor);
					auxfecha1=sum(auxfecha1,-1);
					if (NoLabUS(auxfecha1)=1) then
						do;
							diascon1=diascon1;
						end;
					else if (NoLabUS(auxfecha1)=0) then
						do;
							diascon1=sum(diascon1,1);
						end;
				end;

			else if compress(upcase(HOLIDAY_LIST_ID))='MXUS' then
				do while(auxfecha1>Fecha_Menor);
					auxfecha1=sum(auxfecha1,-1);
					if (NoLabMX(auxfecha1)=1 or NoLabUS(auxfecha1)=1) then
						do;
							diascon1=diascon1;
							put diascon1=;
						end;
					else if (NoLabMX(auxfecha1)=0 and NoLabUS(auxfecha1)=0) then
						do;
							diascon1=sum(diascon1,1);
							put diascon1=;
						end;
				end;
		return(diascon1);
	endsub;

%mend;
