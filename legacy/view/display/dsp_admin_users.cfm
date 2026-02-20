


<!--- MGANN 2011. Uses the following:
      model/m_user/get_odsUser Looks up user in ADW (for creation)
	  model/m_user/get_users   Looks up user in ARA (after creation)
	  model/m_user/InsNewUser  Create ARA User
	  model/m_user/UpddateUser  Update ARA User
	  model/m_user/Delete User  Delate ARA User
	  model/m_user/qry_CheckID  Checks all types of ARA Records for user dependencies (eg, before allow deletion)
	  model/m_emails/Mail_UserAccount  Mails account info on creation or update --->
<cfparam name="Action" default="LookupSetup">
<cfparam name="user_Name" default="">
<cfparam name="id_job" default="">
<cfparam name="Inactive" default="0">
<cfparam name="alion_user" default="">
<cfparam name="UserID" default="">
<cfparam name="Status" default="Active">
<cfparam name="Approve_Op" default="">
<cfparam name="Approve_Grp" default="">
<cfparam name="Approve_div" default="">
<cfparam name="ForSector" default="">
<cfparam name="showUserList" default="no">
<cfparam name="sort" default="Last_name">
<cfset menu="Admin">
<cfset Pagetitle="Administrator: User Setup">
<cfset submenu="users">
<cfset sector="">
<cfset subhdr="">
<cfset email="">
<cfset buttontext="Submit">
<cfset first_name="">
<cfset last_name="">
<cfset job_title="">
<cfset group_dept="">
<!--- Include does lookup of Access Request Forms --->
<cfinclude template="inc_getAuthFile.cfm">

<cfswitch expression="#action#">
<cfcase value="Lookup">

	<cfinclude template="../../model/m_user/get_odsUser.cfm">
	<!---<cfdump var="#ods_Users#" format="text">--->
	<cfif #ods_users.recordcount# EQ 1><!--- exists in corporate user db --->
		<!--- see if this person already is in ARA --->
		<cfset ShowExisting="yes">
		<cfinclude template="../../model/m_user/get_users.cfm">
		
		<cfif gUsers.Recordcount GT 0><!--- Update already in ARA --->
		
			<cfset Faction="app.Admin_UpdateUser">
			<cfset subhdr="Update ARA User Profile">
			<cfset buttontext="Update ARA Profile">
			<cfset ID_User=gUsers.Id_User>
			<cfset id_job=gUsers.id_job>
			<cfset ForSector=gUsers.sctr>
			<cfset qname="gUsers">
			<cfset ChkFile=#GetAuthfile(gUsers.oprid,gUsers.id_user)#>	<!---Check to see if accesss request --->
		<cfelse><!--- new do insert --->
			<cfset Faction="app.Admin_InsNewUser">
			<cfset subhdr="Add ARA User: #Empname#">
			<cfset qname="ods_users">
			<cfset buttontext="Add User">
		</cfif>
	<cfelse>
		<cfif ods_users.recordcount GT 1>
			<cfset errorMsg="This user was found more than once in the ODS database">
		</cfif>
	</cfif>
</cfcase>

<cfcase value="Lookup2">

	<!---<cfdump var="#form#">--->
	
	<cfset ShowExisting="yes">
		<cfinclude template="../../model/m_user/get_hiiUser.cfm">

	<cfif #ods_users.recordcount# EQ 1><!--- exists in corporate user db --->
		<cfset ShowExisting="yes">
		<cfinclude template="../../model/m_user/get_users.cfm">
			
		<cfif gUsers.Recordcount GT 0><!--- Update already in ARA --->

			<cfset Faction="app.Admin_UpdateUser">
			<cfset subhdr="Update ARA User Profile">
			<cfset buttontext="Update ARA Profile">
			<cfset ID_User=gUsers.Id_User>
			<cfset id_job=gUsers.id_job>
			<cfset ForSector=gUsers.sctr>
			<cfset qname="gUsers">
			<cfset ChkFile=#GetAuthfile(gUsers.oprid,gUsers.id_user)#>	<!---Check to see if accesss request --->
		<cfelse><!--- new do insert --->
			
			<cfset Faction="app.Admin_InsNewUser">
			<cfset subhdr="Add ARA User: #Empname#">
			<cfset qname="ods_users">
			<cfset buttontext="Add User">
		</cfif>
	<cfelse>
		<cfif ods_users.recordcount GT 1>
			<cfset errorMsg="This user was found more than once in the ODS database">
		</cfif>
	</cfif>

