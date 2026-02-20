<!--- cfparam name="session.loggedIn" default="No">
<cfparam name="message" default="" --->
<cfset maxrows=12>
<cfparam name="startrow" default=1>
<cfparam name="count" default=1>
<cfparam name="total" default=0>
<cfparam name="topquery" default="myQ">
<cfparam name="bottomquery" default="done">
<cfparam name="allorMine1" default="Mine">
<cfparam name="allorMine2" default="Mine">
<cfparam name="Title" default="Welcome to ARA">
<cfparam name="AllorMine" default="Mine">
<cfparam name="smtitle" default="IN Process">
<cfparam name="activeSort" default="id_ara">

<cffunction name="Usr_Details">
	<cfargument name="id_usr" required="yes">
	<cfset del_flag="">
	<cfquery name="u_info" datasource="#Application.dsn#">
		Select * from v_users
		where id_user=#id_usr#
	</cfquery>
	<cfset thisoprid=u_info.oprid>
	<cfset first_name=u_info.first_name>
	<cfset last_name=u_info.last_name>
	<cfset id_job=u_info.id_job>
	<cfset delegatee=u_info.DelegateTo_oprid>
</cffunction> 


<cfswitch expression="#topquery#">
<cfcase value="Inprocess">
	<cfquery name="InProcess" datasource="#Application.dsn#">
		Select * from v_ARA 
		where id_status IN (1,2,3,4,5,6,7,8,9) 
		Order BY #ActiveSort#
	</cfquery>
	<cfset total=Inprocess.recordcount>
</cfcase>
<cfcase value="myQ">

