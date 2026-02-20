<cfset menu="Admin">
<cfset submenu="title">

<p class="smtitle">Administration</p>
<p class="title">CAE_ODS Job Titles</p>
<p>These job titles were derived from CAE_ODS table All_Users.</p>
<cfquery name="PMs" datasource="cae_ods">
	SELECT     LAST_NAME, FIRST_NAME, LOGIN_NAME, ORGANIZATION, USER_ID, JAMIS_DEPT, DISPLAY_NAME, [COUNTRY ], OFFICE_LOC,
 MAIL_TYPE, OU, [JOB TITLE] AS Jobtitle, USER_INFO, BDAY, MANAGER, [FWD ], FULL_NAME, [SERVER ], [EMPLOYEE TYPE], [BUSINESS UNIT], 
                      [SPECIAL ACCESS]
FROM         ALL_USERS
WHERE     ([JOB TITLE] LIKE '%program%') AND ([JOB TITLE] LIKE '%Manager%')
Order by [JOB Title], Organization, Last_name
</cfquery>
<p>PROGRAM MANAGERS: WHERE     ([JOB TITLE] LIKE '%program%') AND ([JOB TITLE] LIKE '%Manager%')</p>
<ol>
<cfoutput query="PMS">
	<li> <b>#JobTitle#</b> #Last_Name#, #First_name#, Dept: #Jamis_Dept#</li>
</cfoutput>
</ol>
<cfquery name="DMs" datasource="cae_ods">
	SELECT     LAST_NAME, FIRST_NAME, LOGIN_NAME, ORGANIZATION, USER_ID, JAMIS_DEPT, DISPLAY_NAME, [COUNTRY ], OFFICE_LOC,
 MAIL_TYPE, OU, [JOB TITLE] AS Jobtitle, USER_INFO, BDAY, MANAGER, [FWD ], FULL_NAME, [SERVER ], [EMPLOYEE TYPE], [BUSINESS UNIT], 
                      [SPECIAL ACCESS]
FROM         ALL_USERS
WHERE     ([JOB TITLE] LIKE '%division%') AND ([JOB TITLE] LIKE '%Manager%')
Order by [JOB Title], Organization,Last_name
</cfquery>
<p>DIVISION MANAGERS: WHERE     ([JOB TITLE] LIKE '%division%') AND ([JOB TITLE] LIKE '%Manager%')</p>
<ol>
<cfoutput query="DMS">
	<li> <b>#JobTitle#</b> #Last_Name#, #First_name#, Dept: #Jamis_Dept#</li>
</cfoutput>
</ol>

<cfquery name="OPs" datasource="cae_ods">
	SELECT     LAST_NAME, FIRST_NAME, LOGIN_NAME, ORGANIZATION, USER_ID, JAMIS_DEPT, DISPLAY_NAME, [COUNTRY ], OFFICE_LOC,
 MAIL_TYPE, OU, [JOB TITLE] AS Jobtitle, USER_INFO, BDAY, MANAGER, [FWD ], FULL_NAME, [SERVER ], [EMPLOYEE TYPE], [BUSINESS UNIT], 
                      [SPECIAL ACCESS]
FROM         ALL_USERS
WHERE     ([JOB TITLE] LIKE '%Operation%') AND ([JOB TITLE] LIKE '%Manager%')
Order by [JOB Title],Organization,  Last_name
</cfquery>
<p>OPERATION MANAGERS: WHERE     ([JOB TITLE] LIKE '%Operation%') AND ([JOB TITLE] LIKE '%Manager%')</p>
<ol>
<cfoutput query="OpS">
	<li> <b>#JobTitle#</b> #Last_Name#, #First_name#, Dept: #Jamis_Dept#</li>
</cfoutput>
</ol>


<!--- ++++++++++++++++++++++++++++++++  Group Manager ----------------------- --->
<cfquery name="GMgr" datasource="cae_ods">
	SELECT     LAST_NAME, FIRST_NAME, LOGIN_NAME, ORGANIZATION, USER_ID, JAMIS_DEPT, DISPLAY_NAME, [COUNTRY ], OFFICE_LOC,
 MAIL_TYPE, OU, [JOB TITLE] AS Jobtitle, USER_INFO, BDAY, MANAGER, [FWD ], FULL_NAME, [SERVER ], [EMPLOYEE TYPE], [BUSINESS UNIT], 
                      [SPECIAL ACCESS]
