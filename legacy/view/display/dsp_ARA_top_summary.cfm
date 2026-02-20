<cfinclude template="inc_tooltipContent.cfm">

<cfparam name="IsPrint" default="No">
<cfparam name="Thresh_list" default="">
<cfparam name="updateCore" default="No">
<cfparam name="core_del" default="">

<!--- cfset id_cat=ARAdetails.id_cat>
<cfset id_ara=ARAdetails.id_ara --->
<cfif isDefined('url.aid')>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cfelse>
	<b>An encrypted ARA id was not provided to dsp_ARA_top_summary which caused a fatal error. Please notify CAE.</b><cfabort>
</cfif>
<!--- +++++++++++ Pulls ARA, user, groups, sector, category, status ++++++++++ --->
<cfinclude template="../../model/m_ara/qry_ara.cfm">
<!---  Default to current cycle, provide links to other cycles --->
<cfquery name="AllCycles" datasource="#Application.dsn#">
	SELECT Distinct cycle
	From ARAapplog
	where id_ara=#id_ara#
	Order by cycle DESC
</cfquery>
<cfparam name="thiscycle" default="#ListGetAt(ValueList(Allcycles.cycle),1)#">

<cffunction name="Usr_Details">
	<cfargument name="this_user" required="yes">
	<cfset del_flag=""><cfset tip="">
	<cfquery name="u_info" datasource="#Application.dsn#">
		Select * from v_users
		where id_user = '#this_user#'
	</cfquery>
	<cfif u_info.sctr NEQ ""><!--- Then still a current user --->
		<cfset gone="No">
	<cfelse>
		<cfset gone="Yes">
	</cfif>
	<!--- if delegation in effect, need delegated to info --->
	<Cfif (u_info.fk_delegateTo_Id NEQ "") AND (u_info.sctr NEQ "")>
		<cfset del_flag="(d)">
		<cfset tip="#u_info.empname# has delegation in effect.">
		<cfset del_id=#u_info.fk_DelegateTo_ID#>
		<cfquery name="u_info" datasource="#Application.dsn#">
			Select * from v_users
			where id_user = '#del_id#'
		</cfquery>
		<cfset PMCC_list=ListAppend(PMCC_List,u_info.id_user)>
	</cfif>
	<cfset thisoprid=u_info.oprid>
	<cfset first_name=u_info.first_name>
	<cfset last_name=u_info.last_name>
	<cfset id_job=u_info.id_job>

	<cfset name="#u_info.empname#">
</cffunction> 



<cfoutput>

<!-- 1  --><table width=100% cellpadding=0 cellspacing=0 border=0>
<cfif isDefined('topMsg')>
	<tr>
	<td colspan=3>
	<cfif Type eq "C">
		<cfset confirmMsg=topMsg>
	<cfelseif Type eq "E">
		<cfset errorMsg=topmsg>
	<cfelse>
		<cfset message=topMsg>
	</cfif>
	<cfinclude template="dsp_Messages.cfm">
	</td>
	</tr>
</cfif>
<tr>
<td valign="top" <cfif isPrint EQ 'No'>width=65%<cfelse>width=450</cfif>><!--- Left top --->
	<cfif isPrint EQ "No">
	<fieldset><legend><b>ARA  #reference# Summary Data</b></legend>
	<cfelse>
		<fieldset><legend><b><font style="font-size: 9pt; font-family: Trebuchet MS;">ARA  #reference# Summary Data</b></font></legend>
	</cfif>
	<!-- 2 --><table cellpadding=2 width=100% cellspacing=2 class="border">
	<tr>
		<td colspan=4 align="center" class="greyblue">Risk Category: &nbsp;&nbsp;<font style="text-transform:uppercase;font-weight:bold;">#catName#</font>,
		<cfif isEAC EQ 'Yes'>
			&nbsp;&nbsp;&nbsp;EAC Related,
		</cfif>
		&nbsp;&nbsp;&nbsp;Risk Level: <b>#riskLevel#</b>
		</td>
		
	</tr>
	<tr>
		<td class="borderq">ARA Org:</td>
		<td colspan=3 class="border">#org#</td>
	</tr>
	<tr>
		<td  nowrap class="borderq">Customer</td>
		<td class="bordera" colspan=3>#customerName#</td>
	</tr><!-- 3 -->
	<tr>
		<td width=75 nowrap class="borderq">Status</td>
		<td class="bordera">
		<cfif (id_status EQ 8) or (ID_status EQ 9)>
			<font class="red"><img src="images/tabx.png">&nbsp;<b>REJECTED</b></font>
		<cfelse>
			<b>#statusName#</b>
		</cfif>
		</td>
		<td  nowrap class="borderq">Total ARA Amount</td>
		<td class="bordera">
		<cfif amountTotal GT 0>
			<b>#dollarformat(amountTotal)#</b>
		<cfelse>
		TBD by PM
		</cfif>
	</tr>
	<tr>
		<td  nowrap class="borderq">ARA ID Number</td>
		<td class="bordera">#reference#</td>
		<td  nowrap class="borderq">Revision Number</td>
		<td class="bordera">#revision#</td>
	</tr>
	<tr>
		<td  nowrap class="borderq">Project ID</td>
		<td  class="bordera">#jamisNo#</td>
		<td class="borderq">Revenue Recognition</td>
		<td colspan=2 class="border">#RevDescr#</td>
	</tr>
	
	

	
	<!-- /2 --></table>
	</fieldset>
