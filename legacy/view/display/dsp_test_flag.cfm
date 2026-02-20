<cfif session.test_flag EQ 1>
	<cfset session.test_flag=0>
<cfelse>
	<cfset session.test_flag=1>
</cfif>
<!--- cfdump var="#returnto#" format="text"><cfabort --->
<cfoutput>
<cflocation url="index.cfm?app.home" addtoken="No"> 

</cfoutput>