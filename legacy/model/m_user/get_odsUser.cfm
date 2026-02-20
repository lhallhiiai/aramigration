
<!--- +++++++++++++++++ Get User Info From ODS +++++++++++ --->
	<cfquery name="ods_Users" datasource="#application.ods#" result="getUsers">
		SELECT
       '0000'+EMPL_ID AS [empl_nmbr]
       ,[USER_ID] AS [oprtr_id] 
       ,LAST_NAME AS[last_name]
       ,[MDL_INIT] AS[mddl_name]
       ,FIRST_NAME AS[first_name] 
       ,FIRST_NAME+' '+[MDL_INIT]+' '+LAST_NAME AS [full_name] 
       ,EMPL_TYPE AS[empl_type]
       ,LOCTN_CODE AS[lctn_code] 
       ,[JOB_CODE] AS[pstn_code] 
       ,TITLE AS [title] 
       ,'' AS[cost_cntr]
	   ,DIV_CODE as [DVSN]
       ,'0000'+MGR_ID AS [sprvsr_empl_nmbr] 
	   ,group_code as [grp]
	   ,SCTR_CODE as [sctr]
FROM PeopleSoft.Empl_ckis
Where TERM_DATE is NULL
AND TITLE IS NOT NULL
AND 
		USER_ID='#url.alion_user#'

	</cfquery>
	
	<cfset oprid=ods_Users.oprtr_id>
	<cfset first_name=ods_users.first_name>
	<cfset last_name=ods_users.last_name>
	<cfset emplid=ods_users.empl_nmbr>
	<cfset Title=ods_users.title>
	<cfset dvsn=ods_users.dvsn>
	<cfset grp=ods_users.grp>
	<cfset sctr=ods_users.sctr>
	<cfif ods_Users.cost_cntr EQ "">
		<cfset Cost_Center="Undefined">
	<cfelse>
		<cfset Cost_Center=ods_users.cost_cntr>
	</cfif>
	<cfset Empname=ods_users.full_name>
	<cfset subhdr="">
