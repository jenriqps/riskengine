/**********************************************************************
 * Notas de Riesgos Financieros;
 * Jose Enrique Perez ;
 * Licenciatura en Actuaría;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/


proc fcmp outlib=work.myfunc.trial;

	function Stock(Currency$,price,valCurrency$,FX_price);
	/*
	Purpose: To compute the value of a stock
	Currency$: code of the native currency of the stock
	price: price of the stock on its native currency
	valCurrency$: code of the valuation currency of the stock
	FX_price: foreign exchange from native currency to the valuation currency
	*/

		value=0;

		if compress(upcase(Currency))  = valCurrency then value = price;	
		else value = price * FX_price;
		return(value);

	endsub;

run;




