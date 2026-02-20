<!--- Based on ARA id_status and id ARA determines the current Approver. --->

<cfparam name="sector" default="">
<cfparam name="grp" default="">
<cfparam name="division" default="">
<cfparam name="NAID" default="">

<cfif Not isdefined('id_status')><!--- if status was not passed then we pull it --->
	<cfquery name="stat" datasource="#Application.dsn#">
		Select id_status from ARA
		where id_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#ARA_ID#">
	</cfquery>
	<cfset id_status=#stat.id_status#>
</cfif>
<!--- 1,8,9: PM states; 2,3 Contracts States;  4,5: Controller states --->
<cfif Listfind('1,2,3,4,5,8,9',id_status) ><!--- Get PM, Contracts, Controller right from ara record --->
	<cfquery name="TheThree" datasource="#Application.dsn#">
		Select ID_PM,ID_contract,ID_controller
		from ARA
		WHERE id_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#ARA_ID#">
	</cfquery>
	<cfswitch expression="#id_status#">
		<cfcase value="1,8,9"><cfset NAID=TheThree.ID_PM>        </cfcase>
		<cfcase value="2,3"><cfset NAID=TheThree.ID_Contract>   </cfcase>
		<cfcase value="4"><cfset NAID=TheThree.ID_Controller>  </cfcase>
	</cfswitch>
	<cfif NAID EQ "">
		<cfoutput>Contract or Controller Not defined<br></cfoutput>
	</cfif>
	<cfif NAID NEQ "">
		<cfquery name="CurrentApp" datasource="#Application.dsn#">
			Select * from v_users
			where id_user=#NAID#
		</cfquery>
		<!---ccccccccc        CurrentApp        cccccccccc <br>
		<cfdump var="#CurrentApp#" format="text">--->
	</cfif>
<cfelseif Listfind('10,13,15,16,17',ID_status)><!---Cancelled, Exported, Negated Exported, Early Start Complete,Archived --->
	<cfset currentApp.id_user="Done"><cfset NAID="">
<cfelse><!---  Likely to be in Approval chain otherwise search the organizational structure --->
	<cfinclude template="qry_getApprovalChain.cfm">
	<cfquery name="lastApp" datasource="#application.dsn#">
		SELECT TOP 1 *
		FROM araAppLog
		WHERE id_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#ARA_ID#">
		ORDER BY approvalDate desc
	</cfquery>
	<!---<cfdump var="#lastApp#" format="text">--->
	<cfif lastApp.recordcount EQ 0><!--- No one has approved --->
		<cfset NAID = 1>
		<cfset currentCycle = 1>
	<cfelse>
		<cfset currentCycle = lastApp.cycle>
		<cfset n=Listfind(thresh_list,lastApp.id_job)>
		<!---<cfdump var="#thresh_list#" format="text"><cfabort>--->
		<cfif listlen(thresh_list) GT n>
			<cfset NAID=ListGetat(thresh_list,(n+1))><!--- The next job title in the chain --->
		<cfelse>
			<cfset NAID=ListGetat(thresh_list,n)>
		</cfif>
		<!---<cfoutput> zzzzzzzzzzzzzzz #thresh_list# Next is #NAID# zzzzzzzzzzzzzzzzzz </cfoutput>--->
	</cfif>
		<!---<cfoutput>	NAID is #NAID#</cfoutput>--->
    <cfquery name="getDiv" datasource="#Application.dsn#">
		Select division,ID_OpsVP from ARA
		where id_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#ARA_ID#">
	</cfquery>
	<cfquery name="CurrentApp" datasource="#application.dsn#">
		SELECT  *
		FROM v_users
		where id_job=#NAID# 
		and 1=1
		and Inactive='False' and oprid is not null 
		<cfif id_job NEQ 13 or id_job NEQ 14 or id_job NEQ 26>
		and (approve_grp like '%#getDiv.division#%' or trim(approve_grp) = '#trim(getDiv.division)#')	
			<cfif NAID EQ 17 and len(trim(getDiv.ID_OpsVP)) GT 2> <!--- Ops VP, get id from v_ara --->
						and id_user = #getDiv.ID_OpsVP#
					</cfif>
		</cfif>
		<!---<cfif ListFind('25,9',NAID)>
   				and id_user IN (select id_user from dbo.approval_grp where approval_group= '#GRP#' and inactive='False')
		</cfif>--->
	</cfquery>
	
	
	
<!--- 
		Last Approval:<br>
		<cfdump var="#lastApp#" format="text">
		<br>++++++++++++++++++++++++++++++++++++++++++++++++++++++<br>
		Where is the last approval in the thresh_list:<br>
		<cfdump var="#n#" format="text">
		<br>++++++++++++++++++++++++++++++++++++++++++++++++++++++<br>
		What is the entire threshlist:<br>
		<cfdump var="#thresh_list#" format="text">
		<br>++++++++++++++++++++++++++++++++++++++++++++++++++++++<br>
		Query for the current approver is:<br>
		<cfdump var="#CurrentApp#" format="text">
		<br>++++++++++++++++++++++++++++++++++++++++++++++++++++++<br>
		<cfoutput><br>NAID is #NAID#</cfoutput>
--->	
	
	
</cfif>
<cfif isDefined('CurrentApp.delegateTo_oprid') and (CurrentApp.delegateTo_oprid NEQ "")>
	<cfset delegateTo_oprid=CurrentApp.delegateTo_oprid>
</cfif>
 <!--- cfdump var="#currentApp#" format="text" --->
