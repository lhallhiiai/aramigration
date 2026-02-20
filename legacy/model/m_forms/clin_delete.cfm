<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>
	<cfquery name="delCLIN" datasource="#application.dsn#" result="result">
		Delete from CLINs
		where
		Id_clins=#id_clins#
	</cfquery>
	<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="A failure occurred when trying to delete this CLIN. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
		</cfcatch>
	</cftry>
	
	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			<cfset confirmMsg="CLIN deleted.">
   	</cfif>
</cftransaction>
<cfinclude template="con_updateTotals.cfm"><!--- update totals in the controller record --->

<cfif committed EQ "Yes">
	<cflocation addtoken="false" url="?fuseaction=app.ARA_controllerV2&AID=#url.AID#&id_Clins=#id_clins#&Action=InsertSetup&confirmMsg=#confirmMsg#">
<cfelse>
	<cflocation addtoken="false" url="?fuseaction=app.ARA_controllerV2&AID=#url.AID#&id_Clins=#id_clins#&Action=InsertSetup&errorMsg=#errorMsg#">
</cfif>