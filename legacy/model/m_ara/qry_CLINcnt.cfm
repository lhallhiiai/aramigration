<!--- Get CLIN Cnt associated with Jamis Number --->

<cfquery name="Cnt" datasource="#Application.dsn#">
	SELECT count(*) as CLINCount
	FROM ara_CP_Data
	
	WHERE  COSTPT_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#jamisNo#">
</cfquery>
<cfset JamisClins=#Cnt.ClinCount#>

<!--- Count of ARA Clins --->
<cfquery name="ara_clins" datasource="#application.dsn#">
	SELECT count(*) as CLINCount
	FROM clins
	where id_ara= <cfqueryparam cfsqltype="cf_sql_integer" value="#id_ara#">
</cfquery>
<cfset ARAClinCnt=#ara_clins.Clincount#>
	
