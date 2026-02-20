<cfset pagetitle="ARA Delegations">
<cfset menu="Admin">
<cfset submenu="Delegations">
<cfparam name="buttontext" default="submit">
<cfparam name="action" default="InsertSetup">
<cfparam name="title" default="View and Setup Delegations">
<cfparam name="fk_delegateFrom_ID" default="">
<cfparam name="fk_delegateTo_ID" default="">
<cfparam name="This_delegator" default="#session.oprid#">
<cfparam name="startDate" default="">
<cfparam name="EndDate" default="">
<cfparam name="auditor" default="False">
<cfif session.id_job EQ 23 and session.id_role EQ 4>
	<cfset auditor=True>
</cfif>
<cfset noDelegation=0>
<!--- temp, for now default to Corporate User --->
<!--- cfset session.id_role=1 --->

<!--- **********************************************************  --->
<!---          Autocomplete for user look up                     --->
<!--- ********************************************************** --->
<script>
  $(document).ready(function(){
  		<cfif session.id_role EQ 2 or session.id_role EQ 1>
              $("#ara_user").autocomplete("index.cfm?fuseaction=app.ARAusersAutoComplete",
                {
                                minChars:2,
                                delay:200,
                                extraParams: {},
                                autoFill:false,
                                matchSubset:true,
                                matchContains:1,
                                cacheLength:10,
                                selectOnly:1
                });
				$("#ara_user").result(function(event,data)
                {
                                var tmp = data[0].split(" [");
                                var name = tmp[0];
                                var oprid = tmp[1].split("]:")[0];
                                $("#ara_user").val(data[0]);
								$('#delegatee').load('index.cfm?fuseaction=app.delegatees&oprid=' + oprid);
                });
		<cfelse>
				$('#delegatee').load('index.cfm?fuseaction=app.delegatees&oprid=<cfoutput>#session.oprid#</cfoutput>');
		</cfif>


  });
 </script>
<!--- cfinclude template="../../model/m_user/qry_delegateList.cfm" ---><!--- gets delegator and Delegate_To lists --->
<cfinclude template="../../model/m_user/act_delegate.cfm"><!--- Contains insert, update, and delete code --->

<!--- cfdump var='#session#' format="text" --->
<table cellpadding=0 border=0 cellspacing=0 width=95%>
<tr>
	<td>
<cfif session.id_role EQ 2 or session.id_role EQ 1>
	<p class="smtitle">Admin Delegation</p>
<cfelse>
	<p class="smtitle">Set My Delegation</p>
</cfif>
<p class="title"><cfoutput>#pagetitle#</cfoutput></p>
</td>
<td valign="top" nowrap  align="right">
<!--- cfif session.id_role EQ 2 or session.id_role EQ 1>
	<a class="embed" href="index.cfm?fuseaction=app.AdminDelegate&Action=CleanUp">ADMIN: Remove Old Delegations</a>&nbsp;&nbsp;|&nbsp;&nbsp;
</cfif --->
<a class="embed" href="index.cfm?fuseaction=app.help&topic=admin_delegation">Delegation Rules</a>
</td></tr></table>

<cfinclude template="dsp_messages.cfm">
<cfif (Auditor is False) and (NOT ListFind('13,15,17,18,20,21,22,27,28,29',session.id_job))><!--- Auditor=Administrator and Role=User: Don't show form --->
<cfform name="Delegate" id="DelegateID" action="index.cfm?fuseaction=app.AdminDelegate" method="Post">
<cfinput type="Hidden" name="Action" value="#Action#">


<!--- ***********  Delegator: Delegate from   *************** --->


<Table cellpadding=2 cellspacing=2 class="border">
<tr>
<td class="border">
Delegate From<cfif Find('Insert',Action) and ((session.id_role EQ 2) OR (session.id_role EQ 1))> (Enter Lastname)</cfif>: &nbsp;&nbsp;
</td>
	<td class="border" colspan=3>
		<cfif ((session.id_role EQ 2) OR (session.id_role EQ 1)) AND Find('Insert',Action)><!--- This is an admin, can delegate for people  --->
			<!--- autocomplete ARA users, then look up delegatees once delegator selected --->
			<cfinput required="Yes" Message="Enter LastName of Delegator" name="ara_user" id="ara_user" class="inputtext" size=90 maxlength=120 onChange="">

