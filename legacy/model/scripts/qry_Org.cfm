<cfsetting enablecfoutputonly="true">
<cfparam name="q" default="" />
<cfparam name="sctr" default="" />
<cfquery name="gOrg" datasource="#application.dsn#" result="getorg">
	SELECT * 
	FROM ara_CP_Reorg where GRP LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
	<!---WHERE  
		grp LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" /> 
		OR L4_REORG_NAME LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />--->
</cfquery>

<cfset loopcount=1>
<cfoutput query="gOrg">
	Group: #grp#, Group Name: #L4_REORG_NAME# #chr(10)#
	<cfset loopcount=loopcount+1>
</cfoutput>