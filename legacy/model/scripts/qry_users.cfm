<!--- Used for autocomplete select list  on dsp_admin_users --->


<cfsetting enablecfoutputonly="true">
<cfparam name="q" default="" />


<!---<cfquery name="gUsers" datasource="#application.ods#" result="getUsers">
	SELECT  empl_ckis.cost_cntr, org_ckis.cost_center, empl_ckis.first_name, empl_ckis.last_name, 
		    org_ckis.sctr, org_ckis.grp, org_ckis.oprtn, org_ckis.dvsn, org_ckis.org_desc, empl_ckis.oprtr_id
	FROM    empl_ckis INNER JOIN org_ckis ON empl_ckis.cost_cntr = org_ckis.cost_center
	
	and 
		(
			empl_ckis.first_name LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
			OR empl_ckis.last_name  LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
			OR empl_ckis.oprtr_id LIKE  <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
			OR org_ckis.sctr LIKE  <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
		)
		Order by empl_ckis.Last_name
</cfquery>--->

<cfquery name="gUsers" datasource="#application.ods#">
	SELECT  * 
	FROM    HRIS_EMPL 
	where 
		(
			LAST_FIRST_NAME LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
			OR FIVE_N_TWO LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
			OR EMAIL_ADDR LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
		)
		Order by FIVE_N_TWO
</cfquery>



<cfoutput query="gUsers">
	<!--- #last_name#, #first_name# (#UCASE(sctr)#, #Ucase(grp)#) [#oprtr_id#]#chr(10)# (#UCASE(org)#, #Ucase(grp)#) [#FIVE_N_TWO#]#--->
	#FIVE_N_TWO# (#UCASE(org)#, #Ucase(grp)#) [#FIVE_N_TWO#] #chr(10)#
</cfoutput>

