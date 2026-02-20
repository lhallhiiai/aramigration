<!--- **********************************************************  --->
<!---       ARA Contract Information: View Only                            --->
<!--- ********************************************************** --->
<cfif isDefined('url.aid')>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cfelse>
	<cfoutput>An encrypted id_ara was not provided in url string.</cfoutput><cfabort>
</cfif>  
<cfinclude template="../../model/m_ara/qry_contract.cfm">
<br><br>
<cfoutput>
<!--- cfdump var="#GetCM#" format="text" --->
<cfset t=0>
<table width=100% class="outerborder"  cellpadding=2 cellspacing=2>
<cfif id_cat NEQ 4>
<tr><!--           1                    -->
	<cfset t=t+1>
	<td class="qnum">#t#</td>
	<td class="borderq">Start Date Authorized by Customer</td>
	<td nowrap class="border"><cfif isDate(authstart)><b>#dateformat(authStart,"MM/DD/YY")#</b><cfelse>To be provided by contracts</cfif></td>
</tr>
</cfif>
<tr>
	<!--           2                    -->
    <cfset t=t+1>
	<td class="qnum">#t#</td>
	
	<td class="borderq">Type of Customer</td>
	<td  class="border">
	<cfif custDesc NEQ "">#custDesc#<cfelse>To be provided by contracts</cfif></td>
    

</tr>

<tr><!--           3                    -->
	<cfset t=t+1>
	<td class="qnum">#t#</td>
	<td class="borderq">Expected Contract or Mod Execution Date</td>
	<td class="border">
	<cfif executionDate NEQ "">#dateformat(executionDate,"MM/DD/YY")#<cfelse>To be provided by contracts</cfif>
	</td>
	<!--           4                    -->
    <cfset t=t+1>
	<td class="qnum">#t#</td>
	<td class="borderq">Contract Type
		</td>
	<td class="border" valign="bottom">
	<cfif contractType NEQ "">#contractType#<cfelse>To be provided by contracts</cfif>
	

</tr>

<tr><!--           5                    -->
	<cfset t=t+1>
	<td class="qnum">#t#</td>
	<td class="borderq">Procurement Officer</td>
	<td class="border">
	<cfif customerPO NEQ "">#customerPO#<cfelse>To be provided by contracts</cfif>
	</td>
	<!--           4                    -->
    <cfset t=t+1>
	<td class="qnum">#t#</td>
	<td class="borderq">Date PO Contacted
		</td>
	<td class="border" valign="bottom">
	<cfif POContactDate NEQ "" and POContactDate NEQ "01/01/1900">#Dateformat(POContactDate,"MM/DD/YY")#<cfelseif POContactDate EQ "01/01/1900">&nbsp;<cfelse>To be provided by contracts</cfif>
	

</tr>
<cfif id_cat EQ 10 or id_cat EQ 9>
<tr><!--          7                    -->
	<cfset t=t+1>
	<td class="qnum">#t#</td>
	<td class="borderq">Pre-Contract Cost Authorized by Customer</td>
	<td class="border">
	<cfif PCCostAuth NEQ ""><b>#Dollarformat(PCCostAuth)#</b><cfelse>To be provided by contracts</cfif>
	</td>
</tr>
</cfif>
<tr>
<!--           17                    -->
	<cfset t=t+1>
	<td class="qnum">#t#</td>
	<td class="borderq">
	 Anticipated Negotiation Date
	</td>
	<td class="border">
	<cfif anticipatedNegotiation NEQ "" and anticipatedNegotiation NEQ "01/01/00"><b>#Dateformat(anticipatedNegotiation,"MM/DD/YY")#</b><cfelseif anticipatedNegotiation EQ "01/01/00">&nbsp;<cfelse>To be provided by contracts</cfif>
   </td>
</tr>
</table><br><br>

<table width=100% class="outerborder"  cellpadding=2 cellspacing=2>

