<!--- **********************************************************  --->
<!---             ARA - RISK EVAULATION                           --->
<!--- ********************************************************** --->

<cfform name="RiskEval"  method="Post"   preservedata="True" enctype="multipart/form-data" action=""><table cellpadding=2 cellspacing=2 class="border">
<!---              Question 1                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">1.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top">
		Why is it necessary for HII to risk funds in advance of contract
		or modification receipt?
		</td></tr></table>
		</td>
	<td valign="top">
	<cftextarea name="FundsInAdvance" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>
<!---              Question 2                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">2.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top">What is currently being done to ensure contract definitization on the expected contract or modification execution date?
		</td></tr></table>
	</td>
	<td valign="top">
	<cftextarea name="ContractDefinization" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>

<!---              Question 3                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">3.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top">What other pertinent information is available to aid in evaluating this request for at risk approval? Are there any special
	or unusual circumstances?
		</td></tr></table>
	</td>
	<td valign="top">
	<cftextarea name="pertinentInformation" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>

<!---              Question 4                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">4.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top">If work was started prior to presenting the request for management approval, explain why?
		</td></tr></table>
	</td>
	<td valign="top">
	<cftextarea name="workStarted" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>

<!---              Question 5                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">5.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top">What is the consquence of not commencing work in advance of a signed contract or modification?
		</td></tr></table>
	</td>
	<td valign="top">
	<cftextarea name="Consequence" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>

<!---              Question 6                --->
<tr>
	<td valign="top" class="border">
	<table width=100% cellpadding=0 cellspacing=0>
		<tr>
		<td valign="top">6.&nbsp;&nbsp;&nbsp;</td>
		<td valign="top">What is the current status of the anticipated contractual coverage?
		</td></tr></table>
	</td>
	<td valign="top">
	<cftextarea name="currentStatus" rows=3 cols=80 class="inputtext"></cftextarea>
	</td>
</tr>

<tr>
	<td colspan=2 align="center">
	<input type="submit" value="Save Risk Evaluation">
	<input type="submit" value="Sign & Submit">
</table>
</cfform>