<cfif Find(session.id_job,'123')>
session.job_id: <cfoutput>#session.id_job#</cfoutput>
	<cfquery name="MyQ" datasource="#Application.dsn#">
		Select * from v_ara
		where 1=1
		<cfif AllorMine1 EQ 'All'>
			and id_status IN (1,2,3,4,5,6,7,8,9)
		<cfelse>
			<cfswitch expression="#session.id_job#">
				<cfcase value="1"><!--- PM --->
					and Id_PM=#session.id_user# 
					<cfif isDefined('session.delegators') AND (session.delegators NEQ "")>
					or ID_pm IN (#session.delegators#)
					</cfif>
					and id_status in (1,8,9)
				</cfcase>
				<cfcase value="2"><!--- Contract Manger --->
					and Id_Contract=#session.id_user# 
					<cfif isDefined('session.delegators') AND (session.delegators NEQ "")>
					or ID_Contract = #session.delegators#
					</cfif>
					and id_status in (2,3)
				</cfcase>
				<cfcase value="3"><!--- Controller --->
					and Id_Controller=#session.id_user# 
					<cfif isDefined('session.delegators') AND (session.delegators NEQ "")>
					or ID_Controller = #session.delegators#
					</cfif>
					and id_status in (4,5)
				</cfcase>
			  </cfswitch>
		   </cfif>
	 	</cfquery>
		<cfdump var="#MyQ#" format="text">
		<cfset total=#myQ.recordcount#>
	<cfelse>
	<cfquery name="MyQ" datasource="#Application.dsn#">
		select x.* 
		from 
      	(select id_ara,a.id_contract,a.id_pm,a.id_controller,a.id_status,a.reference,a.expirationDate,a.amountTotal,a.jamisNo,a.grp,
				a.op,a.division,a.sector,a.customername
                  ,u.id_user
                  ,u.ID_job,st.oneword
      	from dbo.v_users u
                  INNER JOIN v_ara a on u.sctr=a.sector 
				  		and u.grp=a.grp and 
						u.oprtn=a.op 
						<cfif session.id_job LTE 4>
						and u.dvsn=a.division
						</cfif>
                  INNER JOIN category ON a.id_cat = category.id_cat 
                  INNER JOIN thresholds ON category.riskLevel = thresholds.riskLevel 
                  INNER JOIN jobTitle ON thresholds.id_job = jobTitle.id_job
				  INNER JOIN status st on st.id_status= a.id_status
      	WHERE a.id_status=6 and jobtitle.id_job > 3
                  and jobtitle.id_job NOT in (16,17,21,22,23)
                  and thresholds.low_thresh <= a.amountTotal
                  <cfif AllorMine EQ 'Mine'>
                  and oprid='#session.oprid#'
				  </cfif>
      	group by id_ara
                  ,u.id_user
                  ,u.ID_job
				 ,a.id_contract,a.id_pm,a.id_controller,a.id_status,a.reference,a.expirationDate,a.amountTotal,a.jamisNo,a.grp,a.op,a.division,a.sector,
				  a.customername,st.oneword) x
      	left outer join dbo.araAppLog l on x.id_ara=l.id_ara and x.id_user=l.id_user 
	  	and x.id_job=l.id_user
		where l.id_araAppLog is null
    </cfquery>              

	<cfset total=MyQ.recordcount>
	<cfdump var="#myQ#" format="text"><cfabort>
	<cfoutput>My recordcount is: #myQ.recordcount#<br></cfoutput>
</cfif>
	<!--- cfoutput>My Queue is #MyQ.recordcount# session.id_job is #session.id_job#
	<cfdump var="#MYQ#" format="text"></cfoutput --->



</cfcase>
<!--- passing a list from dashboard --->
<cfcase value="ara_list">
	<cfquery name="ara_list" datasource="#Application.dsn#">
		Select * from v_ara
		where id_ara in (#ara_list#)
		order by #ActiveSort#
	</cfquery>
	<cfset total=ara_list.recordcount>

</cfcase>
<cfcase value="bystate">
	<cfquery name="bystate" datasource="#Application.dsn#">
		Select * from v_ara
		where id_status in (#state#)
		order by #ActiveSort#
	</cfquery>
	<cfset total=#bystate.recordcount#>
</cfcase>
</cfswitch>
<cfswitch expression="#bottomquery#">
<cfcase value="Done"><!--- Approved, Cancelled, Exported --->
	<cfquery name="Done" datasource="#application.dsn#">
		Select * from v_ara
		where id_status in (12,10,13)
	</cfquery>
	<cfset bottomTotal=#Done.Recordcount#>
</cfcase>
</cfswitch>
<cfoutput>
<table cellpadding=0 cellspacing=0 width=100% border=0 align="right">
	<tr>
	<td align="left" nowrap>
		<p class="title">
		#title#</p>
		<p class="smtitle">
		#smtitle#</p>
	</td>
	<td align="right" nowrap>
		<input type="radio" onclick="Javascript: window.location.href='index.cfm?Fuseaction=app.home&AllorMine1=Mine';" 
		       Name="AllorMine1" value="Mine" <cfif #AllorMine1# EQ "Mine">Checked</cfif>>See Mine
		<input type="radio"onclick="Javascript: window.location.href='index.cfm?Fuseaction=app.home&AllorMine1=All';" 
		       Name="AllorMine1" value="All" <cfif #AllorMine1# EQ "All">Checked</cfif>>See All
	
	</td></tr>
</table>
<!--- cfdump var="#session#" format="text" --->
<!--- cfdump var="#Active#" format="text">
<cfabort --->
<!--- cfdump var="#cgi#" format="text" --->
<cfinclude template="dsp_Messages.cfm">
</cfoutput>

<cfif total EQ 0>
	<p>You have no ARAs in your work queue.</p>
<cfelse>	
	<!---- Table Header for home page listings --->
	<table cellpadding=2 width=100% cellspacing=2 class="border">
	          <!--- iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii --->
			        <cfinclude template="inc_HomeTblHdr.cfm">
			  <!--- iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii --->
	<cfset count=Startrow>
	<cfoutput query="#topquery#" maxrows="#maxrows#" startrow="#startrow#">
	
	
	          <!--- iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii --->
			        <cfinclude template="inc_HomeTblRow.cfm">
			  <!--- iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii --->
	</cfoutput>
	</table>
	<!--- +++++++++++++        nav to next pages of ARAs IN PROGRESS / TOP   ++++++++++++++++++++ --->
	<cfset pages=round(val(total/maxrows))>
	<table width=80% cellpadding=2 border=0 align="right">
	<tr>
		<td align="right">
			<cfoutput>
			<cfset pages=round(val(total/maxrows))>
			More ARAs:&nbsp;&nbsp; 
			<CFLOOP INDEX="i" FROM="1"  TO="#pages#">
				<cfset startrow=val((i * maxrows)-maxrows+1)>
			    <a class="embed" href="index.cfm?fuseaction=app.home&menu=home&startrow=#startrow#&topquery=#topquery#&activesort=#activesort#">#i#</a>&nbsp;&nbsp;
			</CFLOOP>
			</cfoutput>
	</td></tr>
	</table>
</cfif>
<!--- +++++++++++++       End of  In Progress nav page     ++++++++++++++++++++ --->


