<cfset id_ara=url.ara_id>
<cfinclude template="../../model/m_ara/qry_ara.cfm">
<cfparam name="Printerfriendly" default="No">
<!--- Help page for the administration of Users --->
<cfif printerfriendly EQ "No">
<table cellpadding=0 cellspacing=0 border=0 width=90%>
<cfelse>
<table cellpadding=0 cellspacing=0 border=0 width=65%>
</cfif>
<tr>
	<td>
	<p class="smtitle">ara <cfoutput>#reference#</cfoutput></p>
	<p class="title">Email & Audit Trail</p>
	</td>
<cfif Printerfriendly EQ "No">
<td valign="top" nowrap align="right">
<a class="embed" href="index.cfm?<cfoutput>#CGI.QUERY_STRING#</cfoutput>&PrinterFriendly=Yes">Printer Friendly</a>&nbsp;&nbsp;
</td>
</cfif>
<td valign="top" width=25 align="right">
<img src="images/LeftArrow.gif" border=0 align="left" >&nbsp;<a class="embed" href="javascript: history.go(-1)">Back</a>
</td></tr></table>



<cfquery name="getEmail" datasource="#Application.DSN#">
	select * from v_emailLog where id_ara = '#url.ara_id#'
	<!---SELECT     status.statusName, araAppLog.id_ara, araAppLog.comment, emailLog.sentDate, emailLog.id_emailLog,  emailLog.msgto, emailLog.msgcc, emailLog.statusID, araAppLog.id_araAppLog, emailLog.subject
FROM         araAppLog INNER JOIN
                      status ON araAppLog.id_status = status.ID_status RIGHT OUTER JOIN
                      emailLog ON araAppLog.id_ara = emailLog.id_ara 
WHERE     araAppLog.id_ara = '#url.ara_id#' and (araAppLog.id_ara = emailLog.id_ara) AND (emailLog.id_emailType = 1) and (araAppLog.id_status = emailLog.statusid)
ORDER BY emailLog.sentDate, araAppLog.id_status --->
	order by id_emaillog
</cfquery>
<cfif getEmail.recordcount gt 0>
<cfset loopcount=1>
<cfif printerfriendly EQ "No">
<table cellpadding=2 cellspacing=2 class="outerborder" width=90%>
<cfelse>
<table cellpadding=2 cellspacing=2 class="outerborder"  width=65%>
</cfif>
<tr>
	<td class="border">Count</td>
    <td nowrap class="borderq">Comment</td> 
	<td nowrap class="borderq">To</td>
    <td nowrap class="borderq">cc</td>
    <td nowrap class="borderq">Date</td>
	<cfif printerFriendly EQ "No">
    <td nowrap class="borderq">View</td>
	</cfif>
</tr>
<cfoutput query="getEmail">
<tr>
	<td valign="top" class="border" valign="top">#loopcount#. </td>
    <td class="border" valign="top">#comment#</td>
	<td class="border" valign="top"><font style="font-size: 9px;">
	#Replace(msgTo,",",",<br>","all")#</font></td>
    <td class="border" valign="top">
	<font style="font-size: 9px;">
	#Replace(msgCC,",",",<br>","all")#</font></td>
    <td valign="top" class="border" nowrap>#Dateformat(sentDate,"MM/DD/YY")# #timeformat(sentdate,"hh:mm tt")#</td>
	<cfif PrinterFriendly EQ "No">
    <td valign="top" class="border">
	
	<!--- a  href="##" onClick="Javascript: popitup('index.cfm?fuseaction=app.AuditEmail&Menu=Admin&submenu=audit&id=#id_emailLog#','Audit Email','toolbar=no, directories=no, location=no, status=yes, menubar=no, resizable=yes, scrollbars=yes,width=600,height=450'); return false"><img src="images/ActobatOnWhite.png" border=0></a --->
	<a href="index.cfm?fuseaction=app.AuditEmail&Menu=Admin&submenu=audit&id=#id_emailLog#"><img src="images/ActobatOnWhite.png" border=0></a>
	</td>
	</cfif>
</tr>
<cfset loopcount=loopcount+1>
</cfoutput>
</table>
<cfelse>
No email log found for this ARA.

</cfif>
