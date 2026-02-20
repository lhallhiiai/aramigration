<!--- Gets list of all active users for announcements. MGann 4/16/2013 --->

<cfquery name="PubList" datasource="#Application.dsn#">
	SELECT oprid,email from v_users
	where inactive=0
	Order by last_name
</cfquery>


