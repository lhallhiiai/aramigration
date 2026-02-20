

<cfset Contract_Jobs="2,7,10"><!--- Contract admin, Group Contracts Manager, Sector Contracts --->
<cfset controller_jobs="3,5,8,11"><!--- Controller, Ops Controller, Group Controller, Sector Controller --->
<cfset PM_Jobs="1,4,6,9,12"><!--- PM, Division Manager, Ops Mgr, Group Mgr, Sector Manager --->
<cfset SelectTxt="Select Delegatee">
<cfif SESSION.approval_grp EQ "">

<cfquery name="getUserID" datasource="#Application.dsn#">
    Select id_user 
    from users
    where oprid='#url.oprid#'
</cfquery>

<cfquery name="AppGrp" datasource="#Application.dsn#">
    Select approval_group 
    from approval_grp
    where id_user='#getUserID.id_user#'
    order by approval_group
</cfquery>

<cfset session.approval_grp=valueList(appGrp.approval_group)>
</cfif>

<cfquery name="ThisUser" datasource="#application.dsn#">
	Select id_user,ID_role,sctr,grp,id_job,oprtn,dvsn
	from v_users
    where oprid='#oprid#'
</cfquery>
<!--- CCS,CFO,DGM,COO,CEO,Delegatee,C-level Delegate,BOD,PCM,CGL cannot delegate--->

<cfif NOT ListFind('13,15,17,18,20,21,22,27,28,29',ThisUser.id_job)>
<cfquery name="getDelegatee" datasource="#application.dsn#" result="gDelegatees">
	    Select * from v_users
		<!--- cannot delegate to self --->
		where id_user <> '#session.id_user#'
		and id_user <> '#ThisUser.id_user#'
		and (grp is not null)
		and oprid is not null 
		and Inactive=0
		<!--- cannot delegate to soemone who has delegated already --->
		and fk_delegateTo_ID is NULL
		<!--- Can delegate to GREATER POWER (role is less than delegate from) and if NOT ADMIN --->
		<!---and (id_role <= #thisUser.ID_Role#)--->
		<!---
		<!--- Job Level Filters: The most complex rules --->
		<cfswitch expression="#thisUser.id_job#">
		<!--- Lowest Level: Division Level must be within same Op --->
		<cfcase value="1"><!--- PM --->
			<cfset SelectTxt="Can delegate to Other PMs">
			and (id_job=#thisUser.id_job#) <!--- cannot delegate to delegatee, because PMs/DMs need to Have Create Role --->
		</cfcase>
		<cfcase value="2,3"><!--- Contract Mgr, Controller --->
			<cfset SelectTxt="Can delegate to same Job Title (or Delegatee)">
			and (id_job=#thisUser.id_job# or id_job=21)
		</cfcase>
		<cfcase value="4"><!--- Division Manager --->
			<cfset SelectTxt="Can delegate to Other DMs, PMs in their group">
			and (id_job=#thisUser.id_job#) or (id_job=1 and Grp='#thisUser.grp#')
		</cfcase>
		
		<cfcase value="9"><!--- Group Manager --->
			<cfset SelectTxt="Can delegate to Other Group Manager, Deputy Grp Mgr, Division Manager in same group">
			<!--- 17: Deputy Group Mgr,  or 4: Division Mgr  --->
			and (id_job=#thisUser.id_job#  OR (id_job=17 and Grp='#thisUser.grp#')) OR (id_job=4 AND Grp='#thisUser.grp#') 
            <cfloop index="i" from="1" to="#listlen(SESSION.approval_grp)#">
            or 
            (id_job=4 AND grp =('#listgetat(SESSION.approval_grp,i)#')) or (id_job=17 AND grp =('#listgetat(SESSION.approval_grp,i)#'))
            </cfloop>
		</cfcase>
	
		<cfcase value="14,19"><!--- Corporate Controller, CAO --->
			<cfset SelectTxt="Can delegate to C-Level Delegatee">
			and (id_job IN (22))
		</cfcase>
		
		<cfcase value="24"><!--- Director Project Control --->
			<cfset SelectTxt="Can delegate to Project Control Managers & Business Operations Directors">
			and (id_job IN (27,28,22)) <!--- Project Control Managers and --->
		</cfcase>
		<cfcase value="25"><!--- Contract Director Lead --->
			<cfset SelectTxt="Can delegate to Other Contract Director Leads & Contract Group Leads">
			and (id_job IN (29,25)) <!--- Contract Group Leads --->
		</cfcase>
		<cfcase value="26"><!--- Director Contracts and Procurement --->
			<cfset SelectTxt="Can delegate to Contract Director Leads">
			and (id_job IN (25)) <!--- Contract Director Lead  --->
		</cfcase>
		
		<cfdefaultcase>
			<cfset selectTxt="Select Delegatee">
		</cfdefaultcase>
		</cfswitch>--->
	Order by Last_name
	</cfquery>
  
	<!--- Now create select text --->
	<cfif GetDelegatee.Recordcount GT 0>
		<select class="inputtext" name="DelegateTo" size="<cfoutput>#Val(GetDelegatee.recordcount+1)#</cfoutput>">
			<option value=""><cfoutput>-- <i>#SelectTxt#</i> --</cfoutput></option>
		<cfoutput query="getDelegatee">
			<option value="#oprid#">#Last_name#, #First_Name# &nbsp;&nbsp;&nbsp;[#title#, #Grp#]</option>
		</cfoutput>
		</select>
	<cfelse>
		There is not an ARA user setup with the appropriate job title and role to accept this delegation, or
		this position is not allowed to delegate their authority.
	</cfif>
	
<cfelse>
	This job title cannot delegate.
	<cfset noDelegation=1>
</cfif>	
<!---<cfdump var="#getDelegatee#" format="text" top=1>--->