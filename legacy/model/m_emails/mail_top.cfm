<cfinclude template="qry_MailDist.cfm">
	

	<!--- Core Team --->
	<cfquery name="Team" datasource="#application.dsn#">
		Select empname,oprid
		from v_users
		where id_user in ('#id_pm#', '#id_contract#','#id_controller#')
		order by id_job
	</cfquery>
<!--- Core Team ---><!--- Think next is unnecessary mel 6/26/2012 --->
	<cfquery name="Team_pm" datasource="#application.dsn#">
		Select empname,oprid
		from v_users
		where id_user='#id_pm#'
	</cfquery>
    <cfquery name="Team_cm" datasource="#application.dsn#">
		Select empname,oprid
		from v_users
		where id_user='#id_contract#'
	</cfquery>
    <cfquery name="Team_con" datasource="#application.dsn#">
		Select empname,oprid
		from v_users
		where id_user='#id_controller#'
	</cfquery>

	
	<cfset teamOprid=ValueList(Team.oprid)>
	<cfset pm_nm=#Team_pm.empname#>
	<cfset contract_nm=#Team_cm.empname#>
	<cfset controller_nm=#Team_con.empname#>
	<cfset loopcount=1>
	<!--- cfdump var="#teamOprid#" format="text"><cfabort --->
	<cfloop index="i" list="#teamOprid#">
		<cfquery name="DelStr" datasource="#Application.dsn#">
			select oprid, DelegateTo_oprid from v_users
			where oprid='#i#'
		</cfquery>
		
		<!--- If there is a delegation --->
		
			<cfswitch expression="#loopcount#">
			<cfcase value="1">
				<cfif (DelStr.DelegateTo_oprid NEQ "")>
					<cfset pm_nm="#pm_nm#" & " [Delegation in effect to #Ucase(DelStr.DelegateTo_oprid)#]">
					<cfoutput>PM: #pm_nm#<br></cfoutput>
				</cfif>
			</cfcase>
			<cfcase value="2">
				<cfif (DelStr.DelegateTo_oprid NEQ "")> 
					<cfset contract_nm="#contract_nm#" & " [Delegation in effect to #Ucase(DelStr.DelegateTo_oprid)#]">
					<cfoutput>Contract_nm: #contract_nm#<br></cfoutput>
				</cfif>
			</cfcase>
			<cfcase value="3">
				<cfif (DelStr.DelegateTo_oprid NEQ "")>
					<cfset controller_nm="#controller_nm#" & " [Delegation in effect to  #Ucase(DelStr.DelegateTo_oprid)#]">
					<cfoutput>controller_nm: #controller_nm#<br></cfoutput>
				</cfif>
			</cfcase>
			</cfswitch>
			<cfset str="Authority Delegated">
			<cfset loopcount= val(loopcount+1)>
			<cfset DelStr.DelegateTo_oprid="">
	</cfloop>
	
	<cfif isDefined('ThisisFinal') and (ThisisFinal EQ "True")>
		<cfset shortDesc="Final Approval By #Session.empname#">
		<cfset intro="ARA has received all necessary approvals.">
		<cfset confirmMsg="ARA #reference# has received final approval from #approver#.">
		<cfif (oprid_delegateTo NEQ "") AND (session.oprid Eq oprid_delegateTo)>
			<cfset confirmMsg="#ConfirmMsg# [delegatee for #oprid_delegateFrom#]">
		</cfif>
	<cfelse>
		<cfset shortDesc="Approval Provided by #session.empname#">
		<cfif (isDefined('oprid_delegateTo') and  oprid_delegateTo NEQ "") and (session.oprid EQ oprid_delegateTo) >
			<cfset shortDesc="#shortDesc#  [delegatee for #oprid_delegateFrom#]">
		</cfif>
		<cfif Next_phrase NEQ ""><!--- next_phrase defined in qry_MailDist --->
			<cfset shortDesc="#ShortDesc#">
		</cfif>
		<cfset intro="">
		<cfset confirmMsg="ARA #reference#: Approved by #session.empname#.">
			<cfif (isDefined('oprid_delegateTo') and  oprid_delegateTo NEQ "")  and (session.oprid EQ oprid_delegateTo) >
			<cfset confirmMsg="#confirmMsg# [delegatee for #oprid_delegateFrom#]">
		</cfif>
		<cfif Next_phrase NEQ ""><!--- next_phrase defined in qry_MailDist --->
			<cfset intro="#ShortDesc#">
		</cfif>
	</cfif>
	
	<cfif isdefined("CurrentApp.recordCount") and CurrentApp.recordCount GT 0 and (not isdefined("thisisfinal") or thisisfinal NEQ "True")>
		<cfquery name="getNextJob" datasource="#Application.dsn#">
			select [title] as jobtitle from jobTitle
			where id_job = #CurrentApp.id_job#
		</cfquery>	
		
		<cfset Next_Phrase=Replace(Next_Phrase,"<br>","")>
		<cfset Subject="ARA #reference#: Next action required by #getNextJob.jobtitle#.">
		<cfset MsgText="This ARA may be acted upon until the ARA expires."> 
	<cfelse>
		<cfset Next_Phrase=Replace(Next_Phrase,"<br>","")>
		<cfif not isdefined("thisisfinal") or thisisfinal NEQ "True">
			<cfset Subject="ARA #reference#: Approved by: #Session.Empname#.">
		<cfelse>		
			<cfset Subject="ARA #reference#: Final Approved by: #Session.Empname#.">
		</cfif>
		<cfset MsgText="This ARA may be acted upon until the ARA expires."> 
	</cfif>
	
<cfset From="ARA@hii-tsd.com">  