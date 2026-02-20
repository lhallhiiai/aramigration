<!---  *********************************************************************  --->
<!---                                                                         --->
<!---            ARA Controller Information Tab                               --->
<!---                                                                         --->
<!---  *********************************************************************  --->
<cfset whichtab="controller">
<cfset pagetitle="ARA Controller Information">
<cfparam name="auth_value" default="">
<cfparam name="prior_value" default="">
<cfparam name="Total_value" default="">
<cfif isDefined('url.aid')>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<!--- cfelse>
	<cfset id_ara=8 --->
</cfif>
<cfinclude template="../../model/m_ara/qry_controller.cfm">
<cfif GetController.RecordCount EQ 0>
	<cfset action="Insert">
<cfelse>
	<cfset action="Update">
</cfif>
<cfswitch expression="#Action#">
<cfcase value="Insert">
	<cfset buttonText="Save">
	<cfset Faction="?fuseaction=app.Con_Insert&AID=#url.aid#">
</cfcase>

<cfcase value="Update">
	<cfset buttontext="Update">
	<cfset Faction="?fuseaction=app.Con_Update&AID=#url.aid#">
	<!--- check to see if required documents have been uploaded. If not do not allow submit --->
	
</cfcase>

</cfswitch>
<cfparam name="FormorView" default="form">
<cfset whichtab="Controller">
<!--- +++++++++++ Pulls ARA, user, groups, sector, category, status ++++++++++ --->
<cfinclude template="../../model/m_ara/qry_ara.cfm">
<script language="javascript" type="text/javascript">
	
function sumTotal(fieldOne,fieldTwo,totalField) {
var a = (document.getElementById(fieldOne).value != '') ? eval(document.getElementById(fieldOne).value) : 0;
var b = (document.getElementById(fieldTwo).value != '') ? eval(document.getElementById(fieldTwo).value) : 0;

document.getElementById(totalField).value = a + b;
}

</script>

<script type="text/javascript">
    $(document).ready(function() {
        $("#hidden_link").fancybox().trigger('click');
		alert ('working?');
    });
</script>
<cfoutput>
<!-- 1  --><table width=100% cellpadding=0 cellspacing=0 border=0>
		<tr>
		<td width=60% valign="top">
		<p class="smtitle">
		ARA #ID_ARA# - #reference# Controller</p>
		<p class="aratitle">Title: #title#</p>
		</td>
		<td valign="top" align="right">
		<a class="embed" href="#self#?fuseaction=app.ARA_Controller">Controller Form</a>&nbsp;&nbsp;|&nbsp;&nbsp;
		<a class="embed" href="#self#?fuseaction=app.ARA_Controller&FormorView=View">Controller View</a>&nbsp;&nbsp;|&nbsp;&nbsp;
		<a class="embed" href="#self#?fuseaction=app.ARA_cfdocument&AID=#AID#">Print ARA <img src="images/PrinterIcon.gif" border=0></a>
<!-- /1  --></td></tr></table>
</cfoutput>
<a href="fancybox.cfm" id="hidden_link" style="display:none;"></a>
<!--- ARA Summary Info at top of page ---><cfinclude template="dsp_ARA_top_summary.cfm">

<fieldset><legend><b>ARA Backup Detail</b></legend>
<!--- ARA Navigational Tabs ---><cfinclude template="dsp_tabset.cfm">
			
<cfinclude template="dsp_messages.cfm">


<!--- If in controller, or rejected and this person is the contract manager, they will see form. Otherwise view only --->
<cfif (FormorView EQ "Form")  AND (ListFind('4,5,8,9',id_status)) and (ID_controller EQ session.id_user)>
<cfoutput>
<cfform name="Controller"  method="Post" preservedata="True" enctype="multipart/form-data" action="#Faction#">
<cfinput type="hidden" name="id_controller" value="#id_controller#"> 
<table width=100% cellpadding=2 cellspacing=2 class="outerborder">
<tr>
	<td class="border" align="right">
	Interest impact to HII of this request is&nbsp;&nbsp;
	</td>
	<td class="border"> $ <cfinput class="inputtext" type="text" name="InterestImpact" REQUIRED="Yes" VALIDATE="integer" MESSAGE="Enter whole dollar amounts" size=10 value="#InterestImpact#">
	</td>
	<td colspan=2 class="border">through receipt of payment</td>
</tr>

<tr>
	<td class="border" align="right">
	Expected burn rate is&nbsp;&nbsp;
	</td>
	<td class="border"> $ <cfinput class="inputtext" type="text" name="BurnRate" REQUIRED="Yes" VALIDATE="integer" MESSAGE="Enter whole dollar amounts" size=10 value="#burnRate#" >
	</td>
	<td colspan=2 class="border">per two week period</td>
</tr>

<tr>
	<td>&nbsp;</td>
	<td class="border"align="center"><font class="smtitle">COST</font></td>
	<td class="border" align="center"><font class="smtitle">FEE</font></td>
	<td class="border" align="center"><font class="smtitle">VALUE</font> [calculated]</td>
</tr>

