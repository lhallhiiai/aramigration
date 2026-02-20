<p style="font-size:11px;font-family:Georgia;text-transform:uppercase;color:##000000;letter-spacing:2px;">ARAs I APPROVED/REJECTED THAT ARE STILL IN APPROVAL CHAIN</p>
<cfset state_ids="1-PM||2,3-Contracts||4,5-Controller||6-Approval Chain||8,9-Rejected">
<cfset total_count=0>
<cfset total_amount=0>

<cfquery name="getLog" datasource="#Application.dsn#">
		Select distinct id_ara from araAppLog 
		where id_user = '#session.id_user#'
</cfquery>

<cfoutput>
<table cellpadding=2 cellspacing=2 class="border">
<tr bgcolor="##EEEEEE">
	<td class="border">Status</td>
	<td class="border">ARA ID</td>
	<td class="border">Sum of Amounts</td>
</tr>
<cfloop query="getlog">
	<cfoutput>
	<cfset aid=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
	<cfquery name="S_Sums" datasource="#Application.dsn#">
		Select Sum(amountTotal) as dollars
		from ara
		where id_ara in (#getLog.id_ara#)
	</cfquery>
    <cfquery name="getARA_dashboardAC" datasource="#Application.dsn#">
		Select * from v_ara
		where id_ara = '#id_ara#'
	</cfquery>
    <cfset total_count = total_count + 1>
	<tr>
		<td class="border">#getARA_dashboardAC.statusName#</td>
		<td class="border" align="center">
			<a class="embed" href="index.cfm?Fuseaction=app.ARA_PM&AID=#AID#&Menu=ARA_Detail">#id_ara#</a>
		</td>
		<td class="border" align="right">
		$#Numberformat(s_sums.dollars,"9,999")#
		<cfset total_amount=val(total_amount + (numberformat(s_sums.dollars,"9999")))></td>
	</tr>
    </cfoutput>
</cfloop>
<tr bgcolor="##EEEEEE">
	<td class="border" align="right">Totals</td>
	<td align="center" class="border">#total_count#</td>
	<td align="right" class="border">$#numberformat(total_amount,"9,999")#</td>
</tr>
</table>
</cfoutput>