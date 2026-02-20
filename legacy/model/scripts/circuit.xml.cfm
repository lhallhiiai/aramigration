<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE circuit>
<!--
	Example circuit.xml file for the model portion of an application.
-->
<circuit access="internal">
	<fuseaction name="users">
		<include template="qry_users" />
	</fuseaction>
	
	<fuseaction name="ARAusers">
		<include template="qry_ARAusers" />
	</fuseaction>
	
	<fuseaction name="ARAusersShort">
		<include template="qry_ARAusersShort" />
	</fuseaction>
	
	<fuseaction name="delegatees">
    		<include template="qry_delegatees" />
	</fuseaction>
	
	<fuseaction name="org">
		<include template="qry_org" />
	</fuseaction>
	
	<fuseaction name="oms">
		<include template="qry_oms" />
	</fuseaction>
    
    <fuseaction name="eac">
		<include template="qry_eac" />
	</fuseaction>
	
	<fuseaction name="JamisNo">
		<include template="qry_JamisNo" />
	</fuseaction>
	
	<fuseaction name="ClinNum">
		<include template="qry_ClinNum" />
	</fuseaction>
    
    <fuseaction name="ARAUser">
		<include template="qry_araUser" />
	</fuseaction>
</circuit>


