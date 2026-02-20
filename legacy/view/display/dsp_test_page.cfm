<!--- MGann: Deletes all pdf files older than one day. If items have been
	  moved to the repository, they will also have to be removed from there
	  manually.  --->
	  
	  <cfset thisPath=#Getdirectoryfrompath(GetCurrentTemplatePath())#>
	  <cfset yesterday=DateAdd("D",-1,Now())>
	  <cfoutput>
	  This Path is: #ThisPath#<br>
	  Yesterday is: #yesterday#<br>
	  </cfoutput>
	
	
	<!--- Delete all ARADocument-111.pdf, that have been generated from print/cfdocument output --->
	<cfdirectory Action="list" name="contents" directory="#Thispath#" filter="ARADocument-*.pdf">
	<cfset dirList=""><!--- saving the list of directories to this list --->
	<cfoutput query="contents">
		FileName is #Name#, Date: #dateformat(DateLastModified,"MM/DD/YY")#<br>
		<cftry>
		<cfif (FileExists("#thispath#\#Name#")) AND (DatelastModified LT yesterday)>
				<br>Deleting .... #thispath#\#Name#<br>
				<cffile action="Delete" file = "#thispath#\#Name#">
		</cfif>
		<cfcatch type="Any">
			<cfset errorMsg="There was a problem trying to delete document: <br><br>#thispath#\#Name#<br><br>">
			<cfset errorMsg=#errorMsg# & "This document may be open by you or another user.">
			<br>#ErrorMsg#<br>
		</cfcatch>
		</cftry>
	</cfoutput>