<!--- deletes ARA and all subbordinate table entries. MGann 12/20/2011 --->
<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">


<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>
		<cfquery name="log" datasource="#Application.dsn#">
			dELETE FROM ARAAppLOG
			WHERE ID_ARA=#id_ara#
		</cfquery>
		<cfquery name="Attach" datasource="#application.dsn#">
			dELETE FROM ATTACHMENTS 
			where id_ara=#id_ara#
		</cfquery>
		<cfquery name="PM" datasource="#application.dsn#">
			delete from ara_pm
			where ara_id=#id_ara#
		</cfquery>
		<cfquery name="Con" datasource="#Application.dsn#">
			delete from ara_con
			where id_ara=#id_ara#
		</cfquery>
		
		<cfquery name="CM" datasource="#application.dsn#">
			delete from ara_cm
			where id_ara=#id_ara#
		</cfquery>
		
		<cfquery name="clins" datasource="#application.dsn#">
			delete from clins
			where id_ara=#id_ara#
		</cfquery>
		<cfquery name="emaillog" datasource="#application.dsn#">
			delete from emaillog
			where id_ara=#id_ara#
		</cfquery>
		<cfquery name="Ara" datasource="#application.dsn#">
			delete from ara
			where id_ara=#id_ara#
		</cfquery>
		<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="A failure occurred when trying to delete this ARA. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
			<cflocation url="index.cfm?fuseaction=app.home&Menu=Home&ErrorMsg=#ErrorMsg#"  addtoken="No">
		</cfcatch>
	</cftry>
	
	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			<cfset confirmMsg="ARA and all subordinate records have been deleted.">
			<cflocation url="index.cfm?fuseaction=app.home&Menu=Home&ConfirmMsg=#ConfirmMsg#&AllorMine1=#Mine#&PageQuery=home" addtoken="No">
   	</cfif>
</cftransaction>