<cfif isDefined('url.aid')>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
</cfif>

<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>
	<cfquery name="cancel" datasource="#application.dsn#" result="result">
		Update ARA
		set id_status=10
		where id_ara=#id_ara#
	</cfquery>
	<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="A failure occurred when cacelling this ARA. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
		</cfcatch>
	</cftry>
	
	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			<cfset confirmMsg="ARA #id_ara# has been cancelled.">
   	</cfif>
</cftransaction>

<cfif committed EQ "Yes">
	<cfset Comment="ARA cancelled by #UCASE(session.oprid)# (#session.jobtitle#)" >
	<cfquery name="Cancel" datasource="#application.dsn#" result="result">
		INSERT INTO ARAAppLog
			(id_ara,
			id_user,
			id_job,
			id_status,
			cycle,
			isRejection,
			comment,
			approvalDate
			)
		VALUES
			(<cfqueryparam cfsqltype="cf_sql_integer" value="#id_ara#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_job#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="10">,
			'1',
			'False',
			'#comment#',
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateFormat(now(), "mm/dd/yyyy")# #timeformat(now(),"hh:mm tt")#">
			)
	</cfquery>
	<!---<cfinclude template="../m_emails/mail_cancel.cfm">--->
	<cfif fuseaction NEQ 'app.AdminCleanOutOldAndExpired'>
		<cflocation addtoken="false" url="#CGI.HTTP_REFERER#&confirmMsg=#comment#">
	</cfif>
<cfelse>
	<cfif fuseaction NEQ 'app.AdminCleanOutOldAndExpired'>
		<cflocation addtoken="false" url="#CGI.HTTP_REFERER#&AID=&errorMsg=#errorMsg#">
	</cfif>
</cfif>