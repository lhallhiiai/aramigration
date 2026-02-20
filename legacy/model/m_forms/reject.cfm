<cfparam name="newStatus" default="9">
<cfset id_user=#session.id_user#>
<cfinclude template="../m_user/get_users.cfm">
<cfset Reject_Comment="<b>REJECTION</b> #Session.jobTitle#, [#session.empname#]:  #form.Rej_desc#">
<cfoutput>
newstatus is #newstatus#<br>
#reject_Comment#
<br>cycle is #cycle#<br>
</cfoutput>
<!--- Reject ARA:  MGann 2/8/2012 --->


<!--- Write Entry into ARAappLog --->  

	  <cfquery name="Log" datasource="#Application.dsn#">
	  	Insert Into araAppLog
		(id_ara,
		id_user,
		id_job,
		id_status,
		isRejection,
		Comment,
		ApprovalDate,
		cycle,
		id_reason,
		Rej_areas
		<cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
				,oprid_delegateFrom
		</cfif>
		<cfif isDefined('oprid_delegateTo') and (oprid_delegateTo NEQ "")>
				,oprid_delegateTo
		</cfif>
		)
		
		VALUES
		(<cfqueryparam cfsqltype="cf_sql_integer" value="#id_ara#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_job#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#newstatus#">,
		'true',
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#Reject_comment#">,
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#cycle#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#id_reason#">,
        <cfif isDefined('Rej_areas')>
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#Rej_areas#">
        <cfelse>
        ''
        </cfif>
		<cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#oprid_delegateFrom#">
		</cfif>
		<cfif isDefined('oprid_delegateFrom') and (oprid_delegateTo NEQ "")>
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#oprid_delegateTo#">
		</cfif>
		)
		
	  </cfquery>
	
<!--- Update status so shows correctly in emails --->
<cfquery name="Status" datasource="#Application.DSN#">
		  	UPdate ARA 
			Set 
			id_Status=#newstatus#
			where id_ara=#Form.id_ara#
		  </cfquery>
<!--- Update Revision and Cycle --->
	<cfquery name="Rev" datasource="#Application.dsn#">
		Select reference, revision
		from ara
		where id_ara=#Form.id_ara#
	</cfquery>
	<cfset new_revision=val(rev.revision+1)>
	<cfdump var="#Rev#" format="text"><br>
	<cfdump var="#new_revision#" format="text">
	<cfset ara_ref=listgetat(rev.reference,1,'-')>
	<!--- cfset ara_num=(val(listgetat(rev.reference,2,'-'))+1) --->
	<cfset ara_ref="#ara_ref#-"&"#new_revision#">  
	  




<!---  Send Email --->
    <!--- retrieve all ara infomation --->
	<cfinclude template="../m_ara/qry_ara.cfm">
	<cfset AID=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
	<cfquery name="gReason" datasource="#Application.dsn#">
		Select reason
		from rejectionReason
		where id_reason=#id_reason#
	</cfquery>
	<cfquery name="Team" datasource="#application.dsn#">
	Select empname
	from v_users
	where id_user in ('#id_pm#','#id_contract#', '#id_controller#')
	</cfquery>
	<cfdump var="#session#" format="text">
	<cfset rejector=#session.empname#>
	<cfdump var="#team#" format="text">
	<cfset team=Valuelist(Team.empname)>
	<cfset pm_nm=ListGetAt(Team,1)>
	<cfset contract_nm=ListGetAt(Team,2)>
	<cfset controller_nm=ListGetAt(Team,3)>
	
	<cfset Subject="ARA #Reference#: Rejected by #rejector#">
	<cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
		<cfset Subject="#subject# [Delegated to by #oprid_delegateFrom#]">
	</cfif>
	<cfset shortDesc="#Form.Title#: Rejection Reason: " & " #gReason.reason#">
	<cfset intro="ARA Rejected and Returned to Program Manager for Revision.">
	<cfset MsgText="<b>ARA #Reference# has been rejected by #session.empname#. Please correct the ARA and resubmit it for approval. The ARA revision number has been incremented to: #ara_ref#.
">  
	<cfinclude template="../m_emails/mail_Reject.cfm">
	<!--- cfmail to="#TO#" cc="#cc#" from="Ariva@Alionscience.com" type="HTML" subject="#subject#">#message#</cfmail --->
	<cfset confirmMsg="ARA #Reference# has been rejected. All ARA participants have been notified, and the ARA has been placed back in the queue of the Program Manager.">


	
	<cfset cycle=val(cycle+1)>
	<!--- Change ARA status to Rejected - set status to 8 if rejected
	      by Peer, or 9 if Rejected in Approvals chain --->
		  <cfquery name="Status" datasource="#Application.DSN#">
		  	UPdate ARA 
			Set 
			Revision=#new_revision#
			,reference='#ara_ref#'
			where id_ara=#Form.id_ara#
		  </cfquery>
	  
<cfswitch expression="#returnTo#">
<cfcase value="approvals">  
	<cflocation url="index.cfm?Fuseaction=app.ARA_approvals&AID=#AID#&confirmMsg=#confirmMsg#"  ADDTOKEN="No">
</cfcase>
<cfcase value="Controller">
	<cflocation url="index.cfm?Fuseaction=app.ARA_ControllerV2&AID=#AID#&confirmMsg=#confirmMsg#"  ADDTOKEN="No">
</cfcase>
<cfcase value="Contracts">
	<cflocation url="index.cfm?Fuseaction=app.ARA_ContractInfo&AID=#AID#&confirmMsg=#confirmMsg#"  ADDTOKEN="No">
</cfcase>
</cfswitch>

