<cfset ara_id="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
<cffunction name="Clean2"><!--- Cleans out $(dollar signs) and commas from money values ---> 
        <cfargument required="yes" name="Value">
        <cfset value=Replace(Value,'$','',"All")><!--- Remove dollar signs --->
        <cfset value=Replace(Value,',','',"All")><!--- Remove commas --->
        <cfreturn value>
</cffunction>
<cfif isDefined('form.SaveCM')>
        <cfset id_status='3'><!--- still working and saving --->
<cfelse><!--- The Complete Submit button has been used --->
        <cfset id_status='4'><!--- CM done - submitted to controller  --->
</cfif>
<cfset confirmMsg="">
<cfif isDefined("form.otherType") and form.otherType NEQ "">
        <cfset contractType="#form.otherType#">
<cfelse>
        <cfset contractType="#form.contractType#">
</cfif>

<!--- Check to see if CM infomation has already been submitted --->
<cfquery name="ChkCM" datasource="#application.dsn#">
        SELECT * from ara_CM
        where id_ara=#ara_id#
</cfquery>
<cfif ChkCM.Recordcount EQ 0><!--- There is no contract info for this ARA --->
        <!--- Get rid foo commas in number --->
        <cfset form.PCCostAuth=Replace(form.PCCostAuth,'$','',"All")><!--- Remove dollar signs --->
        <cfset form.PCCostAuth=Replace(form.PCCostAuth,',','',"All")><!--- Remove commas --->
        
        <cfquery name="newCM" datasource="#application.dsn#">
                INSERT INTO ARA_CM
                        (id_ara,
                        id_user,
                        id_customerType,
                        contractType,
                        authStart,
                        executionDate,
                        customerPO,
                        POContactDate,
                        PCCostAuth,
                        <cfif isDefined('form.fundsToSupport')>
                        fundsToSupport,
                        </cfif>
                        fundsExplanation,
                        <cfif isDefined('form.creditCheck')>
                        creditCheck,
                        </cfif>
                        creditExplanation,
                        <cfif isDefined('form.allApprovals')>
                        allApprovals,
                        </cfif>
                        allApprovalsExplanation,
                        <cfif isDefined('form.forwarded')>
                        forwarded,
                        </cfif>
                        forwardedExplanation,
                        <cfif isDefined('form.workAuthorization')>
                        workAuthorization,
                        </cfif>
                        workAuthorizationExplanation,
                        <cfif isDefined('form.authType')>
                        authType,
                        </cfif>
                        <cfif isDefined('form.writtenConfirmation')>
                        writtenConfirmation,
                        </cfif>
                        writtenConfirmationExplanation,
                        <cfif isDefined('form.alion_conf')>
                        alion_conf,
                        </cfif>
                        Alion_confExplanation,
                        <cfif isDefined('form.anticipatoryCost')>
                        anticipatoryCost,
                        </cfif>
                        anticipatoryCostExplanation,
                        anticipatedNegotiation,
            intClearCompDate,
            pop,
            <cfif isDefined('form.pop2')>
            pop2,
            </cfif>
                        poolAmt, 
            estFunDate)
                VALUES
                        (<cfqueryparam cfsqltype="cf_sql_integer" value="#ara_id#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#form.id_customerType#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#contractType#">,
                        <cfqueryparam cfsqltype="cf_sql_date" value="#form.authStart#">,
                        <cfqueryparam cfsqltype="cf_sql_date" value="#form.executionDate#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.customerPO#">,
                        <cfqueryparam cfsqltype="cf_sql_date" value="#form.POContactDate#">,
                        '#Clean2(form.PCCostAuth)#',
                        <cfif isDefined('form.fundsToSupport')>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#form.fundsToSupport#">,
                        </cfif>
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.fundsExplanation#">,
                        <cfif isDefined('form.creditCheck')>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#form.creditCheck#">,
                        </cfif>
            <cfif isDefined('form.creditExplanation')>
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.creditExplanation#">,
            <cfelse>
                <cfqueryparam cfsqltype="cf_sql_varchar" value="">,
            </cfif>
                        <cfif isDefined('form.AllApprovals')>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#form.allApprovals#">,
                        </cfif>
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.allApprovalsExplanation#">,
                        <cfif isDefined('form.forwarded')>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#form.forwarded#">,
                        </cfif>
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.forwardedExplanation#">,
                        <cfif isDefined('form.workAuthorization')>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#form.workAuthorization#">,
                        </cfif>
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.workAuthorizationExplanation#">,
                        <cfif isDefined('form.authType')>
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.authType#">,
                        </cfif>
                        <cfif isDefined('form.writtenConfirmation')>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#form.writtenConfirmation#">,
                        </cfif>
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.writtenConfirmationExplanation#">,
                        <cfif isDefined('form.Alion_conf')>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#form.Alion_conf#">,
                        </cfif>
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.Alion_confExplanation#">,
                        <cfif isDefined('form.anticipatoryCost')>
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#form.anticipatoryCost#">,
                        </cfif>
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.anticipatoryCostExplanation#">,
                        <cfqueryparam cfsqltype="cf_sql_date" value="#form.anticipatedNegotiation#">,
        
            <cfqueryparam cfsqltype="cf_sql_date" value="#form.intClearCompDate#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.pop#">,
            <cfif isDefined('form.pop2')>
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.pop2#">,
            </cfif>
            <cfif isDefined('form.poolAmt')>
           '#Clean2(form.poolAmt)#', 
           <cfelse>
           '',
            </cfif>
                         <cfif isDefined('form.estFunDate')>
           '#dateformat(form.estFunDate, 'yyyy-mm-dd')#')
           <cfelse>
           '')
            </cfif>
            
        </cfquery>
    

        
