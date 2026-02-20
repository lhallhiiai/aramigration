
<cfinclude template="../../model/m_forms/qry_docList.cfm">

<cfif doclist.recordcount GT 0>
	<p class="subtitle">Document List <cfif isPrint EQ 'No'>(Click Doc Name to Open)</cfif></p>
	<ol>
	<cfoutput query="DocList">
	<cfset aid=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
	<li <cfif isdefined("thisID") and thisID EQ id_attachment>class="hilite"</cfif>><a class="embed" href="#self#?fuseaction=app.getFile&id_attachment=#id_attachment#&aid=#aid#">#FileName# </a> (Size #numberformat(Filesize,",")#), Desc: <b>#Description#</b><br>
	Date Uploaded: #Dateformat(Date,"MM/DD/YY")# #Timeformat(Date,"hh:mm tt")#, by #Empname#, Job Title: #jobtitle#
	<br>Attachment Contains:
	<cfquery name="Info_type" datasource="#application.dsn#">
		SELECT * from attach_checklist
		where id_attachtype in (#filetype#)
	</cfquery>
	<!--- cfdump var="#Info_type#" format="text" --->

	<cfset a_cnt=1> 
	<cfif info_type.recordcount GT 0>
	<cfloop query="info_Type">
		<b>#short_desc#</b> <cfif (info_type.recordcount GT 1) AND (a_cnt LT info_type.recordcount)>&nbsp;&nbsp;|&nbsp;&nbsp;</cfif>
		<cfset a_cnt=a_cnt+1>
	</cfloop>
	<cfelse>
		Additional Information
	</cfif>
<!--- cfif (session.id_user EQ Doclist.Upload_user) AND (isdefined("formOrview") and formorView EQ "form") AND ((id_status LT 6) or (id_status EQ 8) or (id_status EQ 9))><!--- Only te user that uploaded the document should be able to delete it --->	<br>
--->
<cfif (session.id_user EQ Doclist.Upload_user) AND (isdefined("formOrview") and formorView EQ "form")>
	<cfif NOT isdefined('Session.NextApprover')>	
		<cfset Session.NextApprover = "">
	</cfif>
	<cfif (Find(id_status,"1,8,9") and (PM_ID EQ Session.id_user) OR (PM_ID EQ session.delegators)) OR
		  (find(id_status,"2,3,8,9") and (contract_ID EQ session.id_user) OR (Contract_id EQ Session.delegators)) OR
		  (find(id_status,"4,5,8,9") and (controller_ID EQ session.id_user) OR (controller_ID eq session.delegators)) OR
		  (find(id_status,"6") and ((session.id_user EQ id_user) AND (session.nextapprover_d EQ session.oprid))) OR
		  (Session.Oprid EQ Session.NextApprover)
		  >
		<br>
		
		<img src="images/SmDelete.png">&nbsp;&nbsp;<a class="embed" href="#self#?Fuseaction=app.ARA_docs&Action=Delete&returnto=#returnTo#&id_attachment=#id_attachment#&aid=#aid#">Delete</a>

		<br>
	</cfif>
</cfif>
	<br><br>
	</cfoutput>
	
</ol>
<cfelse>
	<cfif isDefined('returnTo') and (Returnto EQ 'PM')>
	<p><b>Optional Documents:</b> No additional/optional documents have been uploaded.</p>
	<cfelse>
	<p><b>DOCUMENTS:</b> 
		No documents have been uploaded.
	</cfif>
</cfif>