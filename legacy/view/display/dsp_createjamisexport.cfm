
<table cellpadding=0 cellspacing=0 width=95%>
<tr>
	<td>
<cfif session.id_role EQ 1 or session.id_role EQ 2><!--- system admin or fin admin --->
	<p class="smtitle">ARA CostPoint EXPORT</p>
</cfif>
</td>
</tr></table>
<cfinclude template="dsp_messages.cfm">
<cfquery name="runExport" datasource="#Application.dsn#">
	exec p_build_ARA_export @v_instance = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.jamis_name#">
</cfquery>
<table bgcolor="#EEEEEE" width="95%">
    <tr>
    	<td style="border:thin solid #000000;text-align:center;">
      	<span style="font-size:14px;">The JAMIS export file has been created.  It has been emailed to Finance for upload to JAMIS.</span>
      </td>
    </tr>
</table>
