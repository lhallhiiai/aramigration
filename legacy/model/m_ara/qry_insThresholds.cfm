<cfset low_thresh=Replace(low_thresh,",","","all")><cfset low_thresh=Replace(low_thresh,"$","","all")>
<cfset high_thresh=Replace(high_thresh,",","","all")><cfset high_thresh=Replace(high_thresh,"$","","all")>
<cfdump var="#form#" format="text">
<cftransaction>
	<cfquery name="ins_thresh"  DATASOURCE="#Application.DSN#">
	INSERT INTO thresholds
		(riskLevel,
		id_job,
		low_thresh,
		high_thresh,
		review_approve,
		delegate,
		added_byoprid,
		added_on)
	VALUES
		(#riskLevel#,
		#id_job#,
		#low_thresh#,
		<cfif (high_thresh EQ "") OR (high_Thresh EQ 0)>
		null,
		<cfelse>
		#high_thresh#,
		</cfif>
		'#review_approve#',
		#delegate#,
		'#session.oprid#',
		'#dateformat(Now(),"MM/DD/YYYY")#'
		)
	</CFquery>
	<!---  Get the id for the new threshold  --->
	<cfquery name="GetID" datasource="#Application.dsn#">
		SELECT MAX(id_threshold) AS NewID
		FROM thresholds
	</cfquery>
	<cfset id_threshold = #GetID.NewID#>
</cftransaction>
<cfinclude template="qry_getThresholds.cfm">
<cfset confirmMsg="Threshold set for job title: #jobtitle#, for Risk Level #RiskLevel#.">
<cflocation url="index.cfm?fuseaction=app.Admin_thresholdsV2&riskLevel=#riskLevel#&id_job=#id_job#&ConfirmMsg=#ConfirmMsg#&this_riskLevel=#riskLevel#&this_id_job=#this_id_job#&action=Updatesetup">