</td></tr>

	<cfelse><!--- Otherwise this is not an admin, and are filling out delegation for themselves --->

		<cfoutput>
		<cfif (#session.id_role# NEQ 2) AND (session.ID_role NEQ 1)><!--- User setting up own delegation --->
			#session.empname#
			<input type="hidden" name="oprid" value="#session.oprid#">
		<cfelse>
			#delegateFrom_oprid#
			<input type="hidden" name="oprid" value="#delegatefrom_oprid#">
		</cfif>
		<cfif (isDefined('id_delegation')) AND (id_delegation NEQ "")>
			<input type="hidden" name="id_delegation" value="#id_delegation#">
		<cfelse>
			<input type="hidden" name="fk_delegateFrom_ID" value="#session.id_user#">
		</cfif>
		</cfoutput>
	</cfif>
	</td></tr>


<!--- *************         Delegate_To          *************** --->


	<tr><td class="border">
	Delegate To<cfif Find('Insert',Action) and ((session.id_role EQ 2) or (session.id_role EQ 1))> (will auto-populate)</cfif>: &nbsp;&nbsp;

<td colspan=3 class="border"><!--- Div is written to by model/scripts/qry_delegatees --->
	
	<cfif Find('Insert',Action)>
				<div id="delegatee"></div>
	<cfelse>
		<cfoutput>#delegateTo_oprid#
		<input type="hidden" name="DelegateTo" value="#delegateTo_oprid#">
		</cfoutput>
	</cfif>
</td></tr>

	<cfoutput>
<tr>
	<td valign="top" class="border">
	Starting Date
	</td>
	<td class="border">
		<cfif action NEQ "DeleteRecord">
		<cfinput  size=12 class="date"  style="background-color: ##E2E8DB;font-family:verdana;font-size:11px;" type="text" name="StartDate" REQUIRED="Yes" VALIDATE="date"
		 messsage="Enter Delegation Start Date" value="#startdate#">
		 <cfelse>
		 #startdate#
		 </cfif>
	</td>
	<td valign="top" class="border">
	Ending Date</td>
	<td valign="top" class="border">
		<cfif Action NEQ 'DeleteRecord'>
		<cfinput  size=12 class="date"  style="background-color: ##E2E8DB;font-family:verdana;font-size:11px;" type="text" name="EndDate" REQUIRED="Yes" VALIDATE="date"
		message="Enter Delegation End Date" value="#enddate#">
		<cfelse>
		#endDate#
		</cfif>
	</td>
	</cfoutput>


</td>
</tr>
<cfoutput>
<tr>
<td colspan=4 align="center" class="border">
<!--- Rules too complicated for update...so not showing update button for now. Delete and start new --->
<cfif NOT Find('Update',Action)>
<input class="button" type="Submit" Value="#buttontext#" onClick="JavaScript:return validateForm();">
</cfif>
<cfif #Find('Insert',Action)#>
	&nbsp;&nbsp;&nbsp;<input class="button" type="button" value="Reset" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.AdminDelegate&Menu=Admin&submenu=Delegations';">
<cfelseif #Find('Update',Action)#>
	&nbsp;&nbsp;&nbsp;<input class="button" type="button" value="Add New" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.AdminDelegate&Menu=Admin&submenu=Delegations';">
<cfelseif #Find('Delete', Action)#>
&nbsp;&nbsp;&nbsp;<input class="button" type="button" value="Cancel" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.AdminDelegate&Menu=Admin&submenu=Delegations';">
</cfif>
</td></tr>
</cfoutput>

</table>
</cfform>

</cfif>


<!--- MGann 8/20/2012: Pre UAT Request by George and Jim to put users own Delegations uptop --->
<cfquery name="ThisDelegator" datasource="#Application.dsn#">
    SELECT     	id_delegation, fk_delegateFrom_ID, fk_delegateTo_ID, delegateFrom_oprid, delegateTo_oprid, startDate, endDate
	FROM         delegation
	where endDate > '#Dateformat(now(),"mm/dd/yy")#'
	and (delegateFrom_Oprid='#This_Delegator#'
	OR 
	DelegateTo_oprid='#This_Delegator#')
	order by startdate ASC
</cfquery>

<cfif ThisDelegator.Recordcount GT 0>
<p class="subtitle"><cfoutput>#UCase(This_delegator)#</cfoutput> Delegations</p>
	<table width=100% cellpadding=2 cellspacing=2 class="border">
	<tr>
		<td width=18> </td>
		<td  class="grad">From</td>
		<td  class="grad">To</td>
		<td  class="grad">Start</td>
		<td class="grad">End</td>
		<!--- <td  class="grad">Delete</td> --->
		<!--- td  class="grad">Delete/Update</td --->
	</tr>
	<cfset loopcount=1>
	<cfoutput query="ThisDelegator">
	<cfif isDefined('thisDel') and (thisDel eq id_delegation)>
	<tr bgcolor="##edf3f9">
	<td width=18 class="approve"><img src="images/ThisArrow.gif" width=18 alt=""></td>
	<cfelse>
	<tr>
		<td width=18 class="border">#loopcount#.</td>
	</cfif>
			<cfset id_user=#fk_DelegateFrom_ID#>
			<cfinclude template="../../model/m_user/get_users.cfm">
			<td class="border"><b>#gUsers.empname#</b>,  #gUsers.title#<br>
			<cfif gUsers.Inactive EQ 1>
					Inactive ARA User
			<cfelse>
				#gUsers.roleName#,
				 #gUsers.sctr#, #gUsers.grp#
			</cfif></font>
			</td>
			<cfset id_user=#fk_DelegateTo_ID#>
			<cfinclude template="../../model/m_user/get_users.cfm">
			<td class="border" nowrap><b>#gUsers.empname#</b>, #gUsers.title#,<br />
			<cfif gUsers.Inactive EQ 1>
					Inactive ARA User
			<cfelse>
				#gUsers.roleName#,
			 <font class="tiny"  style="color:##999999;">#gUsers.sctr#, #gUsers.grp#
		</cfif></font></td>
			<td class="border">#dateformat(startdate,"MM/DD/YY")#</td>
			<td class="border">#dateformat(enddate,"MM/DD/YY")#</td>
			<td align="center" nowrap class="border">
			<cfif (session.id_user eq fk_delegateFrom_ID) or  ((session.id_role EQ 2) OR (session.id_role EQ 1)) >
			<a class="embed" href="#self#?Fuseaction=app.AdminDelegate&Action=DeleteSetup&thisdel=#id_delegation#&id_delegation=#id_delegation#&thisid_user=#fk_DelegateFrom_ID#"><img src="images/SmDelete.png" alt="Delete this Delegation" border=0></a>
			<!--- &nbsp;|&nbsp;
			<a class="embed" href="#self#?Fuseaction=app.AdminDelegate&Action=Updatesetup&thisdel=#id_delegation#&id_delegation=#id_delegation#&thisid_user=#fk_DelegateFrom_ID#"><img src="images/SmUpdate.png" border=0 alt="Update this Delegation"></a> --->
			<cfelse> --
			</cfif>
		</td>
		</tr>
		<cfset loopcount=loopcount+1>
	</cfoutput>
	</table>
</cfif>
<p class="subtitle">All ARA Delegations In Effect</p>
<cfset id_delegation="">
<table width=100% cellpadding=2 cellspacing=2 class="border">
<tr>
	<td width=18> </td>
	<td  class="grad">From</td>
	<td  class="grad">To</td>
	<td  class="grad">Start</td>
	<td class="grad">End</td>
	<td  class="grad">Delete</td>
	<td  class="grad">Email</td>
</tr>
<cfset loopcount=1>
<!--- cfinclude template="../../model/m_user/qry_getDelegation.cfm">
<cfoutput query="Del" --->
<!--- cfquery name="Del" datasource="#Application.DSN#">
	SELECT    id_delegation, fk_delegateFrom_ID, fk_delegateTo_ID, delegateFrom_oprid, delegateTo_oprid, startDate, endDate
	FROM      delegation
	ORDER BY StartDate
</cfquery --->

<cfquery name="Del" datasource="#Application.dsn#">
SELECT     delegation.id_delegation, delegation.fk_delegateFrom_ID, delegation.fk_delegateTo_ID, delegation.delegateFrom_oprid, delegation.delegateTo_oprid, 
           delegation.startDate, delegation.endDate, v_users.last_name, v_users.oprid,v_users.sctr,v_users.grp,v_users.dvsn,v_users.Inactive
FROM       delegation 
		INNER JOIN v_users ON delegation.delegateFrom_oprid = v_users.oprid
		where delegation.endDate >= '#dateformat(now(),"mm/dd/yy")#'
		<!--- ORder by Last_Name, startDate ASC --->
		Order by startDate Desc, Last_name
</cfquery>
<cfoutput query="Del">
<cfif isDefined('thisDel') and (thisDel eq id_delegation)>
	<tr bgcolor="##edf3f9">
	<td width=18 class="approve"><img src="images/ThisArrow.gif" width=18 alt=""></td>
<cfelse>
	<tr>
		<td width=18 class="border">#loopcount#. </td>
</cfif>
	<cfset id_user=#fk_DelegateFrom_ID#>
	<cfinclude template="../../model/m_user/get_users.cfm">
	<td class="border">
	<b>#gUsers.Last_name#, #gusers.First_name#</b>,  #gUsers.title#<br>
	<font class="tiny" style="color:##aaaaaa;">
	<cfif gUsers.Inactive EQ 1>
					Inactive ARA User
	<cfelse>
		#gUsers.roleName#,
		 #gUsers.sctr#, #gUsers.grp#
	</cfif></font></td>
	<!--- cfset id_user=#fk_DelegateTo_ID#>
	<cfset oprid=#DelegateTo_Oprid# --->
	<!--- cfinclude template="../../model/m_user/get_users.cfm" --->
	<cfquery name="gUsers" datasource="#Application.dsn#">
	SELECT     id_user, email, Inactive, emplID, oprid, empname, last_name, first_name, roleName, title, ID_role, ID_job, 
				appOrder, fk_delegateTo_ID,sctr,grp,dvsn,oprtn
	FROM         v_users
	where id_user=#fk_delegateTo_ID#
	</cfquery>
	<td class="border" nowrap>
	<b>#gUsers.Last_name#, #gusers.First_name#</b>,  #gUsers.title#<br>
	<cfif gUsers.Inactive EQ 1>
					Inactive ARA User
	<cfelse>
		<font class="tiny" style="color: ##AAAAAA;">#gUsers.roleName#,
		 #gUsers.sctr#, #gUsers.grp#
	</cfif></font>
	</td>
	<td class="border">#dateformat(startdate,"MM/DD/YY")#</td>
	<td class="border">#dateformat(enddate,"MM/DD/YY")#</td>
	<td align="center" nowrap class="border">
	<cfif (session.id_user eq fk_delegateFrom_ID) or  ((session.id_role EQ 2) OR (session.id_role EQ 1)) >
	<a class="embed" href="#self#?Fuseaction=app.AdminDelegate&Action=DeleteSetup&thisdel=#id_delegation#&id_delegation=#id_delegation#&thisid_user=#fk_DelegateFrom_ID#"><img src="images/SmDelete.png" alt="Delete this Delegation" border=0></a>
	<!--- &nbsp;|&nbsp;
	<a class="embed" href="#self#?Fuseaction=app.AdminDelegate&Action=Updatesetup&thisdel=#id_delegation#&id_delegation=#id_delegation#&thisid_user=#fk_DelegateFrom_ID#"><img src="images/SmUpdate.png" border=0 alt="Update this Delegation"></a> --->
	<cfelse> --
	</cfif>
	</td>
	<cfif (session.id_user eq fk_delegateFrom_ID) or  ((session.id_role EQ 2) OR (session.id_role EQ 1)) >
	<td class="border">
		<!--- Check to see if we have mapping to email --->
		<cfquery name="CheckEmail" datasource="#application.dsn#">	
			Select id_emailLog from emaillog
			where id_delegation=#id_delegation#
			order by id_emailLog
		</cfquery>
		<cfif CheckEmail.recordcount EQ 0>
			--
		<cfelse>
			<cfloop index="id_emailLog" list="#valueList(checkEmail.id_emailLog)#">
				<a href="index.cfm?fuseaction=app.AuditEmail&Menu=Admin&submenu=audit&id=#id_emailLog#"><img src="images/ActobatOnWhite.png" border=0></a>
			</cfloop>
		</cfif>
	</td>
	<cfelse>
		<td class="border" align="center">--</td>
	</cfif>


</tr>
<cfset loopcount=loopcount+1>
</cfoutput>
</table><br><br>
<script language="Javascript" type="text/JavaScript">
/* Validates complete form before submittal for next level of approval */
function validateForm() {

var errMsgHdr = "Please correct the following errors and resubmit:\n\n";
var errMsgs = "";

if (OptionSelected(document.forms.DelegateID.DelegateTo) <=0) {
		errMsgs = errMsgs + "Select person to delegate to\n";
	}
	
if (!isEmpty(errMsgs)) {
		alert(errMsgHdr + errMsgs);
		return false;
	} else {
		return true;
	}
}
</script>