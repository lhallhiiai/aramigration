
<!--- cfdump var="#session#" format="text" --->
<cfparam name="Faction" default="">
<cfset menu="admin">
<cfset submenu="Thresholds">
<!---<cfset session.id_role=1>--->
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
	<cfset title="Approval and Review Thresholds">
	<cfset buttontext="Submit">
</cfdefaultcase>
</cfswitch>
<p class="smtitle">Administration</p>
<p class="title"><cfoutput>#title#</cfoutput></p>
<cfinclude template="dsp_messages.cfm">
<cfoutput>


<cfif isDefined('id_threshold') or isDefined('Addnew')>
<!--- **********************************************************  --->
<!---   Start of Form to Insert or Update                        --->
<!--- ********************************************************** --->
<cfinclude template="../../model/m_ara/qry_getThresholds.cfm">
<cfform name="SetThresholds" id="SetThreholds" action="#self#?fuseaction=#faction#">
<cfif isDefined('url.id_cat')>
	<input type="hidden" name="id_cat" value="#url.id_cat#">
	<input type="hidden" name="id_job" value="#url.id_job#">
<cfelse>

</cfif>
<cfif isDefined('id_threshold')>
	<input type="hidden" name="id_threshold" value="#id_threshold#">
</cfif>
<table width=100% cellpadding=2 cellspacing=2 class="border">
	<tr>
		<td colspan=2 class="border">Category: <b>#Catname#</b></td>
		<td class="borderq">Risk Level</td>
		<td class="border"><b>#riskLevel#</b></td>
		<td class="borderq">Job Title</td>
		<td colspan=3 class="border"><b>#jobTitle#</b></td>
	</tr>
</table>
<table width=100% cellpadding=2 cellspacing=2 class="border">
	<tr>
		<td class="borderq">Low Threshold <br><font class="tiny">(in K: e.g. 100 for 100K)</font></td>
		<td class="border">
		<cfinput type="text" class="inputtext" size=6 maxlength="10" name="low_thresh" value="#low_thresh#" required="yes" Message="Enter Low Threshold">
		</td>
		<td class="borderq">High Threshold</td>
		<td class="border">
		<cfinput type="text" class="inputtext" size=6 maxlength="10" name="high_thresh" value="#high_thresh#" required="yes" Message="Enter High Threshold">
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
	<tr>
		<td class="border" colspan=6 align="center">
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
	<td colspan=2></td>
	<td class="bluehdr" align="center" colspan=3>Category 1 (Low Risk)</td>
	<td class="bluehdr" align="center" colspan=2>Category 2</td>
	<td class="bluehdr" align="center" colspan=2>Category 3</td>
	<td class="bluehdr" align="center" colspan=2>Category 4 (High Risk)</td>
</tr>
<tr>
	<!-- 1 --><td valign="bottom" colspan=2 class="border" nowrap><b>ARA Job Titles<br>In Approval Order</b></td>
	<!-- 2 --><td width=50 class="blue" align="center" bgcolor="#4b5c63" valign="bottom"><img src="images/MatrixHdrAwardFeesCat1.gif"></td>
	<!-- 3 --><td class="blue" align="center" bgcolor="#4b5c63" valign="bottom"><img src="images/MatrixHdrModPendingCat1.gif" align="center"></td>
	<!-- 4 --><td class="blue" align="center" bgcolor="#4b5c63" valign="bottom"><img src="images/MatrixHdrIntClearedCat1.gif"></td>
	<!-- 5 --><td class="blue" align="center" bgcolor="#4b5c63" valign="bottom"><img src="images/MatrixHdrModPendingCat2.gif"></td>
	<!-- 6 --><td class="blue" align="center" bgcolor="#4b5c63" valign="bottom"><img src="images/MatrixHdrCommCat2.gif"></td>
	<!-- 7 --><td class="blue" align="center" bgcolor="#4b5c63" valign="bottom"><img src="images/MatrixHdrScopeCat3.gif"></td>
	<!-- 8 --><td class="blue" align="center" bgcolor="#4b5c63" valign="bottom"><img src="images/MatrixHdrFixedCat3.gif"></td>
	<!-- 9 --><td class="blue" align="center" bgcolor="#4b5c63" valign="bottom"><img src="images/MatrixHdrModPendingCat4.gif"></td>
	<!-- 10 --><td class="blue" align="center" bgcolor="#4b5c63" valign="bottom"><img src="images/MatrixHdrPreContractCat4.gif"></td>
</tr>

<cfquery name="g_jobs" datasource="#Application.dsn#">
	Select * from jobTitle
	Order By appOrder
</cfquery> 

<cfoutput query="g_jobs"><!--- Job Approver List --->
<tr <cfif isDefined('url.id_job') AND (url.id_job EQ id_job)>bgcolor="##EEEEEE"</cfif>>
	<td class="tcell">#apporder#.</td> 
	<td class="tcell">#title#</td><!-- Job Title -->
	<cfset cat_ids="1,2,4,5,6,7,8,9,10">
	<cfloop index="c" list="#cat_ids#">
		<td align="center"  
		<cfif (isDefined('url.id_job') AND (url.id_job EQ id_job)) AND (isDefined('url.id_cat') and (url.id_cat EQ c))>class="thiscell"
		<cfelse>class="tcell"</cfif>>
				<!--- Get thresholds for that id_job  --->
				<cfquery name="g_job_thresh" datasource="#application.dsn#">
					Select * from thresholds
					where id_job=#id_job#
					and id_cat=#c#
					order by id_cat
				</cfquery>
				<!--- cfif Find('1', cat_List)---><!--- have threshold --->
				<cfif g_job_thresh.recordcount GT 0>
					<cfset id_threshold=g_job_thresh.id_threshold>
					<cfinclude template="../../model/m_ara/qry_getThresholds.cfm">
					<cfif #session.id_role# EQ 1><!--- Corporate User can change --->
					<a class="embed"
					 href="index.cfm?fuseaction=app.Admin_thresholds&id_threshold=#id_threshold#&id_cat=#c#&id_job=#id_job#&faction=app.Admin_UpdateThreshold">#line1#</a>
					<cfelse><!--- View Only --->
					#line1#
					</cfif>
					<br>
					#line2#
				<cfelse><!--- do not have threshold, give opportunity to add --->
					<cfif #session.id_role# EQ 1><!--- Corporate User can add --->
					<a class="embed"
					href="index.cfm?fuseaction=app.Admin_thresholds&id_cat=#c#&id_job=#id_job#&AddNew=Yes&faction=app.Admin_InsertThreshold">+</a>
					<cfelse>
					&nbsp;
					</cfif>
				</cfif>		
		</td>
	</cfloop>
</tr>
</cfoutput>
</table>
