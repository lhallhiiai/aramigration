<!---  *********************************************************************  --->
<!---                                                                         --->
<!---            ARA Controller Information Tab Version 2                     --->
<!---            Merges CLINs and Controller Tabs 2/22/2012                   --->
<!---  *********************************************************************  --->


<cfparam name="thisJob" default="3">
<cfset whichtab="controllerV2">
<cfset pagetitle="ARA Controller Information">
<cfparam name="auth_value" default="">
<cfparam name="prior_value" default="">
<cfparam name="Total_value" default="">
<cfparam name="CostFunding" default="">
<cfparam name="FeeFunding" default="">
<cfparam name="ARATotal" default="">
<cfparam name="Reject" default="">
<cfparam name="ThisID" default="">
<cfparam name="FormorView" default="Form">
<cfparam name="UseCheck" default="yes">


<cfif isDefined('ara_id')>
	<cfset id_ara=ara_id>
<cfelseif isDefined('url.aid')>
	<cfset id_ara=#decrypt(url.aid,request.encryptKey,request.encryptType,'hex')#>
</cfif>
<!--- Controller top section of form --->
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




<!--- +++++++++++ Pulls ARA, user, groups, sector, category, status ++++++++++ --->
<cfinclude template="../../model/m_ara/qry_ara.cfm">
<cfif #session.id_user# EQ #getARA.id_controller#>
	<cfparam name="formorview" default="Form">
<cfelse>
	<cfparam name="formorview" default="View">
</cfif>

<!--- +++++++++++++++++++++ REJECT FANCY BOX +++++++++++++++++++++  --->

<!--- If reject button is clicked, will bring up Reject Button in front of page --->
<cfif isDefined('Reject') and (Reject NEQ "")><!--- Show Fancy Box containing reject form --->
	<script type="text/javascript">
	    $(document).ready(function() {
	        $("#hidden_link").fancybox().trigger('click');
	    });
	</script>
</cfif>
<!--- a href="index.cfm?fuseaction=app.AuditTrail&Menu=Admin&submenu=audit&ara_ID=127" id="hidden_link" style="display:none;"></a --->
<cfoutput>
<a href="index.cfm?fuseaction=app.RejectForm&id_status=#id_status#&thiscycle=#val(revision+1)#&divshow=View&id_ara=#id_ara#&returnTo=Controller" id="hidden_link" style="display:none;"></a>
</cfoutput>
<!--- +++++++++++++++++++++ END OF REJECT FANCY BOX +++++++++++++++++++++  --->

<!--- +++++++++++++++++++++ UPLOAD DOC FANCY BOX +++++++++++++++++++++  --->

<!--- If upload button is clicked, will bring up Upload in front of page --->
<cfif isDefined('Upload') and (Upload NEQ "")>
	<script type="text/javascript">
	    $(document).ready(function() {
	        $("#hidden_link2").fancybox().trigger('click');
	    });
	</script>
</cfif>
<cfoutput>
<a href="index.cfm?fuseaction=app.ARA_Docs_include&AID=#AID#&id_cat=#id_cat#&id_status=#id_status#&who=CON&returnTo=Controller&id_controller=#session.id_user#" id="hidden_link2" style="display:none;"></a>
</cfoutput>
<!--- +++++++++++++++++++++ END OF UPLOAD DOC FANCY BOX +++++++++++++++++++++  --->



<script language="javascript" type="text/javascript">

function sumTotal(fieldOne,fieldTwo,totalField) {

var a = (document.getElementById(fieldOne).value != '') ? eval(document.getElementById(fieldOne).value) : 0;
var b = (document.getElementById(fieldTwo).value != '') ? eval(document.getElementById(fieldTwo).value) : 0;

document.getElementById(totalField).value = a + b;
}

</script>
<cfinclude template="../../model/m_ara/qry_CLINcnt.cfm">
<!--- If no CLINS, and if not Early Start don't show controller top summary --->
<cfif (ARAClinCnt EQ 0) AND (id_cat NEQ 10)>
	<script type="text/javascript">
	$("document").ready(function() {

		$("#cont_summary").hide("fast");
	});
	</script>
</cfif>

<cfoutput>
<cfset session.id_controller = id_controller>

<!-- 1  --><table width=100% cellpadding=0 cellspacing=0 border=0>
		<tr>
		<td width=60% valign="top">
		<p class="smtitle">
		ARA  #reference# Controller</p>
		<p class="aratitle">Title: #title#</p>
		</td>
		<td valign="top" align="right">
		<!--- a class="embed" href="#self#?fuseaction=app.ARA_ControllerV2&&AID=#AID#">Controller Form</a>&nbsp;&nbsp;|&nbsp;&nbsp;
		<a class="embed" href="#self#?fuseaction=app.ARA_ControllerV2&FormorView=View&&AID=#AID#">Controller View</a>&nbsp;&nbsp;|&nbsp;&nbsp; --->
		<a class="embed" href="#self#?fuseaction=app.ARA_cfdocument&AID=#AID#">Print ARA <img src="images/PrinterIcon.gif" border=0></a>
