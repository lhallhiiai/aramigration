
<cfparam name="basedate" default=#dateformat(now(),"MM/DD/YY")#>
<!--- Set a window that will include the previous and next month --->
<cfset Start_Date=#Dateformat((DateAdd('m', -2, basedate)),'MM/DD/YY')#>
<cfset End_Date=#Dateformat((DateAdd('m', 3, basedate)),'MM/DD/YY')#>

<!--- cfoutput>start_date is #start_date#<br>
end_date is #end_date#</cfoutput --->
<!--- Corporate close dates --->
<cfquery name="CorpClose" datasource="#APPLICATION.ajes#">
	Select convert (nvarchar(100),date_close,101) as close_dt
	from t_dates_close
	where datetype='c'
	and date_close BETWEEN '#start_date#' AND '#end_date#'
	order by close_dt ASC
</cfquery>
<!--- Ops close dates --->
<cfset CloseList=#Valuelist(CorpClose.close_dt)#>

<cfquery name="OpsClose" datasource="#APPLICATION.ajes#">
	Select convert (nvarchar(100),date_close,101) as close_dt
	from t_dates_close
	where datetype='o'
	and date_close BETWEEN '#start_date#' AND '#end_date#'
	order by close_dt ASC
</cfquery>
<cfset OpList=#Valuelist(OpsClose.close_dt)#>
<!--- AP Travel close dates --->

<cfquery name="TravelClose" datasource="#APPLICATION.ajes#">
	Select convert (nvarchar(100),date_close,101) as close_dt
	from t_dates_close
	where datetype='a'
	and date_close BETWEEN '#start_date#' AND '#end_date#'
	order by close_dt ASC
</cfquery>
<cfset TravelList=#Valuelist(TravelClose.close_dt)#>
<!--- Month End ---->
<cfquery name="MonthEnd" datasource="#APPLICATION.ajes#">
	Select convert (nvarchar(100),date_close,101) as close_dt
	from t_dates_close
	where datetype='m'
	and date_close BETWEEN '#start_date#' AND '#end_date#'
	order by close_dt ASC
</cfquery>
<cfset MonthEndList=#Valuelist(MonthEnd.close_dt)#>

<!--- Holidays --->
<cfquery name="holidays" datasource="cae_ods">
	SELECT convert (nvarchar(100),Date,101) as Holiday 
  	FROM [cae_ods].[dbo].[Calendar]
  	where [Date] BETWEEN '#start_date#' AND '#end_date#'
  	and [Holiday] = 'Y'
	order by date
</cfquery>
<cfset Holidays=#ValueList(holidays.holiday)#>
<cfset Holidays=#Holidays# & ',02/01/2011'>
<!--- cfoutput>
Closelist #CloseList#<br>
Oplist #Oplist#<br>
Holidays #holidays#<br>
AP Travel #TravelList#<br>
MonthEnd #MonthEndList#

</cfoutput --->
<!--- M.Gann: Show month rotating calendar window --->



<style>
.holiday {
border: double 4px #ffa300;
font-family: Trebuchet MS, helvetica, sans-serif;
font-size: 11px;
color:#782828;
}
.ops {

background-color:#005470;
color:#000000;
font-family: Trebuchet MS, helvetica, sans-serif;
font-size: 11px;
color:#ffffff;
}
.today {

background-color: #ffa300;
font-family: Trebuchet MS;
font-size: 11px;
border: solid 1px dddddd;
}
.corpclose {

background-color: #cccccc;
font-family: Trebuchet MS, helvetica, sans-serif;
font-size: 11px;
color:#444444;
}
.travel {
background-color: #e0592a;
font-family: Trebuchet MS, helvetica, sans-serif;
font-size: 11px;
color:#FFFFFF;
}
.monthend {
background-color: #000000;
font-family: Trebuchet MS, helvetica, sans-serif;
font-size: 11px;
color:#FFFFFF;
}

.transparent {
opacity: 0.4;
filter:alpha(opacity=40);
-moz-opacity:0.4; 
-khtml-opacity: 0.4;  
}
.transparent:hover {
opacity: 1;
filter:alpha(opacity=100);
-moz-opacity:1.0; 
-khtml-opacity: 1.0;  
border-color: #000000;
}
.border {
border: solid 1px #cccccc;
color: #999999;
}
</style>

