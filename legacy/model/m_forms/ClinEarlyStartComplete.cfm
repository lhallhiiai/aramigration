<!--- M. Gann 9/4/2012: Once an Early start is approved, CCS will enter the new
      CLINS onto the controller tab. Once this is done the status will be changed to
	  Early Start Complete (id_status = 16), and an email sent to all effected parties. --->
	  
<cfset ara_id="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">


<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>
	<cfquery name="updCLIN" datasource="#application.dsn#" result="result">
		Update ARA
		Set 
		id_status=16
		where
		Id_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#ara_id#">
	</cfquery>
	<cfset Comment="Step 3: Controller [#session.empname#] completed and approved.">
	<cfif session.delegators NEQ ""><!--- Delegatee may be approving --->
		<cfquery name="CheckDel" datasource="#application.dsn#">
			Select * from delegation
			where fk_delegatefrom_id=#session.ID_Controller# and fk_delegateTo_ID=#session.id_user#
			AND (GETDATE() BETWEEN startDate AND endDate)
		</cfquery>
		<cfif CheckDel.recordcount GT 0>
			<cfset id_job=3><!--- Show job as Contract Manager..delegatee might have job type of "Delegatee and we need to relate to approval chain --->
			<cfset Comment="#Comment#" & " [Delegation from #CheckDel.DelegateFrom_Oprid# to #checkDel.Delegateto_Oprid#].">
			<cfset oprid_delegateFrom=CheckDel.DelegateFrom_Oprid>
			<cfset oprid_delegateTo=CheckDel.DelegateTo_Oprid>
		<cfelse>
			<cfset id_job=session.id_job>
		</cfif>
	<cfelse>
		<cfset id_job=session.id_job>
	</cfif>
	<cfset Comment="CLINs Added to Early Start By [#session.empname#]">
	<cfquery name="Approval" datasource="#application.dsn#" result="result">
		INSERT INTO ARAAppLog
			(id_ara,
			id_user,
			id_job,
			id_status,
			cycle,
			isRejection,
			Comment,
			approvalDate
			<cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
				,oprid_delegatefrom
				,oprid_DelegateTo
			</cfif>
			)
		VALUES
			(<cfqueryparam cfsqltype="cf_sql_integer" value="#ara_id#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#id_job#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="16">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#val(revision+1)#">,
			'False',
			'#Comment#',
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
			<cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#oprid_delegatefrom#">
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#oprid_DelegateTo#">
			</cfif>
			)
	</cfquery>
	<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="A failure occurred when trying to update status to Early Start Completed. <br>Details: #cfcatch.detail# <br>">
		</cfcatch>
	</cftry>
	
	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			<cfset confirmMsg="The status of this ARA has been set to Early Start Completed.">
   	</cfif>
</cftransaction>
<cfset id_ara=#ara_id#>
<cfinclude template="../m_ara/qry_ara.cfm">

<!--- Send Approval Email --->
<cfset id_ara=ara_id>
<cfinclude template="../m_emails/mail_ESComplete.cfm">
<cfinclude template="../m_emails/CreatePDF.cfm">
<cfset ConfirmMsg="ARA Set to Early Start Complete">
<cflocation url="index.cfm?fuseaction=app.ARA_ControllerV2&SubMenu=Controller&confirmMsg=#ConfirmMsg#&AID=#url.aid#">