<cfif NOT ListFind('1,4',id_cat)>
<cfset t=t+1>
<tr><!--           8                    -->
	<td class="qnum">#t#</td>
	<td width=60% class="border"> 
	Has the customer set aside <b>enough funds</b> to support the work?
	
	</td>
	<td nowrap class="border">
		<cfif fundstoSupport EQ 1>
			Yes
		<cfelseif fundstoSupport EQ 2>
			No.
			#fundsExplanation#
		<cfelse>
			To be provided.
		</cfif>
	</td>
</tr>
</cfif>

<cfif id_cat EQ 6>
<tr><!--          9                    -->
<cfset t=t+1>
	<td class="qnum">#t#</td>
	<td class="border"> 
		If the customer is commercial, has a <b>credit check</b> been completed?
	</td>
	<td class="border">
		<cfif creditCheck EQ 1>
			Yes
		<cfelseif creditcheck EQ 2>
			No. 
			#creditExplanation#
		<cfelseif creditcheck EQ 3>
			N/A
		<cfelse>
			To be provided.
		</cfif>
	</td>
</tr>
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<tr><!--          10                   -->
	<cfset t=t+1>
	<td class="qnum">#t#</td>
	<td class="border">
		Does a contract, modification, or purchase request for the work to be performed have
		all the necessary <b>customer approvals</b>?

</td>
	<td class="border">
		<cfif allApprovals EQ 1>
			Yes.
		<cfelseif allApprovals EQ 2>
			No.
		#allApprovalsExplanation#
		<cfelse>
			To be provided.
		</cfif>
	</td>
</tr>
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<tr><!--           11                    -->
	<cfset t=t+1>
    <td class="qnum">#t#</td>
	<td class="border">
		Has it been <b>forwarded</b> to the customer's contracts or purchasing department for action?</b>	
	</td>
	<td class="border">
		<cfif #forwarded# EQ 1>
			Yes
		<cfelseif #forwarded# EQ 2>
			No.
			#forwardedExplanation#
		<cfelse>
			To be provided.
		</cfif>
	</td>
</tr>
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<tr><!--           12                    -->
	<cfset t=t+1>
    <td class="qnum">#t#</td>
	<td  class="border">
		Has an individual authorized to contractually bind the customer given 
	<b>authorization to commence work</b>?
	</td>
	<td class="border">
		<cfif workAuthorization EQ 1>
			Yes
		<cfelseif workAuthorization EQ 2>
			No. 
			#workAuthorizationExplanation#
		<cfelse>
			To be provided.
		</cfif>
	</td>
</tr>
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<tr>
<!--           13                    -->
	<cfset t=t+1>
    <td class="qnum">#t#</td>
	<td class="border">Type of Authorization</td>
	<td class="border">
		<cfif authtype NEQ "">#authType#
		<cfelse>To be provided.
		</cfif>
	</td>
</tr>
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<tr>
	<!--           14                    -->
	<cfset t=t+1>
    <td class="qnum">#t#</td>
	<td class="border">Has a written <b>confirmation been mailed  by HII</b> to the customer? </td>
	<td class="border">
		<cfif writtenConfirmation EQ 1>
			Yes
		<cfelseif writtenConfirmation eq 2>
			No.
			#writtenConfirmationExplanation#
		<cfelse>
			To be provided.
		</cfif>
	</td>	
</tr>
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<tr>
	<!--          15                    -->
	<cfset t=t+1>
    <td class="qnum">#t#</td>
	<td class="border">Has a written <b>confirmation received by</b> the customer? </td>
	<td class="border">
		<cfif alion_conf EQ 1>
			Yes
		<cfelseif alion_conf EQ 2>
			No.
			#Alion_confExplanation#
		<cfelse>
			To be provided.
		</cfif>
	</td>	
</tr>
</cfif>

<cfif NOT ListFind('1,4',id_cat)>
<tr>
	<!--           16                    -->
	<cfset t=t+1>
    <td class="qnum">#t#</td>
	<td class="border">Does the authorization confirm that the contract, modification, or purchase order <b>will include 
   anticipatory costs</b> or, if required, an effective date which coincides with HII's commencement or continuance of work?
	</td>	
	<td class="border">
		<cfif anticipatoryCost EQ 1>
			Yes
		<cfelseif anticipatoryCost EQ 2>
			No #anticipatoryCostExplanation#
		<cfelseif anticipatoryCost EQ 3>
			N/A
		<cfelse>
				To be provided.
		</cfif>
	</td>
