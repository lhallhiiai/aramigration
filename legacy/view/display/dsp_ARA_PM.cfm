<!--- **********************************************************  --->
<!---  Program Manager  Information Page                          --->
<!--- ********************************************************** --->
<cfinclude template="inc_tooltipContent.cfm">
<cfparam name="Submenu" default="ARA_Detail">
<cfparam name="FormorView" default="Form">  
<cfparam name="isSaved" default="1">
<cfparam name="thisJob" default="1">
<cfset whichtab="PM"> 
<cfif isDefined('url.aid')>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cfelse>
	Fatal Error: PM page was not passed an encrypted ara id.<cfabort>
</cfif>
<cfif isdefined("url.msg") and url.msg eq "PCcreated">
<center><p class="confirmMsg">ARA has been created</p></center>
</cfif>

<!--- +++++++++++ Pulls ARA, user, groups, sector, category, status ++++++++++ --->
<cfinclude template="../../model/m_ara/qry_ara.cfm">
<cfinclude template="../../model/m_forms/qry_Required_Questions.cfm">
<cfinclude template="../../model/m_ara/qry_PMTab.cfm">
<!--- Retrieve the required questions for the PM tab --->
<cfset reqdQs=#RequiredQs(id_cat,'PM')#>

<!--- If this has been rejected and this is the PM let him see the form --->
<!--- cfdump var="#session#" format="text" --->

<!--- +++++++++++++++++++++ UPLOAD DOC FANCY BOX +++++++++++++++++++++  --->

<!--- If Upload button is clicked, will bring up Reject Button in front of page --->
<cfif isDefined('Upload') and (Upload NEQ "")><!--- Show Fancy Box containing Upload --->
	<script type="text/javascript">
	    $(document).ready(function() {
	        $("#hidden_link2").fancybox().trigger('click');
	    });
	</script>
</cfif>
<cfoutput>
<a href="index.cfm?fuseaction=app.ARA_Docs_include&AID=#AID#&id_cat=#id_cat#&id_status=#id_status#&who=PM&id_pm=#id_pm#&returnTo=PM" id="hidden_link2" style="display:none;"></a>

</cfoutput>
<!--- +++++++++++++++++++++ END OF UPLOAD DOC FANCY BOX +++++++++++++++++++++  --->

<cfoutput>
<!-- 1  --><table width=100% cellpadding=0 cellspacing=0 border=0>
		<tr>
		<td width="60%" valign="top">
		<p class="smtitle">
		ARA Summary</p>
		<p class="aratitle">Title: #title#</p>
		</td>
		<td valign="top" align="right">
		<!--- a class="embed" href="#self#?fuseaction=app.ARA_PM&Menu=ARA_Detail&FormorView=View&AID=#AID#">PM View Only</a>&nbsp;&nbsp;|&nbsp;&nbsp;
		<a class="embed" href="#self#?fuseaction=app.ARA_PM&Menu=ARA_Detail&AID=#AID#">PM Form</a>&nbsp;&nbsp;|&nbsp;&nbsp; --->
		<a class="embed" href="#self#?fuseaction=app.ARA_cfdocument&AID=#AID#">Print ARA <img src="images/PrinterIcon.gif" border=0></a>

<!-- /1  --></td></tr></table>
</cfoutput>
<!--- ARA Summary Info at top of page ---><cfinclude template="dsp_ARA_top_summary.cfm">

<fieldset><legend><b>ARA Backup Detail</b></legend>
<!--- ARA Navigational Tabs ---><cfinclude template="dsp_tabset.cfm">
<!--- If Risk Requested --->
<cfinclude template="dsp_Messages.cfm">
<cfif (FormorView EQ "Form") AND ListFind('1,8,9',id_status) 
and ((ID_PM EQ session.id_user) OR (FindnoCase(id_PM,session.delegators)))>

<script type="text/javascript">
$("document").ready(function() {
	$("#long_qs").hide("normal");
	if($('#amountTotal').val().replace(/\,/g,'') >= 50000)
	{
			$("#long_qs").show("fast");
	}
	else{
		$("#long_qs").hide("fast");
	}

});
</script>

