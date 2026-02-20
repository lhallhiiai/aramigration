
<!--- cfdump var="#session#" format="text" --->
<cfparam name="Faction" default="">
<cfset menu="admin">
<cfset submenu="Thresholds">
<!--- ++++++++++++++  Setup Title and Button Names +++++++++++ --->
<cfswitch expression="#Faction#">
<cfcase value="app.Admin_InsertThreshold">
	<cfset title="Add New Threshold">
	<cfset buttontext="Add">
</cfcase>
<cfcase value="app.Admin_UpdateThreshold">
	<cfset title="Update Threshold">
	<cfset buttontext="Update">
</cfcase>
<cfdefaultcase>
	<cfset title="Approval & Threshold Matrix">
	<cfset buttontext="Submit">
</cfdefaultcase>
</cfswitch>
<cfif #session.id_role# EQ 2><!--- Sys admin --->
	<p class="smtitle">Administration</p>
<cfelse>
	<p class="smtitle">ARA SYSTEM INFO</p>
</cfif>
<p class="title"><cfoutput>#title#</cfoutput></p>
<cfinclude template="dsp_messages.cfm">
<cfoutput>
<!--- cfdump var="#session#" format="text" --->

<cfif isDefined('id_threshold') or isDefined('Addnew')>
<!--- **********************************************************  --->
<!---   Start of Form to Insert or Update                        --->
<!--- ********************************************************** --->
<cfinclude template="../../model/m_ara/qry_getThresholds.cfm">
<cfform name="SetThresholds" id="SetThreholds" action="#self#?fuseaction=#faction#">
<cfif isDefined('url.riskLevel')>
	<input type="hidden" name="riskLevel" value="#url.riskLevel#">
	<input type="hidden" name="id_job" value="#url.id_job#">
<cfelse>

</cfif>
<cfif isDefined('id_threshold')>
	<input type="hidden" name="id_threshold" value="#id_threshold#">
</cfif>
<table width=100% cellpadding=2 cellspacing=2 class="border">
	<tr>
		<td class="borderq">Risk Level</td>
		<td class="border"><b>#riskLevel#</b></td>
		<td class="borderq">Job Title</td>
		<td class="border"><b>#jobTitle#</b></td>
		<td class="borderq">Review/Approve</td>
		<td class="border">
		<cfselect size=2  class="inputtext" name="review_approve" required="Yes" Message="Select whether this job title has approval or review authority">
			<option value="Review" <cfif this_review_approve EQ "Review">Selected</cfif>>Review</option>
			<option value="Approve" <cfif this_review_approve EQ "Approve">Selected</cfif>>Approve</option>
		</cfselect>
		&nbsp;&nbsp;
		Can delegate? 
		<cfif isDefined('this_delegate') and (this_delegate EQ 1)>
			<cfinput type="radio" name="Delegate" Checked
		 	required="yes" Message="Can this job title delegate authority?" value=1>Yes&nbsp;&nbsp;
		<cfelse>
			<cfinput type="radio" name="Delegate" required="yes" Message="Can this job title delegate authority?" value=1>Yes&nbsp;&nbsp;
		</cfif>
		<cfif isDefined('this_delegate') and (this_delegate EQ 0)>
			<cfinput type="radio" name="Delegate" Checked required="yes" Message="Can this job title delegate authority?" value=0>No
		<cfelse>
			<cfinput type="radio" name="Delegate" required="yes" Message="Can this job title delegate authority?" value=0>No
		</cfif>
		</td>
	</tr>
</table>
<table width=100% cellpadding=2 cellspacing=2 class="border">
	<tr>
		<td class="borderq">Low Threshold</td>
		<td class="border">
		<cfinput type="text" class="inputtext" size=12 maxlength="12" name="low_thresh" value="#numberformat(low_thresh,'9,999')#" required="yes" Message="Enter Low Threshold">
		</td>
		<td class="borderq">High Threshold</td>
		<td class="border">
		<cfinput type="text" class="inputtext" size=12 maxlength="12" name="high_thresh" value="#numberformat(high_thresh,'9,999')#">
		
	</tr>
	<tr>
		<td class="border" colspan=4 align="center">
		<input type="submit" class="button" value="#buttontext#">
		<cfif buttontext EQ "Update">
			&nbsp;&nbsp;<input class="button" type="button" value="Clear Entry" onClick="JavaScript: window.location.href='#self#?fuseaction=app.Admin_DeleteThreshold&id_threshold=#id_threshold#';">
		</cfif>
		</td>
	</tr>
</table>

</cfform>
</cfif>
</cfoutput>
<!--- **********************************************************  --->
<!---        Listing of all current Thresholds                     --->
<!--- ********************************************************** --->
<table cellpadding=2 cellspacing=2 class="border">
<tr>
	<td colspan=2>&nbsp;</td>
	<td class="bluehdr" align="center" colspan=4>Risk Level 1 (Low Risk)</td>
	<td class="bluehdr" align="center"  colspan=3>Risk Level 2 (Medium Risk)</td>
	<td class="bluehdr" align="center">Risk Level 3 (High Risk)</td>
	<!--<td class="bluehdr" align="center" colspan=3>Risk Level 4 (High Risk)</td>-->
