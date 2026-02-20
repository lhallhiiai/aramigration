

<cfif Findnocase('agwalajeras01',CGI.HTTP_HOST) GT 0 or Findnocase('mt-contractfinanceapps.hii-tsd',CGI.HTTP_HOST) GT 0>
	<cfset araurl="https://mt-contractfinanceapps.hii-tsd.com/ara">
	<cfset MsgURL="
	<table width='100%' border='0' cellspacing='0' cellpadding='0'>
	   <tr>
		  <td width='34' class='spacer'>&nbsp;</td>
		  <td align='left'>
                  
                  <table width='560' border='0' cellspacing='20' cellpadding='20'>
				 <tr>
					<td class='detail'>
			<font size='+1'>ARA url: <a href= #araURL#>#araURL#</a><p></p><p></p></font>
				</td></tr>
				</table>
	</td></tr></table>
	">
	<cfmail to="#to#,regan.anderson1@hii-tsd.com" cc="#cc#,anna.huang1@hii-tsd.com"  type="HTML" from="ARA@hii-tsd.com" subject="#subject#">
	
	#MsgHdr# #MsgDist# #MsgBody# #MsgURL#
	</cfmail>
	
<cfelse>
	<cfset araurl="https://mt-contractfinanceappstest.hii-tsd.com/ara">
	<cfset MsgURL="
	<table width='100%' border='0' cellspacing='0' cellpadding='0'>
	   <tr>
		  <td width='34' class='spacer'>&nbsp;</td>
		  <td align='left'>
                  
                  <table width='560' border='0' cellspacing='20' cellpadding='20'>
				 <tr>
					<td class='detail'>
			<font size='+1'>ARA url(Dev): <a href= #araURL#>#araURL#</a><p></p><p></p></font>
				</td></tr>
				</table>
	</td></tr></table>
	">
		
	<cfmail to="regan.anderson1@hii-tsd.com, anna.huang1@hii-tsd.com" type="HTML" from="ARA@hii-tsd.com" subject="TEST ARA: #subject#">	
	#MsgHdr#  #MsgDist# #MsgBody# #MsgURL#
	</cfmail>
</cfif>
<cfinclude template="CreatePDF.cfm">
<cfinclude template="Upload_InsertEmail.cfm">