</cfcase>
<!---cfcase value="Insert">
	<cfset Faction="app.Admin_InsNewUser"></cfcase --->
<cfcase value="Delete">
	<cfset Faction="app.Admin_DeleteUser"></cfcase>
<cfcase value="UpdateSetup">
	<cfinclude template="../../model/m_user/get_users.cfm">
	<cfset subhdr="Update #gUsers.empname#">
	<cfset qname="gUsers">
	<cfset ChkFile=#GetAuthfile(gUsers.oprid,gUsers.id_user)#> <!---Check to see if accesss request --->
	<cfset faction="app.Admin_UpdateUser">
</cfcase>
</cfswitch>

<!--- **********************************************************  --->
<!---          Autocomplete for user look up                     --->
<!--- ********************************************************** --->
<script>
  $(document).ready(function(){
              $("#alion_user").autocomplete("index.cfm?fuseaction=app.usersAutoComplete",
                {
                                minChars:1,
                                delay:200,
                                extraParams: {sector: function() { return $("input[name='Sector']:checked").val(); }},
                                autoFill:false,
                                matchSubset:true,
                                matchContains:1,
                                cacheLength:10,
                                selectOnly:1
                });
                $("#alion_user").result(function(event,data)
                {
                                var tmp = data[0].split(" [");
                                var name = tmp[0];
                                var oprid = tmp[1].replace("]","");
                                $("#alion_user").val(oprid);
                });

                $("input[name='Sector']").change(function() {
                	$('input#alion_user').flushCache();
                });

  });
 </script>
 
<!--- **********************************************************  --->
<!---          Show / Hide Assign Group Field                     --->
<!--- ********************************************************** --->
 <script type="text/javascript">
$("document").ready(function() {
	$("#Groups").show("fast");
	<!---<cfif isDefined('id_job') and (id_job NEQ "") and ((id_job LTE 9) or (id_job GT 24)) >
		$("#Groups").show("fast");
	<cfelse >
		$("#Groups").hide("fast");
	</cfif>--->
});
</script>
<script type="text/javascript">
function this_job ()
{
	$("#Groups").show("fast");
  <!--- var job=$("#id_job").val();
   	if (job <= 9 && job > 3){  /* Sector Manager or below */
		$("#Groups").show("fast");
	}
	else if (job > 24){  /* Sector Manager or below */
		$("#Groups").show("fast");
	} else {
		$("#Groups").hide("fast");
	}--->
}
</script>


<!--- cfdump var="#gusers#" format="text" --->
<table cellpadding=0 cellspacing=0 width=95%>
<tr>
	<td>
<cfif session.id_role EQ 2><!--- system admin --->
	<cfif (NOT isdefined('subhdr')) OR (Subhdr EQ "")>
		<p class="smtitle">Administration</p>
		<p class="title">User Setup</p>
	<cfelse>
		<p class="smtitle">User Admin</p>
		<p class="title"><cfoutput>#subhdr#</cfoutput></p>
	
	</cfif>
<cfelse>
	<p class="smtitle">ARA Users</p>
	<p class="title">User List/Lookup</p>
</cfif>
<!--- <cfdump var="#session#" format="text"> --->
</td>
<td valign="top" width=35 nowrap align="right">
<img src="images/HelpIcon.gif" border=0 align="left" >&nbsp;<a class="embed" href="index.cfm?fuseaction=app.help&topic=admin_users">Help</a>
</td></tr></table>
<cfinclude template="dsp_messages.cfm">


<!--- User JQuery Autocomplete  --->
<cfform  name="User_setup"  method="Post"  enctype="multipart/form-data"  action="index.cfm?Fuseaction=app.admin_users">
	<cfinput type="hidden" name="Action" Value="Lookup2">
	<table cellpadding=2 cellpadding=2 class="border">
	<tr><td class="border">
	Enter [all or partial] 5+2 
	</td>
	<td class="border">
	<cfinput type="text" required="yes" Message="Enter all or partial 5+2" class="inputtext" id="alion_user" name="alion_user" style="width:350px;"/>
	</td>
	<td class="border">
	<cfinput name="Lookupsubmit" type="submit" value="LookUp Profile">
	</td></tr>
	</table>
</cfform>
<!--- end of auto complete form --->


