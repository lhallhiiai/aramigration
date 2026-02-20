

<cfparam name="ThisSec" default="#session.sector#">
<cfparam name="ThisGrp" default="#session.Group#">
<cfset submenu="OrgChain">
<!---<cfset seeall="Ahuang,MGann,PHallmann,hvennari,cgreer,nmuzyka,jboyers,dheard,jbryant,tgilliam">--->
<cfparam name="printerfriendly" default="No">
<cffunction name="App_Grp"><!--- Function to create list of other approval groups --->
	<cfargument name="id_job">
	<cfargument name="id_user">
	<cfquery name="getApp_grp" datasource="#Application.dsn#">
		select distinct approval_group
		from approval_grp
		where id_job=#id_job#
		and id_user=#id_user#
		and inactive=0
		and approval_group in ('CEW', 'ISR','CNS', 'LSG','AD','GS', 'WS', 'AUS', 'UXS', 'NUC')
	</cfquery>
	<cfif getApp_grp.recordcount EQ 0>
		<cfset OtherGrps="">
	<cfelse>
		<cfset OtherGrps="<!--[Approves for: #valuelist(getApp_grp.approval_group)#]-->">
	</cfif>
	<cfreturn OtherGrps>
</cffunction>

<!---  *********************************************************************  --->
<!---                                                                         --->
<!---   Header: Title, Sector Navaigation Printer Friendly                    --->
<!---                                                                         --->
<!---  *********************************************************************  --->
<table cellpadding=0 cellspacing=0 border=0 width=95%>
<tr>
	<td valign="middle">
	<p class="smtitle">Approval Chain</p>
	<p class="title"><cfoutput>Group: #ThisGrp#</cfoutput></p>
</td>
<td valign="middle">
<!--- ++++++++++++++++++++++++++ Navigation to other  Groups +++++++++++++++++++++  --->
<table cellpadding=3 cellspacing=3  cellspacing=0>
	<tr>
		<td></td>
		<td colspan=2 align="center">
			Click on Group below to see approval chain
		</td>
		</tr>

	<cfquery name="Sec" datasource="#Application.ods#">
		SELECT distinct org as sctr
		from org_ckis
		where org <> 'CORS' AND org_type='Sector'
		<!---<cfif NOT ListFindNocase(SeeAll,session.oprid)>--->
		<!---<cfif (session.id_role NEQ 2) AND (session.id_job NEQ 13) and (session.id_job NEQ 14)><!--- System Admins, CCS, adn Controller get to see All --->
		and org='#session.sector#'
		</cfif>--->
	</cfquery>

	<!---<cfset sctrs=Valuelist(Sec.Sctr)>--->
    <cfset sctrs="OPER">

	<tr>
	<td>Groups</td>
	<cfloop index="i" list="#sctrs#">
		<cfquery name="getgrp" datasource="#Application.dsn#">
			SELECT DISTINCT GRP
			FROM  ara_CP_Reorg where GRP in ('AD', 'GS', 'WS', 'CEW', 'FSG', 'ISR','LVC', 'AUS', 'UXS', 'NUC')
			ORDER BY GRP
	    </cfquery>

		<td class="border">
		<cfset n=1>
		<cfloop query="getgrp">
			<cfoutput>

			<a class="embed" style="font-size:9px;" href="#self#?fuseaction=app.ApprovalChain&ThisSec=#i#&ThisGrp=#grp#&Menu=ApprovalChain">

			<cfif ThisGrp EQ Grp><font style="background-color: ##eeeeee;"></cfif>#Grp#</font></a>
			</cfoutput>
			<cfif n NEQ getGrp.recordCount>&nbsp;|&nbsp;</cfif>
			<cfset n=n+1>
		</cfloop>
		</td>
	</cfloop>

</table>
<!--- ++++++++++++++++++++++++++    End of Groups at top  +++++++++++++++++++++  --->
</td>
<td valign="middle" nowrap  width=100 align="right">
<cfif printerfriendly EQ "No">
<a class="embed" href="index.cfm?<cfoutput>#CGI.QUERY_STRING#</cfoutput>&PrinterFriendly=Yes">&nbsp;Printer Friendly</a>&nbsp;&nbsp;
<cfelse>
<img src="images/LeftArrow.gif" border=0 align="left" >&nbsp;<a class="embed" href="javascript: history.go(-1)">Back</a>
</cfif>
</td></tr></table>

<!---  *********************************************************************  --->
<!---                                                                         --->
<!---              End of Header, Start of My Approval List                   --->
<!---                                                                         --->
<!---  *********************************************************************  --->
<cfquery name="MatrixJobs" datasource="#Application.dsn#">
	Select distinct id_job
	from thresholds
	order by id_job asc
