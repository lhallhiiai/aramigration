<cfset whichtab="CLINS">
<cfset pagetitle="CLIN Information">
<!--- cfparam name="id_ara" default="7" --->
<cfset id_ara=#decrypt(url.AID,request.encryptKey,request.encryptType,'hex')#>
<cfparam name="FormorView" default="Form">
<cfparam name="Action" default="InsertSetup">
<!---  Invoke: #getClin()# for all clins, #getClin(id_ara)# for all clins with ara, or #getClin(id_ara,id_clins)# for one clin. --->
<cfinclude template="../../model/m_ara/qry_CLIN_List.cfm">

<cfswitch expression="#Action#">
<cfcase value="InsertSetup">
	<cfset buttonText="Add CLIN">
	<cfset faction="?fuseaction=app.clin_submit&AID=#url.AID#">
	<cfset clinVars=#GetClin()#>
</cfcase>

<cfcase value="UpdateSetup">
	<cfset buttonText="Update CLIN">
	<cfset clinVars=#GetClin(id_ara,id_clins)#>
	<cfset faction="?fuseaction=app.clin_update&AID=#url.AID#&id_clins=#id_clins#">
	<!--- cfdump var="#clins#" format="text" --->
</cfcase>

<!---cfcase value="delete">
	<cflocation url="?fuseaction=app.clin_delete&id_clins=#id_clins#">
	<!--- cfdump var="#clins#" format="text" --->
</cfcase --->
</cfswitch>

<!--- +++++++++++ Pulls ARA, user, groups, sector, category, status ++++++++++ --->
<cfinclude template="../../model/m_ara/qry_ara.cfm">

<script language="javascript" type="text/javascript">
	
function sumTotal() {
var a = (document.getElementById('CostFunding').value != '') ? eval(document.getElementById('CostFunding').value) : 0;
var b = (document.getElementById('FeeFunding').value != '') ? eval(document.getElementById('FeeFunding').value) : 0;
document.getElementById('ARATotal').value = a + b;
}

</script>

<cfparam name="Submenu" default="ARA_Detail">


<cfoutput>
<!-- 1  --><table width=100% cellpadding=0 cellspacing=0 border=0>
		<tr>
		<td width=60% valign="top">
		<p class="smtitle">
		ARA #ID_ARA# - #Reference# CLINS</p>
		<p class="aratitle">Title: #title#</p>
		</td>
		<td valign="top" align="right">
		<cfif FormOrView EQ "Form">
			<a class="embed" href="#self#?fuseaction=app.ARA_Clins&formorview=View">Clins View Only</a>&nbsp;&nbsp;|&nbsp;&nbsp;
		<cfelse>
			<a class="embed" href="#self#?fuseaction=app.ARA_Clins">Clins Form</a>&nbsp;&nbsp;|&nbsp;&nbsp;
		</cfif>
		<a class="embed" href="#self#?fuseaction=app.ARA_cfdocument">Print ARA <img src="images/PrinterIcon.gif" border=0></a>
<!-- /1  --></td></tr></table>
</cfoutput>
<!--- ARA Summary Info at top of page ---><cfinclude template="dsp_ARA_top_summary.cfm">

<fieldset><legend><b>ARA Backup Detail</b></legend>
<!--- ARA Navigational Tabs ---><cfinclude template="dsp_tabset.cfm">
		
<!--- If in controller, or rejected and this person is the controller, they will see form. Otherwise view only --->
<cfif (FormorView EQ "Form")  AND (ListFind('4,5,8,9',id_status)) and (ID_controller EQ session.id_user)>


<table cellpadding=0 width=100% cellspacing=0 border=0>
<tr>
<td valign="top">




<cfoutput>
<cfform action="#Faction#">
<cfif NOT Find("Insert", action)>
	<cfinput type="hidden" name="id_Clins" value="#id_Clins#">
</cfif>


<table cellpadding=2 cellspacing=2 class="border">
<!--- If there are clins in JobCost, will autpopulate CLIN num, desc, date --->
<cfif #Clinfo.Recordcount# GT 0>
<tr>
	<td class="borderhdr">
		<b>CLIN Number</b><br>
		<cfif (NOT Find('Insert',Action))>
		<font style="color:##222222;">#ClinNo#</font>
		<cfinput type="hidden" name="ClinNum" value="#ClinNo#">
		
		<cfelse>

		<cfinput type="text" Required="Yes" Message="Enter CLIN Number" name="ClinNum" id="ClinNum" size=30 autosuggest="#valueList(CLINfo.clin_no)#" class="inputtext">
		</cfif>
	</td>
</tr>
<tr>
	<td class="borderhdr">
		<b>CLIN Description</b><br>
		<cfif (NOT Find('Insert',Action))>
		<font style="color:##222222;">#ClinDesc#</font>
		<cfinput type="hidden" name="ClinDesc" value="#ClinDesc#">
		<cfelse>
		<cfinput type="text" required="yes" Message="CLIN Descripiton will be  filled in based on CLIN number" name="ClinDesc" id="ClinDesc" bind="cfc:ara_dev.cfcs.clin.getDescription({ClinNum})" size=30 class="autopop">
		</cfif>
	</td>
