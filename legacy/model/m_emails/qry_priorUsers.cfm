<cfif isDefined('id_ara') and (id_ARA NEQ "")>
	<cfquery name="GetPriorUser" datasource="#Application.dsn#">
		select distinct araAppLog.id_user, users.oprid from araApplog, users
			where 
        	araAppLog.id_ara='#id_ara#' and araAppLog.id_user=users.id_user and user.status = 'active' and inactive='false'
    </cfquery> 
	<cfset dist="">  
	<!--- Setup mailing list --->
	<cfoutput query="GetPriorUser">
		<cfquery name="GetPriorUserEmail" datasource="#application.dsn#">
			Select email from v_users
			where oprid=#GetPriorUser.oprid#
		</cfquery>
		<cfset dist="#dist#" & "," & "#GetPriorUserEmail.email#">
    </cfoutput>
</cfif>