</td>



<!---                         ARA People and Approvers                 --->


<td width=20><img src="images/spacer.gif" width=20></td>
<td <cfif isPrint EQ 'No'>width=35% <cfelse> width=250</cfif> valign="top">
<cfinclude template="../../model/m_ara/qry_getPMCMCon.cfm">
<cfinclude template="../../model/m_ara/qry_getApprovalChain.cfm">
<cfif isPrint EQ "No">
<fieldset><legend><b>Creators, Dates, Audit</b></legend>
<cfelse>
	<fieldset><legend><b><font style="font-size: 9pt; font-family: Trebuchet MS;">Creators, Dates</legend></font>

</cfif>
<!--- cfif Find(session.id_role,'1,2')><!--- allow them to request change to the core team --->
	<table cellpadding=2 border=0 align="right">
	<tr><td align="right">
	<img src="images/SmUpdate.png">&nbsp;<a class="embed" href="index.cfm?Fuseaction=app.ARA_ControllerV2&SubMenu=Controller&AID=#AID#&UpdateCore=Yes">Update Core Team</a>
	</td></tr></table>
</cfif --->


<!--- cfif (updateCore EQ "Yes") and (Find(session.id_role,'1,2')) ><!--- All sysAdmin to change Core Team --->
	<form method="Post" action="index.cfm?fuseaction=app.PMCMCON_Update&AID=#url.aid#" id="People" name="People">
</cfif>
<input type="hidden" name="id_ara" value="#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#">
<input type="hidden" name="id_status" value="#id_status#">

--->	
	<!-- 2 --><table cellpadding=2 width=100% cellspacing=2 class="border">
		<tr>
			<td colspan=2 class="borderq">Created By</td>
			<td class="border">
			
			#GetARA.CreatorName#
		</tr>
<!--- **********************************************************  --->
<!---   Program Manager Top Right                                --->
<!--- ********************************************************** --->

<tr>
			<td colspan=2 class="borderq">Program Manager</td>
			<td class="border">
			
			<cfset PM_ID=ListGetat(PMCC_List,1)>
			<cfset PM=Usr_Details(PM_ID)>
			<cfif PM_id NEQ 0 and updateCore EQ 'No'>
					#name#
					<!--- input type="hidden" name="id_controller" value="#PM_ID#" --->
				<cfif tip NEQ "">
					<a class="embed" href="index.cfm?fuseaction=app.AdminDelegate" title="#tip#">(d)</a>
				</cfif>
				</td>
			<cfelse>
					<cfset pm=#Get_PM()#>
					<CFIF GetPM.RecordCount EQ 0>
						No contract ARA users in sector.
					<cfelse>
						<!--- 
						<select class="inputtext" name="ID_PM">
							<option value="">-- Select ---</option>
							<cfloop query="GetPM">
								<option value="#GetPM.ID_User#" <cfif #GetPM.ID_User# EQ #PM_id#>Selected</cfif>>#GetPM.empname#</option>
							</cfloop>
						</select>
						<input type="hidden" name="curPM" value="#PM_ID#">
						--->
					</cfif>
				
			</cfif>
		</tr>
<!--- **********************************************************  --->
<!---   Contract Manager Top Right                                --->
<!--- ********************************************************** --->
		<tr>
			
			<cfset contract_ID=#ListGetat(PMCC_List,2)#>
			<cfset Contract=Usr_Details(Contract_ID)>
            <cfset del_flag="">
			<cfif contract_id NEQ 0 and updateCore EQ 'No'>
				<td colspan=2 class="borderq">Contract Mgr </td>
				<td class="border">
				#name# 
				<!--- input type="hidden" name="id_contract" value="#contract_ID#" ---> 
				<cfif tip NEQ "">
					<a class="embed" href="index.cfm?fuseaction=app.AdminDelegate" title="#tip#">(d)</a>
				</cfif>
			<cfelse>
				<td colspan=2 class="borderq"> Contract Mgr</td>
				<td class="border">
					<cfset contr=#Get_Contract()#>
					<CFIF GetContract.RecordCount EQ 0>
						No contract ARA users in sector.
					<cfelse>
						<!---
						<select class="inputtext" name="ID_Contract">
							<option value="">-- Select ---</option>
							<cfloop query="GetContract">
								<option value="#GetContract.ID_User#" <cfif #GetContract.ID_User# EQ #contract_id#>Selected</cfif>>#GetContract.empname#</option>
							</cfloop>
						</select>
						<input type="hidden" name="curContract" value="#contract_id#">
						--->
					</cfif>
			</td>
			</cfif>
			
			
		</tr>
