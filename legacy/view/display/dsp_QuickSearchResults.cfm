<!--- cfparam name="session.loggedIn" default="No">
<cfparam name="message" default="" --->
<cfparam name="activeSort" default="ara.id_status">
<cfoutput>

<p class="title">
Quick Search Results</p>
<p></p>
</cfoutput>
<!--- Quick Search Below Navaigation --->

<cfquery name="QS" datasource="#Application.dsn#">
select * 
FROM  v_ara  A
 where 1=1 and <cfif isdefined("url.SearchString")>A.reference LIKE '%#url.SearchString#%'
 or A.JamisNo LIKE '%#url.SearchString#%' 
 <cfelse>A.reference LIKE '%#SearchString#%'
 or A.JamisNo LIKE '%#SearchString#%'</cfif>
 <cfif session.id_job LTE 9><!--- Group Level or Lower, only let them see group --->
		and grp='#session.group#'
<cfelseif listFind('10,11,12',session.id_job)><!--- Sector level, can see everything in their sector --->
		and sector='#session.sector#'
		</cfif>
 <cfif isdefined("url.activesort")>
 ORDER BY '#url.activesort#'
 <cfelse>
 ORDER BY A.id_status
 </cfif>
 </cfquery>
 
 <p><cfoutput>
 A search was done using this search parameter: <strong><cfif isdefined("url.SearchString")>#url.SearchString#<cfelse>#searchstring#</cfif></strong><br>

 </p>
 </cfoutput>


 <cfif #QS.RecordCount# EQ 1><!--- Take directly to details --->
 	<cfset AID=#encrypt(QS.id_ara,request.encryptKey,request.encryptType,'hex')#>
   <cfswitch expression="#QS.id_status#">
   	<cfcase value="1,8,9,10,11,12,14">
	 	<cflocation url="index.cfm?Fuseaction=app.ARA_PM&AID=#AID#" Addtoken="No">
    </cfcase>
	<cfcase value="2,3,13"><!--- Submitted to contracts, exported --->
		<cflocation url="index.cfm?Fuseaction=app.ARA_ContractInfo&SubMenu=Contract&AID=#AID#" Addtoken="No">
	</cfcase>
	<cfcase value="4,5,16"><!--- Submitted to Controller or ES Complete --->
		<cflocation url="index.cfm?Fuseaction=app.ARA_ControllerV2&SubMenu=Controller&AID=#AID#" Addtoken="No">
	</cfcase>
	<cfcase value="6,7"><!--- Submitted to approval chain --->
		<cflocation url="index.cfm?Fuseaction=app.ARA_Approvals&SubMenu=Approvals&AID=#AID#" Addtoken="No">
	</cfcase>
   </cfswitch>
 <cfelseif #QS.RecordCount# GT 1>


<table cellpadding=2 width=100% cellspacing=2 class="border">
<cfoutput>
<tr>
	<td class="grad">&nbsp;</td>
	<td nowrap class="grad"><a href="#self#?fuseaction=app.QuickSearch&activesort=reference&SearchString=#SearchString#" class="embed">ID & Revision</a>
	<cfif activeSort EQ 'ara.reference'><img src="images/sort.png"></cfif></td>
	<td nowrap class="grad">CLINS</td>
	<td class="grad"><a href="#self#?fuseaction=app.QuickSearch&activesort=JamisNo&SearchString=#SearchString#" class="embed">JAMIS ##</a>
	<cfif activeSort EQ 'ara.JamisNo'><img src="images/sort.png"></cfif>
	</td>
	<td class="grad"><a href="#self#?fuseaction=app.QuickSearch&activesort=title&SearchString=#SearchString#" class="embed">Title</a>
	<cfif activeSort EQ 'ara.Title'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.QuickSearch&activesort=CustomerName&SearchString=#SearchString#" class="embed">Customer</a>
	<cfif activeSort EQ 'ara.CustomerName'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.QuickSearch&activesort=ExpirationDate&SearchString=#SearchString#" class="embed">Expiration</a>
	<cfif activeSort EQ 'ara.StartDate'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.QuickSearch&activesort=reference&SearchString=#SearchString#" class="embed" bgcolor="##EEEEEE">Awaiting Approval By</a></td>
	<td class="grad"><a href="#self#?fuseaction=app.QuickSearch&activesort=amountTotal&SearchString=#SearchString#" class="embed">Amount Total</a>
	<cfif activeSort EQ 'ara.AmountTotal'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.QuickSearch&activesort=id_status&SearchString=#SearchString#" class="embed">State</a>
	<cfif activeSort EQ 'ara.id_status'><img src="images/sort.png"></cfif></td>
</tr>
</cfoutput>
<cfset count=1>
<cfoutput query="QS">
<tr>
	<td class="border">#count#.</td>
	<cfset AID=#encrypt(id_ara,request.encryptkey,request.encrypttype,'hex')#></td>
	
	<td nowrap class="border"><a href="index.cfm?Fuseaction=app.ARA_PM&AID=#AID#&Menu=ARA_Detail" class="embed">#reference#</a></td>
	<td class="border">
		<cfquery name="CLINfo" datasource="#application.ods#">
			SELECT clin_no, clin_desc, end_date
			FROM jobcost.t_clin_master_ckis
			WHERE cnct_no = <cfqueryparam cfsqltype="cf_sql_varchar" value="#jamisNo#">
		</cfquery>
		#clinfo.recordcount#
	</td>
	<td nowrap class="border">#JamisNo#</td>
	<td class="border">#title#</td>
	<td class="border">#customerName#</td>
	<td class="border">#Dateformat(ExpirationDate,"MM/DD/YY")#</td>
	<td class="border" bgcolor="##EEEEEEE">TBD</td>
	<td class="border">#dollarformat(amountTotal)#</td>
	<td class="border">#statusName#</td>
	<cfset count=count+1>
</tr>
</cfoutput>
</table>
<cfelse>
<h3>No matching record found. Please try again.</h3>
 </cfif>
