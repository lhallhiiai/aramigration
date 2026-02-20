<cfoutput>
<cfparam name="url.aid" default="9FF4D24E6842A0AB">

<cfset ARA_ID="#decrypt(url.aid,request.encryptkey,request.encrypttype,'hex')#">


<!--- First, get internal ARA details --->

<cfquery name="ARAdetails" datasource="#application.dsn#">
	SELECT *
	FROM ara
	WHERE id_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#ARA_ID#">
</cfquery>


<cfquery name="Risk" datasource="#application.dsn#">
	SELECT *
	FROM category
	WHERE id_cat=<cfqueryparam cfsqltype="cf_sql_integer" value="#ARAdetails.id_cat#">
</cfquery>

<cfquery name="Status" datasource="#application.dsn#">
	SELECT *
	FROM Status
	WHERE id_status=<cfqueryparam cfsqltype="cf_sql_integer" value="#ARAdetails.id_status#">
</cfquery>

<!--- cfquery name="Sector" datasource="#application.dsn#">
	SELECT *
	FROM Sector
	WHERE id_sector=<cfqueryparam cfsqltype="cf_sql_integer" value="#ARAdetails.id_sector#">
</cfquery>

<cfquery name="Groups" datasource="#application.dsn#">
	SELECT *
	FROM Groups
	WHERE id_group=<cfqueryparam cfsqltype="cf_sql_integer" value="#ARAdetails.id_group#">
</cfquery --->

<cfquery name="PMName" datasource="#application.dsn#">
	SELECT empname
	FROM users
	WHERE id_user=<cfqueryparam cfsqltype="cf_sql_integer" value="#ARAdetails.id_user#">
</cfquery>
</cfoutput>
