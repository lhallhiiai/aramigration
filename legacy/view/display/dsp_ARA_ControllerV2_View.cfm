<!---  *********************************************************************  --->
<!---                                                                         --->
<!---            ARA Controller Information View ONly                         --->
<!---                                                                         --->
<!---  *********************************************************************  --->
<cfinclude template="../../model/m_ara/qry_controller.cfm">
<cfif isDefined('url.aid')>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cfelse>
	ERROR: Encrypted aid not provided.<br><cfabort>
</cfif>
<cfoutput>
<cfif isPrint EQ "No">
	<fieldset><legend><b>Controller Summary</b></legend>
<cfelse>
	<fieldset><legend><b><font style="font-size: 9pt; font-family: Trebuchet MS;margin-top: 12pt;margin-bottom: 12pt;">Controller Summary</font></legend>
</cfif>
<!--- cfdump var="#GetController#" format="text" --->
<table width=100% cellpadding=2 cellspacing=2 class="border">
<tr>
	<!----             INTEREST IMPACT                     --->
	<td width="25%" valign="top" class="border" nowrap valign="bottom">
	<b>Interest impact</b> to HII through receipt of payment
	</td>
	<td width="25%" valign="top" nowrap align="right" class="border">
	<cfif InterestImpact NEQ "">
		$ #numberformat(InterestImpact,"9,999.99")#
	<cfelse>
		TBD&nbsp;&nbsp;
	</cfif>
	</td>
	<!----             BURN RATE                     --->
	<td  width="25%" valign=top" nowrap class="border">
	Expected <b>burn rate</b> per two week period
	</td>
	<td width="25%" align="right"  valign="top" nowrap class="border">
	<cfif burnRate NEQ "">
		$ #numberformat(burnRate,"9,999.99")#
	<cfelse>TBD&nbsp;&nbsp;
	</cfif>
	
	
	</td>
</tr>
<tr><!----             INCURRED  COST                     --->
	<td  width="25%"  valign="top" nowrap class="border">
	<b>Incurred Cost</b> not yet Billable
	</td>
	<td align="right"  valign="top" nowrap class="border">
	<cfif IcCost NEQ "">
		$ #numberformat(IcCost,"9,999.99")#
	<cfelse>TBD&nbsp;&nbsp;
	</cfif>
	
	</td>
	<!----             INCURRED  FEE                     --->
	<td  width="25%"  valign="top" class="border">
	<b>Incurred Fee</b> not yet Billable
	</td>
	<td width=25%  align="right"  valign="top" nowrap  class="border">
	<cfif IcFee NEQ "">
		$ #numberformat(IcFee,"9,999.99")#
	<cfelse>TBD&nbsp;&nbsp;
	</cfif>
	</td>
</tr>
<cfif isPrint EQ "No">
<!--- MGann 9/11/2013: CFdocument was printing list of documents 4 times. Now prints out only in final section of PRINT DOC.
This fix was made after reports that some ARAs could not create pdf. When problem ARAs were looked at they
had long lists of documents...so think the fact that it ws timing out was releated to 4 calls to print out list --->
	<tr>
		<td colspan=4 class="border">
	<cfinclude template="_docList.cfm">
		</td>
	</tr>
</cfif>
</table><br><br>
<table cellpadding=2 cellspacing=2 width=100% class="outerborder">
<cfinclude template="../../model/m_ara/qry_CLINcnt.cfm">
<cfinclude template="../../model/m_ara/qry_ClinCostFeeTotals.cfm">
<tr>
	<td class="border">Total <b>Cost</b> [from CLINs below]</td>
	<td nowrap align="right" class="border">
	<cfif Total_Cost_dsp NEQ "">
		$ #Total_Cost_dsp#
	<cfelse>TBD&nbsp;&nbsp;
	</cfif> 
	</td>
	<td class="border">Total <b>Fees</b> [from CLINs below]</td>
	<td  nowrap align="right" class="border">
	<!---      Total_Fee    --->
	<cfif total_Fee_dsp NEQ "">
		#total_Fee_dsp#
	<cfelse>TBD&nbsp;&nbsp;
	</cfif>
	</td>
	<td class="border" align="right">&nbsp;&nbsp;&nbsp;&nbsp;Total</td>
	<td  nowrap align="right" class="border"><!---      Total_Value    --->
	<cfif Total_Value_dsp NEQ "">
		#Total_Value_dsp#
	<cfelse>TBD&nbsp;&nbsp;
	</cfif>
	</td>
