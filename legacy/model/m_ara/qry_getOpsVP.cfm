<!--- Get the OPs VPs in this sector and group --->
	  
<cffunction name="Get_OpsVP">
	  <!--- PMs should allow for PMs as well as division managers to submit --->
	  <cfquery name="GetOpsVP" datasource="#Application.dsn#">	  
	  	Select * from v_Users
		where id_job=17 and approve_GRP = '#form.alion_org#' 
		and Inactive='False'
		order by last_name
	  </cfquery>
	 
	 <cfdump var="#GetOpsVP#">
	 <cfabort>
</cffunction>
