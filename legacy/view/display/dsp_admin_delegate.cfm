<cfset menu="Admin">
<cfset submenu="Delegations">
<!--- temp ---><cfset fk_delegateFrom_ID="">
<!--- temp ---><cfset fk_Delegate_ToID="">
<!--- temp ---><cfset session.userid="">
<!--- temp ---><cfset session.role="">
<!--- temp ---><cfset startDate="">
<!--- temp ---><cfset endDate="">

<p class="smtitle">Administration</p>
<p class="title">View & Setup Delegations</p>
<p>This page has been adapted from Ariva. In that environment, only a certain role [functional approver] could delegate. They could setup their own delegations
or administrators could do it on their behalf. So it probably would be simplest to keep that model.</p>
<cfoutput>

<!--- input type="hidden" name="fk_delegateFrom_ID" value="#session.userid#" --->
<!--- Used this for test: input type="hidden" name="fk_delegateFrom_ID" value="ahuang" --->
<!--- input type="hidden" name="Action" value="#Action#" --->
</cfoutput>
<cfif isdefined("url.msg") and url.msg EQ 1>
	<h3>You already have a delegation to this user in the system that expires after the start date you selected.  Please revoke that delegation and try again.</h3>
</cfif>
<Table cellpadding=2 cellspacing=2 class="border">

	
	
	<!--- *************************** Delegator  *************** --->
<cfif #session.role# EQ 0>
<cfoutput>
		<!--- p class="subtitle"><cfoutput>#Session.userid#@alionscience.com delegating to:</cfoutput></p --->
		<!--- input type="hidden" name="fk_delegateFrom_ID" value="#session.userid#" --->
</cfoutput>
<cfelse>
<form name="Delegate" id="DelegateID" method="Post" onSubmit="return validateForm();" Action="">
	<tr>
	<td class="border">
	Delegate From: &nbsp;&nbsp;
	</td>
	<td class="border" colspan=3>
		<!--- remove people from pull down who already have delegations in effect --->
		<!--- 
		<cfquery name="CurDel" datasource="#request.dsn#">
			Select fk_delegateFrom_ID from delegation
		</cfquery>
		<cfset Tor_list="">
		<cfset tor_list=#QuotedValuelist(CurDel.fk_delegateFrom_ID)#>
		
		--->
		
		<select class="inputtext" name="fk_delegateFrom_ID">
		  <cfquery name="getUser" datasource="idb4PeopleSoft">
			SELECT * FROM cae_alionOrgByUser
			where oprid <> '#session.userid#'
			<!--- 
			<cfif Find('Insert',Action) AND (ListLen(tor_List) GT 0)>
			and oprid NOT IN (#QuotedValueList(curdel.fk_delegateFrom_ID)#)
			</cfif>
			--->
			Order by EmpName
			
		</cfquery>
		
		<cfif #fk_delegateFrom_ID# EQ ""><option value="">-- List of ARA Users ---</option></cfif>
		<cfoutput query="getuser">
		<option class="inputtext" value="#oprid#" <cfif #fk_delegateFrom_ID# EQ #oprid#>Selected</cfif>>#empname#, #n_sector#</option>
		</cfoutput>
		</select>
	</td></tr>
</cfif>
<!--- *************************** Delegate_To  *************** --->
	<tr><td class="border">
	Delegate To: &nbsp;&nbsp;</td>
	<td colspan=3>
	
	<select class="inputtext" name="fk_Delegate_ToID">
		  <cfquery name="getUser" datasource="idb4PeopleSoft">
			SELECT * FROM cae_alionOrgByUser
			where oprid <> '#session.userid#'
			Order by EmpName
			
		</cfquery>
        
       
		
		<cfif #fk_Delegate_ToID# EQ ""><option value="">-- List of ARA Users ---</option></cfif>
		<cfoutput query="getuser">
		<option class="inputtext" value="#oprid#" <cfif #fk_Delegate_ToID# EQ #oprid#>Selected</cfif>>#empname#, #n_sector#</option>
		</cfoutput>
		
		</select>
	</td>
</tr>
	<cfoutput>
<tr>
	<td valign="top" class="border">
	Starting Date
	</td>
	<td class="border">
		<input  size=12 class="date"  style="background-color: ##E2E8DB;" type="text" name="StartDate" REQUIRED="Yes" VALIDATE="date">
		<img src="images/datepicker.gif">
	</td>
	<td valign="top" class="border">
	Ending Date</td>
	<td valign="top" class="border">
		<input  size=12 class="date"  style="background-color: ##E2E8DB;" type="text" name="End" REQUIRED="Yes" VALIDATE="date">
		<img src="images/datepicker.gif">
	</td>
	</cfoutput>

			
</td>
</tr>
<tr>
<td colspan=4 align="center" class="border">
<input type="Submit" Value="Submit">
</td></tr>

	
</table>
</form>

<p class="subtitle">Delegations In Effect (shown only to billing personnel)</p>

<table width=95% cellpadding=2 cellspacing=2 class="border">
<tr>
	<td class="border">From</td>
	<td class="border">To</td>
	<td class="border">Start</td>
	<td class="border">End</td>
	<td class="border">Update/Delete</td>
</tr>
<tr>
	<td class="border">Mgann</td>
	<td class="border">RSutton</td>
	<td class="border">12/1/2010</td>
	<td class="border">12/12/2011</td>
	<td class="border"><a class="embed" href="">Update/Delete</a></td>
</tr>

<tr>
	<td class="border">JBruner</td>
	<td class="border">Gbehning</td>
	<td class="border">12/1/2010</td>
	<td class="border">12/12/2011</td>
	<td class="border"><a class="embed" href="">Update/Delete</a></td>
</tr>
</table><br><br>