<script type="text/javascript">
$("document").ready(function() {
	$("#delegator").hide("normal");
	$("#puke").hide("normal");
	if($('#delegator').val() != "")
	{
			$("#delegator").show("fast");
			$("#puke").show("fast");
	}
	else{
		$("#delegator").hide("fast");
		$("#puke").hide("fast");
	}

});
</script>

<script type="text/javascript">
$(document).ready(function(){ 
	$('#fk_delegateFrom_ID').change(function()
		{
			$("#delegator").show("fast");

			$.get('index.cfm?fuseaction=app.getUserInfo&oprid=' + $(this).val(), function(data) 
			{
				var tmp 	= $.trim(data).split(";");
				var empName 	= $.trim(tmp[0].split(":")[1]) + " " + $.trim(tmp[1].split(":")[1]);
				var sector		= $.trim(tmp[2].split(":")[1]);
				var role		= $.trim(tmp[3].split(":")[1]);
				var title 		= $.trim(tmp[4].split(":")[1]);
				var group 		= $.trim(tmp[5].split(":")[1]);

				$("#delFullName").html(empName);
				$("#group").html(group);
				$("#delSector").html(sector);
				$("#delRole").html(role);
				$("#delTitle").val(title);
				
//				$("#delegator").show("fast");
  				
			});

		});
		});
</script>

<cfinclude template="dsp_Messages.cfm">
<cfparam name="Action" default="InsertSetup">
<cfparam name="fk_delegateFrom_ID" default="">
<cfinclude template="../../model/m_user/qry_delegate.cfm">
<cfif #session.id_role# EQ 1>
	<p class="smtitle">ADMINISTRATOR</p>
	<p class="title">Setup ARA Delegations</p>
<cfelse>
	<p class="smtitle">DELEGATE</p>
	<p class="title">Delegate You Signature Authority</p>
</cfif>
<cfoutput>
<!--- cfdump var="#session#" format="text" --->

<form name="Delegate" id="DelegateID" method="Post" onSubmit="return validateForm();" Action="index.cfm?fuseaction=app.AdminDelegate&Menu=Delegate">
<!--- input type="hidden" name="fk_delegateFrom_ID" value="#session.userid#" --->
<!--- Used this for test: input type="hidden" name="fk_delegateFrom_ID" value="ahuang" --->
<input type="hidden" name="Action" value="#Action#">
</cfoutput>
<Table cellpadding=2 cellspacing=2 class="border">

	
	
	<!--- *************************** Delegator  *************** --->
<cfif #session.id_role# NEQ 1><!--- If not the admin, then delegating for yourself --->

