%let lambda=1;
data gama;
	/* Formatos de las variables */
	format x pdf cdf sdf 10.6;
	/* Etiquetas de las variables */
	label x ="Valor" pdf="Función de densidad" cdf="Función de distribución" sdf="Función de supervivencia";
	/* Ciclos para calcular las probabilidades  */
	do r=1,2,3,5,9,7.5,0.5; 
		do x=0 to 20 by 0.1;
		pdf=pdf('GAMMA',x,r,1/&lambda.); 
		cdf=cdf('GAMMA',x,r,1/&lambda.); 
		sdf=sdf('GAMMA',x,r,1/&lambda.);
		output;
		end;		
	end;
run;


data gamma;
	/* Formatos de las variables */
	format alpha var comma10.6;
	alpha=0.975;
	var=quantile('GAMMA',alpha,2,1/2); output;
run;


data tstudent_var;
	alpha=0.995;
	var=quantile('T',alpha,2); output;
run;
