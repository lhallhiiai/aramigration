
<cfif isDefined('form.CancelPM')>
	<cfset status='10'><!--- ARA status set to cancelled --->
</cfif>
<cfset confirmMsg="">
<cfoutput>
<cfset subject="">
</cfoutput>

<cfquery name="newPM" datasource="#application.dsn#" result="result">
	UPDATE ARA
	SET
		id_status=<cfqueryparam cfsqltype="cf_sql_integer" value="#status#">
	WHERE
		ID_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
</cfquery>
<cfset confirmMsg="ARA #reference# Cancelled.">

<cfif isDefined('CancelPM')><!--- cancel and return to PM form --->
	<cfquery name="Approval" datasource="#application.dsn#" result="result">
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
			(<cfqueryparam cfsqltype="cf_sql_integer" value="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_job#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="10">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#val(form.revision+1)#">,
			'False',
			'Cancel: #session.oprid# [#session.jobtitle#] cancelled ARA.',
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">)
	</cfquery>
    
	<!--- Get all of ara info, send email, return to main screen --->
	<cfset id_ara=#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#>
	<cfinclude template="../m_ara/qry_ara.cfm"><!---ara info including Jamis number --->
    
	<cfquery name="PM" datasource="#application.dsn#">
		Select empname from users
		where id_user=#session.id_user#
	</cfquery>
	
	<cfset intro="ARA #reference# was CANCELLED by #Ucase(session.oprid)#">
    
    <cfset subject="CANCELLED: ARA #reference#, Costpoint Project Number: #JamisNo# -  #title# has been CANCELLED">
	<cfinclude template="../m_emails/mail_cancel.cfm">
	<cfset ConfirmMsg="ARA #reference# has been cancelled.">
	<cflocation addtoken="false" url="?fuseaction=app.ARA_PM&FormorView=View&ConfirmMsg=#ConfirmMsg#&Menu=ARA_Detail&AID=#url.AID#">
</cfif>