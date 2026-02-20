<!--- Look for approval for this user, forn this ara, during this cycle --->
<!--- cfdump var="#url#" format="text" --->

<cfset ara_id=#decrypt(url.aid,request.encryptKey,request.encryptType,'hex')#>
<cfquery name="appCheck" datasource="#application.dsn#">
SELECT *
FROM ARAAppLog
WHERE id_ara = <cfqueryparam cfsqltype="cf_sql_integer" value="#ara_id#">
		AND id_user = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">
		AND cycle =<cfqueryparam cfsqltype="cf_sql_integer" value="#cycle#">
</cfquery><!--- Have they already approved --->
<!--- cfdump var="#appcheck#" format="text"><cfabort --->
<cfif session.delegators NEQ ""><!--- Delegatee may be approving --->
		<cfquery name="CheckDel" datasource="#application.dsn#">
			Select * from delegation
			where fk_delegateTo_ID=#session.id_user#
			AND (GETDATE() BETWEEN startDate AND endDate)
		</cfquery>
		
		<cfif (CheckDel.recordcount GT 0)>
			<!--- Get Job Id of Delegator --->
			<cfquery name="DelJob" datasource="#application.dsn#">
				Select id_job from v_users
				where id_user = #CheckDel.fk_DelegateFrom_ID#
			</cfquery>
			<cfset Comment="#Comment#" & " [Delegation From #CheckDel.DelegateFrom_Oprid# to #checkDel.Delegateto_Oprid#].">
			<!--- Next code added becasue a delegated to person may have to approve as
			      himself as well as the delegator. Need to determine which job is approving --->
			<!--- Check log to see if he approved as delegator --->
			<cfquery name="DidApprove" datasource="#Application.dsn#">
				Select * from araAppLog
				where id_ara=#ara_id#
				and id_user=#session.id_user#
				and comment like '%Delegat%'
			</cfquery>
			
			<cfif DidApprove.Recordcount GT 0>
				<cfset id_job=session.id_job>
			<cfelse>
				<cfset id_job=DelJob.ID_Job>
			</cfif>
		<cfelse>
			<cfset id_job=session.id_job>
		</cfif>
	<cfelse>
		<cfset id_job=session.id_job>
	</cfif>
    After delegation checks id_job is <cfoutput>#id_job#</cfoutput>
	


<!--- This user, has not approved this ara OR he might be a delegate approving for a second time --->    
<cfif (appCheck.recordcount EQ 0) OR (isDefined('CheckDel.recordcount') AND (CheckDel.recordcount GT 0))>
	<cfquery name="Approval" datasource="#application.dsn#" result="result">
		INSERT INTO ARAAppLog
			(id_ara,
			id_user,
			id_job,
			id_status,
			cycle,
			isRejection,
			comment,
			approvalDate
			<cfif url.oprid_delegateFrom NEQ "">
				,oprid_delegateFrom
			</cfif>
			<cfif url.oprid_delegateTo NEQ "">
				,oprid_delegateTo
			</cfif>)
		VALUES
			(<cfqueryparam cfsqltype="cf_sql_integer" value="#ara_id#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#this_job#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#id_status#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#url.cycle#">,
			'False',
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#url.Comment#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
			<cfif url.oprid_delegateFrom NEQ "">
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#url.oprid_delegateFrom#">
			</cfif>
			<cfif url.oprid_delegateTo NEQ "">
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#url.oprid_delegateTo#">
			</cfif>
			)
	</cfquery>

	<!--- If this is final approved, Update status --->
	<cfif isDefined('ThisisFinal') and (ThisisFinal EQ "True")>
		
		<cfquery name="Upd" datasource="#application.dsn#">
			Update ARA
			SET id_status=12
			where id_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#ara_id#">
		</cfquery>
	</cfif>
	<!--- Send Approval Email --->
	<cfset id_ara=ara_id>
	<cfinclude template="../m_emails/mail_Approve.cfm">
	<cfinclude template="../m_emails/CreatePDF.cfm">
	<!--- cfmail to="#TO#" cc="#cc#" from="Ariva@hii-tsd.com" type="HTML" subject="#subject#">#message#</cfmail --->
	
</cfif>

	<cfset confirmMsg="The ARA has been approved.">
	<cflocation addtoken="false" url="?fuseaction=app.ARA_approvals&AID=#url.AID#&id_status=#id_status#&confirmMsg=#confirmMsg#">