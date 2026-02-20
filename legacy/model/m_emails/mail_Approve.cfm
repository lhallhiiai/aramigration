<cfset id_emailType=1><!--- ara status change --->
<cfparam name="url.comment" default="">
<cfinclude template="../m_ara/qry_ara.cfm">
<cfset AID=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
<cfinclude template="mail_top.cfm">
<cfinclude template="Msg_hdrStyle.cfm">

	<cfquery name="getOpsVPName" datasource="#Application.dsn#">
		Select empname from users where id_user in (select ID_OpsVP 
		from ARA
		where id_ara='#id_ara#')
	</cfquery>	
	<cfif getOpsVPName.recordCount GT 0>									
		<cfset OpsVP_nm = #getOpsVPName.empname#>
	</cfif>
	
	
<cfoutput>
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
								 Subject: &nbsp;&nbsp;&nbsp;#Subject#<br><br>
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
				  <p class='tag'>#shortDesc#</p>
                  
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
								   <!---<tr>
								   	<td valign='top' class='border'>ARA State</td><td valign='top' class='border'>#url.comment#</td>
									</tr>--->
									<tr>
								   	<td  valign='top'  class='border'>Risk Category</td><td class='border'>#Catname#</td>
									</tr>
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
								   	<td  valign='top' nowrap class='border'>Contract Administrator</td><td  valign='top' class='border'>#contract_nm#</td>
									</tr>
								<tr>
								   	<td  valign='top' nowrap class='border'>Project Controller</td><td  valign='top' class='border'>#Controller_nm#</td>
									</tr>
								  
								<tr>
								   	<td  valign='top' nowrap class='border'>Portfolio Leader</td><td  valign='top' class='border'>#OpsVP_nm#</td>
								</tr>
									
									<!---<tr>
								   	<td  nowrap class='border'>Group</td><td  valign='top' class='border'>#division#</td>
									</tr>--->
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
					 	<font class='footnote'>Consult the ARA system to view the status of the entire approval chain. This message is automatically generated by the ARA system, and is not intended for reply.</font>
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
