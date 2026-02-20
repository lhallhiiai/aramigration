<cfparam name="Testing" default="on">
<cfparam name="session.test_flag" default=1>

<cfoutput>
<!-- 3 --><table cellpadding=0   width=250 align="center" border=0 cellspacing=0>



<!--   ********************   HOME  ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'Home'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'Home'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.home&Menu=Home"><b>HOME</b></a>
			</td>
			<td  width=7 class="trdot"<cfif #menu# EQ "Home">bgcolor="##afcca1"</cfif>>
			<img src="images/spacer.gif" width=7></td>
		</tr>
	<tr><!--- My Approval Chain --->
				
			<td <cfif #Menu# EQ 'ApprovalChain'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  colspan=2 width=100% <cfif #Menu# EQ 'ApprovalChain'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.ApprovalChain&menu=ApprovalChain&"><b>MY APPROVAL CHAIN</b></a></td>
			<td  width=7 class="trbdot" <cfif #Menu# EQ "ApprovalChain">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>	
		<tr>
			<td  <cfif #Menu# EQ 'Dashboard'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'Dashboard'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.Dashboard&Menu=Dashboard"><b>DASHBOARD</b></a>
			</td>
			<td  width=7 class="trdot"<cfif #menu# EQ "Dashboard">bgcolor="##afcca1"</cfif>>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<cfif (session.id_job EQ 1) or (session.id_job eq 3) or (session.id_job eq 4) ><!--- PMs or division managers can create --->
		<!--   ********************  New Create ARA  ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'ARA_Sum'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'ARA_Sum'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.CreateARAStep1&Menu=ARA_Sum"><b>CREATE ARA</b></a>
			</td>
			<td  width=7 class="trdot" <cfif #Menu# EQ "ARA_Sum"> bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
        </cfif>
		<!--  ******************** ARAs by State *********************** --->
		<tr>
			<td  <cfif #Menu# EQ 'ByState'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'ByState'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.Home&Menu=BYState"><b>ARA LIST</b></a>
			</td>
			<td  width=7 class="trdot" <cfif #Menu# EQ "ByState">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<tr><!--- Unsubmitted / Pre-approval --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Unsubmitted'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Unsubmitted'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.home&menu=Bystate&submenu=Unsubmitted&Pagequery=Bystate&state=1,2,3,4,5&smtitle=In Work / Pre-Approval">IN PROCESS / PRE-APPROVAL</a>
			</td>
			<td  width=7 class="trdot" <cfif #subMenu# EQ "Unsubmitted">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		<tr><!--- In approval chain --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'InApproval'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'InApproval'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.home&menu=Bystate&submenu=InApproval&Pagequery=Bystate&state=6&smtitle=In Approval Chain">IN APPROVAL CHAIN</a>
			</td>
			<td  width=7 class="trdot" <cfif #subMenu# EQ "InApproval">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		<tr><!--- Rejected --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Rejected'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Rejected'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.home&menu=Bystate&submenu=Rejected&Pagequery=Bystate&state=8,9&smtitle=Rejected">REJECTED</a>
			</td>
			<td  width=7 class="trdot" <cfif #subMenu# EQ "Rejected">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		<tr><!--- Approved --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Approved'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Approved'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.home&menu=Bystate&submenu=Approved&Pagequery=Bystate&state=12&smtitle=Approved">APPROVED</a>
			</td>
			<td  width=7 class="trdot" <cfif #subMenu# EQ "Approved">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<tr><!--- Expired but still open --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'OpenExpired'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'OpenExpired'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.home&menu=OpenExpired&submenu=OpenExpired&Pagequery=OpenExpired&smtitle=Open: Expiration Passed">OPEN: EXPIRATION PASSED</a>
			</td>
			<td  width=7 class="trdot" <cfif #subMenu# EQ "OpenExpired">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<cfif (session.id_job EQ 13 OR session.id_role EQ 2)><!--- CCS or Sysdmin can see all pending negations --->
		<tr><!--- Negations --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Negate'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Negate'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.negationList&menu=Bystate&submenu=Negate&smtitle=Exported&Title=Pending Negation">PENDING NEGATION</a>
			</td>
			<td  width=7 class="trdot" <cfif #subMenu# EQ "Negate">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		</cfif>
		
		<tr><!--- Exported --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Archive'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Archive'>bgcolor="##222222"</cfif> class="tlrdot">
			<cfset smtitle="Cancelled, exported, negated, early start Complete">
			<a class="nav3" href="#self#?fuseaction=app.archiveList&menu=Bystate&submenu=Archive&Pagequery=Bystate&state=10,13,14,16,17&smtitle=Exported, Negated, and Early Start Complete&Title=Archived">ARCHIVED</a>
			</td>
			<td  width=7 class="trdot" <cfif #subMenu# EQ "Archive">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		<!--   ********************  Advanced Search  ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'ARA_Sea'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'ARA_Sea'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.searchARA&Menu=ARA_Sea"><b>SEARCH ARA</b></a>
			</td>
			<td  width=7 class="trdot" <cfif #Menu# EQ "ARA_Sea">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>

		
		<!--   ********************  Administration ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'Admin'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'Admin'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.Admin_Users&Menu=Admin&submenu=Users">
			<cfif Find(session.id_role,"1,2")><b>ADMINISTRATION</b><cfelse><B>ARA SYSTEM INFORMATION</cfif></a>
			</td>
			<td  width=7 class="trbdot" <cfif #Menu# EQ "Admin">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
