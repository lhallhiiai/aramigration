<cfsetting requestTimeOut="6000">
<cfparam name="startrow" default=1>
<cfif NOT isDefined('url.maxrows')>
	<cfset maxrows=30>
<cfelse>
	<cfset maxrows=url.maxrows>
</cfif>
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
	
	<cfquery name="ARAOprid" datasource="#application.dsn#">
		select oprid,empname from users
		where id_user=#id#
	</cfquery>
	<cfquery name="GetOprid" datasource="#application.ods#">
		Select oprtr_id 
		from empl_ckis
		where oprtr_id='#ARAOprid.oprid#'
	</cfquery>
	<cfif ARAOprid.recordcount GT 0>
		<cfset name=ARAOprid.empname>
	<cfelse>
		<cfif id NEQ "">
			<cfquery name="getOprid" datasource="#application.dsn#">
				Select oprid from users 
				where id_user=#id#
			</cfquery>
			<cfset name="<font color='##af3610;font-size:10px;'>#ARAOprid.oprid# (Gone)</font>">
		<cfelse>
			<cfset name="<font color='##af3610;font-size:10px;'>#ARAOprid.empname# (Gone)</font>">
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
	<cfif ClinAmt.cost_total NEQ "" and ClinAmt.fee_total NEQ "">
		<cfset jamisTotal=Val(ClinAmt.cost_total+ClinAmt.fee_total)>
	<cfelse>
		<cfset jamisTotal='None'>
	</cfif>
		
	<cfreturn jamisTotal>
</cffunction>

<cfquery name="getLog" datasource="#Application.dsn#">
		Select  id_ara from ara 
		where 1=1
		<cfif session.id_job NEQ 13 and session.id_role NEQ 2><!--- Not CCS or Sys admin --->
		and ((id_pm = '#session.id_user#') or (id_contract = '#session.id_user#') or (id_controller = '#session.id_user#')) 
		</cfif>
		and id_status in (12,13,18) 
		order by #sortBy#
</cfquery> 
<!---<cfdump var="#getLog#" format="text" top=1>--->



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
	</cfif>
	
	&nbsp;&nbsp;|&nbsp;&nbsp;
	<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=1&maxrows=#getlog.recordcount#&sortBy=#sortBy#">Show All</a>
	
	</p>
	
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
		<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&Sortby=Reference asc">ARA Reference</a>
		<cfif sortby EQ 'reference ASC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&Sortby=Reference DESC"><img src="images/asc.gif" border=0></a>
		<cfelseif sortBy EQ 'reference DESC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&SortBy=Reference ASC"><img src="images/desc.gif" border=0></a>
		</cfif>
	</td>
	<td align="center" class="border">
		<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&Sortby=amountTotal Desc">ARA Amount</a>
		<cfif sortby EQ 'amountTotal ASC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&Sortby=amountTotal DESC"><img src="images/asc.gif" border=0></a>
		<cfelseif sortBy EQ 'amountTotal DESC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&SortBy=amountTotal ASC"><img src="images/desc.gif" border=0></a>
		</cfif>
	</td>
	<cfif session.id_job EQ 13>
	<td class="border" align="center" style="width:120px;">
		<font style="font-family: Trebuchet MS;font-size:8px;text-transform:uppercase;">Risk Cost + Fee</font><br>
		CostPoint Amount
	</td>
	</cfif>
	<td class="border">
		<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&Sortby=JamisNo ASC">Costpoint Project Number</a>
		<cfif sortby EQ 'JamisNo ASC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&Sortby=JamisNo DESC"><img src="images/asc.gif" border=0></a>
		<cfelseif sortBy EQ 'JamisNo DESC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&SortBy=JamisNo ASC"><img src="images/desc.gif" border=0></a>
		</cfif>
	</td>
	<td align="center" class="border">
		<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&Sortby=expirationDate ASC">Expiration Date</a>
		<cfif sortby EQ 'expirationDate ASC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&Sortby=expirationDate DESC"><img src="images/asc.gif" border=0></a>
		<cfelseif sortBy EQ 'expirationDate DESC'>
			<a class="embed" href="index.cfm?fuseaction=#returnTo#&startrow=#startrow#&maxrows=#maxrows#&SortBy=expirationDate ASC"><img src="images/desc.gif" border=0></a>
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
		$#Numberformat(s_sums.dollars,"9,999.99")#

		<cfset total_amount=val(total_amount + (numberformat(s_sums.dollars,"9999")))>
		<!--- Get Jamis Amount to compare --->
		<cfset jtotal=JamisInfo(id_ara)>
		</td>
		<cfif session.id_job EQ 13><!--- Only show to CCS --->
			<td class="border" align="right" <cfif (s_sums.dollars NEQ jtotal) AND (jtotal NEQ 0)>bgcolor="##FFFFCC"</cfif>>
			<cfif (s_sums.dollars NEQ jtotal) AND (jtotal NEQ 0)><span class="red" style="font-size:8px;">(DIFF)</span></cfif>
			<cfif jtotal NEQ 'None'>
			$#Numberformat(jtotal,"9,999.00")#
			<cfelse>
			#jtotal#
			</cfif>
			
			</td>
		</cfif>
		<td class="border" align="center">#thisARA.JamisNo#</td>
		
		<td class="border" align="center">#dateformat(thisARA.expirationDate,"mm/dd/yy")#</td>
		
		<td class="border">#Ucase(ChkEmpl(thisARA.PMName,thisARA.id_pm))#</td>
		<td class="border">#Ucase(ChkEmpl(thisARA.ContractName,thisARA.id_contract))#</td>
		<td class="border">#Ucase(ChkEmpl(thisARA.ControllerName,thisARA.id_controller))#</td>
		<td class="border" align="center">
			<cfif (thisARA.id_status EQ 12 or thisARA.id_status EQ 18)  and ((thisARA.id_contract EQ session.id_user or (isdefined("id_usr") and id_usr EQ session.id_user)) or session.id_job EQ 13 or session.id_job EQ 18)>
				<a class="embed" href="index.cfm?fuseaction=app.Negation&id_status=#thisARA.id_status#&id_contract=#thisARA.id_contract#&divshow=View&id_ara=#thisARA.id_ara#">Negate</a></td>
				
			<cfelse>
				<font style="font-size:8px;font-family:Trebuchet MS;color:##999999;">CONTRACT ADMIN</font>
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
		<font style="font-size:9px;font-family:Trebuchet MS;color:##222222;text-transform:uppercase;">
		ARAs where the risk has been eliminated (funding approved) are negated by the contract admin or, if unavailable,  CCS.</font>
	</td>
		
</tr>
</table>
</cfoutput>