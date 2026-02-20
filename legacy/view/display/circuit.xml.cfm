<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>
<!--
	Example circuit.xml file for the display portion of an application.
-->
<circuit access="public">
	
	<!--
		Example display fuseaction. The output of the template is placed
		in a content variable which is used in the layout template.
	-->
	
	
	<fuseaction name="fake_Login">
		<include template="dsp_fake_Login" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="ckis_contracts">
		<include template="dsp_CKIS_contracts" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="test_page">
		<include template="dsp_test_page" contentvariable="body" />
	</fuseaction>
	<fuseaction name="supportRequest">
		<include template="dsp_supportRequest" contentvariable="body" />
	</fuseaction>
	<fuseaction name="test_flag">
		<include template="dsp_test_flag" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="home">
		<include template="dsp_home" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="dashboard">
		<include template="dsp_dashboard" contentvariable="body" />
	</fuseaction>
	<fuseaction name="AdminCleanOutOldAndExpired">
		<include template="dsp_AdminCleanOutOldAndExpired" contentvariable="body" />
	</fuseaction>
	<fuseaction name="negationList">
		<include template="dsp_negationList" contentvariable="body" />
	</fuseaction>
	<fuseaction name="negation">
		<include template="dsp_negate" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="ArchiveList">
		<include template="dsp_ArchiveList" contentvariable="body" />
	</fuseaction>
	
	
	<fuseaction name="reject">
		<include template="dsp_reject" contentvariable="body" />
	</fuseaction>
    
    <fuseaction name="negate">
		<include template="dsp_negate" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="insNewARA">
		<include template="dsp_ARASummary" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="CreateARAStep1">
		<include template="dsp_CreateARAStep1" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="ApprovalChain">
		<include template="dsp_ApprovalChain" contentvariable="body" />
	</fuseaction>
	<fuseaction name="ara_note">
		<include template="dsp_ara_note" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="getSGOD">
		<include template="dsp_getSGOD" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="modal_test">
		<include template="modal_test" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="ARASummary">
		<include template="dsp_ARASummary" contentvariable="body" />
	</fuseaction>

	<fuseaction name="CreateARAStep2">
		<include template="dsp_CreateARAStep2" contentvariable="body" />
	</fuseaction>

	<fuseaction name="EarlyStartARASumm">
		<include template="dsp_EarlyStartARASumm" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="ARADetail">
		<include template="dsp_ARADetail" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="ARA_PM">
		<include template="dsp_ARA_PM" contentvariable="body" />
	</fuseaction>
	
    <fuseaction name="logout">
		<include template="dsp_logout" contentvariable="body" />
	</fuseaction>
    
     <fuseaction name="login">
		<include template="dsp_login" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="ARA_ContractInfo">
		<include template="dsp_ARA_ContractInfo" contentvariable="body" />
	</fuseaction>
	
	
	<fuseaction name="ARA_Clins">
		<include template="dsp_ARA_Clins" contentvariable="body" />
	</fuseaction>
	
	
	<fuseaction name="ARA_Controller">
		<include template="dsp_ARA_Controller" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="ARA_ControllerV2">
		<include template="dsp_ARA_ControllerV2" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="auditTrail">
		<include template="dsp_auditTrail" contentvariable="body" />
	</fuseaction>
    
    <fuseaction name="AuditEmail">
		<include template="dsp_AuditEmail" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="userEmails">
		<include template="dsp_userEmails" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="ARA_Docs">
		<include template="dsp_ARA_Docs" contentvariable="body" />
	</fuseaction>
    
    <fuseaction name="ARA_Docs_include">
		<include template="dsp_ARA_Docs_mini" contentvariable="body" />
	</fuseaction>
    
    <fuseaction name="ARA_Docs_list">
		<include template="_doclist" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="ARA_CFDocument">
		<include template="dsp_ARA_CFDocument" contentvariable="body" />
	</fuseaction>
	<fuseaction name="ARA_Approvals">
		<include template="dsp_ARA_Approvals" contentvariable="body" />
	</fuseaction>
	<fuseaction name="Admin_Users">
		<include template="dsp_Admin_Users" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="admin_publist">
		<include template="dsp_Admin_publist" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="admin_archiveARA">
		<include template="dsp_admin_archiveARA" contentvariable="body" />
	</fuseaction>
    
    <fuseaction name="admin_PDFCleanup">
		<include template="dsp_admin_PDFCleanup" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="admin_rejectSummary">
		<include template="dsp_admin_RejectSummary" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="Admin_OrgChart">
		<include template="dsp_Admin_OrgChart" contentvariable="body" />
	</fuseaction>
	<fuseaction name="AdminDelegate">
		<include template="dsp_Admin_DelegateV3" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="Admin_Thresholds">
		<include template="dsp_admin_thresholds" contentvariable="body" />
	</fuseaction>
	<fuseaction name="Admin_ThresholdsV2">
		<include template="dsp_admin_thresholdsV2" contentvariable="body" />
	</fuseaction>
	
	
	<fuseaction name="AdminOrgStack">
		<include template="dsp_Admin_OrgStack" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="QuickSearch">
		<include template="dsp_QuickSearchResults" contentvariable="body" />
	</fuseaction>
    
    <fuseaction name="Search">
		<include template="dsp_search" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="SearchExport">
		<include template="dsp_searchExport" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="OrgChain">
		<include template="dsp_orgchain" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="Activity">
		<include template="dsp_admin_Activity" contentvariable="body" />
	</fuseaction>
	
	<fuseaction name="help">
		<include template="help/hlp_main" contentvariable="body" />
	</fuseaction>
    
    <fuseaction name="jamisExport">
		<include template="dsp_jamisExport" contentvariable="body" />
	</fuseaction>
    
    <fuseaction name="createjamisexport">
		<include template="dsp_createjamisexport" contentvariable="body" />
	</fuseaction>
	
	 <fuseaction name="CLINDateFix">
		<include template="dsp_CLINDateFix" contentvariable="body" />
	</fuseaction>
    
</circuit>