</cfquery>
<cfquery name="JobApp" datasource="#Application.dsn#">
	Select * from JobTitle
	where id_job in (#ValueList(MatrixJobs.id_job)#)
	and appOrder IS NOT NULL
	order by appOrder
</cfquery>
<Table <cfif printerfriendly EQ "Yes">width=85%<cfelse>width=95%</cfif> cellpadding=2 cellspacing=2 class="border">
	<tr>
		<td valign="bottom" rowspan=2 class="border">Step</td>
		<td valign="bottom" rowspan=2 class="border">ARA Job Title</td>
		<td valign="bottom" rowspan=2 class="border">Person(s) [Click name to see profile]</td>
		<td valign="bottom" align="center" class="border" colspan=4>Risk Level Low Threshholds</td>
	</tr>
	<tr>
		<td class="border" align="center">1</td>
		<td class="border" align="center">2</td>
		<td class="border" align="center">3</td>
		<td class="border" align="center">4</td>
	</tr>
<cfset loopcount=1>

<cfoutput query="jobApp">
	<cfquery name="AppMatrix" datasource="#Application.dsn#">
		SELECT * from Thresholds
		where id_job=#id_job#
		order by risklevel
	</cfquery>
	<cfif (AppMatrix.recordcount GT 1) OR (id_job LT 5)><!--- Core Group, or matrix dictates this job needs to approve --->
	<tr>
		<td align="center" class="border" bgcolor="##edf3f9"><font style="border: solid 1px ##ccdae5;padding:2px 4px 2px 4px; background-color:##edf3f9;color: ##516b7d;"><b>#loopcount#</b></font></td>
		<td class="border" width=250><font class="subtitle">#title#</font>
		<cfif id_job EQ 1>
			<br>Logged in PM <b>[can initiate for any group]</b> is associated with ARA.
		<cfelseif id_job eq 2>
			<br>Contract admin <b>[any in company]</b> is selected by PM during ARA creation.

		<cfelseif id_job eq 3>
			<br>Controller <b>[any in company]</b> is selected by PM during ARA creation.
		</cfif>
		<td class="border">
		<cfquery name="thisJob" datasource="#Application.dsn#">
			Select id_user,id_job,oprid,First_name, Last_name, empname, Grp, delegateTo_oprid
			from v_users
			where id_job=#id_job#
			and Inactive='False' and oprid is not null

			<cfswitch expression="#id_job#">
			<cfcase value="1"><!--- PM group Manager--->
				and grp='#thisGrp#'
			</cfcase>
			<cfcase value="17,24,25,9"><!--- Director Contract Lead --->
					and id_user IN (select id_user from dbo.approval_grp where approval_group= '#ThisGrp#' and  Inactive='False')
			</cfcase>
			</cfswitch>
			order by last_name
		</cfquery>

		<!---<cfif id_job EQ 13>
			<cfdump var="#thisJob#">
		</cfif>--->

		<cfif thisJob.recordCount EQ 0>
			<font style="font-size:8px; font-family: MS Trebuchet;color:##cc0033;">
					NO ARA USER IS DEFINED IN THIS POSITION.</font><br>
					<cfif id_job EQ 1>PMs from other groups in this sector can initiate.
					<cfelseif id_job EQ 2>Contract Managers from other groups in this sector can initiate.
					<cfelseif id_job EQ 3>Controllers from other groups in this sector can initiate.
					</cfif>

		<cfelseif thisjob.recordcount EQ 1>

				<a class="embed" href="index.cfm?fuseaction=app.admin_users&action=UpdateSetup&oprid=#thisjob.oprid#&id_job=#id_job#&id_user=#thisJob.id_user#&sort=last_name&Inactive=0">#thisJob.Last_name#, #thisJob.first_name# <cfif Len(thisJob.oprid) EQ 0><font class="red">[Gone]</font></cfif></a> #App_Grp(id_job,thisJob.id_user)#
			 <cfif thisJob.delegateto_oprid NEQ ""><font style="color:##888888;">[Delegated to #thisJob.delegateto_Oprid#]</font></cfif>

		<cfelseif thisJob.recordCount GT 1>
		<ol>
			<cfloop query="thisjob"><li>#empname#</li>

			</cfloop>
		</ol>
		</cfif>
		<cfset loopcount=val(loopcount+1)>
		</td>

		<cfloop index="i" list="1,2,3">
			<cfquery name="thisthresh" datasource="#Application.dsn#">
				Select low_thresh
				from thresholds
				where id_job=#id_job#
				and riskLevel=#i#
			</cfquery>
			<td nowrap class="border">
			<cfif thisthresh.low_thresh NEQ "">
				<font style="font-size:9px; font-family: Trebuchet MS;">  $#Numberformat(thisthresh.low_thresh,"9,999")#
			<cfelse>
				--
			</cfif>
			</td>
		</cfloop>



	</tr></cfif>


	<!--- Risk Level Lower thresholds --->

</cfoutput>
</table>
