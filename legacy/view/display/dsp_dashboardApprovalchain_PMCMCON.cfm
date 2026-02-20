<cfsetting requestTimeOut="6000">
<cfparam name="startrow" default=1>
<cfset maxrows=20>
<cfparam name="SortBy" default="expirationDate ASC">
<cfif isDefined('url.fuseaction')>
	<cfset returnTo=url.fuseaction>
<cfelse>
	<cfset returnTo="app.home">
</cfif>
	
<cfset total_count=0>
<cfset total_amount=0>

<!---  *********************************************************************  --->
<!---                                                                         --->
<!---                          F U N C T I O N S                              --->
<!---                                                                         --->
<!---  *********************************************************************  --->

<cffunction name="ChkEmpl"><!--- check if still here, and get oprid --->
	<cfargument name="fullname" required="yes">
	<cfargument name="id" required="yes">
	
	<cfquery name="GetOprid" datasource="#application.ods#">
		Select oprtr_id 
		from empl_ckis
		where full_name='#fullname#'
	</cfquery>
	<cfif GetOprid.recordcount GT 0>
		<cfset name=GetOprid.oprtr_id>
	<cfelse>
		<cfif id NEQ "">
			<cfquery name="getOprid" datasource="#application.dsn#">
				Select oprid from users 
				where id_user=#id#
			</cfquery>
			<cfset name="#getOprid.oprid#">
		<cfelse>
			<cfset name="#fullname#">
		</cfif>
	</cfif>
	<cfreturn name>
</cffunction>

<cffunction name="JamisInfo"><!--- Get Amounts that are in Jamis Risk Fields --->
	<cfargument name="this_id" required="yes">
	<cfquery name="clins" datasource="#Application.dsn#">
		Select ClinNo from Clins
		where id_ara=#this_id#
	</cfquery>
	<cfset ClinList=ValueList(clins.clinNo)>
	<cfquery name="clinAmt" datasource="#application.ods#">
		Select Sum(rev_risk_fund_cost) as cost_total, sum(rev_risk_fund_fee) as fee_total
		from jobcost.t_clin_master_ckis
		where clin_no in (<cfqueryparam cfsqltype="cf_sql_varchar" value="#ClinList#" list="yes">)
	</cfquery>
	<cfoutput>
	$#Numberformat((Val(ClinAmt.cost_total+ClinAmt.fee_total)),'9,999')#
	<!---<cfdump var="#clinAmt#" format="text">---></cfoutput>
</cffunction>

<cfquery name="getLog" datasource="#Application.dsn#">
		Select  id_ara from ara 
		where 1=1
		<cfif session.id_job NEQ 13 and session.id_role NEQ 2><!--- Not CCS or Sys admin --->
		and ((id_pm = '#session.id_user#') or (id_contract = '#session.id_user#') or (id_controller = '#session.id_user#')) 
		</cfif>
		and id_status in (12,13) 
		order by #sortBy#
</cfquery> 
<!---<cfdump var="#getLog#" format="text" top=1>--->

<br><br><p class="smtitle">ARAs Pending Negation<br><br></p>

<!---  *********************************************************************  --->
<!---                              NEXT AND PREVIOUS                          --->
<!---  *********************************************************************  --->
<cfoutput>
<cfif getlog.recordcount LT maxrows>
	<p>#getLog.Recordcount# ARAs.</p>  
<cfelse>
	<p>
	<cfif startrow GT 1><!--- Show previous if not on on first page --->
	<cfset prevStart=val(startrow-maxrows)>
	<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#prevstart#&sortBy=#sortBy#">Previous #maxrows#</a>
	&nbsp;&nbsp;|&nbsp;&nbsp;
	</cfif>
	#startrow# to #val(startrow+maxrows-1)# of #getlog.recordcount#
	<cfif val(startrow+maxrows) LTE getlog.recordcount><!--- Have more pages to show --->
	&nbsp;&nbsp;|&nbsp;&nbsp;
	<cfset nextStart=Val(startrow+maxrows)>
	<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#nextstart#&sortBy=#sortBy#">Next #maxrows#</a>
	</cfif></p>
</cfif>
</cfoutput>

