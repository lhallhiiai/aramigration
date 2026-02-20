<cfquery name="prevARA" datasource="#application.dsn#">
	SELECT TOP 1 id_ara
	FROM ara
	ORDER BY ID_ara DESC
</cfquery>
<cfset prevID = prevARA.id_ara>
<cfif prevARA.recordcount eq 0>
	<cfset prevID = 0>
</cfif>
<cfset reference=previd + 1>

<cfquery name="newARA" datasource="#application.dsn#" result="result">
	INSERT INTO ARA
		(id_cat,
		id_user,
		division,
		id_status,
		reference,
		revision,
		title,
		customerName,
		contractNo,
		jamisNo,
		amountTotal,
		startDate,
		expirationDate,
		isEarlyStart,
		ID_REVENUE,
		OMSNum,
        isEAC, 
		ID_PM
		<cfif isDefined('ID_Contract') AND (ID_contract NEQ "")>
		,ID_Contract
		</cfif>
		<cfif isDefined('ID_Controller') AND (ID_controller NEQ "")>
		,ID_Controller
		</cfif>
		<cfif isDefined('ID_OpsVP') AND (ID_OpsVP NEQ "")>
		,ID_OpsVP
		</cfif>)
	VALUES
		(<cfqueryparam cfsqltype="cf_sql_integer" value="#form.id_cat#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.division#">,
		'1',
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#numberformat(reference, "00000000")#-#form.revision#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#form.revision#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.title#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.customerName#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.contractNo#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.jamisNo#">,
		<cfqueryparam cfsqltype="cf_sql_money" value="0">,
		<cfqueryparam cfsqltype="cf_sql_date" value="">,
		<cfqueryparam cfsqltype="cf_sql_date" value="">,
		'0',
		<cfqueryparam cfsqltype="cf_sql_integer" value="#form.ID_REVENUE#">,
		<cfqueryparam cfsqltype="cf_sql_varchar" value="#form.OMSNum#">,
        <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.isEAC#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#form.ID_pm#">
		<cfif isDefined('ID_Contract') AND (ID_contract NEQ "")>
			,<cfqueryparam cfsqltype="cf_sql_integer" value="#form.ID_Contract#">
		</cfif>
		<cfif isDefined('ID_Controller') AND (ID_controller NEQ "")>
			,<cfqueryparam cfsqltype="cf_sql_integer" value="#form.ID_Controller#">
		</cfif>
		<cfif isDefined('ID_OpsVP') AND (ID_OpsVP NEQ "")>
			,<cfqueryparam cfsqltype="cf_sql_integer" value="#form.ID_OpsVP#">
		</cfif>
		)		
</cfquery>

<cfquery name="getID" datasource="#application.dsn#" result="result">
	Select max(id_ara) as id_ara from ara
</cfquery>

<cfquery name="LogNew" datasource="#application.dsn#">
		INSERT INTO ARAAppLog
			(id_ara,
			id_user,
			id_job,
			id_status,
			cycle,
			isRejection,
			comment,
			approvalDate)
		VALUES
			(<cfqueryparam cfsqltype="cf_sql_integer" value="#getID.id_ara#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_job#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="1">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#val(Revision+1)#">,
			'False',
			'ARA #numberformat(reference, "00000000")#-#form.revision# Created.',
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">)
	</cfquery>
<cfset id_ara = #getID.id_ara#>
<cfif (session.id_job NEQ 3)>
<cflocation addtoken="false" url="?fuseaction=app.ARA_PM&Menu=ARA_Detail&AID=#encrypt(getID.id_ara,request.encryptkey,request.encrypttype,'hex')#">
<cfelse>
<cfinclude template="../m_emails/mail_PCCreated.cfm">
<cflocation addtoken="false" url="?Fuseaction=app.ARA_PM&msg=PCcreated&AID=#encrypt(getID.id_ara,request.encryptkey,request.encrypttype,'hex')#&ID_status=1&Menu=ARA_Detail">
</cfif>