<!--- +++++++++++++++++++++ REJECT FANCY BOX +++++++++++++++++++++  --->

<!--- If reject button is clicked, will bring up Reject Button in front of page --->
<cfif isDefined('Reject') and (Reject NEQ "")><!--- Show Fancy Box containing reject form --->
	<script type="text/javascript">
	    $(document).ready(function() {
	        $("#hidden_link").fancybox().trigger('click');
	    });
	</script>
</cfif>
<!--- a href="index.cfm?fuseaction=app.AuditTrail&Menu=Admin&submenu=audit&ara_ID=127" id="hidden_link" style="display:none;"></a --->
<cfoutput>
<a href="index.cfm?fuseaction=app.RejectForm&id_status=#id_status#&thiscycle=#val(revision+1)#&divshow=View&id_ara=#id_ara#&returnTo=Contracts" id="hidden_link" style="display:none;"></a>
</cfoutput>
<!--- +++++++++++++++++++++ END OF REJECT FANCY BOX +++++++++++++++++++++  --->

<!--- Button that calls same page, and defines Reject. When press the button, calls this same
      page, and causes "Reject to be defined --->
	  
	  <input class="button" type="button" value="REJECT" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.ARA_ContractInfo&id_ara=#id_ara#&AID=#AID#&Reject=Yes';">&nbsp;&nbsp;&nbsp;