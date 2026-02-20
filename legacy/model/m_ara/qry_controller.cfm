<cfif isDefined('url.AID')>
	<cfset id_ara=#decrypt(url.AID,request.encryptKey,request.encryptType,'hex')#>
</cfif>
<cfif isDefined('id_ara')>
	<cfquery name="GetController" datasource="#Application.dsn#">
		Select * from ARA_con
		where id_ara=#id_ara#
	</cfquery>
	<cfif GetController.Recordcount GT 0>
		<cfset id_ara=GetController.id_ara>
		<cfset id_ara_con=GetController.id_ara_con>
		<cfset id_user=GetController.id_user>
		<cfset interestImpact=GetController.interestImpact>
		<cfset burnRate=GetController.burnRate>
		<cfset total_cost=GetController.Total_cost>
		
		<cfset total_fee=GetController.Total_fee>
		<cfset Total_value=val(total_cost+total_fee)>
	
		<cfset icCost=GetController.icCost>
		<cfif icCost NEQ "">
			<cfset Incurred_Value=Iccost>
		<cfelse>
			<cfset Incurred_Value=0>
		</cfif>
		<cfset icFee=GetController.icFee>
		<cfif icFee NEQ "">
			<cfset Incurred_Value=val(Incurred_Value+icFee)>
		</cfif>
		
		<!--- see if submitted for approval, and if so get date --->
		<cfquery name="con_app" datasource="#Application.dsn#">
			Select approvalDate from
			araAppLog
			where id_ara=#id_ara#
			and id_status=6
		</cfquery>
		<cfif con_app.recordcount GT 0>
			<cfset conDate=Dateformat(con_app.approvalDate,"MM/DD/YY")>
		<cfelse>
			<cfset conDate="">
		</cfif>
	<cfelse>
		<cfset id_user=session.id_user>
		<cfset interestImpact="">
		<cfset burnRate="">
		<cfset Total_cost="">
		<cfset Total_fee="">
		<cfset Total_auth="">
		<cfset icCost="">
		<cfset icFee="">
	</cfif>
</cfif>