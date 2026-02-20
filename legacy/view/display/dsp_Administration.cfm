<cfset submenu="Administration">
<cfset whichtab=4>
<script type="text/javascript">
			$(function(){
	
				// Tabs
				$('#tabs').tabs(
				{
				selected:<cfoutput>#whichtab#</cfoutput>
				});

				// Datepicker
				 $(".date").datepicker( 
				     { 
				          showButtonPanel: false, 
				          changeMonth: true,
				          changeYear: true,
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
<cfoutput>
<table width=100% cellpadding=0 cellspacing=0 border=0>
<tr>
<td valign="top">
<p class="title">
ARA Administration</p>
</td>
<td valign="top" align="right">
<a class="embed" href=""></a>
</td></tr></table>
<table cellpadding=2 width=100% cellspacing=2 class="border">

<td width=100%>
		<div id="tabs">
			<ul>
				<!--- li><a href="dsp_ARAdetail.cfm?&mel=mel#tabs-1">Program Information</a></li --->
				<li><a href="#tabs-1">ARA Users</a></li>
				<li><a href="#tabs-2">Approval Thresholds</a><img class="tabstatus" src="images/TabCheck.gif"></li>	
			</ul>
<div id="tabs-1"><!---          Reviewers and Approvers          --->
	<cfinclude template="dsp_Admin_Users.cfm">
</div>
<div id="tabs-2"><!---      Thresholds       --->
			<cfinclude template="dsp_Admin_Thresholds.cfm">
</div>
				
</div><!--- end of tabs div --->	
		
</td></tr>
</table>

</body>
</html>