<tr>
	<td class="border" align="right">Cost and Fee authorized by this request&nbsp;&nbsp;</td>
	<td class="border">
	<cfinput class="inputtext" name="Auth_Cost" id="Auth_Cost" size=15 onChange="javascript: sumTotal('Auth_Cost','Auth_Fee','Auth_Value'); sumTotal('Auth_Cost','Prior_Cost','Total_Cost'); sumTotal('Auth_Value','Prior_Value','Total_Value');" value="#cost#" ></td>

	<td class="border"><cfinput class="inputtext" name="Auth_Fee" value="#fee#" id="Auth_Fee" size=15 onChange="javascript: sumTotal('Auth_Cost','Auth_Fee','Auth_Value'); sumTotal('Auth_Fee','Prior_Fee','Total_Fee'); sumTotal('Auth_Value','Prior_Value','Total_Value');"></td>

	<td class="border">
	<cfinput  class="autopop" name="Auth_Value" id="Auth_Value" disabled value="#Auth_value#" size=15></td>
</tr>

<tr>
	<td class="border" align="right">+ Amounts authorized on prior revisions&nbsp;&nbsp;</td>
	<td class="border">
	<cfinput class="inputtext" name="Prior_Cost" value="#PriorCost#" id="Prior_Cost" size=15 onChange="javascript: sumTotal('Prior_Cost','Prior_Fee','Prior_Value'); sumTotal('Auth_Cost','Prior_Cost','Total_Cost'); sumTotal('Auth_Value','Prior_Value','Total_Value');"></td>
	<td class="border"><cfinput class="inputtext" value="#PriorFee#" name="Prior_Fee" id="Prior_Fee" size=15 onChange="javascript: sumTotal('Prior_Cost','Prior_Fee','Prior_Value'); sumTotal('Auth_Fee','Prior_Fee','Total_Fee'); sumTotal('Auth_Value','Prior_Value','Total_Value');">
	</td>
	<td class="border">
	<cfinput class="autopop" name="Prior_Value" id="Prior_Value" disabled size=15 value="#Prior_Value#"></td>
</tr>

<tr>
	<td class="border" align="right">= Total authorized to date [calculated]&nbsp;&nbsp;</td>
	<td class="border">
	<cfinput class="autopop" disabled REQUIRED="Yes" VALIDATE="integer" MESSAGE="Total Cost authorized to date is required" name="Total_Cost" id="Total_Cost" value="#total_cost#" size=15></td>
	<td class="border">
	<cfinput class="autopop" disabled REQUIRED="Yes" VALIDATE="integer" MESSAGE="Total Fee authorized to date is required" name="Total_Fee" id="Total_Fee" value="#total_fee#" size=15></td>
	<td class="border">
	<cfinput  class="autopop" name="Total_Value" id="Total_Value" disabled size=15 value="#total_value#"></td>
</tr>

<tr>
	<td class="border" align="right">Incurred cost and fee not billable&nbsp;&nbsp;</td>
	<td class="border">
	<cfinput class="inputtext" name="Incurred_Cost" value="#icCost#" id="Incurred_Cost" onChange="javascript: sumTotal('Incurred_Cost','Incurred_Fee','Incurred_Value');" size=15></td>
	<td class="border">
	<cfinput class="inputtext" name="Incurred_Fee" value="#icFee#" id="Incurred_Fee" onChange="javascript: sumTotal('Incurred_Cost','Incurred_Fee','Incurred_Value');" size=15></td>
	<td class="border">
	<cfinput class="autopop" name="Incurred_Value" id="Incurred_Value" disabled value="#incurred_Value#" size=15></td>
</tr>

<tr>
	<td class="border" align="right">Recognize revenue on this ARA</td>
	<td colspan=3 class="border">
	<cfif Revenue EQ "Yes">
		<cfinput type="radio"  REQUIRED="Yes" VALIDATE="integer" MESSAGE="Recognize revenue on this ARA" name="Revenue" value="yes" checked="yes">&nbsp;Yes&nbsp;
		<cfinput type="radio"  name="Revenue" value="no">&nbsp;No&nbsp;</td>
	<cfelse>
		<cfinput type="radio"  REQUIRED="Yes" VALIDATE="integer" MESSAGE="Recognize revenue on this ARA" name="Revenue" value="yes">&nbsp;Yes&nbsp;
		<cfinput type="radio"  name="Revenue" value="no" checked="yes">&nbsp;No&nbsp;</td>
	</cfif>
	
	
	
</tr>
<!--- Mel commented out next row-- believe superceded by appLog -- not field in appCon --->
<!--- tr>
	<td class="border" align="right">Controller Certification</td>
	<td colspan=3 class="border">
	<cfinput type="dateField" name="ConDate" mask="MM/DD/YYYY" class="inputtext" value="#ConDate#">
	</td>
	
</tr --->
<tr>
	<td class="border">&nbsp;</td>
	<td class="border" colspan=3>
		<cfoutput>
		<input class="button" type="submit" value="#buttontext#">
		<cfif haveCount LT ListLen(NeedList) OR (NOT isDefined('id_ara_con'))>
			<input disabled type="submit" value="Not Ready to submit for approval" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.con_submit&AID=#AID#';">
	<table cellpadding="0" cellspacing="0" border="0">
		<tr><td><img src="images/warning.png"></td><td>Controller information and supporting documents (#ListLen(NeedList)#) are required prior to submission for approval.</td></tr></table>
        <cfelse>
       
		<input class="button" type="button" value="Submit For Approval" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.con_submit&AID=#AID#&revision=#revision#';">
		</cfif>
	

		</cfoutput>
		
	</td></tr>
</table>

</cfform>
</cfoutput>
<cfelse><!--- Form or view is View only --->
	<cfinclude template="dsp_ARA_Controller_View.cfm">
</cfif>

		