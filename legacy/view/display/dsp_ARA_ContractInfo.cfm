<!--- **********************************************************  --->
<!---       ARA Contract Information                             --->
<!--- ********************************************************** --->

<cfparam name="Submenu" default="ARA_Detail">
<cfparam name="FormorView" default="Form">
<cfparam name="thiscType" default="">
<cfparam name="ThisCustType" default="">
<cfparam name="thisid" default="">
<cfparam name="thisJob" default="2">
<cfparam name="UseCheck" default="yes">
<cfparam name="isSaved" default="1">
<cfparam name="OtherType" default="">
<cfset whichtab="Contract">
<cfparam name="PCCostAuth" default=0>

<cfif isDefined('url.aid')>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
</cfif>

<cfoutput>
<cfquery name="gTitle" datasource="#Application.dsn#">
	select title, reference
	from ARA 
	where id_ara=#decrypt(AID,request.encryptKey,request.encryptType,'hex')#
</cfquery>

<!-- 1  --><table width=100% cellpadding=0 cellspacing=0 border=0>
		<tr>
		<td width="60%" valign="top">
		<!--- replacing fix that was dropped. Title was wrong --->
		<p class="smtitle">
		ARA Contract Info</p>
		<p class="aratitle">#gtitle.reference# - #gtitle.title#</p>
		</td>
		<td valign="top" align="right">
		<!--- a class="embed" href="#self#?fuseaction=app.ARA_PM&Menu=ARA_Detail&FormorView=View&AID=#AID#">PM View Only</a>&nbsp;&nbsp;|&nbsp;&nbsp;
		<a class="embed" href="#self#?fuseaction=app.ARA_PM&Menu=ARA_Detail&AID=#AID#">PM Form</a>&nbsp;&nbsp;|&nbsp;&nbsp; --->
		<a class="embed" href="#self#?fuseaction=app.ARA_cfdocument&AID=#AID#">Print ARA <img src="images/PrinterIcon.gif" border=0></a>

<!-- /1  --></td></tr></table>
</cfoutput>
<!--- ARA Summary Info at top of page ---><cfinclude template="dsp_ARA_top_summary.cfm">

<fieldset><legend><b>ARA Backup Detail for Category:</b></legend>
<!--- ARA Navigational Tabs ---><cfinclude template="dsp_tabset.cfm">
<cfset who="CM">		
<!--- Next Line Returns: doc_cnt (total attachments), havecount, needcount, missingList --->
<cfset docs=#AttachmentStatus(id_ara,id_cat)#>	
<cfinclude template="dsp_messages.cfm">
<cfinclude template="../../model/m_ara/qry_contract.cfm">

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
<a href="index.cfm?fuseaction=app.RejectForm&id_status=#id_status#&thiscycle=#val(revision+1)#&divshow=View&id_ara=#id_ara#&returnTo=Contracts" id="hidden_link" style="display:none;"></a>
</cfoutput>
<!--- +++++++++++++++++++++ END OF REJECT FANCY BOX +++++++++++++++++++++  --->

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
<a href="index.cfm?fuseaction=app.ARA_Docs_include&AID=#AID#&id_cat=#id_cat#&id_status=#id_status#&who=CM&id_contract=#id_contract#&returnTo=Contracts" id="hidden_link2" style="display:none;"></a>
</cfoutput>
<!--- +++++++++++++++++++++ END OF UPLOAD DOC FANCY BOX +++++++++++++++++++++  --->

<!--- Negate --->
<!---<cfif isDefined('url.Negate') and (url.Negate EQ "Yes")>
<cfquery name="CMnegate" datasource="#Application.dsn#">
	update ara set id_status = 14 where id_ara = #id_ara#
</cfquery>
<!--- update audit trail --->
<cfset negate = "">
</cfif>
<cflocation url="index.cfm?fuseaction=app.ARA_ContractInfo&AID=#AID#">--->
<!--- end of Negate--->


