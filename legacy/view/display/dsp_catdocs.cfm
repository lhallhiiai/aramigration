<cfparam name="Printerfriendly" default="No">
<!--- Help page for the administration of Users --->
<cfif printerfriendly EQ "No">
<table cellpadding=0 cellspacing=0 border=0 width=90%>
<cfelse>
<table cellpadding=0 cellspacing=0 border=0 width=65%>
</cfif>
<tr>
	<td>
	<p class="smtitle">Administration</p>
	<p class="title">Documentation by Category</p>
	</td>
<cfif Printerfriendly EQ "No">
<td valign="top" nowrap align="right">
<a class="embed" href="index.cfm?<cfoutput>#CGI.QUERY_STRING#</cfoutput>&PrinterFriendly=Yes">Printer Friendly</a>&nbsp;&nbsp;
</td>
</cfif>
<td valign="top" width=25 align="right">
<img src="images/LeftArrow.gif" border=0 align="left" >&nbsp;<a class="embed" href="javascript: history.go(-1)">Back</a>
</td></tr></table>

<cfquery name="getCat" datasource="#Application.dsn#">
	select * from category 
	where id_cat <> 3
	order by id_cat
</cfquery>
<cfset Id_cats=valueList(GetCat.id_cat)>
<cfset catNames=valueList(GetCat.catName)>
<cfoutput>
<cfset loopcount=1>
<cfloop index="c" list="#id_cats#">
	<cfset catname=listgetat(Catnames,loopcount)>
	
	<cfquery name="reqd" datasource="#application.dsn#">
		select * from attach_checklist
		where catID_List Like '%|#c#|%'
		and  who IN ('CM','Con')
	</cfquery>
	<cfset docnames=Valuelist(reqd.short_desc)>
	<p style="font-weight:bold;">#catname# - #reqd.recordcount# docs</p>
	<ol>
	<cfloop index="n" list="#docnames#">
		<li>#n#</li>
	</cfloop>
	</ol>
	<cfset loopcount=#loopcount# +1>
</cfloop>
</cfoutput>

		 