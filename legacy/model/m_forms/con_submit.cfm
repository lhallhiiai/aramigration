<cfset ara_id="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cfif (id_cat NEQ 10)>
	<cfoutput>
	Total_Value is #Total_Value# (controller) and amountTotal is #amountTotal#<br>
	</cfoutput>
	<cfif Total_Value NEQ amountTotal>
		<cfset errorMsg="The total amount of the ARA (#dollarformat(amountTotal)#) does not equal the Sum of the CLINS (#dollarformat(Total_Value)#). Either change the CLIN amounts or REJECT the ARA. It will be returned to the PM for total amount correction.">
		<cflocation url="index.cfm?fuseaction=app.ARA_ControllerV2&AID=#AID#&ID_status=4&errorMsg=#errorMsg#">
	</cfif>
</cfif>
<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>
	<cfquery name="newCon" datasource="#application.dsn#" result="result">
	UPDATE ARA
	SET
		id_status='6'
	WHERE
		ID_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#ara_id#">
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
			<cfset Comment="#Comment#" & " [Delegation from rom #CheckDel.DelegateFrom_Oprid# to #checkDel.Delegateto_Oprid#].">
			<cfset oprid_delegateFrom=CheckDel.DelegateFrom_Oprid>
			<cfset oprid_delegateTo=CheckDel.DelegateTo_Oprid>
		<cfelse>
			<cfset id_job=session.id_job>
		</cfif>
	<cfelse>
		<cfset id_job=session.id_job>
	</cfif>
	<cfset Comment="#comment#" & " Submitted to approval chain.">
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
			<cfqueryparam cfsqltype="cf_sql_integer" value="6">,
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
			<cfset errorMsg="A failure occurred when trying tosubmit the controller. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
		</cfcatch>
	</cftry>
	
	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			<cfset confirmMsg="This ARA has now been submitted for approvals. It can be viewed, but not updated.">
   	</cfif>
</cftransaction>

<cfif committed EQ "Yes">
	<!--- Get all of ara info, send email, return to main screen --->
	<cfset id_ara=#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#>
	<cfinclude template="../m_ara/qry_ara.cfm"><!---ara info including Jamis number --->
	<cfquery name="PM" datasource="#application.dsn#">
		Select empname from users
		where id_user=#session.id_user#
	</cfquery>
	<cfset id_emailtype=1>
	<cfset intro="ARA information completed and awaiting approval.">
	<cfinclude template="../m_emails/mail_approve.cfm">
	<cflocation addtoken="false" url="?fuseaction=app.ARA_ControllerV2&AID=#url.AID#&FormorView=View&confirmMsg=#confirmMsg#">
<cfelse>
	<cflocation addtoken="false" url="?fuseaction=app.ARA_ControllerV2&AID=#url.AID#&Action=UpdateSetup&errorMsg=#errorMsg#">
</cfif>
