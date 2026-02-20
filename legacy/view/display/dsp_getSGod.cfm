
<!--- 
<script type="text/javascript">
$("document").ready(function() {
	$("#group").hide("normal");
});
</script>

<script type="text/javascript">
function group()
{
    $("#group").show("normal");
}
</script>

--->

<!--- table cellpadding="2" cellspacing="2">
<tr>
<form name="GetOrg">
<td valign="top">
<cfset sctrs=#get_sector()#>
Sector<br><br>
<select class="inputtext" onChange="group();" name="ara_sector">
	<option value="">-- Select Sector --</option>
	<cfoutput>
	<cfloop query="get_Sector">
		<option value="#sctr#">#sctr#</option>
	</cfloop>
	</cfoutput>
</select>
</td>

<td valign="top">
<div id="group">
Group<br><br>
<cfset grps=#get_group('EISS')#>
<select class="inputtext" onChange="ops();" name="ara_group">
	<option value="">-- Select Group --</option>
	<cfoutput>
	<cfloop query="get_group">
		<option value="#grp#">#grp#</option>
	</cfloop>
	</cfoutput>
</select>

</div>
</td>
</tr>
</form>
</table --->
<br><br>
<!--- Using CF Bind --->


<cfform name="bindselect">


<input type="hidden" name="sector_hidden" id="sector_hidden" value="">


<cfselect class="inputtext" name="sector" id="sector" bind="cfc:ara_fb5.view.display.cfcs.bindselect.get_sector(orgcode={sector_hidden})"  bindonload="true">
</cfselect>

<cfselect class="inputtext" style="width: 60px;" name="group" id="group" bind="cfc:ara_fb5.view.display.cfcs.bindselect.get_group(orgcode={sector})">
</cfselect>

<cfselect class="inputtext" style="width: 60px;" name="operation" id="operation" bind="cfc:ara_fb5.view.display.cfcs.bindselect.get_operation(orgcode={group})">
</cfselect>

<cfselect  class="inputtext" style="width: 300px;" name="division" id="division" bind="cfc:ara_fb5.view.display.cfcs.bindselect.get_division(orgcode={operation})">
</cfselect>

</cfform>