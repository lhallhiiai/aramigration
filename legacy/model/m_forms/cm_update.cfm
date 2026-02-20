<!---          Update Contract Managers Tab            --->
<cffunction name="Clean"><!--- Cleans out $(dollar signs) and commas from money values ---> 
	<cfargument required="yes" name="Value">
	<cfset value=Replace(Value,'$','',"All")><!--- Remove dollar signs --->
	<cfset value=Replace(Value,',','',"All")><!--- Remove commas --->
	<cfreturn value>
</cffunction>
<!--- Get rid foo commas in number --->
<cfset form.PCCostAuth=Clean(form.PCCostAuth)>
<cfparam name="id_ara_cm" default=6>
<cfoutput>In update and id_ara_cm is #id_ara_cm#<br></cfoutput>
<cfset ara_id="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cfquery name="UpdCM" datasource="#Application.DSN#">
	Update ara_cm
	set 
	id_customerType=#id_customerType#,
	contractType='#contractType#',
	authStart='#dateformat(authStart,"MM/DD/YYYY")#',
	executionDate='#dateformat(executionDate,"MM/DD/YYYY")#',
	customerPO='#customerPO#',
	POContactDate='#dateformat(POContactDate,"MM/DD/YYYY")#',
	PCCostAuth=#PCCostAuth#,
	<cfif isDefined('FundstoSupport')><!--- radio might not be there --->
	fundsToSupport=#fundsToSupport#,
	</cfif>
	fundsExplanation='#fundsExplanation#',
	<cfif isDefined('CreditCheck')><!--- radio might not be there --->
	creditCheck=#creditCheck#,
	</cfif>
	creditExplanation='#creditExplanation#',
	<cfif isDefined('allApprovals')><!--- radio might not be there --->
	allApprovals=#allApprovals#,
	</cfif>
	allApprovalsExplanation='#allApprovalsExplanation#',
	<cfif isDefined('forwarded')><!--- radio might not be there --->
	forwarded=#forwarded#,
	</cfif>
	forwardedExplanation='#forwardedExplanation#',
	<cfif isDefined('workAuthorization')><!--- radio might not be there --->
	workAuthorization=#workAuthorization#,
	</cfif>
	workAuthorizationExplanation='#workAuthorizationExplanation#',
	<cfif isDefined('authType')><!--- radio might not be there --->
	authType='#authType#',
	</cfif>
	<cfif isDefined('writtenConfirmation')><!--- radio might not be there --->
	writtenConfirmation=#writtenConfirmation#,
	</cfif>
	writtenConfirmationExplanation='#writtenConfirmationExplanation#',
	
	<cfif isDefined('alion_conf')><!--- radio might not be there --->
	alion_conf=#alion_conf#,
	</cfif>
	Alion_confExplanation='#Alion_confExplanation#',
	<cfif isDefined('anticipatoryCost')><!--- radio might not be there --->
	anticipatoryCost=#anticipatoryCost#,
	</cfif>
	anticipatoryCostExplanation='#anticipatoryCostExplanation#',
	<cfif anticipatedNegotiation NEQ "">
	anticipatedNegotiation='#dateformat(anticipatedNegotiation,"MM/DD/YYYY")#',
	<cfelse>
	anticipatedNegotiation='',
	</cfif>
   
    intClearCompDate='#intClearCompDate#',
    pop='#pop#',
    pop2='#pop2#',
    poolAmt='#Clean(poolAmt)#', 
    estFunDate='#estFunDate#' 
	where id_ara_cm=#id_ara_cm#
</cfquery>
