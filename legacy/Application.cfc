<cfcomponent extends="fusebox5.Application" output="false">

<!--- Application.TestFlag: When set to "Yes", can use fakelogin to test in production.
      Otherwise fakelogin is disallowed in production. --->

<cfset application.TestFlag = "No">
<!---
		sample Application.cfc for ColdFusion MX 7 and later compatible systems
	--->

<!--- set Unique application name based on the directory path and added timestamp  --->
<cfset ts="#Dateformat(Now(),'MMDD')#">
<cfset this.name = right(REReplace(getDirectoryFromPath(getCurrentTemplatePath()),'[^A-Za-z]','','all'),64) />
<cfset this.name="#this.name#" & "#ts#">
<cfset this.sessionManagement = true>
<cfset this.sessionTimeout = createTimeSpan(0,1,0,0) >
<!--- enable debugging --->
<cfset FUSEBOX_PARAMETERS.debug = false />
<cfset FUSEBOX_PARAMETERS.password = "4r4PWD" />

<!--- force the directory in which we start to ensure CFC initialization works: --->
<cfset FUSEBOX_CALLER_PATH = getDirectoryFromPath(getCurrentTemplatePath()) />

<!---
		if you define any onXxxYyy() handler methods, remember to start by calling
			super.onXxxYyy(argumentCollection=arguments)
		so that Fusebox's own methods are executed before yours
	--->

<cffunction name="OnRequestStart">
  <cfargument name="targetPage" /> 
  <cfset basePath=cgi.script_name>
  <cfloop list="#basePath#" delimiters="/" index="ii">
    <cfset request.homeDir = ii>
    <cfbreak />
  </cfloop>
  <!--- cfif isDefined('session')>
	<cfdump var="#session#" format="text">
	</cfif --->
 
  <!--- Application database based on path --->
  <cfif FINDNOCASE('agwalajeras01',CGI.HTTP_HOST) GT 0>
    <cfset application.production="Yes">
    <cfset application.dsn="araTSD">
    <cfset application.ajes="ajesTSD">
    <cfset application.PDFDir="C:\websites\ara\temp">
    <cfset application.PDFDirDel="C:\websites\ara\temp">
  <cfelse>
    <cfset application.production="No">
    <cfset application.dsn="araTSD">
    <cfset application.ajes="ajesTSD">
    <cfset application.PDFDir="C:\websites\ara\temp">
    <cfset application.PDFDirDel="C:\websites\ara\temp">
  </cfif>

  <cfset application.ods="cae_ods">
  <!--- cfset application.jc="jobcost" ---><!--- all references to jobcost should not point to cae_ods_jobcost --->
  <cfset application.oms="oms20">
  <cfset request.encryptkey="0330198118910330">
  <cfset request.encryptType="BLOWFISH">
  <!--- cflogin ---><!--- cflogin variable exists only if login credentials are available. --->
  <!--- cfif NOT IsDefined("cflogin") AND NOT IsDefined("FORM.strUsername") --->
  
  <CFIF isDefined('Form.strUsername')>
    <!--- cfset pass = decrypt(FORM.strPassword,request.encryptkey,request.encrypttype,"hex") --->

<cfobject type="java" class="SamplePass" name="x">
	<!---<cfdump var="#x#">--->
	<cfset authresult= "#x.doadauthentication(FORM.strUsername,FORM.strPassword)#">
