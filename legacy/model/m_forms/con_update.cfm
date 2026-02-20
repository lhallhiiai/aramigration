<cfset ara_id="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cffunction name="Clean"><!--- Cleans out $(dollar signs) and commas from money values ---> 
	<cfargument required="yes" name="Value">
	<cfset value=Replace(Value,'$','',"All")><!--- Remove dollar signs --->
	<cfset value=Replace(Value,',','',"All")><!--- Remove commas --->
	<cfreturn value>
</cffunction>
<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>
	<cfquery name="upd_con" datasource="#application.dsn#" result="result">
		UPDATE ara_con
		Set interestImpact=#Clean(interestImpact)#,
		burnRate=#Clean(burnRate)#,
		Total_cost=#Clean(total_cost)#,
		Total_fee=#Clean(total_fee)#
		<cfif isDefined('Form.icCost') and Form.iccost NEQ "">
			,icCost=#Clean(icCost)#
		</cfif>
		<cfif isDefined('Form.icFee') and Form.icFee NEQ "">
			,icFee=#clean(IcFee)#
		</cfif>
		<!---, 
        company='#company#'--->
		where id_ara=#ara_id#
	</cfquery>
    <!---<cfquery name="upd_ARA" datasource="#application.dsn#" result="result">
		UPDATE ara 
		Set
        company='#company#'
		where id_ara=#id_ara#
	</cfquery>--->
	<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="A failure occurred when trying to update the controller info. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
		</cfcatch>
	</cftry>
	
	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			<cfset confirmMsg="Controller Information Updated.">
   	</cfif>
</cftransaction>

<cfif committed EQ "Yes">
		<cfif isDefined('Submit') and Submit EQ "True">
			<cfif form.id_cat NEQ 10>
				<cfoutput>
				Total_Value is #Total_Value# (controller) and amountTotal is #amountTotal#<br>
				</cfoutput>
				<cfif Total_Value NEQ amountTotal>
                
					<cfset errorMsg="Total_Value is #Total_Value# (controller) and amountTotal is #amountTotal#. The total amount of the ARA does not equal the Sum of the CLINS. Either change the CLIN amounts or REJECT the ARA. It will be returned to the PM for total amount correction.">
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