<!-- /1  --></td></tr></table>
</cfoutput>

<!--- ARA Summary Info at top of page ---><cfinclude template="dsp_ARA_top_summary.cfm">

<fieldset><legend><b>ARA Backup Detail</b></legend>
<!--- ARA Navigational Tabs ---><cfinclude template="dsp_tabset.cfm">
<cfset who="CON">
<cfset returnto="Controller">
<!--- Next Line Returns: doc_cnt (total attachments), havecount, needcount, missingList --->
<cfset docs=#AttachmentStatus(id_ara,id_cat)#>

<cfinclude template="dsp_messages.cfm">

<!--- If in controller, or rejected and this person is the contract manager, they will see form. Otherwise view only --->

<cfif (FormorView EQ "Form")  AND (ListFind('4,5',id_status)) and ((ID_controller EQ session.id_user)
OR (FindnoCase(id_controller,session.delegators)))>

<cfoutput>
<div id="cont_summary"><!--- Hide this div if no clins have been divided --->

<cfinclude template="../../model/m_ara/qry_ClinCostFeeTotals.cfm">

<!--- Next loads javascript for form validation --->
<!---<cfinclude template="../../model/m_forms/js_controllerTab.cfm">--->

<script language="Javascript">

function validateForm()
{
	var errMsgHdr = "Please correct the following errors and resubmit:\n\n";
	var errMsgs = "";
	var retVal;

	if (isWhitespace(document.forms.Controller.InterestImpact.value))
	{
		errMsgs = errMsgs + "Enter interest impact to HII through receipt of payment \n";
	}

	if (isWhitespace(document.forms.Controller.BurnRate.value))
	{
		errMsgs = errMsgs + "Enter expected burn rate per two week period  \n";
	}

	if (isWhitespace(document.forms.Controller.IcCost.value))
	{
		errMsgs = errMsgs + "Enter incurred Cost not yet Billable  \n";
	}
	if (isWhitespace(document.forms.Controller.ICfee.value))
	{
		errMsgs = errMsgs + "Enter incurred Fee not yet Billable  \n";
	}
	if (!isEmpty(errMsgs))
	{
		alert(errMsgHdr + errMsgs);
		return false;
	}
	else
	{
	<cfoutput>	var url ='&submit=true';
	</cfoutput>
	document.forms.Controller.action += url;
	document.forms.Controller.submit();
	}
}
</script>
<!--- detection of change on input fields, so can force save --->
<script>
	$(document).ready(function()
	{
		$("input[type=text]").change(function()
		{
			check();
		});
		$("input[type=radio]").change(function()
		{
			check();
		});
		$("select").change(function()
		{
			check();
		});
	});
</script>
<script type="text/javascript">
		function check()
			{
				$("##Upload").removeClass('button');
				$("##Upload").css({'font-family': 'verdana', 'font-size': '11px','color': '##000000'});
				$("##Upload").val("Save form before document upload");
				$("##Upload").attr("disabled", true);
			}
		</script>
<fieldset><legend><b>Controller Summary</b></legend>


<cfform name="Controller"  id="Controller" method="Post" onChange="check();" preservedata="True" enctype="multipart/form-data" action="#Faction#">
<cfinput type="hidden" name="amountTotal" value="#amountTotal#">
<cfinput type="hidden" name="id_cat" value="#id_cat#">
<cfinput type="hidden" name="revision" value="#revision#">
<cfif isdefined("Total_cost") and isdefined("Total_fee")>
	<cfset allowedAmt = amounttotal - Total_cost - Total_fee>
    <input type="hidden" name="allowedAmt" value="#allowedAmt#">
<cfelse>
	<input type="hidden" name="allowedAmt" value="0">
</cfif>

<input type="hidden" name="id_controller" value="#id_controller#">
<table width=100% cellpadding=2 cellspacing=2 class="border">
<!---<tr>

	<!----             select Company                    --->
	<td width="25%" class="border" valign="bottom">
	Company
	</td>
	<td class="border" colspan="5">
	<cfif id_cat NEQ 10>
	 <img src="images/ControllerStep.gif" align="right" alt="">
	 </cfif>
	 <input type="hidden" name="company" value="ALIN">
	<!---
	 <input type="radio" name="company" id="company"  value="ALIN" <cfif #getController.company# EQ "ALIN">checked<cfelse>checked</cfif>>ALIN
     <input type="radio" name="company" id="company2" value="WCGS" <cfif #getController.company# EQ "WCGS">checked</cfif>>WCGS
     <input type="radio" name="company" id="company3" value="WCON" <cfif #getController.company# EQ "WCON">checked</cfif>>WCON
     <input type="radio" name="company" id="company4" value="CANA" <cfif #getController.company# EQ "CANA">checked</cfif>>CANA
