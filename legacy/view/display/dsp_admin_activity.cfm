<cfset pagetitle="Risk Category Analysis">

<!--- +++++++++++++++++++++++++ TABLE HEADER ++++++++++++++++++++++++++++++ --->
<table width="100%" cellpadding="2" cellspacing="2" class="border">
<tr bgcolor="#EFEFEF">
	<td width=290 rowspan=2  colspan=2 valign="bottom" BGCOLOR="#FFFFFF" class="border">
	<p class="smtitle">&nbsp;&nbsp;DashBoard</p>
	<p class="title"><cfoutput>&nbsp;&nbsp;#pagetitle#</cfoutput>
	</td>
	
	<td class="border" colspan=2 align="center">IN PROCESS</td>
	<td class="border" colspan=2 align="center">COMPLETED YTD</td>
</tr>
<tr bgcolor="#EFEFEF">

	<td class="border" width="80" align="right">Count / <font class="red">REJ</font></td>
	<td class="border" align="right">Total </td>
	<td class="border" width="80" align="right">Count </td>
	<td class="border" align="right">Total</td>
</tr>
<!--- +++++++++++++++++++++++++ TABLE HEADER ++++++++++++++++++++++++++++++ --->
<cfset count_total=0>
<cfset amount_total=0>
<cfset open_count=0>
<cfset open_total=0>
<cfset open_rej=0>
<cfset cat_list=""><!--- Used for pie-chart series --->
<cfset open_counts=""><!--- Used for Pie-chart series --->
<cfset all_counts=""><!--- Used for pie chart series --->
<cfset all_amounts=""><!--- Pie Chart List of Amounts --->
<!--- ARAs by Category, status is not cancelled --->
<cfquery name="ByCat" datasource="#Application.dsn#">
	SELECT category.color,category.Catname,ara.id_cat, Record_Count=Count(*),sum(ara.amountTotal) as Cat_Total
	FROM ara,category
	where ara.id_cat=category.id_cat AND ara.id_status <> 10
	<!--- where ara.id_cat=category.id_cat AND ara.id_status IN (12,13,15,16) --->
	GROUP BY ara.id_cat,category.CatName,category.color
</cfquery>
<cfset colorList="">
<cfquery name="cats" datasource="#Application.dsn#">
	Select id_cat,catName,color
    from category
	where id_cat <> 3
	Order by RiskLevel, id_cat
</cfquery>
<cfset catIDs=ValueList(cats.id_cat)>
<cfset catNames=ValueList(cats.CatName)>
<cfset colors=ValueList(cats.Color)>
<cfset loopcount=1>
<cfloop index="c" List="#catIDs#">
<cfoutput>
<tr>
	<td bgcolor="#ListGetat(colors,loopcount)#" width=5 class="border"><img src="images/spacer.gif" width=1 height=1>
	<!--- cfset colorList=ListAppend(colorlist,color) ---->
	</td><!--- Color Coding --->
	<td class="border"><!--- +++++++++++++++++++++++ CATEGORY NAME +++++++++++++++++++  --->
	<!--- #Catname# <cfset cat_List=ListAppend(cat_list,catName) --->
	#ListGetAt(CatNames,loopcount)#
	</td>
	
	<!--- +++++++++++++++++Current InProcess By Category+++++++++++++++  --->
	<cfquery name="OpenByCat" datasource="#Application.dsn#">
		SELECT category.Catname,ara.id_cat, Open_Record_Count=Count(*),sum(ara.amountTotal) as Cat_Total_Open
		FROM ara,category
		where ara.id_cat=category.id_cat AND ara.id_status in (1,2,3,4,5,6,8,9,11) and ara.id_Cat=#c#
		GROUP BY ara.id_cat,category.CatName
	</cfquery>
	<cfif OpenByCat.RecordCount GT 0>
		<cfset open_counts=ListAppend(open_counts,OpenByCat.Open_record_Count)>
		<cfset this_amt=numberformat(OpenByCat.Cat_Total_Open,"9999")>
	<cfelse>
		<cfset open_counts=ListAppend(open_counts,"0")>
		<cfset this_amt=0>
	</cfif>
	<cfset all_amounts=ListAppend(all_amounts,this_amt)>
	<!---                    IN PROCESS REJECTS                         --->
	<cfquery name="RejByCat" datasource="#Application.dsn#">
		SELECT Open_Rej_Count=Count(*)
		FROM ara,category
		where ara.id_cat=category.id_cat AND ara.id_status in (8,9)  and ara.id_cat=#c#
		GROUP BY ara.id_cat,category.CatName
	</cfquery>
	
	<cfif OpenByCat.Open_Record_Count NEQ "">
		<cfset open_count=val(open_count+OpenByCat.Open_Record_Count)>
		<cfset open_total=val(open_total+OpenByCat.Cat_Total_Open)>
	</cfif>
	<td class="border" align="right">
		<cfif OpenByCat.RecordCount GT 0>
			<a class="embed" href="index.cfm?fuseaction=app.home&pagequery=ByCategory&id_cat=#c#&status=Open&smtitle=#OpenByCat.Catname#&title=In Process By Category&Menu=Dashboard">#OpenByCat.Open_Record_Count#</a>
			<cfif RejByCat.Open_Rej_Count NEQ "">
			/ <font class="red">#RejByCat.Open_Rej_Count#</font>
			</cfif>
		<cfelse>
			0
		</cfif>
	</td>
	
	<!---                       Total Amount In Process                         --->
	<td class="border" align="right">
		#dollarformat(OpenByCat.Cat_Total_Open)#
	</td>
	<!--- +++++++++++++++++++++++ TOTAL YTD COMPLETED ARA COUNT +++++++++++++++++++  --->
	<td align="right" class="border">
	<cfquery name="Comp_Tot" datasource="#Application.dsn#">
		Select Count(*) as Comp_count
		from v_ara
		where id_cat=#c#
		and id_status > 11
	</cfquery>
	<cfif Comp_Tot.Comp_count GT 0>
	<a class="embed" href="index.cfm?fuseaction=app.home&pagequery=ByCategory&id_cat=#c#&status=Done&smtitle=#OpenByCat.Catname#&title=Completed This Year&Menu=Dashboard">#Comp_Tot.Comp_count#</a>
	<cfelse>
		0
		</cfif>
		</td>
	<cfset count_total=val(count_total + Comp_Tot.comp_count)>
	<!--- +++++++++++++++++++++++ TOTAL YTD DOLLARS +++++++++++++++++++  --->
	<td class="border" align="right">
	<cfquery name="Comp_Amt" datasource="#Application.dsn#">
		Select sum(amountTotal) as Comp_Dollars
		from v_ara
		where id_cat=#c#
		and id_status > 11
	</cfquery>
	<cfset this_amt=#val(Comp_Amt.Comp_Dollars)#>
		#dollarformat(Comp_amt.Comp_dollars)#
		
		<cfset amount_total=val(amount_total+this_amt)>
	</td>
	
