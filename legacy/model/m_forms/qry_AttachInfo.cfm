<cffunction name="AttachInfo">
	<cfargument name="id_attach" required="no">
	
<cfif (isDefined('id_attach')) and (id_attach NEQ '')>
	<cfquery name="GetDoc" datasource="#Application.dsn#">
		SELECT     attachments.id_attachment, attachments.id_ara, attachments.id_user, 
		   	   attachments.filename, attachments.date, attachments.Filesize, 
                attachments.MimeType, users.id_user AS Expr1, users.oprid, role.roleName,role.id_role

		FROM       attachments 
				INNER JOIN users ON attachments.id_user = users.id_user 
            	INNER JOIN role ON users.ID_role = role.ID_role
		where id_attachment=#id_attach#
	</cfquery>
	<cfset id_attachment=#GetDoc.id_attachment#>
	<cfset id_ara=#GetDoc.id_ara#>
	<cfset id_user=#GetDoc.id_user#>
	<cfset filename=#GetDoc.filename#>
	<cfset fileType=#GetDoc.fileType#>
	<cfset description=#GetDoc.description#>
	<cfset date="#Dateformat(getdoc.date,'MM/DD/YY')#" & " #timeformat(getdoc.date,'hh:mm tt')#">
	<cfset filesize=#GetDoc.Filesize#>
	<cfset MimeType=#GetDoc.MimeType#>
<cfelse>
	<!--- Only initialize variables which will not be passed --->
	<cfset id_attachment="">
	<cfset id_user=#session.id_user#>
	<cfset filename="">
	<cfset fileType="">
	<cfset Description="">
	<cfset date=#Now()#>
	<cfset filesize=0>
	<cfset Mimetype="">
</cfif>

</cffunction>


