
%macro static_parameter();

	method static_parameter kind = trans;

	/* Get all spreads as array */
	CALL PMXELEM(StaticSpreads, 'spreads',., sprdlst);

	/* Over time periods - 3M, 6M etc... */
			do j = 1 to CETES.dim;
				MX_AAA[j] = SUM(CETES[j], sprdlst[1]);		
				MX_AA[j] 	= SUM(CETES[j], sprdlst[2]);		
				MX_A[j] 	= SUM(CETES[j], sprdlst[3]);		
				MX_BBB[j] = SUM(CETES[j], sprdlst[4]);		
				MX_BB[j] 	= SUM(CETES[j], sprdlst[5]);		
				MX_B[j] 	= SUM(CETES[j], sprdlst[6]);		
				MX_CCC[j] = SUM(CETES[j], sprdlst[7]);
			end;

	endmethod;

%mend;
