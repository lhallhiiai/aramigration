<cfset id_ara=140>
<cfinclude template="../../model/m_forms/qry_docList.cfm">
	<p class="subtitle">Document List (Click Doc Name to Open)</p>
	<ol>
	<cfoutput query="DocList">
	<cfset aid=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
	<li <cfif thisID EQ id_attachment>class="hilite"</cfif>><a class="embed" href="#self#?fuseaction=app.getFile&id_attachment=#id_attachment#&aid=#aid#">#FileName# </a> (Size #numberformat(Filesize,",")#), Desc: #Description#<br>
	Date Uploaded: #Dateformat(Date,"MM/DD/YY")# #Timeformat(Date,"hh:mm tt")#, by #Empname#, Role: #Rolename#
	<br>Attachment Contains:
	<cfquery name="Info_type" datasource="#application.dsn#">
		SELECT * from attach_checklist
		where id_attachtype in (#filetype#)
	</cfquery>

	<cfset a_cnt=1> 
	<cfloop query="info_Type">
		<b>#short_desc#</b> <cfif (info_type.recordcount GT 1) AND (a_cnt LT info_type.recordcount)>&nbsp;&nbsp;|&nbsp;&nbsp;</cfif>
		<cfset a_cnt=a_cnt+1>
	</cfloop>
	<br>
	<img src="images/SmDelete.png">&nbsp;&nbsp;<a class="embed" href="#self#?Fuseaction=app.ARA_docs&Action=Delete&id_attachment=#id_attachment#&aid=#aid#">Delete</a>
	&nbsp;&nbsp;|&nbsp;&nbsp;
	<img src="images/SmUpdate.png" alt="">
	<a class="embed" href="#self#?Fuseaction=app.ARA_docs&action=Setup&id_attachment=#id_attachment#&aid=#aid#">Update</a>
	<br><br>
	</cfoutput>
	
</ol>


