<cffunction name="Clean"><!--- Cleans out $(dollar signs) and commas from money values ---> 
	<cfargument required="yes" name="Value">
	<cfset value=Replace(Value,'$','',"All")><!--- Remove dollar signs --->
	<cfset value=Replace(Value,',','',"All")><!--- Remove commas --->
	<cfreturn value>
</cffunction>

<cfif isDefined('form.SavePM')>
	<cfset status='1'><!--- still working and saving --->
<cfelse>
	<cfset status='2'><!--- PM done - submit --->
</cfif>
<cfset confirmMsg="">
<cfoutput>

<!--- br>Now: #form.amountTotal#
<br>--#dollarformat(form.amountTotal)#

idara is #decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#
<cfset id_ara=#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#>
--#id_ara#
<br>status is #status#  --->

</cfoutput>

<cfquery name="newPM" datasource="#application.dsn#" result="result">
	UPDATE ARA
	SET
		totalAnticipated=<cfqueryparam cfsqltype="cf_sql_integer" value="#Clean(form.totalAnticipated)#">,
		percentAnticipated=<cfqueryparam cfsqltype="cf_sql_integer" value="#Clean(form.percentAnticipated)#">,
		id_status=<cfqueryparam cfsqltype="cf_sql_integer" value="#status#">,
		amountTotal=<cfqueryparam cfsqltype="CF_SQL_MONEY" value="#Clean(form.amountTotal)#">,
		startDate=<cfqueryparam cfsqltype="CF_SQL_DATE" value="#form.startDate#">,
		expirationDate=<cfqueryparam cfsqltype="CF_SQL_DATE" value="#form.ExpirationDate#">
	WHERE
		ID_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
</cfquery>
<cfquery name="DelPM" datasource="#application.dsn#">
		delete from ara_PM
		where ARA_id=<cfqueryparam cfsqltype="cf_sql_integer" value="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
	</cfquery>
    
<cfquery name="PMAppList" datasource="#application.dsn#" result="result2">
			INSERT INTO ara_PM
				(ARA_ID,
				actionToClear,
				changeInScope,
                ES_Necessary, 
                Other_necessary
				)
			VALUES
				(<cfqueryparam cfsqltype="cf_sql_integer" value="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.actionToClear#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.changeInScope#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.ES_Necessary#">,
       			<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Other_necessary#">
				)		
		</cfquery>
		
<cfset confirmMsg="ARA #reference# updated.">
<cfif Clean(form.AmountTotal) GTE 50000>
	<!--- Check to see if this has already been provided --->
	<cfquery name="ChkPM" datasource="#application.dsn#">
		SELECT * from ara_PM
		where ARA_id=<cfqueryparam cfsqltype="cf_sql_integer" value="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
	</cfquery>
	
	
	<cfif ChkPM.recordcount EQ 0>
	<!--- ++++++++++++++++++++++++++ Insert Additional 6 Questions, for over 50K ++++++++++++++++++++++++++ --->
		<cfquery name="PMAppList" datasource="#application.dsn#" result="result2">
			INSERT INTO ara_PM
				(ARA_ID,
				fundsInAdvance,
				contractDefinization,
				pertinentInformation,
				workStarted,
				consequence,
				currentStatus
				)
			VALUES
				(<cfqueryparam cfsqltype="cf_sql_integer" value="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.FundsInAdvance#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.ContractDefinization#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.pertinentInformation#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.workStarted#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Consequence#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.currentStatus#">
				)		
		</cfquery>
		
	<cfelse>
	<!--- ++++++++++++++++++++++++++ Otherwise UPDATE 6 Questions ++++++++++++++++++++++++++ --->
		<cfquery name="UpdPM" datasource="#application.dsn#" debug="yes" result="pie">
			UPDATE ara_PM
			set ARA_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">,
			    fundsInAdvance=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.FundsInAdvance#">,
				contractDefinization=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.ContractDefinization#">,
				pertinentInformation=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.pertinentInformation#">,
				workStarted=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.workStarted#">,
				consequence=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Consequence#">,
				currentStatus=<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.currentStatus#">
			where
				ARA_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
		</cfquery>
		
	</cfif>
	 
</cfif><!--- AmountTotal => 50K --->	



				
				


<cfif isDefined('SavePM')><!--- save and return to PM form --->
	<cflocation addtoken="false" url="?fuseaction=app.ARA_PM&Menu=ARA_Detail&AID=#url.AID#&confirmMsg=#confirmMsg#&isSaved=1">
<cfelse><!--- Flag PM approved --->
	<cfset Comment="Step 1: Program Manager [#session.empname#] completed and approved.">
	<cfif session.delegators NEQ ""><!--- Delegatee may be approving --->
		<cfquery name="CheckDel" datasource="#application.dsn#">
			Select * from delegation
			where fk_delegatefrom_id=#ID_PM# and fk_delegateTo_ID=#session.id_user#
			AND (GETDATE() BETWEEN startDate AND endDate)
		</cfquery>
		<cfif CheckDel.recordcount GT 0>
			<cfset id_job=1><!--- Show job as PM...as delegatee might have job type of "Delegatee and we need to relate to approval chain --->
			<cfset Comment="#Comment#" & " [Delegation from #CheckDel.DelegateFrom_Oprid# to #checkDel.Delegateto_Oprid#].">
			<cfset oprid_delegateFrom=CheckDel.DelegateFrom_Oprid>
			<cfset oprid_delegateTo=CheckDel.DelegateTo_Oprid>
		<cfelse>
			<cfset id_job=session.id_job>
		</cfif>
	<cfelse>
		<cfset id_job=1>
	</cfif>
	<cfset Comment="#comment#" & " Submitted to contracts.">
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
			<cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
				,oprid_delegatefrom
				,oprid_DelegateTo
			</cfif>
			)
		VALUES
			(<cfqueryparam cfsqltype="cf_sql_integer" value="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#id_job#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="2">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#val(form.revision+1)#">,
			'False',
			'#comment#',
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateFormat(now(), "mm/dd/yyyy")# #timeformat(now(),"hh:mm tt")#">
			
			<cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#oprid_delegatefrom#">
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#oprid_DelegateTo#">
			</cfif>
			)
	</cfquery>
	<!--- Get all of ara info, send email, return to main screen --->
	<cfset id_ara=#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#>
	<cfinclude template="../m_ara/qry_ara.cfm"><!---ara info including Jamis number --->
	<cfquery name="Name" datasource="#application.dsn#">
		Select empname from users
		where id_user=#session.id_user#
	</cfquery>
	
	<cfset intro="ARA cancelled. Expiration date passed,  ARA no longer needed, or ARA stuck in process due to departing staff. ">
	<cfinclude template="../m_emails/mail_Approve.cfm">
	<cfset ConfirmMsg="PM portion of ARA has been submitted. The Contracts Manager will now provide contract information.">
	<cflocation addtoken="false" url="?fuseaction=app.ARA_PM&FormorView=View&ConfirmMsg=#ConfirmMsg#&Menu=ARA_Detail&AID=#url.AID#&isSaved=1">
</cfif>