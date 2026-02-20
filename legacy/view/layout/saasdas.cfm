<cfQuery name="GetThreshold" datasource="#Application.dsn#">
		  	 SELECT     ara.id_ara, ara.id_cat, category.riskLevel, ara.amountTotal, thresholds.low_thresh, thresholds.high_thresh, 
           				jobTitle.title, jobTitle.appOrder, thresholds.id_job
			 FROM         

			ara INNER JOIN category ON ara.id_cat = category.id_cat 
			INNER JOIN thresholds ON category.riskLevel = thresholds.riskLevel 
			INNER JOIN jobTitle ON thresholds.id_job = jobTitle.id_job

			WHERE ara.id_ara=#id_ara#
			and jobtitle.id_job > 3
			<!--- and ara.AmountTotal Between (thresholds.low_thresh * 1000) and (thresholds.high_thresh * 1000) --->
			and thresholds.low_thresh <= ara.amountTotal
			
			Order by jobtitle.appOrder
	 	</cfquery>
		
		<cfif GetThreshold.RecordCount GT 0>
			<cfset Thresh_List=#ValueList(GetThreshold.id_job)#>
		<cfelse>
			<cfset Thresh_List="">
		</cfif>
		
		<cfset total_approve=#listLen(Thresh_List)#>