<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>
<!--
	Example circuit.xml file for the controller portion of an application.
	Only the controller circuit has public access - the controller circuit
	contains all of the fuseactions that are used in links and form posts
	within your application.
-->


<circuit access="public" xmlns:cf="cf/">

	<!--
		Apply a standard layout to the result of every request.
		This is fine for simple applications that have just one layout but
		for more complicated situations you will need to do something more
		advanced.
	-->
	<postfuseaction>
		<do action="layout.chooseLayout" />
	</postfuseaction>

	<!--
		Default fuseaction for application, uses model and view circuits
		to do all of its work:
	-->
	<fuseaction name="welcome">
		<do action="time.getTime" />
		<do action="display.sayHello" />
	</fuseaction>
	
	<fuseaction name="logout">
		<do action="display.logout" />
	</fuseaction>
	
	<fuseaction name="ckis_contracts">
		<do action="display.ckis_contracts" />
	</fuseaction>
	<fuseaction name="fake_Login">
		<do action="display.Fake_login" />
	</fuseaction>
	
	<fuseaction name="test_flag">
		<do action="display.test_flag" />
	</fuseaction>
	<fuseaction name="test_page">
		<do action="display.test_page" />
	</fuseaction>
	<fuseaction name="modal_test">
		<do action="display.modal_test" />
	</fuseaction>
	
    <fuseaction name="admin_PDFCleanup">
		<do action="display.admin_PDFCleanup" />
	</fuseaction>
    
    <fuseaction name="admin_archiveARA">
		<do action="display.admin_archiveARA" />
	</fuseaction>  
	<fuseaction name="admin_RejectSummary">
		<do action="display.admin_RejectSummary" />
	</fuseaction> 

	<fuseaction name="NegationList">
		<do action="display.NegationList" />
	</fuseaction>
	
	
	<fuseaction name="supportRequest">
		<do action="display.supportRequest" />
	</fuseaction>
	
	<fuseaction name="ARASummary">
		<do action="time.getTime" />
		<do action="display.ARASummary" />
	</fuseaction>
	
	<fuseaction name="ArchiveList">
		<do action="display.ArchiveList" />
	</fuseaction>
	
	<fuseaction name="ClinEarlyStartComplete">
		<do action="m_forms.ClinEarlyStartComplete" />
	</fuseaction>

	<fuseaction name="CreateARAStep1">
		<do action="time.getTime" />
		<do action="display.CreateARAStep1" />
	</fuseaction>

	<fuseaction name="CreateARAStep2">
		<do action="time.getTime" />
		<!-- do action="m_forms.prePop" / -->
		<do action="display.CreateARAStep2" />
	</fuseaction>

	<fuseaction name="insNewARA">
		<do action="m_forms.insNewARA" />
	</fuseaction>

	<fuseaction name="PM_Submit">
		<do action="m_forms.PM_Submit" />
	</fuseaction>

	<fuseaction name="PM_Cancel">
		<do action="m_forms.PM_Cancel" />
	</fuseaction>
	<fuseaction name="CM_Submit">
		<do action="m_forms.CM_Submit" />
	</fuseaction>

	<fuseaction name="Clin_Submit">
		<do action="m_forms.Clin_Submit" />
	</fuseaction>
	<fuseaction name="Clin_Update">
		<do action="m_forms.Clin_Update" />
	</fuseaction>
	<fuseaction name="Clin_Delete">
		<do action="m_forms.Clin_Delete" />
	</fuseaction>
	
	<fuseaction name="Con_insert">
		<do action="m_forms.Con_insert" />
	</fuseaction>
	<fuseaction name="Con_update">
		<do action="m_forms.Con_update" />
	</fuseaction>
	<fuseaction name="Con_submit">
		<do action="m_forms.Con_submit" />
	</fuseaction>

	<fuseaction name="approve">
		<do action="m_forms.approve" />
	</fuseaction>
    
    <fuseaction name="searchARA">
		<do action="display.search" />
	</fuseaction>
	
	<fuseaction name="searchExportARA">
		<do action="display.searchExport" />
	</fuseaction>
	
	<fuseaction name="MailDist">
		<set name="s" value="true" />
		<do action="emails.MailDist" />
	</fuseaction>
	
	<fuseaction name="Publist">
		<do action="emails.Publist" />
		<do action="display.admin_publist" />
	</fuseaction>

	<fuseaction name="EarlyStartARASumm">
		<do action="time.getTime" />
		<do action="display.EarlyStartARASumm" />
	</fuseaction>
	
	<fuseaction name="dashboard">
		<do action="time.getTime" />
		<do action="display.Dashboard" />
	</fuseaction>
	
	<fuseaction name="activity">
		<do action="time.getTime" />
		<do action="display.Activity" />
	</fuseaction>
	
    <fuseaction name="login">
    	<set name="s" value="true" />
		<do action="display.login" />
	</fuseaction>
    
	<fuseaction name="ARA_PM">
		<do action="time.getTime" />
		<!-- do action="m_ara.internalDetails" / -->
		<!-- do action="m_ara.externalDetails" / -->
		<do action="display.ARA_PM" />
	</fuseaction>
	

	<fuseaction name="ARA_ContractInfo">
		<do action="time.getTime" />
		<!-- do action="m_ara.internalDetails" />
		<do action="m_ara.externalDetails" / -->
		<do action="display.ARA_ContractInfo" />
	</fuseaction>

	
	<fuseaction name="ARA_Clins">
		<do action="time.getTime" />
		<!-- do action="m_ara.internalDetails" />
		<do action="m_ara.externalDetails" / -->
		<do action="m_forms.clin_prePop" />
		<do action="display.ARA_Clins" />
	</fuseaction>
	
	<fuseaction name="ARA_ControllerV2">
		<do action="time.getTime" />
		<!-- do action="m_ara.internalDetails" />
		<do action="m_ara.externalDetails" / -->
		<do action="display.ARA_ControllerV2" />
	</fuseaction>
	
	

	<fuseaction name="ARA_Controller">
		<do action="time.getTime" />
		<!-- do action="m_ara.internalDetails" />
		<do action="m_ara.externalDetails" / -->
		<do action="display.ARA_Controller" />
	</fuseaction>
	
	<fuseaction name="PMCMCon_update"><!-- Add contract Manager or Controller to ARA -->
		<do action="m_forms.PMCMCon_update" />
	</fuseaction>
	

	<fuseaction name="ARA_Docs">
		<do action="time.getTime" />
		<!-- do action="m_ara.internalDetails" />
		<do action="m_ara.externalDetails" / -->
		<do action="display.ARA_Docs" />
	</fuseaction>
    
    <fuseaction name="ARA_Docs_include">
    	<set name="s" value="true" />
		<do action="time.getTime" />
		<!-- do action="m_ara.internalDetails" />
		<do action="m_ara.externalDetails" / -->
		<do action="display.ARA_Docs_include" />
	</fuseaction>
    
    <fuseaction name="ARA_Docs_list">
    	<set name="s" value="true" />
		<do action="time.getTime" />
		<!-- do action="m_ara.internalDetails" />
		<do action="m_ara.externalDetails" / -->
		<do action="display.ARA_Docs_list" />
	</fuseaction>
	
	<fuseaction name="ARA_CFDocument">
		<do action="time.getTime" />
		<!-- do action="m_ara.internalDetails" />
		<do action="m_ara.externalDetails" / -->
		<do action="display.ARA_CFDocument" />
	</fuseaction>

	<fuseaction name="ARA_Approvals">
		<do action="time.getTime" />
		<!-- do action="m_ara.internalDetails" />
		<do action="m_ara.externalDetails" / -->
		
		<do action="display.ARA_Approvals" />
	</fuseaction>

	<fuseaction name="ARADetail">
		<do action="time.getTime" />
		<!-- do action="m_ara.internalDetails" />
		<do action="m_ara.externalDetails" / -->
		<do action="display.ARADetail" />
	</fuseaction>
	
	<fuseaction name="ara_note">
		<do action="display.ara_note" />
	</fuseaction>
     
	 <fuseaction name="DeleteEntireARA">
		<do action="m_ara.DeleteEntireARA" />
	</fuseaction>

	<fuseaction name="home">
		<do action="time.getTime" />
		<do action="display.home" />
	</fuseaction>
	
    <fuseaction name="reject">
		<do action="m_forms.reject" />
	</fuseaction>
	
	<fuseaction name="rejectForm">
		<set name="s" value="true" />
		<do action="display.reject" />
	</fuseaction>
    
    <fuseaction name="negation">
		
		<do action="display.negate" />
	</fuseaction>
	
	<fuseaction name="delegatees">
		<set name="s" value="true" />
		<do action="script.delegatees" />
	</fuseaction>
    
    <fuseaction name="AdminCancel">
		<do action="m_forms.AdminCancel" />
	</fuseaction>
	<fuseaction name="AdminCleanOutOldAndExpired">
		<do action="display.AdminCleanOutOldAndExpired" />
	</fuseaction>
    
	<fuseaction name="Admin_Users">
		<do action="users.get_Roles" />
		<do action="display.Admin_Users" />
	</fuseaction>
    
    <fuseaction name="JamisExport">
		<do action="users.get_Roles" />
		<do action="users.get_users" />
		<do action="display.JamisExport" />
	</fuseaction>
    
    <fuseaction name="createjamisexport">
		<do action="users.get_Roles" />
		<do action="users.get_users" />
		<do action="display.createjamisexport" />
	</fuseaction>
    
    
	<fuseaction name="Admin_InsNewUser">
		<do action="users.InsNewUser" />
	</fuseaction>
	
	<fuseaction name="Admin_OrgChart">
		<do action="display.Admin_OrgChart" />
	</fuseaction>
	<fuseaction name="Admin_UpdateUser">
		<do action="users.UpdateUser" />
	</fuseaction>
	<fuseaction name="Admin_DeleteUser">
		<do action="users.DeleteUser" />
	</fuseaction>

	<fuseaction name="AdminDelegate">
		<do action="users.get_Roles" />
		<do action="users.get_users" />
		<do action="display.AdminDelegate" />
	</fuseaction>
	
	<fuseaction name="Admin_thresholds">
		<do action="display.admin_thresholds" />
	</fuseaction>
	<fuseaction name="Admin_thresholdsV2">
		<do action="display.admin_thresholdsV2" />
	</fuseaction>
	<fuseaction name="Admin_InsertThreshold">
		<do action="m_ara.admin_InsertThreshold" />
	</fuseaction>
	<fuseaction name="Admin_UpdateThreshold">
		<do action="m_ara.admin_UpdateThreshold" />
	</fuseaction>
	
	<fuseaction name="Admin_DeleteThreshold">
		<do action="m_ara.admin_DeleteThreshold" />
	</fuseaction>

	<fuseaction name="getUserInfo">
		<set name="s" value="true" />
		<do action="users.userinfo" />
	</fuseaction>
	
	<fuseaction name="AdminOrgstack">
		<do action="display.AdminOrgStack" />
	</fuseaction>
    
    <fuseaction name="AuditTrail">
		<do action="display.auditTrail" />
	</fuseaction>
	
	<fuseaction name="UserEmails">
		<do action="display.userEmails" />
	</fuseaction>
    
     <fuseaction name="AuditEmail">
		<do action="display.AuditEmail" />
	</fuseaction>
	
	<fuseaction name="QuickSearch">
		<do action="display.QuickSearch" />
	</fuseaction>
	<fuseaction name="ApprovalChain">
		<do action="display.ApprovalChain" />
	</fuseaction>
	
	<fuseaction name="checkID">
		<do action="users.checkID" />
	</fuseaction>
	
	<fuseaction name="getSGOD">
		<do action="display.getSGOD" />
	</fuseaction>

	<fuseaction name="usersAutoComplete">
		<set name="s" value="true" />
		<do action="script.users" />
	</fuseaction>
	
	<fuseaction name="ARAusersAutoComplete">
		<set name="s" value="true" />
		<do action="script.ARAusers" />
	</fuseaction>
	
	<fuseaction name="ARAusersShort">
		<set name="s" value="true" />
		<do action="script.ARAusersShort" />
	</fuseaction>
	
	<fuseaction name="OrgAutoComplete">
		<set name="s" value="true" />
		<do action="script.Org" />
	</fuseaction>
    
	<fuseaction name="omsAutoComplete">
		<set name="s" value="true" />
		<do action="script.oms" />
	</fuseaction>
    
    <fuseaction name="eacAutoComplete">
		<set name="s" value="true" />
		<do action="script.eac" />
	</fuseaction>
	
	<fuseaction name="ClinNumAutoComplete">
		<set name="s" value="true" />
		<do action="script.ClinNum" />
	</fuseaction>
    
    <fuseaction name="SearchUserAutoComplete">
		<set name="s" value="true" />
		<do action="script.ARAUser" />
	</fuseaction>
	
	<fuseaction name="JamisNoAutoComplete">
		<set name="s" value="true" />
		<do action="script.JamisNo" />
	</fuseaction>
	
	<fuseaction name="getFile">
		<do action="m_forms.getFile" />
	</fuseaction>
	<fuseaction name="getDoc">
		<do action="m_forms.getDoc" />
	</fuseaction>
	
	<fuseaction name="Help">
		<do action="display.help" />
	</fuseaction>
	
	<fuseaction name="CLINDateFix">
		<do action="display.CLINDateFix" />
	</fuseaction>
</circuit>
