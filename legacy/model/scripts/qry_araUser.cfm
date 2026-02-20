<cfsetting enablecfoutputonly="true">
<cfparam name="q" default="" />
<cfquery name="gUser" datasource="#application.DSN#">
	SELECT * 
	FROM users	
	WHERE  (
		empname LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
	)
	ORDER BY oprid
</cfquery>

<cfset loopcount=1>

<cfoutput query="gUser">
	#first_name# #last_name# [id_User: #id_user#] #chr(10)#
	<cfset loopcount=loopcount+1>
</cfoutput>