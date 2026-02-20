<!--- Based on the ARA Category, this returns a list of the questions
      required for each tab.  --->
<cffunction name="RequiredQs">
	<cfargument name="id_cat" required="yes">
	<cfargument name="tab" required="yes">
	<!--- Pull Questions Based on id_cat and tab --->
	<cfquery name="GetQs" datasource="#Application.dsn#">
		Select * from cat_questions_map
		where catID_List Like '%|#id_cat#|%'
		and tab='#tab#'
	</cfquery>
	<cfset q_cnt=#GetQs.Recordcount#>
	<cfset q_list=#ValueList(GetQs.id_question)#>
</cffunction>