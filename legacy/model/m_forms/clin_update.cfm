<cfset ara_id="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cfoutput>#costfunding#,#feefunding#, #araTotal#</cfoutput>
<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>
	<cfset costFunding=numberformat(val(costFunding),"9999.99")>
	<cfset FeeFunding=numberformat(val(FeeFunding),"9999.99")>
	<cfset ARATotal=numberformat(val(ARATotal),"9999.99")>
	<cfquery name="updCLIN" datasource="#application.dsn#" result="result">
		Update Clins
		Set 
		ClinNo='#ClinNum#',
		Description='#ClinDesc#',
		ExpirationDate='#ClinExp#',
		CostFunding=#CostFunding#,
		FeeFunding=#FeeFunding#,
		Total=#ARATotal#
		where
		Id_clins=#id_clins#
	</cfquery>
	<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="A failure occurred when trying to update this CLIN. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
		</cfcatch>
	</cftry>
	
	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			<cfset confirmMsg="CLIN updated.">
   	</cfif>
</cftransaction>

<cfif committed EQ "Yes">
	<cflocation addtoken="false" url="?fuseaction=app.ARA_Clins&AID=#url.AID#&id_Clins=#id_clins#&Action=InsertSetup&confirmMsg=#confirmMsg#">
<cfelse>
	<cflocation addtoken="false" url="?fuseaction=app.ARA_Clins&AID=#url.AID#&id_Clins=#id_clins#&Action=InsertSetup&errorMsg=#errorMsg#">
</cfif>