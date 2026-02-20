
<cfquery name="getEmail" datasource="#Application.DSN#">
	select * from emailLog where id_emailLog = '#url.id#'
</cfquery>

<cfoutput query="getEmail">
<table><tr>
	<td nowrap class="borderq">#id_ara#</td>
	<td class="border">#msgTo#</td>
    <td class="border">#msgCC#</td>
    <td class="border">#sentDate#</td>
    <td class="border"><cfheader name="content-disposition" value="attachment; filename=ARAEmail.pdf">
<cfcontent type="application/pdf" variable="#message_pdf#">
</td>
</tr>
</table>
</cfoutput>
