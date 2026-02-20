$.extend( jQuery.fn.dataTableExt.oSort, {
    "numeric-comma-pre": function ( a ) {
        var x = (a == "-") ? 0 : a.replace( /,/, "." );
        return parseFloat( x );
    },
 
    "numeric-comma-asc": function ( a, b ) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },
 
    "numeric-comma-desc": function ( a, b ) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    },
    "num-html-pre": function ( a ) {
        var x = String(a).replace( /<[\s\S]*?>/g, "" );
        return parseFloat( x );
    },
 
    "num-html-asc": function ( a, b ) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },
 
    "num-html-desc": function ( a, b ) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    },
    "currency-pre": function ( a ) {
        a = (a==="-") ? 0 : a.replace( /[^\d\-\.]/g, "" );
        return parseFloat( a );
    },
 
    "currency-asc": function ( a, b ) {
        return a - b;
    },
 
    "currency-desc": function ( a, b ) {
        return b - a;
    },
    
} );

$.extend( jQuery.fn.dataTableExt.oSort, {
	   "datetime-us-pre": function ( a ) {
		   var tt = 0;
		   if (a != "")
		   {
			   
	       var b = a.match(/(\d{1,2})\/(\d{1,2})\/(\d{2,4})[<br>|<br\/>|\s]*(\d{1,2}):(\d{1,2}) (am|pm|AM|PM|Am|Pm)/),
	           month = b[1],
	           day = b[2],
	           year = b[3],
	           hour = b[4],
	           min = b[5],
	           ap = b[6];
	 
	       if(hour == '12') hour = '0';
	       if(ap == 'pm' || ap == 'PM' || ap =='Pm') hour = parseInt(hour, 10)+12;
	 
	       if(year.length == 2){
	           if(parseInt(year, 10)<70) year = '20'+year;
	           else year = '19'+year;
	       }
	       if(month.length == 1) month = '0'+month;
	       if(day.length == 1) day = '0'+day;
	       if(hour.length == 1) hour = '0'+hour;
	       if(min.length == 1) min = '0'+min;
	 
	       tt = year+month+day+hour+min;
		   }
	       return  tt;
	   },
	   "datetime-us-asc": function ( a, b ) {
	       return a - b;
	   },
	 
	   "datetime-us-desc": function ( a, b ) {
	       return b - a;
	   }
	});
	 
	jQuery.fn.dataTableExt.aTypes.unshift(
	   function ( sData )
	   {
	       if (sData !== null && sData.match(/(\d{1,2})\/(\d{1,2})\/(\d{2,4})[<br>|<br\/>|\s]*(\d{1,2}):(\d{1,2}) (am|pm|AM|PM|Am|Pm)/))
	       {
	 
	           return 'datetime-us';
	       }
	       return null;
	   }
	);