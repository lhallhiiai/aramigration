<!--- **********************************************************  --->
<!---                        ARA Notes Page                   --->
<!--- ********************************************************** --->

<cfparam name="formorview" default="form">
<cfparam name="notesort" default="Asc">

<cfif isPrint EQ "No">
	<fieldset><legend><b>ARA Backup Detail</b></legend>
<cfelse>
	<fieldset><legend><b><font style="font-size: 9pt; font-family: Trebuchet MS;">Backup Notes</font></legend>
</cfif>
	
<cfif NOT isDefined('isPrint') OR isPrint EQ "no">
<!--- ARA Navigational Tabs ---><cfinclude template="dsp_tabset.cfm">
<cfinclude template="dsp_Messages.cfm">
</cfif>


<!--- ********************************************************************** --->
<!--- Display previous notes, if they exist --->
<cfquery name="Notes" datasource="#Application.dsn#">
	Select * from ara_note
	where id_ara=#id_ara#
	ORDER by id_note #Notesort#
</cfquery>
<cfif #Notes.Recordcount# GT 0>
	<br><br>
	<table cellpadding=0 cellspacing=0>
	<tr><td valign="top">
	<cfoutput>
	<cfif NOT isDefined('isPrint') OR isPrint EQ "no">
		<p class="title2">All Notes: &nbsp;&nbsp;&nbsp;
		<cfif notesort EQ "Desc">
			<img src="images/RightArrow.png" align="absbottom">
		</cfif>
		<a class="embed" href="index.cfm?fuseaction=app.ara_note&aid=#aid#&notesort=Desc">Sort Last to First</a>&nbsp;&nbsp;|&nbsp;&nbsp;
		<cfif notesort EQ "ASC">
			<img src="images/RightArrow.png" align="absbottom">
		</cfif>
		<a class="embed" href="index.cfm?fuseaction=app.ara_note&aid=#aid#&notesort=Asc">Sort First to Last</a></p>
	</cfif>
	</cfoutput>
		<cfoutput query="Notes">
		<cfscript>
		function stripHTML(str) {
	   		return REReplaceNoCase(str,"<[^>]*>","","ALL");
		}
		</cfscript>
		<cfquery name="Author" datasource="#application.dsn#">
			Select empname from users
			where id_user=#added_By#
		</cfquery>
		<cfset cleanStr = stripHTML(note)>
		<cfset whichDate=#dateCompare(notes.added_on,notes.updated_on)#>
		
			<p class="note">
		#Author.empname# Added: #dateformat(added_on,"MM/DD/YY")#, #timeformat(added_on,"hh:mm tt")#</p>
		
	<p style="margin-left: 40px;">#cleanStr#<cfif #Notes.Recordcount# GT 1><br></font></cfif>
		</cfoutput>
	</td></tr></table>
<cfelse>
<p>No status notes have been entered.</p>
</cfif>
</fieldset>

</body>
</html>
