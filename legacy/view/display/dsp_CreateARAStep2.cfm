<!--- cfparam name="session.loggedIn" default="No" --->
<cfinclude template="inc_tooltipContent.cfm">
<cfinclude template="../../model/m_forms/prePop.cfm">
<!--- **********************************************************  --->
<!---          Autocomplete for Sector Look up                     --->
<!--- ********************************************************** --->

<cfparam name="message" default="">
<cfparam name="revision" default=0>
<cfset submenu="">


<cfif form.id_cat EQ 10>
	<cfset form.Early_start="Yes">
<cfelse>
	<cfset form.early_start="No">
</cfif>
<!--- Error Checking to prevent user overwrite of autocomplete information, and subsequent MID error --->
<cfset errorMsg="">

	
<cfif Find('Group:',form.alion_org) EQ 0><!--- Overtyped the Alion Org Info, will cause MID error --->
	<cfset errorMsg="The Group must be selected from the autocomplete list. ">
</cfif>
<!---<cfif form.early_start EQ "yes" and isDefined('Form.OMSNumForm.OMSNumForm.OMSNum') and (find('-',form.OMSNum) EQ 0)>
	<cfset errorMsg="#errorMsg#" & "The OMS number must be selected from the autocomplete list.">
</cfif>--->
<cfif errorMsg NEQ "">
	<cflocation url="index.cfm?fuseaction=app.CreateARAStep1&Menu=ARA_Sum&errorMsg=#errorMsg#">
</cfif>
<!---     End Mid Error Check --->
	

<div id="ARASumm" style="margin:0px;">
<cfoutput>
<cfquery name="riskCat" datasource="#application.dsn#">
			SELECT *
			FROM category
			WHERE id_cat=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.id_cat#">
</cfquery>
<cfquery name="prevARA" datasource="#application.dsn#">
		SELECT TOP 1 id_ara
		FROM ara
		ORDER BY ID_ara DESC
	</cfquery>
	<cfset prevID = prevARA.id_ara>
	<cfif prevARA.recordcount eq 0>
		<cfset prevID = 0>
	</cfif>
	<cfset reference=previd + 1>
    
    

<p class="smtitle">ARA CREATION STEP 2</p>
<p class="title2">Category: #riskCat.catName#: ARA Number: #numberformat(reference, "00000000")#</p>

<!--- cfdump var="#session#" format="text" --->

<cfform name="details2" method="post" action="?fuseaction=app.insNewARA" onSubmit="return validateForm();">
<cfif isdefined("form.isEAC")>
	<cfinput type="hidden" name="isEAC" value="#form.isEAC#">
<cfelse>
	<cfinput type="hidden" name="isEAC" value="No">
</cfif>
<cfinput type="hidden" name="id_cat" value="#form.id_cat#">
<fieldset><legend><b>ARA #numberformat(reference, "00000000")# Info</b></legend>
<table cellpadding=2  width=100% cellspacing=2 class="border">
    <!---                    Status & Revision                   --->
	<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.status#</cfoutput>">
	&nbsp;&nbsp;&nbsp;
	Status:</td>
	<td class="border"> <font style="color:##222222;font-weight:bold;">Draft</font></td>

	</td>
	<td class="borderq" nowrap>
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.araRev#</cfoutput>">
	&nbsp;&nbsp;&nbsp;
	ARA Revision</td>
	<td class="border"><font style="color:##222222;font-weight:bold;">#revision#</font>
	</td>
	<cfinput type="hidden" name="revision" value="#revision#">
</tr>
<tr>
	<td class="borderq"><img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.araorg#</cfoutput>">&nbsp;&nbsp;&nbsp;&nbsp;
	ARA Org:
	</td>
	<td class="border" colspan=3><b>#form.alion_org#</b>
	<cfset group = Trim(listgetat(form.alion_org,2,':'))>
	<cfset Division="">
	<!--- br>Division is #Division#<br --->
	<cfif Form.Early_start EQ "No">
		<!---<cfinput type="hidden" name="division" value="#ContractDetails.grp#">--->
		<cfinput type="hidden" name="division" value="#replacenocase(Trim(listgetat(form.alion_org,2,':')), ", Group Name","")#">	
	<cfelse>
		<cfinput type="hidden" name="division" value="#replacenocase(Trim(listgetat(form.alion_org,2,':')), ", Group Name","")#">
	</cfif>
	<cfset sector="">
	
	</td>
