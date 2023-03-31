
%macro static_parameter();

	method static_parameter kind = trans;

	/* Get all spreads as array */
	CALL PMXELEM(StaticSpreads, 'spreads',., sprdlst);

	/* Over time periods - 3M, 6M etc... */
			do j = 1 to US_Curve.dim;
				US_Curve_AAA[j] = SUM(US_Curve[j], sprdlst[1]);		
				US_Curve_AA[j] 	= SUM(US_Curve[j], sprdlst[2]);		
				US_Curve_A[j] 	= SUM(US_Curve[j], sprdlst[3]);		
				US_Curve_BBB[j] = SUM(US_Curve[j], sprdlst[4]);		
				US_Curve_BB[j] 	= SUM(US_Curve[j], sprdlst[5]);		
				US_Curve_B[j] 	= SUM(US_Curve[j], sprdlst[6]);		
				US_Curve_CCC[j] = SUM(US_Curve[j], sprdlst[7]);
			end;

	endmethod;

%mend;
