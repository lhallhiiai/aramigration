<cfparam name="url.aid" default="9FF4D24E6842A0AB">
<cfset sctr="TEOS">
<cfset grp="DSG">

<cfset ARA_ID="#decrypt(url.aid,request.encryptkey,request.encrypttype,'hex')#">

<cfquery name="appLog" datasource="#application.dsn#">
	SELECT top 500 *
	FROM v_approvals
	WHERE id_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#ARA_ID#">
	<cfif isDefined("cycle")>
		and cycle=<cfqueryparam cfsqltype="cf_sql_integer" value="#cycle#">
	</cfif>
	ORDER BY approvalDate asc
</cfquery>

<!--- Needs to have SGOD incorporated --->
<cfquery name="approvers" datasource="#application.dsn#">
	SELECT *
	FROM v_users
	WHERE (grp=<cfqueryparam cfsqltype="cf_sql_varchar" value="#grp#">
		AND id_job in (1,2,3,4,5,6,7,8,9))
	OR (sctr=<cfqueryparam cfsqltype="cf_sql_varchar" value="#sctr#">
		AND id_job in (10,11,12,13,14,15))
	OR id_job in (16,17,18)
	ORDER BY appOrder ASC
</cfquery>

