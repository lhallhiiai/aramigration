<cfswitch expression="#blank#">
	<cfcase value="yes"> 
		<cfinclude template="lay_blank.cfm" />
	</cfcase>
	<cfcase value="view"> 
		<cfinclude template="lay_view.cfm" />
	</cfcase>
	<cfcase value="small"> 
		<cfinclude template="lay_window.cfm" />
	</cfcase>
	<cfdefaultcase>
		<cfinclude template="lay_main.cfm" />
	</cfdefaultcase>
</cfswitch>