<!--- Is this  a leap year? --->
<cfset Y=#val(dateformat(now(),"YYYY"))#>
<cfset thisMo=#dateformat(now(),"MM")#>
<cfif (#Y# MOD 4) EQ 0>
	<cfset FebCnt=29>
<cfelse>
	<cfset FebCnt=28>
</cfif>
<!--- Three lists: Name of month, Num of Month, day_count in month --->
<cfset MoList="January, February, March, April, May,June,July,August,September,October,November,December">
<cfset MoIndex="01,02,03,04,05,06,07,08,09,10,11,12">
<cfset MoCnt="31,#Febcnt#,31,30,31,30,31,31,30,31,30,31">
<cfset ThisMo=#dateformat(Now(),"MM")#>
<cfset ThisDay=#dateformat(now(),"DD")#>

<cffunction name="Build_Cal">
	<cfargument name="last_this_next" required="yes">
	<cfargument name="year" required="no"><!--- Will assume this year --->
		<cfoutput>
		
			<cfswitch expression="#last_this_Next#">
			<cfcase Value="Last"><!--- Last Month --->
				<cfif thisMo EQ 01><!--- If January --->
					<cfset lastMo=12>
					<cfset thisdate="#lastMo#/1/" & #Val(dateformat(Now(),"YYYY")-1)#>
					<cfset longdate="#listgetat(MoList,lastMo)# #Val(dateformat(Now(),"YYYY")-1)#">
				<cfelse>
					<cfset lastMo=#Val(ThisMo)#-1>
					<cfset thisdate="#lastMo#/01/#y#">
					<cfset longdate="#listgetat(MoList,lastMo)# #y#">
				</cfif>
				<cfset day_total=#listgetat(moCnt,lastMo)#>
			</cfcase>
			<cfcase Value="This"><!--- This Month --->
					<cfset thisdate="#thisMo#/01/#y#">
					<cfset longdate="#listgetat(molist,thismo)# #y#">
					<cfset day_Total=#listgetat(moCnt,thisMo)#>
					<style>
					.border {
					color:##000000;
					}
					</style>
			</cfcase>
			<cfcase value="Next"><!--- Next Month --->
					<cfif thisMo EQ 12><!--- If december --->
						<cfset nextMo=01>
						<cfset thisdate="#NextMo#/01/" & #Val(dateformat(Now(),"YYYY")+1)#>
						<cfset longdate="#ListgetAt(MoList,NextMo)# #Val(dateformat(Now(),"YYYY")+1)#">
					<cfelse>
						<cfset NextMo=#Val(ThisMo)#+1>
						<cfset thisdate="#NextMo#/01/#y#">
						<cfset longdate="#ListgetAt(MoList,NextMo)# #Y#">
					</cfif>
					<cfset day_Total=#listgetat(moCnt,NextMo)#>
			</cfcase>
			</cfswitch>
	<table cellpadding=2 cellspacing=2 
	<cfif (#last_this_Next# EQ 'Last') OR (#last_this_Next# EQ 'Next')>  style="border: solid 1px grey;"
	<cfelse> class="outerborder" style="border:solid 2px black;"></cfif>
		<tr><!---  H E A D E R --->
			<td class="border" colspan=7 align="center">
			#longdate#
		</td></tr>
			<td class="border">S</td>
			<td class="border">M</td>
			<td class="border">T</td>
			<td class="border">W</td>
			<td class="border">T</td>
			<td class="border">F</td>
			<td class="border">S</td>
		</tr>
		<tr><!--- Starting week --->
			<cfset DOW=#dayofweek(thisDate)#>
			<cfset count=1>
			<cfset day_count=1>
			#thisDate# #dow#
			<CFLOOP INDEX="count" FROM="1" TO="7" STEP="1">
				<cfset day=#ListDeleteAt(thisdate, "2", "/")#>
				
				<cfset day=#ListInsertAt(day,2,day_count,"/")#>
				<cfset day=#dateformat(day,"MM/DD/YYYY")#>
				<cfif #count# LT #DOW#><!--- month not started yet --->
					<td class="border">&nbsp;</td>
				<cfelseif  #count# GTE #DOW#>
					<td 
					<cfif (#last_this_next# EQ "This") AND (#day_count# EQ #ThisDay#)>
					class="today"
					<cfelseif #find(day,holidays)#>
					class="holiday" title="Company Holiday"
					<cfelseif #find(day,oplist)#>
					class="ops"  title="Operations Closing"
					<cfelseif #find(day,closelist)#>
					class="corpclose"  title="Corporate Close"
					<cfelseif #find(day,travellist)#>
					class="travel"   title="Period Close">
					
					<cfelse>
					class="border"
					</cfif>
					>#day_count#</td>
					<cfset day_count=#day_count# +1>
				</cfif>
			</CFLOOP>
		</tr>
		
		
<cfloop condition="#day_count# LTE #day_total#">
		
	<cfset td_cnt=1>
	<tr>
		<cfloop index="td_cnt" from="1" to="7" Step="1">
			<cfif day_count LTE day_total>
				<cfset day=#ListDeleteAt(thisdate, "2", "/")#>
				<cfset day=#ListInsertAt(day,2,day_count,"/")#>
				<cfset day=#dateformat(day,"MM/DD/YYYY")#>
					
					<td <cfif (#last_this_next# EQ "This") AND (#day_count# EQ #ThisDay#)>
					class="today" title="today"
					<cfelseif #find(day,holidays)#>
					class="holiday" title="Company Holiday"
					<cfelseif #find(day,oplist)#>
					class="ops"  title="Operations Closing"
					<cfelseif #find(day,closelist)#>
					class="corpclose"  title="Corporate Close"
					<cfelseif #find(day,travellist)#>
					class="travel"   title="Travel Close"
					<cfelseif #find(day,monthendlist)#>
					class="monthend"   title="End of Month"
					<cfelse>
					class="border"
					</cfif>
					>#day_count#</td>
						<cfset day_count=#day_count# + 1>

			<cfelse>
				<td class="border">&nbsp;</td>
			</cfif>
					
</cfloop>
			</tr>
		</cfloop>		
		</table>
		</cfoutput>
</cffunction>

<cfif (Len(CloseList) GT 0) and (Len(TravelList) GT 0) and (Len(oplist GT 0))>
<table border=0 cellpadding=8>
	<tr>
		<td colspan=3 align="center">
		<p class="close">Two Month Accounting Calendar</p>
		</td>
	<tr>
	<td valign="top" align="center"><!--- this month --->
		<cfoutput>#build_cal('This')#</cfoutput>
	</td>
	<td>
	<!--- center color key --->
	<table align="center"  class="border" cellpadding=0 border=0 cellspacing=0>
	<tr><td align="center" class="ops" style="padding:3px;border: solid 1px #999999;">Ops Close</td></tr>
	<tr><td align="center" class="corpclose" style="padding:3px;border: solid 1px #999999;">Corp Close</td></tr>
	<tr><td align="center" nowrap class="travel" style="padding:3px;border: solid 1px #999999;">Period Close</td></tr>
	<tr><td align="center" class="holiday" style="padding:3px;">Holidays</td></tr>
	<tr><td align="center" class="today" style="padding:3px;border: solid 1px #999999;">Today</td></tr>
	</table>
	
	<td valign="top" align="center"><!--- next month --->
		<cfoutput>#build_cal('Next')#</cfoutput>
	</td>
	</tr>
</table>
<cfelse>
<p class="close" style="text-align:left;font-size:18px;color:#af3610;">Unable to retrieve calendar dates. Notify CAE immediately.</p>
</cfif>


<!--- table align="center"  class="border" cellpadding=0 border=0 cellspacing=5>
<tr>

<td width=10 height=10 class="ops"><img src="images/spacer.gif" height=10 width=10></td>
<td class="tiny">Ops Close</td>
<td  width=10 height=10 class="corpclose"><img src="images/spacer.gif" height=10 width=10></td>
<td class="tiny">Corporate Close</td>
<td width=10 height=10  class="travel"><img src="images/spacer.gif" height=10 width=10></td>
<td class="tiny" height=10>Travel Close</td>
<td width=10 width=10 height=10 class="monthend"><img src="images/spacer.gif" height=10 width=10></td>
<td   class="tiny" height=10>Month End</td>
<td width=10 height=10 class="holiday"><img src="images/spacer.gif" height=10 width=10></td>
<td  class="tiny" width=10 height=10>Holidays</td>
<td width=10 height=10 class="today"><img src="images/spacer.gif" height=10 width=10></td>
<td  class="tiny" width=10 height=10>Today</td>
</tr></table>
<br><br --->
	
	
	