
<cfparam name="MsgText" default="">
<cfset ID_EMAILTYPE =2>

<!--- ********************************************************* --->
<!---    MGann 10/25/11 All actions associated with delegation   --->
<!--- ********************************************************* --->
<cffunction name="rule1">
	<!--- Rule 1: Don't allow if Delegate_To has a delegation in effect.
	      We will only allow one level of delegation --->
	<cfquery name="CheckDelegate_To" datasource="#application.dsn#">
		Select * from delegation
		where fk_delegateFrom_ID=#Form.fk_delegateTo_ID#
		AND ((startDate between '#Form.StartDate#'   and '#form.EndDate#') 
		OR (endDate between '#Form.StartDate#'   and '#form.EndDate#'))
	</cfquery>
	<cfdump var="#CheckDelegate_To#" format="text"><cfabort>
	<cfif #CheckDelegate_To.RecordCount# GT 0>
		<cfoutput>
		<cfset errorMsg="#CheckDelegate_To.delegateTo_Oprid# has a delegation in effect during this timeframe. ARA only allows one level of delegation authority.">
		<cflocation url="index.cfm?Fuseaction=app.AdminDelegate&errorMsg=#errorMsg#"  ADDTOKEN="No">
		</cfoutput>
	</cfif>

</cffunction>
<cffunction name="rule2">
<!--- Rule 2: Do not Allow multiple Delegate TO during same time frame --->
	<cfquery name="CheckDelegate_From" datasource="#application.dsn#">
		Select * from delegation
		where fk_delegateFrom_ID=#Form.fk_delegateFrom_ID#
		AND ((startDate between '#Form.StartDate#'   and '#form.EndDate#') 
		OR (endDate between '#Form.StartDate#'   and '#form.EndDate#'))
	</cfquery>
	<cfoutput>
	<cfdump var="#CheckDelegate_From#" format="text">
	</cfoutput>
	<cfif #CheckDelegate_From.Recordcount# GT 0>
		<cfoutput>
		<cfset errorMsg="#Ucase(CheckDelegate_From.delegateFrom_oprid)# already has a delegation in effect for this time period ">
		<cfset errorMsg=errorMsg &  '(#dateformat(Form.StartDate,"MM/DD/YY")# - #dateformat(Form.EndDate,"MM/DD/YY")#). You can only delegate to one person during a timeframe.'>
		<cflocation url="index.cfm?Fuseaction=app.AdminDelegate&ThisDel=#CheckDelegate_From.id_delegation#&errorMsg=#errorMsg#"  ADDTOKEN="No">
		</cfoutput>
	</cfif>
</cffunction>


<cffunction name="delinfo">
	<cfargument name="getid_delegation" Required="No">
	<cfif isDefined('getid_delegation') and #getid_delegation# NEQ "">
		<cfquery name="GetDel" datasource="#application.dsn#">
			Select * from Delegation
			where id_delegation='#getid_delegation#'
		</cfquery>
		<!--- cfdump var="#GetDel#" format="text" --->
		<cfset fk_delegateFrom_ID=GetDel.fk_delegateFrom_ID>
		<cfset fk_delegateTo_ID=GetDel.fk_delegateTo_ID>
		<cfset delegateFrom_oprid=GetDel.delegateFrom_oprid>
		<cfset delegateTo_oprid=GetDel.delegateTo_oprid>
		<cfset StartDate=Dateformat(GetDel.StartDate,"MM/DD/YYYY")>
		<cfset EndDate=Dateformat(GetDel.EndDate,"MM/DD/YYYY")>
		<cfset dateadded=dateformat(GetDel.dateadded,"MM/DD/YY")>
		<cfset addedBy=GetDel.addedby>
		<cfif getDel.datemodified NEQ "">
			<cfset datemodified=#dateformat(getDel.datemodified,"MM/DD/YY")#>
		<cfelse>
			<cfset datemodified="">
		</cfif>
		<cfset modifiedby=GetDel.modifiedby>
	<cfelse>
		<cfset fk_delegateFrom_ID="">
		<cfset fk_delegateTo_ID="">
		<cfset delegateFrom_oprid="">
		<cfset delegateTo_oprid="">
		<cfset StartDate="">
		<cfset EndDate="">
		<cfset dateadded=dateformat(Now(),"MM/DD/YY")>
		<cfset addedBy=session.id_user>
		<cfset datemodified="">
		<cfset modifiedby="">
	</cfif>
	<cfreturn>
</cffunction>
		