</tr>
</cfif>

<cfif id_cat EQ 1>
<tr>
	<!--           16                    -->
	<cfset t=t+1>
    <td class="qnum">#t#</td>
	<td class="borderq">POP of current Award Fee Period</td>	
	<td class="border"><strong>#POP#</strong></td>
</tr>
</cfif>

<cfif id_cat EQ 1>
<tr>
	<!--           16                    -->
	<cfset t=t+1>
    <td class="qnum">#t#</td>
	<td class="borderq">Award fee pool amount for total contract or Delivery Order. If shared, maximum HII share of award fee pool.</td>	
	<td class="border"><strong>#poolAmt#</strong></td>
</tr>
</cfif>

<cfif id_cat EQ 1>
<tr>
	<!--           16                    -->
	<cfset t=t+1>
    <td class="qnum">#t#</td>
	<td class="borderq">Estimated funding date for award fee decision based on most recent fee award.</td>	
	<td class="border"><strong>#estFunDate#</strong></td>
</tr>
</cfif>



<cfif id_cat EQ 4>
<tr>
	<!--           16                    -->
	<cfset t=t+1>
    <td class="qnum">#t#</td>
	<td class="borderq">Internally Cleared Completion Date</td>	
	<td class="border"><strong>#intClearCompDate#</strong></td>
</tr>
</cfif>

<CFIF isPrint EQ "No">
<!--- MGann 9/11/2013: CFdocument was printing list of documents 4 times. Now prints out only in final section of PRINT DOC.
This fix was made after reports that some ARAs could not create pdf. When problem ARAs were looked at they
had long lists of documents...so think the fact that it ws timing out was releated to 4 calls to print out list --->
<cfinclude template="../../model/m_forms/qry_docList.cfm">
<cfif doclist.recordcount GT 0>
<tr>	
	<td colspan=5 class="border">
	<p class="subtitle">&nbsp;&nbsp;&nbsp;&nbsp;Supporting Contracts Document(s)</p>
	<ol>
	<cfloop query="DocList">
	<cfset aid=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
	<li><a class="embed" href="#self#?fuseaction=app.getFile&id_attachment=#id_attachment#&aid=#aid#">#FileName# </a> (Size #numberformat(Filesize,",")#), Desc: #Description#<br>
	Date Uploaded: #Dateformat(Date,"MM/DD/YY")# #Timeformat(Date,"hh:mm tt")#, by #Empname#, Jobtitle: #JobTitle#
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
	<br><br>
	</cfloop>
	
</ol>
</td></tr>
</cfif>
</cfif>

<cfquery name="CACert" datasource="#Application.dsn#">
		select * from ARAAppLog
		where id_ara=#id_ara#
		and id_status=4
	</cfquery>
<cfif CaCERT.RecordCount GT 0>
<tr>
	<td colspan=2 class="border"  align="right">Contract Information submitted on:&nbsp; </td>
	<td class="border">&nbsp;&nbsp;#dateformat(CaCERT.ApprovalDate,"DDDD MM/DD/YYYY")# #timeformat(CACert.ApprovalDate,"hh:mm tt")# </td>
</cfif>
<tr>
</table>
</cfoutput>

<!--- Allows CM to negate --->

<cfif id_status EQ 12 and (getARA.id_contract EQ session.id_user or (isdefined("id_usr") and id_usr EQ session.id_user))>
<form name="negate"  id="negate" method="Post" preservedata="True" enctype="multipart/form-data" action="">
<table border="0" align="center">
<tr>
	<td align="center">
		<cfoutput><input class="button" type="button" value="&nbsp;&nbsp;NEGATE ARA" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.Negation&id_status=#id_status#&id_contract=#id_contract#&divshow=View&id_ara=#id_ara#&returnTo=Contracts';">
		</cfoutput>
	</td></tr>
</table>
</form> 
</cfif>
