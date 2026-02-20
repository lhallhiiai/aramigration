<cfif (NOT isDefined("session.loggedin")) or (not isdefined("session.oprid"))>
	<cfset message="Your session has timed out.">
	<cfset tmpVar = StructClear(session)>
	<cflocation url="index.cfm?Message=#message#">
</cfif>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<cfset seeall="Ahuang,MGann,SYan,JLamantia,Phallman,hvennari,cgreer,Nmuzyka,JBoyers">
<cfparam name="Printerfriendly" default="no">
<cfparam name="Menu" default="">
<cfparam name="submenu" default="">
<cfparam name="whichtab" default=0>
<cfparam name="env" default="">
<cfparam name="IsPrint" default="No"><!--- Used to toggle between web page and cfdocument --->


<html>
<head>
<link rel="icon" href="images/favicon.ico" type="image/x-icon" />
<link rel="shortcut icon" href="images/favicon.ico" type="image/x-icon" />

<cfif isDefined("pageTitle")>
  <title><cfoutput>#pageTitle#</cfoutput></title>
 <cfelse>
  <title>At Risk Authorization Management</title>
</cfif>
	
	<!--- script type='text/javascript' src='includes/js/js_header.js'></script --->
	<script type='text/javascript' src='includes/js/jquery-1.6.1.min.js'></script>

	<script type='text/javascript' src='includes/js/jquery.tools.min.js'></script>
	<script language="javascript" type="text/javascript" src="includes/js/jquery.autocomplete.js"></script>
	<script type='text/javascript' src='includes/js/jquery-ui-1.7.3.custom.min.js'></script>
	<!--- script type='text/javascript' src='includes/js/jquery-ui-1.8.21.custom.min.js'></script --->
	<script type="text/javascript" src="includes/js/jquery.mousewheel-3.0.4.pack.js"></script>
	<script type="text/javascript" src="includes/js/jquery.fancybox-1.3.4.pack.js"></script>
	<!--- script language="javascript" type="text/javascript" src="includes/js/jquery_latest.js"></script --->
	<!--- script type='text/javascript' src='includes/js/jquery-1.2.3.min.js'></script --->
	<script type="text/javascript" src="includes/js/JavaScript_DataValidation.js"></script>
	<!--- mgann 8/24/2015: changed to import becuse of cfdocument hanging issues --->
	<style type="text/css">
  		@import url("includes/css/style_main.css");
	</style>
	<!--- <link  rel=stylesheet type="text/css" href="includes/css/style_main.css"> --->
	<link  rel=stylesheet type="text/css" href="includes/css/jquery.autocomplete.css">
	<link  rel=stylesheet type="text/css" href="includes/css/jquery-ui-1.7.3.custom.css">
	<!--- link  rel=stylesheet type="text/css" href="includes/css/ui-lightness/jquery-ui-1.8.21.custom.css" --->
	<link  rel=stylesheet type="text/css" href="includes/css/jquery.fancybox-1.3.4.css">
<cfif CGI.Query_String NEQ "" and findnocase("Admin_Users",CGI.Query_String)>
	
	<script language="javascript" type="text/javascript" src="includes/js/jquery.dataTables.js"></script>
	<script language="javascript" type="text/javascript" src="includes/js/jquery.dataTables.ext.js"></script>
	<link type="text/css" rel="stylesheet" href="includes/css/sty_dataTables.css" />
</cfif>
	

	<script type="text/javascript">
			$(function(){
	
				

				// Datepicker
				 $(".date").datepicker( 
				     { 
				          showButtonPanel: false, 
				          changeMonth: true,
				          changeYear: true,
						  <cfif isDefined('UseCheck') and (UseCheck EQ "Yes")>
						  onSelect:function(dateText, inst) 
						  {
						  	check();
						  },
						  </cfif>
						  buttonImage: 'images/datepicker.gif' 
						  // buttonImageOnly: true 
				     });
				
				//hover states on the static widgets
				$('#dialog_link, ul#icons li').hover(
					function() { $(this).addClass('ui-state-hover'); }, 
					function() { $(this).removeClass('ui-state-hover'); }
				);
				
			});
		</script>
		<style type="text/css">
			/*demo page css*/
			body{ font: 62.5% "Trebuchet MS", sans-serif; margin: 0px;}
			.demoHeaders { margin-top: 2em; }
			#dialog_link {padding: .4em 1em .4em 20px;text-decoration: none;position: relative;}
			#dialog_link span.ui-icon {margin: 0 5px 0 0;position: absolute;left: .2em;top: 50%;margin-top: -8px;}
			ul#icons {margin: 0; padding: 0;}
			ul#icons li {margin: 2px; position: relative; padding: 4px 0; cursor: pointer; float: left;  list-style: none;}
			ul#icons span.ui-icon {float: left; margin: 0 4px;}
		</style>	