<cfif subhdr NEQ ""><!--- Then have processed lookup --->
<table cellpadding=2 cellspacing=2 width=90% class="border">
	
<cfoutput query="#qName#">
<cfform  name="UserForm"  method="Post" enctype="multipart/form-data" action="index.cfm?Fuseaction=#Faction#">
	<cfinput type="hidden" name="ShowUserList" value="#ShowUserList#">
	<cfif session.id_role EQ 2><!--- System Admin --->
		<cfinput type="hidden" name="oprid" value="#oprid#">
		<cfinput type="hidden" name="first_name" value="#first_name#">
		<cfinput type="hidden" name="Last_name" value="#Last_Name#">
		<cfinput type="hidden" name="CostCenter" value="#cost_center#">
		<!---<cfinput type="hidden" name="sctr" value="#sctr#">--->
		<cfinput type="hidden" name="grp" value="#grp#">
		<cfinput type="hidden" name="email_addr" value="#email_addr#">
		<!---<cfinput type="hidden" name="oprtn" value="#oprtn#">--->
		<cfinput type="hidden" name="dvsn" value="#dvsn#">
		
		<cfif isDefined('Id_User') and (Id_User NEQ "")>
			<cfinput type="hidden" name="Id_user" value="#id_User#">
			<cfset userId=#id_user#>
		</cfif>
</cfif>
<cfif Faction eq "app.Admin_UpdateUser"><!--- User already exists...doing update show dates --->
	<tr>
		<td class="borderq">
		
		Added: 
		</td>
		<td class="border">
		<cfif isDefined('created_on') and created_on NEQ "">
			#dateformat(created_on,"MM/DD/YY")# #timeformat(created_on,"hh:mm tt")#, By 
			<cfquery name="creator" datasource="#Application.dsn#">
				select oprid from users where id_user=#created_by#
			</cfquery>
			#creator.oprid#
		<cfelse>
			Unknown, Pre SOX FY 2013
		</cfif>
		</td>
		<td class="borderq">
		Modified: 
		</td>
		<td class="border">
		<cfif isDefined('modified_on') and modified_on NEQ "">
			#dateformat(modified_on, "MM/DD/YY")# #timeformat(modified_on,"hh:mm tt")#, By 
			<cfquery name="updator" datasource="#Application.dsn#">
			select oprid from users where id_user=#modified_by#
		</cfquery>
		#updator.oprid#
		<cfelse>
		&nbsp;&nbsp;--
	    </cfif>
   </tr>
</cfif>
		
<tr>
	<td class="borderq" >
		Name
	</td>
	<td  class="border">
		<b>#EmpName#</b>
		<cfinput type="hidden" name="empname"  value="#EmpName#">

	</td>
	<td class="borderq">
		Employee ID
	</td>
	<td colspan=2 class="border">
		#emplID#
		<cfinput type="hidden" name="emplid" value="#emplid#">

	</td>
</tr>
<tr>
	<td width="40%" colspan=2 class="borderq">
	ORG:&nbsp;&nbsp;<!---Sector <img src="images/RightArrow.png"> --->
	Group <img src="images/RightArrow.png"> 
	<!---Operation <img src="images/RightArrow.png"> --->
	Division</td>
	<td width="60%" colspan=3 class="border">
	<!---#sctr# <img src="images/RightArrow.png"> --->
	#grp# <img src="images/RightArrow.png"> 
	<!---#oprtn# <img src="images/RightArrow.png"> --->
	#dvsn#
	</td>

</tr>

<tr>
	
	<td colspan=2 class="borderq">Status: &nbsp;&nbsp;&nbsp;&nbsp;
	<cfif session.id_role EQ 2><!--- System Admin --->
		<input name="Inactive" value="0" type="radio" <cfif #Inactive# EQ 0>checked</cfif>>&nbsp;Active
		<input name="Inactive" value="1" type="radio" <cfif #Inactive# EQ 1>checked</cfif>>&nbsp;Inactive
	<cfelse><!--- Non-Admin --->
		<cfif Inactive EQ 0>Active<cfelseif Inactive EQ 1>Inactive</cfif>
	</cfif>
	</td>
	<td class="borderq">
	Job Title
	</td>
	<td  colspan=2 class="border">
	<b>#title#</b>&nbsp;&nbsp;&nbsp;<img src="images/RightArrow.png">&nbsp;<a class="embed" href="index.cfm?fuseaction=app.ApprovalChain&ThisSec=#sctr#&ThisGrp=#grp#&Menu=ApprovalChain">See Approval Chain</a>
	</td>
	
