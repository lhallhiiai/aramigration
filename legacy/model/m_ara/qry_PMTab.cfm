
<!--- Query Information for PM tab --->
<cfquery name="PM_Tab" datasource="#Application.dsn#">
	SELECT     
		ara.id_ara, ara_PM.ara_PM_ID, ara_PM.ara_ID, ara_PM.fundsInAdvance, 
		ara_PM.contractDefinization, ara_PM.pertinentInformation, 
        ara_PM.workStarted, ara_PM.consequence, ara_PM.currentStatus, ara_PM.ES_Necessary, ara_PM.Other_necessary,
		ara.id_cat, ara.amountTotal, ara.amountRequested, ara.totalAnticipated, 
        ara.percentAnticipated, ara.startDate, ara.ExpirationDate, ara.isEarlyStart, ara.ID_esReason, ara.esOther
		
FROM     ara INNER JOIN
         ara_PM ON ara.id_ara = ara_PM.ara_ID
where ara.id_ara=#id_ara# and ara_Pm.ara_id=#id_ara#
</cfquery>
<cfif PM_Tab.Recordcount EQ 0>
	<cfset totalAnticipated="0">
	<cfset percentAnticipated="0">
	<cfset amountTotal=0>
	<cfset startDate="">
	<cfset expirationDate="">
	<cfset FundsInAdvance="">
	<cfset ContractDefinization="">
	<cfset pertinentInformation="">
	<cfset workStarted="">
	<cfset Consequence="">
	<cfset currentStatus="">
    <cfset ES_Necessary="">
    <cfset Other_necessary="">
<cfelse>
	<cfset Totalanticipated=PM_Tab.totalAnticipated>
	<cfset percentAnticipated=PM_Tab.percentAnticipated>
	<cfset amountTotal=PM_Tab.amountTotal>
	<cfset startDate=Dateformat(PM_Tab.startDate,"MM/DD/YYYY")>
	<cfset ExpirationDate=Dateformat(PM_Tab.ExpirationDate,"MM/DD/YYYY")>
	<cfset FundsInAdvance=PM_Tab.fundsInAdvance>
	<cfset ContractDefinization=PM_Tab.contractDefinization>
	<cfset pertinentInformation=PM_tab.pertinentInformation>
	<cfset workStarted=PM_Tab.workStarted>
	<cfset Consequence=PM_tab.Consequence>
	<cfset currentStatus=PM_Tab.currentStatus>
    <cfset ES_Necessary=PM_Tab.ES_Necessary>
    <cfset Other_necessary=PM_Tab.Other_necessary>
</cfif>
	
	