<cfif (session.id_job Eq 13) or (session.id_job EQ 14) or (session.id_role EQ 2)> <!--- CCS, Controller, System Admin --->
		<tr><!--- ARA Risk Category DASHBOARD --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Activity'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Activity'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.Activity&Menu=Admin&submenu=Activity">RISK CATEGORY DASHBOARD</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "Activity">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
        <tr><!--- Jamis Export --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'export'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'export'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.JamisExport&Menu=Admin&submenu=export">JAMIS EXPORT</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "export">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<tr><!--- User Email List --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'emailist'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'emailist'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.publist&Menu=Admin&submenu=emailist">USER EMAILS</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "emailist">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
</cfif>
<cfif session.id_role EQ 2>
	<!--- Clean up pdf files --->
		<tr><!--- CleanUp --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'PDFCleanup'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'PDFCleanup'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.admin_PDFCleanup&Menu=Admin&submenu=PDFCleanup">PDF CLEANUP</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "PDFCleanup">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<tr><!--- Clean up and cancel old aras--->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'ARACleanUP'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'ARACleanUP'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.AdminCleanOutOldAndExpired&Menu=Admin&submenu=ARACleanUP">CANCEL OLD ARAS</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "ARACleanUP">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
     <!--- Archive old ARAs --->
		<tr><!--- CleanUp --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'archiveARA'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'archiveARA'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.admin_archiveARA&Menu=Admin&submenu=archiveARA">ARCHIVE ARAs</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "archiveARA">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>

</cfif>
		<tr><!--- User Setup --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Users'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Users'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.Admin_Users&Menu=Admin&submenu=Users">ARA USERS</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "Users">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
<cfif session.id_role EQ 2>	
		<tr><!--- Email Archive --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'EmailArchive'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'EmailArchive'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.userEmails&Menu=Admin&submenu=EmailArchive">LOOKUP EMAIL ARCHIVES</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "EmailArchive">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
</cfif>	
		<tr><!--- View and Setup Delegations --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Delegations'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Delegations'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.AdminDelegate&Menu=Admin&submenu=Delegations">DELEGATIONS</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "Delegations">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		<tr><!--- ThresholdsV2 --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Thresholds'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Thresholds'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav3" href="#self#?fuseaction=app.Admin_thresholdsV2">APPROVAL & THRESHOLD MATRIX</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "Thresholds">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		<!--   ********************  Users Guide ******************* -->
		<!---<tr>
			<td  <cfif #Menu# EQ 'UG'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'UG'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="ARAUserGuideV2.pdf" target="_blank">
			<b>DOCUMENTS AND HELP</a>
			</td>
			<td  width=7 class="trbdot" <cfif #Menu# EQ "UG">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>--->
		<tr><!--- ARA Users Guide --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100%  class="tlrdot">
			<a class="nav3" href="ARAUserGuide.pdf" target="_blank">ARA USERS GUIDE</a></td>
			<td  width=7 class="trbdot"
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		<tr><!--- FSG Users Guide --->
		
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100%  class="tlrdot">
			<a class="nav3" href="ARA Workflow for Fleet Support Group.docx">FSG SPECIFIC ARA INFORMATION</a></td>
			<td  width=7 class="trbdot" 
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		
<!---
<cfif session.oprid EQ 'mgann'>	
		<!--   ******************** Support Request ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'Support'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'Support'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.SupportRequest&Menu=Support">
			<b>SUPPORT REQUEST</a>
			</td>
			<td  width=7 class="trbdot" <cfif #Menu# EQ "Support">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<!--   ******************** modal_test ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'Support'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'Support'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.Modal_test&Menu=Support">
			<b>MODAL TEST</a>
			</td>
			<td  width=7 class="trbdot" <cfif #Menu# EQ "Support">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
