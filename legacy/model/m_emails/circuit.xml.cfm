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
	<fuseaction name="delegation">
		<include template="mail_delegation" />
	</fuseaction>
	
	<fuseaction name="UserAccount">
		<include template="mail_UserAccount" />
	</fuseaction>
	<fuseaction name="MailDist">
		<include template="qry_MailDist" />
	</fuseaction>
	
	<fuseaction name="PubList">
		<include template="qry_CreatePublist" />
	</fuseaction>

	
</circuit>
