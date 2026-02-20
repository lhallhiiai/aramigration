<cfparam name="thisid" default="">
<cfif isDefined('url.aid')>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cfelse>
	<cfoutput>ERROR: Encrypted ara id was not passed.</cfoutput><cfabort>
</cfif>
<cfset docs=#AttachmentStatus(id_ara,id_cat)#>
<cfoutput>
<cfif isprint EQ "No"><p class="subtitle">REQUIRED INFO</p></cfif>
<p>#HaveCount# of #total_Cnt# required documents have been provided. <cfif isPrint EQ "Yes">All documents are accessible from the ARA Website.</cfif></p>
</cfoutput>
<cfset row=1>
<cfinclude template="_docList.cfm">