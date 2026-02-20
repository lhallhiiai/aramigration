<!--- cfparam name="session.loggedIn" default="No" --->
<cfinclude template="inc_tooltipContent.cfm">
<cfparam name="message" default="">
<cfparam name="alion_org" default="">
<cfparam name="pagetitle" default="Create an ARA">
<cfset menu="ARA_Sum">
<cfset submenu="">
<div id="ARASumm" style="margin:0px;">

<script>
  $(document).ready(function(){
              $("#alion_org").autocomplete("index.cfm?fuseaction=app.OrgAutoComplete&<cfoutput>grp=#session.group#</cfoutput>",
                {
                                minChars:2,
                                delay:200,
                                extraParams: {limit:100}, 
                                autoFill:false,
                                matchSubset:true,
                                matchContains:1,
                                cacheLength:100,
                                selectOnly:1
                });
                $("#alion_org").result(function(event,data)
                {
                                var tmp = data[0].split(" [");
                                var name = tmp[0];
                                /* var oprid = tmp[1].replace("]",""); */
                               /* $("#alion_org").val(alion_org); */
                });

                $("input[name='Sector']").change(function() {
                	$('input#alion_org').flushCache();
                });
				$("#OMSNum").autocomplete("index.cfm?fuseaction=app.omsAutoComplete",
                {
                                minChars:2,
                                delay:200,
                                extraParams: {limit:100}, 
                                autoFill:false,
                                matchSubset:true,
                                matchContains:1,
                                cacheLength:100,
                                selectOnly:1
                });
				
				$("#JNumber").autocomplete("index.cfm?fuseaction=app.jamisNoAutoComplete",
                {
                                minChars:2,
                                delay:200,
                                extraParams: {limit:100}, 
                                autoFill:false,
                                matchSubset:true,
                                matchContains:1,
                                cacheLength:100,
                                selectOnly:1
                });
				

  });
 </script>
 
<script type="text/javascript">
$("document").ready(function() {

	$("#jamisDiv").hide("fast");
	$("#omsDiv").hide("fast");
});
</script>

<script type="text/javascript">
function this_cat ()
{	
	
   var cat=$("#id_cat").val();
   if (cat == 10) {        /* Selected Early start */
   		$("#jamisDiv").hide("normal");
		$("#omsDiv").show("normal");
   } else
   		{
		$("#omsDiv").hide("normal");
		$("#jamisDiv").show("normal");
	}
   if (cat == 4) {        /* Selected Internally Cleared */
		$("#eacDiv").show("normal");
		document.getElementById('isEACRadioNo').checked = false;
   } else
   		{
		$("#eacDiv").hide("normal");
		document.getElementById('isEACRadioNo').checked = true;
	}
}

</script>

<cfoutput>
<table cellpadding=0 cellspacing=0 width=95%>
<tr>
	<td>
<p class="smtitle">ARA Step 1</p>
<p class="title">#pagetitle# </cfoutput></p><cfoutput>

</td>
<td valign="top" width=50 align="right">
<img src="images/HelpIcon.gif" border=0 align="left" >&nbsp;<a class="embed" href="index.cfm?fuseaction=app.help&topic=CreateARAStep1">Help</a>
</td></tr></table>
<cfinclude template="dsp_messages.cfm">
<cfform name="AraStep1" id="AraStep1" action="?fuseaction=app.CreateARAStep2&Menu=ARA_Detail&whichtab=0" >

<table cellpadding=2 cellspacing=2 class="border">
<tr>
	<td width=150 valign="top" class="greyblue" align="right"><br><b>RISK CATEGORY</b>&nbsp;&nbsp;</td>

	<td  colspan=3 class="greyblue">
		<table cellpadding=0 width=100% cellspacing=0 border=0>
		<tr>
		<td valign="top">
		<cfquery name="riskCat" datasource="#application.dsn#">
			SELECT *
			FROM category
			where risklevel <> 0
			order by RiskLevel
		</cfquery>
		
		<select onChange="this_cat();" size="#riskCat.recordcount#"  class="inputtext" name="id_cat" id="id_cat">
			<cfloop query="riskCat">
				<option value="#Id_cat#">Risk Level: #RiskLevel# - #Catname#</option>
			</cfloop>
		</td>
		<td width=341 colspan=2 class="greyblue" valign="top">
		<p style="padding:0px 10px 10px 10px; color:##FFFFFF;">The Risk Category cannot be changed once the ARA is Created.<br><br>The Risk Category  determines follow-on
		form checks. To change the risk category cancel and recreate the ARA.  Click help above to get more information on the risk category.</p>
		</td></tr></table>
	</td>
</tr>

<tr>
	<td align="right" class="border" nowrap>Org Autocomplete <br>
	<font style="color:##999999; font-size:10px;">[enter 2 chars]<br>
	</td>
	<td colspan=3 class="border">
	<p style="color:##999999; font-size:10px;margin:5px;">Enter&nbsp;&nbsp; <b>GROUP</b>&nbsp;&nbsp;or&nbsp;&nbsp;<b>GROUP NAME</b></p>
	
