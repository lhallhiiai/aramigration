<cfparam name="userid" default="">
<cfparam name="errorMsg" default="">
<cfparam name="confirmMsg" default=""><cfparam name="committed" default="">
<cfset timestamp='#dateformat(now(),"MM/DD/YY")# #timeformat(now(),"HH:MM")#'>
<cfif inactive eq 0>
	<cfset status="Active">
<cfelse>
	<cfset status="Inactive">
</cfif>
<!---<cfinclude template="act_UploadAccessRequest.cfm">--->
<!--- Check for duplicates --->
<!--- cfquery name="checkDup" datasource="#Application.dsn#">
	Select * from users, role
	where users.oprid='#oprid#'
	and users.ID_role=Role.id_role
</cfquery --->


<cfif NOT Find(Form.id_job,'1,2,3,13,21,22,23,28,29')><!--- PM,Contracts,Controller,CCS, Delegatees we allow multiple of ---> 
	<!--- Make sure that for JobTitles above 3, that there are not duplicate
	      job titles for that organization. e.g., only 1 division manager per division --->
		<cfinclude template="CheckDupJob.cfm">
</cfif>

<cftransaction action="begin">
	<!--- @Comment: Start Transaction (TRY) --->
	<cfset committed = "Yes" />

<cfquery name="getnewID" datasource="#Application.dsn#">
		Select Max(id_user) as newID1 From Users
	</cfquery>


	<cfquery name="newUser" datasource="#application.dsn#">
		INSERT INTO USERS
			(emplID,
			oprid,
			ID_role,
			ID_job,
			first_name,
			last_name,
			empname,
			costcenter,
			Status,
			Inactive
			
			<cfif isDefined('Approve_grp')>
				,Approve_grp
			</cfif>
			,created_by
			,created_on
			,email
			)
		VALUES
			('#emplID#',
			'#oprid#',
			#id_role#,
			#id_job#,
			'#first_name#',
			'#last_name#',
			'#empname#',
			'#costcenter#',
			'#status#',
			'#Inactive#'
			<cfif isDefined('Approve_grp')>
				,'#Approve_grp#'
			</cfif>
			,#session.id_user#
			,'#timestamp#'
			,'#email_addr#'
			)
			
	</cfquery>

	<cfquery name="getID" datasource="#Application.dsn#">
		Select Max(id_user) as newID From Users
	</cfquery>

	<cfset userID = #getID.newID#>
    <cfif isdefined("form.Approve_grp") and form.Approve_grp EQ 0>
    <cfquery name="ClearApprovalGrp" result="ThisChange" datasource="#application.dsn#">
        Delete from 
        	approval_grp where id_user ='#userID#' 
    </cfquery>
    <cfelseif isdefined("form.Approve_grp") and form.Approve_grp NEQ 0>
    <cfloop index="i" list="#form.Approve_grp#" delimiters=",">
    <cfquery name="insertApprovalGrp" result="ThisChange" datasource="#application.dsn#">
        INSERT into	
        	approval_grp (id_user, approval_group, created_by, created_on, id_role, id_job)
        values 
        	('#userID#', '#i#', '#SESSION.id_user#', <cfqueryparam cfsqltype="cf_sql_timestamp" value="#Timestamp#">, #id_role#, #id_job#)
    </cfquery>
	</cfloop>	
    </cfif>
    
	

	<!--- @Comment: Check for Commit --->
	<cfif committed EQ "Yes">
    		<cftransaction action="commit" />
			<cfset id_user=userID>
			<cfset confirmMsg="#first_name# #last_name# successfully added to ARA.">
   	</cfif>
	
	<!--- Upload User Access Form and Save to database --->
	<cfset fileAction="upload"><cfset action="Add">
	<cfinclude template="act_UploadAccessRequest.cfm">
</cftransaction>





<cfif committed EQ "Yes">
	<cfinclude template="get_users.cfm">
	<cfinclude template="../m_emails/mail_UserAccount.cfm">
	<cflocation url="#self#?fuseaction=app.admin_users&Action=Lookup&alion_user=#Form.oprid#&ConfirmMsg=#ConfirmMsg#&userID=#userID#" addtoken="No">
<cfelse>
	<cflocation url="#self#?fuseaction=app.admin_users&Action=Lookup&alion_user=#Form.oprid#&ErrorMsg=#ErrorMsg#&Userid=#userid#" addtoken="No">
</cfif>