<cfswitch Expression="#Action#">
<!-- N E W:   New Delegation -->
<CFCASE VALUE="InsertSetup">
	 	<!---  Initialize all form fields  --->
		<cfset Delegation=#delinfo()#>
		<Cfset buttontext = "Add Delegation">
		<cfset action="InsertRecord"><!--- reflects next action --->
</CFCASE>

<!---  U P D A T E   S E T U P --->
<cfcase value="UpdateSetup">
	<cfset Delegation=#delinfo(id_delegation)#>
	<cfset PageTitle="Update Delegation">
	<cfset smtitle="Delegation">
	<cfset buttontext="Update Delegation">
	<cfset title="Update Delegation">
	<cfset action="UpdateRecord">
</cfcase>

<!---  D E L E T E    S E T U P --->
<cfcase value="DeleteSetup">
	<cfset Delegation=#delinfo(id_delegation)#>
	<cfset warningMsg="Clicking on delete, will permanantly delete this delegation from ARA.">
	<cfset smtitle="Delete">	
	<cfset title="Delete Delegation">	
	<cfset action="DeleteRecord">
	<cfset buttontext="Delete">
</cfcase>
<!-- *******************************************************************
                  Delegation  EXECUTE ACTIONS    
								  
 *********************************************************************** -->
 <!---  INSERT Delegation --->
