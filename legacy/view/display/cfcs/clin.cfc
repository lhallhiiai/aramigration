<cfcomponent output="false">

	<cffunction name="getDescription" access="remote" returntype="String">
		<cfargument name="ClinNum" type="String" required="true">
		
		<cfquery name="getDesc" datasource="#application.ods#">
			SELECT clin_desc
			FROM jobcost.t_clin_master_ckis
			WHERE clin_no = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ClinNum#">		
		</cfquery>
		<cfset result="#getDesc.clin_desc#">
		<cfreturn result>
	</cffunction>

	<cffunction name="getExp" access="remote" returntype="String">
		<cfargument name="ClinNum" type="String" required="true">
		
		<cfquery name="getDesc" datasource="#application.ods#">
			SELECT end_date
			FROM jobcost.t_clin_master_ckis
			WHERE clin_no = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ClinNum#">		
		</cfquery>
		<cfset yr="#left(getDesc.end_date,4)#">
		<cfset mday="#right(getDesc.end_date,4)#">
		<cfset mo=#left(mday,2)#>
		<cfset day=#right(mday,2)#>
		<cfset result="#mo#/#day#/#yr#">
		<cfreturn result>
	</cffunction>


</cfcomponent>