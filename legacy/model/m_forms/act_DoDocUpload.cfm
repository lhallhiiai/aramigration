<cfparam name="returnto" default="docs">
<cfoutput>ID_ARA is #ID_ARA#</cfoutput>
<cfset AID="#encrypt(id_ara,request.encryptkey,request.encrypttype,'hex')#">
<cfswitch expression="#ReturnTo#">
<cfcase value="PM">
	<cfset returnCircuit="app.ARA_PM&AID=#AID#">
</cfcase>
<cfcase value="Contracts">
	<cfset returnCircuit="app.ARA_ContractInfo&AID=#AID#">
</cfcase>
<cfcase value="controller">
	<cfset returnCircuit="app.ARA_controllerV2&AID=#AID#">
</cfcase>
<cfcase value="docs">
	<cfset returnCircuit="app.ARA_docs&Aid=#AID#">
</cfcase>
</cfswitch>

<cfoutput>returnto is #returnto# and returncircuit is #returnCircuit#</cfoutput>
<!--- cfdump var="#form#" format="text" --->

<cfparam name="id_attachment" default="">

<cfset valid_ext="pdf,PDF,xls,XLS,xlsx,XLSX">
<cfoutput>Action is #Action#</cfoutput>
<cfswitch expression="#Action#">


<!--- +++++++++++++++++++++ INSERT DOCUMENT START +++++++++++++++++++++++++++ --->
<cfcase value="Upload">
	<cfoutput>
		<cfset temp_name = fileName /><!--- Long, weird temporary file name that CF gives file. Used later to delete --->
		<!--- For binary uploads, need to first load to temp directory -- then save it to database --->
		<cfset destDir="#Getdirectoryfrompath(GetCurrentTemplatePath())#" & "temp\">
		<cffile action="upload" filefield="FileName" destination="#application.PDFDir#" 
	   		 nameconflict="Overwrite" />
		<cfset ins_filename = #CFFILE.ServerFile#><!--- Orginal file name once the file is uploaded --->
		<cfset temp_filename = ins_filename><!--- save orginal name, so can delete when done --->
		<CFSET Saved = #CFFILE.FILEWASSAVED#><!--- Yes or no Flag that the file was saved --->
		<CFSET Filesize = #CFFILE.FILESIZE#><!--- Integer --->
		<cfset clientFileExt=#CFFILE.clientFileExt#><!--- .pdf,.doc etc --->
		
		<cfif NOT #find(clientFileExt,valid_ext)#>
			<cfset ErrorMsg="PDF, XLS, and XLSX are the only accepted document types. Please save the document in one of these formats and re-upload.">
			<cflocation url="#self#?fuseaction=#returnCircuit#&ErrorMsg=#ErrorMsg#" addtoken="No">
		</cfif>
		
		<!--- cfoutput>Ins_Filename: #ins_filename#, Saved: #Saved#, Filesize: #Filesize#, clientFileExt: #ClientFileExt#<br> </cfoutput --->
		<cfif #Saved# EQ "Yes">
				<cffile action="readbinary" file="#fileName#" variable="insFile" />
				<!--- After Binary upload saved is #CFFILE.FILEWASSAVED# --->
				<!--- cfset ins_fileName = lcase(att_fields[attachment_type]) & proposal_name & "_" & oms_number & "[tmp]" & ins_ext / --->
				<!--- cffile action="readbinary" file="#tempDirectory##fileName#" variable="insFile" / --->
				<!--- cffile action="readbinary" filefield="origDocName" destination="#tempdirectory#" 
			   		 nameconflict="overwrite" / --->
			
				<!--- remove strange characters and spaces from file name --->
				<cfset ins_fileName = ReReplace(ins_fileName, "[^a-zA-Z0-9_.]", "_", "All") />
		   		<cfset ins_fileName = replace(ins_fileName, "%20", "_", "All") />
				<cfset ins_ext=".#ClientFileExt#">
				<cfif len(ins_filename) GT 28><!--- Then will truncate the file file name --->
					<cfset ins_filename="#Mid(ins_filename,1,24)#.#ClientFileExt#">
					<cfset trunc=" (name truncated to 28 chars) ">
				<cfelse>
					<cfset trunc="">
				</cfif>
		
				<!--- Tasha has full list of mime types. I narrowed it bacause we are only allowing .pdf files --->
		   		<cfscript>
		   		mimetype = '';
				switch(ins_ext) {
					case ".pdf,PDF":
						mimetype = "application/pdf";
						break;
					case ".xls,XLS":
								mimetype = "application/vnd.ms-excel";
								break;
					case "xlsx,XLSX":
								mimetype = "application/msword";
								break;
					default:
						mimetype = "text/html";
						}
				</cfscript>
		
				<!--- cfset tmp = ListToArray(inc_type) />
				<cfset inc_types = ArrayToList(tmp) / --->
				
				<cfquery name="insAttchmnt" datasource="#Application.dsn#" result="insAttchmnt">
		   		INSERT INTO attachments
		              (
		              id_ara
		              ,id_user
					  ,filename
					  ,fileType
					  ,description
					  ,date
					  ,Filesize
					  ,MimeType
					  ,binary_file
		              )
		        VALUES
		              (
		              <cfqueryparam value ="#id_ara#" cfsqltype = "CF_SQL_INTEGER" />
					  ,<cfqueryparam value ="#session.id_user#" cfsqltype="cf_sql_integer" />
		              ,<cfqueryparam value ="#ins_filename#" cfsqltype="cf_sql_varchar" />
		              ,<cfqueryparam value ="#ID_attachtype#" cfsqltype = "CF_SQL_varchar">
					  ,<cfqueryparam value="#description#" cfsqltype="CF_SQL_varchar" />
					  ,<cfqueryparam value="#now()#" cfsqltype="CF_SQL_TIMESTAMP" />
					  ,<cfqueryparam value ="#filesize#" cfsqltype = "CF_SQL_INTEGER">
					  ,<cfqueryparam value="#Mimetype#" cfsqltype="cf_sql_varchar">
					  ,<cfqueryparam value ="#insFile#" cfsqltype="cf_sql_blob" />
					  )
		   		</cfquery>
				<cfquery name="getThisID" datasource="#Application.dsn#">
					Select Max(id_attachment) as thisID From attachments
				</cfquery>
				<cfset ThisID = #getThisID.ThisID#>	
				<!--- +++++++++++++++++  Delete Temporary File +++++++++++++++++++++  --->
				<!---<cfoutput>Temp File is:
				#application.PDFDirdel#\#temp_filename#<br></cfoutput>--->
				<CFFILE ACTION="Delete"
    				FILE="#application.PDFDirdel#\#temp_filename#">

				
				<cfset ConfirmMsg="File: #ins_filename# #trunc# saved in database.">
				<cflocation url="#self#?fuseaction=#returnCircuit#&ThisID=#ThisID#&ConfirmMsg=#ConfirmMsg#" addtoken="No">
	<cfelse>
		<cfset ErrorMsg="Unable to save file">
		<cflocation addtoken="No" url="#self#?fuseaction=#returnCircuit#&ErrorMsg=#ErrorMsg#">
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
		<cflocation addtoken="No" url="#self#?Fuseaction=#returnCircuit#&ErrorMsg=#ErrorMsg#">
	<cfelse>
		<cflocation addtoken="No" url="#self#?Fuseaction=#returnCircuit#&ConfirmMsg=#ConfirmMsg#">
	</cfif>
	</cfoutput>
</cfcase>
<!--- +++++++++++++++++++++ DELETE DOCUMENT END +++++++++++++++++++++++++++ --->


</cfswitch>

