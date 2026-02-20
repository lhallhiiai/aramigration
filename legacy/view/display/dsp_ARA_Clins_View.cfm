<cfset whichtab="CLINS">
<cfset pagetitle="CLIN Information">

<p class="subtitle">CLINS Associated with this ARA [Read Only]</p>


<cfif clins.recordcount GT 0>
<cfset grand_total=0>
<cfset costfund_total=0>
<cfset FeeFund_total=0>
<cfset loopcount=1>
<table cellpadding=2 cellspacing=2 width="95%" class="border">
<tr>
	<td>&nbsp;</td>
	<td class="border">CLIN</td>
	<td class="border">Expiration</td>
	<td class="border">Description</td>
	<td class="border">Cost Funding</td>
	<td class="border">Fee Funding</td>
	<td class="border" align="right">Total</td>
	
</tr>
<cfoutput query="clins">
<tr>
	<td class="border">#loopcount#.</td>
	<td class="border">#clinNo#</td>
	<td class="border">#dateformat(expirationDate,"MM/DD/YY")#</td>
	<td class="border">#Description#</b></td>
	<td class="border" align="right">$#numberformat(costFunding,"9,999.99")#</td>
	<td class="border" align="right">$#numberformat(feeFunding,"9,999.99")#</td>
	<td class="border" align="right">$#numberformat(total,"9,999.99")#</td>
	
	<cfset costFund_total=val(costFund_total + costFunding)>
	<cfset FeeFund_total=val(FeeFund_total + feefunding)>
	<cfset grand_total=val(grand_total + total)>
	<cfset loopcount=Val(loopcount + 1)>
</tr>
</cfoutput>
<tr>
	<cfoutput>
	<td colspan=4 class="border" align="right">TOTALS:</td>
	<td align="right" class="border">$#numberformat(costFund_Total,"9,999")#</td>
	<td align="right" class="border">$#numberformat(FeeFund_Total,"9,999")#</td>
	<td align="right" class="border">$#numberformat(grand_total,"9,999")#</td>
	</cfoutput>
</tr>
</table>
<cfelse>
<p>No CLINS have been defined for this ARA.</p>
</cfif>

		