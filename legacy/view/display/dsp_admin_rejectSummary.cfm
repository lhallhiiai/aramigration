
<cfparam name="All" default="Inprocess">
<cfif All EQ "Inprocess">
	<cfset Title="Rejects in Process">
<cfelse>
	<cfset Title="All Rejects History">
</cfif>

<cfquery name="Rej" datasource="#Application.dsn#">
	SELECT     ara.id_ara, ara.reference, ara.amountTotal, araAppLog.isRejection, araAppLog.id_status, araAppLog.id_job, 		araAppLog.comment, araAppLog.cycle, 
                      rejectionReason.reason, users.empname, araAppLog.approvalDate, araAppLog.id_reason
FROM  ara INNER JOIN
      araAppLog ON ara.id_ara = araAppLog.id_ara 
	  INNER JOIN rejectionReason ON araAppLog.id_reason = rejectionReason.id_Reason 
	  INNER JOIN users ON araAppLog.id_user = users.id_user
<cfif All EQ 'Inprocess'>
	and ara.id_status in (8,9)
<cfelse>
	ORDER BY araAppLog.id_reason
</cfif>
</cfquery>

<table width="100%" cellpadding=0 cellspacing=0 border=0>
<tr>
<td width=50%>
<p class="title"><cfoutput>#Title#</cfoutput></p>
</td>
<td align="right" width=50%>
<input type="radio" onclick="Javascript: window.location.href='index.cfm?Fuseaction=app.admin_rejectSummary&All=All';" 
		       Name="All" value="All" <cfif #All# EQ "All">Checked</cfif>>All
			   &nbsp;&nbsp;
<input type="radio" onclick="Javascript: window.location.href='index.cfm?Fuseaction=app.admin_rejectSummary&All=Inprocess';" 
		       Name="All" value="Inprocess" <cfif #All# EQ "Inprocess">Checked</cfif>>In Process
</td></tr>
</table>
<table width="100%" cellpadding=2 cellspacing=2>
<tr>
<td valign="top">
<cfset loopcount=1>
<table cellpadding="2" cellspacing="2" class="border">
<tr>
	<td></td>
	<td class="border">ARA Reference</td>
	<td class="border">Date</td>
	<td class="border">Reason /Comment</td>
</tr>
<cfset DocCnt=0> <cfset ClinCnt=0><cfset AmountCnt=0> <cfset misMatch=0><cfset inCnt=0> <cfset OtherCnt=0>
<cfoutput query="rej">
<tr>
	<td class="border">#loopcount#. </td>
	<td class="border" nowrap>
	<cfset AID=#encrypt(Rej.id_ara,request.encryptKey,request.encryptType,'hex')#>
	<a href="index.cfm?Fuseaction=app.ARA_PM&AID=#AID#&&Menu=ARA_Detail" class="embed">#reference#</a>
	</td>
	<td class="border">
		#dateformat(ApprovalDate,"MM/DD/YY")#
		</td>
	<td class="border">
		<b>
		<cfswitch expression="#id_reason#">
		<cfcase value="1">Insufficient Documentation <cfset DocCnt=DocCnt+1></cfcase>
		<cfcase value="2">Incorrect Clin <cfset ClinCnt=ClinCnt+1></cfcase>
		<cfcase value="3">Incorrect Amount <cfset AmountCnt=AmountCnt+1> </cfcase>
		<cfcase value="4">Amounts & Docs Mismatch <cfset misMatch=Mismatch+1> </cfcase>
		<cfcase value="5">Inadequate Justification <cfset inCnt = InCnt+1></cfcase>
		<cfcase value="6">Other <cfset OtherCnt = OtherCnt+1></cfcase>
		</cfswitch>
		<br>
		</b>
		<cfset i=Find(']:',comment)>
		<i>#Mid(Comment,(i+3),(len(comment)))#</i>
	</td>
</tr>
<cfset loopcount=loopcount+1>
</cfoutput>
</table>

</td>
<td valign="top">
<cfset colors="94b783,6c8d9b,4b5c63,ffcc66,fe9c01,af3610">
<cfset reasons="Insuff Docs,Bad CLIN,Bad Amt,Amt Mismatch,Justif- ication,Other">
<cfset counts="#docCnt#,#ClinCnt#,#AmountCnt#,#Mismatch#,#inCnt#,#OtherCnt#">
<br><b>Reject Reasons</b><br><br>
<cfchart
     format="png"
	 chartheight="350"
	 chartwidth="370"
 	 xAxistitle = "Reject Reasons"
	 show3D="yes"
	 labelformat="number"
	 yaxistitle="Counts"
	 markersize=20
	font = "Trebuchet MS" 
  
    fontSize = "9"
	 seriesplacement="default">
	<cfchartseries
             type="bar"
             serieslabel=""
			 paintStyle="raise"
   			 colorlist = "#colors#">
			<cfset Listptr=1>
			<cfloop index="i" list="#reasons#">
					<cfset this_reason=#Listgetat(reasons,listptr)#>
					<cfset this_count=#Listgetat(counts,listptr)#>
					<cfchartdata item="#this_reason#" value="#this_count#">
					<cfset Listptr=#listptr# + 1>
			</cfloop>
</cfchartSeries>
</cfchart>


</td>
</table>