<!---<cfoutput>authresult is #authresult#</cfoutput>
		<cfabort>--->
	
    <cfquery name="loginCheck" datasource="#Application.dsn#">
         select *
           from users
           where oprid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.strUsername#">
       </cfquery>
 
	 
     <cfif loginCheck.recordcount eq 0  AND authresult EQ "SUCCEED">
        <!--- if it's not in user table, grant PM access --->        
        <cfquery name="ods_Users" datasource="#application.ods#" result="getUsers">
            SELECT 
			EMPL_ID as [empl_nmbr], 
			LAST_FIRST_NAME as [full_name], 
			FIVE_N_TWO as [oprtr_id], 
			EMAIL_ADDR,
			ORG as[sctr], L3_REORG_NAME, 
			GRP as [grp], 
			MGR_EMPL_ID AS [sprvsr_empl_nmbr], 
			MGR_NAME			
			FROM HRIS_EMPL
			WHERE FIVE_N_TWO='#FORM.strUsername#' 
			
			
			<!--- Original query for ALION users
			SELECT
           '6'+EMPL_ID AS [empl_nmbr]
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
            <!---AND TITLE IS NOT NULL--->
            AND USER_ID='#FORM.strUsername#'  --->
			
        </cfquery>
		
		
        <cfset oprid=ods_Users.oprtr_id>
        <cfset first_name=listgetat(ods_users.full_name,2)>
        <cfset last_name=listgetat(ods_users.full_name,1)>
        <cfset emplid=ods_users.empl_nmbr>
        <cfset Title="">
        <cfset dvsn="">
		<cfset EMAIL_ADDR=ods_Users.EMAIL_ADDR>		
        <cfset grp=ods_users.grp>
        <cfset sctr=ods_users.sctr>
		<cfset Cost_Center="Undefined">
        <!---<cfif ods_Users.cost_cntr EQ "">
          <cfset Cost_Center="Undefined">
          <cfelse>
          <cfset Cost_Center=ods_users.cost_cntr>
        </cfif>--->
        <cfset Empname=ods_users.full_name>
        <cfset subhdr="">
        <cfset timestamp='#dateformat(now(),"MM/DD/YY")# #timeformat(now(),"HH:MM")#'>
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
                        ,created_by
                        ,created_on
						,email
                        )
                    VALUES
                        ('#ods_Users.empl_nmbr#',
                        '#oprid#',
                        3, 4,
                        '#first_name#',
                        '#last_name#',
                        '#empname#',
                        '#Cost_Center#',
                        'Active',
                        'False'
                        ,'#ods_Users.empl_nmbr#'
                        ,'#timestamp#' 
						,'#EMAIL_ADDR#'
                        )			
                </cfquery>
      </cfif>
          
    <!--- Build roles to control links --->
    <cfif authresult EQ "SUCCEED">
      <!--- If in local database, and corporate --->
      
      <cfquery name="userInfo" datasource="#Application.dsn#">
		         select *
		           from v_users
		           where oprid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#FORM.strUsername#">
		       </cfquery>
      <cfif userInfo.inactive eq 1>
        <cfset StructClear(session)>
        <cfset session.loggedIn="false">
        <!--- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
						  The user is inactive. Display an error message and the
						  login form.
						  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->
        <cfset message="Your login is inactive.">
        <cfinclude template="dsp_login.cfm">
        <cfabort>
      </cfif>
      
      <!--- Otherwise set up session vars required by the application --->
      <cfset session.LoggedIn="true">
	  <cfset session.email="#userInfo.email#">
      <cfset session.oprid="#FORM.strUsername#">
      <cfset session.id_user="#userInfo.id_user#">
      <cfset session.emplID="#userInfo.emplID#">
      
      <!--- cfset session.ID_group="#userInfo.ID_group#">
				<cfset session.ID_sector="#userInfo.ID_sector#" --->
      <cfset session.sector=#userInfo.sctr#>
      <cfset session.group=#userInfo.grp#>
      <cfset session.oprtn=#userInfo.oprtn#>
      <cfset session.dvsn=#userinfo.dvsn#>
      <cfset session.ID_role="#userInfo.ID_role#">
      <cfset session.ID_job="#userInfo.ID_job#">
      <cfset session.approval_level= session.id_job>
      <cfset session.empName="#userInfo.empName#">
      <cfset session.jobtitle="#userInfo.title#">
      
      <!--- ++++++++++++++  Approval Group Assignments +++++++++++++++++  --->
      
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
	  
      <cfset session.approval_grp=valueList(appGrp.approval_group)>
	  <!---<cfdump var="#AppGrp#">
	  <cfdump var="#SESSION#">
	  <cfabort>--->
      <!--- NOT QuotedValueList, use list=true in CFQueryParam --->
      
      <!--- 3. Session.Approval_level .... Might have more power than my base id_job --->
      <CFIF AmIDelegatee.id_job GT session.id_job>
        <!--- do I have more power then my id_job --->
        <cfset session.approval_level = AmIDelegatee.id_job>
        <cfelse>
        <!--- Otherwise my job id defines my level of authority --->
        <cfset session.approval_level= session.id_job>
      </cfif>
      <cfset FilePath = GetDirectoryFromPath(GetCurrentTemplatePath()) />
      <cfif #Findnocase('MGann',FilePath)#>
        <cfset session.env="MG Dev">
        <cfelseif #FindNocase('AHuang',FilePath)#>
        <cfset session.env="AH Dev">
        <cfelse>
        <!--- Use server to determine development or Production --->
        <cfif Findnocase('ara',filepath)>
          <cfset session.env="Staging">
          <cfelseif findnocase('ara/index.cfm', filepath)>
          <cfset session.env="Production">
          <cfelse>
          <cfset session.env="Dev">
        </cfif>
      </cfif>
      <cfelse>
      <!--- FAIL: (loginCheck.recordcount gt 0) AND (authresult.auth) --->
      <cfset StructClear(session)>
      <cfset session.loggedIn="false">
      <!--- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
					  The user was not authenticated. Display an error message and the
					  login form.
					  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ --->
      <cfset message="The login and password entered were not found. Contact the system administrator to obtain access.">
      <cfinclude template="dsp_Login.cfm">
      <cfabort>
    </cfif>
    <!--- END: (loginCheck.recordcount gt 0) AND (authresult.auth) --->
    <!--- /cfif --->
    <!--- /cflogin --->
    
    <cfelseif (NOT isDefined('session.oprid') OR isDefined("url.logout"))>
    <!--- Form.strUserName is not defined --->
    <cfset structClear(session)>
    <!--- cfdump var="#session#" format="text" --->
    <cfset session.loggedIn="false">
    <cfinclude template="dsp_login.cfm">
    <cfabort>
  </cfif>
  <cfset super.onRequestStart(arguments.targetPage)>
