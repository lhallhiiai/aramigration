<script language="Javascript" type="text/JavaScript">
/*         The minimum Req'd fields to start the save process         */
function minReqd() {
var errMsgHdr = "The following fields must be completed to SAVE the contract:\n\n";
var errMsgs = "";
/*               id_customerType            */
	if (OptionSelected(document.forms.ContractInfo.id_customerType) <= 0) {
		errMsgs = errMsgs + "Customer Type must be selected\n";
	}
/*               contractType            */
	if ((isWhitespace(document.forms.ContractInfo.OtherType.value)) && (OptionSelected(document.forms.ContractInfo.contractType) <=0)) {
		errMsgs = errMsgs + "Select contract type or enter other type\n";
	}	
	
if (!isEmpty(errMsgs)) {
		alert(errMsgHdr + errMsgs);
		return false;
	} else {
		return true;
	}
}


/* Validates complete form before submittal for next level of approval */
function validateForm() {

var errMsgHdr = "Please correct the following errors and resubmit:\n\n";
var errMsgs = "";

<cfif (id_cat NEQ 4) and (id_cat NEQ 1)>
/*               authStart            */
	if (isWhitespace(document.forms.ContractInfo.authStart.value)) {
		errMsgs = errMsgs + "Authorized Start Date is Required\n";
	}
	else
		{
		if (ForceDate(document.forms.ContractInfo.authStart.value)) {
			errMsgs = errMsgs + "Date needs to be in the form of mm/dd/yy or mm/dd/yyyy.\n";
		}
	}
</cfif>
/*               id_customerType            */
	if (OptionSelected(document.forms.ContractInfo.id_customerType) <= 0) {
		errMsgs = errMsgs + "Customer Type must be selected\n";
	}
<cfif id_cat NEQ 4>
/*               executionDate            */
	if (isWhitespace(document.forms.ContractInfo.executionDate.value)) {
		errMsgs = errMsgs + "Expected Execution date is Required\n";
	}
	else
		{
		if (ForceDate(document.forms.ContractInfo.executionDate.value)) {
			errMsgs = errMsgs + "Execution date needs to be in the form of mm/dd/yy or mm/dd/yyyy.\n";
		}
	}
</cfif>
/*               contractType            */
	if ((isWhitespace(document.forms.ContractInfo.OtherType.value)) && (OptionSelected(document.forms.ContractInfo.contractType) <=0)) {
		errMsgs = errMsgs + "Select contract type or enter other type\n";
	}
<cfif NOT Find(id_cat,'1,4')>	
/*               customerPO            */
	if (isWhitespace(document.forms.ContractInfo.customerPO.value)) {
		errMsgs = errMsgs + "Enter name of procurement officer.\n";
	}
	
/*               POContactDate            */
	if (isWhitespace(document.forms.ContractInfo.POContactDate.value)) {
		errMsgs = errMsgs + "PO contacted date is required\n";
	}
	else
		{
		if (ForceDate(document.forms.ContractInfo.executionDate.value)) {
			errMsgs = errMsgs + "PO contact date needs to be in the form of mm/dd/yy or mm/dd/yyyy.\n";
		}
	}
</cfif>


<cfif id_cat EQ 10>
/*               PCCostAuth            */
	if (isWhitespace(document.forms.ContractInfo.PCCostAuth.value)) {
		errMsgs = errMsgs + "Enter numeric cost authorized by customer\n";
	}
	else
	  {
	  if (!isNumber(document.forms.ContractInfo.PCCostAuth)) {
	  	errMsgs= errMsgs + "Authorized cost is an invalid number\n";
	  }
	}
</cfif>


<cfif id_cat EQ 1>
	if (isWhitespace(document.forms.ContractInfo.pop.value)) {
		errMsgs = errMsgs + "POP of current Award Fee Period is required\n";
	}

	if (isWhitespace(document.forms.ContractInfo.poolAmt.value)) {
		errMsgs = errMsgs + "Award fee pool amount is required\n";
	}
</cfif>
	/* Next question Removed 
	if (isWhitespace(document.forms.ContractInfo.estFundDate.value)) {
		errMsgs = errMsgs + "Estimated funding date for award fee is required\n";
	}
	*/

<cfif id_cat EQ 4>
	if (isWhitespace(document.forms.ContractInfo.intClearCompDate.value)) {
		errMsgs = errMsgs + "Internally Cleared Completion Date is required\n";
	}
</cfif>
/*              Bottom Half of Form                     */

<cfif NOT ListFind('1,4',id_cat)><!--- Not Reqd for Award Fees or Internally Cleared --->
/*               8: fundsToSupport            */
if (!isObjChecked(document.forms.ContractInfo.fundsToSupport)) {

	                errMsgs = errMsgs + "Yes or No: Does customer have enough funds\n";
	
	} else if (get_radio_value(document.forms.ContractInfo.fundsToSupport) == "2") {
	

	                if (isWhitespace(document.forms.ContractInfo.fundsExplanation.value)) {
	
	                errMsgs = errMsgs + "Explain why customer does not have enough funds\n";
	
	                }
	
	}
</cfif>
<cfif id_cat eq 6>	
/*               9: creditCheck            */
if (!isObjChecked(document.forms.ContractInfo.creditCheck)) {

	                errMsgs = errMsgs + "Yes, No, or N/A: Commercial customer credit check\n";
	
	} else if (get_radio_value(document.forms.ContractInfo.creditCheck) == "2") {

	                if (isWhitespace(document.forms.ContractInfo.creditExplanation.value)) {
	
	                errMsgs = errMsgs + "Explain why customer did not have credit check\n";
	
	                }
	
	}
</cfif>

/*               10: allApprovals            */
<cfif NOT ListFind('1,4',id_cat)><!--- Not Reqd for Award Fees or Internally Cleared --->
if (!isObjChecked(document.forms.ContractInfo.allApprovals)) {

	                errMsgs = errMsgs + "Yes or No: Does this have necessary customer approvals\n";
	
	} else if (get_radio_value(document.forms.ContractInfo.allApprovals) == "2") {

	                if (isWhitespace(document.forms.ContractInfo.allApprovalsExplanation.value)) {
	
	                errMsgs = errMsgs + "Explain why all necessary customer approvals have not been obtained\n";
	
	                }
	
	}
</cfif>
	/*               11: forwarded            */
<cfif NOT ListFind('1,4',id_cat)>
if (!isObjChecked(document.forms.ContractInfo.forwarded)) {

	                errMsgs = errMsgs + "Yes or No: Has this been forwarded to the customer contracts department\n";
	
	} else if (get_radio_value(document.forms.ContractInfo.forwarded) == "2") {

	                if (isWhitespace(document.forms.ContractInfo.forwardedExplanation.value)) {
	
	                errMsgs = errMsgs + "Explain why it has not been forwarded to customer contracts\n";
	
	                }
	
	}
</cfif>	
/*               12: workAuthorization            */
<cfif NOT ListFind('1,4',id_cat)>
if (!isObjChecked(document.forms.ContractInfo.workAuthorization)) {

	                errMsgs = errMsgs + "Yes or No: Has an individual authorized the work.\n";
	
	} else if (get_radio_value(document.forms.ContractInfo.workAuthorization) == "2") {

	                if (isWhitespace(document.forms.ContractInfo.workAuthorizationExplanation.value)) {
	
	                errMsgs = errMsgs + "Explain why an individual has not authorized work.\n";
	
	                }
	
	}
</cfif>	
/*               13: authType            */
<cfif NOT ListFind('1,4',id_cat)>
if (!isObjChecked(document.forms.ContractInfo.authType)) {

	                errMsgs = errMsgs + "Please indicate an authorization type.\n";
	
	}
	
</cfif>
/*               14: writtenConfirmation         */
<cfif NOT ListFind('1,4',id_cat)>
if (!isObjChecked(document.forms.ContractInfo.writtenConfirmation)) {

	                errMsgs = errMsgs + "Yes or No: Has an written confirmation been mailed to customer?\n";
	
	} else if (get_radio_value(document.forms.ContractInfo.writtenConfirmation) == "2") {

	                if (isWhitespace(document.forms.ContractInfo.writtenConfirmationExplanation.value)) {
	
	                errMsgs = errMsgs + "Explain why confirmation has not been sent.\n";
	
	                }
	
	}
</cfif>
/*               15: Alion_conf         */
<cfif NOT ListFind('1,4',id_cat)>
if (!isObjChecked(document.forms.ContractInfo.Alion_conf)) {

	                errMsgs = errMsgs + "Yes or No: Has an written confirmation been mailed by customer?\n";
	
	} else if (get_radio_value(document.forms.ContractInfo.Alion_conf) == "2") {

	                if (isWhitespace(document.forms.ContractInfo.Alion_confExplanation.value)) {
	
	                errMsgs = errMsgs + "Explain why confirmation has not been mailed by customer.\n";
	
	                }
	
	}
</cfif>

/*               16: anticipatoryCost         */
<cfif id_cat NEQ 1 and id_cat NEQ 4>
if (!isObjChecked(document.forms.ContractInfo.anticipatoryCost)) {

	                errMsgs = errMsgs + "Will authorization include anticipatory costs?\n";
	
	} else if (get_radio_value(document.forms.ContractInfo.anticipatoryCost) == "2") {

	                if (isWhitespace(document.forms.ContractInfo.anticipatoryCostExplanation.value)) {
	
	                errMsgs = errMsgs + "Explain the answer no to anticipatory costs.\n";
	
	                }
	
	}
</cfif>

/*               anticipatedNegotiation            */

<cfif id_cat NEQ 1 and id_cat NEQ 4>
	if (isWhitespace(document.forms.ContractInfo.anticipatedNegotiation.value)) {
		errMsgs = errMsgs + "Anticipated negotiation date is required\n";
	}
	else
		{
		if (ForceDate(document.forms.ContractInfo.anticipatedNegotiation.value)) {
			errMsgs = errMsgs + "Anticipated negotiation date needs to be in the form of mm/dd/yy or mm/dd/yyyy.\n";
		}
	}
	
</cfif>
if (!isEmpty(errMsgs)) {
		alert(errMsgHdr + errMsgs);
		return false;
	} else {
		return true;
	}
}
</script>