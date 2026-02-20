<!--- If controller record exists, need to update controller total_cost and total fee --->
<cfinclude template="../m_ara/qry_ClinCostFeeTotals.cfm">
<cfoutput>
<!---
********************sumcost ***************************<br><br>
<cfdump var="#sumcost#" format="text">
********************sumFee ***************************<br><br>
<cfdump var="#sumfee#" format="text">

--->

<cfquery name="UpdTotals" datasource="#Application.dsn#">
	Update ARA_Con
	Set total_cost=<cfqueryparam cfsqltype="cf_sql_float" value="#total_Cost#">,
	total_fee=<cfqueryparam cfsqltype="cf_sql_float" value="#total_Fee#">
	where id_ara=#id_ara#
</cfquery>

</cfoutput>
