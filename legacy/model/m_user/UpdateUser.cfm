<cfif inactive eq 0>
	<cfset status="Active">
<cfelse>
	<cfset status="Inactive">
</cfif>


<cfset timestamp='#dateformat(now(),"MM/DD/YY")# #timeformat(now(),"HH:MM")#'>
<!--- PM,Contracts,Controller,CCS, Delegatees are job ids we allow multiple of ---> 
<cfif NOT Find(Form.id_job,'1,2,3,13,21,22,23,28,29') AND Form.inactive EQ 'False'>

	<cfif isDefined('Id_user') and Id_user NEQ ""><!--- this is an update --->
		<!--- cfdump var="#form#" format="text" --->
		<!--- If changing Job, Group or Approve group will need to check to see if there
		      is already someone assigned to that group with same approval level --->
		<cfquery name="WhatChange" result="ThisChange" datasource="#application.dsn#">
			select oprid
			from v_users
			where id_job=#form.id_job#
			and inActive='False'
			and oprid <> '#Form.oprid#'
			and (Grp='#form.grp#'
			<cfif isDefined('') and #Form.Approve_grp# NEQ "">
			 OR 
			Approve_Grp='#form.Approve_Grp#'
			</cfif>
			or Approve_Grp='#form.grp#')
			and Grp <> 'CORP'
		</cfquery>
		<cfdump var="#WhatChange#" format="text">
	</cfif>
	<cfif WhatChange.recordcount GT 0>
	<!--- Make sure that for JobTitles above 3, that there are not duplicate
	      job titles for that organization. e.g., only 1 division manager per division --->
		<cfinclude template="CheckDupJob.cfm">
	</cfif>
</cfif>

<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />
	<cftry>

	<cfquery name="UpdateUser" result="Upd" datasource="#application.dsn#">
			Update  Users
			SET id_role=<cfqueryparam cfsqltype="cf_sql_integer" value="#id_role#">,
			id_job=<cfqueryparam cfsqltype="cf_sql_integer" value="#id_job#">,
			status=<cfqueryparam cfsqltype="cf_sql_varchar" value="#status#">,
			Inactive=<cfqueryparam cfsqltype="cf_sql_integer" value=#Inactive#>
			<cfif isDefined('Approve_Grp')>
			,Approve_grp=<cfqueryparam cfsqltype="cf_sql_varchar" value="#Approve_grp#">
			</cfif>
			,modified_by=<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">
			,modified_on=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Timestamp#">
			where ID_User=#ID_User#
	</cfquery>
    
    
    
    <!--- insert row for each approval group assigned --->
    
    <cfquery name="insertApprovalGrp" result="ThisChange" datasource="#application.dsn#">
        UPDATE
        	approval_grp
        Set inactive = 'True', 
        	modified_by = '#SESSION.id_user#', 
            modified_on =<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Timestamp#">            
        WHERE ID_User=#ID_User#
    </cfquery>
    <cfif isdefined("form.Approve_grp") and form.Approve_grp NEQ 0>
    <cfloop index="i" list="#form.Approve_grp#" delimiters=",">    
    <cfquery name="insertApprovalGrp" result="ThisChange" datasource="#application.dsn#">
        INSERT into	
        	approval_grp (id_user, approval_group, created_by, created_on, id_role, id_job)
        values 
        	('#form.ID_USER#', '#i#', '#SESSION.id_user#', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Timestamp#">, '#id_role#', '#id_job#')
    </cfquery>
	</cfloop>
    <cfelseif isdefined("form.Approve_grp") and form.Approve_grp EQ 0>
    <cfquery name="ClearApprovalGrp" result="ThisChange" datasource="#application.dsn#">
        Delete from 
        	approval_grp where id_user ='#form.ID_USER#'
    </cfquery>
 	</cfif>
	
	<!--- @Comment: Catch DBMS Issues, if True ROLLBACK else COMMIT --->
		<cfcatch type="database">
			<cfset committed = "No" />
			<cftransaction action = "rollback" />
			<cfset errorMsg="Unable to update user. <br>Details: #cfcatch.detail# <br>SQL: #cfcatch.sql#">
		</cfcatch>

	</cftry>

	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			<!--- cfinclude template="get_users.cfm">
			<cfinclude template="../m_emails/mail_UserAccount.cfm" --->
			<cfset confirmMsg="#empname# successfully Updated.">
   	</cfif>
</cftransaction>



<cfif isDefined('form.approvalform') and (form.approvalform NEQ "")>
	<cfset Action="Update"><cfset fileAction="Upload">
	<cfinclude template="act_UploadAccessRequest.cfm">
</cfif>
<cfset userID=#ID_user#>
<cfif committed EQ "Yes">
	<cfinclude template="get_users.cfm">
	<cfinclude template="../m_emails/mail_UserAccount.cfm">
	<cflocation url="#self#?fuseaction=app.admin_users&Action=Lookup&alion_user=#Form.oprid#&ConfirmMsg=#ConfirmMsg#&userID=#userID#" addtoken="No">
<cfelse>
	<cflocation url="#self#?fuseaction=app.admin_users&Action=Lookup&alion_user=#Form.oprid#&ErrorMsg=#ErrorMsg#&Userid=#userid#" addtoken="No">
</cfif>