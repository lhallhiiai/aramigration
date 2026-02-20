<!--- Email Sent to Core Team when Approved: PM, Contracts, Controller --->



<cfset id_emailType=1><!--- ara status change --->
<!--- cfset to="#gUsers.oprid#@hii-tsd.com" --->

<cfset From="ARA@hii-tsd.com"> 
	<cfquery name="Team" datasource="#application.dsn#">
		Select empname,oprid
		from v_users
		where id_user in ('#id_pm#', '#id_contract#','#id_controller#')
		order by id_job ASC
	</cfquery>
<!--- Core Team --->
	<cfquery name="Team_pm" datasource="#application.dsn#">
		Select empname,oprid
		from v_users
		where id_user='#id_pm#'
	</cfquery>
    <cfquery name="Team_cm" datasource="#application.dsn#">
		Select empname,oprid
		from v_users
		where id_user='#id_contract#'
	</cfquery>
    <cfquery name="Team_con" datasource="#application.dsn#">
		Select empname,oprid
		from v_users
		where id_user='#id_controller#'
	</cfquery>

	
	<cfset teamOprid=ValueList(Team.oprid)>
	<!--- names used in text of message --->
	<cfset pm_nm=Team_pm.empname>
	<cfset contract_nm=Team_cm.empname>
	<cfset controller_nm=Team_con.empname>
    
<cfoutput>#teamoprid#<br></cfoutput>
	<cfif id_status NEQ 10> <!--- this is not cancel --->
		<cfset status_list="2,4,5,6,8,9"><!--- Submitted to Contracts, Controller, Approval Chain --->
        <cfset team_index="1,2,3,3,1,1"><!--- Index to PM, Contracts, Controller --->
        <cfoutput>id_status is #id_status# listfind(status_list,id_status) is #listfind(status_list,id_status)# status_lis is #status_list# </cfoutput>
        <cfset delindex=listfind(status_list,id_status)><!--- what state are we in --->
        <cfset thisJob=ListGetAT(team_index,delindex)><!--- get delegation for that member of core team --->
        <cfquery name="DelMsg" datasource="#Application.dsn#">
            SElect delegateto_oprid
            from v_users
            where oprid='#ListGetAT(teamOprid,thisJob)#'
        </cfquery>
    <cfelse><!--- is a cancel --->
    	<cfset status_list="10"><!--- Cancelled --->
		<cfset team_index="1,2,3,3"><!--- Index to PM, Contracts, Controller --->
        <cfoutput>id_status is #id_status# listfind(status_list,id_status) is #listfind(status_list,id_status)# status_lis is #status_list# </cfoutput>
        <cfset delindex=listfind(status_list,id_status)><!--- what state are we in --->
        <cfset thisJob=ListGetAT(team_index,delindex)><!--- get delegation for that member of core team --->
        <cfquery name="DelMsg" datasource="#Application.dsn#">
            SElect delegateto_oprid
            from v_users
            where oprid='#ListGetAT(teamOprid,thisJob)#'
        </cfquery>
    </cfif>
	<cfif (DelMsg.delegateTo_oprid NEQ "") and (DelMsg.delegateTo_oprid EQ session.oprid)>
		<cfoutput>#DelMsg.delegateTo_oprid#</cfoutput>
		<cfset Del_msg="  [Delegatee]">
	<cfelse>
		<cfset Del_msg="">
	</cfif>

	<cfset loopcount=1>
	
	<cfloop index="i" list="#teamOprid#">
		<cfquery name="DelStr" datasource="#Application.dsn#">
			select DelegateTo_oprid from v_users
			where oprid='#i#'
		</cfquery>
		<cfif DelStr.DelegateTo_oprid NEQ "">
			<cfswitch expression="#loopcount#">
			<cfcase value="1">
				<cfset pm_nm="#pm_nm#" & " [Delegation to  #Ucase(DelStr.DelegateTo_oprid)#]">
				<cfset Next_phrase=" <br>Next Approver is #UCASE(ListGetAt(teamOprid,2))#.">
			</cfcase>
			<cfcase value="2">
				<cfset contract_nm="#contract_nm#" & " [Delegation in effect to  #Ucase(DelStr.DelegateTo_oprid)#]">
				<cfset Next_phrase=" <br>Next Approver is #UCASE(ListGetAt(teamOprid,3))#.">
			</cfcase>
			<cfcase value="3"> 
				<cfset controller_nm="#controller_nm#" & " [Delegation  to  #Ucase(DelStr.DelegateTo_oprid)#]">
				<!--- Next approver will be determined by qry_MailDist --->
			</cfcase>
			</cfswitch>
			<cfset loopcount= val(loopcount+1)>
		</cfif>
	</cfloop>
	
	<cfinclude template="qry_mailDist.cfm">
	
	<cfquery name="getOpsVPName" datasource="#Application.dsn#">
		Select empname from users where id_user in (select ID_OpsVP 
		from ARA here id_ara='#id_ara#')
	</cfquery>	
	<cfif getOpsVPName.recordCount GT 0>									
		<cfset OpsVP_nm = #getOpsVPName.empname#>
	</cfif>
	
	<cfoutput>
	After call to mailDist<br>
	From: #From#<br>
	To: #to#<br>
	CC: #CC#<br>
	</cfoutput>
	<cfset Approver=#session.empname#>
	<cfset Subject="ARA #Reference#: Approved by #Approver#" & "#del_msg#"> >