<cfelse>
	<tr>
	<td class="border">
	Delegate From: &nbsp;&nbsp;
	</td>
	<td class="border" colspan=3>
		<!--- remove people from pull down who already have delegations in effect --->
		<cfquery name="CurDel" datasource="#application.dsn#">
			Select fk_delegateFrom_ID from delegation
		</cfquery>
		<cfset tor_list=#QuotedValuelist(CurDel.fk_delegateFrom_ID)#>
		tor_list is <cfoutput>#tor_list#, #fk_delegateFrom_ID#</cfoutput><br>
		<select class="inputtext" name="fk_delegateFrom_ID" id="fk_delegateFrom_ID">
		  <cfquery name="getUser" datasource="#application.dsn#">
			SELECT  users.id_user, users.emplID, users.oprid, users.ID_group, users.ID_sector, 
			        users.ID_role, users.ID_job, users.empname, users.first_name, 
                    users.last_name, users.Status, users.Inactive, groups.groupName, 
					sector.sectorName, jobTitle.title AS title, jobTitle.description, 
					jobTitle.appOrder, role.roleName, role.roleShort, role.roleDesc
			FROM     users INNER JOIN
                      role ON users.ID_role = role.ID_role INNER JOIN
                      groups ON users.ID_group = groups.ID_group INNER JOIN
                      sector ON users.ID_sector = sector.ID_sector INNER JOIN
                      jobTitle ON users.ID_job = jobTitle.id_job
			where oprid <> '#session.oprid#'
			<cfif Find('Insert',Action) AND (ListLen(tor_List) GT 0)>
			and oprid NOT IN (#QuotedValueList(curdel.fk_delegateFrom_ID)#)
			</cfif>
			Order by Last_name	
		</cfquery>
		
		<cfif #fk_delegateFrom_ID# EQ ""><option value="">-- Select Delegator --</option></cfif>
		<cfoutput query="getuser">
		<option class="inputtext" value="#oprid#" <cfif #fk_delegateFrom_ID# EQ #oprid#>Selected</cfif>>#empname#</option>
		</cfoutput>
		</select>
	</td>
	<td class="border">
	<div id="delegator">
	<cfoutput>
	<b><span id="delFullName">#GetUser.empname#</span></b><br><br>
	Sector: <span id="delSector">#getUser.sectorName#</span><br />
	Group: <span id="delSector">#getUser.GroupName#</span><br />
	ARA Role: <span id="delRole">#getUser.RoleName#</span><br />
	Job Title: <span id="delTitle">#getUser.title#</span>
	</cfoutput>
	</div>
	</td>
	</tr>
</cfif>

<!--- *************************** Delegate_To  **********************  --->
	<div id="puke">
	<tr><td class="border">
	Delegate To: &nbsp;&nbsp;</td>
	<td colspan=3>

	<select class="inputtext" name="fk_Delegate_ToID">
		  <cfquery name="getUser" datasource="#application.dsn#">
			SELECT * FROM users
			where oprid <> '#session.id_user#'
			Order by EmpName
			
		</cfquery>
		
		<cfif #fk_Delegate_ToID# EQ ""><option value="">-- Select Delegate_To --</option></cfif>
		<cfoutput query="getuser">
		<option class="inputtext" value="#oprid#" <cfif #fk_Delegate_ToID# EQ #oprid#>Selected</cfif>>#empname# </option>
		</cfoutput>
		
		</select>
		
	</td>
</tr>

	<cfoutput>
<tr>
	<td valign="top" class="border">
	Starting Date
	</td>
	<td class="border">
		<input class="date" style="background-color:##eeeeee;font-family:verdana,arial;font-size:11px;" type="text" name="startDate" value="#startdate#" size=10>
	</td>
	<td valign="top" class="border">
	Ending Date</td>
	<td valign="top" class="border">
		<input class="date"  style="background-color:##eeeeee;font-family:verdana,arial;font-size:11px;" type="text" name="endDate" value="#endDate#" size=10>
	</td>
	</cfoutput>

			
</td>
</tr>
</div>
	
	
<tr>
<cfoutput>
<td align="center" colspan=4 valign="middle" class="border">
		<input type="submit" value="#buttontext#">
		<cfif #find('Update',Action)#>
		<input  class="button" type="button" value="Delete" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.admindelegate&Action=DeleteRecord&fk_delegateFrom_ID=#fk_delegateFrom_ID#';">
		</cfif>
</td></tr>
</cfoutput>
</table>
</form>

<script language="Javascript" type="text/JavaScript">
function validateForm() {
var errorMsgHdr = "Please correct the following errors and resubmit:\n\n";
var errorMsgs = "";
	
	if (isWhitespace(document.forms.DelegateID.startDate.value)) {
		errorMsgs = errorMsgs + "- Start date is required.\n";
	}
	if (!ForceDate(document.forms.DelegateID.startDate)) {
		errorMsgs = errorMsgs + "- Start date  needs to be in the form of mm/dd/yy or mm/dd/yyyy.\n";
	}
	if (isWhitespace(document.forms.DelegateID.endDate.value)) {
		errorMsgs = errorMsgs + "- End Date is required.\n";
	}
	if (!ForceDate(document.forms.DelegateID.endDate)) {
		errorMsgs = errorMsgs + "- End Date needs to be in the form of mm/dd/yy or mm/dd/yyyy.\n";
	}
	
/* Check to make sure delegator selected */
	if (OptionSelected(document.forms.DelegateID.fk_Delegate_ToID) < 0) {
		errorMsgs = errorMsgs + "- Please select Delegate_To from the user list\n";
	}
	
	if (!isEmpty(errorMsgs)) {
		alert(errorMsgHdr + errorMsgs);
		return false;
	} else {
		return true;
	}
}
</script>