</tr>
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.contractTitle#</cfoutput>">
	&nbsp;&nbsp;&nbsp;
	Title
	</td>

	<td colspan=3 class="border">
		<cfif form.id_cat NEQ 10><!--- then not early start, have existing contract data --->
			#contractdetails.proj_name#
			<cfinput type="hidden" name="title" value="#contractdetails.proj_name#">
		<cfelse>
			<cfinput type="text" size=100 maxlength=500 class="inputtext" name="title" Required="yes" Message="Early Starts must provide a draft title">
		</cfif>
	</td>
</tr>
<tr>
	<td class="borderq">
		<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.Customer#</cfoutput>">
		&nbsp;&nbsp;&nbsp;Customer
	</td>
	<td colspan=3 class="border">
	<cfif form.id_Cat NEQ 10><!--- Not Early Start --->
		<cfset cust="#contractdetails.cust_name#">
		#cust#
		</td><!--- Changed from endUser to company name --->
		<input type="hidden" name="customerName" value="#cust#">
	<cfelse>
		<cfinput type="text" name="CustomerName" size=100 maxlength=500 class="inputtext" Required="Yes" Message="Early starts must provide a customer name">
	</cfif>
	
</tr>
<cfif form.id_cat NEQ 10><!--- Not Early Start --->
<tr>
	<td class="borderq">
		<img class="question" align="left" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.earlyStartJamisNo#</cfoutput>">&nbsp;&nbsp;&nbsp;
	PROJECT ID <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;or Early Start</td>
	<td class="border">
	<cfif Form.Early_start EQ "No">
		#Form.JNumber#
		<cfinput name="JamisNo" type="hidden" value="#Form.JNumber#">
	<cfelse>
		Early Start
		<cfinput name="isEarlyStart" type="hidden" value="1">
	</cfif>
	</td>
	<td class="borderq">
	Revenue Recognition
	</td>
	<td class="border">
	<cfquery name="rd" datasource="#Application.dsn#">
		select descr
		from revenueDescr
		where id_revenue=#form.id_revenue#
	</cfquery>
		#rd.descr#
		<cfinput name="id_revenue" type="hidden" value="#form.id_revenue#">
	</td>
		<cfinput type="hidden" name="contractNo" value="#contractdetails.COSTPT_NO#">
</tr>
<cfelse><!--- is Early start --->
	<cfinput type="hidden" name="JamisNo" value="Early Start">
	<cfinput type="hidden" name="contractNo" value="Early Start">
	<cfinput type="hidden" name="ID_REVENUE" value="2">
		 
</cfif>
<cfinput type="hidden" value="" name="OMSNum">
</table>
</fieldset>


<fieldset><legend><b>ARA Creators (in same Sector)</b></legend>
<!--- Next include looks up PMs, Contracts, Controllers for same Group and Sector --->
<cfinclude template="../../model/m_ara/qry_getPMCMCon.cfm">
<cfset pm=#Get_PM()#><cfset contr=#Get_Contract()#><cfset control=#Get_Controller()#>
<table cellpadding=2  width=100% cellspacing=2 class="border" bgcolor="##efefef">
<tr bgcolor="##ffffff">
	<td valign="top" align="center" class="border" width="150">
	<cfif (session.id_job NEQ 3)><b>Program Manager</b><br>
	<b>#session.empname#</b><br><br>
	You are the assigned PM for this ARA.
    <input type="hidden" name="ID_PM" value="#session.id_user#">
    <cfelse>
    <b>Program Manager </b><br />
    <select class="inputtext" name="ID_PM" id="ID_PM">
				<option value="">-- Select from all PMs  --</option>
				<cfif isDefined('IsUser.RecordCount') and (IsUser.Recordcount GT 0) And (isUser.id_Job EQ 2)>
					<option value="#isUser.id_user#" selected>#isUser.last_name# #isUser.first_name# (Original)</option>
				</cfif>
				<cfloop query="getPM">
					<option value='#id_user#'>#last_name#, #first_name# [#approve_GRP#]</option>
				</cfloop>
			</select>
    </cfif>
	</td>