<cfoutput>
<cfset MsgHdr="
<html>
<head>
   <meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
   <title>#title#</title>
   <style type='text/css' media='screen'>
      body {
         margin: 0;
         padding: 0;
         background-color: ##FFFFFF;
      }
	a
	{color: ##FFFFFF; text-decoration: underline;}
      
	.detail {
	background-color: ##4b5c63;
	font-family: Trebuchet MS, helvetica,sans-serif;
	color: ##ffffff;
	font-size: 11px;
	line-height: 14px;
	}
      .ariva {
         font-family: georgia;
         font-size: 16px;
         font-weight: normal;
         color: ##ffffff;
		 letter-spacing:0px;
         margin: 10px 10px 0px 10px;
         padding:10px 10px 10px 10px;
      }
	  .tag {
         font-family: Trebuchet MS, helvetica,sans-serif;
         font-size: 13px;
         font-weight: normal;
         color: ##ffffff;
		 text-transform:uppercase;
		 letter-spacing:0px;
         margin: 0;
         padding:0px 0px 0px 10px;
		 margin: 0px 0px 10px 10px;
      }
.border {
border-style:solid;
border-width: 1px;
border-color: ##b4c4cc;
font-family: Trebuchet MS, Arial,sans-serif;
color:##ffffff;
font-size:12px;
}

      .title {
	   	font-family: Trebuchet MS, helvetica,sans-serif;
         font-size: 13px;
         font-weight: normal;
         color: ##ffffff;
		 text-transform:uppercase;
         background-color: ##000000;
         padding: 2px 10px 4px 10px;
      }
	.footnote {
	font-family: verdana,sans-serif;
	font-size: 10px;
	color: ##FFFFFF;
	background-color:##4b5c63;
	text-align:center;
	margin:10px;
	padding:10px;
	}
   </style>

</head>
<body>
">
<cfset MsgDist="
<table width='100%' border='0' cellspacing='0' cellpadding='0'>
   <tr>
      <td width='34' class='spacer'>&nbsp;</td>
      <td align='left'>
                  
                  <table width='560' border='0' cellspacing='0' cellpadding='0'>
                     <tr>
                        <td class='detail'>
                           
                           <table width='560' border='0' cellspacing='10' cellpadding='0' class='post'>
                              <tr>
                                 <td class='detail'>
								 From:&nbsp;&nbsp;&nbsp;#From#<br>
								 To: &nbsp;&nbsp;&nbsp;#TO#<br>
								 CC: &nbsp;&nbsp;&nbsp;#CC#<br>
								 Subject: &nbsp;&nbsp;&nbsp;#subject#<br><br>
								 </td></tr>
							</table>
					</td></tr></table>
</td></tr></table>
">

<cfset MsgBody="
<table width='100%' border='0' cellspacing='0' cellpadding='0'>
   <tr>
      <td width='34' class='spacer'>&nbsp;</td>
      <td align='left'>
         
         <table width='560' border='0' bgcolor='##4b5c63' cellspacing='0' cellpadding='0'>
            <tr>
               <td bgcolor='##7995a2' colspan='3'>
                  <p class='ariva' >ARA #Reference# .... #dateformat(Now(),'MM/DD/yy')# #timeformat(now(),'hh:mm tt')# </p>
				  <p class='tag'>#intro#</p>
                  
               </td>
            </tr>
            <tr>
               <td width='560' valign='top'>
                  
                  <table width='560' border='0' cellspacing='0' cellpadding='0'>
                     <tr>
                        <td class='detail'>
                           <table width='560' border='0' cellspacing='10' cellpadding='0' class='post'>
                              <tr>
                                 <td class='detail'><br><br>
                                   <table bgcolor='##596c74' align='center' cellpadding='4' cellspacing='2' class='border'>
								   <tr>
								   	<td  valign='top'  class='border'>Cost Point Number</td><td class='border'>#JamisNo#</td>
									</tr>
									<tr>
								   	<td  valign='top' class='border'>Program / Project Title</td><td  valign='top' class='border'>#Title#</td>
									</tr>
									<tr>
								   	<td   valign='top' nowrap class='border'>Customer Name</td><td  valign='top' class='border'>#CustomerName#</td>
									</tr>
									<tr>
								   	<td   valign='top'  nowrap class='border'>Program / Project Manager</td><td  valign='top' class='border'>#pm_nm#</td>
									</tr>
								
									<tr>
										<td  valign='top' nowrap class='border'>Portfolio Leader</td><td  valign='top' class='border'>#OpsVP_nm#</td>
									</tr>
									<tr>
								   	<td  valign='top' nowrap class='border'>Contract Administrator</td><td  valign='top' class='border'> #contract_nm# </td>
									</tr>
									<tr>
								   	<td  valign='top' nowrap class='border'>Project Controller</td><td  valign='top' class='border'> #controller_nm# </td>
									</tr>
									
									<tr>
									<td nowrap class='border'>Approved ARA Amount</td><td class='border'>#dollarformat(AmountTotal)#</td>
									</tr>
									<tr>
									<td   nowrap class='border'>Required Start</td><td class='border'>#dateformat(startDate,'MM/DD/YY')#</td>
									</tr>
									<tr>
									<td  nowrap class='border'>ARA Expiration Date</td><td class='border'>#dateformat(expirationDate,'MM/DD/YY')#</td>
									</tr>
									</table>
									                                 
                                    </td>
                              </tr>
                           </table>
                           
                        </td>
                     </tr>
  
                     <tr>
                        <td>&nbsp;</td>
                     </tr>
          

					 <tr>
					 <td class='ariva'>
					 	<font class='footnote'>This message is automatically generated by the ARA system, and is not intended for reply.</font>
					</td></tr>
                  </table>
                  
               </td>
               
            </tr>
         </table>
         
      </td>
   </tr>
</table>

</body>
</html>
">
	
</cfoutput>
<!--- Mail it --->
<cfinclude template="mail_sendit.cfm">