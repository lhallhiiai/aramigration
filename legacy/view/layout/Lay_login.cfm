
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<cfparam name="Menu" default="">
<cfparam name="submenu" default="">

<html>
<head>
<cfif isDefined("pageTitle")>
  <title><cfoutput>#pageTitle#</cfoutput></title>
  <cfelse>
  <title>At Risk Authorization</title>
</cfif>
	<!-- script type='text/javascript' src='includes/js/js_header.js'></script -->
	<script type='text/javascript' src='includes/js/jquery-1.2.3.min.js'></script>
	<link  rel=stylesheet type="text/css" href="includes/css/style_main.css">
	

</head>

<BODY  TOPMARGIN="0" MARGINHEIGHT=0 LEFTMARGIN="0" MARGINWIDTH=0>
<map name="home_map"><area coords="1,1,250,100" href=""></map>  
<map name="tracker"><area coords="722,1,976,38" href=""></map>  
<!-- outer most table -->
<!--- Next is so we can tell whether we are in development or our local directory --->
<!-- 1 --><table class="env" border=0 cellpadding=0 cellspacing=0>
<tr>
		<td  align="center">
	<font class="white">
<cfoutput>#env#</cfoutput></font>
</td></tr>
<!--- End of environment row --->
</table>

<!-- 1 --><table border=0 width=100% id="container" cellpadding=0 cellspacing=0>
<tr><!-- Header Row -->
<td class="hdr_bkg">
<!-- 2 --><table id="maintab" height=103 class="hdr_login" align="center"  border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td height=103>
		<img src="images/spacer.gif" width="1150" height="88" border=0>
			<div id="revision">
			<!--- ****************** R E V I S I O N    ***********************   --->
			
									REVISION 2.0
									
		   <!--- ****************** R E V I S I O N    ***********************   --->
		</div></td>
	</tr>
<!-- /2 --></table>
<!-- 1 --></td></tr>
<!-- ************************************************************** -->
<!--                   MAIN BODY                                    -->
<!-- ************************************************************** -->
<!-- 1 --><tr><td class="bkg" valign="top" bgcolor="#567d9d">
<!-- 2 --><table class="main"  align="center"  cellpadding="0" cellspacing="0" border="0">
<tr>


<!-- 2 --><td  height=100%  class="rdot" width="1150">

<td width=20><!-- gutter -->
	<img src="images/spacer.gif" height=100% border=0 width=20>
</td>
<td height=100% align="center" valign="top" width=100%>
<table border=0 height=100% cellpadding=0 cellspacing=0>
<tr><td valign="top" height="95%" width=100% >
<div height="100% id="maintab"><br><br><!-- Begin Content--> 
     <cfoutput>#fusebox.layout#</cfoutput>
</div>
</td></tr>
<tr>
<td height=5%><cfoutput>
<p class="tiny">&copy; #dateformat(Now(),"YYYY")# Huntington Ingalls Industries</p></cfoutput>
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
<!-- 1 --><tr><td valign="bottom" class="bottom">
		<!-- 2 --><table align="center" cellpadding=0 cellspacing=0 border=0>
		<tr><td class="bottom_img" align="center">
		<map name="tracker">
			   <area coords="1,1,228,85" href=".html"><!--- CTO link? --->
			   <area coords="868,1,1150,40" href=".html"><!--- CAE Tracker ---></map>  


		<img src="images/spacer.gif" width="1150" height="35" usemap="#tracker" border=0 alt="Report Problems to CAE">
		<!-- /2 --></td></tr></table>
		</td>
		</tr>

</table>




</body>
</html>