</tr>
</table>
</fieldset>

</cfoutput>
<cfif isPrint EQ "No">
	<fieldset><legend><b>CLINS For This ARA</b></legend>
<cfelse>
	<fieldset><legend><b><font style="font-size: 9pt; font-family: Trebuchet MS; margin-top: 12pt;margin-bottom: 12pt;">CLINS for this ARA</font></legend>
</cfif>

<!--- cfif id_status NEQ 13 and id_cat NEQ 10 --->
<cfif (id_cat NEQ 10) or (id_cat EQ 10 and id_status EQ 16)><!--- if it is early start, have clins been completed --->

<cfinclude template="../../model/m_ara/qry_CLIN_List.cfm">
<cfset araClins=#getClin(id_ara)#><!--- --->
<cfif clins.recordcount GT 0>
	
	<cfset grand_total=0>
	<cfset costfund_total=0>
	<cfset FeeFund_total=0>
	<cfset loopcount=1>
	<table cellpadding=2 cellspacing=2 WIDTH=100% class="border">
	<tr>
		<td></td>
		<td class="border"><cfoutput>CLIN</cfoutput></td>
		<td class="border">Expiration</td>
		<td class="border">Description</td>
		<td class="border" align="right">Cost Funding</td>
		<td class="border"align="right">Fee Funding</td>
		<td class="border" align="right">Total</td>
		<td></td>
	</tr>
	<cfoutput query="clins">
		<tr>
			<td width=18 class="border">#loopcount#.</td>
		<td class="border">#clinNo#</td>
		
		<td class="border">#dateformat(expirationDate,"MM/DD/YY")#</td>
		<td class="border">#Description#</b></td>
		<td class="border" align="right">$#numberformat(costFunding,"9,999.99")#</td>
		<td class="border" align="right">$#numberformat(feeFunding,"9,999.99")#</td>
		<td class="border" align="right">$#numberformat(total,"9,999.99")#</td>
		</td>
		<cfset costFund_total=val(costFund_total + costFunding)>
		<cfset FeeFund_total=val(FeeFund_total + feefunding)>
		<cfset grand_total=val(grand_total + total)>
		<cfset loopcount=Val(loopcount + 1)>
	</tr>
	</cfoutput>
	<tr>
		<cfoutput>
		<td colspan=4 class="border" align="right">TOTALS:</td>
		<td align="right" class="border">$#numberformat(costFund_Total,"9,999.99")#</td>
		<td align="right" class="border">$#numberformat(FeeFund_Total,"9,999.99")#</td>
		<td align="right" class="border">$#numberformat(grand_total,"9,999.99")#</td>
		</cfoutput>
	</tr>
	</table>
<cfelse>
		<p>No CLINs have been defined for this ARA. </p>

</cfif>


</fieldset>

<cfelseif id_cat eq 10 and id_status EQ 12 and session.id_job EQ 13>

<cfoutput>
<cfinclude template="dsp_ClinFormV2.cfm">
</cfoutput>

</div>
<!---  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->
<!---                       CLIN BOTTOM PORTION OF PAGE                            --->
<!---  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->
<cfelseif id_cat eq 10 and ara_clins.clinCount EQ 0>
	<p>For early start ARAs, CLINs are entered after they are set up.</p>

</cfif>


		