<cfcase value="InsertRecord">
	<cfset PageTitle = "Add Delegation Schedule">
	<cfset rule1check=#rule1()#><!--- Only one level of delegation --->
	<cfset rule2check=#rule2()#><!--- Only one delegation in time frame --->
	
	
	
	<cfquery name="getOpr" datasource="#application.dsn#">
		Select oprid as delegateFrom_oprid from users 
		where id_user=#fk_delegateFrom_ID#
	</cfquery>
	<cfset delegateFrom_oprid=getOpr.delegateFrom_oprid>
	<cfquery name="getOpr" datasource="#application.dsn#">
			select oprid as delegateTo_oprid from users 
			where id_user=#fk_delegateTo_ID#
	</cfquery>
	<cfset delegateTo_oprid=getOpr.delegateTo_oprid>
	<cfdump var="#getOpr#" format="text">
	
	
	<cftransaction>
		<cfquery name="AddDelegation" datasource="#application.dsn#">
			Insert Into Delegation
			(fk_delegateFrom_ID,fk_delegateTo_ID,delegateFrom_oprid,delegateTo_oprid,startDate,EndDate,dateadded,addedby)
			Values
			(#fk_delegateFrom_ID#,#fk_delegateTo_ID#,'#delegateFrom_oprid#','#delegateTo_oprid#','#Dateformat(startDate,"MM/DD/YY")#',
			'#Dateformat(EndDate,"MM/DD/YY")#','#Dateformat(now(),"MM/DD/YY")#',#session.id_user#)
		</cfquery>
		<cfquery name="getID" datasource="#application.dsn#">
			Select Max(id_delegation) as newdel From delegation
		</cfquery>
		<cfset id_delegation = #getID.newdel#>	
	</cftransaction>
	<cfset Delegation=#delinfo(id_delegation)#>
	<cfset Subject="ARA Delegation: #UCASE(delegateFrom_oprid)# Delegated to #UCASE(delegateTo_oprid)#">
	<cfset Subject=#Subject# & " #dateformat(startDate,'MM/DD/YY')# - #dateFormat(endDate,'MM/DD/yy')#">
	<cfset title=#subject#>
	
	<cfset shortDesc="#Ucase(delegateFrom_oprid)#" & " approval authority delegated to " & "#Ucase(delegateTo_oprid)#">
	<cfset MsgText="<b>#Ucase(delegateFrom_oprid)#</b> has delegated his/her authority ARAs
	to <b>#Ucase(delegateTo_oprid)#</b>.  This delegation of authority is valid for the period #dateformat(startDate,'MM/DD/YY')# through #dateformat(EndDate,'MM/DD/YY')#.  Both #Ucase(delegateFrom_oprid)# and #UCASE(delegateTo_oprid)#  will be notified via email when ARAs change status or progress in the approval cycle.
">  
	<cfinclude template="../m_emails/mail_Delegation.cfm">
	
	<cfset confirmMsg="Approval authority for <b>#getDelegateFromEmail.email#</b> has been delegated to <b>#getDelegateToEmail.email#</b>">
	<cfset confirmMsg=confirmMsg & " from #startdate# - #enddate#.">
	<cflocation url="index.cfm?fuseaction=app.AdminDelegate&Action=Updatesetup&thisdel=#id_delegation#&id_delegation=#id_delegation#&fk_delegateFrom_ID=#fk_delegateFrom_ID#&thisid_user=#fk_delegateFrom_ID#&confirmMsg=#confirmMsg#"  ADDTOKEN="No">
</cfcase>
<!---  ******************** UPDATE DELEGATION  ********************** --->
<CFCASE VALUE="UpdateRecord">
	<cfset title="Updated Delegation">
	<cfoutput>Delegate_To is #fk_delegateTo_ID#</cfoutput>
	<cftransaction>
		<cfquery name="oprid" datasource="#application.dsn#">
			select oprid from users where id_user=#fk_delegateTo_ID#
		</cfquery>
		<cfquery name="UpdDel" datasource="#application.dsn#">
			Update Delegation
			Set 
			fk_delegateTo_ID=#fk_delegateTo_ID#,
			delegateTo_oprid='#oprid.oprid#',
			startDate='#dateformat(startDate,'MM/DD/YYYY')#',
			endDate='#dateformat(endDate,'MM/DD/YYYY')#',
			modifiedby=#session.id_user#,
			datemodified='#dateformat(Now(),"MM/DD/YY")#'
			where id_delegation=#id_delegation#
		</cfquery>
	</cftransaction>
	
	<cfset Delegation=#delinfo(id_delegation)#>
	<cfset Subject="ARA Delegation Updated: #UCASE(delegateFrom_oprid)# Delegated to #UCASE(delegateTo_oprid)#">
	<cfset Subject=#Subject# & " #dateformat(startDate,'MM/DD/YY')# - #dateFormat(endDate,'MM/DD/yy')#">
	<cfset title=#subject#>
	<cfset shortDesc="Updated: #Ucase(delegateFrom_oprid)#" & " approval authority delegated to " & "#Ucase(delegateTo_oprid)#">
	<cfset MsgText="The delegation from <b>#Ucase(delegateFrom_oprid)#</b>
	to <b>#Ucase(delegateTo_oprid)#</b> has been updated.  This delegation of authority is valid for the period (#dateformat(startDate,'MM/DD/YY')# through #dateformat(EndDate,'MM/DD/YY')#).  Both #Ucase(delegateFrom_oprid)# and #UCASE(delegateTo_oprid)#  will be notified via email when ARAs change status or progress in the approval cycle.
">  <cfinclude template="../m_emails/mail_delegation.cfm">
	<cfset ConfirmMsg="Delegation Updated.">
	
	<cflocation url="index.cfm?fuseaction=app.AdminDelegate&Action=Updatesetup&id_delegation=#id_delegation#&thisdel=#id_delegation#&thisid_user=#fk_delegateFrom_ID#&confirmMsg=#Subject#&Menu=delegate&Submenu="  ADDTOKEN="No">
	
</CFCASE>

<!---  ******************** DELETE Delegation  ********************** --->
<CFCASE VALUE="DeleteRecord"> 
	<cfset title="Delete Delegation">
	<cfoutput>I am in delete and is is #id_delegation#</cfoutput>
	<cfset thisInfo=#delinfo(id_delegation)#>
	<cfquery name="DelDel" datasource="#application.dsn#">
		delete  from delegation
		Where id_delegation=#id_delegation#
	</cfquery>
	<cfquery name="ChkDel" datasource="#application.dsn#">
		Select * from delegation
		where id_delegation=#id_delegation#
	</cfquery>
	<cfif #chkdel.recordcount# GT 0>
		<cfset errorMsg="Unable to delete delegation. Call CAE.">
		<cflocation url="index.cfm?fuseaction=admin.delegate&menu=delegate&errormsg=#errorMsg#"  ADDTOKEN="No">
    <cfelse>
	<cfset subject="#Ucase(delegateFrom_oprid)# Delegation to #Ucase(delegateTo_oprid)# Deleted.">
	<cfset shortDesc="#Ucase(delegateFrom_oprid)# delegation of approval authority deleted.">
<cfset MsgText="
The delegation of approval authority from <b>#ucase(delegateFrom_oprid)#</b> to <b>#ucase(delegateTo_oprid)#</b>,
that was in effect from #dateformat(startDate,'MM/DD/YY')# until #dateformat(endDate,'MM/DD/YY')#
has been deleted. ARA's will proceed through the original designations.

">
	<cfinclude template="../m_emails/mail_delegation.cfm">
	<cfset confirmMsg="Delegation assignment deleted.">
	<cflocation url="index.cfm?fuseaction=app.AdminDelegate&confirmMsg=#confirmMsg#"  ADDTOKEN="No">
	</cfif>
	
</CFCASE>

</cfswitch>