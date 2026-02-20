
<cfif isDefined('form.jnumber') AND (form.jnumber NEQ "")><!--- Early Starts will not have pre-existing information --->

	<cfset jnumber=Trim(listgetat(form.jnumber,1,','))>
    <cfset jnumberCompany=Trim(listgetat(form.jnumber,3,','))>
	<cfquery name="ContractDetails" datasource="#application.dsn#">
		Select * from ARA_CP_DATA 
		where COSTPT_NO='#jnumber#' and Replace(CUST_NAME, ',', '') = '#jnumberCompany#' 
	</cfquery>
	
<cfset EndCustName=ContractDetails.cust_Name>
<cfset form.jnumber=Trim(listgetat(form.jnumber,1,','))>

<cfif contractdetails.recordcount EQ 0>
	<cfset errorMsg="Project and customer name Not Found">
	<cflocation url="index.cfm?fuseaction=app.CreateARAStep1&Menu=ARA_Sum&errorMsg=#errorMsg#">
</cfif>


<cfelse><!--- may have to initializes variable --->
</cfif><!--- found id in agreements table --->


