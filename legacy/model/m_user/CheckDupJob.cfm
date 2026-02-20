<cfparam name="errorMsg" default="">
	<cfquery name="checkdup" datasource="#application.dsn#">
		Select * from v_users
		where inActive='False'
		
		<cfswitch expression="#id_job#">
		
		<cfcase value="4"><!--- Division Manager --->
			AND dvsn='#dvsn#' and id_job=4
		</cfcase>
		
		<cfcase value="7"><!--- Group Contracts Manager --->
			and id_job=7
			<cfif NOT isDefined('Approve_grp')><!--- the approval group is the home group --->
				and grp='#grp#'
			<cfelse><!--- Need to Make sure no one else has approval for this grp --->
			    and (grp='#Approve_grp#' OR Approve_grp='#Approve_grp#')
			</cfif>
		</cfcase>
		<cfcase value="8"><!--- Group Controller --->
			 and id_job=8
			<cfif isDefined('approve_grp') and (Approve_grp NEQ "")>
				and Approve_Grp='#approve_grp#' and oprid <> '#form.oprid#'
			<cfelse>
				AND grp='#grp#'
			</cfif>
		</cfcase>
		<cfcase value="9"><!--- Group Manager --->
			AND grp='#grp#' and id_job=9
		</cfcase>
		<cfcase value="10"><!--- Sector Contracts --->
			AND sctr='#sctr#' and id_job=10
		</cfcase>
		<cfcase value="11"><!--- Sector Controller --->
			AND sctr='#sctr#' and id_job=11
		</cfcase>
		<cfcase value="12"><!--- Sector Manager --->
			AND sctr='#sctr#' and id_job=12
		</cfcase>
		<!--- cfcase value="13"><!--- CCS-Contract Setup --->
			AND id_job=13
		</cfcase --->
		<cfcase value="14"><!--- Corporate Controller --->
			AND id_job=14
		</cfcase>
		<cfcase value="15"><!--- Cheif Finanacial Officer --->
			AND id_job=15
		</cfcase>
		<cfcase value="16"><!--- DELEGATE: Chief of Staff--->
			AND sctr='#sctr#' and id_job=16
		</cfcase>
		<cfcase value="17"><!--- DELEGATE: Deputy Group Manager--->
			AND id_job=17
		</cfcase>
		<cfcase value="18"><!--- Chief Operating Officer--->
			AND id_job=18
		</cfcase>
		<cfcase value="19"><!--- Chief Administrative officer--->
			AND id_job=19
		</cfcase>
		<cfcase value="20"><!--- CEO: Chief Executive Officer Bahman --->
			AND id_job=20
		</cfcase>
		</cfswitch>
	</cfquery>
	<cfif CheckDup.recordcount GT 0><!--- a job title should not be being duplicated --->
		<cfswitch expression="#id_job#">
		<cfcase value="4">
			<cfset errorMsg="There can only be one Division Manger per division. #CheckDup.empname# is already the Division Manager for Division #dvsn#.">
		</cfcase>
		<cfcase value="5">
			<cfset errorMsg="There can only be one Operations Controller per operation. #CheckDup.empname# is already the Operations Controller  for Operation #oprtn#.">
		</cfcase>
		<cfcase value="6">
			<cfset errorMsg="There can only be one Operations Manager per operation. #CheckDup.empname# is already the Operations Manager  for Operation #oprtn#.">
		</cfcase>
		<cfcase value="7">
			<cfset errorMsg="There can only be one Group Contracts Manager per group. #CheckDup.empname# is already the Group Contracts Manager  for grp #grp#.">
		</cfcase>
		<cfcase value="8">
		<!--- for group controllers can be in same group, but have different assigned approval groups --->
			<cfif isDefined('checkdup.Approve_Grp') and (checkDup.Approve_grp NEQ "")>
				<cfset grp=checkdup.approve_grp>
			</cfif>
			<cfset errorMsg="There can only be one Group Controller per group. #CheckDup.empname# is already the Group Controller  for sector, group: #sctr#, #grp#.">
		</cfcase>
		<cfcase value="9">
			<cfset errorMsg="There can only be one Group Manager per group. #CheckDup.empname# is already the Group Manager  for grp #grp#.">
		</cfcase>
		<cfcase value="10">
			<cfset errorMsg="There can only be one Sector Contract Manager per Sector. #CheckDup.empname# is already the Sector  Contracts Manager for Sector #sctr#.">
		</cfcase>
		<cfcase value="11">
			<cfset errorMsg="There can only be one Sector Controller per Sector. #CheckDup.empname# is already the Sector  Controller for Sector #sctr#.">
		</cfcase>
		<cfcase value="12">
			<cfset errorMsg="There can only be one Sector Manager per Sector. #CheckDup.empname# is already the Sector  Manager for Sector #sctr#.">
		</cfcase>
		
		<cfcase value="16">
			<cfset errorMsg="There can only be one Chief of Staff per Sector. #CheckDup.empname# is already the Chief of Staff for Sector #sctr#.">
		</cfcase>
		<!--- cfcase value="13">
			<cfset errorMsg="There can only be one Sector Manager per Sector. #CheckDup.empname# is already the Sector Manager for Sector #sctr#.">
		</cfcase --->
		<cfcase value="15,18,20">
			<cfset errorMsg="There can only be one each Corporate Executive positions in the company. Corporate position #checkdup.title# is already defined in ARA by #checkdup.empname#.">
		</cfcase>
		</cfswitch>
		
	</cfif><!--- checkdup GT 1 --->
	<cfif errormsg NEQ "">
		<cflocation url="index.cfm?fuseaction=app.Admin_Users&Menu=Admin&submenu=Users&errorMsg=#errorMsg#">
	</cfif>