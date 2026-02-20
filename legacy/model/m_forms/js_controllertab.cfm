<script language="Javascript">

function validateForm() {

var errMsgHdr = "Please correct the following errors and resubmit:\n\n";
var errMsgs = "";
	  if ((document.getElementById("company").checked == false) && (document.getElementById("company2").checked == false) && (document.getElementById("company3").checked == false) && (document.getElementById("company4").checked == false))
	{
	  errMsgs = errMsgs + "Select an HII company associated with this ARA.\n";
	  }

if (isWhitespace(document.forms.Controller.InterestImpact.value)) {
		errMsgs = errMsgs + "Enter interest impact to HII through receipt of payment \n";
	}
	
if (isWhitespace(document.forms.Controller.BurnRate.value)) {
		errMsgs = errMsgs + "Enter expected burn rate per two week period  \n";
	}
if (isWhitespace(document.forms.Controller.IcCost.value)) {
		errMsgs = errMsgs + "Enter incurred Cost not yet Billable  \n";
	}
if (isWhitespace(document.forms.Controller.ICfee.value)) {
		errMsgs = errMsgs + "Enter incurred Fee not yet Billable  \n";
	}
	alert('Finished Error Checking');
	if (!isEmpty(errMsgs)) {
		alert(errMsgHdr + errMsgs);
		return false;
	} else {
		alert('no errors found');
		return true;
	}
}
</script>