<cfif isDefined('url.aid')>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cfelse>
	<cfset id_ara=8>
</cfif>
<cfset docs=#AttachmentStatus(id_ara,id_cat)#>
<cfoutput>
<cfif isprint EQ "No"><p class="smtitle">REQUIRED INFO</p></cfif>
<p class="aratitle">#HaveCount# of #total_Cnt# required documents have been provided. <cfif isPrint EQ "Yes">All documents are accessible from the ARA Website</cfif></p>
<br><br>
<cfset row=1>
<table cellpadding=2 cellspacing=2 class="border">
<td></td>
<td class="border"><font class="tiny">Have <br>or Need</td>
<td class="border">Required Documents</td>
<td class="border">Upload Doccuments</td>
</tr>

<cfloop index="Need" list="#NeedList#">
<tr>
	<td valign="top" class="border">#row#.</td>
	<cfquery name="CatDocs" datasource="#Application.dsn#">
		Select * from attachments a, users u, role r
		where a.id_ara=#id_ara#
		and a.filetype LIKE '%#need#%'
		and a.id_user=u.id_user
		and u.id_role=r.id_role
	</cfquery>
	<td valign="top" align="center" class="border">
		<cfif Catdocs.recordcount EQ 0>
			<img src="images/SmGreyMinus.png">
		<cfelse>
			<img src="images/SmCheck.png">
		</cfif>
	</td>
	<cfset this_cat=#ListGetat(NeedDesc,row)# />
	<td valign="top" class="border">#this_cat#</td>
	<td class="border">
	<cfif Catdocs.recordcount EQ 0> --
	<cfelse>
	<ul>
		<cfloop query="CatDocs">
		<li class="doc"> <a class="embed" href="#self#?fuseaction=app.getFile&id_attachment=#id_attachment#">#FileName#</a>
		 (Size #numberformat(Filesize,",")#), <br>Desc: #Description#<br>
		  Date Uploaded: #Dateformat(Date,"MM/DD/YY")# #Timeformat(Date,"hh:mm tt")#, 
		  by #Empname#, Role: #Rolename#
		  
		 </cfloop>
		 </ul>
	</cfif>
	</td>
	<cfset row=row+1>
</tr>

</cfloop>
</table>
</cfoutput>