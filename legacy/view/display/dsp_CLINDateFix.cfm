<!--- A temp script to correct end_date not being properly converted --->

<cfquery Name="ClinList"  result="this" datasource="#Application.dsn#">
	SELECT    a.id_clins,a.id_ara,a.clinNo,a.expirationDate,b.clin_no, substring(cast(b.end_date as varchar(8)), 5,2)+'/'+substring (cast(b.end_date as varchar(8)),7,2)+'/'+substring(cast(b.end_date as varchar(8)),1,4) as JamisEndDate
	FROM         ara.dbo.clins a,cae_ods.jobcost.t_clin_master b
	where a.clinNo=b.clin_no
	and a.expirationdate <> substring(cast(b.end_date as varchar(8)), 5,2)+'/'+substring (cast(b.end_date as varchar(8)),7,2)+'/'+substring(cast(b.end_date as varchar(8)),1,4) 
	Order by clinNo
</cfquery>
<cfdump format="text" top=1 var="#this#">
<p class="Title">Temporary script to fix CLIN dates</p>
<cfset loopcount=1>
<ol>
<cfset CLINLst="">
<cfoutput maxrows=100 query="ClinList">
<li>Clin ID: #id_clins#, #CLINNo#, Changing date from #dateformat(ExpirationDate,"MM/DD/YY")# to #JamisEndDate#</li>
<cfquery name="FixDate" datasource="#Application.dsn#">
	Update CLINs
	Set expirationDate='#Dateformat(JamisEndDate,"mm/dd/yy")#'
	where id_clins=#id_Clins#
</cfquery>
<cfset ClinLst=ListAppend(CLINLst,ClinNo)>



</cfoutput>
</ol>
<cfoutput>#ClinLst#</cfoutput>
