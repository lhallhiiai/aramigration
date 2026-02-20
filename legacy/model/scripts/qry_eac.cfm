<cfsetting enablecfoutputonly="true">
<cfparam name="q" default="" />
<cfparam name="sector" default="" />
<cfquery name="gOMS" datasource="#application.oms#" result="getOMSID">
	SELECT OMSID,oppTitle
	FROM tblOppMaster
	WHERE  (
		OMSID LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />

	)
	ORDER BY omsID
</cfquery>
<cfoutput query="gOMS">
	 #OMSID# - #opptitle# #chr(10)#
</cfoutput>