--->


</tr>--->

<tr>
	<!----             INTEREST IMPACT                     --->
	<td width="25%" class="border" valign="bottom">
	Interest impact to HII through receipt of payment
	</td>
	<td class="border">
	 $ <cfinput class="inputtext" type="text" name="InterestImpact" id="InterestImpact" REQUIRED="Yes" VALIDATE="integer" MESSAGE="Interst Impact: Enter whole dollar amounts" size=12 maxlength=15 value="#InterestImpact#">
	</td>
	<!----             BURN RATE                     --->
	<td  width="25%" valign="bottom" class="border">
	Expected burn rate per two week period
	</td>
	<td colspan=3 class="border">
	 $ <cfinput class="inputtext" type="text" name="BurnRate" id="BurnRate" REQUIRED="Yes" VALIDATE="integer" MESSAGE="Burn Rate: Enter whole dollar amounts" size=12  maxlength=15 value="#burnRate#" >
	</td>
</tr>
<tr><!----             INCURRED  COST                     --->
	<td  width="25%"  valign="bottom" class="border">
	Incurred <b>Cost</b> not yet Billable
	</td>
	<td class="border">
	$ <cfinput class="inputtext" name="IcCost" id="IcCost" value="#IcCost#" size=12  maxlength=15  >

	</td>
	<!----             INCURRED  FEE                     --->
	<td  width="25%"  valign="bottom" class="border">
	Incurred <b>Fee</b> not yet Billable
	</td>
	<td colspan=3 class="border">
	$ <cfinput class="inputtext" name="ICfee" value="#ICfee#" id="ICFee" size=12  maxlength=15 >
	</td>
</tr>
<cfif id_cat NEQ 10 >
<tr >
	<td class="border">Total <b>Cost</b> [from CLINs below]</td>
	<td nowrap class="border"><!---      Total_cost    --->
	$ <cfinput type="text" readonly name="total_cost_dsp" id="Total_Cost_dsp" value="#Total_Cost_dsp#" size=12 class="autopop"><!--- show in number format $9,999.00 --->
	<input type="hidden" name="Total_Cost" value="#total_Cost#" id="Total_cost"></td>
	<td class="border">Total <b>Fees</b> [from CLINs below]</td>
	<td  nowrap class="border"><!---      Total_Fee    --->
	$ <cfinput type="text" name="total_fee_dsp" readonly id="Total_Fee_dsp" value="#Total_Fee_dsp#"size=12 class="autopop">
	<input type="hidden" name="Total_Fee" value="#total_Fee#" id="Total_Fee"></td>
	<td class="border">Total</td>
	<td  nowrap class="border"><!---      Total_Value    --->
	$ <cfinput type="text" readonly name="Total_Value_dsp" id="Total_Value_dsp" value="#Total_Value_dsp#" size=12 class="autopop">
	<input type="hidden" name="Total_Value" value="#total_Value#" id="Total_Value"></td>
</tr>
<cfelse><!--- Early Start no clin totals filled in --->

	<input type="hidden" name="Total_Cost" id="total_value" value="0">
	<input type="hidden" name="Total_Fee" id="Total_Fee" value="0">
	<input type="hidden" name="Total_Value" id="Total_Value" value="0">
</cfif>
<!----   uuuuuuuuuuuuuuuuuuuuuuuuu Show Uploaded Documents uuuuuuuuuuuuuuuuuuuuuuuuuuuuu   --->
<tr bgcolor="##efefef" >
	<td valign="top" colspan=2 class="border">
	<cfif id_cat EQ 10>
		<b>Document Uploads are Optional For Early Start</b>
	<cfelse>
		<img src="images/RightArrow.png" align="left"><b>&nbsp;&nbsp;<font style="color:##7ea6c1">Required Controller Document(s)</b></font>
	</cfif>
	<td valign="top" class="border" colspan=4><!--- list what is required --->
		<div id="docdesc">
		<cfif docTypes.recordcount GT 0>
			<cfloop query="docTypes">
			<cfif find(ID_attachtype,MissingList)>
				<img src="images/SmGreyMinus.png"> #short_desc# <cfif id_cat NEQ 10>(Need)</cfif>
				<img style="vertical-align: bottom;padding-left:5px;padding-right:5px;" src="images/tooltip-icon.png"
		title="<cfoutput><b>#Short_Desc#</b><br>#Long_desc#</cfoutput>">
			<cfelse>
				<img src="images/SmCheck.png">#short_desc# (Have)
				<img style="vertical-align: bottom;padding-left:5px;padding-right:5px;" src="images/tooltip-icon.png"
		title="<cfoutput><b>#Short_Desc#</b><br>#Long_desc#</cfoutput>">
			</cfif>
			<br>
			</cfloop>
		<cfelse>
			There are no required uploads.
		</cfif>
		</div>
	</td>
