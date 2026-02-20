<cfsetting enablecfoutputonly="true">
<cfparam name="q" default="" />
<cfparam name="sector" default="" />
<cfquery name="gOMS" datasource="#Application.DSN#" result="getOMSID">
	SELECT OMS_ID,oprtnty_title
	FROM OMS30.dbo.OPRTNTY
	WHERE  (
		OMS_ID LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />

	)
	ORDER BY oms_ID
</cfquery>
<cfoutput query="gOMS">
	 #OMS_ID# - #oprtnty_title# #chr(10)#
</cfoutput>
