<!---  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->
<!---            CLINs:    BOTTOM PORTION OF CONTROLLER PAGE                       --->
<!---  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->

<cfparam name="CLINAction" default="InsertSetup">
<cfinclude template="../../model/m_ara/qry_Clin_List.cfm">
<!--- CLIN AutoComplete --->
<script>
  $(document).ready(function(){
		  $("#ClinNum").autocomplete("index.cfm?fuseaction=app.ClinNumAutoComplete&<cfoutput>JamisNo=#JamisNo#&id_ara=#id_ara#</cfoutput>",
			{
				minChars:1,
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

<!--- CLIN Sum Fields --->
<script language="javascript" type="text/javascript">

function sumTotal(fieldOne,fieldTwo,totalField) {
     var aNum = document.getElementById(fieldOne).value;
	 var aNum = aNum.replace(/[$,]/g,'');
	 var bNum = document.getElementById(fieldTwo).value;
	 var bNum = bNum.replace(/[$,]/g,'');
	 if ((isNaN(aNum) == true) || (isNaN(bNum) == true)){
	 	alert('You entered a non-numeric value');
	}
	 var totalNum=Number(aNum) + Number(bNum);
	document.getElementById(totalField).value = (totalNum).toFixed(2);
}

</script>

<!--------      CLIN INSERT, UPDATE, DELETE  ----------------- --->
<cfswitch expression="#CLINAction#">
<cfcase value="InsertSetup">
	<cfset buttonText="ADD">
	<cfset faction="?fuseaction=app.clin_submit&AID=#url.AID#">
	<cfset clinVars=#GetClin()#>
</cfcase>

<cfcase value="UpdateSetup">
	<cfset buttonText="UPDATE">
	<cfset clinVars=#GetClin(id_ara,id_clins)#>
	<cfset faction="?fuseaction=app.clin_update&AID=#url.AID#&id_clins=#id_clins#">
	<!--- cfdump var="#clins#" format="text" --->
</cfcase>
</cfswitch>

<!---<fieldset><legend><b>CLINS Worksheetzzzzzzzzzzzzzzz</b></legend>--->
<table cellpadding=2 cellspacing=2 class="border" width=100%>
<cfoutput>
<!--- +++++++++++++++++++++++ PREFACE TO CLIN  FORM +++++++++++++++++++++++++++++++++ --->

<!--- If there are clins in JobCost, will autpopulate CLIN num, desc, date --->
<cfset araClins=#getClin(id_ara)#><!--- --->
<cfif ClinAction EQ "InsertSetup">
	<cfset costFunding="">
	<cfset feeFunding="">
	<cfset ARATotal="">
</cfif>
<cfform name="CLinForm" action="#Faction#">
<!--- If (Not Early Start & Not Exported)  OR (Is early start & status=Approved & User is CCS --->
<cfif (id_cat NEQ 10 and id_status NEQ 13) or (id_cat EQ 10 and id_status EQ 12 and session.id_job EQ 13)>
<input type="hidden" name="company" value="ALIN">
</cfif>

<!---      +++++++++++++++++++++++ Amount of Total Left to work with ++++++++++++++++++++++    --->
<cfif isdefined("SumCost.COSTSUBTOTAL") and isdefined("SumFee.FEESUBTOTAL") and id_cat NEQ 10>
	<cfset allowedAmt = amounttotal - SumCost.COSTSUBTOTAL - SumFee.FEESUBTOTAL>

<cfelseif id_cat EQ 10 and session.id_job EQ 13 and id_status EQ 12>
	<cfquery name="getESClin" datasource="#Application.dsn#">
		SELECT sum(clin_Total) As Sum_clins
		from v_clin
		where id_ara=#id_ara#
	</cfquery>
    <cfset allowedAmt = Amounttotal - #getESClin.Sum_Clins#>
<cfelse><!--- Not Early Start, Not CCS, Not Approved --->
	<cfset allowedAmt=#amountTotal#>
	<cfset allowedAmt = amounttotal - Total_cost - Total_Fee>
</cfif>
<tr>
	<td>&nbsp;&nbsp;</td>
	<td class="border" colspan=3 align="center">Currently remaining amount is <i><b>#dollarformat(allowedAmt)#</b></td>
	<td>&nbsp;&nbsp;</td>
</tr>

<!--- +++++++++++++++++++++++      START OF CLIN  FORM  +++++++++++++++++++++++++++++++++ --->
<input type="hidden" name="allowedAmt" value="#allowedAmt#">

<cfinput type="Hidden" name="AID" value="#AID#">
<cfinput type="Hidden" name="ARAClinCnt" value="#ARAClinCnt#">
<cfif NOT Find("Insert", ClinAction)>
	<cfinput type="hidden" name="id_Clins" value="#id_Clins#">
</cfif>


<!--- tr><td colspan=5>id_status EQ <cfoutput>#id_status#</cfoutput> and session.id_job EQ <cfoutput>#session.id_job#</cfoutput></td></tr --->
<tr>
<!---                     NON-EARLY START CLINS            --->
<cfif id_cat NEQ 10>
		<td valign="bottom" class="borderhdr" <cfif #ARAClinCnt# EQ #JamisClins#>colspan="4"</cfif>>
			<b>CLIN</b>
			[#JamisNo# has #JamisClins# CLINS in CostPoint]. <cfif #ARAClinCnt# LT #JamisClins#><br></cfif>
			<cfif #ARAClinCnt# EQ #JamisClins#><!--- The count of CLINs in ARA=The count in Jamis, so there are none, left to use --->
				All CLINs for this CostPoint Number are already in ARA.
			<cfelse>
				<cfif (NOT Find('Insert',CLINAction))><!--- Editing Existing Clin --->
					<font style="color:##222222;">#ClinNo#</font>
					<cfinput type="hidden" name="ClinNum" value="#ClinNo#">
				<cfelse><!--- Autocomplete CLIN INFO --->
					<cfinput type="text" Required="Yes" Message="Enter CLIN Number"
					  name="ClinNum" id="ClinNum" size=80  class="inputtext">
				</cfif>
			</cfif>
		</td>
	<!--- /cfif --->
<cfelse><!--- Is Early Start, no info in Jamis yet --->

	<td valign="bottom" class="borderhdr">
		<input type="hidden" type="hidden" name="amountTotal" value="#amountTotal#">
		CLIN Number<b>
		<cfinput type="text" class="inputtext" name="TempClinNum" size="40" maxlength=50 value="To Be Supplied Post Contract by CCS.">
	</td>
</cfif>
<cfif (#ARAClinCnt# LT #JamisClins#) OR id_cat EQ 10><!--- then there are still CLINs that can be used, or in the case of Early Starts may enter multiple --->
	<!--- Cost Funding --->
	<td valign="bottom" class="borderhdr">
		<b>At Risk<br>Cost Funding</b><br>
		<cfinput type="text" required="Yes" Message="Cost Funding is required, only numeric value allowed. Enter 0 if no At Risk Cost Funding" name="CostFunding" validate="float"
		id="CostFunding" onchange="javascript: sumTotal('CostFunding','FeeFunding','ARATotal');"
		size=10 maxlength=20 class="inputtext" value="#CostFunding#">
	</td>

	<!--- Risk Funding --->
	<td valign="bottom"  class="borderhdr">
		<b>At Risk <br>Fee Funding</b><br>

        <cfif id_cat NEQ 1>
		<cfinput type="text" required="yes" Message="Fee Funding is required, only numeric value allowed. Enter 0 if no At Risk Fee Funding" name="FeeFunding"  validate="float"
		id="FeeFunding" onchange="javascript: sumTotal('CostFunding','FeeFunding','ARATotal');"
		size=10 maxlength=20 class="inputtext" value="#FeeFunding#">
        <cfelse><br />
        N/A
        <input type="hidden" name="FeeFunding" id="FeeFunding" value="0">
        </cfif>

	</td>

	<!--- Line Total --->
	<td valign="bottom" class="borderhdr">
		Line/CLIN  Total<br>
		<cfinput class="autopop" type="text" name="ARATotal" id="ARATotal"
		value="#Numberformat(ARATotal,"9999.99")#" size=10 maxlength=20 READONLY>
	</td>
	<td valign="bottom" class="border">
		<input type="submit" class="button" value="#buttonText#">
	</td>
	</cfif>
</tr>
</table>
</cfform>

</cfoutput>

<cfset araClins=#getClin(id_ara)#><!--- --->

<cfif clins.recordcount GT 0>

<cfset grand_total=0>
<cfset costfund_total=0>
<cfset FeeFund_total=0>
<cfset loopcount=1>
<table cellpadding=2 border=0 width=100%>
<tr>
<td colspan=3>
<p><b>CLINS For This ARA</b></p>
</td>
<td width=450 colspan=5 align="right">
<cfif id_cat EQ 10 and session.id_job EQ 13 and allowedAmt EQ 0>
<cfoutput>
Set ARA status to Early Start Complete when done: <input class="button" type="Submit" value="Early Start Complete" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.ClinEarlyStartComplete&AID=#AID#&Revision=#revision#';">
</cfoutput>
</cfif>
</td>
</tr></table>
<table cellpadding=2 cellspacing=2 WIDTH=100% class="border">
<tr>
	<td></td>
	<td class="border"><cfoutput>CLIN</cfoutput></td>
	<td class="border">End Date</td>
	<td class="border">Description</td>
	<td class="border" align="right">Cost Funding</td>
	<td class="border"align="right">Fee Funding</td>
	<td class="border" align="right">Total</td>
	<td></td>
</tr>
<cfoutput query="clins">
<cfif isDefined('url.id_clins') AND (url.id_clins EQ id_clins)>
	<tr bgcolor="##edf3f9">
	<td width=18 class="approve"><img src="images/ThisArrow.gif" width=18 alt=""></td>
<cfelse>
	<tr>
		<td width=18 class="border">#loopcount#.</td>
</cfif>
	<td class="border">
	<cfif id_cat EQ 30><!--- If early start, can edit enterd data --Mel dummied out for now --delete and doover if you got it wrong --->
		<a class="embed" href="index.cfm?fuseaction=app.ARA_Clins&action=UpdateSetup&AID=#AID#&id_clins=#id_clins#">#clinNo#</a></td>	<cfelse><!--- Otherwise, delete and reselect from Jamis if don't want this entry --->
		#clinNo#
	</cfif>
	<td class="border">#dateformat(expirationDate,"MM/DD/YY")#</td>
	<td class="border">#Description#</b></td>
	<td class="border" align="right">$#numberformat(costFunding,"9,999.99")#</td>
	<td class="border" align="right">$#numberformat(feeFunding,"9,999.99")#</td>
	<td class="border" align="right">$#numberformat(total,"9,999.99")#</td>
	<td align="center" class="border">
		<!--- Delete --->
		<a class="embed" href="index.cfm?fuseaction=app.clin_delete&AID=#AID#&id_clins=#id_clins#"><img src="images/SmDelete.png" border=0 alt="Delete this CLIN"></a>
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
	<cfif NOT isDefined('warningMsg')>
	<br><br>
		<p>No CLINs have been defined for this ARA. Type in CLIN number to start.</p>
	</cfif>

</cfif>


</fieldset>