
<cfparam name="email_type" default="all">

<cfif isDefined('FindMsg')>
  <cfset user=getToken(form.alion_user,1,"[")>
  <cfset user=getToken(user,1,",")>
  <cfif form.email_type EQ 2>
			<cfset subtitle="Delegations">
		<cfelseif form.email_type EQ 3>
			<cfset subtitle="User Profile Creations and Updates">
		<cfelse>
			<cfset subtitle="Delegations and User Profile Changes">
		</cfif> 
  <cfquery name="getEmail" datasource="#Application.dsn#">
  		select * from emailLog
		where subject like '%#user#%'
		and id_emailtype <> 1
		<cfif form.email_type EQ 2>
			and id_emailType=2
		<cfelseif form.email_type EQ 3>
			and id_emailType=3
		</cfif>
		Order by sentDate
	</cfquery>
	
</cfif>

<!--- **********************************************************  --->
<!---          Autocomplete for user look up                     --->
<!--- ********************************************************** --->
<script>
  $(document).ready(function(){
             $("#alion_user").autocomplete("index.cfm?fuseaction=app.ARAusersShort",
                {
                                minChars:2,
                                delay:200,
                                extraParams: {},
                                autoFill:false,
                                matchSubset:true,
                                matchContains:1,
                                cacheLength:10,
                                selectOnly:1
                });
				$("#alion_user").result(function(event,data)
                {
                                var tmp = data[0].split(" [");
                                var name = tmp[0];
                                var oprid = tmp[1].split("]:")[0];
                                $("##ara_user").val(data[0]);
	
                });

                /* $("input[name='Sector']").change(function() {
                	$('input#alion_user').flushCache();
                }); */

  });
 </script>
<cfset smtitle="administration">
<cfset title="Search Delegation & Profile Emails">
<cfoutput>
<p class="smtitle">#smtitle#</p>
<p class="title">#title#</p>
</cfoutput>

<cfform  name="FindEmail"  method="Post" enctype="multipart/form-data" action="index.cfm?Fuseaction=app.userEmails">
<table cellpadding=2 cellspacing=2 class="border">
<tr>
	<td class="border">Enter Lastname</td>
	<td class="border">
	<cfinput class="inputtext" size=40 type="text" id="alion_user" name="alion_user" required="Yes" message="Enter Lastname"></td>
	<td class="border">
	Email Type
	<td class="border">
		<input type="radio" name="email_type" <cfif email_type EQ "all">Checked</cfif> value="all">ALL
		&nbsp;&nbsp;
		<input type="radio" name="email_type"  <cfif email_type EQ "2">Checked</cfif> value="2">Delegations
		&nbsp;&nbsp;
		<input type="radio" name="email_type"  <cfif email_type EQ "3">Checked</cfif> value="3">User Profile
	</td>
</tr>
<tr>
	<td colspan=4 class="border" align="center">
		<input type="submit" class="button" id="FindMsg" name="findMsg" value="Lookup Email">
	</td>
</tr>
</table>
</cfform>
<cfif isDefined('getEmail')>
	<!--- cfdump var="#getEmail#" format="text" top="1" --->
<p class="bottomtitle"><cfoutput>#user#: #subtitle#</cfoutput></p>
<table cellpadding="2" cellspacing="2" class="border">
<cfoutput query="getEmail">
	<tr>
	<td nowrap class="borderq">#id_emailLog#</td>
	<td class="border">#MsgTo#</td>
    <td class="border">#subject#
	<!--- <cfquery name="gApprovals" datasource="#application.dsn#">
		select id_emailLog,id_emailType,sentDate,comment
		where id_emailType=1
		and comment like '%Delegation%'
		and comment like '%user%'
		and sent --->
	

	
	</td>
    <td class="border">#dateformat(sentDate,"MM/DD/YY")# #timeformat(sentDate,"HH:MM tt")#</td>
    <td class="border">
		<a href="index.cfm?fuseaction=app.AuditEmail&Menu=Admin&submenu=audit&id=#id_emailLog#"><img src="images/ActobatOnWhite.png" border=0></a>
	<!---<cfheader name="content-disposition" value="attachment; filename=ARAEmail.pdf">
	<cfcontent type="application/pdf" variable="#message_pdf#">--->
</td>
</tr>
</cfoutput>
</table>
</cfif>