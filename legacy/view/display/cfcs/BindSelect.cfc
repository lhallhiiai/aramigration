<!--- Get array of sectors --->
    <cffunction name="get_sector" access="remote" returnType="array">
        <cfargument name="orgcode" type="string" required="true">
        <!--- Define variables --->
        <cfset var result=ArrayNew(2)>
        <cfset var i=0>

        <!--- Get data --->
       
        <cfquery name="get_sector" datasource="cae_ods">
	SELECT *
	FROM org
	WHERE grp = ''
	ORDER by sctr
	</cfquery>
		<cfset result[1][1]="">
		<cfset result[1][2]="-- Select Sector --">

        <!--- Convert results to array --->
        <cfloop index="i" from="1" to="#get_sector.recordcount#">
            <cfset result[i+1][1]=get_sector.sctr[i]>
            <cfset result[i+1][2]=get_sector.sctr[i]>
        </cfloop>

        <!--- And return it --->
        <cfreturn result>
    </cffunction>

    <!--- Get array of groups --->
    <cffunction name="get_group" access="remote" returnType="array">
        <cfargument name="orgcode" type="string" required="true">
        <!--- Define variables --->

        <cfset var result=ArrayNew(2)>
        <cfset var i=0>

        <!--- Get data --->
        <cfquery name="get_group" datasource="cae_ods">
		SELECT *
		FROM org
		WHERE (sctr = '#ARGUMENTS.orgcode#')
		AND (oprtn = '')
		AND (grp != '')
		ORDER by grp
		</cfquery>

        <!--- Convert results to array --->
        <cfloop index="i" from="1" to="#get_group.recordcount#">
            <cfset result[i][1]=get_group.grp[i]>
            <cfset result[i][2]=get_group.grp[i]>
        </cfloop>


	<cfreturn result>

</cffunction>


    <!--- Get array of operations--->
    <cffunction name="get_operation" access="remote" returnType="array">
        <cfargument name="orgcode" type="string" required="true">
        <!--- Define variables --->

        <cfset var result=ArrayNew(2)>
        <cfset var i=0>

        <!--- Get data --->
        <cfquery name="get_operation" datasource="cae_ods">
	SELECT *
	FROM org
	WHERE (grp = '#ARGUMENTS.orgcode#')
	AND (dvsn = '')
	AND (oprtn != '')
	ORDER by oprtn
	</cfquery>

        <!--- Convert results to array --->
        <cfloop index="i" from="1" to="#get_operation.recordcount#">
            <cfset result[i][1]=get_operation.oprtn[i]>
            <cfset result[i][2]=get_operation.oprtn[i]>
        </cfloop>


	<cfreturn result>

</cffunction>





    <!--- Get array of divisions --->
    <cffunction name="get_division" access="remote" returnType="array">
        <cfargument name="orgcode" type="string" required="true">
        <!--- Define variables --->

        <cfset var result=ArrayNew(2)>
        <cfset var i=0>

        <!--- Get data --->
        <cfquery name="get_division" datasource="cae_ods">
	SELECT *
	FROM org
	WHERE (oprtn = '#ARGUMENTS.orgcode#')
	AND (cost_center = '')
	AND (dvsn != '')
	and org_type='Division'
	ORDER by dvsn
	</cfquery>

        <!--- Convert results to array --->
        <cfloop index="i" from="1" to="#get_division.recordcount#">
            <cfset result[i][1]=get_division.dvsn[i]>
            <cfset result[i][2]="#get_division.dvsn[i]#" & " -- #get_division.org_desc[i]#">
        </cfloop>


	<cfreturn result>

</cffunction>