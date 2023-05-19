
%macro cfdiscount();

		/* Create a function to discount cash flows */
		function cfdiscount(numflows,matamt[*],matdate[*],rates[*],ratedates[*],evaldate) kind = pricing;

			/* Find the number of remaining payments and the number of rates */
			rempay = numflows;
			ratesize = dim(rates);

			/* Find the discounted cash flows. Note that the program does not interpolate */
			/* but rather takes the previous rate. Continuous compounding is assumed. */ 
			do i = 1 to rempay;

					temp = matamt{i};
					/*Case of cashflows maturing before the shortest term rate */
					if (matdate{i}-evaldate)/365 <= ratedates{1} then temp = matamt{i}*exp(-rates{1}*(matdate{i}-evaldate)/365);

					/* Case of cash flows maturing after the longest term rate */
					if (matdate{i}-evaldate)/365 >= ratedates{ratesize} then temp = matamt{i}*exp(-rates{ratesize}*(matdate{i}-evaldate)/365);

					
					/* Case of cash flows maturing within the rate curve */
					j = 1;
					if (matdate{i}-evaldate)/365 > ratedates{1} and matdate{i} < ratedates{ratesize} then 
					do while (j <= ratesize);
						if (matdate{i}-evaldate)/365 < ratedates{j+1} then do;
							temp = matamt{i}*exp(-rates{j}*(matdate{i}-evaldate)/365);
							j = ratesize + 1;
						end;
					else j = j + 1;

				end;
			/* Calculate the sum of the discounted cashflows */
				if i = 1 then totalnet = temp;
				else totalnet = totalnet + temp;

			end; 

			return(totalnet);

		endsub;
%mend;