<script type="text/javascript">
		$(document).ready(function() {
		
			


			$("a[rel=example_group]").fancybox({
				'transitionIn'		: 'none',
				'transitionOut'		: 'none',
				'titlePosition' 	: 'over',
				'titleFormat'		: function(title, currentArray, currentIndex, currentOpts) {
					return '<span id="fancybox-title-over">Image ' + (currentIndex + 1) + ' / ' + currentArray.length + (title.length ? ' &nbsp; ' + title : '') + '</span>';
				}
			});

			

			$("#hidden_link").fancybox({
				'width'				: '75%',
				'height'			: '75%',
				'autoScale'			: false,
				'transitionIn'		: 'none',
				'transitionOut'		: 'none',
				'type'				: 'iframe'
			});
		});
	</script>
	
</head>
<cfset FilePath = GetDirectoryFromPath(GetCurrentTemplatePath()) />
<cfset server=#CGI.Server_name#>
<cfif #Findnocase('MGann',FilePath)#>
	<cfset env="MGann Local">
<cfelseif #FindNocase('AHUang',FilePath)#>
	<cfset env="Ahuang Local">
<cfelseif FindNoCase('127',CGI.HTTP_Host)>
	<cfset env="LOCALHOST">
<cfelse><!--- Use server to determine development or Production --->
	<cfif Findnocase('ara_staging',filepath)>
		<cfset env="Staging">
	<cfelseif findnocase('ara/index.cfm', filepath)>
		<cfset env="Production">
	<cfelse>
		<cfset env="development">
	</cfif>
</cfif>

<BODY   TOPMARGIN="0" MARGINHEIGHT=0 LEFTMARGIN="0" MARGINWIDTH=0>
<!--- cfdump var="#CGI#" format="text" --->

<!-- outer most table -->
<cfif Find('172.20.41',CGI.HTTP_HOST) OR Find('127',CGI.HTTP_HOST)><!--- Development Server --->
<!--- Next is so we can tell whether we are in development or our local directory --->
<!-- 1 --><table class="env" border=0 cellpadding=0 cellspacing=0>
<tr>
		<td  align="center">
		<cfset strPath = GetDirectoryFromPath(GetCurrentTemplatePath()) />
<font class="env">
<cfoutput>#env#, &nbsp;&nbsp; DSN: #application.dsn#</cfoutput>
</td></tr>
<!--- End of environment row --->
</table>
</cfif>

<!-- 1 --><table border=0 width=100% id="container" cellpadding=0 cellspacing=0>
<cfif Printerfriendly EQ "No">
<tr><!-- Header Row -->
<td class="hdr_bkg">

<!-- 2 --><table id="maintab" class="hdr" align="center"  border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td>
		<img src="images/spacer.gif" width="1150" height="88" usemap="#home_map" alt="" border=0>
			
			<div id="revision">
			<!--- ****************** R E V I S I O N    ***********************   --->
			
									REVISION 2.0
									
		   <!--- ****************** R E V I S I O N    ***********************   --->
		</div></td>
	</tr>
<!-- /2 --></table>
</cfif>
<!-- 1 --></td></tr>
<!-- 1 --><tr><td class="tdot" width=100% height="1" bgcolor=#273a43>

<!-- /1 --></td></tr>
<!-- ************************************************************** -->
<!--                   MAIN BODY                                    -->
<!-- ************************************************************** -->
<!-- 1 --><tr><td class="bkg" valign="top">
<!-- 2 --><table class="main"  align="center"  cellpadding=0 cellspacing=0 border=0>
<tr>
<cfif printerfriendly EQ "No">
<td valign="top" height=100% class="nav_bkg">

	<!-- ************************************************************** -->
	<!--                   Left Navigation                              -->
	<!-- ************************************************************** -->
	<!-- 3 --><table cellpadding=0  width=250 align="center" border=0 cellspacing=0>
	<cfoutput>
	<!--   ******************** who are you ******************* -->
		<tr>
			<td colspan=4 bgcolor="##7995a2" class="tlrdot">
			
	<font class="white" style="font-size:9px;">
			Logged in <strong><i><cfoutput>#session.oprid#</cfoutput></i></strong>
			<cfif isdefined('session.jobtitle')>, #session.jobtitle#</cfif></font>
	
			</td>
		</tr>
		</table>
</cfoutput>


<cfinclude template="inc_nav.cfm">
</cfif>
<!-- /2 --></td><!--- end of left cell containing navigation --->
<!-- 2 -->
<!-- Right Side - right of navigation, main part of page -->
<!-- 2 --><td valign="top" height=100%  class="rdot" width=900>

<td width=20><!-- gutter -->
	<img src="images/spacer.gif" height=100% border=0 width=20>
</td>
<td height=100% align="left" valign="top" width=100%>
<table border=0 height=100% width=100% cellpadding=0 cellspacing=0>
<tr><td bgcolor=#FFFFFF valign="top" height="95%" width=100% >
<div height="100% id="maintab"><br><br><!-- Begin Content--> 
     <cfoutput>#body#</cfoutput>
</div>
</td></tr>
<tr>
<td height=5% style="text-align:center;padding:20px 0px 10px 0px;"><cfoutput>
<p>&copy; #dateformat(Now(),"YYYY")# Huntington Ingalls Industries
</p></cfoutput>
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
		
		<!-- /2 --></td></tr></table>
		</td>
		</tr>
</cfif>--->
</table>




</body>
</html>