<!---  *********************************************************************  --->
<!---                                H E A D E R                              --->
<!---  *********************************************************************  --->
<cfoutput>
<table cellpadding=2 cellspacing=2 width="100%" class="border">
<tr bgcolor="##EEEEEE">
	<td width=15>
	<td class="border" nowrap>
		<a class="embed" href="index.cfm?fuseaction=#returnTo#&Sortby=Reference asc">ARA Reference</a>
		<cfif sortby EQ 'reference ASC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&Sortby=Reference DESC"><img src="images/asc.gif" border=0></a>
		<cfelseif sortBy EQ 'reference DESC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&SortBy=Reference ASC"><img src="images/desc.gif" border=0></a>
		</cfif>
	</td>
	<td align="center" class="border">
		<a class="embed" href="index.cfm?fuseaction=#returnTo#&Sortby=amountTotal Desc">ARA Amount</a>
		<cfif sortby EQ 'amountTotal ASC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&Sortby=amountTotal DESC"><img src="images/asc.gif" border=0></a>
		<cfelseif sortBy EQ 'amountTotal DESC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&SortBy=amountTotal ASC"><img src="images/desc.gif" border=0></a>
		</cfif>
	</td>
	<td class="border">
		<i>Amt in CostPoint</i>
	</td>
	<td class="border">
		<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&Sortby=JamisNo ASC">CostPoint Number</a>
		<cfif sortby EQ 'JamisNo ASC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&Sortby=JamisNo DESC"><img src="images/asc.gif" border=0></a>
		<cfelseif sortBy EQ 'JamisNo DESC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&SortBy=JamisNo ASC"><img src="images/desc.gif" border=0></a>
		</cfif>
	</td>
	<td align="center" class="border">
		<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&Sortby=expirationDate ASC">Expiration Date</a>
		<cfif sortby EQ 'expirationDate ASC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&Sortby=expirationDate DESC"><img src="images/asc.gif" border=0></a>
		<cfelseif sortBy EQ 'expirationDate DESC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&SortBy=expirationDate ASC"><img src="images/desc.gif" border=0></a>
		</cfif>
	
	
	</td>
	
	<td align="center" class="border">
	PM</td>
	<td class="border">Contracts</td>
	<td class="border">Controller</td>
	<td align="center" class="border">Negate ARA</td>
</tr>
</cfoutput>



<!---  *********************************************************************  --->
<!---                              L O O P                                    --->
<!---  *********************************************************************  --->
<cfset counter=startrow>
<cfoutput query="getlog" startrow="#startrow#" maxrows="#maxrows#">
	<cfset aid=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
	
    <cfquery name="thisARA" datasource="#Application.dsn#">
		Select * from v_ara
		where id_ara = '#id_ara#'
	</cfquery>
	
    <cfif thisARA.recordcount GT 0>
	
    <cfquery name="S_Sums" datasource="#Application.dsn#">
		Select Sum(amountTotal) as dollars
		from ara
		where id_ara in (#getLog.id_ara#)
	</cfquery>
    
    <cfset total_count = total_count + 1>
	
	<tr>
		<td class="border">#counter#.</td>
		<td class="border" align="center">
			<a class="embed" href="index.cfm?Fuseaction=app.ARA_PM&AID=#AID#&Menu=ARA_Detail">#thisARA.reference#</a>
		</td>
		<td class="border" align="right">
		$#Numberformat(s_sums.dollars,"9,999")#
		<cfset total_amount=val(total_amount + (numberformat(s_sums.dollars,"9999")))></td>
		<td class="border" align="right"><i>#JamisInfo(id_ara)#</i></td>
		
		<td class="border" align="center">#thisARA.JamisNo#</td>
		<td class="border" align="center">#dateformat(thisARA.expirationDate,"mm/dd/yy")#</td>
		
		<td class="border"><font style="font-size:8px;font-family:Trebuchet MS;color:##999999;">#Ucase(ChkEmpl(thisARA.PMName,thisARA.id_pm))#</font></td>
		<td class="border"><font style="font-size:8px;font-family:Trebuchet MS;color:##999999;">#Ucase(ChkEmpl(thisARA.ContractName,thisARA.id_contract))#</font></td>
		<td class="border"><font style="font-size:8px;font-family:Trebuchet MS;color:##999999;">#Ucase(ChkEmpl(thisARA.ControllerName,thisARA.id_controller))#</font></td>
		<td class="border" align="center">
			<cfif thisARA.id_status EQ 13 and ((thisARA.id_contract EQ session.id_user or (isdefined("id_usr") and id_usr EQ session.id_user)) or session.id_job EQ 13 or session.id_role EQ 2)>
				<a class="embed" href="index.cfm?fuseaction=app.Negation&id_status=#thisARA.id_status#&id_contract=#thisARA.id_contract#&divshow=View&id_ara=#thisARA.id_ara#&returnTo=#returnTo#">Negate</td>
				
			<cfelse>
				--
			</cfif>
		</td>
		
	</tr>
	<cfset counter=counter+1>
    </cfif>
</cfoutput>
<cfoutput>
<tr bgcolor="##EEEEEE">
	
	<td class="border" colspan=3 align="right"><b>TOTAL</B>&nbsp;</td>
	
	<td align="right" class="border">$#numberformat(total_amount,"9,999")#</td>
	<td align="right" class="border" colspan=6>
		<font style="font-size:8px;font-family:Trebuchet MS;color:##222222;text-transform:uppercase;">
		ARAs where the risk has been eliminated (funding approved) are negated by the contract admin or, if unavailable CCS.</font>
	</td>
		
</tr>
</table>
</cfoutput>