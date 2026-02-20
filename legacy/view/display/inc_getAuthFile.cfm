<!--- Checks to see if ther eis already an authorization form 
	  Creates a list of links to open for this user.  --->
<cffunction name="GetAuthfile">
	<cfargument name="oprid" required="Yes">
	<cfargument name="id_user" required="yes">
	<cfset fileList="">
	<cfset FileLinks="">
	<!--- Modified 9/19/2013: Mgann. We have started storing access forms in the database
	      so that they cannot accidentally be deleted. This function has been modified to
		  include list of directory files, as well as the new access forms which will only be
		  stored in the database.  --->
		  
	<!--- Access form in directory --->
	<cfset DocPath="#reverse(CGI.CF_TEMPLATE_PATH)#">
	<cfset DocPath="#Reverse(Mid(Docpath,(Find('\',Docpath)+1),(Len(docpath))))#\AccessRequests">
	<cfset DocUrl="#Reverse(CGI.HTTP_REFERER)#">
	<cfset DocUrl="#Reverse(Mid(DocUrl,(Find('/',DocUrl)+1),(Len(docUrl))))#/AccessRequests">
	<cfdirectory Action="list" name="contents" filter="#oprid#*.*" directory="#Docpath#">
	
	<cfoutput query="contents">
		<cfset fileList=ListAppend(Filelist,Name)>
		<cfset FileLinks=ListAppend(FileLinks,'<a class="embed" href="#docUrl#/#name#">#name#</a>')>
		
	</cfoutput>
	<cfif #Len(Filelist)# GT 0><!--- Have at least 1 Access Request --->
		<!--- Sort list to make sure last file is last item in List --->
		<cfset fileList=#ListSort(FileList,'Textnocase')#>
		<cfset AuthFile=#ListLast(FileList)#>
	</cfif>
	
	<!--- Access Form(s) stored in database --->
	
	<cfquery name="GetAccessForm" datasource="#Application.DSN#">
		SELECT     userAccessForm.id_form, userAccessForm.id_user, userAccessForm.mime_type, 
				   userAccessForm.access_form, userAccessForm.file_name, 
                   userAccessForm.created_on,userAccessForm.created_by, users.oprid
		FROM       userAccessForm INNER JOIN
                   users ON userAccessForm.id_user = users.id_user
		WHERE     (userAccessForm.id_user = #id_user#)
	</cfquery>
	
	<cfoutput query="GetAccessForm">
		<cfset fileList=ListAppend(filelist,file_name)>
		<cfquery name="getoprid" datasource="#Application.dsn#">
			select oprid from users where
			id_user=#created_by#
		</cfquery>
		<cfset fileLinks=ListAppend(FileLinks,'<a class="embed" href="index.cfm?fuseaction=app.getFile&id_form=#id_form#">#file_name#</a> 
		#dateformat(created_on,"MM/DD/YY")# #timeformat(created_on,"hh:mm tt")# Uploaded by: #getoprid.oprid#')>
	</cfoutput>
	
</cffunction>