<cfinput name="alion_org" id="alion_org" size=80 class="inputtext" maxlength=100>
<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.araorg#</cfoutput>">
	</td>
</tr>
<!--- Spending or Revenue --->

<tr>
	<td align="right" class="border">Revenue Recognition</td>
	<td colspan=3 valign="top" nowrap class="border">
	<cfquery name="Rev" datasource="#Application.dsn#">
		select * from revenueDescr
        where id_revenue=2
		order By ID_revenue
	</cfquery>
	<cfloop query="Rev">
		<input type="radio" name="Id_revenue" value="#ID_revenue#" checked>
		#Descr#&nbsp;&nbsp;&nbsp;
	</cfloop>
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.Revenue#</cfoutput>">
	</td>
</tr>

</table>
<div id="eacDiv" style="display:none">
<table cellpadding=2 cellspacing=3  class="borderNotop"  width=100%>
<tr>
	<td align="center" class="border">You have selected Internally Cleared Risk Category, is this ARA EAC-related?</td>
	<td valign="top" width="20%" align="center" nowrap class="border"><cfinput type="radio" id="isEACRadioNo" required="yes" message="Please indicate if this entry is EAC related" name="isEAC" value="No"> No </td>
    <td valign="top" width="20%" align="center" nowrap class="border"><cfinput type="radio" name="isEAC" id="isEACRadioYes" required="yes" message="Please indicate if this entry is EAC related" value="Yes"> Yes </td>
</tr>

</table>
</div>

<div id="jamisDiv"><!---            JAMIS                ---->
<table cellpadding=2 cellspacing=2  class="borderNotop"  width=100%>

<!--- Jamis Contract Only necesary when Category is not Early Start  --->
<tr>

	<td width=190 align="right" valign="bottom" class="border">Level 1 PROJECT ID Autocomplete
	</td>
	<td colspan=3 class="border">
	<p style="color:##999999; font-size:10px;margin:5px;">Enter&nbsp;&nbsp; <b>PROJECT ID &nbsp;&nbsp;</b> &nbsp;&nbsp;or&nbsp;&nbsp; <b>PROJECT NAME &nbsp;&nbsp;</b></p>
	<cfinput name="JNumber" id="JNumber" size=80 class="inputtext" maxlength=120><img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.jamisNoES#</cfoutput>">
	</td>

</tr>
</table>
</div>
<input type="hidden" name="OMSNum" id="OMSNum" value="0">
<!---<div id="omsDiv"><!---             OMS                ---->
		<!---<table cellpadding=2 cellspacing=2  width=100% class="borderNotop">
		<tr>
			<td width=190 class="border" align="right">OMS Number</td>
			<td  class="border">
				<cfinput class="inputtext" type="text" name="OMSNum" id="OMSNum"  size="100"><img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.OMSNo#</cfoutput>">
			</td>
			
		</tr>
		</table>--->
</div>--->

<table cellpadding=2 cellspacing=2  width=100%  class="borderNotop">
<tr>
	<td colspan=4  class="border" align="center">
		<!--- input type="button" class="button" value="Next" onClick="JavaScript: this.form.submit();" --->
		<input type="submit" class="button" value="Next" onClick="return validateForm()">
		&nbsp;&nbsp;
		<input type="button" class="button" value="Reset" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.CreateARAStep1&Menu=ARA_Sum';">
	</td>
</tr>

</table>

</cfform>
</cfoutput>
</div>
<!---                  FORM CHECKS                    --->

<script language="Javascript" type="text/JavaScript">
function validateForm() {
var errMsgHdr = "Please correct the following errors and resubmit:\n\n";
var errMsgs = "";
var errMsgs = "";

/*               Risk Category                               */
	if (OptionSelected(document.forms.AraStep1.id_cat) < 0) {
		errMsgs = errMsgs + "Risk Category must be selected\n";
	
	/*           If Early Start, need Jamis                             */
	} 
	
	if ((document.forms.AraStep1.id_cat.value)  < 10){
		if (isWhitespace(document.AraStep1.JNumber.value)) {
	                errMsgs = errMsgs + "Enter the existing CostPoint Number\n";
	
	                }
	}
	if ((document.forms.AraStep1.id_cat.value)  == 10) {
		if (isWhitespace(document.AraStep1.OMSNum.value)) {
	                errMsgs = errMsgs + "Early starts require an Opportunity Tracking System Number\n";
	
	                }
	}
/*           Organization                                      */

if (isWhitespace(document.forms.AraStep1.alion_org.value)) {
		errMsgs = errMsgs + "Enter the financially responsible organization.\n";
	}	
/*           Recognize Revenue                                 */  
	if (!isObjChecked(document.AraStep1.Id_revenue)) {

	                errMsgs = errMsgs + "Indicate the type of Revenue Recognition\n";
	}
	
          

if (!isEmpty(errMsgs)) {
		alert(errMsgHdr + errMsgs);
		return false;
	} else {
		return true;
	}
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