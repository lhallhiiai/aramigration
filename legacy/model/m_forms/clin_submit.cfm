<cfset id_ara="#decrypt(AID,request.encryptkey,request.encrypttype,'hex')#">
<cffunction name="Clean"><!--- Cleans out $(dollar signs) and commas from money values ---> 
	<cfargument required="yes" name="Value">
	<cfset value=Replace(Value,'$','',"All")><!--- Remove dollar signs --->
	<cfset value=Replace(Value,',','',"All")><!--- Remove commas --->
	<cfreturn value>
</cffunction>
<!--- Check for autoselected value: should have multiple dashes, oen comma, and two brackets --->

<cfif isdefined("form.allowedAMT") and form.ARATotal GT Form.allowedAMT>
	<cfset errorMsg="The Sum of the CLIN Amounts Must Not Exceed Total ARA amount (Total ARA amount is #Form.allowedAMT#, and Clin Line Total is #aratotal#). You may enter another amount, or reject ARA for PM to update Total ARA Amount">
	<cflocation addtoken="false" url="?fuseaction=app.ARA_controllerV2&AID=#url.AID#&Action=Insert&errorMsg=#errorMsg#">   
<cfelse>
<cfquery name="upd_ARA" datasource="#application.dsn#" result="result">
		UPDATE ara 
		Set
        company='#company#'
		where id_ara=#id_ara#
	</cfquery>
<cfif NOT isDefined('TempClinNum')><!--- Parse automcomplete from Jamis if not early start --->
	<!--- Check for autoselected value: should have multiple dashes, oen comma, and two brackets --->
	<cfset findcount=find('-',Form.ClinNum)>
	<cfset findcount= findcount + (find(',',Form.ClinNum)) + (find('[',Form.ClinNum)) + (find(']',Form.ClinNum))>
	<cfif findcount EQ 0>
		<cfset errorMsg="Invalid number Entered.">
		<cflocation url="index.cfm?Fuseaction=app.ARA_ControllerV2&AID=#AID#&ID_status=4&Menu=ARA_Detail&errorMsg=Invalid%20Clin%20Entered.#findcount#" addtoken="No">
	<cfelse>
		<cfset Num=LISTGetAt(Form.ClinNum,1,',')>
		<cfset temp=ListGetAT(Form.ClinNum,2,',')>
		<cfset i=Find('[End:',Temp)>
		<cfset ClinDesc=Trim(Mid(Temp,1,i-1))>
		<cfset ClinExp=Trim(Mid(temp,i+5,(len(temp))))>
		<cfset ClinExp=Reverse(Mid((Reverse(ClinExp)),2,(len(ClinExp))))>
		<cfset CameFromJamis=1>
	</cfif>
<cfelse><!--- Early Start Clins provided in TempClinNum --->
	<cfset Num=TempClinNum>
	<cfquery name="GetDesc" datasource="#application.ods#">
		   Select Clin_desc,
		        substring(cast(end_date as varchar(8)), 5,2)+'/'+substring (cast(end_date as varchar(8)),7,2)+'/'+substring(cast(end_date as varchar(8)),1,4) as end_date
            FROM jobcost.t_clin_master_ckis

            WHERE  (
            clin_no = <cfqueryparam value="#tempClinNum#" cfsqltype="cf_sql_varchar" />
            )

	</cfquery>
	<cfdump var="#GetDesc#" format="text">
	<cfif GetDesc.RecordCount GT 0>
		<cfset ClinDesc=GetDesc.Clin_Desc>
		<!---<cfset ClinExp="#mid(clinDesc.end_date,5,2)#" & '/' & "#mid(clinDesc.end_Date,7,2)#" & "/" & "#mid(clindesc.end_date,1,4)#">--->
		<!---<cfset ClinExp=Dateformat(")>--->
		<cfset ClinExp=GetDesc.end_date>
		<cfoutput>ClinExp is #clinExp#</cfoutput>
	<cfelse>
		<cfset ClinDesc="Not found in Jobcost">
		<cfset ClinExp=Dateformat(Now(),"MM/DD/YY")>
		
	</cfif>
	<cfset CameFromJamis=0>
</cfif>

<cfquery name="checkClin" datasource="#Application.dsn#">
	SELECT * 
	FROM ara_CP_Data	
	WHERE  clin = '#trim(num)#'
</cfquery>

<cfif checkClin.recordcount EQ 0> <!--- clin does not exist --->
		
	<cfoutput><cfset errorMsg="#Num# you have selected does not exist. Please check and try again"></cfoutput>

	<cflocation addtoken="false" url="?fuseaction=app.ARA_controllerV2&AID=#url.AID#&Action=Insert&errorMsg=#errorMsg#">   
<cfelse>
<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>

	<cfquery name="newCLIN"  datasource="#application.dsn#" result="result">
		INSERT INTO clins
			(id_ara,
			clinNo,
			description,
			expirationDate,
			costFunding,
			feeFunding,
			total,
			CameFromJamis)
		VALUES
			(<cfqueryparam cfsqltype="cf_sql_integer" value="#id_ara#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#Num#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#ClinDesc#">,
			<cfqueryparam cfsqltype="cf_sql_date" value="#checkClin.end_dt#">,
			<cfqueryparam cfsqltype="cf_sql_float" value="#Clean(form.costFunding)#">,
			<cfqueryparam cfsqltype="cf_sql_float" value="#Clean(form.feeFunding)#">,
			<cfqueryparam cfsqltype="cf_sql_float" value="#Clean(form.ARATotal)#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="0">)
	</cfquery>
	<cfdump var="#result#" format="text">
	<cfquery name="getID" datasource="#Application.dsn#">
		Select Max(id_clins) as newID From Clins
	</cfquery>
	<cfset id_clins = #getID.newID#>	
	<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="any">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
		</cfcatch>
	</cftry>
	
	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			<cfset confirmMsg="CLIN added to ARA.">
   	</cfif>
</cftransaction>
<cfinclude template="con_updateTotals.cfm"><!--- update totals in the controller record --->

<cfif committed EQ "Yes">

	<cflocation addtoken="false" url="?fuseaction=app.ARA_controllerV2&AID=#url.AID#&id_Clins=#id_clins#&confirmMsg=#confirmMsg#">
<cfelse>
	<cfset errorMsg="A failure occurred when trying to add this CLIN. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
	<cflocation addtoken="false" url="?fuseaction=app.ARA_controllerV2&AID=#url.AID#&id_Clins=#id_clins#&errorMsg=#errorMsg#">
</cfif>
</cfif> <!-- checkClin --->
</cfif>
