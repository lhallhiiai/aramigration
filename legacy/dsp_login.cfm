
<!--- cfif (NOT isDefined("session.loggedin")) or (not isdefined("session.oprid"))>
	<cflocation url="index.cfm?fuseaction=app.logout">
</cfif --->
<!---   +++++++++++++++++ CORP CLOSE ++++++++++++++++ --->

<cfquery name="getCorpClose" datasource="#APPLICATION.ajes#">
	select top 1 date_close, convert(varchar(19),date_close,100) as strDateClose
  from v_dates_corpclose where date_close > CURRENT_TIMESTAMP order by date_close
</cfquery>
<cfquery name="getPeriod" datasource="#APPLICATION.ajes#">
	select prd, yr from ro_fy;
</cfquery>

<cfset corpPeriod = getPeriod.prd>
<cfset corpFY = getPeriod.yr>
<cfset corpDateClose = getCorpClose.date_close>
<cfset strCorpDateClose = getCorpClose.strDateClose>

<!---   +++++++++++++++++ OPS CLOSE ++++++++++++++++ --->

<cfquery name="getOpsClose" datasource="#APPLICATION.ajes#">
	select top 1 date_close, convert(varchar(19),date_close,100) as strDateClose
  from v_dates_opsclose where date_close > CURRENT_TIMESTAMP order by date_close
</cfquery>
<cfset opsDateClose = getOpsClose.date_close>
<cfset strOpsDateClose = getOpsClose.strDateClose>
<cfparam name="Printerfriendly" default="No">
<cfparam name="Message" default="">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html>
<head>
  <title>At Risk Authorization Management</title>
  <link  rel=stylesheet type="text/css" href="includes/css/style_main.css">
  <link rel="icon" href="images/favicon.ico" type="image/x-icon" />
  <link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />

</head>

<cfset FilePath = GetDirectoryFromPath(GetCurrentTemplatePath()) />
<cfset server=#CGI.Server_name#>
<cfif FINDNOCASE('agxalajeras01',CGI.HTTP_HOST) GT 0>
			<cfset env="Development">
<cfelseif FINDNOCASE('agwalajeras01',CGI.HTTP_HOST) GT 0>
			<cfset env="Production">
<cfelse>
		<cfset env="Unknown">
</cfif>
<BODY  TOPMARGIN="0" MARGINHEIGHT=0 LEFTMARGIN="0" MARGINWIDTH=0>
<!-- outer most table -->

<!-- 1 --><table border=0 width=100% id="container" cellpadding=0 cellspacing=0>
<cfif Printerfriendly EQ "No">
<tr><!-- Header Row -->
<td class="hdr_bkg">

<!-- 2 --><table id="maintab" class="hdr" align="center"  border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		<img src="images/spacer.gif" width="1150" height="88" border=0>
			
			</td>
	</tr>
<!-- /2 --></table>
</td></tr></cfif>
<!-- 1 -->
<!-- 1 --><tr><td class="tdot" width=100% height="1" bgcolor="#757575">
<!-- /1 --></td></tr>
<!-- ************************************************************** -->
<!--                   MAIN BODY                                    -->
<!-- ************************************************************** -->
<!-- 1 --><tr><td class="bkg" valign="top">
<!-- 2 --><table class="main"  align="center" cellpadding=0 cellspacing=0 border=0>
<tr>
<cfif printerfriendly EQ "No">
<td valign="top" height=100% class="nav_bkg">
<p style="color:#ffffff;padding:120px 30px 100px 30px;">


ARA is a finanical system used to process At Risk Authorizations. It is a part of the AJERAS financial suite of tools.
Business questions concerning this system can be addressed to the finance department.
</p>

	<!-- ************************************************************** -->
	<!--                   Left Navigation                              -->
	<!-- ************************************************************** -->
	<!-- 3 -->
    <table cellpadding=0  width=250 align="center" border=0 cellspacing=0>
	<cfoutput>
	<!---   ******************** who are you ******************* --->
		<tr>
			<td colspan=4></td>
		</tr>
		</table>
</cfoutput>