<!--- If in contract, or rejected and this person is the contract manager, they will see form. Otherwise view only --->
<!--- cfif (FormorView EQ "Form")  AND (ListFind('2,8,9',id_status)) 
      and ((ID_contract EQ session.id_user) OR (FindnoCase(id_contract,session.delegators))) --->
	  

<cfif (FormorView EQ "Form")  AND (id_status EQ 2) 
      and ((ID_contract EQ session.id_user) OR (FindnoCase(id_contract,session.delegators)))>

<cfparam name="PCCostAuth" default="0">
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

<script type="text/javascript">
function checkQuestions()
{
	
	if (document.getElementById('workAuthorization2').checked){
		document.getElementById('writtenConfirmation2').checked = true;
		document.getElementById('writtenConfirmationExplanation').value = 'Not Applicable';
		document.getElementById('authType').checked = true;		
		document.getElementById('Alion_conf').checked = true;
		document.getElementById('Alion_confExplanation').value = 'Not Applicable';
		document.getElementById('anticipatoryCost').checked = true;
		document.getElementById('anticipatoryCostExplanation').value = 'Not Applicable';
	}
	else{
		document.getElementById('writtenConfirmation2').checked = false;
		document.getElementById('writtenConfirmationExplanation').value = '';
		document.getElementById('authType').checked = false;		
		document.getElementById('Alion_conf').checked = false;
		document.getElementById('Alion_confExplanation').value = '';
		document.getElementById('anticipatoryCost').checked = false;
		document.getElementById('anticipatoryCostExplanation').value = '';
	}
}
</script>

<cfform name="ContractInfo" id="ContractInfo" method="Post" preservedata="True" enctype="multipart/form-data" action="?fuseaction=app.CM_submit&AID=#url.aid#">
<cfinput name="isSaved" id="isSaved" type="hidden" value="#isSaved#">
<cfoutput>

<input type="Hidden" name="revision" value="#revision#">
<input type="hidden" name="id_contract" value="#id_contract#">
<cfif isDefined('id_ara_cm')>
	<input type="hidden" name="id_ara_cm" value="#id_ara_cm#">
</cfif>

<cfset t=0>
<table width=100% class="outerborder"  cellpadding=2 cellspacing=2>
<cfif (id_cat NEQ 4) and (id_cat NEQ 1)>
<tr><!--           1                    -->
	<cfset t=t+1>
	<td class="qnum">#t#</td>
	<td nowrap class="border">Start Date Authorized by Customer</td>
	<td width=155 class="border">
	<input size=12 tabindex=1 class="date"  style="background-color: ##E2E8DB;font-family:verdana;font-size:11px;" value="#authStart#" name="authStart">
    </td>
</tr>   
<cfelse>
	<input type="hidden" value="#DateFormat(Now())# #TimeFormat(Now())#" name="authStart">
</cfif>
<tr>

	<!--           2                    -->
    <cfset t=t+1>
	<td class="qnum">#t#</td>
	<td class="border">Type of Customer</td>
	<td class="border">
	<cfquery name="custType" datasource="#application.dsn#">
		SELECT *
		FROM customerType
	</cfquery>
		
		<select tabindex=2 class="inputtext" name="id_customerType"  display="description" value="id_customerType">
		<option value="">--- Select Type --</option>
		<cfloop query="custType">
			<option value="#id_customerType#" <cfif thisCusttype EQ id_customerType>Selected</cfif>>#description#</option>
		</cfloop>
		</select>

</tr>

