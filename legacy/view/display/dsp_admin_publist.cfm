
<p class="smtitle">admin</p>
<p class="title">Announcement Email List</p>

<cfset emailList="">
<cfset rowcount=0>
<cfparam name="batch" default=1>
<cfparam name="startrow" default=1>
<cfparam name="maxrows" default=700>
<p>Total Active Users: <cfoutput>#Publist.Recordcount#</cfoutput></p>
<p>Batch <cfoutput>#batch#</cfoutput></p>
<cfoutput query="Publist" startrow="#startrow#" maxrows="#maxrows#">
	<cfif rowcount EQ 4>
		<!---<cfset emailList=ListAppend(emaillist,"<br>"," ")>--->
		<cfset emailList="#emailList#" & "<br>">
		<cfset rowcount=0>
	</cfif>
	<cfset this_email="#publist.email#">
	<cfset emailList=ListAppend(emailList,this_email,"; ")>
	<cfset rowcount=val(rowcount+1)>
	
	
</cfoutput>
<table width=500><tr><td>
<cfoutput>
#emailList#
</cfoutput>

<br>
<cfset batch=val(batch+1)>
<cfset startrow=val(startrow+maxrows)>
<cfoutput>
<a href="index.cfm?fuseaction=app.publist&Menu=Admin&submenu=emailist&batch=#batch#&startrow=#startrow#">Next #maxrows#</a>
</cfoutput>
</td></tr></table>