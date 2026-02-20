<!--- displayed on right part of approval tab. Contains Reject Information --->
<!--- font style="font-size:15px;">

<cfdump var="#cgi.QUERY_STRING#" format="text">
</font --->
<cfparam name="newstatus" default=9>
<cfif isDefined('cgi.query_String') and Find('Reject',cgi.query_string)>
	<cfquery name="RejLog" datasource="#application.dsn#">
			Select top 1 * from ARAapplog
			where id_ara=#id_ara#
			and isRejection='True'
			and cycle=#thiscycle#
			Order by ApprovalDate Desc
	</cfquery>
	<cfset aid=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
	<cfset currentcycle=thiscycle>
	<cfset newstatus=8>
	<!--- If being called from other Controller or Contracts, need to check for delegation --->


	<cfquery name="ARA_User" datasource="#Application.dsn#">
			Select empname,title,id_user, oprid, delegateTo_oprid
			from
			v_users
			where id_user=#session.id_user#
	</cfquery>
	<!--- Next may have to change when testing delegation of PM, contracts, Controller --->
	<cfset oprid_delegateTo="">
	<cfset oprid_delegatefrom="">
</cfif>
<cfset divShow="View">
	<div id="Reject">
	<!--- Superscript for cycle number --->
		<cfswitch expression="#thiscycle#">
			<cfcase value="1"><cfset sup="st"></cfcase>
			<cfcase value="2"><cfset sup="nd"></cfcase>
			<cfcase value="3"><cfset sup="rd"></cfcase>
			<cfdefaultcase><cfset sup="th"></cfdefaultcase>
		</cfswitch>
	<cfoutput><p class="Rejection">#thisCycle#<sup>#sup#</sup> Reject Info</p></cfoutput>
	<cfif (RejLog.Recordcount EQ 0) and ((id_status NEQ 8) AND (id_status NEQ 9))>
<!--- Show Rejection Form --->
			<cfoutput>
			<cfform name="reject_ara" id="reject_ara" action="index.cfm?fuseaction=app.reject&aid=#aid#">
				<input type="hidden" name="id_ara" value="#id_ara#">
				<input type="hidden" name="cycle" value="#thiscycle#">
				<cfif isDefined('del.del_title') and del.del_title NEQ "">
					<input type="hidden" name="title" value="#del.del_title#">
				<cfelse>
					<!--- Go on defined on next???? this is workaround --->
					<cfif isDefined('Ara_user.Title')>
						<input type="hidden" name="title" value="#Ara_user.Title#">
					<cfelse>
						<input type="hidden" name="title" value="#session.jobtitle#">
					</cfif>
				</cfif>
				<cfif isDefined('oprid_delegateTo') and oprid_delegateTo NEQ "">
				<input type="hidden" name="oprid_delegateTo" value="#oprid_delegateTo#">
				</cfif>
				<cfif isDefined('oprid_delegateFrom') and oprid_delegateFrom NEQ "">
				<input type="hidden" name="oprid_delegateFrom" value="#oprid_delegateFrom#">
				</cfif>
				<input type="hidden" name="returnto" value="#returnto#">
				<input type="hidden" name="newstatus" value="#newstatus#">
			<table cellpadding=2 cellspacing=2 class="border">
			<tr>
			<td>
			<b>Comments</b><br><br>
			<cftextarea name="Rej_desc" required="yes" Message="You must supply a description of why this ARA is being rejected" 
			cols=35 rows=6 class="inputtext">
			
			</cftextarea>
			<tr>
			<td>
			<b>Reason Code</b><br><br>
			<cfquery name="RejReason" datasource="#Application.DSN#">
				Select * from RejectionReason
			</cfquery>
			<cfselect class="inputtext" name="id_reason"  required="yes" Message="Select a Reason Code" size=3>
				
				<cfloop query="RejReason">
					<option value="#ID_Reason#">#Reason#</option>
				</cfloop>
			</cfselect>
			
			</td></tr>
			<tr>
			<td>
			<b>Affected Tab Information</b><br><br>
			<table cellpadding=2 cellspacing=2 class="border">
				
				<tr>
					<td class="border"><cfinput type="checkbox" name="Rej_areas" value="PM" required="yes" message="Please select which tab(s) are affected"></td><td class="border">Program Mgr</td>
					<td class="border"><cfinput type="checkbox" name="Rej_areas" value="Contract" required="yes" message="Please select which tab(s) are affected"></td><td class="border">Contract Mgr</td>
				
				</tr>
				
				<tr>
					<td class="border"><cfinput type="checkbox" name="Rej_areas" value="Controller" required="yes" message="Please select which tab(s) are affected"></td><td class="border">Controller</td>
					<td class="border"><cfinput type="checkbox" name="Rej_areas" value="Documents" required="yes" message="Please select which tab(s) are affected"></td><td class="border">Documents</td>
				</tr>
			</table>
			<tr>
				<td class="border" align="center">
					<cfinput class="button" name="submit" type="submit" value="Submit Reject">
				</td>
			</tr>
			
			</table>
			</cfform>
			</cfoutput>
	<cfelse>
			<!--- Display Only --->
			
			<cfquery name="Rej" datasource="#Application.dsn#">
				Select TOP 1 * from ARAAppLog,RejectionReason
				where ARAAppLog.id_ara=#id_ara#
				and ARAAppLog.isRejection='True'
				and ARAAppLog.cycle=#thiscycle#
				and ARAAppLog.id_reason=RejectionReason.id_reason
				Order by ARAAppLog.ApprovalDate Desc
			</cfquery>
			<CFOUTPUT QUERY="rej">
			<cfquery name="Rejector" datasource="#Application.dsn#">
				Select empname from users where 
				id_user=#id_user#
			</cfquery>
			#Rejector.empname#, #dateformat(ApprovalDate,"MM/DD/YY")# #timeformat(ApprovalDate,"hh:mm tt")#<br><br>
			<b>REJECTION COMMENTS</b><br><br>
			#comment#
			<br><br>
			<b>REASON CODE</b><br><br>
			#reason#<br><br>
			<b>AREAS TO CORRECT</b><br><br>
			<cfif #listLen(Rej_Areas)# GT 1>
				<ul>
				<cfloop index="str" list="#Rej_areas#">
					<li class="square"> #str#</li>
				</cfloop>
				</ul>
			<cfelse>
				#rej_areas#
			</cfif>
<cfif (session.id_job EQ 13) or (session.id_user EQ ID_PM)><!--- CCS, Sys admin, or PM --->
				
<script type="text/javascript">
	function confirmCancel()
	{
	var r=confirm("By canceling this ARA, you are confirming that this ARA is no longer necessary. No one will be able to make any changes or revise this form. Please click OK to confirm your cancellation.");
	if (r==true)
	  {
	  return true;
	  }
	else
	  {
	  return false;
	  }
	}
</script>

<cfform action="?fuseaction=app.PM_cancel&AID=#url.aid#" id="PMFormC" name="PMFormC">
<cfinput type="hidden" name="reference" value="#reference#">
<cfinput type="hidden" name="revision" value="#revision#">
<cfinput type="hidden" name="title" value="#title#">
<cfinput type="hidden" name="jamisNo" value="#jamisNo#">
<table width="100%" cellpadding=2 cellspacing=2 >
	<tr>
		<td align="left">
		<br><hr><br>
		<input class="button" type="submit" name="CancelPM" value="Cancel This ARA" onClick="return confirmCancel();"></td>
    </tr>
</table>
</cfform>
</cfif>
</cfoutput>
			
</cfif>
	

	</div>