<tr><!--           3                    -->
	<cfif id_cat NEQ 4>
		<cfset t=t+1>
		<td class="qnum">#t#</td>
		<td  nowrap class="border">Expected Contract or Mod Execution Date</td>
		<td class="border" width=155>
		<input  size=12 class="date"  tabindex=3 style="background-color: ##E2E8DB;font-family:verdana;font-size:11px;"  name="executionDate" value="#executiondate#">
    <cfelse>
    	<input type="hidden" name="executionDate" value="#DateFormat(Now())# #TimeFormat(Now())#">
	</cfif>
	<cfset t=t+1>
	<td class="qnum">#t#</td><!--           4                    -->
	
	<td nowrap class="border">Contract Type
		<select tabindex=4 name="contractType" class="inputtext">
		<cfif id_cat NEQ 1><!--- Award Fees must be CPFF --->
		
			<option value="">--- Select ---</option>
			<option value="CPFF" <cfif ThisCtype EQ "CPFF">Selected</cfif>>CPFF</option>
			<option value="FFP" <cfif ThisCtype EQ "FFP">Selected</cfif>>FFP</option>
			<option value="T&M" <cfif ThisCtype EQ "T&M">Selected</cfif>>T&M</option>
			<option value="CP LOE" <cfif ThisCtype EQ "CP LOE">Selected</cfif>>CP LOE</option>
		<cfelse>
			<option value="">--- Select ---</option>
			<option value="CPFF" Selected>CPFF</option>
		</cfif>
		</select>
		</td>
		<td class="border" valign="bottom">
		<cfif id_cat NEQ 1>
		or, enter other:
		<input type="text"  class="inputtext" name="OtherType" size=20 maxlength="50" value="#otherType#">
		<cfelse>
		CPFF req'd for Award Fees
		<input type="text"  disabled class="disabled" name="OtherType" size=1 maxlength="1" value="#otherType#">
	    </cfif>
	
</tr>
<cfif NOT Find(id_cat,'1,4')>
<tr><!--           5                    -->
	<cfset t=t+1>
	<td class="qnum">#t#</td>
	<td  nowrap class="border"> Customer Procurement Official (PO) Contacted</td>
	<td class="border" width=155><input   tabindex=5 size=20 class="inputtext" type="text" name="customerPO" value="#customerPO#">
    <cfset t=t+1>
	<td class="qnum">#t#</td>
	<td class="border">Date PO Contacted</td>
	<td class="border"><input  size=12  tabindex=6 class="date"  style="background-color: ##E2E8DB;font-family:verdana;font-size:11px;" name="POContactDate" value="#pocontactDate#">
</tr>
<cfelse>
	<input type="hidden" name="customerPO" value="">
	<input type="hidden" name="POContactDate" value="">
</cfif>

<cfif id_cat EQ 10 or id_cat EQ 9>
<tr><!--           7                    -->
	<cfset t=t+1>
	<td class="qnum">#t#</td>
	<td  nowrap class="border">Pre-Contract Cost Authorized by Customer</td>
	<td class="border" colspan=4>
		$ <input  class="inputtext" tabindex=7 type="text" name="PCCostAuth" value="#PCCostAuth#" size=15>
	</td>
</tr>
<cfelse>
	<input type="hidden" name="PCCostAuth" value="0">
</cfif>
</table>

<table width=100% class="outerborder"  cellpadding=2 cellspacing=2>
<cfif NOT ListFind('1,4',id_cat)>
<cfset t=t+1>
<tr><!--           8                    -->
	<td class="qnum">#t#</td><!--- Not required for Award Fees and Internally Cleared --->
	<td  width=50% colspan=2 <cfif NOT ListFind('1,4',id_cat)>class="border"<cfelse>class="grey"</cfif> >
	Has the customer set aside <b>enough funds</b> to support the work?</td>
	<td nowrap width=50% colspan=2 class="border">
		<input   tabindex=8 type="radio"  name="fundsToSupport" <cfif fundstoSupport EQ 1>Checked</cfif> value="1">&nbsp;Yes&nbsp;
		<input   type="radio"  name="fundsToSupport" <cfif fundstoSupport EQ 2>Checked</cfif> value="2">&nbsp;No&nbsp;
		If no explain:&nbsp;&nbsp;
		<input name="fundsExplanation" value="#fundsExplanation#" class="inputtext" type="text" size=35 maxlength=70>
	</td>
</tr>
<cfelse>
	<input name="fundsExplanation" type="hidden" value="">
</cfif>

