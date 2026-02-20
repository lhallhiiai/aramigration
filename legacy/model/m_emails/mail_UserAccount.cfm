<cfset id_emailType=3>
<cfset to="#gUsers.oprid#@hii-tsd.com">
<cfif gUsers.Approve_Grp NEQ "">
	<cfset approve="Approval Group: #gUsers.Approve_Grp#">
<cfelse>
	<cfset approve="">
</cfif>
<cfset cc="anna.huang1@hii-tsd.com">
<cfset From="ARA@hii-tsd.com">  
<cfset subject="ARA Account info for #gUsers.empname#">
<cfset title="ARA User Account">
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
                  <p class='ariva' >ARA User Account .... #dateformat(Now(),'MM/DD/yy')# #timeformat(now(),'hh:mm tt')# </p>
				  <p class='tag'>Your ARA User Account Added or Updated</p>
                  
               </td>
            </tr>
            <tr>
               <td width='560' valign='top'>
                  
                  <table width='560' border='0' cellspacing='0' cellpadding='0'>
                     <tr>
                        <td class='detail'>
                           
                           <table width='560' border='0' cellspacing='10' cellpadding='0' class='post'>
                              <tr>
                                 <td class='detail'>
                                    <p>Your account on the ARA system has been added or updated:</p>
									<p>Name: #empname#<br>
									Group, Sector: #gUsers.grp#, #gUsers.sctr#<br>
									Operation, Division: #gUsers.dvsn#, #gUsers.org_Desc#<br>
									#Approve# <br>
									ARA Job Title: <b>#gUsers.title#</b><br>
									ARA Security Level: <b>#gUsers.roleName#</b><br>
									</p>
							
                                 
                                    </td>
                              </tr>
                           </table>
                           
                        </td>
                     </tr>
  
                     <tr>
                        <td>&nbsp;</td>
                     </tr>
          
                     <!-- tr>
                        <td height='4' bgcolor='##7995a2'></td>
                     </tr>
					  <tr>
			
                        <td class='detail'>
						<table width='560' border='0' cellspacing='10' cellpadding='0' class='post'>
                              <tr>
                                 <td class='detail'>
									<p></p>
								</td></tr>
						</table>
						
						</td>
                     </tr -->

					 <tr>
					 <td class='detail'>
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