<!--- confirm cancel --->

<script type="text/javascript">
function check()
{
	//alert('check this value');

	var test = $('#amountTotal').val().replace(/\,/g,'');
	if($('#amountTotal').val().replace(/\,/g,'') >= 50000)
	{
			$("#long_qs").show("fast");
	}
	else{
		$("#long_qs").hide("fast");
	}
}
</script>
<script type="text/javascript">
function check2()
{
	var amtTotal = $('#amountTotal').val().replace(/\,/g,'');
	var totalAnt = $('#Totalanticipated').val().replace(/\,/g,'');
	 if(totalAnt >= amtTotal){
		alert('Anticipated Funding must not exceed Total ARA Amount');
	}
	
}

function CalculatePercentage() {
		var amtTotal = document.forms.PMForm.amountTotal.value.replace(/\,/g,'');
		var totalAnt = document.forms.PMForm.Totalanticipated.value.replace(/\,/g,'');
		if (amtTotal >=0 && totalAnt>=0) {
		document.forms.PMForm.percentAnticipated.value = (amtTotal)/(totalAnt)*100;
		}
	}
	
	
</script>
<!--- If any form changes are made want to disable Upload buttton --->


<script type="text/javascript">
		function disablebutton()
			{
				$("#Upload").removeClass('button');
				$("#Upload").css({'font-family': 'verdana', 'font-size': '11px','color': '##000000'});
				$("#Upload").val("Save form before document upload");
				$("#Upload").attr("disabled", true);
				$("#isSaved").val(0);
			}
</script>
<script>
	$(document).ready(function()
	{
		$("input[type=text],textarea").change(function()
		{
			disablebutton();
		});
		$("input[type=radio]").change(function()
		{
			disablebutton();
		});
		$("select").change(function()
		{
			disablebutton();
		});
	});
</script>
<script language="JavaScript" type="text/JavaScript">
$(document).ready(function() {
	  
		$('a.tab').click(function() { 
		  if ($('#isSaved').val()== 0)
		  {
          var answer = confirm("You have unsaved input. Cancel and save input first.")
          if (answer){
          }
          else
          { return false; }            
		  }
      });
	  
	  
});
</script>

<cfform action="?fuseaction=app.PM_submit&AID=#url.aid#" id="PMForm" name="PMForm">
<cfinput type="hidden" name="reference" value="#reference#">
<cfinput type="hidden" name="revision" value="#revision#">
<cfinput type="hidden" name="ID_Pm" value="#id_pm#">
<!--- cfinput type="hidden" id="isSaved"  name="isSaved" value="#isSaved#" --->
<!--- Next for mail_submitnext...to target distribution list --->
<cfif Find(ID_PM,Session.delegators)><!--- If the PM has delegated to this person --->
	<cfinput type="hidden" name="oprid_delegateTo" value="#session.oprid#">
	<cfquery name="PM_Opr" datasource="#Application.dsn#">
		Select oprid from v_users
		where id_user=#ID_PM#
	</cfquery>
	<cfinput type="hidden" name="oprid_delegateFrom" value="#PM_opr.oprid#">
</cfif>
<!-- 1  --><table width="100%" cellpadding=2 cellspacing=2 class="outerborder">
<tr><cfoutput>
	<td class="border" nowrap><b>Total ARA Amount</b>: <br />
    $ <cfinput class="inputtext" name="amountTotal" value="#numberformat(AmountTotal,'9,999.99')#" onChange="check();"> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  <strong><font size="+1"> &le; </font></font></strong>
	</td>
    
	<td nowrap class="border">Total Funded Value Anticipated: <br />
    $ <cfinput  class="inputtext" name="Totalanticipated" value="#Numberformat(Totalanticipated,'9,999.99')#" maxlength="20" size=20 onBlur="CalculatePercentage();">
	</td>
	
	<td class="border" nowrap colspan="2">Percent of Funded Value Anticipated: <br />
	<cfinput   class="autopop"  name="percentAnticipated" value="#percentAnticipated#" readonly="true" size="4">% <i>(automatically calculated)</i></td>
