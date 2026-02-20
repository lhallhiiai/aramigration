

<cfform name="bindselect">


<input type="hidden" name="sector_hidden" id="sector_hidden" value="">


<cfselect name="sector" id="sector" bind="cfc:cfcs.bindselect.get_sector(orgcode={sector_hidden})"  bindonload="true">
</cfselect>


<cfselect name="group" id="group" bind="cfc:cfcs.bindselect.get_group(orgcode={sector})">
</cfselect>


<cfselect name="operation" id="operation" bind="cfc:cfcs.bindselect.get_operation(orgcode={group})">
</cfselect>

<cfselect name="division" id="division" bind="cfc:cfcs.bindselect.get_division(orgcode={operation})">
</cfselect>

</cfform>