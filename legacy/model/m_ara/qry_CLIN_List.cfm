<cffunction name="getClin">
	<cfargument name="ara" required="No">
	<cfargument name="clin" required="No">
	<cfif isDefined('ara') or isDefined('clin')>
		<!---   Pull the list of CLINS for an ARA --->
		<cfquery name="clins" datasource="#Application.dsn#">
			SELECT  ara.id_ara, clins.clinNo, clins.id_clins, clins.description, clins.expirationDate, 
					clins.revisionAmt, clins.costFunding, clins.feeFunding, 
					clins.total, ara.reference, ara.title
					
			FROM     ara INNER JOIN
			         clins ON ara.id_ara = clins.id_ara
					 where 1=1
			<cfif isDefined('ara')>
				and ara.id_ara=#ara#	
			</cfif>
			<cfif isDefined('clin')>
				and clins.id_clins=#clin#
			</cfif>
			ORDER BY ClinNo
		</cfquery>
		
		<cfif Clins.Recordcount EQ 1><!--- single clin to initialize --->
			<cfset ClinNo=clins.ClinNo>
			<cfset ClinDesc=clins.Description>
			<cfset ClinExp=#dateformat(clins.ExpirationDate,"MM/DD/YY")#>
			<!--- Commas are screwing up Javascript --------------- cfset CostFunding=numberformat(clins.CostFunding,"9,999.99")>
			<cfset FeeFunding=numberformat(clins.FeeFunding,"9,999.99")>
			<cfset ARATotal=numberformat(clins.Total,"9,999.99") --->
			<cfset CostFunding=numberformat(clins.CostFunding,"9999.99")>
			<cfset FeeFunding=numberformat(clins.FeeFunding,"9999.99")>
			<cfset ARATotal=numberformat(clins.Total,"9999.99")>
		</cfif>
<cfelse><!---There is no ara or clin number, initialize vars --->
	<cfset ClinNo="">
	<cfset ClinDesc="">
	<cfset ClinExp="">
	<cfset CostFunding="">
	<cfset FeeFunding="">
	<cfset ARATotal="">
</cfif>
</cffunction>