</tr>
<tr>
<!-- 1 --><td valign="bottom" colspan=2 class="border" nowrap><b>ARA User Roles<br>In Approval Order</b></td>
<!-- 2 --><td width=50 class="blue" align="center" bgcolor="#8B939B" valign="bottom"><img src="images/AwardandIncentiveFees_gray.png"></td>
<!-- 3 --><td class="blue" align="center" bgcolor="#8B939B" valign="bottom"><img src="images/ModificationPending1_gray.png" align="center"></td>
<!-- 4 --><td class="blue" align="center" bgcolor="#8B939B" valign="bottom"><img src="images/PeriodofPerformance_gray.png"></td>
<!-- 5 --><td class="blue" align="center" bgcolor="#8B939B" valign="bottom"><img src="images/LetterContractandATP_gray.png"></td>
<!--- start of Risk Level 2 --->
<!-- 7 --><td class="blue" align="center" bgcolor="#8B939B" valign="bottom"><img src="images/ModificationPending2_gray.png"></td>
<!-- 8 --><td class="blue" align="center" bgcolor="#8B939B" valign="bottom"><img src="images/ChangeinExisting SOW_gray.png"></td>
<!-- 9 --><td class="blue" align="center" bgcolor="#8B939B" valign="bottom"><img src="images/PreviousRIExperience_gray.png"></td>
<!--- start of Risk Level 3 --->
<!-- 10 --><td class="blue" align="center" bgcolor="#8B939B" valign="bottom"><img src="images/Pre-Contract_Costs_gray.png"></td>    

</tr>

<cfquery name="g_jobs" datasource="#Application.dsn#">
	Select * from jobTitle
	Where appOrder IS NOT NULL
	Order By appOrder
</cfquery> 

<cfoutput query="g_jobs"><!--- Job Approver List --->
<tr <cfif isDefined('url.id_job') AND (url.id_job EQ id_job)>bgcolor="##EEEEEE"</cfif>>
	<td class="tcell">#apporder#.</td> 
	<td class="tcell">#title#
	<cfif ListFind('13,14,15,18,19,20,24,26',id_job)>
		<cfquery name="HIups" datasource="#Application.dsn#">
			Select oprid
			from v_users
			where id_job=#id_job#
			and inactive=0
		</cfquery>
		<cfif HIUps.recordcount GT 0>
		<cfelse>
			(undefined)
		</cfif>
	</cfif>
	
	</td><!-- Job Title -->
	<cfset cat_ids="1,2,4,5,7,8,9,10,6">
	<cfset riskLevels="1,2,3">
	<cfset riskCols="4,3,1">
	<cfset loopcount=1>
	<cfloop index="r" list="#riskLevels#">
		<td colspan="#ListGetAt(riskcols,loopcount)#" align="center"  
		<cfif (isDefined('url.id_job') AND (url.id_job EQ id_job)) AND (isDefined('url.riskLevel') and (url.riskLevel EQ r))>class="thiscell"
		<cfelse>class="tcell"</cfif>>
				<!--- Get thresholds for that id_job  --->
				<cfquery name="g_job_thresh" datasource="#application.dsn#">
					Select * from thresholds
					where id_job=#id_job#
					and riskLevel=#r#
		
				</cfquery>
				<!--- cfif Find('1', cat_List)---><!--- have threshold --->
				<cfif g_job_thresh.recordcount GT 0>
					<cfset id_threshold=g_job_thresh.id_threshold>
					<cfinclude template="../../model/m_ara/qry_getThresholds.cfm">
					<cfif #session.id_role# EQ 2><!--- Corporate User can change --->
					<a class="embed"
					 href="index.cfm?fuseaction=app.Admin_thresholdsV2&id_threshold=#id_threshold#&riskLevel=#r#&id_job=#id_job#&faction=app.Admin_UpdateThreshold">#line1#
					<cfelse><!--- View Only --->
					#line1#
					</cfif>
					&nbsp;
					#line2#</a>
				<cfelse><!--- do not have threshold, give opportunity to add --->
					<cfif #session.id_role# EQ 2><!--- Corporate User can add --->
					<a class="embed"
					href="index.cfm?fuseaction=app.Admin_thresholdsV2&risklevel=#r#&id_job=#id_job#&AddNew=Yes&faction=app.Admin_InsertThreshold">+</a>
					<cfelse>
					&nbsp;
					</cfif>
				</cfif>		
		</td>
		<cfset loopcount=#loopcount# + 1>
	</cfloop>
</tr>
</cfoutput>
</table>
<p></p>
	<a href="https://hii.sharepoint.us/sites/Command_Media/Procedures/Forms/AllItems.aspx?id=%2Fsites%2FCommand%5FMedia%2FProcedures%2FTSO%2DC101%2Epdf&parent=%2Fsites%2FCommand%5FMedia%2FProcedures" target="_blank">Contract At Risk Authorization/Risk Inventory Procedure </a>
<p></p>
<img src="images/riskLevelNote.jpg">
