
<cfquery name="ara" datasource="#application.dsn#">  
		Select * from v_ara
		where (1=1)
		<cfif #url.expirationDate# NEQ "">
			and convert(varchar(20), startdate, 101) like '#expirationDate#%'
		</cfif>
		<cfif #url.id_status# NEQ "">
			and id_status= #id_status#
		</cfif>
		<cfif #url.id_user# NEQ "">
			and (id_user = #id_user# or id_pm = #id_user# or id_contract = #id_user# or id_controller = #id_user#)
		</cfif>
        <cfif #url.JamisNo# NEQ "">
			and jamisNo like '%#JamisNo#%'
		</cfif>
        <cfif #url.id_cat# NEQ "">
			and id_cat = #id_cat# 
		</cfif>
        <cfif #url.id_ara# NEQ "">
			and reference like '%#id_ara#%'
		</cfif>
        <cfif #url.customername# NEQ "">
			and customername like '%#customername#%'
		</cfif>
        <cfif #url.sectorName# NEQ "">
			and sector = '#sectorName#'
		</cfif>
        <!---<cfif #url.clinNo# NEQ "" and len(listClin) NEQ 0>
			and id_ara in (#listClin#)
		</cfif>--->
        <cfif #url.groupName# NEQ "">
			and division = '#groupName#'
		</cfif> 
        <cfif #url.amount# NEQ "">
			and (amountTotal like '%#amount#%' or totalAnticipated like '%#amount#%') 
		</cfif>        
		Order BY id_ara
	</cfquery>

<cfdocument format="pdf" orientation="landscape"> 
<cfdocumentsection>
<cfoutput>
<table cellpadding=2 width=100% cellspacing=2 border=1 class="border">
<tr>
	<td class="grad">&nbsp;</td>
	<td nowrap class="grad">ID & Revision</td>
	<td class="grad">Group</td>
	<td nowrap class="grad">CLINS</td>
	<td class="grad">PROJECT ID ##</td>
	<td class="grad">Title</td>
	<td class="grad">Customer</td>
	<td class="grad">Expiration</td>
	<td class="grad">Amount Total</td>
	<td class="grad">Status</td>
	
</tr>
</cfoutput>
<cfset count=1>
<cfoutput query="ara">
<tr>
	<td class="border">#count#.</td>
	
	<td nowrap class="border">#reference#</td>
	<td nowrap class="border">#Division#</td>
	<td class="border">
    
		<cfquery name="CLINfo" datasource="#application.dsn#">
			SELECT * 
			FROM CLINS
			WHERE id_ara = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id_ara#">
		</cfquery>
		#clinfo.clinno#
	</td>
	<td nowrap class="border">#JamisNo#</td>
	<td class="border">#title#</td>
	<td class="border">#customerName#</td>
	<td class="border">#Dateformat(expirationDate,"MM/DD/YY")#</td>
	<td class="border">#dollarformat(amountTotal)#</td>
	<td class="border">#statusName#</td>
	<cfset count=count+1>
</tr>
</cfoutput>
</cfdocumentsection>
</table>
</cfdocument>
