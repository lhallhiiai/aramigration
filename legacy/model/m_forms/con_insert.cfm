<cfdump var="#form#" format="text">
<cffunction name="Clean"><!--- Cleans out $(dollar signs) and commas from money values ---> 
	<cfargument required="yes" name="Value">
	<cfset value=Replace(Value,'$','',"All")><!--- Remove dollar signs --->
	<cfset value=Replace(Value,',','',"All")><!--- Remove commas --->
	<cfreturn value>
</cffunction>
<cfset ara_id="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
    <cftransaction action="begin">
        <!--- @Comment: Start Transaction (TRY) --->
        <cfset committed = "Yes" />
        <!--- cftry --->
        <cfquery name="newCon" datasource="#application.dsn#" result="result">
        INSERT INTO ARA_Con
            (id_ara,
            id_user,
            interestImpact,
            burnRate,
            total_cost,
            total_fee
			<cfif  isDefined('Form.iccost') and Form.iccost NEQ "">
            ,icCost
			</cfif>
			<cfif isDefined('Form.icFee') and Form.icFEE NEQ "">
            ,icFee
			</cfif>
			<!---,
            company--->
            )
        VALUES
            (<cfqueryparam cfsqltype="cf_sql_integer" value="#ara_id#">,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
            <cfqueryparam cfsqltype="cf_sql_float" value="#clean(form.InterestImpact)#">,
            <cfqueryparam cfsqltype="cf_sql_float" value="#Clean(form.BurnRate)#">,
            <cfqueryparam cfsqltype="cf_sql_float" value="#clean(form.total_Cost)#">,
            <cfqueryparam cfsqltype="cf_sql_float" value="#clean(form.total_Fee)#">
			<cfif isDefined('Form.icCost') and Form.iccost NEQ "">
            	,<cfqueryparam cfsqltype="cf_sql_float" value="#Clean(form.IcCost)#">
			</cfif>
			<cfif isDefined('Form.icCost') and Form.icFEE NEQ "">
            	,<cfqueryparam cfsqltype="cf_sql_float" value="#Clean(form.IcFee)#">
			</cfif>
			<!---,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.company#">--->)
        </cfquery>
       
        <!---<cfquery name="upd_ARA" datasource="#application.dsn#" result="result">
		UPDATE ara 
		Set
        company='#company#'
		where id_ara=#ara_id#
	</cfquery>--->
        <!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
            <!--- cfcatch type="database">
                <cfset committed = "No" />
                <cftransaction action = "rollback" />
                <cfset errorMsg="A failure occurred when trying insert the controller cost and fee information. ">
        <cfdump var="#cfcatch#" format="text">
            </cfcatch>
        </cftry--->
        
        <!--- @Comment: Check for Commit --->
        <cfif committed EQ "Yes">
                <cftransaction action="commit" />
                <cfset confirmMsg="Controller Summary Information recorded.">
        </cfif>
    </cftransaction>
 
    <cfif committed EQ "Yes">
		<cfif isDefined('Submit') and Submit EQ "True">
			<cfif form.id_cat NEQ 10>
				<cfoutput>
				Total_Value is #Total_Value# (controller) and amountTotal is #amountTotal#<br>
				</cfoutput>
				<cfif Total_Value NEQ amountTotal>
					<cfset errorMsg="The total amount of the ARA (#dollarformat(amountTotal)#) does not equal the Sum of the CLINS (#dollarformat(Total_Value)#). Either change the CLIN amounts or REJECT the ARA. It will be returned to the PM for total amount correction.">
					<cflocation url="index.cfm?fuseaction=app.ARA_ControllerV2&AID=#AID#&ID_status=4&errorMsg=#errorMsg#">
				</cfif>
			</cfif>
			<cflocation addtoken="false" url="?fuseaction=app.con_submit&AID=#url.AID#&id_cat=#id_cat#&revision=#revision#&Total_Value=#Total_Value#&amountTotal=#amountTotal#">
		<cfelse>
        	<cflocation addtoken="false" url="?fuseaction=app.ARA_ControllerV2&AID=#url.AID#&Action=Update&confirmMsg=#confirmMsg#">
		</cfif>
    <cfelse>
        <cflocation addtoken="false" url="?fuseaction=app.ARA_controllerV2&AID=#url.AID#&Action=Insert&errorMsg=#errorMsg#">
    </cfif>