<cfif id_cat EQ 6>
<cfset t=t+1>
<tr><!--           9                    -->
	<td class="qnum">#t#</td><!--- Only Required for cat 6 commercial --->
	<td colspan=2 class="border"> If the customer is commercial, has a <b>credit check</b> been completed?</td>
	<td nowrap colspan=2 class="border">
	 <!--- Question asked for commercial accounts only --->
		<input   type="radio"  name="creditCheck" value="1" <cfif creditcheck EQ 1>Checked</cfif>>&nbsp;Yes&nbsp;
		<input   type="radio"  name="creditCheck" value="2" <cfif creditcheck eq 2>Checked</cfif>>&nbsp;No&nbsp;
		<input   type="radio"  name="creditCheck" value="3" <cfif creditcheck eq 3>Checked</cfif>>&nbsp;N/A&nbsp;
		If no explain:&nbsp;&nbsp;
		<input name="creditExplanation" value="#creditexplanation#" class="inputtext" type="text" size=35 maxlength=70>
	</td>
</tr>
<cfelse>
<input name="creditExplanation" type="hidden" value="">
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<cfset t=t+1>
<tr><!--          10                    --><!--- Not required for Award Fees and Internally Cleared --->
	<td class="qnum">#t#</td>
	<td colspan=2 class="border">
	Does a contract, modification, or purchase request for the work to be performed have all the necessary <b>customer approvals</b>?</td>
	<td colspan=2 class="border">
		<input   type="radio"  name="allApprovals" value="1" <cfif allApprovals eq 1>Checked</cfif>>&nbsp;Yes&nbsp;
		<input   type="radio"  name="allApprovals" value="2" <cfif allapprovals eq 2>Checked</cfif>>&nbsp;No&nbsp;
		If no explain:&nbsp;&nbsp;
		<input name="allApprovalsExplanation" value="#allApprovalsExplanation#" class="inputtext" type="text" size=35 maxlength=70>
	</td>
</tr>
<cfelse>
	<input name="allApprovalsExplanation" type="hidden" value="">
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<cfset t=t+1>
<tr><!--           11                    -->
	<td class="qnum">#t#</td>
	<td colspan=2 class="border">
	Has it been <b>forwarded</b> to the customer's contracts or purchasing department for action?</td>
	<td colspan=2 class="border">
		<input   type="radio"  name="forwarded" value="1" <cfif forwarded eq 1>Checked</cfif>>&nbsp;Yes&nbsp;
		<input   type="radio"  name="forwarded" value="2" <cfif forwarded eq 2>Checked</cfif>>&nbsp;No&nbsp;
		If no explain:&nbsp;&nbsp;
		<input name="forwardedExplanation"  value="#forwardedExplanation#" class="inputtext" type="text" size=35 maxlength=70>
	</td>
</tr>
<cfelse>
<input name="forwardedExplanation" type="hidden" value="">
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<cfset t=t+1>
<tr><!--           12                    -->
	<td class="qnum">#t#</td>
	<td colspan=2 class="border">
	Has an individual authorized to contractually bind the customer given <b>authorization to commence work</b>?</td>
	<td colspan=2 class="border">
		<input   type="radio"  name="workAuthorization" value="1" id="workAuthorization1" <cfif workauthorization eq 1>checked</cfif> onclick="checkQuestions();">&nbsp;Yes&nbsp;
		<input   type="radio"  name="workAuthorization" value="2" id="workAuthorization2" <cfif workauthorization eq 2>checked</cfif> onclick="checkQuestions();">&nbsp;No&nbsp;
		If no explain:&nbsp;&nbsp;
		<input id="workAuthorizationExplanation" name="workAuthorizationExplanation" value="#workAuthorizationExplanation#" class="inputtext" type="text" size=35 maxlength=70>
	</td>
</tr>
<cfelse>
<input name="workAuthorizationExplanation" type="hidden" value="">
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<cfset t=t+1>
<tr><!--           13                    -->
	<td class="qnum">#t#</td>
	<td colspan=2 class="border">Type of Authorization</td>
	<td colspan=2 class="border">
		<input   type="radio"  name="authType" value="Written" <cfif authtype EQ "Written">checked</cfif>>&nbsp;Written&nbsp;
		<input   type="radio"  name="authType" value="Verbal" <cfif authtype EQ "Verbal">checked</cfif>>&nbsp;Verbal&nbsp;	
        <input   type="radio" id="authType"  name="authType" value="N/A" <cfif authtype EQ "N/A">checked</cfif>>&nbsp;N/A&nbsp;		
	</td>
