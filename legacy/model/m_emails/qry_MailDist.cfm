<!--- Generates Email Distribution List: 
	  PM, Contracts, Controller, Everybody that touched it, all deletees, 
	  and the next person in the approval chain --->

<cfset next_Phrase="">
<cfset To="">
<cfset CC="">
<cffunction name="Usr_Details">
	<cfargument name="id_usr" required="yes">
	<cfset del_flag="">
	<cfquery name="u_info" datasource="#Application.dsn#">
		Select * from v_users
		where id_user = '#id_user#'
	</cfquery>
	<Cfif u_info.fk_delegateTo_Id NEQ "">
		<cfset del_flag="(d)">
		<cfset tip="#u_info.empname# has delegation in effect.">
		<cfset id_usr=#u_info.fk_DelegateTo_ID#>
		<cfquery name="u_info" datasource="#Application.dsn#">
			Select * from v_users
			where id_user = '#id_user#'
		</cfquery>
	</cfif>
	<cfset thisoprid=u_info.oprid>
	<cfset first_name=u_info.first_name>
	<cfset last_name=u_info.last_name>
	<cfset id_job=u_info.id_job>
</cffunction> 

<!--- Function to build email addresses based on id_user --->
<cffunction name="GetMail">
	<cfargument name="id_user" Required="yes">
	<cfset this_email="">
	<cfquery name="Opr" datasource="#application.dsn#">
		Select id_job,oprid, delegateTo_oprid, email from v_users
		where id_user=#id_user# and inactive='false'
	</cfquery>
	<!--- cfdump var="#opr#" format="text" --->
	<cfset delegateTo_Oprid=Opr.delegateTo_Oprid>
	<cfif NOT find(OPR.Oprid,TO) and Not Find(opr.oprid,CC)>
		<cfset this_email="#Opr.email#">
	</cfif>
	<cfif (delegateTo_oprid NEQ "") AND (Not Find(DelegateTo_oprid,CC)) AND (Not Find(DelegateTo_oprid,TO))>
		<cfset del="#Opr.DelegateTo_oprid#" & "@hii-tsd.com">
		<cfset del_oprid=#delegateTo_oprid#>
		<cfset this_email=ListAppend(this_email,del)>
		<cfset delegatee=delegateTo_oprid>
	</cfif>
	<!--- See if this user has been delegated to, so delegator can be copied --->
	<cfquery name="delegator" datasource="#application.dsn#">
		Select oprid from v_users
		where fk_DelegateTo_id=#id_user#
	</cfquery>
	<cfif (delegator.oprid NEQ "") AND (Not Find(delegator.oprid,CC)) AND (Not Find(delegator.oprid,TO))>
		<cfset tor="#delegator.oprid#" & "@hii-tsd.com">
		<cfset this_email=ListAppend(this_email,tor)>
		<cfset delegator=delegator.oprid>
	</cfif>
		
	<cfreturn this_email>
 </cffunction>
	
<!--- Status of ARA will dictate address decisions --->
<cfquery name="GetStat" datasource="#application.dsn#">
	Select id_status, grp  
	from v_ara
	where id_ara=#id_ara#
</cfquery>
<cfset grp=getStat.grp>

	
<!--- dist_list will be a list of user ids --->
<!--- PM, Contracts, Controller are in ara record --->
<cfquery name="KeyTeam" datasource="#Application.dsn#">
	Select ID_PM,ID_Contract,ID_Controller 
	from ARA
	where id_ara='#id_ARA#'
</cfquery>

<cfset Dist_List="#KeyTeam.ID_PM#" & "," & "#KeyTeam.id_Contract#" & "," & "#keyTeam.id_controller#">

	
<!--- Any other involved users that have entry in approval log --->


<cfquery name="GetCUsers" datasource="#Application.dsn#">
		select distinct id_user 
		from users where oprid in ('BAtefi', 'PWeaver', 'sMendler', 'bBroadus')
 </cfquery>
 
 <!--- Put all C-suite users in a list to be excluded later (CR 9/21/2012 form Jim) --->
 <cfset cUser_list = ValueList(GetCUsers.id_user)>

