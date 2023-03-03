%macro NoLabUS(tr=*);

	function NoLabUS(date)
   	kind = "Utility functions"
   	label = "Indicates if a date is a US holiday";

		year= year(date);
		NoLabUS=0;

		if date= holiday('CHRISTMAS',year) then NoLabUS=1;
		if date= holiday('COLUMBUS',year) then NoLabUS=1;
		if date= holiday('EASTER',year) then NoLabUS=1;
		if date= holiday('HALLOWEEN',year) then NoLabUS=1;
		if date= holiday('LABOR',year) then NoLabUS=1;
		if date= holiday('MLK',year) then NoLabUS=1;
		if date= holiday('MEMORIAL',year) then NoLabUS=1;
		if date= holiday('NEWYEAR',year) then NoLabUS=1;
		if date= holiday('THANKSGIVING',year) then NoLabUS=1;
		if date= holiday('USINDEPENDENCE',year) then NoLabUS=1;
		if date= holiday('USPRESIDENTS',year) then NoLabUS=1;
		if date= holiday('VALENTINES',year) then NoLabUS=1;
		if date= holiday('VETERANS',year) then NoLabUS=1;
		return(NoLabUS);
	endsub;

%mend;