</tr>
<tr>
	<td class="borderhdr">
		Expiration Date<br>
		<cfif (NOT Find('Insert',Action))>
		<font style="color:##222222;">#ClinExp#</font>
		<cfinput type="hidden" name="ClinExp" value="#ClinExp#">
		<cfelse>
		<cfinput class="autopop" required="yes" Message="Expiration Date will be filled in based on CLIN number" name="ClinExp" id="ClinExp" bind="cfc:ara_dev.cfcs.clin.getExp({ClinNum})" size=10>
		</cfif>
	</td>
</tr>
<!--- Otherwise there are no CLINS in Job Cost Table .... allowing for manual input --->
<cfelse>
<!--- Display warning message only when no clins in the ARA system are defined for this ARA --->
<cfquery name="ARA_Clins" datasource="#Application.dsn#">
	Select id_clins
	from clins
	where id_ara=#id_ara#
</cfquery>
<cfif ARA_Clins.recordcount EQ 0>
	<cfset warningMsg="No CLINs exist for this ARA. Enter CLINS manually. CLINs will need to be cross verified once the ARA is negated.">
</cfif>
<tr>
	<td class="borderhdr">
		<b>CLIN Number</b><br>
		<cfinput type="text" Required="Yes" Message="Enter CLIN Number" name="ClinNum" id="ClinNum" value="#ClinNo#" size=30 class="inputtext">
	</td>
</tr>
<tr>
	<td class="borderhdr">
		<b>CLIN Description</b><br>
		<cfinput type="text" required="yes" Message="CLIN Descripiton" name="ClinDesc" id="ClinDesc"  value="#ClinDesc#" size=30 class="inputtext">
	</td>
</tr>
<tr>
	<td class="borderhdr">
		Expiration Date<br>
		<cfinput class="date" style="background-color: ##E2E8DB; font-family: verdana;font-size: 11px;" value="#ClinExp#" required="yes" Message="Expiration Date required" name="ClinExp" id="ClinExp" size=10>
	</td>
</tr>


</cfif>
<tr>
	<td class="borderhdr">
		<b>At Risk Cost Funding</b><br>
		<cfinput type="text" required="Yes" Message="Cost Funding is required" name="CostFunding" id="CostFunding" onchange="javascript: sumTotal();" size=20 class="inputtext" value="#CostFunding#">
	</td>
</tr>
<tr>
	<td class="borderhdr">
		<b>At Risk Fee Funding</b><br>
		<cfinput type="text" required="yes" Message="Fee Funding is required" name="FeeFunding" id="FeeFunding" onchange="javascript: sumTotal();" size=20 class="inputtext" value="#FeeFunding#">
	</td>
</tr>
<tr>
	<td class="borderhdr">
		At Risk Total Amt (calculated)<br>
		<cfinput class="readonly" type="text" name="ARATotal" id="ARATotal" value="#ARATotal#" size=20 readonly>
	</td>
</tr>

<tr>
	<td class="border" align="center">
		<input type="submit" name="submit" value="#buttontext#">
</table>

</cfform>
</cfoutput>
</td>
<td width=15><img src="images/spacer.gif" width=15></td><!--- gutter --->
<td valign="top">

<cfset TblWidth=600>
<cfset AID=#encrypt(id_ara,request.encryptkey,request.encrypttype,'hex')#>
<cfset araClins=#getClin(id_ara)#><!--- --->
<cfif clins.recordcount GT 0>
<cfinclude template="dsp_messages.cfm">
<cfset grand_total=0>
<cfset costfund_total=0>
<cfset FeeFund_total=0>
<cfset loopcount=1>
<table cellpadding=2 cellspacing=2 class="border">
<tr>
	<td>&nbsp;</td>
	<td class="border"><cfoutput>CLIN</cfoutput></td>
	<td class="border">Expiration</td>
	<td class="border">Description</td>
	<td class="border">Cost Funding</td>
	<td class="border">Fee Funding</td>
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
	<td class="border"><a class="embed" href="index.cfm?fuseaction=app.ARA_Clins&action=UpdateSetup&AID=#AID#&id_clins=#id_clins#">#clinNo#</a></td>
	<td class="border">#dateformat(expirationDate,"MM/DD/YY")#</td>
	<td class="border">#Description#</b></td>
	<td class="border" align="right">$#numberformat(costFunding,"9,999")#</td>
	<td class="border" align="right">$#numberformat(feeFunding,"9,999")#</td>
	<td class="border" align="right">$#numberformat(total,"9,999")#</td>
	<td align="center" class="border">
		<!--- Delete --->
		<a class="embed" href="index.cfm?fuseaction=app.clin_delete&AID=#AID#&id_clins=#id_clins#"><img src="images/SmDelete.png" border=0 alt="Delete this xxCLIN"></a>
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
	<td align="right" class="border">$#numberformat(costFund_Total,"9,999")#</td>
	<td align="right" class="border">$#numberformat(FeeFund_Total,"9,999")#</td>
	<td align="right" class="border">$#numberformat(grand_total,"9,999")#</td>
	</cfoutput>
</tr>
</table>
<p><img src="images/warning.png" align="left">&nbsp;Controller needs to complete <b>CLIN</b> tab and <b>Controller</b> tab prior to submitting for approval.</p>
<cfelse>
	<cfif NOT isDefined('warningMsg')>
	<br><br>
		<p>No CLINs have been defined for this ARA. Type in CLIN number to start.</p>
	</cfif>
</cfif>

</td></tr></table>

<cfelse>
	<cfset clinVars=#GetClin(id_ara)#>
	<cfinclude template="dsp_ARA_Clins_View.cfm">
</cfif>	