FROM         ALL_USERS
WHERE     ([JOB TITLE] LIKE '%Group%') AND ([JOB TITLE] LIKE '%Manager%')
Order by [JOB Title], Organization, Last_name
</cfquery>
<p>Group MANAGERS: WHERE     ([JOB TITLE] LIKE '%Group%') AND ([JOB TITLE] LIKE '%Manager%')</p>
<ol>
<cfoutput query="GMgr">
	<li> <b>#JobTitle#</b> #Last_Name#, #First_name#, Dept: #Jamis_Dept#</li>
</cfoutput>
</ol>

<!--- ++++++++++++++++++++++++++++++++  Sector Manager ----------------------- --->
<cfquery name="SMgr" datasource="cae_ods">
	SELECT     LAST_NAME, FIRST_NAME, LOGIN_NAME, ORGANIZATION, USER_ID, JAMIS_DEPT, DISPLAY_NAME, [COUNTRY ], OFFICE_LOC,
 MAIL_TYPE, OU, [JOB TITLE] AS Jobtitle, USER_INFO, BDAY, MANAGER, [FWD ], FULL_NAME, [SERVER ], [EMPLOYEE TYPE], [BUSINESS UNIT], 
                      [SPECIAL ACCESS]
FROM         ALL_USERS
WHERE     ([JOB TITLE] LIKE '%Sector%') AND ([JOB TITLE] LIKE '%Manager%')
Order by [JOB Title], Organization, Last_name
</cfquery>
<p>SECTOR MANAGERS: WHERE     ([JOB TITLE] LIKE '%Sector%') AND ([JOB TITLE] LIKE '%Manager%')</p>
<ol>
<cfoutput query="SMgr">
	<li> <b>#JobTitle#</b> #Last_Name#, #First_name#, Dept: #Jamis_Dept#</li>
</cfoutput>
</ol>


<!--- ++++++++++++++++++++++++++++++++  Contracts ----------------------- --->
<cfquery name="CAS" datasource="cae_ods">
	SELECT     LAST_NAME, FIRST_NAME, LOGIN_NAME, ORGANIZATION, USER_ID, JAMIS_DEPT, DISPLAY_NAME, [COUNTRY ], OFFICE_LOC,
 MAIL_TYPE, OU, [JOB TITLE] AS Jobtitle, USER_INFO, BDAY, MANAGER, [FWD ], FULL_NAME, [SERVER ], [EMPLOYEE TYPE], [BUSINESS UNIT], 
                      [SPECIAL ACCESS]
FROM         ALL_USERS
WHERE     ([JOB TITLE] LIKE '%Contract%') AND (([JOB TITLE] LIKE '%Manager%') OR ([Job Title] Like '%ADMIN%'))
Order by [JOB Title], Organization, Last_name
</cfquery>
<p>CONTRACT MANAGERS: WHERE     ([JOB TITLE] LIKE '%Contract%') AND (([JOB TITLE] LIKE '%Manager%') OR ([Job Title] Like '%ADMIN%'))</p>
<ol>
<cfoutput query="CAS">
	<li> <b>#JobTitle#</b> #Last_Name#, #First_name#, Dept: #Jamis_Dept#</li>
</cfoutput>
</ol>

<!--- ++++++++++++++++++++++++++++++++  Controller ----------------------- --->
<cfquery name="CNT" datasource="cae_ods">
	SELECT     LAST_NAME, FIRST_NAME, LOGIN_NAME, ORGANIZATION, USER_ID, JAMIS_DEPT, DISPLAY_NAME, [COUNTRY ], OFFICE_LOC,
 MAIL_TYPE, OU, [JOB TITLE] AS Jobtitle, USER_INFO, BDAY, MANAGER, [FWD ], FULL_NAME, [SERVER ], [EMPLOYEE TYPE], [BUSINESS UNIT], 
                      [SPECIAL ACCESS]
FROM         ALL_USERS
WHERE     ([JOB TITLE] LIKE '%Controller%')
Order by [JOB Title], Organization, Last_name
</cfquery>
<p>CONTROLLERS: WHERE     ([JOB TITLE] LIKE '%Controller%')</p>
<ol>
<cfoutput query="CNT">
	<li> <b>#JobTitle#</b> #Last_Name#, #First_name#, Dept: #Jamis_Dept#</li>
</cfoutput>
</ol>