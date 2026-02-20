<cffunction name="GetAppList">
	<cfargument name="id_ara" required="yes">
	<cfquery name="AppList" datasource="#Application.DSN#">
		Select id_job,low_thrsh,High_thresh

</cffunction>