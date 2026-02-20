<!--- **********************************************************  --->
<!---  Program Manager  Information Page View Only Version        --->
<!--- ********************************************************** --->

<cfoutput query="GetARA">
<!-- 1  --><table width="100%" cellpadding=2 cellspacing=2 class="outerborder">
<tr>
	<td nowrap class="borderq">Total ARA Amount:
	</td>
	<td colspan=3 class="border">#dollarformat(amountTotal)#</td>
</tr>

<tr>
	<td class="borderq" nowrap>Total Funded Value Anticipated:
	</td>
	<td class="border">#dollarformat(TotalAnticipated)# </td>
	<td class="borderq">Percent of Funded Value Anticipated:
	</td>
	<td class="border">#percentAnticipated#%</td>
</tr>

<tr>
	<td class="borderq" nowrap>Required Start Date:
	</td>
	<td class="border">
	<cfif startDate EQ "">
		TBD By PM
	<cfelse>
		#dateformat(startDate, "MM/DD/YY")#
	</cfif> </td>
	<td class="borderq">Expiration Date:
	</td>
	<td class="border">
	<cfif ExpirationDate EQ "">
		TBD by PM
	<cfelse>
		#dateformat(ExpirationDate,"MM/DD/YY")#
	</cfif>
	</td>
</tr>

 <tr>
	<td valign="top" class="borderq">Program Manager Submission:</td>
	<td colspan=3 class="border">
	<cfquery name="GetPM" datasource="#Application.dsn#">
		Select approvaldate from araApplog
		where id_ara=#id_ara# and id_job=1
	</cfquery>
	<Cfif GetPm.RecordCount GT 0>
		 	#Dateformat(GetPM.approvalDate,"dddd MM/DD/YY")# #timeformat(GetPM.approvalDate,"hh:mm tt")#
	<cfelse>
			Not PM Approved yet
	 </cfif><!--- PM date moved ???? to where --->
	</td>
</tr>


<!---              Question 1                --->
<cfif id_cat EQ 6 or id_cat EQ 8 or id_cat EQ 9>
<tr>
	<td valign="top" class="borderq" colspan="2">Reason for the change in the scope of work or Period of Performance</td>
	<td colspan=3 class="border" colspan="2">#changeInScope#</td>
</tr>
</cfif>
<cfif id_cat EQ 4>
<tr>
	<td valign="top" class="borderq" colspan="2">Describe necessary actions to clear At Risk</td>
	<td colspan=3 class="border" colspan="2">#ActionToClear#</td>
</tr>
</tr>
</cfif>
<cfif isPrint EQ "No">
<!--- MGann 9/11/2013: CFdocument was printing list of documents 4 times. Now prints out only in final section of PRINT DOC.
This fix was made after reports that some ARAs could not create pdf. When problem ARAs were looked at they
had long lists of documents...so think the fact that it ws timing out was releated to 4 calls to print out list --->
<tr>
	<td colspan=4 class="border">
	<cfset returnTo="PM">
	<cfinclude template="_docList.cfm">
	</td>
</tr>
</cfif>
<!-- 1  --></table>

<cfif (AmountTotal GT 50000) AND (id_cat NEQ 4) >
<!-- 1  --><table width=100% class="outerborder" cellpadding=5 cellspacing=2>
<tr>
	<td  class="greyblue" colspan=3>
	The next questions apply if the ARA is greater than $50K and is NOT category Award Fees or Internally Cleared.
	</td>
</tr>

<!---              Question 1  fundsInAdvance           --->
<tr>
	<td width=20 class="border" valign="top">
		1.
	</td>
	<td <cfif isDefined('IsPrint') AND (isPrint EQ "Yes")>width=350<cfelse>width=45%</cfif> valign="top"class="border">
		<b>Justify Risk</b><br>
Why is it necessary for HII to risk funds in advance of contract
		or modification receipt?
		</td>
		<td class="border" <cfif isDefined('IsPrint') AND (isPrint EQ "Yes")>width=350<cfelse>width=45%</cfif>valign="top">
		<b>Answer</b><br>
		<cfif fundsinAdvance EQ "">
			Answer not provided.
		<cfelse>
			#fundsInAdvance#
		</cfif>
	</td>
</tr>

<!---              Question 2  contractDefinization              --->
<tr>
	<td class="border" valign="top">
	2.</td>
		<td valign="top"  class="border">
		<b>Finalization Actions in Progress
</b><br>
		What is currently being done to ensure contract definitization on the expected contract or modification execution date?
		<td valign="top"  class="border">
		<b>Answer</b><br>
		<cfif contractDefinization EQ "">
			Answer not provided.
		<cfelse>
			#contractDefinization#
		</cfif>
	</td>
</tr>
<!---              Question 3: pertinentInformation               --->
<tr>
	<td class="border" valign="top">
	3.</td>
		<td class="border" valign="top"><b>
		Other Risk Info</b><br>
		What other pertinent information is available to aid in evaluating this request for at risk approval? Are there any special
	or unusual circumstances?</td>
	<td valign="top"   class="border">
		<b>Answer</b><br>
		<cfif pertinentInformation EQ "">
			Answer not provided.
		<cfelse>
			#pertinentInformation#
		</cfif>
	
	</td>
</tr>

<!---              Question 4   workStarted             --->
<tr>
	<td class="border" valign="top">
	4.</td>
		<td class="border" valign="top">
		<b>Work Prior to ARA</b><br>
		If work was started prior to presenting the request for management approval, explain why?</i>
		</td>
		<td class="border" valign="top">
		<b>Answer</b><br>
		
		<cfif workStarted EQ "">
			Answer not provided.
		<cfelse>
			#workStarted#
		</cfif>
	
	</td>
</tr>

<!---              Question 5 consequence               --->
<tr>
	<td class="border" valign="top">
	5.</td>
		<td valign="top"   class="border">
		<b>Consequence of Disapproval</b><br>
		What is the consequence of not commencing work in advance of a signed contract or modification?</i>
		
	</td>
	<td class="border" valign="top">
	<b>Answer</b><br>
		<cfif consequence EQ "">
			Answer not provided.
		<cfelse>
			#consequence#
		</cfif>
	</td>
</tr>

<!---              Question 6 currentStatus               --->
<tr>
	<td valign="top" class="border">
		6.</td>
	<td class="border" valign="top">
	<b>Current Status</b><br>
	What is the current status of the anticipated contractual coverage?
	</td>
	<td valign="top" class="border">
	<b>Answer</b><br>
		<cfif currentStatus EQ "">
			Answer not provided.
		<cfelse>
			#currentStatus#
		</cfif>
	</td>
</tr>

</table>
</cfif>
</cfoutput>