</td></cfif>
<!-- /2 --><!--- end of left cell containing navigation --->
<!-- 2 -->
<!-- Right Side - right of navigation, main part of page -->
<!-- 2 --><td valign="top" height=100%  class="rdot" width=900>

<td width=20><!--- gutter --->
	<img src="images/spacer.gif" height=100% border=0 width=20>
</td>
<td height=100% align="left" valign="top" width=100%>
<table border=0 width=100% cellpadding=0 cellspacing=0>
<tr><td bgcolor=#FFFFFF valign="top" height="95%" width="100%" >

<div height="100% id="maintab" ><br><br><!--- Begin Content---> 
<table border=0 cellpadding=0 cellspacing=0> 
<tr>
<td valign="top">
<p class="title">Welcome to ARA <strong>(DEVELOPMENT)</strong></p>
<!--- cfdump var="#this#" format="text">
	<cfif isDefined('session')>
	<cfdump var="#session#" format="text">
	</cfif --->
	
<cfinclude template="dsp_messages.cfm">
<cfoutput>
<cfform name="save" method="post" action="">
	<table width=350 class="border" align="center" cellpadding=2 cellspacing=2>
	<tr>
		<td class="border">User Name:</td>	
		<td class="border">
			<cfinput class="inputtext" type="text" name="strusername" required="Yes" message="Provide Login">
		</td>
	</tr>
	<tr>
		<td class="border">Password:</td>
		<td class="border"><cfinput class="inputtext" type="password" name="strpassword"  required="Yes" message="Provide Password"></td>
	</tr>
	<tr>
		<td class="border" colspan=2 align="center">
			<cfinput name="submit" type="submit" value="Login">
	</td></tr></table>
</cfform>
</td>
<td width=20><img src="images/spacer.gif"></td>
<td valign="top">
<img src="images/spacer.gif" width="350" height="30">
<p class="close">Access to ARA&nbsp;&nbsp;</p>

If you request access level <strong><font colot="##af3610">ABOVE PROJECT MANAGER</font></strong>, please <a class="embed" href="ARAApp-AccessRequest.doc"><b>CLICK HERE</b></a> to download the ARA access request form. Follow the completion and submission instructions, noted in the form. 

</td>

<!---<cfdump var="#Application.env#" format="text">--->
</tr>
</table>
</cfoutput>

</td></tr>

<!---<cfset opsDateClose="">--->
<!---<cfif (Len(corpDateClose) GT 0) AND (Len(opsDateClose) GT 0)>
<tr>
	<td colspan=2>
		</td>
		<td width=10><img src="images/spacer.gif" width=10></td>
		<td colspan=2 align="right">
			<cfinclude template="dsp_billCalendar.cfm">   
		</td>
		</tr>
		<!-- /3 --></table>
		<img src="images/spacer.gif" height=70 border=0 width=600><br>
		</td>
</tr>
<cfelse>
<tr>
	<td colspan=2><br /><br />
<p class="close" style="text-align:left;font-size:18px;">Unable to retrieve closing calendar dates. Notify CAE immediately.</p>
	<br /><br /></td>
</tr>
</cfif>--->
<tr>
<td height=5% style="text-align:center;padding:20px 0px 10px 0px;"><cfoutput>
<p>&copy; #dateformat(Now(),"YYYY")# Huntington Ingalls Industries</p></cfoutput>
</td></tr>
    </table>



</td>
<td width=20><!-- gutter -->
	<img src="images/spacer.gif" width=20>
</td>
</tr>
<!-- /2 --></table>
<!-- Prior to including this, should just have ended table at level 3 -->

<!-- /1 --></td></tr>
<!---<cfif PrinterFriendly EQ "No">
<!-- 1 --><tr><td valign="bottom" class="bottom">
		<!-- 2 --><table align="center" cellpadding=0 cellspacing=0 border=0>
		<tr><td class="bottom_img" align="center">
		<img src="images/spacer.gif" width="1150" height="35">
		<!-- /2 --></td></tr></table>
		</td>
		</tr>
</cfif>--->
</table>
</div>



</body>
</html>
