%macro Fecha_masmenos_dias_habiles(tr=);

	/*Si se tiene una fecha y se quiere sumar o restar x días hábiles. Resultado fecha*/
	function Fecha_masmenos_dias_habiles(Fecha_Inicial,Dias_Habiles,HOLIDAY_LIST_ID $)
   	kind = "Utility functions"
   	label = "Date plus x business days";
		atras_adelante=Dias_Habiles/abs(Dias_Habiles);
		diasaux=Dias_Habiles;
		* Mexican calendar;
		if HOLIDAY_LIST_ID='MX' then
			do while(diasaux^=0);
				Fecha_Inicial=sum(Fecha_Inicial,atras_adelante);
				if(NoLabMX(Fecha_Inicial)=1) then
					do;
						diasaux=diasaux;
					end;
				else if (NoLabMX(Fecha_Inicial)=0) then
					do;
						diasaux=sum(diasaux,-atras_adelante);
					end;
			end;
		* USA calendar;
		if HOLIDAY_LIST_ID='US' then
			do while(diasaux^=0);
				Fecha_Inicial=sum(Fecha_Inicial,atras_adelante);
				if(NoLabUS(Fecha_Inicial)=1) then
					do;
						diasaux=diasaux;
					end;
				else if (NoLabUS(Fecha_Inicial)=0) then
					do;
						diasaux=sum(diasaux,-atras_adelante);
					end;
			end;
		* Mexican and USA calendar;
		if HOLIDAY_LIST_ID='MXUS' then
			do while(diasaux^=0);
				Fecha_Inicial=sum(Fecha_Inicial,atras_adelante);
				if(NoLabMX(Fecha_Inicial)=1 or NoLabUS(Fecha_Inicial)=1) then
					do;
						diasaux=diasaux;
					end;
				else if (NoLabMX(Fecha_Inicial)=0 and NoLabUS(Fecha_Inicial)=0) then
					do;
						diasaux=sum(diasaux,-atras_adelante);
					end;
			end;
		return(Fecha_Inicial);
	endsub;

%mend;
