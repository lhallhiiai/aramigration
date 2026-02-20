<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>
<!--
	Example circuit.xml file for the model portion of an application.
-->
<circuit access="internal">
	
	<!--
		Example model fuseaction that just references an action fuse.
		Model fuseactions should only reference actions and queries.
	-->
	<fuseaction name="externalDetails">
		<include template="externalDetails" />
	</fuseaction>

	<fuseaction name="internalDetails">
		<include template="internalDetails" />
	</fuseaction>
		
	<fuseaction name="approval_prePop">
		<include template="approval_prePop" />
	</fuseaction>

	<fuseaction name="getCurrentApprover">
		<include template="getCurrentApprover" />
	</fuseaction>
	
	<fuseaction name="admin_UpdateThreshold">
		<include template="qry_updThresholds" />
	</fuseaction>

	<fuseaction name="Admin_InsertThreshold">
		<include template="qry_insThresholds" />
	</fuseaction>
	
	<fuseaction name="Admin_DeleteThreshold">
		<include template="qry_delThresholds" />
	</fuseaction>
	
	<fuseaction name="DeleteEntireARA">
		<include template="DeleteEntireARA" />
	</fuseaction>
</circuit>
