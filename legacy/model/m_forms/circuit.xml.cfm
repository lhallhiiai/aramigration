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
	<fuseaction name="prePop">
		<include template="prePop" />
	</fuseaction>

	<fuseaction name="insNewARA">
		<include template="insNewARA" />
	</fuseaction>

	<fuseaction name="reject">
		<include template="reject" />
	</fuseaction>
	
    <fuseaction name="PM_submit">
		<include template="PM_submit" />
	</fuseaction>
    
	<fuseaction name="PM_cancel">
		<include template="PM_cancel" />
	</fuseaction>
	
	<fuseaction name="AdminCancel">
		<include template="qry_AdminCancel" />
	</fuseaction>
	
	<fuseaction name="ClinEarlyStartComplete">
		<include template="ClinEarlyStartComplete" />
	</fuseaction>
    	
	<fuseaction name="CM_submit">
		<include template="CM_submit" />
	</fuseaction>
		
	<fuseaction name="clin_prePop">
		<include template="clin_prePop" />
	</fuseaction>

	<fuseaction name="Clin_submit">
		<include template="Clin_submit" />
	</fuseaction>

	<fuseaction name="Clin_Update">
		<include template="Clin_Update" />
	</fuseaction>
	
	<fuseaction name="Clin_Delete">
		<include template="Clin_Delete" />
	</fuseaction>
	
	<!-- Update Controller and Contract Manager -->
	<fuseaction name="PMCMCON_Update">
		<include template="PMCMCon_Update" />
	</fuseaction>
	
	<!-- Controller TAB -->
	<fuseaction name="Con_insert">
		<include template="Con_insert" />
	</fuseaction>
	
	<fuseaction name="Con_update">
		<include template="Con_update" />
	</fuseaction>
	<fuseaction name="Con_submit">
		<include template="Con_submit" />
	</fuseaction>
	
	
	<fuseaction name="getfile">
		<include template="act_getfile" />
	</fuseaction>
	
	<fuseaction name="getdoc">
		<include template="qry_getDoc" />
	</fuseaction>
		
	<fuseaction name="approve">
		<include template="approve" />
	</fuseaction>
		
</circuit>
