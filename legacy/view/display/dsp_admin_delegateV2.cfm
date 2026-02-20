<cfset pagetitle="ARA Delegations">
<cfset menu="Admin">
<cfset submenu="Delegations">
<cfparam name="buttontext" default="submit">
<cfparam name="action" default="InsertSetup">
<cfparam name="title" default="View and Setup Delegations">
<cfparam name="fk_delegateFrom_ID" default="">
<cfparam name="fk_delegateTo_ID" default="">
<cfparam name="startDate" default="">
<cfparam name="EndDate" default="">
<!--- temp, for now default to Corporate User --->
<cfset session.id_role=1>
<cfinclude template="../../model/m_user/qry_delegateList.cfm"><!--- gets delegator and Delegate_To lists --->
<cfinclude template="../../model/m_user/act_delegate.cfm"><!--- Contains insert, update, and delete code --->

<!--- cfdump var='#session#' format="text" --->
<table cellpadding=0 cellspacing=0 width=95%>
<tr>
	<td>
<p class="smtitle">Admin Delegation</p>
<p class="title"><cfoutput>#pagetitle#</cfoutput></p>
</td>
<td valign="top" width=25 align="right">
<img src="images/HelpIcon.gif" border=0 align="left" >&nbsp;<a class="embed" href="index.cfm?fuseaction=app.help&topic=admin_delegation">Help</a>
</td></tr></table>

<cfinclude template="dsp_messages.cfm">