</cffunction>

<cffunction name="onError" returntype="void" output="true">
  <cfargument name="exception" required="true">
  <cfargument name="eventname" type="string" required="true">
  <cfif find("OTB",CGI.HTTP_HOST) GT 0 or find("dev",CGI.HTTP_HOST) GT 0>
    <cfdump var="#arguments.exception#">
    <cfmail to="anna.huang1@hii-tsd.com" from="ARA-Error@hii-tsd.com" subject="ARA - Error Notification" type="html">
ARA      <br />
      IP Address: #CGI.REMOTE_ADDR#<br />
      Time: #dateformat(now(), "mmm. dd, yyyy")# #timeformat(now(), "long")#<br />
      Referer: #CGI.HTTP_REFERER#
      <hr />
      <cfdump var="#arguments.exception#">
	<cfif isDefined('session')>
      <cfdump var="#SESSION#">
</cfif>
    </cfmail>
    <cfelse>
    <!---<cfdump var="#arguments.exception#">--->
    <cfif findnocase('is undefined in SESSION', arguments.exception) EQ 0>
      <cfmail to="anna.huang1@hii-tsd.com" from="ARA-Error@hii-tsd.com" subject="ARA - Error Notification" type="html">
ARA     <br />
        IP Address: #CGI.REMOTE_ADDR#<br />
        Time: #dateformat(now(), "mmm. dd, yyyy")# #timeformat(now(), "long")#<br />
        Referer: #CGI.HTTP_REFERER#
        <hr />
        <cfdump var="#arguments.exception#">
	<cfif isDefined('session')>
        <cfdump var="#SESSION#">
   	</cfif>
      </cfmail>
    </cfif>
    <cflocation addtoken="no" url="/ara/index.cfm?action=error">
  </cfif>
</cffunction>

</cfcomponent>