<cfif isDefined('url.id_attachment')><!--- called to display ARA attachment file --->
	<cfquery name="GetAttach" datasource="#Application.dsn#">
		SELECT id_attachment, filename, MimeType, binary_file
		FROM attachments
		WHERE id_attachment = #url.id_attachment#
	</cfquery>
	
	
	<cfheader name="content-disposition" value="attachment; filename=#GetAttach.filename#">
	<cfcontent type="#GetAttach.MimeType#" variable="#GetAttach.binary_file#">
	
<cfelseif isDefined('url.id_form')><!--- being called to display user access form --->

	<cfquery name="GetAccessForm" datasource="#Application.dsn#">
		SELECT id_form, id_user, mime_type, access_form, file_name
		FROM userAccessForm
		WHERE id_form = #url.id_form#
	</cfquery>
	<cfheader name="content-disposition" value="attachment; filename=#GetAccessForm.file_name#">
	<cfcontent type="#GetAccessForm.Mime_Type#" variable="#GetAccessForm.access_form#">

<cfelseif isDefined('url.id_email')><!--- email --->

	<cfquery name="GetEmail" datasource="#Application.dsn#">
		SELECT TOP [id_emailLog]
	      ,[id_ara]
	      ,[id_emailType]
	      ,[subject]
	      ,[MsgTo]
	      ,[MsgCC]
	      ,[message_pdf]
	      ,[sentDate]
	      ,[statusID]
	      ,[id_araAppLog]
	      ,[id_delegation]
  		FROM [ara_dev].[dbo].[emailLog]
		WHERE id_emailLog = #url.id_emailLog#
	</cfquery>
	<cfheader name="content-disposition" value="attachment; filename=#GetEmail.file_name#">
	<cfcontent type="#GetAccessForm.Mime_Type#" variable="#GetAccessForm.access_form#">
</cfif>