</tr>

<tr>


	<td colspan=3 class="border" style="padding: 10px;">
	<cfif session.id_role EQ 2><!--- System Admin --->
	<p class="hdr2">ARA ROLE</b></p>
	
		<table cellpadding=2>
		<cfloop query="gRoles">
		<cfif id_role NEQ 5><!--- Auditor Role not implemented....sox Access form is in conflict with App.
		                          Auditor can be acheived by role=User, Jobtitle = Auditor --->
		<tr>
			<td valign="top">
			<Cfif isDefined('gUsers.ID_Role') AND (gUsers.ID_Role EQ ID_role)>
				<cfinput type="radio" required="yes" Message="You must select a Security / System Role" 
				name="ID_role" value="#id_role#" Checked>
			<cfelse>
				<cfinput type="radio" required="yes" Message="You must select a Security / System Role" 
				name="ID_role" value="#id_role#">
			</cfif>
			
			
			</td>
			<td nowrap valign="top"><b>#rolename#</b>:</td><td valign="top"> #roleDesc#</td></tr>
		</cfif>
		</cfloop>
		</table>
		<cfelse><!--- Non-admin User --->
		<b>ARA ROLE</b>
		&nbsp;&nbsp;
			<cfif isDefined('RoleName') and (Rolename NEQ "")>
				#roleName#
			<cfelse>
				Not an ARA user
			</cfif>
		</cfif>
		<cfif session.id_role EQ 2>
		<p><b>NOTE:</b>&nbsp;&nbsp;Auditors/Read only users can be configured using a role of "User" and a job title of "Administrator".</p>
		</cfif>
	
	</td>

	<td   valign="top" class="border">
	<cfif session.id_role EQ 2><!--- system admin --->
	<p class="hdr2">ARA JOB TITLE</b></p>
		<cfquery name="get_jobs" datasource="#application.dsn#">
			Select * from JobTitle where inactive=0
			Order by AppOrder,title
		</cfquery>
		<cfselect size=#val(get_jobs.recordcount)# class="inputtext" onChange="this_job();" id="id_job" name="id_job" required="yes" Message="Select a job the user will play in the approval process.">
			<cfloop query="Get_jobs">
				<option value="#id_job#" <cfif gUsers.id_job EQ id_job>selected</cfif>>#title#</option>
			</cfloop>
		</cfselect>
	<cfelse><!--- Non admin user --->
		<b>ARA JOB TITLE</b>:
		&nbsp;&nbsp;
		<cfif isDefined('RoleName') and Rolename NEQ "">
			#Title#
		<cfelse>
			Not an ARA user
		</cfif>
	</cfif>
	
			
	</td>
	<td valign="top" class="border">
	<cfif session.id_role EQ 2>
	
	<div id="Groups">
		<p class="hdr2">Approval Group <br><font style="color:##888888;font-size:7px;">in addition to home group (#grp#)</font></p>
		
		<cfquery name="groups" datasource="#application.dsn#">
			SELECT DISTINCT GRP FROM ara_CP_Reorg where GRP in ('CEW', 'LVC', 'ISR', 'FSG','AD', 'GS','WS', 'AUS', 'UXS', 'NUC') ORDER BY GRP
			<!---select distinct grp,sctr
			from org_ckis
			-- sctr='#sctr#'
			where  grp not in ('DETG', 'BSG', 'OSG','') and sctr != 'DOIS'
			order by sctr--->
		</cfquery>
		<cfset groupList=#ValueList(groups.grp)#>
        	<cfif not isdefined("id_user")>
            	<cfset id_user = 0>
            </cfif>	
        	
                
           <select size="#val(groups.recordcount+1)#" class="inputtext" name="Approve_grp" multiple>
           	<option value="0"> - Select - </option>
			<cfset loopcount=1>
			<cfloop index="grp" list="#groupList#">
			
            	<cfquery name="HasThisGroup" datasource="#application.dsn#">
                    SELECT  *
                    FROM    approval_grp
                    Where <cfif isdefined("url.userID")>id_user = '#url.userID#' <cfelse>id_user = #id_user#</cfif> and 
                    approval_group= '#ListGetAt(grouplist,loopcount)#'  and inactive = 'False' and id_job = '#gUsers.id_job#'
                </cfquery>
				<cfif HasThisGroup.RecordCount GT 0>
					<option value="#ListGetAt(grouplist,loopcount)#" SELECTED>#ListGetAt(grouplist,loopcount)#</option>
				<cfelse>
					<option value="#ListGetAt(grouplist,loopcount)#">#ListGetAt(grouplist,loopcount)#</option>
				</cfif>
				<cfset loopcount=loopcount+1>
			</cfloop>
		</select>
	</div>
	
	<cfelse>
		Approves for Group: <b>#gUsers.Approve_grp#</b>
	</cfif>
	</td>
</tr>
<cfif session.id_role EQ 2><!--- system admin --->
<tr>
	<td class="border">
	Upload Access Request
	<td colspan=4 class="border">
		<cfif isDefined('id_user') and (id_user NEQ "")>
			<cfif isDefined('Filelinks') AND FileLinks NEQ "">
				Access Request(s) previously uploaded. You may re-upload a new access request; It will not overwrite the previous form.
				<ol>
				<cfloop index="docLink" List="#fileLinks#">
					<li>#docLink#</li>
				</cfloop>
				</ol>
			<cfelse>
				<font class="tiny">An access request form has not been uploaded for this user.</font>
			</cfif>
		<cfelse>
			<font class="tiny">An access Request form is required.</font>
		</cfif>
		<cfif Faction EQ "app.Admin_InsNewUser">
			<cfinput type="file" class="inputtext" Name="approvalform" required="Yes" message="New Users Require an Access Request Form" size="80" maxlength="200">
		<cfelse>
			<cfinput type="file" class="inputtext" Name="approvalform" size="80" maxlength="200">
		</cfif>
		
	</td>
	
</tr>
</cfif>
<cfif session.id_role EQ 2><!--- system admin --->
<tr>
	<td colspan=6 class="border" align="center">
		<input class="button" type="submit" value="#buttontext#">
		</td>
</tr>
</cfif>

</table>

</cfform>

</cfoutput>

</cfif><!--- 1 record found --->
<cfset id_user=""><cfset oprid="">

<!---                         +++++++++++++++++++++   USER LIST   ++++++++++++++++++++++            --->


<cfif ShowUserList EQ "Yes">
<cfquery name="sctrs" datasource="#application.ods#">
	select distinct sctr from org_ckis
</cfquery>
<cfif isDefined('url.staleusers')>
<br><br>
<p class="title">Stale User List: <Cfoutput>#dateformat(Now(),"mm/dd/YY")#,  #timeformat(now(),"hh:mm tt")#</cfoutput></p>

<cfelseif (isDefined('url.inactive') and url.inactive EQ 0)>
<br><br>
<p class="title">Active Users: <Cfoutput>#dateformat(Now(),"mm/dd/YY")#,  #timeformat(now(),"hh:mm tt")#</cfoutput></p>
<cfelseif (isDefined('url.inactive') and url.inactive EQ 1)>
<br><br>
<p class="title">Inctive Users: <Cfoutput>#dateformat(Now(),"mm/dd/YY")#,   #timeformat(now(),"hh:mm tt")#</cfoutput></p>
</cfif>
<br><br>
<table id="userList" cellpadding=0 cellspacing=0 width=95%>
<tr>
<td valign="top">
<p class="subtitle">Click name 
<cfif session.id_role EQ 2>to update<cfelse>for user details</cfif>. 
</p>
</td>
<!---<td nowrap>
Click for Sector:
<cfoutput>
<cfloop index="i" list="#valuelist(sctrs.sctr)#">
    <input type="radio" name="ForSector" onclick="Javascript: window.location.href='index.cfm?Fuseaction=app.admin_users&ShowUserList=Yes&sort=sctr&ForSector=#i#';" value="#i#" <cfif Forsector EQ i>checked</cfif>>&nbsp;#i#&nbsp;
</cfloop>
</cfoutput>
</td>--->
<td align="right">
	<img src="images/rightArrow.png">
	<a class="embed" href="index.cfm?FuseAction=app.admin_users&Sort=ID_Role&Menu=Admin&Submenu=Part&ShowUserList=No">Hide User List</a>&nbsp;&nbsp;
	<cfif session.id_role EQ 2>
		<cfif Inactive EQ 0>
			<img src="images/rightArrow.png"><a class="embed" href="index.cfm?fuseaction=app.Admin_Users&Menu=Admin&submenu=Users&ShowUserList=Yes&Inactive=1">See Inactive Users</a>
		<cfelse>
			<img src="images/rightArrow.png"><a class="embed" href="index.cfm?fuseaction=app.Admin_Users&Menu=Admin&submenu=Users&ShowUserList=Yes&Inactive=0">See Active Users</a>
		</cfif>
		&nbsp;&nbsp;<img src="images/rightArrow.png"><a class="embed" href="index.cfm?fuseaction=app.Admin_Users&Menu=Admin&submenu=Users&ShowUserList=Yes&StaleUsers">See Stale Users</a>
	</cfif>
</td>
</tr></table>
<table id="userlist" cellpadding=3 cellspacing=0  width="100%" class="border" style="border-collapse:collapse;">
 <thead>

	<th></th>
	<th>Name</th>
	<th>Job Title</th>
	
	<th>Group</th>
	<th>Ops</th>
	<th>Division</th>
	<th>Security Role</th>


</thead>
<cfif showUserList NEQ "No">
	<cfinclude template="../../model/m_user/get_users.cfm">
</cfif>
<cfset count=1>
<tbody>

<cfoutput query="gUsers">
<cfif (gUsers.sctr NEQ "" and gUsers.grp NEQ "") OR (session.id_role EQ 2)><!--- only show users that are also in ODS, unless this is an admin --->
<cfif isDefined('userid') and (userid eq id_user)>
	<tr>
	<td width=18 class="approve"><img src="images/ThisArrow.gif" width=18 alt=""></td>
<cfelse>
	<tr>
		<td width=18 class="border">#count#.</td>
</cfif>

	<td class="border"><a class="embed" href="#self#?fuseaction=app.admin_users&action=UpdateSetup&id_user=#id_user#&oprid=#oprid#&id_job=#id_job#&sort=#sort#&ShowUserList=Yes&Inactive=#Inactive#">#Last_name#,&nbsp;&nbsp;#First_Name# </a></td>
	
	<td class="border">#title#
	<cfif #Approve_Grp# NEQ "">
		<span class="red"><br>Approves for Group #approve_grp#</span>
	</cfif>
	</td>
	<cfif gUsers.sctr EQ "" and gUsers.grp EQ "">
		
		<td class="border">#grp#</td>
		<td class="border">#oprtn#</td>
		<td class="border">#dvsn# #org_desc#</td>
		<td class="border"><span class="red">(Gone)</span></td>
	<cfelse>
		
		<td class="border">#grp#</td>
		<td class="border">#oprtn#</td>
		<td class="border">#dvsn# #org_desc#</td>
		<td class="border">#RoleName#</td>
	</cfif>
	
	
</tr>
<cfset count=count+1>
</cfif>

</cfoutput>
</tbody>
</table>
<cfelse>
<br>
	<img src="images/rightArrow.png">&nbsp;&nbsp;<a href="index.cfm?Fuseaction=app.admin_users&ShowUserList=Yes" class="embed"><b>Show User List</a>
<br>
</cfif>

<script language="javascript" type="text/javascript">
	$(document).ready(function() {
		var defaultSearchTerm = ""; //
		var n = location.href.indexOf("?Conflict"); // is there a note id in the url string
		if (n > 1) {
			defaultSearchTerm = location.href.substr(n + 1);
		}
		var oTable = $('#userlist').dataTable({
			"oSearch" : {
				"sSearch" : defaultSearchTerm
			},
			"searching" : true,
			"bJQueryUI" : true,
			"bProcessing" : true,
			"bFilter" : true,
			"sPaginationType" : "full_numbers",
			"iDisplayLength" : 50,
			"aLengthMenu" : [ [ -1, 10, 25, 50 ], [ "All", 10, 25, 50 ] ],
			"bAutoWidth" : false,
			"aaSorting" : [ [ 0, "asc" ] ],
			"aoColumns" : [ {
				"sType" : "numeric",
				"bSortable" : true}, //count
			{
				"sType" : "html",
				"bSortable" : true},//name
			{
				"sType" : "html", //job tile
				"bSortable" : true
			},
			
			{
				"sType" : "html", //group
				"bSortable" : true
			},
			{
				"sType" : "html", //ops
				"bSortable" : false
			},
			{
				"sType" : "html", //division
				"bSortable" : false
			},
			{
				"sType" : "html", //Security Role
				"bSortable" : false
			}
			

			]
		});
	});
</script>