<cfform name="Delegate" id="DelegateID" action="index.cfm?fuseaction=app.AdminDelegate" method="Post">
<cfinput type="Hidden" name="Action" value="#Action#">


	<!--- ***********  Delegator: Delegate from   *************** --->
	
	
	
	<Table cellpadding=2 cellspacing=2 class="border">
	<tr>
	<td class="border">
	Delegate From: &nbsp;&nbsp;
	</td>
	<td class="border" colspan=3>
		<cfif #session.id_role# EQ 1><!--- This is an admin, can delegate for people  --->
			<cfif NOT isDefined('id_delegation')><!--- starting new delegation --->
			<cfset DelegateFrom_list=#getlist('delegateFrom')#>
			<cfif delegateFrom.Recordcount EQ 1><!--- have already selected delegate_From --->
					<cfoutput><b>#delegateFrom.empname#</b> ORG: [<b>#DelegateFrom.sctr#, #DelegateFrom.grp#, #DelegateFrom.oprtn#</b>]  ROLE/JOB: [<b>#delegatefrom.Rolename#,  #DelegateFrom.title#</b>]
					<input type="hidden" name="fk_delegateFrom_ID" value="#delegateFrom.id_user#">
					</cfoutput>
			<cfelse>
				<!--- Do not display Delegate_Tos until have selections --->
				<script>
				function reloadPage(selBox)
				{
					window.location.href='index.cfm?fuseaction=app.AdminDelegate&Menu=Admin&submenu=Delegations&thisid_user=' + selBox.value;
				}
				</script>
				<select class="inputtext" name="fk_delegateFrom_ID" id="fk_delegateFrom_ID" onChange="JavaScript:reloadPage(this);">
				  
				
				<cfif #fk_delegateFrom_ID# EQ ""><option value="">-- List of ARA Users ---</option></cfif>
				<cfoutput query="delegateFrom"><!--- fom function getlist --->
					<option class="inputtext" value="#id_user#" 
					<cfif #fk_delegateFrom_ID# EQ #id_user#>Selected</cfif>>#empname# &nbsp;&nbsp;-- &nbsp;&nbsp; 
					ORG [#sctr#, #grp#,#oprtn#, #dvsn#], &nbsp;&nbsp;-- &nbsp;&nbsp; ROLE/JOB [#roleName#, #title#]</option>
				</cfoutput>
				</select>
			</cfif>
		<cfelse><!--- Updating existing delegation --->
			
			<cfinclude template="../../model/m_user/qry_getDelegation.cfm">
			<cfoutput>#del.delegator_empname#  
			<input type="hidden" name="id_delegation" value="#id_delegation#">
			</cfoutput>
		</cfif>
	 
	<cfelse><!--- Otherwise this is not an admin, and are filling out delegation for themselves --->
		
		<cfoutput>
		#session.empname#
		<cfif (isDefined('id_delegation')) AND (id_delegation NEQ "")>
			<input type="hidden" name="id_delegation" value="#id_delegation#">
		<cfelse>
			<input type="hidden" name="fk_delegateFrom_ID" value="#session.id_user#">
		</cfif>
		</cfoutput>
	</cfif>
	</td></tr>
	
	
<!--- *************         Delegate_To          *************** --->



<cfif isdefined('url.thisid_user') OR (session.id_role NEQ 1) or (isDefined('id_delegation'))>
	<tr><td class="border">
	Delegate To: &nbsp;&nbsp;
	<cfif isDefined('thisuser')>
	<!--- cfdump var="#thisuser#" format="text" --->
	</cfif>
	</td>
	<td colspan=3 class="border">
	<cfif Action NEQ 'DeleteRecord'>
	<cfset DelegateTo_list=#getlist('DelegateTo')#>
	<!--- cfdump var="#DelegateTo#" format="text" --->
	<cfif #DelegateTo.Recordcount# GT 5>
		<cfset show=5>
	<cfelse>
		<cfset show=#val(DelegateTo.Recordcount + 1)#>
	</cfif>
	
	<cfselect size="3" class="inputtext" required="yes" Message="Select someone to delegate to" name="fk_delegateTo_ID">
		<cfif #fk_delegateTo_ID# EQ ""><option value="">-- <cfoutput>#selecttxt#</cfoutput> ---</option></cfif>
			<cfoutput query="DelegateTo">
			<option class="inputtext" value="#id_user#" <cfif #fk_delegateTo_ID# EQ #id_user#>Selected</cfif>>#empname#
			&nbsp;&nbsp;- &nbsp;&nbsp;ORG [#sctr#, #grp#, #oprtn#, #dvsn#] &nbsp;&nbsp;- &nbsp;&nbsp;ROLE/JOB [#RoleName#, #Title#]</option>
		</cfoutput>
		
		</cfselect>
	<cfelse>
		<cfquery name="To_Name" datasource="#application.dsn#">
		Select empname from users where 
		oprid='#delegateTo_oprid#'
		</cfquery>
		<cfoutput>#To_Name.empname#</cfoutput>
	</cfif>
	</td>
</tr>
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
<input class="button" type="Submit" Value="#buttontext#">
<cfif #Find('Insert',Action)#>
	&nbsp;&nbsp;&nbsp;<input class="button" type="button" value="Reset" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.AdminDelegate&Menu=Admin&submenu=Delegations';">
<cfelseif #Find('Update',Action)#>
	&nbsp;&nbsp;&nbsp;<input class="button" type="button" value="Add New" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.AdminDelegate&Menu=Admin&submenu=Delegations';">
<cfelseif #Find('Delete', Action)#>
&nbsp;&nbsp;&nbsp;<input class="button" type="button" value="Cancel" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.AdminDelegate&Menu=Admin&submenu=Delegations';">
</cfif>
</td></tr>
</cfoutput>
</cfif>
	
</table>
</cfform>

<p class="subtitle">Delegations In Effect (shown only to Administrators? or view only to everyone)</p>


<cfset id_delegation="">
<table width=100% cellpadding=2 cellspacing=2 class="border">
<tr>
	<td width=18> </td>
	<td  class="grad">From</td>
	<td  class="grad">To</td>
	<td  class="grad">Start</td>
	<td class="grad">End</td>
	<td  class="grad">Delete/Update</td>
</tr>
<cfset loopcount=1>
<!--- cfinclude template="../../model/m_user/qry_getDelegation.cfm">
<cfoutput query="Del" --->
<cfquery name="Del" datasource="#Application.DSN#">
	SELECT * FROM Delegation
	ORDER BY StartDate
</cfquery>
<cfoutput query="Del">
<cfif isDefined('thisDel') and (thisDel eq id_delegation)>
	<tr bgcolor="##edf3f9">
	<td width=18 class="approve"><img src="images/ThisArrow.gif" width=18 alt=""></td>
<cfelse>
	<tr>
		<td width=18 class="border">#loopcount#.</td>
</cfif>
	<cfset id_user=#fk_DelegateFrom_ID#>
	<cfinclude template="../../model/m_user/get_users.cfm">
	<td class="border">#gUsers.empname#<br><font class="tiny">#gUsers.roleName#, #gUsers.title#, #gUsers.sctr#, #gUsers.grp#,#gUsers.oprtn#, #gUsers.dvsn#</font></td>
	<cfset id_user=#fk_DelegateTo_ID#>
	<cfinclude template="../../model/m_user/get_users.cfm">
	<td class="border" nowrap>#gUsers.empname#<br /><font class="tiny">#gUsers.roleName#, #gUsers.title#, #gUsers.sctr#, #gUsers.grp#,#gUsers.oprtn# #gUsers.dvsn#</font></td>
	<td class="border">#dateformat(startdate,"MM/DD/YY")#</td>
	<td class="border">#dateformat(enddate,"MM/DD/YY")#</td>
	<td align="center" nowrap class="border">
	<cfif (session.id_user eq fk_delegateFrom_ID) or (session.id_role EQ 1)>
	<a class="embed" href="#self#?Fuseaction=app.AdminDelegate&Action=DeleteSetup&thisdel=#id_delegation#&id_delegation=#id_delegation#&thisid_user=#fk_DelegateFrom_ID#"><img src="images/SmDelete.png" alt="Delete this Delegation" border=0></a>
	&nbsp;|&nbsp;
	<a class="embed" href="#self#?Fuseaction=app.AdminDelegate&Action=Updatesetup&thisdel=#id_delegation#&id_delegation=#id_delegation#&thisid_user=#fk_DelegateFrom_ID#"><img src="images/SmUpdate.png" border=0 alt="Update this Delegation"></a>
	<cfelse> -- 
	</cfif>
</td>

</tr>
<cfset loopcount=loopcount+1>
</cfoutput>
</table><br><br>