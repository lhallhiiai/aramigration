<cfquery name="CLINfo" datasource="#application.ods#">
	SELECT clin_no, clin_desc, end_date
	FROM jobcost.t_clin_master_ckis
	WHERE cnct_no = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ARAdetails.jamisNo#">
</cfquery>