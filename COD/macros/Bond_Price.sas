
%macro Bond_Price();

	/* Create a bond pricing method using the _cashflow_ structure */


		method Bond_Price desc = "Bond Pricing Function" kind = price;


			/* Find the number of coupon payments remaining */
			rempay = int((MaturityDate - _date_)/(30*Coup_Freq));
			_cashflow_.num = rempay;

			if rempay = 0 then
			do;

			/* if bond matures, its new value is par */
			_value_ = Par_LC;

			end;

			else if rempay > 0 then
			do;
			/* Load all of the coupon payment dates and amounts into the _cashflow_ structure */
				do i = 1 to rempay;

						/* Set the maturity dates */
						_cashflow_.matdate{i} = INTNX('month',_date_,Coup_Freq*i);

						/* Set the maturity amounts */
						_cashflow_.matamt{i} = Par_LC*(Coupon)*(Coup_Freq/12);
				end;

				/* Load the principal repayment into the _cashflow_ structure */
				/* Set the date */
				_cashflow_.num = rempay+1;
				_cashflow_.matdate{rempay+1} = _cashflow_.matdate{rempay};

				/* Set the amount */
				_cashflow_.matamt{rempay+1} = Par_LC;

				/* Find the discounted value of the cashflows for corporate bonds using a user defined function */
				*cf_value = cfdiscount(rempay+1,_cashflow_.matamt,_cashflow_.matdate,cred_ir_ref.crrates,cred_ir_ref.crrates.mat,_date_);
				_value_ = pv_cashflow(., ., ., cred_ir_ref.crrates);
			end;
		endmethod;

%mend;
