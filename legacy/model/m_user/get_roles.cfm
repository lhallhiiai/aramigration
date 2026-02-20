<!--- Gets the user role definitions --->
<cfquery name="gRoles" datasource="#application.dsn#">
	Select * from role
</cfquery>