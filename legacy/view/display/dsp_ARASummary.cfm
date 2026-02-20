<!--- cfparam name="session.loggedIn" default="No" --->
<cfinclude template="inc_tooltipContent.cfm">
<cfparam name="message" default="">
<cfset menu="ARA_Sum">
<cfset submenu="">
<div id="ARASumm" style="margin:0px;">
<cfoutput>
<p class="smtitle">ARA CREATION</p>
<p class="title">Non-Early Start ARA
Create ARA</p>

<p class="title">
Creation Step 1: Retrieve CKIS Data</p>
<cfform>
<table cellpadding=0 cellspacing=2>
<tr>
<td valign="top">
	<table cellpadding=2 cellspacing=2 class="border">
		<tr>
			<td class="border"><img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.jamisNo#</cfoutput>">Enter Costpoint Project Number</td>
			<td class="border"><cfinput name="JamisNo" size=20></td>
		</tr>
		<tr>
			<td class="border" colspan=2 align="center">
			<input type="submit" value="Retrieve CKIS Info">
		</tr>
	</table>
</td>
<td width=20>&nbsp;&nbsp;</td>
<td><!-- sample autocomplete  -->
<p>Autocomplete for CKIS number would be handled thusly:<br>
	<img src="images/Autocomplete.gif">
	
</td>
</tr>
</table>
		
</cfform>



<p class="smtitle">Program Manager</p>
<p class="title">
Creation Step 2</p>
<cfform>	
<fieldset><legend><b>Warehouse / CostPoint Derived Information</b></legend>
<table cellpadding=2 width=100% cellspacing=2 class="border">
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.sector#</cfoutput>">
	ARA Sector
	
	</td><td class="border">CORS </td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.group#</cfoutput>">
	ARA Group
	
	</td><td class="border">EXPA </td>
</tr>
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.jamisNo#</cfoutput>">
	CostPoint Number
	</td>
	<td class="border">003800-00</td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.ContractNo#</cfoutput>">
	Contract Number
	</td>
	<td class="border">N00024-01-D-7023</td>
	
<tr>
	<td class="borderq"><img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.contractTitle#</cfoutput>">
Title
	</td>
	<td class="border">This is the title pulled from CKIS
	<td class="borderq"><img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.Customer#</cfoutput>">
	Customer
	</td>
	<td class="border">Nation Bureau of Investigation  (pulled from CKIS)</td>
</tr>
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.programMgr#</cfoutput>">
	Program Manager
	</td>
	<td class="border">John Smith
	</td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.contractMgr#</cfoutput>">
	Contract Administrator
	</td>
	<td class="border">Kim Pontillo
	</td></tr>
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.Controller#</cfoutput>">
	Controller
	</td>
	<td class="border">Jeff Accountguy
	</td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.sectorMgr#</cfoutput>">
	Sector Manager
	</td>
	<td class="border">Jim Sector
	</td>
</tr>

<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.groupMgr#</cfoutput>">
	Group Manager
	</td>
	<td class="border">Sue Sparks
	</td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.divisionMgr#</cfoutput>">
Division Manger
	</td>
	<td class="border">Catherine Stick
	</td>
</tr>

</table>
</fieldset>
<fieldset><legend><b>PM Supplied Information</b></legend>
<table cellpadding=2 width=100% cellspacing=2 class="border">
<tr>
	
	<td class="border" style="border-color:##854141;">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.riskCat#</cfoutput>">
	<font style="color:##854141;"><b>Risk Category</b></font> 
	</td>
	<td class="border" style="border-color:##854141;">
		<cfselect class="inputtext" name="id_cat">
			<option value="1"  selected>AWARD FEES</option>
			<option value="2">MOD PENDING (Incremental funding)</option>
			<option value="3">INTERNALLY CLEARED</option>
			<option value="4">COMMERCIAL AT-RISK - NON GOVERNMENT</option>
			<option value="5">CHANGE IN SCOPE</option>
			<option value="6">FIXED PRICE MOD</option>
			<option value="7">MOD PENDING</option>
			<option value="7">PRE-CONTRACT COSTS</option>
		</cfselect>
	</td>
	<td class="borderq" >
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.riskLevel#</cfoutput>">
	Risk Level</td>
	<td class="border">
	Assigned based on category.
</tr>
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.status#</cfoutput>">
	Status</td>
	<td class="border">

	Draft

	</td>
	<td class="border">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.amount#</cfoutput>">
	ARA Amount</td>
	<td class="border"><cfinput class="inputtext" name="ARA_amount" size=10 required="yes">
</tr>



<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.araID#</cfoutput>">
	ARA ID Number</td>
	<td class="border">1122 </td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.araRev#</cfoutput>">
	ARA Revision Number</td>
	<td class="border">0</td>
</tr>
<tr>
	<td class="border">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.reqStart#</cfoutput>">
	Required Start Date</td>
	<td class="border"><cfinput class="inputtext" name="req_start" size=15></td>
	<td class="border">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.expDate#</cfoutput>">
	Expiration Date</td>
	<td class="border"><cfinput class="inputtext" name="exp_date" size=15></td>
</tr>
</table>
</fieldset>
<!--- 
<tr>
	<td class="border">Rejection Reason</td>
	<td colspan=3 class="border">
	<textarea class="inputtext" cols=90 rows=3 name="Rejection_reason"></textarea>
	</td>
</tr>
--->
<table cellpadding=5 width=95% cellspacing=2>
<tr>
	<td colspan=4 align="center" >
		<input name="button" class="button" type="submit" value="Create ARA">
	</td>
</tr>
</table>
</cfform>
</cfoutput>
</div>

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