</tr>
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<cfset t=t+1>
<tr><!--           14                    -->
	<td class="qnum">#t#</td>
	<td colspan=2 class="border">
	Has a written <b>confirmation been mailed by HII</b> to the customer?</td>
	<td colspan=2 class="border">
		<input   type="radio" id="writtenConfirmation1"  name="writtenConfirmation" value="1" <cfif writtenConfirmation EQ 1>Checked</cfif>>&nbsp;Yes&nbsp;
		<input   type="radio" id="writtenConfirmation2" name="writtenConfirmation" value="2" <cfif writtenConfirmation EQ 2>Checked</cfif>>&nbsp;No&nbsp; 
		If no explain:&nbsp;&nbsp;
		<input name="writtenConfirmationExplanation" id="writtenConfirmationExplanation" value="#writtenConfirmationExplanation#" class="inputtext" type="text" size=35 maxlength=70>
	</td>
</tr>
<cfelse>
<input name="writtenConfirmationExplanation" type="hidden" value="">
</cfif>


<cfif NOT ListFind('1,4',id_cat)>
<cfset t=t+1>
<tr><!--           15                    -->
	<td class="qnum">#t#</td>
	<td colspan=2 class="border">
	Has a written <b>confirmation been mailed by customer</b>?</td>
	<td colspan=2 class="border">
		<input   type="radio"  name="Alion_conf" value="1" <cfif Alion_conf EQ 1>Checked</cfif>>&nbsp;Yes&nbsp;
		<input   type="radio" id="Alion_conf" name="Alion_conf" value="2" <cfif Alion_conf EQ 2>Checked</cfif>>&nbsp;No&nbsp; 
		If no explain:&nbsp;&nbsp;
		<input id="Alion_confExplanation" name="Alion_confExplanation"  value="#Alion_confExplanation#" class="inputtext" type="text" size=35 maxlength=70>		
	</td>
</tr>
<cfelse>
<input name="Alion_confExplanation" type="hidden" value="">
</cfif>


<cfif NOT ListFind('1,4',id_cat)>
<cfset t=t+1>
<tr><!--           16                    -->
	<td class="qnum">#t#</td>
	<td colspan=2 class="border">
	Does the authorization confirm that the contract, modification, or purchase order <b>will include anticipatory costs</b> or, if required, an effective date which coincides with HII's commencement or continuance of work?</td>
	
	<td colspan=2 class="border">
		
		<input type="radio"  name="anticipatoryCost" value="1" <cfif anticipatoryCost EQ 1>Checked</cfif>>&nbsp;Yes&nbsp;
		<input   type="radio"  name="anticipatoryCost" value="2" <cfif anticipatoryCost EQ 2>Checked</cfif>>&nbsp;No&nbsp;
		<input   type="radio" id="anticipatoryCost"  name="anticipatoryCost" value="3" <cfif anticipatoryCost EQ 3>Checked</cfif>>&nbsp;N/A&nbsp;
	If no explain:&nbsp;&nbsp;
		<input name="anticipatoryCostExplanation" id="anticipatoryCostExplanation"  value="#anticipatoryCostExplanation#" class="inputtext" type="text" size=20 maxlength=70>
	</td>
</tr>
<cfelse>
<input type="hidden"  name="anticipatoryCost" value="0">
<input name="anticipatoryCostExplanation" type="hidden" value="">
</cfif>

<cfif id_cat NEQ 4>
<cfset t=t+1>
<tr><!--           17                    -->
	<td class="qnum">#t#</td>
	<td colspan=2 width=415 class="border">
	 Anticipated Negotiation Date
	</td>
	<td colspan=2 width=391 class="border">
		
		<cfif #dateformat(anticipatedNegotiation,"YY")# EQ "00">
			<cfset anticipatedNegotiation="">
		</cfif>
		<input size=12 class="date" type="text"  style="background-color: ##E2E8DB;font-size:11px;font-family:verdana;" name="anticipatedNegotiation" id="anticipatedNegotiation"  value="#anticipatedNegotiation#">
   </td>
