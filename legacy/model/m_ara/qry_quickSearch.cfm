<!--- Quick Search Below Navaigation --->

<cfquery name="QS" datasource="#Application.dsn#">
 SELECT * From ara,status
 where reference LIKE '%#SearchString#%'
 or JamisNo LIKE '%#SearchString#%'
 and ara.id_status=status.id_status
 ORDER BY ara.id_status
 </cfquery>
 <p><cfoutput>
 Search string is #searchstring# and QS.recordcount is #QS.RecordCount#<br>
 <cfdump var="#QS#" format="text">
 </p>
 </cfoutput>
 <ol>
 <cfoutput query="QS">
 <li>ARA ID: #Reference#  CostPoint No: #ContractNO#
 </cfoutput>
 </ol>
 <cfif #QS.RecordCount# EQ 1><!--- Take directly to details --->
 	<cfset AID=#encrypt(QS.id_ara,request.encryptKey,request.encryptType,'hex')#>
   <cfswitch expression="#QS.id_status#">
   	<cfcase value="1,6,7,8,9,10,11,12">
	 	<cflocation url="index.cfm?Fuseaction=app.ARA_PM&AID=#AID#" Addtoken="No">
    </cfcase>
	<cfcase value="2,3"><!--- Submitted to contracts --->
		<cflocation url="index.cfm?Fuseaction=app.ARA_ContractInfo&SubMenu=Contract&AID=#AID#" Addtoken="No">
	</cfcase>
	<cfcase value="4,5"><!--- Submitted to Controller --->
		<cflocation url="index.cfm?Fuseaction=app.ARA_Controller&SubMenu=Controller&AID=#AID#" Addtoken="No">
	</cfcase>
   </cfswitch>
 <cfelse>
 	<cfinclude template="../../view/display/dsp_quickSearchResults.cfm">
 
 </cfif>