/**********************************************************************
 * Exercise 6;
 * Jose Enrique Perez ;
 * Licenciatura en Actuaría;
 * Facultad de Negocios. Universidad La Salle México;
 **********************************************************************/

proc iml;

	start Price(vector);
	/*
	Purpose: To price stocks and exchange rates
	vector: vector or matrix with the prices	
	*/
		value=0;
	   	value=vector;
	   	return(value);
	finish;
	
	start LinInterp(x, y, _t);
	/* 	Linear interpolation based on the values (x1,y1), (x2,y2),....
	   	The X  values must be nonmissing and in increasing order: x1 < x2 < ... < xn
	   	The values of the _t vector are linearly interpolated.
		This function is based on https://blogs.sas.com/content/iml/2020/05/04/linear-interpolation-sas.html
	*/
	   d = dif(x, 1, 1);                     /* check that x[i+1] > x[i] */
	   if any(d<=0) then stop "ERROR: x values must be nonmissing and strictly increasing.";
	   idx = loc(_t>=min(x) && _t<=max(x));  /* check for valid scoring values */
	   if ncol(idx)=0 then stop "ERROR: No values of t are inside the range of x.";
	 
	   p = j(nrow(_t)*ncol(_t), ncol(y), .);     /* allocate output (prediction) vector */
		*print p;
	   t = _t[idx];                        /* subset t values inside range(x) */
	   k = bin(t, x);                      /* find interval [x_i, x_{i+1}] that contains s */
	   xL = x[k];   yL = y[k,];             /* find (xL, yL) and (xR, yR) */
	   xR = x[k+1]; yR = y[k+1,];
		*print yL;
		*print yR;
	   f = (t - xL) / (xR - xL); 
		*print f;          /* f = fraction of interval [xL, xR] */
		*print idx;
	   	p[idx,] = (1 - f)#yL + f#yR;        /* interpolate between yL and yR */
	   return( p );
	finish;
	
	start ZeroCouponBond(date,mat_date,FV,curve,den);
	/*
	Purpose: To price zero coupon bonds
	date: valuation date vector
	mat_date: maturity date vector
	FV: face value vector
	curve: discount curve matrix, the first column must be the terms of the curve
			the remaining columns are the rates
	den: denominator for the counting day convention
	*/
		value=0;
		* Time (days) to maturity;
		t = mat_date - date;
		*print t;
		* Interpolating to get the rate for time t;
		r = LinInterp(curve[,1], curve[,2:ncol(curve)],t);
		*print r;
		* Discount factor;
		df=1/(1+r#t/den);
		*print df;
		* Present value of the face values;
		value=FV#df;
		return(t(value));	
	finish;
	
	*Saving the functions;
	store module=_all_;

quit;
