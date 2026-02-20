<!--- MGann: Deletes all pdf files older than one day. If items have been
	  moved to the repository, they will also have to be removed from there
	  manually.  --->
	  
	  <cfset thisPath=#Getdirectoryfrompath(GetCurrentTemplatePath())#>
	  <cfset i=FindnoCase('view',thisPath)>
	  <cfset root_path=Mid(thisPath,1,(i-1))>
	  <cfset email_path="#root_path#" & "model\m_emails\temp">
	  <cfset temp_path="#root_path#" & "temp">
	  <cfset yesterday=DateAdd("D",-1,Now())>
	  <p class="smtitle">Admin</p>
	  <p class="title">PDF File Cleanup</p>
	  <p>This utility will delete pdf files older than 1 day that are:
	  <ol>
      <li>PDFs created in the temp folder (temp/ARADocument-123.pdf)
	  <li>Created as a result of Print ARA / CFDocument (temp/ARADocument-123.pdf)
	  </ol>
	  </p>
	  <hr>
	  <cfoutput>
	<b>Deleting from: #application.PDFDir# as of: #dateformat(yesterday,"MM/DD/YY")#....</b><br><br>
	  </cfoutput>
	
	
	
	
	<!--- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->
	<!---                        CFDOCUMENT FILES                                    --->
	<!--- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->
	
	<cfdirectory Action="list" name="contents" directory="#application.PDFDirdel#" filter="*.pdf">
	
	<cfset dirList=""><!--- saving the list of directories to this list --->
	<ol>
	<cfoutput query="contents">
		<cftry>
		<cfif (FileExists("#application.PDFDirdel#\#Name#")) AND (DatelastModified LT yesterday)>
				<li>Deleting .... #application.PDFDirdel#\#Name#</li>
				<cffile action="Delete" file = "#application.PDFDirdel#\#Name#">
		<cfelse>
		
		</cfif>
		<cfcatch type="Any">
			<cfset errorMsg="There was a problem trying to delete document: <br><br>#thispath#\#Name#<br><br>">
			<cfset errorMsg=#errorMsg# & "This document may be open by you or another user.">
			<li><b>#ErrorMsg#</b>
		</cfcatch>
		</cftry>
	</cfoutput>
	</ol>

	<p><b>Clean-up of temp files - older than one day - complete.</b></p>
	