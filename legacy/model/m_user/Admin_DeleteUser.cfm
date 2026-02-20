<cfif inactive eq 0>
	<cfset status="Active">
<cfelse>
	<cfset status="Inactive">
</cfif>
<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>

	<cfquery name="UpdateUser" datasource="#application.dsn#">
			Update  Users
			SET id_role=<cfqueryparam cfsqltype="cf_sql_integer" value="#id_role#">,
			status=<cfqueryparam cfsqltype="cf_sql_varchar" value="#status#">,
			Inactive=<cfqueryparam cfsqltype="cf_sql_integer" value=#Inactive#>	
			where ID_User=#ID_User#
	</cfquery>
	
	<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="Unable to update user. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
		</cfcatch>

	</cftry>

	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			
			<cfset confirmMsg="#empname# successfully Updated.">
   	</cfif>
</cftransaction>
<cfset userID=#ID_user#>
<cfif committed EQ "Yes">
	<cflocation url="#self#?fuseaction=app.admin_users&ConfirmMsg=#ConfirmMsg#&userID=#userID#" addtoken="No">
<cfelse>
	<cflocation url="#self#?fuseaction=app.admin_users&ErrorMsg=#ErrorMsg#&Userid=#userid#" addtoken="No">
</cfif>