</cfif>
--->
		<!--   ********************  Logout  ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'Logout'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="trbldot" <cfif Menu EQ 'Logout'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="index.cfm?Fuseaction=app.logout">LOGOUT</a>
			</td>
			<td  width=7 class="trbdot">
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<tr>
			<td colspan=4>
	<table width=100% bgcolor="##7995a2" cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td align="center" class="white">QUICK SEARCH
	</td></tr>
	<tr><td align="center">
		<cfform name="QuickSearch" action="index.cfm?fuseaction=app.QuickSearch" method="post">
		<cfinput type="hidden" name="DoSearch" value="Go">
		<!--- cfinput type="text" size=30 name="SearchEntity" id="SearchEntity" autosuggest="#ValueList(autopopSearch.invoiceEntity, ',')#" autosuggestminlength="1" --->
		<cfinput type="text" size=30 name="SearchString" title="Quick Search on ARA Reference or JAMIS## ">
	</td></tr>
	<tr>
		<td align="center">
		<cfinput name="submit" type="submit" value="Find it"><br><br>
		</td>
	</tr>
	</cfform>
	<tr>
		<td align="center">
		<font style="font-family: verdana;color:##FFFFFF; font-size: 9px;">Enter partial or complete ARA or Costpoint Project Number<br><br></font></td>
	</tr>
	
</table>

			
			</td>
		</tr>
<!--- cfif (session.oprid EQ 'mgann'  or session.oprid Eq 'ahuang'  or session.oprid eq 'Tgilliam' or (session.oprid eq 'Syan' and env EQ "Staging") OR (isDefined('session.Fakelogin'))) --->
<!--- Disallow login in production unless debug is set to yes by application.cfc --->
<!---Application.testflag is: "#application.testFlag#" and env is #env#<br>--->
<!---<CFIF (Env NEQ "Production" OR Application.testFlag EQ "Yes") AND (session.id_role EQ 2 or (isDefined('session.Fakelogin')))>
--->


<!--- <cfif Application.Production EQ "NO">--->
<cfif (<!---Application.Production NEQ "NOO" and --->(session.id_role EQ 2)) or (isDefined('session.Fakelogin'))>
<script>
  $(document).ready(function(){
              $("##ara_user_login").autocomplete("index.cfm?fuseaction=app.ARAusersShort",
                {
                                minChars:2,
                                delay:200,
                                extraParams: {},
                                autoFill:false,
                                matchSubset:true,
                                matchContains:1,
                                cacheLength:10,
                                selectOnly:1
                });
				$("##ara_user_login").result(function(event,data)
                {
                                var tmp = data[0].split(" [");
                                var name = tmp[0];
                                var oprid = tmp[1].split("]:")[0];
                                $("##ara_user").val(data[0]);
	
                });
  });
 </script>
<tr>
	<td colspan=4 valign="top">
<table width=100% bgcolor="##444444" cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td align="center">
		<font style="font-family: verdana;font-size:10px;color:white;"><br>LOGON AS USER (Type LastName or Oprid)</font>
	</td></tr>
	<tr><td align="center">
		<cfform name="FakeLogin" action="index.cfm?fuseaction=app.fake_login" method="post">
		<!--- cfinput type="text" size=30 name="SearchEntity" id="SearchEntity" autosuggest="#ValueList(autopopSearch.invoiceEntity, ',')#" autosuggestminlength="1" --->
		<cfinput type="text" size=30 name="ara_user_login" id="ara_user_login" title="search on oprid or last name">
	</td></tr>
	<tr>
		<td align="center">
		<cfinput name="IseeAll" id="IseeAll"  type="submit" value="Login">
		<input name="reset" type="reset" value="Reset"><br><br>
		</td>
	</tr>
	</cfform>
	
</table>
</td></tr>
</cfif>

</table>
<table cellpadding=0 cellspacing=0 border=0>
<tr>
	<td valign="top">
	<img src="images/stairs.jpg" class="nopadd">
	</td></tr>

</table>
</cfoutput>