</tr>
<cfset loopcount=loopcount+1>
</cfoutput>
</cfloop>
<cfoutput>
<tr bgcolor="##EFEFEF">
	<td class="border" colspan=2 align="right">TOTAL</td>
	<td class="border" align="right"><b>#open_count#</b></td>
	<td class="border" align="right"><b>#dollarformat(open_total)#</b></td>
	<td class="border" align="right"><b>#Count_total#</td>
	<td class="border" align="right"><b>#dollarformat(amount_total)#</b></td>
</tr>
</cfoutput>
</table>
<!--- Convert the category amounts to percentages of the total --->
<cfset percents=""><cfset total_percent=0>
<cfloop index="i" list="#all_amounts#">
	<cfset this_percent=val(i/open_total)>
	<cfset total_percent=val(total_percent+this_percent)>
	<cfset percents=ListAppend(percents,this_percent)>
</cfloop>
<cfoutput>
<table width=100% cellpadding=0 cellspacing=0>
<tr>
<td width=50%><!--- By Counts --->
<br><b>In Process Counts</b><br>
<cfchart
     format="png"
	 chartheight="325"
	 chartwidth="325"
 	 xAxistitle = "CATEGORY"
	 show3D="yes"
	 labelformat="number"
	 yaxistitle="Cummulative Amounts"
	 markersize=20
	font = "Trebuchet MS" 
  
    fontSize = "9"
	 seriesplacement="default">
	<cfchartseries
             type="pie"
             serieslabel="Sector"
			 paintStyle="raise"
   			 colorlist = "#colors#">
			<cfset Listptr=1>
			<cfloop index="i" list="#CatNames#">
					<cfset this_Cat=#Listgetat(CatNames,listptr)#>
					<cfset this_count=#Listgetat(open_counts,listptr)#>
					<cfchartdata item="#this_cat#" value="#this_count#">
					<cfset Listptr=#listptr# + 1>
			</cfloop>
</cfchartSeries>
</cfchart>
</td>
<td width=50%><!--- GRAPH 2:             By Percents --->
<br><b>In Process Percent of Dollars</b><br>
<cfchart
     format="png"
	 chartheight="325"
	 chartwidth="325"
 	 xAxistitle = "CATEGORY"
	 show3D="yes"
	 labelformat="percent"
	 yaxistitle="Cummulative Amounts"
	 markersize=20
	font = "Trebuchet MS" 
  
    fontSize = "9"
	 seriesplacement="default">
	<cfchartseries
             type="pie"
             serieslabel="Sector"
			 paintStyle="raise"
   			 colorlist = "#colors#">
			<cfset Listptr=1>
			<cfloop index="i" list="#CatNames#">
					<cfset this_Cat=#Listgetat(CatNames,listptr)#>
					<cfset this_pct=#Listgetat(percents,listptr)#>
					<cfchartdata item="#this_cat#" value="#this_pct#">
					<cfset Listptr=#listptr# + 1>
			</cfloop>
</cfchartSeries>
</cfchart>
</cfoutput>

</td>
</tr></table>



