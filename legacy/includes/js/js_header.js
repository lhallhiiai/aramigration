
<!--
// klc 10/11/07: replaced placeFocus with one that accepts arguments to fix CheckOrder.cfm and SubscribeConfirmation.cfm cursor placement and tab control from going to login fields.
function placeFocus(formName, fieldName) {

	var formName = formName;
	var fieldName = fieldName;

	if ((formName != null) && (fieldName != null) && (formName.length > 0) && (fieldName.length > 0)) {
		document.forms[formName].elements[fieldName].focus();
	}
	else if (document.forms.length > 0) {
	  	var field = document.forms[0];
		for (i = 0; i < field.length; i++) {
			if ((field.elements[i].type == "text") || (field.elements[i].type == "textarea") || (field.elements[i].type.toString().charAt(0) == "s")) {
				document.forms[0].elements[i].focus();
				break;
         	}
      	}
   	}	//end if 
}	//end function placeFocus

// KLC 07/30/08 - added popup window functions
var newwindow = '';

function popitup(url,title,controls)
{
	if (!newwindow.closed && newwindow.location)
	{
		newwindow.location.href = url;
	}
	else
	{
		newwindow=window.open(url,title,controls);
		if (!newwindow.opener) newwindow.opener = self;
	}
	if (window.focus) {newwindow.focus()}
	return false;
}
// -->
