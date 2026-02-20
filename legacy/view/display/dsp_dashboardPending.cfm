<p style="font-size:11px;font-family:Georgia;text-transform:uppercase;color:##000000;letter-spacing:2px;">PENDING ACTION</p>
<cfset state_ids="1-PM||2,3-Contracts||4,5-Controller||6-Approval Chain||8,9-Rejected||12-Approved">
<cfset total_count=0>
<cfset total_amount=0>
<cfset title="ARAs by State">
<cfset sum_list="">
<cfset state_cnt_list="">
<cfset name_list="">
<cfoutput>
<table cellpadding=0 cellspacing=0 border=0>
<tr>
<td valign="top">
	<table cellpadding=2 cellspacing=2 class="border">
	<tr bgcolor="##EEEEEE">
		<td class="border">State</td>
		<td class="border">Count</td>
		<td class="border">Sum of Amounts</td>
	</tr>
	<cfloop index="i" list="#state_ids#" DELIMITERS='||'>
		<cfset state=GetToken(i,1,'-')>
		<cfset name=GetToken(i,2,'-')>
		<cfset name_list=listAppend(name_list,name)>
		<cfquery name="S_Sums" datasource="#Application.dsn#">
			Select Sum(amountTotal) as dollars
			from v_ara
			where id_status in (#state#)
			
		</cfquery>
		
		<cfif S_Sums.dollars GT 0>
			<cfset  sum_list=ListAppend(sum_list,S_sums.dollars)>
		<cfelse>
			<cfset  sum_list=ListAppend(sum_list,"0")>
		</cfif>
		
		<cfquery name="Counts" datasource="#Application.dsn#">
			Select Count(*) as StateNum
			from v_ara
			where id_status in (#state#)
			<!---<cfif session.id_job LT 10><!--- Group Level or Lower, only let them see group --->
			and (grp='#session.group#' or grp IN ('#session.approve_grp#'))	
			<cfelseif listFind('10,11,12',session.id_job)><!--- Sector level, can see everything in their sector --->
			and sector='#session.sector#'
			</cfif>--->
		</cfquery>
		
		<cfset state_cnt_list=ListAppend(state_cnt_list,Counts.StateNum)>
		
		<tr>
			<td class="border">#Name#</td>
			<td class="border" align="center">
			<cfset total_count=total_count+counts.statenum>
			<cfif counts.statenum GT 0>
				<cfset smtitle="ARAs IN #name# State">
				<a class="embed" href="index.cfm?fuseaction=app.home&pagequery=bystate&state=#state#&smtitle=#smtitle#&title=#Title#">#counts.statenum#</a>
			<cfelse>
				0
			</cfif>
			</td>
			<td class="border" align="right">
			$#Numberformat(s_sums.dollars,"9,999")#
			<cfset total_amount=val(total_amount + (numberformat(s_sums.dollars,"9999")))></td>
		</tr>
	</cfloop>
	<tr bgcolor="##EEEEEE">
		<td class="border" align="right">Totals</td>
		<td align="center" class="border">#total_count#</td>
		<td align="right" class="border">$#numberformat(total_amount,"9,999")#</td>
	</tr>
	</table>
<td width=25>
	<img src="images/spacer.gif" width=25>
</td>
<td valign="top">
<cfset listptr=1>
<cfchart
     format="png"
	 chartheight="250"
	 chartwidth="560"
 	 xAxistitle = "S T A T E"
	 show3D="yes"
	 labelformat="currency"
	 yaxistitle="TOTAL AMOUNTS"
	 markersize=20
	font = "Trebuchet MS" 
  
    fontSize = "11"
	 seriesplacement="cluster">
	<cfchartseries
             type="bar"
             serieslabel="xxxxxx"
			 paintStyle="raise"
   			 colorlist = "##567D9D,##C4CfAF,##567D9D,##C4CfAF,##567D9D,##C4CfAF,##567D9D,##C4CfAF">
			<cfset Listptr=1>
			<cfloop index="i" list="#sum_list#">
					<cfset this_Sum=#numberformat(Listgetat(sum_list,listptr),"9999")#>
					<cfset this_cnt=#Listgetat(name_list,listptr)#>
					<cfchartdata item="#this_cnt#" value="#this_sum#">
					<cfset Listptr=#listptr# + 1>
			</cfloop>
</cfchartSeries>
</cfchart>
</cfoutput>
</td></tr>
</table>