<!--- **********************************************************  --->
<!---   Controller   Top Right                                --->
<!--- ********************************************************** --->
		<tr>		
			<cfset controller_ID=#ListGetat(PMCC_List,3)#> 
			<cfset Controller=Usr_Details(controller_ID)>            
            <cfset del_flag="">
			<cfif controller_id NEQ 0 and updateCore EQ 'No'>
				<td colspan=2 class="borderq">Controller</td>
				<td class="border">
				#name# 
				
				<input type="hidden" name="id_controller" value="#controller_ID#">
				<cfif tip NEQ "">
					<a class="embed" href="index.cfm?fuseaction=app.AdminDelegate" title="#tip#">(d)</a>
				</cfif>
				
			<cfelse><!--- Controller not yet assigned --->
				<td colspan=2 class="borderq">
				Controller</td>
				<td class="border">
					<cfset contr=#get_Controller()#>
					<CFIF GetController.RecordCount EQ 0>
						No contract ARA users in sector or group.
					<cfelse>
						<!--- <select class="inputtext" name="ID_Controller">
							<option value="">-- Select ---</option>
							<cfloop query="GetController">
								<option value="#GetController.ID_User#" <cfif GetController.ID_user EQ controller_id>Selected</cfif>>#GetController.empname#</option>
							</cfloop>
						</select>
						--->
						<input type="hidden" name="curController" value="#controller_id#">
					</cfif>
			</td></cfif>
			<!---
			<cfif updateCore EQ "Yes" and Find(session.id_role,'1,2')><!--- All sysAdmin to change Core Team --->
			<tr>
				<td colspan=3 align="center" class="border">
				<input type="submit"  value="Assign">
				</td>
			</tr>
			</form>
			</cfif>
			--->
			
			
		</tr>
		<CFIF (contract_id EQ 0) OR (controller_id EQ 0)><!--- still need controller or contracts assigned --->
		
		</cfif>

<!--- **********************************************************  --->
<!---   OPS VP  Top Right                                --->
<!--- ********************************************************** --->

		<tr>		
			<cfset OpsVP_ID=#getARA.id_OpsVP#> 
			<cfset Controller=Usr_Details(OpsVP_ID)>            
            <cfset del_flag="">
			<cfif OpsVP_ID NEQ 0 and updateCore EQ 'No'>
				<td colspan=2 class="borderq">Portfolio Leader</td>
				<td class="border">
				#name# 
				
				<input type="hidden" name="id_OpsVP" value="#OpsVP_ID#">
				<cfif tip NEQ "">
					<a class="embed" href="index.cfm?fuseaction=app.AdminDelegate" title="#tip#">(d)</a>
				</cfif>
				
			<cfelse><!--- Controller not yet assigned --->
				<td colspan=2 class="borderq">
				Controller</td>
				<td class="border">
					<cfset contr=#get_Controller()#>
					<CFIF GetController.RecordCount EQ 0>
						No contract ARA users in sector or group.
					<cfelse>
						<input type="hidden" name="curController" value="#OpsVP_ID#">
					</cfif>
			</td></cfif>
			
		</tr>
		<CFIF (OpsVP_ID EQ 0) OR (OpsVP_ID EQ 0)>
		
		</cfif>

		
				
		<!--- cfif isPrint EQ 'No'><!--- don't show in CFdocument --->
				<tr><td colspan=3 align="right">
					<a class="embed" href="index.cfm?fuseaction=app.ARADetail&Menu=ARA_Detail&whichtab=4">See complete approval chain
					<cfif isDefined('total_approve')>(#total_approve# Total)</cfif></a>
				</td></tr>
		</cfif --->

	
	<cfinclude template="../../model/m_ara/qry_timeopen.cfm">
	
	<!--- tr>
		<td colspan=2 class="borderq">Now</td>
		<td class="border">#Now#</td>
	</tr --->
	<tr>
		<td colspan=2 class="borderq">Date Opened</td>
		<td class="border">#start#</td>
	</tr>
	<tr>
		<td  colspan=2 class="borderq">Req'd Start Date</td>
		<td class="bordera">
		<cfif #startDate# EQ "">
			TBD by PM
		<cfelse>
			#dateformat(startDate,"mm/dd/yyyy")#
		</cfif>
		</td>
	</tr>
	<tr>
		<td colspan=2  class="borderq">Expiration Date</td>
		<td class="bordera">
		<cfif #ExpirationDate# EQ "">
			TBD by PM
		<cfelse>
			#dateformat(expirationDate,"mm/dd/yyyy")#
		</cfif>
		</td>
	</tr>
	<cfif isPrint EQ 'No'>
	<tr>
		<td class="border" colspan=3 align="right">
		<img src="images/rightArrow.png">&nbsp;&nbsp;<a class="embed" href="index.cfm?fuseaction=app.AuditTrail&Menu=Admin&submenu=audit&ara_ID=#decrypt(url.aid,request.encryptKey,request.encryptType,'hex')#">See ARA Audit / History</a>  <!--- #decrypt(url.invoice,request.encryptKey,request.encryptType,'hex')# --->
		</td>
	</tr>
	</cfif>
	</table>
		
	</fieldset>
<!-- 1  --></td></tr></table>
	</cfoutput>
