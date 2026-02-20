<cfparam name="id_ara" default="117">

<p class="smtitle">Dashboard</p>
<p class="title">
<!---<cfif session.approval_level LT 10>
	My Sector and Group
<cfelseif Find(session.approval_level,"10,11,12")>
	My Sector
<cfelse>
	All Open ARAs
</cfif>--->
All Open ARAs
</p>

<br><br>
<table width=100% cellpadding=2 cellspacing=2>
<tr>
<td valign="top">
<cfinclude template="dsp_dashboardPending.cfm">
</td>
</tr>
<tr>
<td valign="top">	
<cfinclude template="dsp_dashboardExpirations.cfm">
</td>
</tr>
<!---<tr>
<td valign="top" colspan="2">	
<cfinclude template="dsp_dashboardApprovalchain.cfm">
</td>
</tr>--->
</table>



