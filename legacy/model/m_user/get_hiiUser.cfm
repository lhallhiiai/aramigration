
<!--- +++++++++++++++++ Get User Info From ODS +++++++++++ --->
<cfquery name="ods_users" datasource="#application.ods#" result="getUsers">
	SELECT  *  
	FROM    HRIS_EMPL 
	where FIVE_N_TWO ='#form.alion_user#'		
		Order by FIVE_N_TWO
</cfquery>
	<cfset namelist= valuelist(ods_users.LAST_FIRST_NAME)>
	<cfset oprid=ods_users.FIVE_N_TWO>
	<cfset first_name=listgetat(namelist,2)>
	<cfset last_name= listgetat(namelist,1)>
	<cfset emplid=ods_users.EMPL_ID>
	<cfset email_addr=ods_users.email_addr>
	<cfset Title="">
	<cfset dvsn="">
	<cfset grp="ods_users.grp">
	<cfset sctr="ods_users.org">
	<cfset Cost_Center="Undefined">
	<cfset Empname=ods_users.LAST_FIRST_NAME>
	<cfset subhdr="">
