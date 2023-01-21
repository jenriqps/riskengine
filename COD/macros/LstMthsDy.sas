%macro LstMthsDy(tr=);
	/*Último día del mes*/
	function LstMthsDy(m,d,y)
   	kind = "Utility functions"
   	label = "Indicates the number of days in a month (for example, 28, 29, 30, 31)";
   	
		LstMthsDy=d;
		if d=31 and m in (4,6,9,11) then
			 LstMthsDy=30;
		else if (d>=29 and m=2 and mod(y,4)=0 and (mod(y,100)>0 or mod(y,400))) then
			LstMthsDy=29;
		else if (d>=29 and m=2) then LstMthsDy=28;
		return(LstMthsDy);
	endsub;
%mend;
