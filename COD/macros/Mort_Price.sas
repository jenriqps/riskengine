
%macro Mort_Price();

      method Mort_Price desc = "Mortgage Pricing Function" kind = price;
      
         /* Remaining payments on mortgage */
         rempay = intck('month', _date_, MaturityDate);
         _cashflow_.int.num = rempay+1;
         _cashflow_.prin.num = rempay+1;
         _cashflow_.num = rempay+1;
      
         /* First payment date */
         FirstPayDate = intnx('month', _date_, 0, 'end');
         
         /* debug3 */
         /*if LoanOfficer EQ "Bart" and guar_entity EQ "Ginnie" then do;
            m=month(_date_);
            d=day(MaturityDate);
            y=year(_date_);
            put simulationreplication= _date_= m= d= y= FirstPayDate=;
         end; */
              
         LeftOverBal = RemainingBal;

         do i= 1 to rempay+1;
            TempCFDate = intnx('month', FirstPayDate, i-1, 'same');
            
            /* debug2 */
            /*if LoanOfficer EQ "Bart" and guar_entity EQ "Ginnie" then do;
                  put simulationreplication= _date_= i= FirstPayDate= TempCFDate= ;
            end; */
              
            /* Monthly interest payment - assumed fix and not amortizing */
            InterestPayment = round((cpn_rate/12)*LeftOverBal, 0.11);

            if InterestPayment < 0 then InterestPayment = 0;

            /* Monthly principal payment - assumed fixed */
            PrincipalPayment = monthly_cf - InterestPayment;

            /* Interest leg */
            _cashflow_.int.matdate[i] = TempCFDate;
            _cashflow_.int.matamt[i] = InterestPayment;

            /* Principal leg */
            _cashflow_.prin.matdate[i] = TempCFDate;
            _cashflow_.prin.matamt[i] = PrincipalPayment;

            /* Total CF */
            _cashflow_.matdate[i] = TempCFDate;
            _cashflow_.matamt[i] = monthly_cf;

            LeftOverBal = max(LeftOverBal - PrincipalPayment, 0);
         end;

         /* PV of interest payments */
         *pv_int = cfdiscount(rempay+1,_cashflow_.int.matamt,_cashflow_.int.matdate,ir_ref.rates,ir_ref.rates.mat,_date_);

         /* PV of principal payments */
         *pv_prin = cfdiscount(rempay+1,_cashflow_.prin.matamt,_cashflow_.prin.matdate,ir_ref.rates,ir_ref.rates.mat,_date_);

         /* PV of total cashflow */
         _value_ = cfdiscount(rempay+1,_cashflow_.matamt,_cashflow_.matdate,ir_ref.rates,ir_ref.rates.mat,_date_);

         
         /* debug1 */
         /*if LoanOfficer EQ "Bart" and guar_entity EQ "Ginnie" then do;
                  put simulationreplication= _date_= ir_ref.rates.mat= TempCFDate=  _value_=;
         end;*/
              
      endmethod;
%mend;
