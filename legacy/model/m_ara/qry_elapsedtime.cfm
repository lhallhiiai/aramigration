<cfquery name="GetStart" datasource="#Application.dsn#">
	Select * from 
	ARAApplog 
	where id_ara=#id_ara#
	and id_job=1
	
</cfquery>
<!--- cfset start="#Dateformat(GetStart.ApprovalDate,'MM/DD/YY')#" &  " #timeformat(GetStart.ApprovalDate,'hh:mm tt')#" --->
<cfset dtFrom = ParseDateTime( GetStart.ApprovalDate) />

<cfset now="#Dateformat(Now(),'MM/DD/YY')#" &  " #timeformat(Now(),'hh:mm tt')#">
<cfset dtDiff=(Now() - dtFrom)>
<!---
<cfoutput>

#dtDiff#<br>
<cfif Fix(dtDiff) GT 1>
#DateDiff( "yyyy", "12/30/1899", dtDiff )# Years,
#DateFormat( dtDiff, "m" )# Months,
</cfif>
#DateFormat( dtDiff, "d" )# Days,

#TimeFormat( dtDiff, "h" )# Hours,
#TimeFormat( dtDiff, "m" )# Minutes,
#TimeFormat( dtDiff, "s" )# Seconds
</cfoutput>

<cfset dur_mins=#Datediff("m",now,dtFrom)#>

<cfoutput>
dur_mins #dur_mins# #dtfrom#
</cfoutput>

--->
