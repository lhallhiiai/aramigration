<cfset smtitle="Ara Archives">
<cfset title="Cancelled, Exported, Negated, Negated Exported, Early Start Complete">
<cfparam name="activeSort" default="id_status">
<cfset maxrows=50>
<cfparam name="startrow" default=1>
<cfparam name="prevstart" default=1>

<cfoutput>
<p class="smtitle">#smtitle#</p>
<p class="title">#title#</p>
</cfoutput>

<cfquery name="Archives" datasource="#Application.DSN#">
	Select * from v_ara
	where
	<cfif not isdefined('whichstate')>
	id_status in (10,13,14,15,16)
	</cfif>
	order by #activeSort#, reference
</cfquery>

<!---  *********************************************************************  --->
<!---                              NEXT AND PREVIOUS                          --->
<!---  *********************************************************************  --->
<cfoutput>
<cfif Archives.recordcount LT maxrows>
	<p>#Archives.Recordcount# ARAs.</p>  
<cfelse>
	<p>
	<cfif startrow GT 1><!--- Show previous if not on on first page --->
	<cfset prevStart=val(startrow-maxrows)>
	<a class="embed" href="index.cfm?fuseaction=app.archivelist&startrow=#prevstart#&activeSort=#activeSort#">Previous #maxrows#</a>
	&nbsp;&nbsp;|&nbsp;&nbsp;
	</cfif>
	#startrow# to #val(startrow+maxrows-1)# of #Archives.recordcount#
	<cfif val(startrow+maxrows) LTE Archives.recordcount><!--- Have more pages to show --->
	&nbsp;&nbsp;|&nbsp;&nbsp;
	<cfset nextStart=Val(startrow+maxrows)>
	<a class="embed" href="index.cfm?fuseaction=app.archivelist&startrow=#nextstart#&activeSort=#activeSort#">Next #maxrows#</a>
	</cfif>
	
	</p>
	
</cfif>
</cfoutput>
<table cellpadding=2 width=100% cellspacing=2 class="border">
<!--- *****                          Table Header                    ***** --->
<tr>
	<td>&nbsp;</td>
	<td nowrap width=105 class="grad"><a href="#self#?fuseaction=app.archivelist&activesort=reference" class="embed">ID & Revision</a>
	<cfif activeSort EQ 'id_ara'><img src="images/sort.png"></cfif></td>
	<td class="grad" width=94><a href="#self#?fuseaction=app.archivelist&activesort=state" class="embed">State</a>
	<cfif activeSort EQ 'id_status'><img src="images/sort.png"></cfif></td>
	
	
	<td class="grad"><a href="#self#?fuseaction=app.archivelist&activesort=Grp" class="embed">Group</a>
	<cfif activeSort EQ 'grp'><img src="images/sort.png"></cfif>
	</td>
    <td class="grad"><a href="#self#?fuseaction=app.archivelist&activesort=div" class="embed">Div</a>
	<cfif activeSort EQ 'div'><img src="images/sort.png"></cfif>
	</td>
	<td class="grad"><a href="#self#?fuseaction=app.archivelist&activesort=jamis" class="embed">JAMIS ##</a>
	<cfif activeSort EQ 'JamisNo'><img src="images/sort.png"></cfif>
	</td>
	<td class="grad"><a href="#self#?fuseaction=app.archivelist&activesort=title" class="embed">Title</a>
	<cfif activeSort EQ 'Title'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.archivelist&activesort=Customer" class="embed">Customer</a>
	<cfif activeSort EQ 'CustomerName'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.archivelist&activesort=AmountTotal" class="embed">Amount Total</a>
	<cfif activeSort EQ 'AmountTotal'><img src="images/sort.png"></cfif></td>
</tr>






<cfoutput query="Archives" startrow="#startrow#" maxrows="#maxrows#">
<tr>
	<td class="border">#startrow#.</td>
	<td nowrap width=105 class="border"><a href="#self#?fuseaction=app.ARA_PM&AID=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#&Menu=ARA_Detail" class="embed">#reference#</a>
	</td>
	<td class="border" width=94>#StatusName#
	</td>
	
	
	<td class="border">#Grp#
	
	</td>
    <td class="border">#division#
	
	</td>
	<td class="border">#jamisNo#
	
	</td>
	<td class="border">#Title#
	</td>
	<td class="border">#CustomerName#
	</td>
	<td class="border" align="right">
	#dollarformat(AmountTotal)#
	</td>
	<cfset startrow=startrow+1>
</tr>

</cfoutput>

	
</table>
	