<!--- Finds out which documents are needed and what has already been uploaded --->

<cffunction name="AttachmentStatus">
	<cfargument name="id_ara" required="yes">
	<cfargument name="id_cat" required="yes">
	<!--- Pull document types needed for this type of ARA --->
	<cfquery name="DocTypes" datasource="#Application.dsn#">
		Select * from attach_checklist 
		where catID_List Like '%|#id_cat#|%' 
		<cfif isdefined("who")> 
		and who='#who#' 
		<cfelse>
        and who in ('CM', 'CON')
		</cfif>

	</cfquery>
	<cfset total_cnt=#Doctypes.Recordcount#>
	<cfquery name="Docs" datasource="#Application.dsn#"><!--- Current doc information --->
		SELECT     attachments.id_attachment, attachments.id_ara, attachments.id_user, 
		   attachments.filename, attachments.date, attachments.Filesize, attachments.filetype,
           attachments.MimeType, users.id_user AS Expr1, users.oprid, role.roleName,role.id_role

			FROM       attachments
			 
			INNER JOIN users ON attachments.id_user = users.id_user 
            INNER JOIN role ON users.ID_role = role.ID_role
			
			where id_ara=#id_ara#
	</cfquery>
	<cfset doc_cnt=#Docs.Recordcount#>
	<!--- Needs and haves in two lists --->
	<cfset NeedList=#valueList(DocTypes.ID_attachtype)# />
	<cfset NeedDesc=#valueList(DocTypes.Short_Desc)# />
	<cfset HaveList=#ValueList(Docs.FileType)# />
	<cfset MissingList="" />
	<cfset havecount=0 /><cfset needcount=0 />
	<cfloop index="i" list="#NeedList#">
		<cfif #ListValueCount(Havelist,i)# GT 0>
			<cfset haveCount=havecount+1>
		<cfelse>
			<cfset needcount=needcount+1>
			<cfset MissingList=ListAppend(MissingList,i)>
		</cfif>
	</cfloop>
</cffunction>

