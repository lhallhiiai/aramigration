
<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>
	<cfquery name="gName" datasource="#application.dsn#">
		select empname from users
		where id_user=#id_user#
	</cfquery>
	
	<!--- @Check to see if there is any data that refers to them --->
	<cfinclude template="qry_checkID.cfm">

	<cfif HasRecords><!--- Set them to inactive instead --->
		<cfquery name="Inactive" datasource="#Application.dsn#">
			Update Users
			Set status='Inactive',
			Inactive=1
			where id_user=#id_user#
		</cfquery>
		<cfset warningMsg="#gName.empname# has data associated with them in ARA and could not be deleted. Their user profile has instead been set to inactive. While inactive they will not be allowed to log into ARA, but their associated data will be preserved. They can be reactivated at any time and resume system access by updating their profile.">
	<cfelse><!--- They have no data and can be deleted --->	
		<cfquery name="DeleteUser" datasource="#application.dsn#">
				Delete from Users
				where ID_User=#ID_User#
		</cfquery>
		<cfset confirmMsg="User #gName.empname# successfully deleted.">
	</cfif>
	<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="Unable to delete user #gName.empname#. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
		</cfcatch>

	</cftry>

	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			
			
   	</cfif>
</cftransaction>
<cfif committed EQ "Yes">
	<cfif isDefined('WarningMsg')>
		<cflocation url="#self#?fuseaction=app.admin_users&WarningMsg=#WarningMsg#&userid=#id_user#" addtoken="No">
	<cfelse>
		<cflocation url="#self#?fuseaction=app.admin_users&ConfirmMsg=#ConfirmMsg#" addtoken="No">
	</cfif>
<cfelse>
	<cflocation url="#self#?fuseaction=app.admin_users&ErrorMsg=#ErrorMsg#" addtoken="No">
</cfif>