</tr>

<tr>
	<td colspan=6 class="border">
	<cfinclude template="_docList.cfm">
	</td>
</tr>

<tr>
	<td align="center" class="border" colspan=6>
		<input class="button" type="submit" id="SaveCM" name="saveCM" value="Save">
	<!--- If people start putting in form data, we wnt them to save before hitting upload. So we disable that button
		      if they put form info in --->

		<script type="text/javascript">
		function check()
			{
				$("##Upload").removeClass('button');
				$("##Upload").css({'font-family': 'verdana', 'font-size': '11px','color': '##000000'});
				$("##Upload").val("Save form before document upload");
				$("##Upload").attr("disabled", true);
			}
		</script>
		<!--- uuuuuuuuuuuuuuuuuuuu UPLOAD BUTTON uuuuuuuuuuuuuuuuuuu  --->
		<!--- if any changes are made to the form, will set this button value to:
		      Save form before you upload, and disable this button --->
		<input  class="button" type="button" id="Upload" name="Upload" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.ARA_ControllerV2&id_ara=#id_ara#&AID=#AID#&Upload=Yes&v';" value="Upload Document(s)">

		<!--- uuuuuuuuuuuuuuuuuuuu END UPLoad Button uuuuuuuuuuuuuuuuuuu  --->
		<cfoutput>

		<cfquery name="CLINs" datasource="#Application.dsn#">
				Select count(*) as CLINCNT
				From CLINs
				where id_ara=#id_ara#
		</cfquery>
		<!--- ssssssssssssssssssss Submit for Approval ssssssssssssssss  --->
		<!--- Check if either we don't have needed document or CLINS --->
		<cfif ((Needcount GT 0) AND (id_CAT NEQ 10)) OR (id_CAT NEQ 10 and CLINS.CLINCNT EQ 0) >

			<cfset subText="Submit for Approval after Doc Upload">
			<cfif CLINs.CLINCNT EQ 0>
				<cfset subtext="#subtext#" & " & CLINS Below">
			</cfif>
			<input type="button" disabled style="width:315px;color:##000000;font-family:verdana;font-size:11px;"
			value="#subtext#">
		<cfelse>
			<!--- cfinput class="button" name="submit" type="submit" value="Submit for Next Approval" onclick="alert('I clicked');" --->
			<input class="button" type="button" value="Submit For Approval" onClick="Javascript: validateForm();">
		</cfif>
		</cfoutput>
        <p></p>


	</td></tr>
</table>
</cfform>

</fieldset>
</div>

<cfif id_cat NEQ 10 or (id_cat EQ 10 and id_status EQ 13 and session.id_job EQ 13)>

<!---  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->
<!---                       CLIN BOTTOM PORTION OF PAGE                            --->
<!---  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->

<cfinclude template="dsp_ClinFormV2.cfm">
</cfif>
</cfoutput>

<cfform name="Reject" id="Reject"  method="Post" preservedata="True"  enctype="multipart/form-data" action="#Faction#">
<table border="0" align="center">
<tr>
	<td align="center" colspan=1>
		<cfoutput>
		<input class="reject_btn"  type="button" value="&nbsp;&nbsp;REJECT ARA" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.ARA_ControllerV2&id_ara=#id_ara#&AID=#AID#&Reject=Yes';">
		</cfoutput>
	</td></tr>
</table>
</cfform>
<cfelseif id_cat EQ 10 and id_status EQ 13 and session.id_job EQ 13>
	<!--- show CLIN page for CCS --->
    <cfinclude template="dsp_ClinFormV2.cfm">
<cfelse><!--- Form or view is View only --->

    <cfinclude template="dsp_ARA_ControllerV2_View.cfm">
</cfif>

<!--- Tooltip Initialization ---->
<script>
// initialize tooltip
$("#docdesc img[title]").tooltip({

	// place tooltip on the right edge
	position: "center right",

	// a little tweaking of the position
	offset: [17, 10],

	// custom opacity setting
	opacity: 1.0
}).dynamic({ bottom: { direction: 'down', bounce: true } });
</script>
