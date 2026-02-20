<!--- MGann 9/21/11: This query returns all information about documents, BUT DOES NOT
      return the binary BLOB document. So Gets info -- but without performance hit --->
<cfparam name="sort" default="date">
<cfparam name="id_attachment" default="">
<cfquery name="DocList" DataSource="#Application.dsn#">
	SELECT     attachments.id_attachment, attachments.id_ara, attachments.filename, attachments.fileType, 
			   attachments.description, attachments.date, attachments.id_user as Upload_user,
               attachments.Filesize, attachments.MimeType, role.roleName, users.id_user, users.ID_role, 
			   users.id_job,users.empname, 
			   users.first_name, users.last_name,  jobTitle.title as jobtitle
			   
	FROM       attachments 
	           INNER JOIN users ON attachments.id_user = users.id_user 
			   INNER JOIN role ON users.ID_role = role.ID_role 
			   INNER JOIN jobTitle ON users.ID_job = jobTitle.id_job
	where 1=1		   
	<cfif isDefined('id_ara') and id_ara NEQ "" or (isDefined('url.id_ara') and url.id_ara NEQ "")>
	and id_ara=#id_ara#
	</cfif>
	<cfif id_attachment NEQ "">
	and attachments.id_attachment=#id_attachment#
	</cfif>
	<cfif isDefined('ThisJob') and (ThisJob NEQ "")>
	and users.id_job=#ThisJob#
	</cfif>
    <!---and jobtitle.appOrder is not null mgann 1/6/2015: removed as delegation may be to somone without approval status ---> 
	Order by #sort#
</cfquery>
