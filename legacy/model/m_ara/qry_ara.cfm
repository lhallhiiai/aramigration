<cfif isDefined('id_ara') and (id_ARA NEQ "")>
	<cfquery name="GetARA" datasource="#Application.dsn#">
		Select * from v_ara a, category c,  v_users u, status st, revenueDescr RD
		where a.id_cat=c.id_cat
		and a.id_user=u.id_user
		and a.id_status=st.id_status
		and a.id_revenue=RD.id_revenue
		and a.id_ara=#id_ara#
	</cfquery>
	
	<cfset id_cat=GetARA.id_cat>
	<cfset risklevel=Getara.risklevel>
	<cfset catName=GetARA.catName>
	<cfset revision=GetARA.revision>
	<!--- cfset currentcycle=val(revision+1) --->
	<cfset id_user=GetARA.id_user>
	<cfset first_name=GetARA.first_name>
	<cfset empname=GetARA.empname>
	<cfset last_name=GetARA.last_name>
	<cfset id_status=GetARA.id_status>
	<cfset statusName=GetARA.statusName>
	<cfset sector=GetARA.sector>
	<cfset group=GetARA.grp>
	<cfset op=GetARA.op>
	<cfset division=GetARA.division>
	<cfset org="<b>#Division#</b>">
	<cfset title=GetARA.title>
	<cfset customerName=GetARA.customerName>
	<cfset reference=GetARA.reference>
	<cfset revision=GetARA.revision>
	<cfset contractNo=GetARA.contractNo>
	<cfset doNo=GetARA.doNo>
	<cfset jamisNo=GetARA.jamisNo>
	<cfset OMSNum=GetARA.OMSNum>
    <cfset PMName=GetARA.PMName>
    <cfset ContractName=GetARA.ContractName>
    <cfset ControllerName=GetARA.ControllerName>
	
	<cfset contractType=GetARA.contractType>
	<cfset amountTotal=GetARA.amountTotal>
	<!--- cfset amountRequested=GetARA.amountRequested --->
	<cfset totalAnticipated=GetARA.totalAnticipated>
	<cfif GetARA.percentAnticipated EQ "">
		<cfset percentAnticipated=0>
	<cfelse>
		<cfset percentAnticipated=GetARA.percentAnticipated>
	</cfif>
	<cfset startDate=GetARA.startDate>
	<cfset expirationDate=GetARA.expirationDate>
	<cfset isEarlyStart=GetARA.isEarlyStart>
	<cfset RevDescr=GetARA.Descr>
	<cfset id_pm=GetARA.id_pm>
	<cfset id_contract=GetAra.id_contract>
	<cfset id_controller=GetAra.id_controller>
	<cfset id_OpsVP=GetAra.ID_OpsVP>
	<cfif len(trim(id_OpsVP)) GT 3>
	<cfquery name="getOpsVP" datasource="#application.dsn#">
		select empname from v_users where id_user=#id_OpsVP#
	</cfquery>
	<cfif getOpsVP.recordCount GT 0>
		<cfset OpsVP_nm=getOpsVP.empname>
	</cfif>
	<cfelse>
		<cfset OpsVP_nm="">
	</cfif>
	<cfquery name="getEac" datasource="#application.dsn#">
		select isEac from ARA where id_ara=#id_ara#
	</cfquery>
	<cfset isEac=GetEAC.isEac>
	
	<cfif GetARA.company EQ "">
		<cfset DefaultCompany="ALIN">
	<cfelse>
		<cfset DefaultCompany=GetARA.Company>
	</cfif>
	<cfset Company=GetARA.Company>
	
	<!--- Get PM ARA Information --->
	
	<cfquery name="GetPM" datasource="#Application.dsn#">
		Select * from ara_pm
		where ara_id=<cfqueryparam CFSQLType="CF_SQL_INTEGER" VALUE="#id_ara#">
	</cfquery>
    
    
	<cfif #getPM.recordcount# GT 0>
		<cfset ara_PM_ID=GetPM.ara_PM_ID>
		<cfset fundsInAdvance=GetPM.fundsInAdvance>
		<cfset contractDefinization=GetPM.contractDefinization>
		<cfset pertinentInformation=GetPM.pertinentInformation>
		<cfset workStarted=GetPM.workStarted>
		<cfset consequence=GetPM.consequence>
		<cfset currentStatus=GetPM.currentStatus>
        <cfset actiontoClear=GetPM.actiontoClear>
        <cfset changeInScope=GetPM.changeInScope>
	<cfelse><!--- PM information not completed, or under 50K --->
		<cfset ara_PM_ID="">
		<cfset fundsInAdvance="">
		<cfset contractDefinization="">
		<cfset pertinentInformation="">
		<cfset workStarted="">
		<cfset consequence="">
		<cfset currentStatus="">
        <cfset actiontoClear="">
        <cfset changeInScope="">
        
	</cfif>


</cfif>