<!--- Get the PM, Controller, Contracts Persons in this sector and group
      that will be the key creators of this ARA. These key creators
	  may be creating ARAs across organizational boundaries. --->
	  
<cffunction name="Get_PM">
	  <!--- PMs should allow for PMs as well as division managers to submit --->
	  
	  <cfquery name="GetPM" datasource="#Application.dsn#">
	  
	  	Select * from v_Users
		where grp IS NOT NULL <!--- --(sctr='#sector#' AND sctr IS NOT NULL)--->
		<!--- and grp='#group#' --->
		and (id_job=1) or (id_job=4)
		and Inactive='False'
		order by last_name
	  </cfquery>
	 
	 <!--- Contract Managers in same group or division --->
</cffunction>

<cffunction name="Get_Contract">  
	  <cfquery name="GetContract" datasource="#Application.dsn#">
	  
	  	Select * from v_Users
		where <!---grp IS NOT NULL --(sctr='#sector#' AND sctr IS NOT NULL)--->
		<!--- and grp='#group#' --->
		(id_job=2) and oprid is not null 
		and Inactive='False'
		order by empname
	  </cfquery> 
</cffunction>
<!---<cfdump var="#Get_Contract#">--->
<cffunction name="get_Controller">  
	  <!--- Controller in same group or division --->
	  
	  <cfquery name="GetController" datasource="#Application.dsn#">
	  
	  	Select * from v_Users
		where <!---grp IS NOT NULL --(sctr='#sector#' and sctr IS NOT NULL)--->
		(id_job=3) and oprid is not null 
		and Inactive='False'
		order by empname
	  </cfquery>
	  
</cffunction>