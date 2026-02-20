<cfoutput>
<tr>
	<td>&nbsp;</td>
	<td nowrap class="grad"><a href="#self#?fuseaction=app.home&activesort=id_ara&Menu=home" class="embed">ID & Revision</a>
	<cfif activeSort EQ 'id_ara'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.home&activesort=id_status&Menu=home" class="embed">State</a>
	<cfif activeSort EQ 'id_status'><img src="images/sort.png"></cfif></td>
	<td class="grad" width=100>Awaiting Approval By</td>
	<td class="grad"><a href="#self#?fuseaction=app.home&activesort=JamisNo&Menu=home" class="embed">Project ID ##</a>
	<cfif activeSort EQ 'JamisNo'><img src="images/sort.png"></cfif>
	</td>
	<td class="grad"><a href="#self#?fuseaction=app.home&activesort=Title&Menu=home" class="embed">Title</a>
	<cfif activeSort EQ 'Title'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.home&activesort=CustomerName&Menu=home" class="embed">Customer</a>
	<cfif activeSort EQ 'CustomerName'><img src="images/sort.png"></cfif></td>
	<!--- td class="grad"><a href="#self#?fuseaction=app.home&activesort=StartDate&Menu=home" class="embed">Req'd Start</a>
	<cfif activeSort EQ 'StartDate'><img src="images/sort.png"></cfif></td --->
	
	<td class="grad"><a href="#self#?fuseaction=app.home&activesort=amountTotal&Menu=home" class="embed">Amount Total</a>
	<cfif activeSort EQ 'AmountTotal'><img src="images/sort.png"></cfif></td>
	
	<td class="grad">
		<img src="images/SmDelete.png">
	</td>
</tr>
</cfoutput>
