
<table cellpadding=0 cellspacing=0 width=95%>
<tr>
	<td>
<cfif session.id_role EQ 1 or session.id_role EQ 2><!--- system admin or fin admin --->
	<p class="smtitle">ARA JAMIS EXPORT</p>
</cfif>
</td>
</tr></table>
<cfinclude template="dsp_messages.cfm">



<table cellpadding=10 cellspacing=10 width=95%>
 <tr>
    <td>
  <br />
    <form method="post" action="index.cfm?fuseaction=app.createjamisexport&jamis_name=ALIN">
        <input style="font-family:tahoma;font-size:16px;width:400px;" type="submit" name="btnSubmit" id="btnSubmit0" value="Export All ALIN ARAs" />
    </form>
    </td>
 </tr>
 <tr>
 	<td>
    <form method="post" action="index.cfm?fuseaction=app.createjamisexport&jamis_name=WCGS">
        <input style="font-family:tahoma;font-size:16px;width:400px;" type="submit" name="btnSubmit" id="btnSubmit0" value="Export All WCGS ARAs" />
    </form>
   	</td>
 </tr>
 <tr>
 	<td>
    <form method="post" action="index.cfm?fuseaction=app.createjamisexport&jamis_name=WCON">
        <input style="font-family:tahoma;font-size:16px;width:400px;" type="submit" name="btnSubmit" id="btnSubmit0" value="Export All WCON ARAs" />
    </form>
    </td>
 </tr>
 <!---
 <tr>
 	<td>
    <form method="post" action="index.cfm?fuseaction=app.createjamisexport&jamis_name=CANA">
        <input style="font-family:tahoma;font-size:16px;width:400px;" type="submit" name="btnSubmit" id="btnSubmit0" value="Export All CANA ARAs" />
    </form>
  </td>
</tr>
--->

<tr>
 	<td>
    <form method="post" action="index.cfm?fuseaction=app.createjamisexport&jamis_name=CAND">
        <input style="font-family:tahoma;font-size:16px;width:400px;" type="submit" name="btnSubmit" id="btnSubmit0" value="Export All CAND ARAs" />
    </form>
  </td>
</tr>
</table>