</tr>

<tr>

	<td  class="border">Required Start Date:
	</td>
	<td class="border">
		<cfif isDate(startDate)>
			<cfinput type="text" name="startDate" style="background-color: ##E2E8DB;font-size:11px;font-family:verdana;" value="#dateformat(startDate,"MM/DD/YYYY")#" size=10 class="date">
		<cfelse>
			<cfinput type="datefield" mask="MM/DD/YYYY" name="startDate" style="background-color: ##E2E8DB;font-size:11px;font-family:verdana;" value="" size=10 class="date">
		</cfif>
	</td>
	<td class="border">Expiration Date</td>
	<td class="border">
		<cfif isDate(ExpirationDate)>
			<cfinput type="text" style="background-color: ##E2E8DB;font-size:11px;font-family:verdana;" name="ExpirationDate" mask="" size=10 class="date" value="#dateformat(ExpirationDate,"MM/DD/YYYY")#">
		<cfelse>
			<cfinput  type="datefield" mask="MM/DD/YYYY" style="background-color: ##E2E8DB;font-size:11px;font-family:verdana;" name="ExpirationDate" size=10 class="date" value="">
		</cfif>
	</td>
</tr>
</cfoutput>
<cfoutput>
<cfif id_cat EQ 10>
<tr>
	<td class="border">Early Start Reason</td>
	<td  colspan=3 class="border">
		<cfselect class="inputtext" name="ES_Reason_Code">
			<option value="1">Resources presently available</option>
			<option value="2">Need to hire resources</option>
			<option value="3">Allow time for site preparation</option>
		</cfselect>
	</td>
</tr>
<tr>
	<td valign="top" class="border">Early Start Necessary to:</td>
	<td colspan=3 class="border">
		<input type="checkbox" name="ES_Necessary"  <cfif ListFind(ES_Necessary,"Schedule") GT 0> checked="yes"</cfif> value="Schedule">Meet Customer Schedules<br />
		<input type="checkbox" name="ES_Necessary" <cfif ListFind(ES_Necessary,"Coverage") GT 0> checked="yes"</cfif> value="Coverage">Assure Continuity of Coverage<br>
        <input type="checkbox" name="ES_Necessary" <cfif ListFind(ES_Necessary,"Both") GT 0> checked="yes"</cfif> value="Both">Both, and/or<br>
		Other <cfinput class="inputtext" name="Other_necessary" size=40 value="#Other_necessary#">
	</td>
</tr>
<cfelse>
<input type="hidden" name="ES_Necessary" value="" />
<input type="hidden" name="Other_necessary" value="" />

</cfif>
</cfoutput>

 <!--- tr>
	<td valign="top" class="border">Program Manager Certification:</td>
	<td colspan=3 class="border">
		Date supplied when PM submits.
	</td>
</tr --->

