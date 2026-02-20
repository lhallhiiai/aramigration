<cfparam name="Testing" default="on">
<cfoutput>
<!-- 3 --><table cellpadding=0   width=250 align="center" border=0 cellspacing=0>



<!--   ********************   HOME  ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'Home'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'Home'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=home.home&Menu=Home"><b>HOME</b></a>
			</td>
			<td  width=7 class="trdot"<cfif #menu# EQ "Home">bgcolor="##afcca1"</cfif>>
			<img src="images/spacer.gif" width=7></td>
		</tr>
	<!--   ********************  Summary Information  ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'ARA_Sum'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'ARA_Sum'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.ARASummary&Menu=ARA_Sum"><b>CREATE NEW ARA</b></a>
			</td>
			<td  width=7 class="trdot" <cfif #Menu# EQ "ARA_Sum">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<!--   ********************  Early Start ARA  ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'ARA_Early'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'ARA_Early'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.EarlyStartARASumm&Menu=ARA_Early"><b>CREATE EARLY START ARA</b></a>
			</td>
			<td  width=7 class="trdot" <cfif #Menu# EQ "ARA_Early">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		<tr><!--- Program Information --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'ARA_detail'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'ARA_detail'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.ARADetail&Menu=ARA_Detail&whichtab=0">ARA DETAIL</a></td>
			<td  width=7 class="trdot" <cfif #Menu# EQ "ARA_detail">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<tr><!--- RISK EVALUATION --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Risk'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Risk'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.ARADetail&SubMenu=risk&whichtab=1">RISK EVALUATION</a></td>
			<td  width=7 class="trdot" <cfif submenu EQ 'Risk'>bgcolor="##afcca1"</cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		

		<tr><!--- CONTRACT INFORMATION --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Contract'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #submenu# EQ 'Contract'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.ARADetail&SubMenu=Contract&whichtab=2">CONTRACT INFO</a></td>
			<td  width=7 class="trdot" <cfif submenu EQ 'Contract'>bgcolor="##afcca1"</cfif>>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<!--   ********************  Controller Info ******************* -->
		
		<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Controller'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'controller'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.ARADetail&SubMenu=Controller&whichtab=3">CONTROLLER INFO</a></td>
			<td  width=7 class="trdot" <cfif submenu EQ 'Controller'>bgcolor="##afcca1"</cfif>>
			<img src="images/spacer.gif" width=7></td>
		<tr><!--- JAMIS CLINS --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Clins'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'CLINS'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.ARADetail&SubMenu=CLINS&whichtab=4">JAMIS CLINS</a></td>
			<td  width=7 class="trdot"  <cfif submenu EQ 'Clins'>bgcolor="##afcca1"</cfif>>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<tr><!--- REVIEW & APPROVALS --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Approvals'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Approvals'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.ARADetail&SubMenu=Approvals&whichtab=5">REVIEW & APPROVALS</a></td>
			<td  width=7 class="trdot" <cfif submenu EQ 'Approvals'>bgcolor="##afcca1"</cfif> >
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		<!--   ********************  Administration ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'Admin'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="tlrdot" <cfif Menu EQ 'Admin'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.Users&Menu=Admin&subMenu=Users"><b>ADMINISTRATION</b></a>
			</td>
			<td  width=7 class="trbdot" <cfif #Menu# EQ "Admin">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
	
		<tr><!--- User Setup --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Users'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Users'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.Users&Menu=Admin&submenu=Users">ARA USERS</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "Users">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		<tr><!--- View and Setup Delegations --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Delegations'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Delegations'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.AdminDelegate&Menu=Admin&submenu=Delegations">DELEGATIONS</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "Delegations">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
		
		<tr><!--- Thresholds --->
				
			<td  width=7 class="tldot">
				<img src="images/spacer.gif" width=7>
			</td>
			<td <cfif #subMenu# EQ 'Thresholds'>bgcolor="##afcca1"</cfif> width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td  width=100% <cfif #subMenu# EQ 'Thresholds'>bgcolor="##222222"</cfif> class="tlrdot">
			<a class="nav2" href="#self#?fuseaction=app.Thresholds&Menu=Admin&submenu=Thresholds">THRESHOLDS</a></td>
			<td  width=7 class="trbdot" <cfif #subMenu# EQ "Thresholds">bgcolor='##afcca1'></cfif>
			<img src="images/spacer.gif" width=7></td>
		</tr>
	
		<!--   ********************  Logout  ******************* -->
		<tr>
			<td  <cfif #Menu# EQ 'Logout'>bgcolor="##afcca1"</cfif>  width=7 class="tldot">
			<img src="images/spacer.gif" width=7></td>
			<td colspan=2 class="trbldot" <cfif Menu EQ 'Logout'>bgcolor="##222222"</cfif> colspan=2 class="tlrdot">
			<a class="nav2" href="index.cfm?Fuseaction=home.logout">LOGOUT</a>
			</td>
			<td  width=7 class="trbdot">
			<img src="images/spacer.gif" width=7></td>
		</tr>
		<tr>
			<td colspan=4>
	<table width=100% bgcolor="##7995a2" cellpadding=0 cellspacing=0 border=0>
	<tr>
		<td align="center" class="white">Quick Search 
	</td></tr>
	<tr><td align="center">
		<cfform name="QuickSearch" action="" method="post">
		<cfinput type="hidden" name="DoSearch" value="Go">
		<!--- cfinput type="text" size=30 name="SearchEntity" id="SearchEntity" autosuggest="#ValueList(autopopSearch.invoiceEntity, ',')#" autosuggestminlength="1" --->
		<cfinput type="text" size=30 name="SearchEntity">
	</td></tr>
	<tr>
		<td align="center">
		<cfinput name="submit" type="submit" value="Find it"><br><br>
		</td>
	</tr>
	</cfform>
	
</table>

			
			</td>
		</tr>
		
</table>
<table cellpadding=0 cellspacing=0 border=0>
<tr>
	<td valign="top">
	<img src="images/stairs.jpg" class="nopadd">
	</td></tr>
</table>
</cfoutput>