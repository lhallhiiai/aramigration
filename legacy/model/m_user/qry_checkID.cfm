<!--- MGann This routine is run to check to see if the user has any associated records
      in the database. Example: If user has records of any kind -- cannot delete him from
	  the system --->

<cfparam name="id_user" default=3>
<cfset HasRecords=0>
<cfset id_list="ara.id_user,ara_cm.id_user,ara_con.id_user,
attachments.id_user,
araAppList.programManager,
araApplist.contractAdmin,
araApplist.controller,
araapplist.groupContractsManager,
araapplist.groupController,
araapplist.divisionManager,
araapplist.operationManager,
araapplist.groupManager,
araapplist.sectorContractsManager,
araapplist.sectorController,
araapplist.sectorManager,
araapplist.cao,
araapplist.cfo,
araapplist.coo">
<cfoutput>
<cfloop index="field" list="#id_list#">
	<cfset tbl=#gettoken(field,1,'.')#>
	<cfset col=#getToken(field,2,'.')#>
	Table is #tbl# and column is #col#<br>
	<cfquery name="CheckID" datasource="#Application.dsn#">
		Select #col#
	    from #tbl#
		where #col#=#id_user#
	</cfquery>
	<cfif #checkID.recordcount# GT 0>
		<cfset HasRecords=1>
		<cfbreak>
	</cfif>
</cfloop>
</cfoutput>