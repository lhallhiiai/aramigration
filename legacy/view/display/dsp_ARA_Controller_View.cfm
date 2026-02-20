<!---  *********************************************************************  --->
<!---                                                                         --->
<!---            ARA Controller Information View ONly                              --->
<!---                                                                         --->
<!---  *********************************************************************  --->
<cfinclude template="../../model/m_ara/qry_controller.cfm">
<cfif isDefined('url.aid')>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cfelse>
	ERROR: Encrypted aid not provided.<br><cfabort>
</cfif>
<cfoutput>
<table width=100% cellpadding=2 cellspacing=2 class="outerborder">
<tr>
	<td class="border" align="right">
	Interest impact to HII of this request is&nbsp;&nbsp;
	</td>
	<td class="dollar"><b>#dollarformat(interestImpact)#</b>
	</td>
	<td colspan=2 class="border">through receipt of payment</td>
</tr>

<tr>
	<td class="border" align="right">
	Expected burn rate is&nbsp;&nbsp;
	</td>
	<td class="dollar"> <b>#dollarformat(burnRate)#</b>
	</td>
	<td colspan=2 class="border">per two week period</td>
</tr>

<tr>
	<td>&nbsp;</td>
	<td class="border"align="center"><font class="smtitle">COST</font></td>
	<td class="border" align="center"><font class="smtitle">FEE</font></td>
	<td class="border" align="center"><font class="smtitle">VALUE</font></td>
</tr>

<tr>
	<td class="border" align="right">Cost and Fee authorized by this request&nbsp;&nbsp;</td>
	<td class="dollar">
	<cfif isDefined('Cost') and (Cost NEQ "")>
		#dollarformat(cost)#
	<cfelse>
		<cfset cost=0>
		TBD
	</cfif>
	</td>
	<td class="dollar">
	<cfif isDefined('Fee') and (Fee NEQ "")>
		#dollarformat(Fee)#
	<cfelse>
		<cfset fee=0>
		TBD
	</cfif>
	</td>
	<td class="dollar">
	<cfif (isDefined('Cost') and (Cost NEQ "")) and (isDefined('Fee') and (Fee NEQ ""))>
		#dollarformat(val(cost+fee))#
	<cfelse>
		TBD
	</cfif>
	</td>
</tr>

<tr>
	<td class="border" align="right">+ Amounts authorized on prior revisions&nbsp;&nbsp;</td>
	<td class="dollar">
	<cfif isDefined('priorCost') and (priorCost NEQ "")>
		#dollarformat(priorCost)#
	<cfelse>
		TBD
	</cfif>
	</td>
	<td class="dollar">
	<cfif isDefined('priorFee') and (priorFee NEQ "")>
		#dollarformat(priorFee)#
	<cfelse>
		TBD
	</cfif>
	</td>
	<td  class="dollar">
	<cfif (isDefined('priorCost') and (priorCost NEQ "")) and (isDefined('priorFee') and (priorFee NEQ ""))>
		#dollarformat(val(priorCost+priorFee))#
	<cfelse>
		TBD
	</cfif>
	</td>
</tr>

<tr>
	<td class="border" align="right">= Total authorized to date&nbsp;&nbsp;</td>
	<td class="dollar">
	<cfif (isDefined('priorCost') and (priorCost NEQ "")) and (isDefined('cost') and (cost NEQ ""))>
		#dollarformat(val(cost+priorcost))#
	<cfelse>
		TBD
	</cfif>
	</td>
	<td  class="dollar">
	<cfif (isDefined('priorfee') and (priorfee NEQ "")) and (isDefined('fee') and (fee NEQ ""))>
		#dollarformat(val(fee+priorfee))#
	<cfelse>
		TBD
	</cfif>
	</td>
	<td  class="dollar">
	<cfif (cost NEQ "") and (fee NEQ "") and (priorCost NEQ "") and (priorFee NEQ "")>
		#dollarformat(val(cost+fee+priorcost+priorfee))#
	<cfelse>
		TBD
	</cfif>
	</td>
</tr>

<tr>
	<td class="border" align="right">Incurred cost and fee not billable&nbsp;&nbsp;</td>
	<td class="dollar">
	<cfif isDefined('icCost') and icCost NEQ "">
		#dollarformat(icCost)#
	<cfelse>
		TBD
	</cfif>
	</td>
	<td class="dollar">
	<cfif isDefined('icFee') and icFee NEQ "">
		#dollarformat(icFee)#
	<cfelse>
		TBD
	</cfif>
	</td>
	<td class="dollar">
	<cfif (isDefined('iccost') and (iccost NEQ "")) and (isDefined('icfee') and (icfee NEQ ""))>
		#dollarformat(val(iccost+icfee))#
	<cfelse>
		TBD
	</cfif>
	
	</td>
</tr>

<tr>
	<td class="border" align="right">Recognize revenue on this ARA</td>
	<td class="border" style="text-align:center;">
	#ucase(Revenue)#</td>
	
</tr>
<cfquery name="ConDate" datasource="#Application.dsn#">
	select * from ARAApplog
	where id_ara=#id_ara#
	and id_status=6
</cfquery>
<cfset ConDate=#Condate.ApprovalDate#>
<tr>
	<td align="right" class="greyblue">
	<cfif isDate(conDate)>
   		Controller information submitted by for approval on:
	<cfelse>
		Controller information approval submission.
	</cfif>
	</td>
	<td  colspan=3 class="greyblue">&nbsp;&nbsp;
	<cfif isDate(conDate)>
		#dateformat(conDate,"dddd MM/DD/YYYY")# #timeformat(conDate,"hh:mm tt")# 
	<cfelse>
		Controller submission pending.
	</cfif>
	</td>

<tr>
</cfoutput>
</table>


		