<!--- Contracts --->	
	<td valign="top" align="center" width="34%" class="border">
	<b>Contract Administrator</b><br>
		
		<cfif GetContract.Recordcount GT 0><!--- Have users in the system that are contracts --->
			<select class="inputtext" name="ID_Contract" id="ID_Contract">
				<option value="">-- Select CAs  --</option>
				<cfif isDefined('IsUser.RecordCount') and (IsUser.Recordcount GT 0) And (isUser.id_Job EQ 2)>
					<option value="#isUser.id_user#" selected>#isUser.empname#(Original)</option>
				</cfif>
				<cfloop query="GetContract">
					<option value='#id_user#'>#empname# [#approve_GRP#]</option>
				</cfloop>
			</select>
			<cfif isDefined('CMWarning') and (LEN(CurrentCM.full_name) GT 0)>
				<br><br>
				<table width=95% cellpadding=2 cellspacing=2>
				<tr>
				<td valign="top" width=12><img src="images/smyellowBang.png"></td>
				<td align="left" width=100%><font style="font-size:9px;text-align:left;">#CMwarning#</font></td>
				</tr>
				</table>
			</cfif>
		
		<cfelse>
		<table cellpadding=2><tr>
			<td valign="top">
			<img src="images/redwarning.png">
			</td><td valign="top">
			No Contract Administrators for this Sector (#sector#). 
			
			</td></tr></table>
			<INput type="hidden" name="ID_Contract" value="">
		</cfif>
	</td>
<!--- Controller --->
	<td valign="top" width=33% align="center" class="border">
		<b>Controller</b><br>
		
		<cfif GetController.recordcount GT 0>
   
			<select class="inputtext" name="ID_Controller" id="ID_Controller">
				<option value="">-- Select Controllers --</option>
                
				<cfloop query="GetController">
                <cfif SESSION.id_Job EQ 3 and SESSION.oprid EQ oprid>
					<option value="#id_user#" selected>#empname# [#approve_GRP#]</option>
				<cfelse>
					<option value='#id_user#'>#empname# [#approve_GRP#]</option>
                </cfif>
				</cfloop>
			</select>
		<cfelse>
		<table cellpadding=2><tr>
			<td valign="top"><img src="images/redwarning.png">
			</td><td valign="top">
			No Controllers for this Sector (#sector#) and Group (#Group#). 

			</td></tr></table>
			<INput type="hidden" name="ID_Controller" value="">
		</cfif>
		</td>

<!--- Ops VP --->
				
	<cfquery name="GetOpsVP" datasource="#Application.dsn#">	  
	  	Select * from v_Users
		where id_job=17 and approve_GRP like '%#trim(right(listgetat(form.alion_org,1,','),3))#%' 
		and Inactive='False' 
		order by last_name
	  </cfquery>
	
	<td valign="top" width=33% align="center" class="border">
		<b>Portfolio Leader</b><br>
		
		<cfif GetOpsVP.recordcount GT 0>
   
			<select class="inputtext" name="ID_OpsVP" id="ID_OpsVP">
				<option value="">-- Select Portfolio Leader --</option>
                
				<cfloop query="GetOpsVP">
                <cfif SESSION.id_Job EQ 17 and SESSION.oprid EQ oprid>
					<option value="#id_user#" selected>#empname# &nbsp;&nbsp;[#approve_GRP#]</option>
				<cfelse>
					<option value='#id_user#'>#empname# &nbsp;&nbsp;[#approve_GRP#]</option>
                </cfif>
				</cfloop>
			</select>
		<cfelse>
		<table cellpadding=2><tr>
			<td valign="top"><img src="images/redwarning.png">
			</td><td valign="top">
			No Portfolio Leader for this Sector (#sector#) and Group (#Group#). 

			</td></tr></table>
			<INput type="hidden" name="ID_OpsVP" value="">
		</cfif>
	</td>
</tr>
	
<tr  bgcolor="##ffffff">
	<td colspan=5 align="center" class="border">
		<!--- input name="button" class="button" type="submit" value="Create Early Start ARA" --->
		<cfif (GetContract.Recordcount GT 0) AND (GetController.recordcount GT 0)>
			<cfinput type="submit" class="button" value="Create ARA" name="Create ARA">
		<cfelse>
			<img src="images/redwarning.png"> Contract Admins or Controllers need to be setup to proceed with this ARA.
		</cfif>
	</td>
</tr>
</table>
</fieldset>
</cfform>


<cfif form.id_cat NEQ 10><!--- If not early start, there is existing Jamis info --->

<fieldset><legend><b>Warehouse: Contract Information</b></legend>

<table cellpadding=2 width=100% cellspacing=2 class="border">
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.sector#</cfoutput>">
	Contract Sector</td>
	<td class="border">
	<cfif isDefined('ContractDetails.Program_Manager_Sector') and (ContractDetails.Program_Manager_Sector NEQ "")>
	#ContractDetails.Program_Manager_Sector#
	<cfelse>
	Unknown
	</cfif>	
	
	</td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.group#</cfoutput>">
	Contract Group
	</td>
	<td class="border">
	<cfif isDefined('contractDetails.PROGRAM_MANAGER_GRP') and (contractDetails.PROGRAM_MANAGER_GRP NEQ "")>
	#ContractDetails.PROGRAM_MANAGER_GRP#
	<cfelse>
	Unknown
	</cfif>	
	</td>
</tr>
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.programMgr#</cfoutput>">
	Program Manager
	</td>
	<td class="border">
	<cfif isDefined('contractDetails.Program_Manager_Name') and (contractDetails.Program_Manager_Name NEQ "")>
	#contractDetails.Program_Manager_Name#
	<cfelse>
	Unknown
	</cfif>	
	</td>
	<td class="borderq">
	
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.contractMgr#</cfoutput>">
	Contract Administrator</td>
	<td class="border">
	<cfif isDefined('contractDetails.Contract_Admin_Name') and (contractDetails.Contract_Admin_Name NEQ "")>
	#contractDetails.Contract_Admin_Name#
	<cfelse>
	Unknown
	</cfif>	
	</td></tr>
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.Controller#</cfoutput>">
	Controller</td>
	<td class="border">
	<cfif isDefined('contractDetails.Project_Controller_Name') and (contractDetails.Project_Controller_Name NEQ "")>
	#contractDetails.Project_Controller_Name#
	<cfelse>
	Unknown
	</cfif>	
	</td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.sectorMgr#</cfoutput>">
	Division Manager</td>
	<td class="border">
	<cfif isDefined('contractDetails.Division_Manager_name') and (contractDetails.Division_Manager_Name NEQ "")>
	#contractDetails.Division_Manager_Name#
	<cfelse>
	Unknown
	</cfif>	
	</td>
</tr>

<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.groupMgr#</cfoutput>">
	Group Manager</td>
	<td class="border">
	<cfif isDefined('contractDetails.Group_Manager_Name') and (contractDetails.Group_Manager_Name NEQ "")>
	#contractDetails.Group_Manager_Name#
	<cfelse>
	Unknown
	</cfif>	
	</td>
	<td class="borderq" colspan=2>
	&nbsp;&nbsp;
	</td>
</tr>

</table>
</fieldset>
</cfif>
</cfoutput>
<!--- form validation to see if CM and Controllers are assigned --->
<script language="javascript">
function validateForm() {
var errMsgHdr = "Please correct the following errors and resubmit:\n\n";
var errMsgs = "";
var errMsgs = "";

if (isWhitespace(document.getElementById("ID_Contract").value)) {
		errMsgs = errMsgs + "You must select a Contract Administrator\n";
	} 
if (isWhitespace(document.getElementById("ID_Controller").value)) {
		errMsgs = errMsgs + "You must select a Controller\n";
	} 
if (isWhitespace(document.getElementById("ID_OpsVP").value)) {
		errMsgs = errMsgs + "You must select a Portfolio Leader \n";
	} 
	

if (!isEmpty(errMsgs)) {
		alert(errMsgHdr + errMsgs);
		return false;
	} else {
		return true;
	}
	return false;
}
</script>
<!--- Tooltip Initialization ---->
<script>
// initialize tooltip
$("#ARASumm img[title]").tooltip({

	// place tooltip on the right edge
	position: "center right",

	// a little tweaking of the position
	offset: [17, 10],

	// custom opacity setting
	opacity: 1.0
}).dynamic({ bottom: { direction: 'down', bounce: true } });
</script>