<cfif isDefined('id_ara')>
	<cfquery name="GetCM" datasource="#Application.dsn#">
		Select * from ARA_CM,customerType
		where id_ara=#id_ara#
		and ara_cm.id_customerType=customerType.id_customerType
	</cfquery>
	<cfif GetCM.Recordcount GT 0>
		<cfset id_ara_cm=GetCM.id_ara_cm>
		<cfset id_user=GetCM.id_user>
		<cfset id_customerType=GetCM.id_customerType>
		<cfset thisCustType=id_customerType>
		<cfset custdesc=GetCM.description>
		<cfset contractType=GetCM.contractType>
		<cfset thisCtype=ContractType>
       <cfif ContractType NEQ "CPFF" and ContractType NEQ "FFP" and ContractType NEQ "T&M" and ContractType NEQ "CP LOE">
       	<cfset otherType=ContractType>
       <cfelse>
       	<cfset otherType="">
       </cfif> 
		<cfset authStart=GetCM.authStart>
		<cfif authstart NEQ "">
			<cfset authstart=#dateformat(authstart,"MM/DD/YYYY")#>
		</cfif>
		<cfset executionDate=GetCM.executionDate>
		<cfif executionDate NEQ "">
			<cfset executionDate=#dateformat(executionDate,"MM/DD/YYYY")#>
		</cfif>
		<cfset customerPO=GetCM.customerPO>
		<cfset POContactDate=GetCM.POContactDate>
		<cfif POContactDate NEQ "">
				<cfset POContactDate=#dateformat(POContactDate,"MM/DD/YYYY")#>
		</cfif>
		<cfset PCCostAuth=#Trim(numberformat(GetCM.PCCostAuth,"9999"))#>
		<!--- cfset PCCostAuth=GetCM.PCCostAuth --->
		<cfset fundsToSupport=GetCM.fundsToSupport>
		<cfset fundsExplanation=GetCM.fundsExplanation>
		<cfset creditCheck=GetCM.creditCheck>
		<cfset creditExplanation=GetCM.creditExplanation>
		<cfset allApprovals=GetCM.allApprovals>
		<cfset allApprovalsExplanation=GetCM.allApprovalsExplanation>
		<cfset forwarded=GetCM.forwarded>
		<cfset forwardedExplanation=GetCM.forwardedExplanation>
		<cfset workAuthorization=GetCM.workAuthorization>
		<cfset workAuthorizationExplanation=GetCM.workAuthorizationExplanation>
		<cfset authType=GetCM.authType>
		<cfset writtenConfirmation=GetCM.writtenConfirmation>
		<cfset writtenConfirmationExplanation=GetCM.writtenConfirmationExplanation>
		<cfset alion_Conf=GetCM.alion_conf>
		<cfset Alion_confExplanation=GetCM.Alion_confExplanation>
		<cfset anticipatoryCost=GetCM.anticipatoryCost>
		<cfset anticipatoryCostExplanation=GetCM.anticipatoryCostExplanation>
		<cfset anticipatedNegotiation=Dateformat(GetCM.anticipatedNegotiation,"MM/DD/YY")>
     
        <cfif GetCM.intClearCompDate NEQ '1900-01-01 00:00:00.000'>
        	<cfset intClearCompDate=Dateformat(GetCM.intClearCompDate,"MM/DD/YY")>
        <cfelse>
        	<cfset intClearCompDate="">
        </cfif>
        <cfset pop=GetCM.pop>
        <cfset pop2=GetCM.pop2>
        <cfset poolAmt=GetCM.poolAmt>
         <cfif GetCM.estFunDate NEQ '1900-01-01 00:00:00.000'>
        	<cfset estFunDate=Dateformat(GetCM.estFunDate,"MM/DD/YY")>
        <cfelse>
        	<cfset estFunDate="">
        </cfif>
		<!--- cfset CACertification=Dateformat(GetCM.CACertification,"MM/DD/YY") --->
		<cfquery name="CMCert" datasource="#Application.dsn#">
			SELECT  araAppLog.id_ara, araAppLog.id_user, araAppLog.id_job, 
					araAppLog.id_status, users.id_user AS Expr1, users.empname, 
            		araAppLog.approvalDate
					
			FROM    araAppLog 
					INNER JOIN users ON araAppLog.id_user = users.id_user
			
			WHERE   araAppLog.id_status=2
		</cfquery>
		<cfif cmcert.recordcount GT 0>
			<cfset CACertification=#dateformat(cmcert.approvaldate,"MM/DD/YY")#>
			<cfset CertBy=#cmcert.empname#>
		</cfif>
	<cfelse><!--- initialize variables --->
	
		<cfset id_user="">
		<cfset id_customerType="">
		<cfset custdesc="">
		<cfset contractType="">
		<cfset authStart="">
		<cfset executionDate="">
		<cfset customerPO="">
		<cfset POContactDate="">
		<cfset PCCostAuth="">
		<cfset fundsToSupport="">
		<cfset fundsExplanation="">
		<cfset creditCheck="">
		<cfset creditExplanation="">
		<cfset allApprovals="">
		<cfset allApprovalsExplanation="">
		<cfset forwarded="">
		<cfset forwardedExplanation="">
		<cfset workAuthorization="">
		<cfset workAuthorizationExplanation="">
		<cfset authType="">
		<cfset writtenConfirmation="">
		<cfset writtenConfirmationExplanation="">
		<cfset alion_conf="">
		<cfset Alion_confExplanation="">
		<cfset anticipatoryCost="">
		<cfset anticipatoryCostExplanation="">
		<cfset anticipatedNegotiation="">
		<cfset CACertification="">
        <cfset intClearCompDate="">
		<cfset pop="">
		<cfset poolAmt="">
		<cfset estFunDate="">
	</cfif>
</cfif>