</tr>
<cfelse>
<input name="anticipatedNegotiation" type="hidden" value="">
</cfif>

<!--- doc upload questions --->
<cfif id_cat EQ 1>
<cfset t=t+1>
<tr>
	<td class="qnum">#t#</td>
	<td colspan=2 width=415 class="border">POP of current Award Fee Period</td>
	<td colspan=2 width=391 class="border">From: 
		<cfinput size=12 type="text" class="date" style="background-color: ##E2E8DB;font-size:11px;font-family:verdana;" name="pop" value="#dateformat(GetCM.pop, 'mm/dd/yyyy')#" required="yes" message="POP From Date of current Award Fee Period is required for this category">&nbsp;&nbsp; To:
        <cfinput size=12 type="text" class="date" style="background-color: ##E2E8DB;font-size:11px;font-family:verdana;" name="pop2" value="#dateformat(GetCM.pop2, 'mm/dd/yyyy')#" required="yes" message="POP To Date of current Award Fee Period is required for this category">
   </td>
</tr>
<cfelse>
	<input name="pop" type="hidden" value="">
    <input name="pop2" type="hidden" value="">
</cfif>

<cfif id_cat EQ 1>
<cfset t=t+1>
<tr>
	<td class="qnum">#t#</td>
	<td colspan=2 width=415 class="border">Award fee pool amount for total contract or Delivery Order. If shared, maximum HII share of award fee pool.</td>
	<td colspan=2 width=391 class="border">
		<cfinput size=12 type="text"  style="background-color: ##E2E8DB;font-size:11px;font-family:verdana;" validate="float" name="poolAmt" value="#poolAmt#" required="yes" message="Award fee pool amount is required for this category">
   </td>
</tr>
<cfelse>
	<input name="poolAmt" type="hidden" value="0">
</cfif>


<cfif id_cat EQ 1>
<cfset t=t+1>
<tr>
	<td class="qnum">#t#</td>
	<td colspan=2 width=415 class="border">Estimated funding date for award fee decision based on most recent fee award.</td>
	<td colspan=2 width=391 class="border">
		<cfinput size=12 class="date" type="text" required="yes" Message="Estimated Funding Date Required" style="background-color: ##E2E8DB;font-size:11px;font-family:verdana;" name="estFunDate" value="#estFunDate#">
   </td>
</tr>
<cfelse>
	<input name="estFunDate" type="hidden" value="#dateformat(now(), 'mm/dd/yyyy')#">
</cfif>

<cfif id_cat EQ 4>
<cfset t=t+1>
<tr>
	<td class="qnum">#t#</td>
	<td colspan=2 width=415 class="border">Internally Cleared Completion Date</td>
	<td colspan=2 width=391 class="border">		
		<cfif #dateformat(intClearCompDate,"YY")# EQ "00">
			<cfset intClearCompDate="">
		</cfif>
		<input size=12 class="date" type="text"  style="background-color: ##E2E8DB;font-size:11px;font-family:verdana;" name="intClearCompDate"  value="#intClearCompDate#">
   </td>
</tr>
<cfelse>
<input name="intClearCompDate" type="hidden" value="#dateformat(now(), 'mm/dd/yyyy')#">
</cfif>
</cfoutput>

