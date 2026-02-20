
<cfif (isDefined('url.aid')) AND (NOT isDefined('id_ara'))>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
</cfif>

<cfparam name="buttontext" default="Submit">
<cfparam name="FormOrView" default="Form">
<cfparam name="ThisID" default="">
<cfset whichtab="documents">
<cfset pagetitle="ARA Documents">
<cfparam name="Action" default="Setup">
<cfset max_doc=100>

<!--- ++++++++++++++ Functions to Include +++++++++++++++++++++  --->
<!--- +++++++++++ Pulls ARA, user, groups, sector, category, status ++++++++++ --->
<cfinclude template="../../model/m_ara/qry_ara.cfm">
<!--- QRY_AttachInfo: <cfset info=#DocInfo()# inits empty vars. #DocInfo(id_attachment)# inits vars for existing attachment --->
<cfinclude template="../../model/m_forms/qry_attachinfo.cfm">


<!--- Tooltips for Required Documents --->
<cfquery name="GetTips" datasource="#Application.dsn#">
	Select * from attach_checklist
</cfquery>
<cfset tooltip.img = "<img style='vertical-align: bottom;padding-left:5px;margin-bottom:3px;' src='images/tooltip-icon-tiny.png'><br>">


<cfswitch expression="#action#">
<cfcase value="setup"><!--- setting up to either insert or update --->
	<cfif isDefined('id_attachment') and (id_attachment NEQ '')>
		<cfset docinfo=#AttachInfo(id_attachment)#>
		<cfset Action="Update"><!--- Updating an existing document --->
		<cfset buttonText="Update Attachment Info">
		<cfset thisID=id_attachment>
	<cfelse>
		<cfset docinfo=#AttachInfo()#>
		<cfset action="Upload">
		<cfset buttonText="Attach Document to ARA">
	</cfif>
</cfcase>
<cfcase value="Upload">
	<cfset buttontext="Attach File to ARA">
	<cfif isDefined('FileName') and (FileName NEQ '')>
		<cfinclude template="../../model/m_forms/act_DoDocUpload.cfm">
	</cfif> 
</cfcase>
<cfcase value="update">
	<cfinclude template="../../model/m_forms/qry_UpdAttach.cfm">
</cfcase>
<cfcase value="delete">
	<cfinclude template="../../model/m_forms/act_DoDocUpload.cfm">
</cfcase>
</cfswitch>
<cfoutput>
<!-- 1  --><table width=100% cellpadding=0 cellspacing=0 border=0>
		<tr>
		<td width=50%  valign="top">
		<p class="smtitle">
		ARA Documents</p>
		<p class="aratitle">Title: #title#</p>
		</td>
		<td valign="top" align="right">
		<a class="embed" href="#self#?Fuseaction=app.ara_CFDocument&AID=#AID#">Print ARA <img src="images/PrinterIcon.gif" border=0 align="right"></a>
<!-- /1  --></td></tr></table>
</cfoutput>
<!--- ARA Summary Info at top of page ---><cfinclude template="dsp_ARA_top_summary.cfm">

<fieldset><legend><b>ARA Backup Detail</b></legend>
<!--- ARA Navigational Tabs ---><cfinclude template="dsp_tabset.cfm">
<cfif NOT isDefined('session.nextApprover')>
	<cfset session.nextApprover ="">
</cfif>
<!--- cfdump var="#session#" format="text" --->
<!--- If in controller, or rejected and this person is the contract manager, they will see form. Otherwise view only --->
<cfif (FormorView EQ "Form")  AND (ListFind('1,2,3,4,5,8,9',id_status)) and 
((ID_controller EQ session.id_user) OR (ID_PM EQ session.id_user) OR (ID_Contract EQ session.id_user)) 
OR (isDefined('url.ApproverUpload') and url.ApproverUpload EQ "Yes")>
<br><br>
<div id="docdesc" style="margin:0px;">
<cfoutput>
<fieldset>
		    <legend><b>Upload Documentation Required for: <i>#ThisCat#</i></b></legend>
			



<cfinclude template="dsp_messages.cfm"><!--- If present display ConfirmMsg, ErrorMsg, Warning Msg --->

<cfform method="Post" id="DocUpload" name="DocUpload" enctype="multipart/form-data"  action="index.cfm?fuseaction=app.ARA_Docs">
<cfinput type="hidden" name="action" value="#action#">
<cfinput type="hidden" name="id_ara" value="#id_ara#">
<cfinput type="hidden" name="FormOrView" value="#FormOrView#">
<Cfif isDefined('id_attachment') and (ID_attachment NEQ "")>
	<cfinput type="hidden" name="id_attachment" value="#id_attachment#">
	<cfinput type="hidden" name="FileName" value="#fileName#">
