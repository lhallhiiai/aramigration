<!--- Used to set up session variables for different users for test purposes --->
<cfif isDefined('ara_user_login')>
	<cfset oprid=GetToken(form.ara_user_login,2,'[')>
	<cfset oprid=GetToken(oprid,1,']')>	
</cfif>
<cfinclude template="../../model/m_user/get_users.cfm">

				<cfset session.approval_grp="">
				<cfset session.id_user="#gUsers.id_user#">
				<cfset session.oprid="#gUsers.oprid#">
				<cfset session.emplID="#gUsers.emplID#">
				<cfset session.sector=#gUsers.sctr#>
				<cfset session.group=#gUsers.grp#>
				<cfset session.oprtn=#gUsers.oprtn#>
				<cfset session.dvsn=#gUsers.dvsn#>
				<cfset session.ID_role="#gUsers.ID_role#">
				<cfset session.ID_job="#gUsers.ID_job#">
				<cfset session.approval_level="#gUsers.ID_job#">
				<cfset session.empName="#gUsers.empName#">
				<cfset session.jobtitle="#gUsers.title#">
				
				<!--- Who has delegated to me? I need to add their groups to my approval List --->
				<cfquery name="AmIDelegatee" datasource="#Application.DSN#">
					Select id_user,id_job
					FROM v_users
					where fk_DelegateTo_ID='#session.id_user#'
				</cfquery>
				<!--- Will use this throughout the app to determine who has delegated, and what I should approve --->
				<cfset session.delegators=ValueList(AmIDelegatee.id_user)>
				<cfset session.delegate_id_job=ValueList(AmIDelegatee.id_job)>
				<cfquery name="AppGrp" datasource="#Application.dsn#">
					Select approval_group 
					from approval_grp
					where id_user=#session.id_user#
					<cfif AmIDelegatee.recordcount GT 0>
					or id_user=#AmIDelegatee.id_user#
					</cfif>
					and inactive = 0
					order by approval_group
				</cfquery>
				<!---<cfdump var="#AppGrp#" format="text">--->
				<cfset session.approval_grp=valueList(appGrp.approval_group)><!--- NOT QuotedValueList, use list=true in CFQueryParam --->		
				<cfif session.id_job EQ 9><!--- If group manager append their home group --->
					<cfset session.approval_grp = ListAppend(session.approval_grp,session.group)>
				</cfif>		
				
				<cfset session.fakelogin="yes">
				<!--- cfdump var="#session#" format="text"><cfabort --->
			<cflocation url="index.cfm?fuseaction=app.home&Menu=home&fakelogin=Yes">