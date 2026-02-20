<!--- cfparam name="session.loggedIn" default="No" --->
<cfinclude template="inc_tooltipContent.cfm">
<cfparam name="message" default="">
<cfset submenu="">
<div id="ARASumm" style="margin:0px;">
<cfoutput>
<p class="smtitle">ARA CREATION</p>
<p class="title">Early Start</p>
<fieldset><legend><b>Warehouse / CostPoint  Derived Information</b></legend>
<table cellpadding=2 width=100% cellspacing=2 class="border">
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.sector#</cfoutput>">
	ARA Sector</td>
	<td class="border">CORS</td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.group#</cfoutput>">
	ARA Group
	</td>
	<td class="border">EXPA</td>
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
	Contract Administrator</td>
	<td class="border">Kim Pontillo
	</td></tr>
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.Controller#</cfoutput>">
	Controller</td>
	<td class="border">Jeff Acct
	</td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.sectorMgr#</cfoutput>">
	Sector Manager</td>
	<td class="border">Jim Sector
	</td>
</tr>

<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.groupMgr#</cfoutput>">
	Group Manager</td>
	<td class="border">Sue Sparks
	</td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.divisionMgr#</cfoutput>">
	Division Manger</td>
	<td class="border">Catherine Stick
	</td>
</tr>

</table>
</fieldset>
<fieldset><legend><b>PM Supplied Information</b></legend>
<cfform>
<table cellpadding=2 width=100% cellspacing=2 class="border">
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.status#</cfoutput>">
	Status</td>
	<td class="border">Draft

	</td>
	<td class="border">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.amount#</cfoutput>">
	ARA Amount</td>
	<td class="border"><cfinput class="inputtext" name="ARA_amount" size=10 required="yes">
</tr>
<tr>
	<td class="border">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.riskCat#</cfoutput>">
	Risk Category</td>
	<td class="border">
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
	<td class="border">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.riskLevel#</cfoutput>">
	Risk Level</td>
	<td class="border">2 (determined by category selection)
</tr>


<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.jamisNoES#</cfoutput>">
	CostPoint Number</td>
	<td class="border">
		Early Start
	</td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.ContractNoES#</cfoutput>">
	Contract Number</td>
	<td class="border">Early Start</td>
	
<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.contractTitle#</cfoutput>">
	Title</td>
	<td class="border">
		<cfinput type="text" name="title" maxlength=50 size=35 class="inputtext">
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.customer#</cfoutput>">
	Customer</td>
	<td class="border">
		<cfinput type="text" name="customerName" maxlength=50 size=35 class="inputtext">
</td>
</tr>


<tr>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.araID#</cfoutput>">
	ARA ID Number</td>
	<td class="border">1122 </td>
	<td class="borderq">
	<img class="question" src="images/tooltip-icon.png" title="<cfoutput>#tooltip.araRev#</cfoutput>">
	ARA Revision</td>
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
		<input name="button" class="button" type="submit" value="Create Early Start ARA">
	</td>
</tr>
</table>
</cfform>
<div id="ARASumm" style="margin:0px;">
</cfoutput>

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