<CFELSE><!--- Contract info already exists, we want to update --->
        <cfinclude template="cm_update.cfm">
</cfif>
<cfset confirmMsg="Contract Administrator information updated.">
        



<cfif id_status EQ 3><!--- Saving -- not submitted yet --->
        <cflocation addtoken="false" url="?fuseaction=app.ARA_ContractInfo&AID=#url.AID#&ConfirmMsg=#ConfirmMsg#">
        
        
<cfelse><!--- Submitted to next step:  controller --->
        <cfset ConfirmMsg="Contract information has been updated. This entry is now submitted to the controller and is no longer available for you to edit.">
        
        <!--- 1. Update contract certification date --->
        <cfquery name="newCM" datasource="#application.dsn#" result="result">
        UPDATE ARA
        SET
                id_status=#id_status#
        WHERE
                ID_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#ara_id#">
        </cfquery>
        
        <!--- 2. Update CACertification date --->
        <cfquery name="CaCert" datasource="#application.dsn#" result="result">
        UPDATE ARA_CM
        SET
                CACertification='#dateformat(Now(),"MM/DD/YYYY")#'
        WHERE
                ID_ara=<cfqueryparam cfsqltype="cf_sql_integer" value="#ara_id#">
        </cfquery>
        <cfset Comment="Step 2: Contract Administrator [#session.empname#] completed and approved.">
        <cfif session.delegators NEQ ""><!--- Delegatee may be approving --->
                <cfquery name="CheckDel" datasource="#application.dsn#">
                        Select * from delegation
                        where fk_delegatefrom_id=#ID_Contract# and fk_delegateTo_ID=#session.id_user#
                        AND (GETDATE() BETWEEN startDate AND endDate)
                </cfquery>
                <cfif CheckDel.recordcount GT 0>
                        <cfset id_job=2><!--- Show job as Contract Manager..delegatee might have job type of "Delegatee and we need to relate to approval chain --->
                        <cfset Comment="#Comment#" & " [Delegation From #CheckDel.DelegateFrom_Oprid# to #checkDel.Delegateto_Oprid#].">
                        <cfset oprid_delegateFrom=CheckDel.DelegateFrom_Oprid>
                        <cfset oprid_delegateTo=CheckDel.DelegateTo_Oprid>
                <cfelse>
                        <cfset id_job=session.id_job>
                </cfif>
        <cfelse>
                <cfset id_job=session.id_job>
        </cfif>
        <cfset Comment="#comment#" & " Submitted to controller.">
        <!--- Update Approval Log  --->
        <cfquery name="Approval" datasource="#application.dsn#" result="result">
                INSERT INTO ARAAppLog
                        (id_ara,
                        id_user,
                        id_job,
                        id_status,
                        cycle,
                        isRejection,
                        Comment,
                        approvalDate
                        <cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
                                ,oprid_delegatefrom
                                ,oprid_DelegateTo
                        </cfif>
                        )
                VALUES
                        (<cfqueryparam cfsqltype="cf_sql_integer" value="#ara_id#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.id_user#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#id_job#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="4">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#val(form.revision+1)#">,
                        'False',
                        '#comment#',
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                        <cfif isDefined('oprid_delegateFrom') and (oprid_delegateFrom NEQ "")>
                                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#oprid_delegatefrom#">
                                ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#oprid_DelegateTo#">
                        </cfif>)
        </cfquery>
        
        
        <!--- Get all of ara info, send email, return to main screen --->
        <cfset id_ara=#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#>
        <cfinclude template="../m_ara/qry_ara.cfm"><!---ara info including Jamis number --->
        <cfquery name="PM" datasource="#application.dsn#">
                Select empname from users
                where id_user=#session.id_user#
        </cfquery>
        <cfset id_emailtype=1>
        <cfset intro="Approved by Contract Administrator and Requires Your Input">
        <cfif session.delegators NEQ "">
                <cfset intro="#intro#" & "(Delegation from #CheckDel.DelegateFrom_Oprid# to #checkDel.Delegateto_Oprid#)."> 
        </cfif>
        <cfinclude template="../m_emails/mail_Approve.cfm">
        <cfset ConfirmMsg="Contract portion of ARA has been submitted. The controller will now provide Clins and Financial Information.">
        <cflocation addtoken="false" url="?fuseaction=app.ARA_ContractInfo&FormorView=View&AID=#url.AID#&ConfirmMsg=#ConfirmMsg#">
        
</cfif>
