<cfparam name="Printerfriendly" default="No">
<!--- Help page for the administration of Users --->
<cfif printerfriendly EQ "No">
<table cellpadding=0 cellspacing=0 width=90%>
<cfelse>
<table cellpadding=0 cellspacing=0 width=65%>
</cfif>
<tr>
	<td>
<p class="smtitle">Delegation</p>
<p class="title">Rules of Delegation</p>
<!--- cfdump var="#CGI#" format="text" --->

</td>
<cfif Printerfriendly EQ "No">
<td valign="top" nowrap align="right">
<a class="embed" href="index.cfm?<cfoutput>#CGI.QUERY_STRING#</cfoutput>&PrinterFriendly=Yes">&nbsp;Printer Friendly</a>&nbsp;&nbsp;|&nbsp;&nbsp;
</td>
</cfif>
<td valign="top" width=25 align="right">
&nbsp;<a class="embed" href="javascript: history.go(-1)">Back</a>
</td></tr></table>
<cfif printerfriendly EQ "No">
<table cellpadding=0 cellspacing=0 width=90%>
<cfelse>
<table cellpadding=0 cellspacing=0 width=65%>
</cfif>
<tr>
	<td>


<br><br>
<font class="blocknum">1.</font><font class="step">&nbsp;&nbsp;One delegation to one person during a specific time frame</p>
<p class="help">A user can only delegate to one person for a specific time frame; they cannot delegate a multiple people for a single time frame. A user can have multiple, sequential delegations, to different people. For example, a 3-week vacation may require coverage by 3 different persons during each of the sequential weeks. ARA allows these sequential delegations to be setup in advance.</p>


<font class="blocknum">2.</font><font class="step">&nbsp;&nbsp;You cannot delegate to a person that already has a delegation in effect.</p>
<p class="help">Delegations are only allowed to be one level deep.</p>

<font class="blocknum">3.</font><font class="step">&nbsp;&nbsp;Job titles can only delegate to specific job titles</p>
<p class="help">Delegations are allowed are based on ARA job titles (not Peoplesoft job titles). The table below defines which job titles can delegate to other job titles.
<cfquery name="GetTitles" datasource="#Application.dsn#">
	Select * from
	jobtitle 
	where Inactive='False'
	and id_job != 23
	order by apporder
</cfquery>
<table cellpadding=2 cellspacing=2 class="border">
<tr bgcolor="#cccccc">
	<td class="border">Approval Order</td>
	<td class="border">Job title</td>
	<td class="border">Description and Delegation rules</td>
</tr>
<cfoutput query="GetTitles">
<tr>
	<td class="border">
	<cfif #appOrder# EQ ""><font style="font-size:7px;color:##6c8d9b;">Not an Approver</font>
	<cfelse>#appOrder#</cfif>
	</td>
	<td class="border">#title#</td>
	<td class="border">#Description#</td>
</tr>


</cfoutput>
</table>
	
</td></tr></table>