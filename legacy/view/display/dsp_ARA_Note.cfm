<!--- **********************************************************  --->
<!---                        ARA Notes Page                   --->
<!--- ********************************************************** --->
<cfinclude template="inc_tooltipContent.cfm">
<cfparam name="Action" default="InsertSetup">
<cfparam name="buttontext" default="submit">
<cfparam name="Note" default="">
<cfparam name="notesort" default="desc">  
<cfset whichtab="Notes">
<cfif isDefined('url.aid')>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cfelse>
	Error: Encrypted ARA ID Not Provided to dsp_ara_note.
</cfif>


<!--- +++++++++++ Pulls ARA, user, groups, sector, category, status ++++++++++ --->
<cfinclude template="../../model/m_ara/qry_ara.cfm">
<!--- ++++++++++  Insert, update and delete actions associated with notes ++++ --->
<cfinclude template="../../model/m_forms/act_ara_note.cfm">

<!--- ------------------------------------------------------------------ --->

<cfoutput>
<!-- 1  --><table width=100% cellpadding=0 cellspacing=0 border=0>
		<tr>
		<td width="60%" valign="top">
		<p class="smtitle">
		ARA Status Note</p>
		<p class="aratitle">Title: #title#</p>
		</td>
		<td valign="top" align="right">
        <!---
		<a class="embed" href="#self#?fuseaction=app.ara_note&Menu=ARA_Detail&FormorView=View&AID=#AID#">Notes View Only</a>&nbsp;&nbsp;|&nbsp;&nbsp;
		<a class="embed" href="#self#?fuseaction=app.ara_note&Menu=ARA_Detail&AID=#AID#">Notes Form</a>&nbsp;&nbsp;|&nbsp;&nbsp;--->
		<a class="embed" href="#self#?fuseaction=app.ARA_cfdocument&AID=#AID#">Print ARA <img src="images/PrinterIcon.gif" border=0></a>

<!-- /1  --></td></tr></table>
</cfoutput>
<!--- ARA Summary Info at top of page ---><cfinclude template="dsp_ARA_top_summary.cfm">
	<cfparam name="formorview" default="form">

<cfif (FormorView EQ "Form")>
<fieldset><legend><b>ARA Backup Detail</b></legend>
<!--- ARA Navigational Tabs ---><cfinclude template="dsp_tabset.cfm">
<cfinclude template="dsp_Messages.cfm">



<cfset MaxtipLen=2000>
<cfset Tiplen=0>
<cfset charsleft=2000>
<cfset tip="">


<script type="text/javascript">
<!--
/* This script and many more are available free online at
The JavaScript Source :: http://javascript.internet.com
Created by: kojak :: http://commoncoder.com */

function CheckFieldLength(fn,wn,rn,mc) {
  var len = fn.value.length;
  if (len > mc) {
    fn.value = fn.value.substring(0,mc);
    len = mc;
  }
  document.getElementById(wn).innerHTML = len;
  document.getElementById(rn).innerHTML = mc - len;
}
//-->
</script>



<cfoutput>
<p class="title">Status Notes</p>
<table width=100% class="outerborder" cellpadding="2" cellspacing="2">
<tr>
	<td class="border">
		Up to 2000 characters. &nbsp;&nbsp;&nbsp;&nbsp;(<small><span id="charcount3">0</span> characters entered.&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;<span id="remaining3">2000</span> characters remaining.</small>)
	</td>
</tr>
	<cfform action="index.cfm?fuseaction=app.ara_note" method="post">
	<cfinput type="Hidden" name="Action" value="#Action#">
	<cfinput type="hidden" name="id_ara" value="#id_ara#">
	<cfif NOT #FindNoCase('Insert',Action)#>
		<cfinput type="hidden" name="id_note" value="#id_note#">
	</cfif>
	<cfinput type="hidden" name="added_by" value="#session.id_user#">
	<tr>
		<td class="border">
		<textarea id="note" onkeyup="CheckFieldLength(note, 'charcount3', 'remaining3', 2000);" onkeydown="CheckFieldLength(note, 'charcount3', 'remaining3', 2000);" onmouseout="CheckFieldLength(note, 'charcount3', 'remaining3',2000);"  class="inputtext" name="note" cols=100 rows=5>#note#</textarea> </td>
	</tr>
  
    <tr>
        <td align="center" class="border">
		<input type="submit" name="submit" value="#buttontext#" />
		<cfif NOT #findnocase('Insert',Action)#>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="button" value="Delete" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.ara_note&Action=Delete&id_note=#id_note#&aid=#AID#';">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" value="Add New" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.ara_note&Action=InsertSetup&AID=#AID#';">
		<cfelse>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="reset" name="reset" value="Reset" />
		</cfif></td>
    </tr>
  </cfform>
  
</table>
</cfoutput>

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
	<p class="title2">All Notes: &nbsp;&nbsp;&nbsp;
	<cfif notesort EQ "Desc">
		<img src="images/RightArrow.png" align="absbottom">
	</cfif>
	<a class="embed" href="index.cfm?fuseaction=app.ara_note&aid=#aid#&notesort=Desc">Sort Last to First</a>&nbsp;&nbsp;|&nbsp;&nbsp;
	<cfif notesort EQ "ASC">
		<img src="images/RightArrow.png" align="absbottom">
	</cfif>
	<a class="embed" href="index.cfm?fuseaction=app.ara_note&aid=#aid#&notesort=Asc">Sort First to Last</a></p>
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
		<cfif isDefined('this_id_note') and (id_note EQ this_id_note)><font class="hilite"></cfif>
		<cfif session.id_user EQ added_by><!--- Then can make edits to Note --->
			<p><b><a href="index.cfm?fuseaction=app.ara_note&Action=Updatesetup&this_id_note=#id_note#&id_note=#id_note#&AID=#AID#" class="note">
		#Author.empname# Added: #dateformat(added_on,"MM/DD/YY")#, #timeformat(added_on,"hh:mm tt")#</a> </b> (can edit)</p>
		<cfelse>
			<p class="note">
		#Author.empname# Added: #dateformat(added_on,"MM/DD/YY")#, #timeformat(added_on,"hh:mm tt")#</p>
		</cfif>
	<p style="margin-left: 40px;">#cleanStr#<cfif #Notes.Recordcount# GT 1><br></font></cfif>
		</cfoutput>
	</td></tr></table>
<cfelse>
<p>No status notes have been entered.</p>
</cfif>
</fieldset>
<cfelse>
	<cfinclude template="dsp_ARA_Note_view.cfm">
</cfif>
</body>
</html>
