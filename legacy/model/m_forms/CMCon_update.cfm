<cfset ara_id="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
here I am 
<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>
	<cfquery name="upd_con" datasource="#application.dsn#" result="result">
		UPDATE ara
		Set 
		ID_Controller=#Form.ID_Controller#,
		ID_Contract=#Form.ID_Contract#
		where id_ara=#ara_id#
	</cfquery>
	<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="A failure occurred when trying to update controller and contract managers. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
		</cfcatch>
	</cftry>
	
	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			<cfset confirmMsg="Controller and Contract manager updated.">
   	</cfif>
</cftransaction>

<cfif committed EQ "Yes">
	<cflocation addtoken="false" url="index.cfm?fuseaction=app.ARA_PM&AID=#url.AID#&Action=UpdateSetup&confirmMsg=#confirmMsg#">
<cfelse>
	<cflocation addtoken="false" url="index.cfm?fuseaction=app.ARA_PM&AID=#url.AID#&Action=UpdateSetup&errorMsg=#errorMsg#">
</cfif>