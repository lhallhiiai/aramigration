<!--- Changes with Op Column April 2013 --->

<cfparam name="submenu" default="">
<cfparam name="state" default="">
<cfset missing="">
<cfif isDefined('url.pagequery')>
	<cfset pagequery=#url.pagequery#>
<cfelse>
	<cfset pagequery='Home'>
</cfif>

<cfif NOT isDefined('url.smtitle')>
	<cfset title="ARA Home">
	<cfset smtitle="">
<cfelse>
	<cfif NOT isDefined('url.title')>
		<cfset title="ARA List">
	<cfelse>
		<cfset title=url.title>
	</cfif>
</cfif>

<!--- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  --->
<!--- July 23 2012: Temp may want to move to application cfc if works.
      For PMs, Contract mamgers, and Controllers, add to the session.approval grp list
	  other Groups found in v_ara to the list of approval groups --->
	  <cfif Find(session.id_job,'1,2,3')>
		  <cfquery name="Others" datasource="#application.dsn#">
		  	select GRP
			from v_ara
			where id_status < 6
			<cfswitch expression="#session.id_job#">
				<cfcase value="1"><!--- PM ---> AND ID_PM=#Session.id_user#</cfcase>
				<cfcase value="2"><!--- Contract Mgr ---> AND ID_contract=#session.id_user#</cfcase>
				<cfcase value="3"><!--- Contract Mgr ---> AND ID_controller=#session.id_user#</cfcase>
                
			</cfswitch>
		   </cfquery>
		   
		   <!--- cfdump var="#Others#" format="text" --->
		 <cfif not isDefined("session.approval_grp")>
			<cfset session.approval_grp = "">
		</cfif>
		<cfloop query="Others">
			<cfif Not FindNoCase(others.grp,session.approval_grp)>
				<!--- ----------------------<cfoutput>#Others.grp#</cfoutput --->
				<cfset session.approval_grp=ListAppend(session.approval_grp,"'#Others.grp#'")>
			</cfif>
		</cfloop>
		</cfif>
		
<!--- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  --->  

<cfparam name="Othergrp" default="">
<cfparam name="this_group" default="">
<cfparam name="activeSort" default="id_ara">
<cfparam name="next_job" default="">
<cfparam name="session.otherGrp" default="">
<cfparam name="smtitle" default="">
<cfparam name="title" default="">


