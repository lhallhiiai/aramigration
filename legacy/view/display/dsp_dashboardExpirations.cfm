
<p style="font-size:11px;font-family:Georgia;text-transform:uppercase;color:##000000;letter-spacing:2px;">CRITICAL ARA EXPIRATIONS</p>
<table cellpadding=0 cellspacing=0 border=0>
<tr>
<td valign="top">
<table cellpadding=2 cellspacing=2 class="border">
<tr bgcolor="#EEEEEE">
	<td class="border" align="right">Expires in...</td>
	<td class="border">Count</td>
	<td class="border">Sum of Amounts</td>
</tr>
<cfset total_dollars=0>
<cfset total_count=0>
<cfset exp_sums="">
<cfoutput>
<!--- ++++++++++++++++++++++++++  EXPIRED +++++++++++++++++++++++++++++++ --->
<cfset expires="0,5,10,15,30">
<cfloop index="exp" list="#expires#">
	<cfquery name="Ex" datasource="#Application.dsn#">
		SELECT id_ara, reference, AmountTotal  from v_ARA
		<cfif exp NEQ 0>
		where ExpirationDate Between  
				<cfswitch expression="#exp#">
				<cfcase value=5>GetDate()</cfcase><!--- next 5 days --->
				<cfcase value=10>dateAdd(day,5,getdate())</cfcase><!--- 5-10 days --->
				<cfcase value=15>dateAdd(day,10,getdate())</cfcase><!--- 10-15 days --->
				<cfcase value=30>dateAdd(day,15,getdate())</cfcase><!--- 15-30 days --->
				</cfswitch>
				and dateAdd(day,#exp#,getdate())
		<cfelse>
		where ExpirationDate <= GetDate()
		</cfif>
		and id_status not in (10,11,12,13,15)
		Order by ExpirationDate asc
	</cfquery>
	<cfquery name="Sum" datasource="#Application.dsn#">
		Select Sum(amountTotal) as dollars
		from v_ara
		<cfif exp NEQ 0>
		where ExpirationDate Between  
				<cfswitch expression="#exp#">
				<cfcase value=5>GetDate()</cfcase><!--- next 5 days --->
				<cfcase value=10>dateAdd(day,5,getdate())</cfcase><!--- 5-10 days --->
				<cfcase value=15>dateAdd(day,10,getdate())</cfcase><!--- 10-15 days --->
				<cfcase value=30>dateAdd(day,15,getdate())</cfcase><!--- 15-30 days --->
				</cfswitch>
				and dateAdd(day,#exp#,getdate())
		<cfelse>
		where expirationDate <= GetDate()
		</cfif>
		and id_status not in (12,13,7,10)
		<!---<cfif session.approval_level LT 10><!--- Group Level or Lower, only let them see group --->
		and (grp='#session.group#' or grp IN ('#session.approve_grp#'))	
		<cfelseif listFind('10,11,12',session.approval_level)><!--- Sector level, can see everything in their sector --->
		and sector='#session.sector#'
		</cfif>--->
	</cfquery>
	
	<cfif Sum.dollars GT 0>
		<cfset  exp_sums=ListAppend(exp_sums,Numberformat(Sum.dollars,"9999"))>
	<cfelse>
		<cfset  exp_sums=ListAppend(exp_sums,"0")>
	</cfif>
		
		
	<tr>
		<td class="border" align="right">
		<cfswitch expression="#exp#">
				<cfcase value=0>Already expired <cfset smtitle="Already Expired ARAs"> </cfcase>
				<cfcase value=5>Next 5 days <cfset smtitle="Expire in the next 5 days"></cfcase><!--- next 5 days --->
				<cfcase value=10>5 to 10 days <cfset smtitle="Expire in the next 5-10 days"></cfcase><!--- 5-10 days --->
				<cfcase value=15>10 to 15 days <cfset smtitle="Expire in the next 10-15 days"></cfcase><!--- 10-15 days --->
				<cfcase value=30>15 to 30 days <cfset smtitle="Expire in the next 15-30 days"></cfcase><!--- 15-30 days --->
	  </cfswitch></td>
		<td class="border" align="center"><!---  Count of ARAs  --->
			<cfset ids=ValueList(Ex.id_ara)>
			<cfif listLen(ids) GT 0>
				<cfif listLen(ids) EQ 1><!--- Go directly to ara detail page --->
					<cfset AID=#encrypt(Ex.id_ara,request.encryptKey,request.encryptType,'hex')#>
					<a class="embed" href="index.cfm?fuseaction=app.ARA_PM&id_ara=#Ex.id_ara#&AID=#AID#">#listLen(ids)#</a>
				<cfelse>
					<cfset title="ARAs Pending Expirations">
					#listLen(ids)#
				</cfif>
			<cfelse>
				0
			</cfif>
			<cfset total_count=val(total_count+(listlen(ids)))>
		</td>
		<td align="right" class="border"><!--- Total, summed amount --->
		$#numberformat(Sum.Dollars,"9,999")#
		<cfset total_dollars=val(total_dollars + (numberformat(sum.dollars,"9999")))>
		</td>	
	</tr>
	
</cfloop>
<tr bgcolor="##EEEEEE">
	<td class="border" align="right">Totals</td>
	<td align="center" class="border">#total_count#</td>
	<td align="right" class="border">$<cfoutput>#Numberformat(total_dollars,"9,999")#</cfoutput></td>
</tr>
	
</table>

</td>
<td width=25>
	<img src="images/spacer.gif" width=25>
</td>
<td align="right" width="560" valign="top">
<cfset listptr=1>
<cfchart
     format="png"
	 chartheight="250"
	 chartwidth="560"
 	 xAxistitle = "DAYS TILL EXPIRES"
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
			<cfloop index="i" list="#exp_sums#">
					<cfset this_Sum=#numberformat(Listgetat(exp_sums,listptr),"9999")#>
					<cfset this_cnt=#Listgetat(expires,listptr)#>
					<cfchartdata item="#this_cnt#" value="#this_sum#">
					<cfset Listptr=#listptr# + 1>
			</cfloop>
</cfchartSeries>
</cfchart>

</td></tr>
</table>
</cfoutput>