<cfquery name="GetPriorUser" datasource="#Application.dsn#">
		select distinct A.id_user 
		from araApplog A, users B 
		where A.id_ara='#id_ara#' and A.id_user = b.id_user and b.status <> 'inactive'
 </cfquery>
 
 
 <cfif GetPriorUser.Recordcount GT 0>
	<!--- Put all prior approvers on  mailing list --->
	<cfoutput query="GetPriorUser">
		<cfif NOT Find(id_user,dist_list)><!--- don't add duplicate --->
			<cfset dist_list=ListAppend(dist_list,id_user)>
		</cfif>
	</cfoutput>
  </cfif> 
  

<!--- If Logged in person, is not on the  distribution list....add them --->
<cfif NOT ListFind(dist_list,session.id_user)>
	<cfset dist_list=ListAppend(dist_list,session.id_user)>
</cfif>

<!--- Formulate TO list based on current state --->
	
	<!--- Notify all Contract Setup People --->
	<cfif isDefined('ThisisFinal') and ((ThisisFinal EQ "True") or (ThisisFinal EQ "Next"))>
		<cfinclude template="../m_ara/getCurrentApprover.cfm">
		
		<cfparam name="this_groupEmail" default="">
		<cfif CurrentApp.RecordCount GT 0>
			<cfset this_group=ValueList(currentApp.oprid)>
			<cfset this_groupEmail=ValueList(currentApp.email)>
		</cfif>
		<cfif CurrentApp.recordcount EQ 1><!--- The next approver exists in the system --->
			<cfset Next=GetMail(CurrentApp.id_user)>
			<cfset Next_Phrase="">
			<cfif CurrentApp.delegateTo_oprid NEQ "">
				<cfset Next_Phrase="#Next_Phrase#." & " [Delegated to #delegateTo_oprid#]">
			</cfif>
			<cfset TO=ListAppend(TO,Next)>
		<cfelseif CurrentApp.recordcount GT 1><!--- 1+ approver --->
			<cfset Next_Phrase="">
			<cfif CurrentApp.delegateTo_oprid NEQ "">
				<cfset Next_Phrase="#Next_Phrase#." & " [Delegated to #delegateTo_oprid#]">
			</cfif>
			<cfset TO=ListAppend(TO,this_groupEmail)>
		
		<cfelse><!--- There is a hole in the approval chain --->
			<cfset errorMsg="The next position in the approval chain is presently unassigned, and the ARA cannot be routed further.">
			<cfset errorMsg="#errorMsg#" & " Your management chain needs to request job re-assignments to the ARA help desk.">
			<cflocation url="index.cfm?Fuseaction=app.ARA_approvals&ErrorMsg=#ErrorMsg#&AID=#url.AID#&ID_Status=#id_status#&Menu=ARA_Detail">
		</cfif>
		
    <!--- Created by PC, notify PM --->
	<cfelseif session.id_job eq 3 and GetStat.id_status EQ 1>
		<cfset Next=GetMail(ListGetat(dist_List,1))>
		<cfset url.comment="ARA has been created by Project Controller">
		<cfset TO=ListAppend(to,this_email)>
		<cfset Next_Phrase="">
		<cfif isdefined("del") and del NEQ "">
			<cfset Next_phrase="#Next_Phrase#" & " [Delegated to #ucase(Del_oprid)#]">
		</cfif>    
        
        
	<!--- Submitted to Contracts --->
	<cfelseif GetStat.id_status EQ 2>
		<cfset Next=GetMail(ListGetat(dist_List,2))>
		<cfset url.comment="Approved by Program Manager. Submitted to Contracts">
		<cfset TO=ListAppend(to,this_email)>
		<cfset Next_Phrase="<br> Next Approver is #Ucase(opr.oprid)#">
		<cfif isdefined("del") and del NEQ "">
			<cfset Next_phrase="#Next_Phrase#" & " [Delegated to #ucase(Del_oprid)#]">
		</cfif>
		
	<!--- Submitted to Controller --->
	<cfelseif GetStat.id_status EQ 4>
		<cfset Next=GetMail(listGetAT(dist_list,3))>
		<cfset url.comment="Approved by Contracts. Submitted to Controller">
		<cfset TO=ListAppend(to,this_email)>
		<cfset Next_Phrase="<br> Next Approver is #Ucase(opr.oprid)#">
		<cfif isdefined("del") and del NEQ "">
			<cfset Next_phrase="#Next_Phrase#" & " [Delegated to #ucase(Del_oprid)#]">
		</cfif>
		
	
	<!--- Cancelled --->
	<cfelseif GetStat.id_status EQ 10>
		<cfset Next=GetMail(session.id_user)>
		<cfset url.comment="ARA Cancelled by #ucase(session.oprid)# [#session.jobtitle#]">
		<cfset TO=ListAppend(to,this_email)>
		<cfset Next_Phrase="">
		
	<!--- It is somewhere in the approval chain --->
	<cfelseif GetStat.id_status EQ 6>
		<cfinclude template="../m_ara/getCurrentApprover_OpsVP.cfm">
		<cfparam name="this_groupEmail" default="">
		<cfif CurrentApp.RecordCount GT 0>
			<cfset this_group=ValueList(currentApp.oprid)>
			<cfset this_groupEmail=ValueList(currentApp.email)>
		</cfif>
		<cfif CurrentApp.recordcount EQ 1><!--- The next approver exists in the system --->
			<cfset Next=GetMail(CurrentApp.id_user)>
			<cfset Next_Phrase="">
			<cfif CurrentApp.delegateTo_oprid NEQ "">
				<cfset Next_Phrase="#Next_Phrase#." & " [Delegated to #delegateTo_oprid#]">
			</cfif>
			<cfset TO=ListAppend(TO,Next)>
		<cfelseif CurrentApp.recordcount GT 1><!--- 1+ approver --->
			<cfset Next_Phrase="">
			<cfif CurrentApp.delegateTo_oprid NEQ "">
				<cfset Next_Phrase="#Next_Phrase#." & " [Delegated to #delegateTo_oprid#]">
			</cfif>
			<cfset TO=ListAppend(TO,this_groupEmail)>
		
		<cfelse><!--- There is a hole in the approval chain --->
			<cfset errorMsg="The next position in the approval chain is presently unassigned, and the ARA cannot be routed further.">
			<cfset errorMsg="#errorMsg#" & " Your management chain needs to request job re-assignments to the ARA help desk.">
			<cflocation url="index.cfm?Fuseaction=app.ARA_approvals&ErrorMsg=#ErrorMsg#&AID=#url.AID#&ID_Status=#id_status#&Menu=ARA_Detail">
		</cfif>
		
	<cfelseif GetStat.id_status EQ 8 or GetStat.id_status EQ 9>
		<cfset PM=GetMail(KeyTeam.ID_PM)>
		<cfset TO=ListAppend(TO,this_email)>
		<cfset Next_Phrase="<br>Returned to Program Manager">
	</cfif>
	
	
	<!--- Put everyone else on CC list --->
	<!--- cfoutput>dist_list is #dist_List#<br><br></cfoutput --->
    
    <cfloop index="i" list="#cUser_list#">
		<cfif listfind(cc,i) GT 0>
			<cfoutput>#listfind(cc,i)#</cfoutput>
            <cfset cc=ListDeleteAT(cc, listfind(cc,i))>
		</cfif>
	</cfloop>
    
    <cfloop index="i" list="#cUser_list#">
		<cfif listfind(dist_list,i) GT 0>
            <cfset dist_list=ListDeleteAT(dist_list, listfind(dist_list,i))>
		</cfif>
	</cfloop>
    
 	<cfloop index="i" list="#dist_list#">
		<cfset this=#GetMail(i)#><!--- Get Email, plus that of delegatee --->
		<cfif (this_email NEQ "") AND NOT FIND(this_email,TO) and NOT FIND(This_email,CC)>
			<cfset cc=ListAppend(cc,this_email)>
		</cfif>
	</cfloop>
	<cfset cc=Replace(cc,',',', ','all')><!--- put space in after comma, so that CC list will wrap --->
	
	