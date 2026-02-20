<cfif isDefined('id_ara')>
	<cfquery name="GetController" datasource="#Application.dsn#">
		Select * from ARA_con
		where id_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#id_ara#">
	</cfquery>
	
	<cfset id_ara_con=GetController.id_ara_con>
	<cfset id_user=GetController.id_user>
	<cfset interestImpact=GetController.interestImpact>
	<cfset burnRate=GetController.burnRate>
	<cfset cost=GetController.cost>
	<cfset fee=GetController.fee>
	<cfset priorCost=GetController.priorCost>
	<cfset priorFee=GetController.priorFee>
	<cfset icCost=GetController.icCost>
	<cfset icFee=GetController.icFee>
	<cfset revenue=GetController.revenue>
	<cfset conDate=GetController.conDate>
</cfif>