</table>
<table cellpadding=2 cellspacing=2 class="outerborder" width=100%>
<!----   uuuuuuuuuuuuuuuuuuuuuuuuu Show Uploaded Documents uuuuuuuuuuuuuuuuuuuuuuuuuuuuu   --->
<tr>	
	<td valign="top" width="353" class="border">
	<b>Required Contract Administrator Document(s)</b>
	<td valign="top"  class="border"><!--- list what is required --->
	<div id="docdesc">
		<cfif docTypes.recordcount GT 0>
			<cfloop query="docTypes">
			<cfif find(ID_attachtype,MissingList)>
				<img src="images/SmGreyMinus.png">&nbsp;<cfoutput>#short_desc#</cfoutput> (Need) 
				<img style="vertical-align: bottom;padding-left:5px;padding-right:5px;" src="images/tooltip-icon.png" 
		title="<cfoutput><b>#Short_Desc#</b><br>#Long_desc#</cfoutput>"><br>
			<cfelse>
				<img src="images/SmCheck.png">&nbsp;&nbsp;<cfoutput>#short_desc#</cfoutput> (Have)
				<img style="vertical-align: bottom;padding-left:5px;padding-right:5px;" src="images/tooltip-icon.png" 
		title="<cfoutput><b>#Short_Desc#</b><br>#Long_desc#</cfoutput>"> <br>
			</cfif>
			
			</cfloop>
		<cfelse>
			There are no required uploads.
		</cfif>
	</div>	
	</td>
</tr>

<tr>
	<td colspan=2 class="border">
	<cfset returnTo="contracts">
	<cfinclude template="_docList.cfm">
	</td>
</tr>
<cfoutput>

<tr>
	<td class="border" colspan=5 align="center">
		<table cellpadding=2 cellspacing=0 border=0>
		<tr>
		<td valign="top">
		<input class="button" type="submit" id="SaveCM" name="saveCM" value="Save" onclick="return minReqd();">
		</td>
		<td valign="top">
		<!--- If people start putting in form data, we wnt them to save before hitting upload. So we disable that button
		      if they put form info in --->
			  
		<script type="text/javascript">
		function check()
			{
				$("##Upload").removeClass('button');
				$("##Upload").css({'font-family': 'verdana', 'font-size': '11px','color': '##000000'});
				$("##Upload").val("Save form before document upload");
				$("##Upload").attr("disabled", true);
				$("##isSaved").val(0);
			}
		</script>
  
		<!--- uuuuuuuuuuuuuuuuuuuu UPLOAD BUTTON uuuuuuuuuuuuuuuuuuu  --->
		<!--- if any changes are made to the form, will set this button value to:
		      Save form before you upload, and disable this button --->
		<input  class="button" type="button" id="Upload" name="Upload" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.ARA_ContractInfo&id_ara=#id_ara#&AID=#AID#&Upload=Yes&id_contract=#id_contract#';" value="Upload Documents">
	
		<!--- uuuuuuuuuuuuuuuuuuuu END UPLoad Button uuuuuuuuuuuuuuuuuuu  --->
		</td>
		<td valign="top">
	<!--- If we have all the documents we need the submit is enabled, otherwise it is not --->
	
	<cfif NeedCount GT 0 and id_cat NEQ 4><!--- HaveList,NeedList,HaveCount, NeedCount are in qry_attachmentstatus --->
	
		<input type="button" disabled style="width:265px;color:##000000;font-family:verdana;font-size:11px;" value="Submit for Approval after Document Upload">
	<cfelse>
		<input class="button" type="submit" value="Submit for Next Approval." onClick="return validateForm();">&nbsp;
	</cfif>
		</td></tr></table>
        

</tr>
</table>
</cfoutput>
</cfform>



<cfinclude template="../../model/m_forms/js_contractTab.cfm"><!--- form validation on submit --->

       
<form name="Reject"  id="Reject" method="Post" preservedata="True" enctype="multipart/form-data" action="">
<table border="0" align="center">
<tr>
	<td align="center">
		<cfoutput><input class="reject_btn" type="button" value="&nbsp;&nbsp;REJECT ARA" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.ARA_ContractInfo&aid=#aid#&id_status=#id_status#&Reject=Yes&thiscycle=#val(revision+1)#&divshow=View&id_ara=#id_ara#&returnTo=Contracts';">
		</cfoutput>
	</td></tr>
</table>
</form> 
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
<cfelse>
	<!--- The current state of this ARA is: <cfoutput><b>#StatusName#</b></cfoutput><br --->
	<cfinclude template="dsp_ARA_contractInfo_View.cfm">
</cfif>
<!---
<cfoutput>
<cfinclude template="dsp_docList.cfm">

</cfoutput>--->