<!--- *****                            Functions                          ***** --->
<cffunction name="Usr_Details">
			<cfargument name="id_usr" required="yes">
			<cfset del_flag="">
			<cfset otherGrp="">
			<cfif id_usr EQ "Done">
							<cfabort>
			</cfif>
			<cfquery name="u_info" datasource="#Application.dsn#">
				Select * from v_users
				where id_user=#id_usr#
			</cfquery>
			<!---<cfdump var="#u_info#">--->

			<!--- Check to see if still user in corporate database --->
			<cfquery name="GetCorp" datasource="#application.ods#">
				Select  FIVE_N_TWO 
				from HRIS_EMPL
				where  FIVE_N_TWO='#u_info.oprid#'
			</cfquery>
			<!---<cfdump var="#GetCorp#">
			<cfabort>--->
			<cfif getCorp.recordcount GT 0>
				<cfset gone="No">
			<cfelse>
				<cfset gone="Yes">
			</cfif>

			<cfset this_Oprid=u_info.oprid>
			<cfset jobtitle=u_info.title>
			<cfset first_name=u_info.first_name>
			<cfset last_name=u_info.last_name>
			<cfset id_job=u_info.id_job>
			<cfset delegatee=u_info.DelegateTo_oprid>
			<cfquery name="u_grp" datasource="#Application.dsn#">
				select  approval_group
				from  approval_grp
				where id_user=#id_usr#
			</cfquery>
		
			<cfset Approval_grp=ValueList(u_grp.approval_group)>
			
			<!---<cfif gone EQ 'Yes'>
				<cfset oprid="<font style='color:##af3610;font-size:11px;font-weight:bold'>#this_Oprid#</font>">
			<cfelse>
				<cfset oprid="<b>#this_Oprid#</b>">
			</cfif>--->
			<cfset oprid="<b>#this_Oprid#</b>">
		</cffunction> 


	<cfswitch expression="#pagequery#">
	<cfcase value="admin"><!--- admin needs to see all regardless of group and sector --->
		<cfquery name="admin" datasource="#Application.dsn#">
			Select * from v_ARA 
			where id_status < 0
			Order BY id_ara,id_status
		</cfquery>
	</cfcase>
	<cfcase value="home,MineinApproval"><!--- default for every one. All states prior to approval --->
		<!---<cfif (session.id_job EQ 21) OR (Session.id_job eq 22)><!--- Delegatee --->
			<cfif session.delegate_id_job NEQ ""><!--- Assume the job role of delegator --->
				<cfset session.id_job = session.delegate_id_job>
			</cfif>
		</cfif>--->
        <cfif session.delegate_id_job NEQ ""><!--- Assume the job role of delegator --->
				<cfset session.id_job = session.delegate_id_job>
			</cfif>
		
		<cfquery name="home" datasource="#Application.dsn#">
			Select  * from v_ARA
			<cfswitch expression="#session.id_job#">
			<cfcase value="1">
				where id_status in (1,2,3,8,9)
				and (ID_PM=#session.id_user# 
				<cfif session.delegators NEQ "">
				or ID_Pm=#session.delegators#
				</cfif>)

			</cfcase>
			<cfcase value="2">
				where id_status in (2,3)
				and (ID_Contract=#session.id_user# 
				<cfif session.delegators NEQ "">
				or ID_Contract=#session.delegators#
				</cfif>)
				
			</cfcase>
			<cfcase value="3">
				where id_status in (4,5)
				and (ID_Controller=#session.id_user# 
				<cfif session.delegators NEQ "">
				or ID_Controller=#session.delegators#
				</cfif>)
			</cfcase>
			<cfcase value="5,6,7,8,10,11,12,16">
				where 1=0
			</cfcase>
			<cfcase value="9,25"><!--- Group Manager, Contract Lead --->
				where (division='#session.group#' or division in(<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.approval_grp#" list="yes">))
				and id_status=6
			</cfcase>
			<!--- Director Contracts and Procurment or Corporate Controller  and all the other Old titled people e.g., Sector Manager --->
			<cfcase value="4,24,26,14,17,18,19,20,21,22,23,27,28,29">
				where id_status=6
			</cfcase>
			<cfcase value="13"><!--- CCS --->
				where id_status in (6,12)
			</cfcase>
			</cfswitch>
			
			
			Order BY #ActiveSort#
		</cfquery>
		
		<cfif ListFind('1,2,3,4',session.id_job)><!--- Show PM/DM, CA, Controller what is in the approval chain --->
			<cfquery name="MineInApproval" datasource="#Application.dsn#">
			Select * from v_ara
			where 1=1
			<cfswitch expression="#session.id_job#">
			<cfcase value="1,4">and (Id_PM=#session.id_user# 
							<cfif session.delegators NEQ "">
							or ID_Pm=#session.delegators#
							</cfif>) and id_status in (3,4,5,6)</cfcase>
			<cfcase value="2">and (ID_Contract=#session.id_user# 
							<cfif session.delegators NEQ "">
							or ID_Contract=#session.delegators#
							</cfif>)and id_status in (5,6)</cfcase>
			<cfcase value="3">and (ID_controller=#session.id_user#
							<cfif session.delegators NEQ "">
							or ID_controller=#session.delegators#
							</cfif>)and id_status=6</cfcase>
			</cfswitch>
			ORDER BY #ActiveSort#
			</cfquery>
			<!---<cfdump var="#MineInApproval#" format="text" top=1>--->
		</cfif>
		
		
	</cfcase>
	<!--- passing a list from dashboard --->
	<cfcase value="ara_list">
		<cfquery name="ara_list" datasource="#Application.dsn#">
			Select * from v_ara
			where id_ara in (#ara_list#)
			
			Order BY #ActiveSort#
		</cfquery>
		<!---<cfdump var="#ara_list#" format="text">--->
	</cfcase>
	<cfcase value="bystate">
		<cfquery name="bystate" datasource="#Application.dsn#">
			Select   * from v_ara
			where id_status in (#state#)
			Order BY #ActiveSort#
		</cfquery>
	<!--- cfdump var="#bystate#" format="text" --->
	</cfcase>
	
	<cfcase value="OpenExpired">
		<cfquery name="OpenExpired" datasource="#Application.dsn#">
			Select   * from v_ara
			where id_status in (1,2,3,4,5,6,7,8)
			and ExpirationDate < '#dateformat(now(),"MM/DD/YY")#'
			Order BY #ActiveSort#
		</cfquery>
	<!--- cfdump var="#bystate#" format="text" --->
	</cfcase>
	<!--- Drill down from By Category Overview Report  --->
	<cfcase value="ByCategory">
		<cfquery name="ByCategory" datasource="#Application.DSN#">
			Select * from v_ara
			where id_cat=#url.id_cat#
			<cfif url.status EQ 'Open'><!--- Every State Prior to Approved --->
				and id_status IN (1,2,3,4,5,6,8,9,11)
			<cfelseif url.status EQ 'Done'><!--- Every State Except Cancelled --->
				and id_status > 11
			</cfif>
			Order BY #ActiveSort#
		</cfquery>
	</cfcase>
	<cfcase value="NoOrg">
	<cfquery name="Noorg" datasource="#Application.DSN#">
		Select * from v_ara
		where (sector is null) and (grp is null) and (op is null)
		and id_status in (1,2,3,4,5,6,7,8,9)
	</cfquery>
	</cfcase>
	</cfswitch>
<!--- *****                             /Pagequeries                          ***** --->

<cfoutput>
<table cellpadding=0 cellspacing=0 width=100% border=0 align="right">
	<tr>
	<td align="left" nowrap>
		<p class="title">
		#title#</p>
		<p class="smtitle">
		#smtitle#</p><br><br> 
	
	<td align="right" nowrap>
	<img src="images/Helpicon.gif" border=0>&nbsp;<a class="embed" href="index.cfm?fuseaction=app.help&topic=getting_started">Getting Started</a><br><br>
	</td></tr>
</table><br><br>
</cfoutput>
<cfinclude template="dsp_Messages.cfm">
<!---<cfdump var="#session#" format="text">--->
<!---<cfif (ListFind('9,14,24,25,26',session.id_job))>
<cflocation  url="/ara/index.cfm?fuseaction=app.home&menu=Bystate&submenu=InApproval&Pagequery=Bystate&state=6">
	</cfif>--->
	
<cfset OuterLoop =1>


<cfloop index = "OuterLoop" from = "1" to = "1">
<cfoutput>

<cfif OuterLoop EQ 1>
	
	<cfif NOT isDefined('url.smtitle')>
	<p class="title">ARAs Requiring My Action</p>
	</cfif>
<cfelseif Outerloop EQ 2>
	<cfif (NOT ListFind('1,2,3,4,9,14,24,25,26',session.id_job) or NOT isDefined('MineinApproval'))>

		<cfbreak><!--- we only show second list of ARAs pending approval on home page of core people --->
	</cfif>
	<br><br>
	<p class="title">My ARAs Pending Approval</p>
	<cfset pagequery="MineInApproval">
</cfif>

<table cellpadding=2 width=100% cellspacing=2 class="border">
<!--- *****                          Table Header                    ***** --->
<tr>
	<td>&nbsp;</td>
	<td nowrap width=105 class="grad"><a href="#self#?fuseaction=app.home&PageQuery=#pagequery#&activesort=id_ara&Menu=home&state=#state#&smtitle=#smtitle#" class="embed">ID & Revision</a>
	<cfif activeSort EQ 'id_ara'><img src="images/sort.png"></cfif></td>
	<td class="grad" width=94><a href="#self#?fuseaction=app.home&PageQuery=#pagequery#&activesort=id_status&Menu=home&state=#state#&smtitle=#smtitle#" class="embed">State</a>
	<cfif activeSort EQ 'id_status'><img src="images/sort.png"></cfif></td>
	
	
		<cfif (submenu NEQ 'Archive') and (submenu  NEQ 'Approved')>
		<td class="grad" nowrap>
			Awaiting Approval By
		</td>
		<!---<cfelse>
			Company--->
		</cfif>
	</td>
	<td class="grad"><a href="#self#?fuseaction=app.home&PageQuery=#pagequery#&activesort=Grp&Menu=home&state=#state#&smtitle=#smtitle#" class="embed">Grp</a>
	<cfif activeSort EQ 'grp'><img src="images/sort.png"></cfif>
	</td>
    <td class="grad"><a href="#self#?fuseaction=app.home&PageQuery=#pagequery#&activesort=division&Menu=home&state=#state#&smtitle=#smtitle#" class="embed">Div</a>
	<cfif activeSort EQ 'op'><img src="images/sort.png"></cfif>
	</td>
	<td class="grad"><a href="#self#?fuseaction=app.home&PageQuery=#pagequery#&activesort=JamisNo&Menu=home&state=#state#&smtitle=#smtitle#" class="embed">CostPoint ##</a>
	<cfif activeSort EQ 'JamisNo'><img src="images/sort.png"></cfif>
	</td>
	<td class="grad"><a href="#self#?fuseaction=app.home&PageQuery=#pagequery#&activesort=Title&Menu=home&state=#state#&smtitle=#smtitle#" class="embed">Title</a>
	<cfif activeSort EQ 'Title'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.home&PageQuery=#pagequery#&activesort=CustomerName&Menu=home&state=#state#&smtitle=#smtitle#" class="embed">Customer</a>
	<cfif activeSort EQ 'CustomerName'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.home&activesort=amountTotal&Menu=home&pagequery=#pagequery#&state=#state#&smtitle=#smtitle#" class="embed">Amount Total</a>
	<cfif activeSort EQ 'AmountTotal'><img src="images/sort.png"></cfif></td>
	<cfif (session.id_role EQ 2) or (session.id_job EQ 13)>
	<td class="grad">Cancel</td>
	</cfif>
	<cfif (session.id_role eq 2) and (application.production EQ "No")>
	<td class="grad">
		<img src="images/SmDelete.png">
	</td>
	</cfif>
</tr>
<!--- *****                      End  Table Header                    ***** --->
</cfoutput>

<cfset running_total=0>
<cfset count=0>
<!--- <cfdump var="#session#" format="text"> --->
<!--- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->
<!---                         MAIN CFOUTPUT LOOP                            --->
<!--- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->

<cfoutput query="#pagequery#">
		<cfset currentcycle=val(revision+1)>
		<cfset ara_id=#id_ara#>
		<cfset this_group ="">
		<cfset missing="">
		<cfinclude template="../../model/m_ara/qry_GetApprovalChain.cfm">
		
		<!--- Cancelled, Exported,Negated, Negated Exported, Early Start Complete --->
		<cfif (id_status NEQ 10) and (id_status NEQ 13) and (id_status NEQ 12) and (id_status NEQ 18) and (id_status NEQ 14) and (id_status NEQ 16)>
			<cfinclude template="../../model/m_ara/getCurrentApprover.cfm">
		
			<cfif currentApp.id_job EQ 17>
				<cfinclude template="../../model/m_ara/getCurrentApprover_OpsVP.cfm">
			</cfif>
			<cfif (currentApp.id_user NEQ "" and currentApp.id_user NEQ "Done")>
				<cfset this_user=Usr_Details(currentApp.id_user)>
			<cfelseif currentApp.id_user EQ "Done">
				DONE
			<cfelse>
				<cfset this_Oprid="zzzz">
				<cfset jobtitle="zzzz">
				<cfset first_name="zzzz">
				<cfset last_name="zzzz">
				<cfset id_job=25>
				<cfset delegatee="zzzz">		  	
				
			</cfif>
			<cfset next_app=currentApp.id_user>
		<cfelse>
			<cfset this_user="">
			<cfset next_app="">
		</cfif>
		
        
		
		
<cfoutput>
<!--- Decide whether or not to show this row to this user:  
		. Is the logged in user is the user associated with this ara
		. Or is this a delegate of this user
		. Or if a list of users is returned, is this user part of that list
		. Or just worry about sector and group if the all or mine toggle is set to all

--->


</cfoutput>


<cfset show_row = 0>
<cfif pagequery EQ 'Home'>

	<cfif Len(this_group ) GT 0><!--- we have a list of people, like CCS --->
		<cfif (session.oprid EQ delegatee)  OR (Session.oprid EQ this_Oprid) or (ListFind(this_group,session.oprid)) >
		<cfset show_row =1>
	    </cfif>
	<cfelse><!--- Just one person --->
		<cfif ((session.oprid EQ delegatee)  OR (Session.oprid EQ this_Oprid))>
		<cfset show_row=1>
		</cfif>
	</cfif>
	
<cfelse><!--- driven here by another query from the dashboard --->
	<cfif (isDefined('URL.Pagequery') OR Pagequery EQ 'mineInApproval')><!--- then we are passing parms of what we want to see --->
		<cfset show_row=1>
	<cfelse>
		<cfset show_row=0>
	</cfif>
</cfif>

<cfif Show_Row>


<tr>
	
	<cfset count=count+1>
	<cfset AID=#encrypt(id_ara,request.encryptkey,request.encrypttype,'hex')#>
	<!---                COLUMN 1: COUNT                   --->
	<td valign="top" class="border">#count#.</td>
	
	<!---                COLUMN 2: ARA ID & LINK                   --->
	<td valign="top" nowrap class="border">
	<!--- +++++++++++++++++++++    Links to specific tabs   ++++++++++++++++++++++++++++ ---> 
	<cfif ((ID_contract EQ session.id_user) OR (FindnoCase(id_contract,session.delegators)))><!--- This is the contract manager for this ARA --->
			<cfset Faction="app.ARA_ContractInfo">
	<cfelseif ((ID_controller EQ session.id_user) OR (FindnoCase(id_controller,session.delegators)))>
		<cfset Faction="app.ARA_ControllerV2">
	<cfelseif ((ID_PM EQ session.id_user) OR (FindnoCase(id_PM,session.delegators)))>
		<cfset Faction="app.ARA_PM">
	<cfelse>
		<cfset Faction="app.ARA_PM">
	</cfif>
	<cfif (id_status GT 5) and (id_status LTE 12)><!--- take right to approval tab --->
		<a href="index.cfm?Fuseaction=app.ARA_approvals&AID=#AID#&ID_Status=#id_status#&Menu=ARA_Detail" class="embed">#reference#</a>
	<cfelse>
		<a href="index.cfm?Fuseaction=#Faction#&AID=#AID#&ID_status=#id_status#&Menu=ARA_Detail" class="embed">#reference#</a>
		
	</cfif>
	<br><font style="font-size: 7px;font-family:Trebuchet MS;text-transform:uppercase;" >Expires: #dateformat(ExpirationDate,"MM/DD/YY")#</font>
	</td>
	
	
	
	<!--- td valign="top" class="border" --->
		<!--- cfquery name="CLINfo" datasource="#application.jc#">
			SELECT clin_no, clin_desc, end_date
			FROM jobcost.t_clin_master_ckis
			WHERE cnct_no = <cfqueryparam cfsqltype="cf_sql_varchar" value="#jamisNo#">
		</cfquery --->
		
	<!--- /td ---> 
	
	<!---                COLUMN 3: STATUS                   --->
	<td valign="top" class="border">
	<cfif id_status EQ 8 or ID_status EQ 9>
		<font class="red">REJECTED
	<cfelse>
		#OneWord#
	</cfif>
	
	</td>
	
	
	<!---                COLUMN 4: CURRENT APPROVER                    --->
	
	<!--- <cfdump var="#currentApp#" format="text"> --->
	<cfif listFind('10,12,13,14,15,16,17',id_status)><!--- Approved, Exported,negated, Negated Exported --->
			<!---&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Done--->
	<cfelse>
	<td valign="top" class="border" width=100 bgcolor="##EEEEEE">
	
		<cfif isDefined('CurrentApp.id_user') AND CurrentApp.id_user NEQ "">
		
			<cfif (CurrentApp.id_job NEQ 13)><!--- if it's not CCS  --->
				<cfif Len(this_group) EQ 0>
					<cfif CurrentApp.id_job EQ 17>
						<cfquery name="getOpsVP" datasource="#application.dsn#">
							select ID_opsVP from v_ara where id_ara= #id_ara#
						</cfquery>
						
						<cfif getOpsVP.recordCount GT 0 and trim(getOpsVP.ID_opsVP) NEQ "">
							<cfset u=Usr_Details(getOpsVP.ID_opsVP)>
							#oprid# 
						</cfif>
					<cfelse>
						<cfset u=Usr_Details(currentApp.id_user)>
						#oprid# 
					</cfif>
				<cfelse>
				<b>#this_group#</b>
				</cfif> <br>
				<font style="font-size: 7px;font-family:Trebuchet MS;text-transform:uppercase;" >#jobtitle# </font>
				<cfif (isDefined('delegatee') and delegatee NEQ "")>
					<br><font style="font-size: 7px;font-family:Trebuchet MS;text-transform:uppercase;color:##77032a;" >DELEGATED TO:</font>
					<br><b> #delegatee#</b>
					<cfset delegatee="">
				<cfelse>
				</cfif>
			<cfelse>
				<b>FINAL: CCS</b>
				<cfloop index="i" list="#this_group#">
				<b>#i#</b><br>
				</cfloop>
			</cfif>
		<cfelse>
			<a href="index.cfm?Fuseaction=app.ARA_approvals&AID=#AID#&ID_Status=#id_status#&Menu=ARA_Detail" class="embed"><b>Job unassigned</b></a>
		</cfif>
		</td>
	</cfif>
	
	<!---                COLUMN 5: Grp                   --->
	<!---<cfif Sector NEQ "">
	<td valign="top" class="border">
		#Grp#
	</td>
    
    <!---                COLUMN 5: op                   --->
	<td valign="top" class="border">
		#division#
	</td>
	<cfelse><!--- Sector, Group, Ops are Null as dividion is not longer there --->
		<td colspan=2 valign="top" class="border" align="center">
			<font style="color: ##af3610;font-family:Trebuchet MS;">DVSN #division# Gone</td>
		</td>
	</cfif>--->
	
	<td valign="top" class="border">
		#Grp#
	</td>
    
    <td valign="top" class="border">
		#division#
	</td>
	
	
	<!---                COLUMN 6:                   --->
	<td valign="top" nowrap class="border">#JamisNo#</td>
	
	<!---                COLUMN 7: RISK Level & Title                   --->
	<td valign="top" class="border">
	<font style="font-size: 7px;font-family:Trebuchet MS;text-transform:uppercase;color:##698aa1;" >Risk: #riskLevel#, Category: #catName#</font><br>
	#title#</td>
	
	<!---                COLUMN 8: CUSTOMER                   --->
	<td valign="top" class="border">#customerName#</td>
	
	
	<!---                COLUMN 9: AMOUNT                      --->
	<td valign="top" align="right" class="border">$#numberformat(amountTotal,"9,999")# 
	<cfset running_total=val(running_total+amountTotal)>
	<!--- $#numberformat(running_total,"9,999")# ---></td>
	
	
	<!---                COLUMN 10: ADMIN ONLY can Cancel or DELETE                   --->
	<cfif session.id_role EQ 2 or session.id_job EQ 13>
	<td valign="top" class="border">
		<a class="embed"  href="index.cfm?Fuseaction=app.AdminCancel&ARA&AID=#Aid#&PageQuery=#Pagequery#">Cancel</a>
	</td>
	</cfif>
	<cfif (session.id_role eq 2) and (application.production EQ "No")>
	<td valign="top" class="border">
		<a href="index.cfm?Fuseaction=app.DeleteEntireARA&AID=#Aid#&PageQuery=#Pagequery#"><img src="images/SmDelete.png" border=0></a>
	</td>
	</cfif>
	
</tr>
<cfset this_group=""><cfset next_job=""><cfset id_job="">
</cfif>
</cfoutput>
<cfoutput>
<tr>
	<cfif (submenu NEQ 'Archive') and (submenu  NEQ 'Approved')>
		<td class="border" colspan=9 align="right">
	<cfelse>
		<td class="border" colspan=8 align="right">
	</cfif>
	Total For #Ucase(smtitle)#
	</td>
	<td class="border" align="right">
	<b>$#numberformat(running_total,"9,999")#</b>
	</td>
</tr>
</cfoutput>
</table>


</cfloop><!--- Outer Loop --->

<cfif session.id_job EQ 13> <!--- show CCS approved ARA so they could enter CLINS --->
<br><br><p class="title">Approved Early Start, Enter CLINS on the Controller Tab</p><br><br>
<table cellpadding=2 width=100% cellspacing=2 class="border">
<tr>
	<td class="grad">&nbsp;</td>
	<td nowrap class="grad"><a href="#self#?fuseaction=app.home&activesort=id_ara&Menu=home" class="embed">ID & Revision</a>
	<cfif activeSort EQ 'id_ara'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.home&activesort=JamisNo&Menu=home" class="embed">JAMIS ##</a>
	<cfif activeSort EQ 'JamisNo'><img src="images/sort.png"></cfif>
	</td>
	<td class="grad"><a href="#self#?fuseaction=app.home&activesort=Title&Menu=home" class="embed">Title</a>
	<cfif activeSort EQ 'Title'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.home&activesort=CustomerName&Menu=home" class="embed">Customer</a>
	<cfif activeSort EQ 'CustomerName'><img src="images/sort.png"></cfif></td>
	<!--- td class="grad"><a href="#self#?fuseaction=app.home&activesort=StartDate&Menu=home" class="embed">Req'd Start</a>
	<cfif activeSort EQ 'StartDate'><img src="images/sort.png"></cfif></td --->
	
	<td class="grad"><a href="#self#?fuseaction=app.home&activesort=amountTotal&Menu=home" class="embed">Amount Total</a>
	<cfif activeSort EQ 'AmountTotal'><img src="images/sort.png"></cfif></td>
	<cfif (session.id_role EQ 2) and (application.production EQ "No")>
	<td class="grad">
		<img src="images/SmDelete.png">
	</td>
	</cfif>
</tr>
<cfparam name="CCSActiveSort" default="id_ara">
	<cfquery name="CCS" datasource="#Application.dsn#">
		Select * from v_clin 
		where id_status = 12 and id_cat=10
	</cfquery>
   
<cfset count=0>
<cfoutput query="CCS">
<cfquery name="CCS2" datasource="#Application.dsn#">
		Select * from v_ara 
		where id_ara='#CCS.id_ara#'
	</cfquery>
<tr>
	<cfset count=count+1>
	<td valign="top" class="border">#count#</td>
	<cfset AID=#encrypt(id_ara,request.encryptkey,request.encrypttype,'hex')#></td>
	
	<td valign="top" nowrap class="border">
		<cfset Faction="app.ARA_ControllerV2">
		<a href="index.cfm?Fuseaction=#Faction#&AID=#AID#&ID_status=#id_status#&Menu=ARA_Detail" class="embed">#CCS2.reference#</a></td>
	<td valign="top" nowrap class="border">#CCS2.JamisNo#</td>
	<td valign="top" class="border">
	<font style="font-size: 7px;font-family:Trebuchet MS;text-transform:uppercase;color:##698aa1;" >Risk: #CCS2.riskLevel#, Category: #CCS2.catName#</font><br>
	#CCS2.title#</td>
	<td valign="top" class="border">#CCS2.customerName#</td>
	<td valign="top" align="right" class="border">$#numberformat(CCS2.amountTotal,"9,999")#</td>
	<cfif ListFind('huang,mgann',session.oprid)>
	<td class="border">
		<a href="index.cfm?Fuseaction=app.DeleteEntireARA&AID=#Aid#&PageQuery=#pagequery#"><img src="images/SmDelete.png" border=0></a>
	</td>
	</cfif>
</tr>
</cfoutput>

</table>
</cfif>

<!--- end of CCS display --->

<cfoutput>
<cfif find(session.Id_job,"1,2,3")><!--- Will show approved to PM, Contracts, Controller --->
<br><br><p class="title">
ARAs Pending Negation
</p>
<cfinclude template="inc_NegateList.cfm">

</cfif>
</cfoutput>