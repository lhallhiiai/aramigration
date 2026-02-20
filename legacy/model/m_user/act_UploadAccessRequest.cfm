<!--- Updated 9/2013 to store access forms in database --->


<cfparam name="id_form" default="">

<cfset valid_ext="pdf,PDF">
<!---<cfset filename="xxxxxx">--->
<cfswitch expression="#FileAction#">


<!--- +++++++++++++++++++++ INSERT DOCUMENT START +++++++++++++++++++++++++++ --->
<cfcase value="Upload">
	<cfoutput>
		<cfset temp_name = approvalform /><!--- Long, weird temporary file name that CF gives file. Used later to delete --->
		<!--- For binary uploads, need to first load to temp directory -- then save it to database --->
		<cfset destDir="#Getdirectoryfrompath(GetCurrentTemplatePath())#">
		<cfset i = findnocase('model',destdir)>
		<cfset destdir="#Mid(destdir,1,i-1)#temp\">
		<cffile action="upload" filefield="approvalform" destination="#destdir#" 
	   		 nameconflict="Overwrite" />
		<cfset ins_filename = #CFFILE.ServerFile#><!--- Orginal file name once the file is uploaded --->
		<cfset temp_filename = ins_filename><!--- save orginal name, so can delete when done --->
		<CFSET Saved = #CFFILE.FILEWASSAVED#><!--- Yes or no Flag that the file was saved --->
		<CFSET Filesize = #CFFILE.FILESIZE#><!--- Integer --->
		<cfset clientFileExt=#CFFILE.clientFileExt#><!--- .pdf,.doc etc --->
		
		
		<cfif NOT #find(clientFileExt,valid_ext)#>
			<cfset ErrorMsg="#valid_ext# are the only accepted document types. Please save the document in one of these formats and re-upload.">
			<cflocation url="#self#?fuseaction=app.Admin_Users&ErrorMsg=#ErrorMsg#" addtoken="No">
		</cfif>
		
		<!--- cfoutput>Ins_Filename: #ins_filename#, Saved: #Saved#, Filesize: #Filesize#, clientFileExt: #ClientFileExt#<br> </cfoutput --->
		<cfif #Saved# EQ "Yes">
				<cffile action="readbinary" file="#approvalform#" variable="insFile" />
				After Binary upload saved is #CFFILE.FILEWASSAVED#<br>
				<!--- cfset ins_fileName = lcase(att_fields[attachment_type]) & proposal_name & "_" & oms_number & "[tmp]" & ins_ext / --->
				<!--- cffile action="readbinary" file="#tempDirectory##fileName#" variable="insFile" / --->
				<!--- cffile action="readbinary" filefield="origDocName" destination="#tempdirectory#" 
			   		 nameconflict="overwrite" / --->
			
				<!--- remove strange characters and spaces from file name --->
				<cfset ins_fileName = ReReplace(ins_fileName, "[^a-zA-Z0-9_.]", "_", "All") />
		   		<cfset ins_fileName = replace(ins_fileName, "%20", "_", "All") />
				<cfset ins_ext=#UCASE(ClientFileExt)#>
				<cfif len(ins_filename) GT 60><!--- Then will truncate the file file name --->
					<cfset ins_filename="#Mid(ins_filename,1,60)#.#ClientFileExt#">
					<cfset trunc=" (name truncated to 60 chars) ">
				<cfelse>
					<cfset trunc="">
				</cfif>
		
				<!--- Tasha has full list of mime types. I narrowed it bacause we are only allowing .pdf files --->
		  
		   		<cfset mimetype="ins_ext">
				<cfswitch expression="#ClientFileExt#">
					<cfcase value="PDF">
						<cfset mimetype = "application/pdf">
					</cfcase>
					<cfcase  value="XLS">
						<cfset mimetype = "application/vnd.ms-excel">
					</cfcase>
					<cfcase value="DOC,DOCX">
						<cfset mimetype = "application/msword">
					</cfcase>
					<cfdefaultcase>
						<cfset mimetype = "text/html">
					</cfdefaultcase>
				</cfswitch>
				
				<!--- cfset tmp = ListToArray(inc_type) />
				<cfset inc_types = ArrayToList(tmp) / --->
				
				<cfquery name="insAttchmnt" datasource="#Application.dsn#" result="insAttchmnt">
		   		INSERT INTO userAccessForm
		              (
		              id_user
					  ,action
					  ,ID_role
					  ,ID_job
					  ,access_form
					  ,created_by
					  ,created_on
					  ,mime_type
					  ,file_name
		              )
		        VALUES
		              (
					<cfqueryparam value ="#id_user#" cfsqltype="cf_sql_integer" />
					,<cfqueryparam value="#Action#" cfsqltype="CF_SQL_varchar" />
		            ,<cfqueryparam value ="#ID_role#" cfsqltype="cf_sql_integer" />
		            ,<cfqueryparam value ="#ID_job#" cfsqltype = "CF_SQL_integer" />
					,<cfqueryparam value ="#insFile#" cfsqltype="cf_sql_blob" />
					,<cfqueryparam value="#Session.id_user#" cfsqltype="CF_SQL_integer" />
					,<cfqueryparam value="#now()#" cfsqltype="CF_SQL_TIMESTAMP" />
					,<cfqueryparam value="#mimetype#" cfsqltype="CF_SQL_varchar" />
					,<cfqueryparam value="#ins_filename#" cfsqltype="CF_SQL_varchar" />
					  )
		   		</cfquery>
				
				<cfquery name="getThisID" datasource="#Application.dsn#">
					Select Max(id_form) as thisID From userAccessForm
				</cfquery>
				<cfset ThisID = #getThisID.ThisID#>	
				<!--- +++++++++++++++++  Delete Temporary File +++++++++++++++++++++  --->
				<!---<cfoutput>Temp File is:
				#destdir##temp_filename#<br></cfoutput>--->
				<CFFILE ACTION="Delete"
    				FILE="#destdir##temp_filename#">

				
				<cfset ConfirmMsg="#confirmMsg#" & "#ins_filename# #trunc# saved in database.">
				<!---<cflocation url="#self#?fuseaction=#returnCircuit#&ThisID=#ThisID#&ConfirmMsg=#ConfirmMsg#" addtoken="No">--->
	<cfelse>
		<cfset ErrorMsg="Unable to save file">
		<!---<cflocation addtoken="No" url="#self#?fuseaction=#returnCircuit#&ErrorMsg=#ErrorMsg#">--->
	</cfif>
	</cfoutput>
