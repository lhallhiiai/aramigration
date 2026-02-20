
<cfform>
<!-- 1  --><table width="100%" cellpadding=2 cellspacing=2 class="outerborder">
<tr>
	<td nowrap class="border">Total Funded Value Anticipated:
	</td>
	<td class="border"><cfinput class="inputtext" name="Total_anticipated" maxlength="20" size=20></td>
	<td class="border">Amount of Risk Funding Request:
	</td>
	<td class="border"><cfinput  class="inputtext" name="Risk_Requested" maxlength="20" size=20></td>
</tr>

<tr>
	<td class="border" nowrap>Percent of Funded Value Anticipated:
	</td>
	<td class="border">99% </td>
	<td class="border">Required Start Date:
	</td>
	<td class="border"><cfinput  class="inputtext" name="Req_start_Date" maxlength="20" size=20></td>
</tr>
<tr>
	<td class="greyblue" colspan=4>
	The next 2 questions only show if the ARA is an early start ARA
	</td>
</tr>
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
		<cfinput type="checkbox" name="ES_Necessary" value="Schedule">Meet Customer Schedules
		&nbsp;&nbsp;<cfinput type="checkbox" name="ES_Necessary" value="Coverage">Assure Continuity of Coverage<br>
		Other <cfinput class="inputtext" name="Other_necessary" size=50 >
	</td>
</tr>
<tr>
	<td valign="top" class="border">Program Manager Certification:</td>
	<td colspan=3 class="border">
		<cfinput type="dateField" name="PM_certified" mask="MM/DD/YYYY" class="inputtext" width="75">
	</td>
</tr>
<!-- 1  --></table>
<!-- 1  --><table width=100% class="outerborder" cellpadding=2 cellspacing=2>
<tr>
	<td class="greyblue" colspan=2>
	The next questions only show if the ARA is greater than $50K
	</td>
</tr>
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
	<input class="button" type="submit" value="Save Risk Evaluation">
	<input class="button" type="submit" value="Sign & Submit">
</table>
</cfform>
