<!--- MGann 9/21/11: Update Attachments table --->
<cfset aid=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
<cfparam name="return_to" default="app.ARA_Docs&aid=#aid#">
<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>
	<cfquery name="UpdAttach" datasource="#Application.dsn#">
		Update  Attachments
		SET
		fileType=<cfqueryparam cfsqltype="cf_sql_varchar" value="#ID_attachtype#">,
		description=<cfqueryparam cfsqltype="cf_sql_varchar" value="#description#">
		WHERE (id_attachment = #id_attachment#)
	</cfquery>
	<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="A failure occurred when trying to update this attachment (#FileName#). <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
		</cfcatch>

	</cftry>
</cftransaction>
<!--- @Comment: Check for Commit --->
<cfif committed EQ "Yes">
  		<cftransaction action="commit" />
	<cfset confirmMsg="Attachment: #Filename# updated.">
 	</cfif>
<!--- Return to document load page with errror or Confirm --->
<cfif committed EQ 'No'>
	<cflocation addtoken="No" url="#self#?Fuseaction=#return_to#&Action=Setup&ThisID=#id_attachment#&ErrorMsg=#ErrorMsg#">
<cfelse>
	<cflocation addtoken="No" url="#self#?Fuseaction=#return_to#&Action=Setup&ThisID=#id_attachment#&ConfirmMsg=#ConfirmMsg#">
</cfif>