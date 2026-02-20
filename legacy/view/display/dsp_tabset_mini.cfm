<!--- QRY_AttachmentStatus.cfm: <cfset docs=#AttacmentStatus(id_ara,id_cat)#>.  --->
<!---<cfinclude template="../../model/m_forms/qry_AttachmentStatus.cfm">--->
<!--- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++  --->

<cfquery name="cName" datasource="#Application.dsn#">
	Select Catname from category
	where id_cat=#id_cat#
</cfquery>

<cfset ThisCat=#cname.CatName#>
<!--- Next Line Returns: doc_cnt (total attachments), havecount, needcount, missingList --->
<!--- cfset docs=#AttachmentStatus(id_ara,id_cat)# --->
<!--- If rejected, get areas rejected --->
<cfif Find(id_status,'8,9')>
	<cfquery name="Bad" datasource="#application.dsn#"> 
		SELECT Top 1 *
		from ARAAppLog
		WHERE id_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#id_ara#">
		and isRejection='True'
		<cfif isDefined('url.ThisCycle')>
			and cycle=#url.ThisCycle#
		</cfif>
		ORDER BY ApprovalDate DESC
	</cfquery>
	<cfset badtabs=#Bad.Rej_areas#>
<cfelse>
	<cfset badtabs="">
</cfif>
<script>
// initialize tooltip
$("#tabset img[title]").tooltip({    //where C
	// place tooltip on the right edge
	position: "center right",
	// can tweak the position
	offset: [17, 10],
	// custom opacity setting
	opacity: 1.0
}).dynamic({ bottom: { direction: 'down', bounce: true } });
</script>
