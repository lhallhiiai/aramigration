<cfparam name="SelectTxt" default="">
<!--- Populates Delegator and Delegator Lists  --->
<cffunction name="getlist">
	<cfargument name="qname" required="No"><!--- delegate_From, Delegate_ToList --->
	<!--- List of people that who already have delegations in effect --->
	<cfquery name="CurDel" datasource="#application.dsn#">
		Select fk_delegateFrom_ID from delegation
	</cfquery>
	<cfset DelegateFrom_list=#Valuelist(CurDel.fk_delegateFrom_ID)#><!--- will exclude them in next query --->
	
	<!--- If Delegate From selected: need job title, group,  sector etc to filter down Delegate_Tos --->
	<cfif  (isDefined('url.thisid_user')) or (Session.id_role GT 1)>
		<cfif Session.id_Role GT 1><!--- session.role GT 1 is delegating for self --->
			<cfset url.thisid_user=#session.id_user#>
		</cfif>
		<cfquery name="thisUser" datasource="#application.dsn#">
			Select * from v_users
			where id_user='#url.thisid_user#'
		</cfquery>
		<cfdump var="#thisUser#" format="text">
	</cfif>
	
	
	<!---                 DELEGATE TO LIST                        --->
	<cfquery name="#qname#" datasource="#application.dsn#">
	    Select * from v_users
		where 1=1
	<cfswitch expression="#qname#">
	<cfcase value="delegateFrom">
		and ID_job NOT IN (19,20)
		<cfif isDefined('url.thisid_user')>
			and id_user=#url.thisid_user#
		</cfif>
	</cfcase>
	<cfcase value="DelegateTo">
		<!--- cannot delegate to self --->
		and id_user <> '#session.id_user#'
		and status='Active'
		<!--- cannot delegate to soemone who has delegated already --->
		<!--- cfif Len(DelegateFrom_list) GT 0>
			and id_user NOT IN (#DelegateFrom_list#)
		</cfif  This gets check on insert, bcause timeframes can be different --->
		
		<cfif isDefined('URL.thisid_user')>
		<!--- Have selected delegateFrom. Disallow delegation to self  --->
			and (id_user <> '#URL.thisid_user#')
		</cfif>
	
		<!--- Can delegate to GREATER POWER (role is less than delegate from) and if NOT ADMIN --->
		and (id_role <= #thisUser.ID_Role#)
		
		<!--- Job Level Filters: The most complex rules --->
		<cfswitch expression="#thisUser.id_job#">
		<!--- Lowest Level: Division Level must be within same Op --->
		<cfcase value="1,2,3"><!--- PM, Contract Mgr, Controller,Division Mgr --->
			<cfset SelectTxt="ARA Users with same ARA Job Title">
			and sctr='#thisUser.sctr#'
			and id_job=#thisUser.id_job#
		</cfcase>
		<cfcase value="4"><!--- Division Mgr --->
			<cfset SelectTxt="PMs and DMs">
			and sctr='#thisUser.sctr#'
			and id_job=1 or id_job=4
		</cfcase>
		<cfcase value="5,6"><!--- Operations Level must be within same Group --->
			<cfset SelectTxt="ARA Users in same Group and same Job Title">
			and grp='#thisUser.grp#'
			and id_job=#thisUser.id_job#
		</cfcase>
		<cfcase value="7,8,9"><!--- Group Level: Must be within same Sector --->
			<cfset SelectTxt="ARA Users in same Sector, same Job Title, as powerful ARA Role">
			<cfif thisUser.id_job EQ 9><!--- Group Manager: Can delet to GrpMgr or Deputy Group Mgr --->
				and (id_job=#thisUser.id_job#) OR (id_job=20)
			<cfelse>
				and id_job=#thisUser.id_job#
			</cfif>
		</cfcase>
		<cfcase value="10,11,13"><!--- Sector Level --->
			<cfset SelectTxt="Sector Manager or Deputy">
			<cfif thisUser.id_job EQ 13><!--- Sector Manager: can delegate to other SecMgr or Chief of Staff --->
				and ((id_job=#thisUser.id_job#) OR (id_job=19))
			<cfelse>
				and (id_job=#thisUser.id_job#)
			</cfif>
		</cfcase>
		<cfcase value="16,17,18"><!--- Corporate Level: Can only delegate to other corp level --->
			<cfset SelectTxt="Other Corporate-Level Positions">
			and (id_job IN (16,17,18))
		</cfcase>
		<!---<cfcase value="24"><!--- Auditor, only delegate to other auditors --->
			and id_job=24
		</cfcase>--->
		</cfswitch>
		
	</cfcase>
	</cfswitch>
	Order by Last_name	
</cfquery>
<cfif isDefined('DelegateTo')>
	
<cfdump var="#DelegateTo#" format="text">
</cfif>
<cfif (Qname EQ "DelegateTo") and (DelegateTo.RecordCount EQ 0)>
	<cfset SelectTxt="No one with the appropriate authority is a user of ARA">
</cfif>
	
</cffunction>