</cfif>
<table width=100% cellpadding=2 cellspacing=2>

<tr>
	<td  class="border">
		<cfif Action NEQ "Update">
		
			<b>Upload .pdf and .xls and .xlsx supporting documents.</b><br><br>
			<div onclick="$('input[type=file]').click()" width=150 height=30 >
				<cfinput style="font-size: 11px;" name="Filename" required="Yes" Message="Select a file to Upload" type="file" maxlength="200"  id="upload"  size="65"  /></div>
				<br><font class="tiny">Maximum length of filename is 28 characters. Name will be truncated.</font> 
		<cfelse><!--- can only update Meta data for Update --->
		<p style="margin-left:20px;">
		<font class="message">Updating Information for File: <b>#Filename#</b><br>
		Size: #numberformat(Filesize,",")# Uploaded: #Date#
		</p>
		</cfif>
    </td>
	<td class="border" rowspan="2"><b>Contains Required Info:</b>
	<table width=100% cellpadding=0>
	<cfloop query="DocTypes">
		<tr>
		<td valign="top">
		
		<cfif find(ID_attachtype,MissingList)>
			<img src="images/SmGreyMinus.png">
		<cfelse>
			<img src="images/SmCheck.png">
			
		</cfif>
		
		</td>
		<td valign="top">
		 <cfif Find(ID_attachtype,Filetype)>
		<cfinput type="checkbox" name="ID_attachtype" value="#ID_attachtype#" Required="Yes" Message="Check the required information this document contains" Checked>
		<cfelse>
			<cfinput type="checkbox" name="ID_attachtype" value="#ID_attachtype#" Required="Yes" Message="Check the required information this document contains">
		</cfif>
</td>
		<td valign="top">#Short_desc#
		<img style="vertical-align: bottom;padding-left:5px;padding-right:5px;" src="images/tooltip-icon.png" 
		title="<cfoutput><b>#Short_Desc#</b><br>#Long_desc#</cfoutput>"></td>
		</tr>
	</cfloop>
    	<tr>
		<td valign="top">
		
			<img src="images/SmGreyMinus.png">
		</td>
		<td valign="top">
		 <!---<cfif Find(ID_attachtype,Filetype)>
		<cfinput type="checkbox" name="ID_attachtype" value="#ID_attachtype#" Required="Yes" Message="Check the required information this document contains" Checked>
		<cfelse>--->
			<cfinput type="checkbox" name="ID_attachtype" value="0" Required="Yes" Message="Check the required information this document contains">
		<!---</cfif>--->
</td>
		<td valign="top">Other 
		<img style="vertical-align: bottom;padding-left:5px;padding-right:5px;" src="images/tooltip-icon.png" 
		title="<cfoutput><b>Other supporting documentation</b></cfoutput>"></td>
		</tr>
	</table>
	</td>
</tr>
<tr>
	<td class="border">
		<br><b>Description</b>:&nbsp;&nbsp;<cfinput name="description" id="description"  value="#description#" required="Yes" Message="Describe the contents of the document" type="text" maxlength="2000"  class="inputtext2"  size="60"  /><br>
    </td>
</tr>
<tr>
	<td colspan=2 class="border" align="center">
		<input type="submit" class="button" value="#buttontext#">
			</td></tr>
		


	</td>
</tr>


</table>
</cfform>
</cfoutput>


 	</fieldset>
</div>
<cfif NOT isDefined('returnTo')>
	<cfswitch expression="#session.id_job#">
		<cfcase value="1"><cfset returnto="PM"></cfcase>
		<cfcase value="2"><cfset returnto="Contracts"></cfcase>
		<cfcase value="3"><cfset returnto="Controller"></cfcase>
		<cfdefaultcase><cfset returnto="docs"></cfdefaultcase>
	</cfswitch>
</cfif>

<cfinclude template="_docList.cfm">
<cfelse><!--- view only --->
	<cfset returnto="">
	<cfinclude template="dsp_ARA_docs_view.cfm">
	

</cfif>

<!--- Tooltip Initialization ---->
<script>
// initialize tooltip
$("#docdesc img[title]").tooltip({

	// place tooltip on the right edge
	position: "center right",

	// a little tweaking of the position
	offset: [17, 10],

	// custom opacity setting
	opacity: 1.0
}).dynamic({ bottom: { direction: 'down', bounce: true } });
</script>