</cfcase>

<!--- +++++++++++++++++++++ UPDATE DOCUMENT START +++++++++++++++++++++++++++ --->
<CFCASE value="Update">

</cfcase>



<!--- +++++++++++++++++++++ DELETE DOCUMENT START +++++++++++++++++++++++++++ --->
<CFCASE value="Delete">
	<cfoutput>
	<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>
		  <cfquery name="DeleteAttach" datasource="#Application.dsn#">
		  		delete from attachments
				where id_attachment=#id_attachment#
				<cfif #id_attachment# NEQ -1>
					and id_attachment=#id_attachment#
				</cfif>
		 </cfquery>
	 <!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="A failure occurred when trying to delete this user to the database. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
		</cfcatch>

	</cftry>
	 	
	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />

			<cfset confirmMsg="Attachment successfully deleted.">
   	</cfif>
	</cftransaction>
	<!--- Return to document load page with errror or Confirm --->
	<cfif committed EQ 'No'>
		<!---<cflocation addtoken="No" url="#self#?Fuseaction=#returnCircuit#&ErrorMsg=#ErrorMsg#">--->
	<cfelse>
		<!---<cflocation addtoken="No" url="#self#?Fuseaction=#returnCircuit#&ConfirmMsg=#ConfirmMsg#">--->
	</cfif>
	</cfoutput>
</cfcase>
<!--- +++++++++++++++++++++ DELETE DOCUMENT END +++++++++++++++++++++++++++ --->


</cfswitch>

