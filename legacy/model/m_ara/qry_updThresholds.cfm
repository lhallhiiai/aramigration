<!--- Update Threshold Value.
	 id_cat and id_job are fixed and not updatable. --->

<cfset low_thresh=Replace(low_thresh,",","","all")><cfset low_thresh=Replace(low_thresh,"$","","all")>
<cfset high_thresh=Replace(high_thresh,",","","all")><cfset high_thresh=Replace(high_thresh,"$","","all")>
<cfoutput>
high_thresh is #high_thresh#
</cfoutput>

<cftransaction>
<cfquery name="UpdThresh" datasource="#Application.dsn#">
	Update  Thresholds
	SET
	low_thresh=#low_thresh#,
	<cfif (high_thresh EQ "") OR (high_thresh EQ 0)>
		high_thresh=NULL,
	<cfelse>
		high_thresh=#high_thresh#,
	</cfif>
	review_approve='#review_approve#',
	delegate=#delegate#,
	modified_byoprid='#session.oprid#',
	modified_on='#dateformat(Now(),"MM/DD/YYYY")#'
	WHERE (id_threshold = #id_threshold#)
</cfquery>
</cftransaction>
<cfinclude template="qry_getThresholds.cfm">
<cfset confirmMsg="Threshold updated for job title: #jobtitle#, for Risk Level #RiskLevel#.">
<cflocation url="index.cfm?fuseaction=app.Admin_thresholdsV2&riskLevel=#RiskLevel#&id_job=#id_job#&ConfirmMsg=#ConfirmMsg#&this_riskLevel=#riskLevel#&this_id_job=#this_id_job#&action=Updatesetup">
