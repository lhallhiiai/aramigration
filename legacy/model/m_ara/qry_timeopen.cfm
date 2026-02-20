<!--- How long has thiis ara been in process --->
<cfquery name="GetStart" datasource="#Application.dsn#">
	Select top 1 * from 
	ARAApplog 
	where id_ara=#id_ara#
	order by id_araAppLog Asc
	
</cfquery>
<cfset start="#Dateformat(GetStart.ApprovalDate,'MM/DD/YY')#" &  " #timeformat(GetStart.ApprovalDate,'hh:mm tt')#">
<cfset now="#Dateformat(Now(),'MM/DD/YY')#" &  " #timeformat(Now(),'hh:mm tt')#">

<!--- cfset mins=#Datediff('n',Getstart.ApprovalDate,Now())#>
<cfset hours=#Mins# MOD 60>
<cfset duration="">
<cfif days GT 0>
	<cfset duration = "#duration#" & "#days# Day(s)">
</cfif>
<cfif Hours GT 0>
	<cfset duration= "#duration#" & "#hours# Hour(s)">
</cfif>
<cfif mins GT 0>
	<cfset duration= "#duration#" & "#mins# Minute(s)">
</cfif --->

 