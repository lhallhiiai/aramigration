
<!--- Mgann: 1/27/2012  GET APPROVAL CHAIN
	  This is a rewrite to retrieve the chain of approval for ARA.
	  The Sector and Group tables were removed from the ARA DB, and
	  it was decided we should use the warehouse dynamically and not
	  define any org tables within the App. Plus we really had to delve
	  further into the org, down to the division to get what we needed.
	  
	  So I truly hope....this is the last rewite of the approval chain...
	  it is becoming a bit of a ball and chain.    --->

<cfparam name="thiscycle" default=1>


	  <!--- The PM, Contracts, and Controller are stored with the ARA
	        and are independent of amount. --->

	  <cfquery name="PMCC" datasource="#Application.dsn#">
	  		Select ID_PM, ID_Contract, ID_Controller
			from v_ara
			where id_ara=#id_ara#
	  </cfquery>
	  
	  <cfoutput>
	  <cfset PMCC_List="#PMCC.ID_PM#">
	  <cfset Originator=#PMCC.ID_PM#>
	  <cfif PMCC.ID_Contract EQ "">
	  	<cfset pmcc_list=ListAppend(PMCC_List,'0')>
	  <cfelse>
	  		<cfset pmcc_list=ListAppend(PMCC_List,PMCC.ID_Contract)>
	  </cfif>
	  
	  <cfif PMCC.ID_Controller EQ "">
	  	<cfset pmcc_list=ListAppend(PMCC_List,'0')>
	  <cfelse>
	  	<cfset pmcc_list=ListAppend(PMCC_List,PMCC.ID_Controller)>
	  </cfif>
	  </cfoutput>
<cfif NOT ListFind('13,14,15,16,17', id_status)>  <!--- Done. Exported, Negated, Negated Exported, Early Start Complete, Archived --->
	  <!--- Need to figure out where in the approval chain we are starting.
	        A PM or a Division  --->
	  <cfset ThisLevel=#Usr_Details(Originator)#>
	  <cfoutput>
	 
	  
	  <cfquery name="JobList" datasource="#Application.dsn#">
	  	Select id_job
		from JobTitle 
		where apporder IS NOT NULL
	    order by appOrder
	  </cfquery>
	  <cfset appList=#Valuelist(JobList.ID_job)#>
	
	  <!--- This job id is: #id_job#<br>
	  Jobs: #applist#, id_cat is #id_cat#<br> --->
	  </cfoutput>
	  
		
			
			
	  
	   <!---   Based on Amount, lookup levels of approvals required --->
	  <cfif AmountTotal GT 0><!--- then the amount has been filled in --->
	  	<cfQuery name="GetThreshold" datasource="#Application.dsn#">
		  	 SELECT     ara.id_ara, ara.id_cat, category.riskLevel, ara.amountTotal, thresholds.low_thresh, thresholds.high_thresh, 
           				jobTitle.title, jobTitle.appOrder, thresholds.id_job
			 FROM         

			ara INNER JOIN category ON ara.id_cat = category.id_cat 
			INNER JOIN thresholds ON category.riskLevel = thresholds.riskLevel 
			INNER JOIN jobTitle ON thresholds.id_job = jobTitle.id_job

			WHERE ara.id_ara=#id_ara#
			and jobtitle.apporder IS NOT NULL
			and jobtitle.id_job >= 1
			<!---and jobtitle.id_job NOT in (16,17,21,22,23) and jobtitle.appOrder is not null--->
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
	  </cfif>
<cfelse><!--- Has already gone through approval chain --->
	<!--- Is: Exported, Negated, Negated Exported, Early Start Complete, Archived --->
	<cfquery name="PriorApprovals" datasource="#Application.dsn#">
		SELECT   araAppLog.id_job, jobTitle.title, araAppLog.id_ara
		FROM     araAppLog INNER JOIN
                      jobTitle ON araAppLog.id_job = jobTitle.id_job
		where id_ara=#id_ara#
		and (id_status > 1 and id_status NOT IN (13,14,15,16,17))
		and cycle=#thisCycle#
		order by id_araAppLog
	</cfquery>
	<!---pppppppppppppppp PriorApprovals pppppppppppppppp<br>
	<cfdump var="#PriorApprovals#" format="text">--->
	<cfset Thresh_List=ValueList(PriorApprovals.id_job)>
	<cfset TitlesAtTimeOfApproval=ValueList(PriorApprovals.title)>
	<!---<ol>
	<cfloop index="n" list="#TitlesAtTimeofApproval#">
	<li><cfoutput>#n#</cfoutput></li>
	</cfloop>
	</ol>--->
</cfif>  
	  