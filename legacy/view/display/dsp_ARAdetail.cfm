<cfparam name="Submenu" default="ARA_Detail">
<cfparam name="whichtab" default=3>


<cfoutput>
<!-- 1  --><table width=100% cellpadding=0 cellspacing=0 border=0>
		<tr>
		<td valign="top">
		<p class="title">
		ARA Detail: Title of ARA</p>
		</td>
		<td valign="top" align="right">
		<a class="embed" href="#self#?fuseaction=app.ARA_cfdocument&AID=#AID#">Print ARA <img src="images/PrinterIcon.gif" border=0></a>
<!-- /1  --></td></tr></table>
</cfoutput>
<!--- ARA Summary Info at top of page ---><cfinclude template="dsp_ARA_top_summary.cfm">

<fieldset><legend><b>ARA Backup Detail</b></legend>
<!--- ARA Navigational Tabs ---><cfinclude template="dsp_tabset.cfm">
			
<!--- **********************************************************  --->
<!---  Program Information Page                                  --->
<!--- ********************************************************** --->
<div id="tabs-1"><!---          Program Information          --->
	<cfinclude template="dsp_ARA_Program.cfm">
	<br>
</div>
<div id="tabs-2"><!---      Contract Information Tab       --->
	<cfinclude template="dsp_ARA_ContractInfo.cfm">	
</div>
<div id="tabs-3"><!---              CLINS --->
	<cfinclude template="dsp_ARA_Clins.cfm">

</div>
<div id="tabs-4"><!---          Controller Information        --->
	<cfinclude template="dsp_ARA_Controller.cfm">	
	
</div>
<div id="tabs-5">
	<cfinclude template="dsp_ARA_docs.cfm">
</div>

<div id="tabs-6"><!---      Review and Approvals       --->
	<cfinclude template="dsp_ARA_Approvals.cfm">
</div>

				
</div><!--- end of tabs div --->	
		

</fieldset>
</body>
</html>