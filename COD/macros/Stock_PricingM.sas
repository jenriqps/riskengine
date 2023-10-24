
%macro Stock_PricingM();

	Method Stock_PricingM  desc="Método Acciones" Kind=price;

		_value_=0;

		if compress(upcase(LocalCurrency))  = "MXN" then _VALUE_ = PRICE.ref_price;	
		else _VALUE_ = PRICE.ref_price;

	endmethod;

%mend;
