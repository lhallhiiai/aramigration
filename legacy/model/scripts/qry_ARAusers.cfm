<!--- Used for autocomplete select list  on dsp_admin_users --->


<cfsetting enablecfoutputonly="true">
<cfparam name="q" default="" />
<cfparam name="sector" default="" />
<cfquery name="gARAUsers" datasource="#application.dsn#" result="getARAUsers">
	SELECT *
	FROM v_users
	WHERE 1=1
	AND (
		first_name LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
		OR last_name LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
		OR oprid LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
		OR ltrim(rtrim(first_name)) + ' ' + ltrim(rtrim(last_name)) LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
	)
	ORDER BY last_name
</cfquery>
<cfoutput query="gARAUsers">
	#last_name#, #first_name# [#oprid#]: #title#, Role #RoleName#, Org: #sctr#, #grp# #chr(10)#
</cfoutput>