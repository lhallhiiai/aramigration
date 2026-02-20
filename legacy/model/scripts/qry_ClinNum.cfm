<cfsetting enablecfoutputonly="true">
<cfparam name="q" default="" />
<cfquery name="InARA" datasource="#Application.DSN#">
	Select ClinNO
	from Clins
	where id_ara=#URL.id_ARA#
</cfquery>
<cfset HaveClins=#QuotedValueList(InARA.ClinNo)#>



<cfquery name="gCLIN" datasource="#application.dsn#">
	SELECT *
	FROM ara_CP_Data
	
	WHERE  (
		CLIN LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
	)
	and COSTPT_NO = <cfqueryparam cfsqltype="cf_sql_varchar" value="#URL.jamisNo#">
	<cfif #len(haveClins)# GT 0>
		and CLIN NOT IN (#PreserveSingleQuotes(HaveClins)#)
	</cfif>
	ORDER BY CLIN
</cfquery>

<cfset loopcount=1>

<cfif gClin.recordcount GT 0>
	<cfoutput query="gCLIN">
		#CLIN#, #rereplace(PROJ_NAME2,'[^\w]', ' ', 'all')# [End: #end_dt#] [Group:#GRP#] [PM:#PM#]  #chr(10)#
		<cfset loopcount=loopcount+1>
	</cfoutput>
<cfelse>
   <cfoutput>Not Found.</cfoutput>
</cfif>
