<!--- Totals Up CLIN amounts for controller summary --->
<cfif isDefined('ARAClinCnt') AND (ARAClinCnt GT 0)>
	<cfquery name="SumCost" datasource="#Application.dsn#">
		SELECT SUM(costFunding) as CostSubtotal FROM CLINs
		where id_ara =  <cfqueryparam cfsqltype="cf_sql_integer" value="#id_ara#">
	</cfquery>
	<cfset Total_cost=SumCost.CostSubtotal>
	<cfset Total_Cost_dsp=NumberFormat(total_cost,"9,999.99")>
	
	<cfquery name="SumFee" datasource="#Application.dsn#">
		SELECT SUM(FeeFunding) as FeeSubtotal FROM CLINs
		where id_ara =  <cfqueryparam cfsqltype="cf_sql_integer" value="#id_ara#">
	</cfquery>
	<cfset Total_Fee=SumFee.FeeSubtotal>
	<cfset Total_Fee_dsp=NumberFormat(total_fee,"9,999.99")>
	
	<cfset Total_Value=val(SumCost.CostSubtotal+SumFee.FeeSubtotal)>
	<cfset Total_Value_dsp=NumberFormat(Total_Value,"9,999.99")>
<cfelse><!--- No Clins Yet --->
	<cfset Total_cost=0>
	<cfset Total_Cost_dsp=0>
	<cfset Total_Fee=0>
	<cfset Total_Fee_dsp=0>
	
	<cfset Total_Value=0>
	<cfset Total_Value_dsp=0>
</cfif>