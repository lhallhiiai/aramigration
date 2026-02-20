<cfinclude template="../../model/m_forms/qry_AttachmentStatus.cfm">
<!--- Next Line Returns: doc_cnt (total attachments), havecount, needcount, missingList --->
<cfset docs=#AttachmentStatus(id_ara,id_cat)#>

<!--- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++  --->
<cfquery name="cName" datasource="#Application.dsn#">
	Select Catname from category 
	where id_cat=#id_cat#
</cfquery>
<cfset ThisCat=#cname.CatName#>

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
<!--- cfdump var="#bad#" --->
<!--- tabs --->
<cfoutput>
<div id="tabset">
<table width=830 cellpadding=0 cellspacing=0 class="tabs_outer">
<tr>
	<td width=830 height=30 valign="bottom">
		<table cellpadding=0  height=25 cellspacing=0 border=0>
		<tr> <!--- ++++++++++++++++++++    Program Manager +++++++++++++++++++++++++++  --->
			<td width=3><img src="images/spacer.gif" width=3></td>
			<td height=25 align="center" <cfif whichtab EQ "PM">class="tab_front"<cfelse>class="tab_back"</cfif>>
	 		<a class="tab" href="index.cfm?Fuseaction=app.ARA_PM&AID=#AID#">Program Manager</a>
			<cfif (id_status GT 1) and (id_status NEQ 10)>
				<cfif #Find('PM',badtabs)#>
					<img  class="tabstatus" title="<cfoutput>#tooltip.pmCheck#</cfoutput>" src="images/tabx.png">
				<cfelse>
					<img  class="tabstatus" title="<cfoutput>#tooltip.pmCheck#</cfoutput>" src="images/tabcheck.png"> 
				</cfif>
			<cfelse>
				<img class="tabstatus"  title="<cfoutput>#tooltip.pmMinus#</cfoutput>" src="images/tabminus.png">
			</cfif>
			</td>
			
			<!--- ++++++++++++++++++++    Contract Manager +++++++++++++++++++++++++++  --->
			<td width=3 class="tab_spacer"><img src="images/spacer.gif" width=3></td>
			<td height=25 align="center" <cfif whichtab EQ "contract">class="tab_front"<cfelse>class="tab_back"</cfif>>
	 		<a class="tab" href="index.cfm?fuseaction=app.ARA_ContractInfo&AID=#AID#">Contract Administrator</a> 
			<cfif (id_status GT 2) AND (id_status NEQ 10)>
				<cfif #Find('Contract',badtabs)#>
					<img  class="tabstatus" title="<cfoutput>#tooltip.pmCheck#</cfoutput>" src="images/tabx.png">
				<cfelse>
					<img  class="tabstatus" title="<cfoutput>#tooltip.contractCheck#</cfoutput>" src="images/tabcheck.png"> 
				</cfif>
			<cfelse>
				<img class="tabstatus" src="images/tabminus.png" title="<cfoutput>#tooltip.contractMinus#</cfoutput>"> 
			</cfif>
			</td>
			
			<!--- ++++++++++++++++++++    ControllerV2 +++++++++++++++++++++++++++  --->
			<td width=3 class="tab_spacer"><img src="images/spacer.gif" width=3></td>
			<td height=25 align="center" <cfif whichtab EQ "ControllerV2">class="tab_front"<cfelse>class="tab_back" </cfif>>
	 		<a class="tab" href="index.cfm?fuseaction=app.ARA_controllerV2&AID=#AID#">Controller</a> 
			<cfif (id_status GT 5) and (id_status NEQ 10)><!--- Submitted to project manager --->
				<cfif Find('Controller',badtabs)>
					<img  class="tabstatus" title="<cfoutput>#tooltip.pmCheck#</cfoutput>" src="images/tabx.png">
				<cfelse>
					<img  class="tabstatus" title="<cfoutput>#tooltip.clinsCheck#</cfoutput>" src="images/tabcheck.png">
				</cfif>
			<cfelse>
				<img class="tabstatus" src="images/tabminus.png" title="<cfoutput>#tooltip.clinsMinus#</cfoutput>"> 
			</cfif>
			</td>
			<!---
			
					
			<!--- ++++++++++++++++++++    CLINS +++++++++++++++++++++++++++  --->
			<td width=3 class="tab_spacer"><img src="images/spacer.gif" width=3></td>
			<td height=25 align="center" <cfif whichtab EQ "clins">class="tab_front"<cfelse>class="tab_back"</cfif>>
	 		<a class="tab" href="index.cfm?fuseaction=app.ARA_Clins&AID=#AID#">CLINS V1</a>
			<cfif id_status GT 5><!--- Submitted to project manager --->
				<cfif #Find('CLIN',badtabs)#>
					<img  class="tabstatus" title="<cfoutput>#tooltip.pmCheck#</cfoutput>" src="images/tabx.png">
				<cfelse>
					<img  class="tabstatus" title="<cfoutput>#tooltip.clinsCheck#</cfoutput>" src="images/tabcheck.png">
				</cfif>
			<cfelse>
				<img class="tabstatus" src="images/tabminus.png" title="<cfoutput>#tooltip.clinsMinus#</cfoutput>"> 
			</cfif>
			</td>
			
			
			<!--- ++++++++++++++++++++    Controller +++++++++++++++++++++++++++  --->
			<td width=3 class="tab_spacer"><img src="images/spacer.gif" width=3></td>
			<td height=25 align="center" <cfif whichtab EQ "Controller">class="tab_front"<cfelse>class="tab_back" </cfif>>
	 		<a class="tab" href="index.cfm?fuseaction=app.ARA_controller&AID=#AID#">Controller V1</a> 
			<cfif id_status GT 5><!--- Submitted to project manager --->
				<cfif Find('Controller',badtabs)>
					<img  class="tabstatus" title="<cfoutput>#tooltip.pmCheck#</cfoutput>" src="images/tabx.png">
				<cfelse>
					<img  class="tabstatus" title="<cfoutput>#tooltip.clinsCheck#</cfoutput>" src="images/tabcheck.png">
				</cfif>
			<cfelse>
				<img class="tabstatus" src="images/tabminus.png" title="<cfoutput>#tooltip.clinsMinus#</cfoutput>"> 
			</cfif>
			</td
			
			--->
			
			<!--- ++++++++++++++++++++    Documents +++++++++++++++++++++++++++  --->
			<td width=3 class="tab_spacer"><img src="images/spacer.gif" width=3></td>
			<td height=25 align="center" <cfif whichtab EQ "Documents">class="tab_front"<cfelse>class="tab_back" </cfif>>
			
	 		<a class="tab" href="index.cfm?fuseaction=app.ARA_docs&Aid=#AID#">
			Docs: Total #doc_cnt#, Required:
			<cfoutput>#haveCount# of #ListLen(NeedList)#</cfoutput>
			</a>
			<cfif Find('Documents',badtabs)>
				<img  class="tabstatus" title="<cfoutput>#tooltip.pmCheck#</cfoutput>" src="images/tabx.png">	
			<cfelseif havecount LT ListLen(NeedList)>
				<img src="images/tabminus.png" border=0 title="<cfoutput>#tooltip.docsMinus#</cfoutput>">
			<cfelse>
				<img  class="tabstatus" title="<cfoutput>#tooltip.docsCheck#</cfoutput>" src="images/tabcheck.png"> 
			</cfif>
			</td>
			
			<!--- ++++++++++++++++++++    Approvals +++++++++++++++++++++++++++  --->
			<td width=3 class="tab_spacer"><img src="images/spacer.gif" width=3></td>
			<td height=25 align="center" <cfif whichtab EQ "Approvals">class="tab_front"<cfelse>class="tab_back"</cfif>>
			<a class="tab" href="index.cfm?fuseaction=app.ARA_approvals&AID=#AID#">Approvals</a> 
			<cfswitch expression="#id_status#">
			<cfcase value="12,13,14,15,16,17"><!--- Approved --->
				<img  class="tabstatus" title="<cfoutput>#tooltip.ApprovalCheck#</cfoutput>" src="images/tabcheck.png"> 
			</cfcase>
			<cfcase value="8,9"><!--- Rejected --->
	 			<img class="tabstatus" src="images/tabx.png"> 
			</cfcase>
			<cfdefaultcase>
				<img src="images/tabminus.png" border=0 title="<cfoutput>#tooltip.ApprovalMinus#</cfoutput>">
			</cfdefaultcase>
			</cfswitch>
			</td>
			
			<!--- ++++++++++++++++++++    Notes +++++++++++++++++++++++++++  --->
			<td width=3 class="tab_spacer"><img src="images/spacer.gif" width=3></td>
			<td height=25 align="center" <cfif whichtab EQ "Notes">class="tab_front"<cfelse>class="tab_back" </cfif>>
			<cfquery name="noteCount" datasource="#Application.dsn#">
				select count (*) as n_cnt from ara_note
				where id_ara=#id_ara#
			</cfquery>
	 		<a class="tab" href="index.cfm?fuseaction=app.ara_note&Aid=#AID#">
			Notes 
			</a> (#noteCount.n_cnt#)
			</td>
		</tr>
		</table>
	 </td>
</tr>
</table>
</div>
</cfoutput>
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
