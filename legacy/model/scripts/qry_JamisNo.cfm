<cfsetting enablecfoutputonly="true">
<cfparam name="q" default="" />

	  
<cfquery name="gJamis" datasource="#application.dsn#">
select distinct COSTPT_NO as JamisNumber, PROJ_NAME as AgreementTitle, PROJ_NAME as AgreementTitle2, COSTPT_NO as ContractNumber, GRP, CUST_NAME  
from      ARA_CP_DATA
where      1=1 
AND (COSTPT_NO LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
        OR PROJ_NAME LIKE <cfqueryparam value="%#URL.q#%" cfsqltype="cf_sql_varchar" />
            )
Order By    COSTPT_NO,PROJ_NAME, GRP
</cfquery>


<cfif (Len(URL.q) GT 2) AND (gJamis.RecordCount EQ 0)>
	<cfoutput>'#url.q#' Not Found</cfoutput>

<cfelse>
	<cfset loopcount=1>
	<cfoutput query="gJamis">
		 #JamisNumber#, Title: #AgreementTitle# - #AgreementTitle2# , #Replace(CUST_NAME, ",","")#, #GRP# #chr(10)#
		<cfset loopcount=loopcount+1>
	</cfoutput>
</cfif>