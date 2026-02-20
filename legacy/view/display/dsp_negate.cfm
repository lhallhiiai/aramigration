<!--- **********************************************************  --->
<!---       ARA Contract Information                             --->
<!--- ********************************************************** --->

<cfparam name="Submenu" default="ARA_Detail">
<cfparam name="FormorView" default="Form">
<cfparam name="thiscType" default="">
<cfparam name="ThisCustType" default="">
<cfparam name="thisid" default="">
<cfparam name="thisJob" default="2">
<cfparam name="UseCheck" default="yes">
<cfparam name="isSaved" default="1">
<cfparam name="OtherType" default="">
<cfparam name="PCCostAuth" default=0>

	
<cfquery name="clins" datasource="#Application.dsn#">
	SELECT  * 
	FROM     ara INNER JOIN
			 clins ON ara.id_ara = clins.id_ara
			 where 1=1 and ara.id_ara=#url.id_ara# and negate=0	
	ORDER BY ClinNo
</cfquery>

	
	
<cfif not isdefined("URL.id_clins") and clins.recordcount GT 0>	
	<table width=90% align="center" cellpadding=2 cellspacing=2  cellspacing=0>
		<tr bgcolor="#EEEEEE">
			<th colspan="8" align="center"><cfoutput>ARA Negation for ARA ###url.id_ara#</cfoutput></th>
		</tr>
		<tr bgcolor="#EEEEEE">
			<th>&nbsp;</th>
			<th class="border">CLIN</th>
			<th class="border">Expiration</th>
			<th class="border">Description</th>
			<th class="border" align="right">Cost Funding</th>
			<th class="border"align="right">Fee Funding</th>
			<th class="border" align="right">Total</th>
			<th class="border" align="right">&nbsp;</th>
		</tr>
		<cfset grand_total=0>
		<cfset costfund_total=0>
		<cfset FeeFund_total=0>
		<cfset loopcount=1>
			
	<cfoutput query="clins">
		<tr>
			<td width=18 class="border">#loopcount#.</td>
			<td class="border">#clinNo#</td>		
			<td class="border">#dateformat(expirationDate,"MM/DD/YY")#</td>
			<td class="border">#Description#</b></td>
			<td class="border" align="right">$#numberformat(costFunding,"9,999.99")#</td>
			<td class="border" align="right">$#numberformat(feeFunding,"9,999.99")#</td>
			<td class="border" align="right">$#numberformat(total,"9,999.99")#</td>
			<td class="border" align="center"><a class="embed" href="index.cfm?fuseaction=app.Negation&id_clins=#id_clins#&id_ara=#url.id_ara#&returnTo=home" onclick="return confirm('Are you sure you want to NEGATE THE FUNDING ON THIS CLIN?');"><strong>Negate</strong></a></td>
		</tr>
		<cfset costFund_total=val(costFund_total + costFunding)>
		<cfset FeeFund_total=val(FeeFund_total + feefunding)>
		<cfset grand_total=val(grand_total + total)>
		<cfset loopcount=Val(loopcount + 1)>
	</cfoutput>

	</table>


<cfelseif isdefined("URL.id_clins")>
	<cfquery name="clins" datasource="#Application.dsn#">
		SELECT  * 
		FROM     ara INNER JOIN
				 clins ON ara.id_ara = clins.id_ara
				 where 1=1 and ara.id_ara=#url.id_ara# and negate = 0 	
		ORDER BY ClinNo
	</cfquery>
			
	<cfquery name="updateClins" datasource="#Application.dsn#">
		Update CLINS set negate=1 where id_clins = '#URL.id_clins#' 
	</cfquery>
	
	<cfif clins.recordcount GT 1>
		<cfquery name="updateStatus" datasource="#Application.dsn#">
			Update ara set id_status = 18 where id_ara = '#URL.id_ara#' 
		</cfquery>
	<cfelse>
		<cfquery name="updateStatus" datasource="#Application.dsn#">
			Update ara set id_status = 14 where id_ara = '#URL.id_ara#' 
		</cfquery>
	</cfif>
	
	
	<cfquery name="Log" result="thisLog"  datasource="#Application.dsn#">
	  	Insert Into araAppLog
		(id_ara,
		id_user,
		id_job,
		id_status,
		isRejection,
		Comment,
		ApprovalDate,
		cycle,
		id_reason,
		Rej_areas
		<cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
				,oprid_delegateFrom
		</cfif>
		<cfif isDefined('oprid_delegateTo') and (oprid_delegateTo NEQ "")>
				,oprid_delegateTo
		</cfif>
		)
		
		VALUES
		(<cfqueryparam cfsqltype="cf_sql_integer" value="#url.id_ara#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
		<cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_job#">,
		<cfif clins.recordcount GT 1>18,<cfelse>14,</cfif>
		'False',
		'CLIN #clins.clinNo# (#URL.id_clins#) Negated by #session.oprid#, #Session.jobtitle#',
		<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
		'',
		'',
		''
		<cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#oprid_delegateFrom#">
		</cfif>
		<cfif isDefined('oprid_delegateFrom') and (oprid_delegateTo NEQ "")>
				,<cfqueryparam cfsqltype="cf_sql_varchar" value="#oprid_delegateTo#">
		</cfif>
		)
		
	  </cfquery>
			
	 <!--- update clin status --->		
	 

<!---  Send Email --->
    <!--- retrieve all ara infomation --->
	<cfinclude template="../../model/m_ara/qry_ara.cfm">
	<cfset AID=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
	<cfquery name="Team" datasource="#application.dsn#">
	Select empname
	from v_users
	where id_user in ('#id_pm#','#id_contract#', '#id_controller#')
	</cfquery>
	
	<cfset rejector=#session.empname#>
	<!---<cfdump var="#team#" format="text">--->
	<cfset team=Valuelist(Team.empname)>
	<cfset pm_nm=ListGetAt(Team,1)>
	<cfset contract_nm=ListGetAt(Team,2)>
	<cfset controller_nm=ListGetAt(Team,3)>
	
	<cfset Subject="ARA #Reference#: Negated by #rejector#">
	<cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
		<cfset Subject="#subject# [Delegated to by #oprid_delegateFrom#]">
	</cfif>
	<cfset shortDesc="">
	<cfif clins.recordcount GT 1>	
	<cfset intro="ARA Partially Negated">
	<cfset MsgText="<b>ARA #Reference# has been partially negated by #session.empname#.">  
	<cfelse>
	<cfset intro="ARA Negated">
	<cfset MsgText="<b>ARA #Reference# has been negated by #session.empname#.">
	</cfif>
	
	<cfinclude template="../../model/m_emails/mail_Negate.cfm">
	<cfif clins.recordcount GT 1>
	<cfset confirmMsg="ARA #Reference# has been partially negated.">
	<cfelse>
		<cfset confirmMsg="ARA #Reference# has been negated.">
			</cfif>
	  
<cfswitch expression="#returnTo#">
<cfcase value="home">  
	<cflocation url="index.cfm?confirmMsg=#confirmMsg#"  ADDTOKEN="No">
</cfcase>

<cfdefaultcase>
	<cflocation url="index.cfm?Fuseaction=#returnto#&AID=#AID#&confirmMsg=#confirmMsg#"  ADDTOKEN="No">
</cfdefaultcase>
</cfswitch>
</cfif>






