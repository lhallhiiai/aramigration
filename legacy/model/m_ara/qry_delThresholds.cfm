<cfinclude template="qry_getThresholds.cfm">
<cfset confirmMsg="Threshold deleted for job title: #jobtitle#, for Risk Level #riskLevel#.">
<cftransaction>
	<cfquery name="del_thresh"  DATASOURCE="#Application.DSN#">
	Delete from thresholds
	where id_threshold=#id_threshold#
	</CFquery>
</cftransaction>
<cflocation url="index.cfm?fuseaction=app.Admin_thresholdsV2&riskLevel=#riskLevel#&id_job=#id_job#&ConfirmMsg=#ConfirmMsg#&this_riskLevel=#riskLevel#&this_id_job=#this_id_job#">