<cfswitch expression="#topic#">
<cfcase value="CreateARAStep1">
	<cfinclude template="hlp_CreateARAStep1.cfm">
</cfcase>

<cfcase value="admin_users">
	<cfinclude template="hlp_admin_users.cfm">
</cfcase>
<cfcase value="admin_delegation">
	<cfinclude template="hlp_admin_delegation.cfm">
</cfcase>

<cfcase value="getting_started">
	<cfinclude template="hlp_getting_started.cfm">
</cfcase>
</cfswitch>