<!-- 1  --></table>
<!---<cfquery name="PMDocs" datasource="#Application.DSN#">
	SELECT     attach_checklist.ID_attachtype, attachments.id_attachment, attachments.id_ara, attach_checklist.Short_desc, attachments.filename, 
               attachments.description, attachments.date, attachments.Filesize, attachments.fileType, attachments.id_user, ara.ID_PM
	FROM       attach_checklist INNER JOIN
               attachments ON attach_checklist.ID_attachtype = attachments.fileType INNER JOIN
               ara ON attachments.id_ara = ara.id_ara
    WHERE     (attachments.id_ara = #id_ara#) and attachments.id_user=ara.ID_PM
</cfquery>--->
<table cellpadding=2 cellspacing=2 class="outerborder" width=100%>
<!----   uuuuuuuuuuuuuuuuuuuuuuuuu Show Uploaded Documents uuuuuuuuuuuuuuuuuuuuuuuuuuuuu   --->

<tr>
	<td colspan=2 class="border">
	<cfset returnTo="PM">
	<cfinclude template="_docList.cfm">
	</td>
</tr>
</table>
<cfif NOT ListFind('1,5, 7, 10',id_cat)>
<table width=100% class="outerborder" cellpadding=2 cellspacing=2>

<!---              Question 1                --->
<cfif id_cat EQ 6 or id_cat EQ 8 or id_cat EQ 9>
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">&nbsp;&nbsp;</td>
		<td valign="top">Reason for the change in the scope of work or Period of Performance
		</td></tr></table>
		</td>
	<td valign="top">
	<cftextarea name="changeInScope"  value="#changeInScope#" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>
<cfelse>
<input name="changeInScope" value="N/A" type="hidden">
</cfif>
<cfif id_cat EQ 4>
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">&nbsp;&nbsp;</td>
		<td valign="top">Describe necessary actions to clear At Risk
		</td></tr></table>
		</td>
	<td valign="top">
	<cftextarea name="actionToClear"  value="#ActionToClear#" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>
<cfelse>
	<input name="actionToClear"  value="N/A" type="hidden">
</cfif>
</table>
<cfelse>
<input type="hidden" name="actionToClear" value="N/A" /> 
<input type="hidden" name="CHANGEINSCOPE" value="N/A" />
</cfif>
<!--- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->
<!--- end of doc upload questions--->

 <div id="long_qs">
<!-- 1  --><table width=100% class="outerborder" cellpadding=2 cellspacing=2>
<cfif id_cat EQ 1 or id_cat EQ 4>
<input type="hidden" name="FundsInAdvance" value="N/A" />
<input type="hidden" name="ContractDefinization" value="N/A" />
<input type="hidden" name="pertinentInformation" value="N/A" />
<input type="hidden" name="workStarted" value="N/A" />
<input type="hidden" name="consequence" value="N/A" />
<input type="hidden" name="currentStatus" value="N/A" />
<cfelse>
<tr>
	<td class="black" colspan=2>
	ARA Amounts greater than $50K, and not category AWARD FEES or INTERNALLY CLEARED require all 6 questions to be answered.
	</td>
</tr>
<!---              Question 1                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">1.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top">
		<b>Justify Risk</b><br>Why is it necessary for HII to risk funds in advance of contract
		or modification receipt?
		</td></tr></table>
		</td>
	<td valign="top">
	<cftextarea name="FundsInAdvance" value="#FundsInAdvance#" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>
<!---              Question 2                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">2.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top">
		<b>Finalization Actions in Progress</b><br>What is currently being done to ensure contract definitization on the expected contract or modification execution date?
		</td></tr></table>
	</td>
	<td valign="top">
	<cftextarea name="ContractDefinization"  value="#ContractDefinization#" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>

<!---              Question 3                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">3.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top">
		<b>Other Risk Info</b><br />What other pertinent information is available to aid in evaluating this request for at risk approval? Are there any special
	or unusual circumstances?
		</td></tr></table>
	</td>
	<td valign="top">
	<cftextarea name="pertinentInformation"  rows=3 value="#pertinentInformation#" cols=80 class="inputtext"></cftextarea>
	</td>
</tr>

<!---              Question 4                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">4.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top"><b>Work Prior to ARA</b><br>If work was started prior to presenting the request for management approval, explain why?
		</td></tr></table>
	</td>
	<td valign="top">
	<cftextarea name="workStarted" value="#workStarted#" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>

<!---              Question 5                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">5.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top"><b>Consequence of Disapproval</b></br>What is the consquence of not commencing work in advance of a signed contract or modification?
		</td></tr></table>
	</td>
	<td valign="top">
	<cftextarea name="Consequence" value="#consequence#" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>

<!---              Question 6                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">6.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top"><b>Current Status</b><br>What is the current status of the anticipated contractual coverage?
		</td></tr></table>
	</td>
	<td valign="top">
	<cftextarea name="currentStatus" value="#currentStatus#" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>
</cfif>
</table>
</div>
<cfoutput>
<!-- 1  --><table width=100% class="border" cellpadding=2 cellspacing=2>
<tr>
	<td colspan=2 align="center">
	<input class="button" type="submit" name="SavePM" value="Save">
	<!--- input class="button" type="submit" name="SavePM" value="Save" onclick="Javascript:$('##isSaved').val(1);" --->
	<!--- uuuuuuuuuuuuuuuuuuuu UPLOAD BUTTON uuuuuuuuuuuuuuuuuuu  --->
		<!--- if any changes are made to the form, will set this button value to:
		      Save form before you upload, and disable this button --->
		<input  class="button" type="button" id="Upload" name="Upload" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.ARA_PM&id_ara=#id_ara#&AID=#AID#&Upload=Yes&';" value="Upload Documents">
	
	<!--- uuuuuuuuuuuuuuuuuuuu END UPLoad Button uuuuuuuuuuuuuuuuuuu  --->
	<!--- If we have all the documents we need the submit is enabled, otherwise it is not --->

	<input class="button" type="button" name="SignPM" value="Sign & Submit" onClick="return validateForm();">
</table>
</cfoutput>
</cfform>
<cfelse>
	<p>The program information is complete and can only be viewed. The current state of this ARA is: <cfoutput><b>#StatusName#</b></cfoutput></p>
	<cfinclude template="dsp_ARA_PM_View.cfm">
</cfif>

<!--- PM can cancel before it's approved. RD 6.7 --->
<cfif (FormorView EQ "Form") AND ListFind('1,2,3,4,5,6,7,8,9,11',id_status) and session.id_user EQ ID_PM>
<script type="text/javascript">
	function confirmCancel()
	{
	var r=confirm("By canceling this ARA, you are confirming that this ARA is no longer necessary. No one will be able to make any changes or revise this form. Please click OK to confirm your cancellation.");
	if (r==true)
	  {
	  return true;
	  }
	else
	  {
	  return false;
	  }
	}
</script>

<cfform action="?fuseaction=app.PM_cancel&AID=#url.aid#" id="PMFormC" name="PMFormC">
<cfinput type="hidden" name="reference" value="#reference#">
<cfinput type="hidden" name="revision" value="#revision#">
<cfinput type="hidden" name="title" value="#title#">
<cfinput type="hidden" name="jamisNo" value="#jamisNo#">
<table width="100%" cellpadding=2 cellspacing=2 >
	<tr>
		<td align="center"><input class="button" type="submit" name="CancelPM" value="Cancel This ARA" onClick="return confirmCancel();"></td>
    </tr>
</table>
</cfform>
</cfif>

</fieldset>
</body>
</html>
<script type="text/javascript">
function save() {
	$("#isSaved").val(1);
	document.forms.PMForm.submit();
}
</script>


<script type="text/JavaScript">

function validateForm() {
var errMsgHdr = "Please correct the following errors and resubmit:\n\n";
var errMsgs = "";
var errMsgs = "";


/*  amountTotal   */
	if (isWhitespace(document.forms.PMForm.amountTotal.value)) {
		errMsgs = errMsgs + "Total amount of the ARA is required\n";
	} 
	else 
		{
		if (document.forms.PMForm.amountTotal.value <= 0) {
			errMsgs = errMsgs + "The total amount is  0. Enter correct amount.\n";
		}
		
	}
	
	/*  Totalanticipated   */
	if (isWhitespace(document.forms.PMForm.Totalanticipated.value)) {
		errMsgs = errMsgs + "Total Funded Value Anticipated is required\n";
	}
	else 
		{
		if (document.forms.PMForm.Totalanticipated.value <= 0) {
			errMsgs = errMsgs + "The total anticipated is 0. Enter correct amount.\n";
			<!---alert(isFinite(document.forms.PMForm.Totalanticipated.value));--->
		}
		/*
		
		if (isFinite(document.forms.PMForm.Totalanticipated.value) = false) {
			errMsgs = errMsgs + "Only numeric amount allowed.\n";
		}
		*/
		
	}

	
/*   Compare amountTotal with Total Anticipated   */
	if (document.forms.PMForm.percentAnticipated.value >100)  {
		errMsgs = errMsgs + "Total ARA Amount has exceeded Total Fund Anticipated\n";
	} 
	
/*                THE BIG 6 QUESTIONS                        */
<cfif id_cat NEQ 1 AND id_cat NEQ 4>
	if (document.forms.PMForm.amountTotal.value >= 50000){
		/*  1.   FundsInAdvance */
		if (isWhitespace(document.forms.PMForm.FundsInAdvance.value)) {
			errMsgs = errMsgs + "1. Provide Justification of Risk\n";
		}
		/*  2.   ContractDefinization */
		if (isWhitespace(document.forms.PMForm.ContractDefinization.value)) {
			errMsgs = errMsgs + "2. Provide Finalization Actions in Progress\n";
		}
	
	/*  3.   pertinentInformation */
		if (isWhitespace(document.forms.PMForm.pertinentInformation.value)) {
			errMsgs = errMsgs + "3. Provide Other Risk Info\n";
		}
	
	/*  4.   workStarted */
		if (isWhitespace(document.forms.PMForm.workStarted.value)) {
			errMsgs = errMsgs + "4. Provide Work Prior to ARA\n";
		}
	
	/*  5.   Consequence */
		if (isWhitespace(document.forms.PMForm.Consequence.value)) {
			errMsgs = errMsgs + "5. Provide consequence of disapproval\n";
		}
	
	/*  6.    currentStatus */
		if (isWhitespace(document.forms.PMForm.currentStatus.value)) {
			errMsgs = errMsgs + "6. Provide Current Status\n";
		}
	}
</cfif>
/*  Actions to Clear   */

	if (isWhitespace(document.forms.PMForm.actionToClear.value)) {
		errMsgs = errMsgs + "Please Describe necessary actions to clear At Risk\n";
	}	
	
	/*  Change in Scope   */
<cfif id_cat EQ 6 or id_cat EQ 8 or id_cat EQ 9>

	if (isWhitespace(document.forms.PMForm.changeInScope.value)) {
		errMsgs = errMsgs + "Please describe reasons for change of scope\n";
	}
</cfif>
/*  percentAnticipated   */
	/*if (isWhitespace(document.forms.PMForm.percentAnticipated.value)) {
		errMsgs = errMsgs + "The percent anticipated is required\n";
	}
	else 
		{
		if (document.forms.PMForm.percentAnticipated.value <= 0) {
			errMsgs = errMsgs + "The percent anticipated is 0. Enter correct amount.\n";
		}
		
	} */

/*  Start Date   */
	if (isWhitespace(document.forms.PMForm.startDate.value)) {
		errMsgs = errMsgs + "Start date  is required\n";
	} else if (!ForceDate(document.forms.PMForm.startDate)) {
		errMsgs = errMsgs + "Start Date is not a valid date - use MM/DD/YY.\n";
	}
	
	var exDate = new Date(document.getElementById("ExpirationDate").value.substring(0,10));
	var stDate = new Date(document.getElementById("startDate").value.substring(0,10));
	var today = new Date();
	
    if (exDate < stDate) {
		errMsgs = errMsgs + "Please make sure all dates are in mm/dd/yyyy format. Expiration date must be after the start date\n";
    }
	if (exDate <= today) {
		errMsgs = errMsgs + "Please make sure all dates are in mm/dd/yyyy format. Expiration date must be in the future\n";
    }
	
	
	
/*  ExpirationDate   */
	if (isWhitespace(document.forms.PMForm.ExpirationDate.value)) {
		errMsgs = errMsgs + "Expiration date  is required\n";
	} else if (!ForceDate(document.forms.PMForm.ExpirationDate)) {
		errMsgs = errMsgs + "Expiration Date is not a valid date - use MM/DD/YY.\n";
	}
/*  percentAnticipated   */
	if (isWhitespace(document.forms.PMForm.percentAnticipated.value)) {
		errMsgs = errMsgs + "Percent of Funded Value Anticipated is required\n";
	}

if (!isEmpty(errMsgs)) {
		alert(errMsgHdr + errMsgs);
		return false;
	} else {
		save();
		return true;
	}
}
</script>