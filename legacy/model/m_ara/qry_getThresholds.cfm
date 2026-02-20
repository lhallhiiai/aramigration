<!--- Pull the threshold information --->
<cfif isDefined('id_threshold')>
	<cfset type="this_thresh">
<cfelse>
	<cfparam name="type" default="init">
</cfif>
<cfif type NEQ "init"><!--- need all thresholds info --->
	<cfquery name="g_thresh" datasource="#application.dsn#">
		SELECT     thresholds.id_threshold, thresholds.low_thresh, thresholds.high_thresh, 
				   thresholds.review_approve, thresholds.delegate, 
	               category.riskLevel, jobTitle.id_job, jobTitle.title as jobTitle, 
				   jobTitle.description, jobTitle.appOrder
	
		FROM       thresholds 
	               INNER JOIN category ON thresholds.riskLevel = category.RiskLevel 
	               INNER JOIN jobTitle ON thresholds.id_job = jobTitle.id_job
					and category.RiskLevel <> 0
		<cfif isDefined('id_threshold')>
			AND id_threshold=#id_threshold#
            and jobtitle.apporder is not null
		</cfif>   
		
		ORDER BY category.riskLevel, jobtitle.appOrder
		
	</cfquery>
<cfelse><!--- Pre-populate category and job title --->
	<cfquery name="rl" datasource="#application.dsn#">
		Select RiskLevel from category
		where riskLevel=#riskLevel# and risklevel <> 0
	</cfquery>
	<cfquery name="job" datasource="#application.dsn#">
		Select title, appOrder from Jobtitle
		where id_job=#id_job# and apporder is not null
	</cfquery>
</cfif>

<cfswitch expression="#Type#">
<cfcase value="init"><!--- Initialize blank variables, for new threshold --->
	<cfset id_threshold="">
	<cfset low_thresh="">
	<cfset High_Thresh="">
	<cfset review_approve="">
	<cfset delegate="">
	<cfset this_delegate="">
	<cfset this_review_approve="">
	<cfset id_cat="">
	<cfset RiskLevel="#rl.RiskLevel#">
	
	<cfset id_job="#id_job#">
	<cfset jobTitle="#job.title#">
	<cfset added_byoprid="#session.oprid#">
	<cfset added_on=dateformat(Now(),"MM/DD/YYYY")>
</cfcase>

<cfcase value="this_thresh"><!--- Initialize existing threshold --->
	<cfset id_threshold=g_thresh.id_threshold>
	<cfset low_thresh=g_thresh.low_thresh>
	<cfset high_thresh=g_thresh.high_thresh>
	<cfif high_thresh EQ "">
		<cfset line2="&ge; $#numberformat(low_thresh,'9,999')#">
	<cfelse>
		<cfset line2="&ge; $#numberformat(low_thresh,'9,999')# " & "&nbsp;&nbsp;&##8804;&nbsp;&nbsp;" & " $#numberformat(high_thresh,'9,999')#">
	</cfif>
	<cfset this_review_approve=g_thresh.review_approve>
	<cfset delegate=g_thresh.delegate>
	<!--- setup what will show in matrix --->
	<!--- &#8805; => Greater than or Equal to 
      	  &#8804; <= Less than or Equal to 
	      &lt; Less than
	      &gt; Greater than --->
	<cfif this_review_approve EQ "Review">
		<cfset line1="R ">
	<cfelseif this_review_approve EQ "Approve">
		<cfset line1="A ">
	<cfelse>
		<cfset line1="">
	</cfif>
	<cfif line1 NEQ "">
		<cfif delegate EQ 1>
			<cfset line1="#line1# " & "(d)">
			<cfset this_delegate=1>
		<cfelse>
			<cfset this_delegate=0>
		</cfif>
	</cfif>
	<cfset RiskLevel=g_thresh.RiskLevel>
	<cfset id_job=g_thresh.id_job>
	<cfset this_id_job=g_thresh.id_job>
	<cfset jobTitle=g_thresh.jobTitle>
	<cfset modified_byoprid=session.oprid>
	<cfset modified_on=dateformat(now(),"MM/DD/YYYY")>
</cfcase>
</cfswitch>
