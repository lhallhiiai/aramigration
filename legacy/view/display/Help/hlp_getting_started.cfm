<cfparam name="Printerfriendly" default="no">
<cfif printerfriendly EQ "No">
<table cellpadding=0 cellspacing=0 width=90%>
<cfelse>
<table cellpadding=0 cellspacing=0 width=65%>
</cfif>
<tr>
	<td>
<p class="smtitle">Getting Started</p>
<p class="title">ARA Processing At-a-Glance</p>
<!--- cfdump var="#CGI#" format="text" --->

</td>
<cfif Printerfriendly EQ "No">
<td valign="top" nowrap align="right">
<a class="embed" href="index.cfm?<cfoutput>#CGI.QUERY_STRING#</cfoutput>&PrinterFriendly=Yes">Printer Friendly</a>&nbsp;&nbsp;
</td>
</cfif>
<td valign="top" width=25 align="right">

<img src="images/LeftArrow.gif" border=0 align="left" >&nbsp;<a class="embed" href="javascript: history.go(-1)">Back</a>
</td></tr></table>
<cfif printerfriendly EQ "No">
<table cellpadding=0 cellspacing=0 width=90%>
<cfelse>
<table cellpadding=0 cellspacing=0 width=65%>
</cfif>
<tr>
<td>
<img src="images/ARAAtAGlance.gif" border="0">
</td></tr>
</table>