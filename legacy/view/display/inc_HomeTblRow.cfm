
<cfoutput>

<tr>
	<td valign="top" class="border">#count#.</td>
	<cfset AID=#encrypt(id_ara,request.encryptkey,request.encrypttype,'hex')#></td>
	
	<td valign="top" nowrap class="border">
	
	<cfif ((ID_contract EQ session.id_user) OR (FindnoCase(id_contract,session.delegators)))><!--- This is the contract manager for this ARA --->
			<cfset Faction="app.ARA_ContractInfo">
	<cfelseif ((ID_controller EQ session.id_user) OR (FindnoCase(id_controller,session.delegators)))>
		<cfset Faction="app.ARA_ControllerV2">
	<cfelseif ((ID_PM EQ session.id_user) OR (FindnoCase(id_PM,session.delegators)))>
		<cfset Faction="app.ARA_PM">
	<cfelse>
		<cfset Faction="app.ARA_PM">
	</cfif>
	<cfif id_status GT 5><!--- take right to approval tab --->
		<a href="index.cfm?Fuseaction=app.ARA_approvals&AID=#AID#&ID_Status=#id_status#&Menu=ARA_Detail" class="embed">#reference#</a>
	<cfelse>
		<a href="index.cfm?Fuseaction=#Faction#&AID=#AID#&ID_status=#id_status#&Menu=ARA_Detail" class="embed">#reference#</a>
		
	</cfif>
	<br><font style="font-size: 7px;font-family:Trebuchet MS;text-transform:uppercase;" >Expires: #dateformat(ExpirationDate,"MM/DD/YY")#</font>
	</td>
	<!--- td valign="top" class="border" --->
		<cfquery name="CLINfo" datasource="#application.ods#">
			SELECT clin_no, clin_desc, end_date
			FROM jobcost.t_clin_master_ckis
			WHERE cnct_no = <cfqueryparam cfsqltype="cf_sql_varchar" value="#jamisNo#">
		</cfquery>
		
	<!--- /td ---> 
	<td valign="top"class="border">
	<cfif id_status EQ 8 or ID_status EQ 9>
		<font class="red">REJECTED
	<cfelse>
		#OneWord#
	</cfif>
	</td>
	<td valign="top" class="border" width=100 bgcolor="##EEEEEEE">
		<cfset ara_id=#id_ara#>
		<!--- cfinclude template="../../model/m_ara/GetCurrentApprover.cfm" --->
		
		<cfinclude template="../../model/m_ara/qry_GetApprovalChain.cfm">
		<!--- Getapproval chain returns 2 lists: Pmcc_list, and thresh_list the list of everyone in the approval matrix --->
		<cfswitch expression="#id_status#">
		<cfcase value="1,8,9"><!--- PM --->
			<cfset this_user=Usr_Details(ListGetat(pmcc_list,1))>
			<cfset next_app=ListGetat(pmcc_list,1)>
		</cfcase>
		<cfcase value="2,3"><!--- Contracts --->
			<cfset this_user=Usr_Details(ListGetat(pmcc_list,2))>
			<cfset next_app=ListGetat(pmcc_list,2)>
		</cfcase>
		<cfcase value="4,5"><!--- Controller --->
			<cfset this_user=Usr_Details(ListGetat(pmcc_list,3))>
			<cfset next_app=ListGetat(pmcc_list,3)>
		</cfcase>
		<cfcase value="6"><!--- Into the Approval Chain --->
			
			<cfset delegatee=User_org.DelegateTo_oprid>
			<cfset this_user=Usr_Details(User_org.id_user)>
<!--- cfdump var="#user_org#" format="text" --->
		</cfcase>
		</cfswitch>
		<cfif u_info.id_job NEQ 13>
			<b>#u_info.oprid#</b> <br>
			<font style="font-size: 7px;font-family:Trebuchet MS;text-transform:uppercase;" >#u_info.title# </font>
			<cfif (isDefined('Delegatee') and Delegatee NEQ "")>
				<br><font style="font-size: 7px;font-family:Trebuchet MS;text-transform:uppercase;color:##77032a;" >DELEGATED TO:</font>
				<br><b>#delegatee#</b>
				<cfset delegatee="">
			<cfelse>
			</cfif>
		<cfelse>
			<b>FINAL: Contract Setup (CCS)</b>
		</cfif>
	</td>
	<td valign="top" nowrap class="border">#JamisNo#</td>
	<td valign="top" class="border">#title#</td>
	<td valign="top" class="border">#customerName#</td>
	<!--- td class="border">#Dateformat(startDate,"MM/DD/YY")#</td --->
	
	<td valign="top" align="right" class="border">$#numberformat(amountTotal,"9,999")#</td>
	
	<td class="border">
		<a href="index.cfm?Fuseaction=app.DeleteEntireARA&AID=#Aid#"><img src="images/SmDelete.png" border=0></a>
	</td>
	<cfset count=count+1>
</tr>
</cfoutput>