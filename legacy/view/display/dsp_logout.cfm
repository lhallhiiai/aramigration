<cfoutput>
<!--- cfdump var="#session#" format="text" --->

<cfset tmpVar = StructClear(session)>
<!--- cfdump var="#session#" format="text" --->
<cflocation addtoken="false" url="index.cfm">
</cfoutput>