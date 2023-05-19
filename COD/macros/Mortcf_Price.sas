
%macro Mortcf_Price();

		/* Create a mortgage pricing method using the _cashflow_ structure */

		method Mortcf_Price desc = "Mortgage Pricing Function" kind = price;

			/*- present value of these cash flows */                                                                                                                                               
	        _value_ = pv_cashflow( ., ., ., ir_ref.rates);    

		endmethod;

%mend;
