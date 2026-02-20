<p class="smtitle">Administration</p>
<p class="title">Cancel Expired ARAs that are in Process</p>
<cfoutput>
<form autocomplete="off" name="CancelOld"  method="Post"  action="index.cfm?Fuseaction=app.AdminCleanOutOldAndExpired">
<table cellpadding=2 cellspacing=2 class="border">
<tr>
<td class="border">Enter Expiration Date <br>
All In process ARAs with expiration dates prior to this will be cancelled:
<td class="border"><input type="text" name="ExpDate" style="background-color: ##E2E8DB;font-size:11px;font-family:verdana;" value="#dateformat(now(),"MM/DD/YYYY")#" size=10 class="date">
</td>
<td class="border"><input type="submit" name="CleanUp" value="Run CleanUp">
</tr>
</table>
</form>
</cfoutput>
<cfif isDefined('cleanUp')>
<cfquery name="oldies" datasource="#Application.dsn#">
	SELECT   top 10  ara.id_ara, ara.division, ara.reference, ara.amountTotal, status.OneWord, ara.startDate, ara.expirationDate
	FROM         ara 
                 INNER JOIN  status ON ara.id_status = status.ID_status
                      where ara.id_status in (1,2,3,4,5,6,8,9)
                      and expirationDate <= '#Dateformat(Form.expDate,"MM/DD/YY")#'
                      ORDER BY ExpirationDate

</cfquery>
<cfif oldies.recordcount GT 0>
<p>The following ARAs have been <strong>cancelled</strong>. An entry of this action has also been written to the audit trail.</p>
<ol>
<cfoutput query="oldies">
<li>ARA #reference#, Division: #division#, Expiration Date: #dateformat(ExpirationDate,"mm/dd/yy")#, #Dollarformat(AmountTotal)#
<cfinclude template="../../model/m_forms/qry_AdminCancel.cfm">
</cfoutput>
</ol>
<cfelse>
	Nothing to clean-up.
</cfif>
</cfif>
