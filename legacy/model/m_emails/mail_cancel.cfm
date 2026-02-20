<cfset id_emailType=1><!--- ara status change --->
<cfparam name="url.comment" default="">
<cfinclude template="../m_ara/qry_ara.cfm">
<cfset AID=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
<cfinclude template="mail_top.cfm">
<cfinclude template="Msg_hdrStyle.cfm">
<cfset From="ARA@hii-tsd.com">  
<cfset Subject="ARA #reference# cancelled by #Ucase(session.oprid)#">
<cfset intro="Cancelled by #Ucase(session.oprid)# [CostPoint No: #JamisNo#, Title: #title#]">
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
	.whitepadd {
	margin:10px 5px 10px 5px;
	color:##ffffff;
	font-size: 11px;
	font-weight:normal;
	font-family:Trebuchet MS, helvetica,sans-serif;
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
								 Subject: #Subject#<br><br>
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
									<td nowrap class='border'>Requested ARA Amount</td><td class='border'>#dollarformat(totalAnticipated)#</td>
									</tr>
									<tr>
									<td   nowrap class='border'>Required Start</td><td class='border'>#dateformat(startDate,'MM/DD/YY')#</td>
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
<cfinclude template="mail_sendit.cfm">