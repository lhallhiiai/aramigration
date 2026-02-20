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
	<fuseaction name="get_roles">
		<include template="get_roles" />
	</fuseaction>
	
	<fuseaction name="get_users">
		<include template="get_users" />
	</fuseaction>
	
	<fuseaction name="insNewUser">
		<include template="insNewUser" />
	</fuseaction>
	
	<fuseaction name="UpdateUser">
		<include template="UpdateUser" />
	</fuseaction>
	<fuseaction name="DeleteUser">
		<include template="DeleteUser" />
	</fuseaction>
	
	<fuseaction name="checkID">
		<include template="qry_checkID" />
	</fuseaction>
	
	
		
</circuit>
