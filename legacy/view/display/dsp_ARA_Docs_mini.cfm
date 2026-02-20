
<cfif (isDefined('url.aid')) AND (NOT isDefined('id_ara'))>
	<cfset id_ara="#decrypt(url.AID,request.encryptkey,request.encrypttype,'hex')#">
</cfif>

<cfparam name="buttontext" default="Submit">
<cfparam name="FormOrView" default="Form">
<cfparam name="ThisID" default="">
<cfset whichtab="documents">
<cfset pagetitle="ARA Documents">
<cfparam name="Action" default="Setup">
<cfparam name="id_contract" default="">
<cfparam name="id_controller" default="">

<!--- <cfset max_doc=10> --->


<!--- ++++++++++++++ Functions to Include +++++++++++++++++++++  --->
<!--- +++++++++++ Pulls ARA, user, groups, sector, category, status ++++++++++ --->
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


<cfinclude template="dsp_tabset_mini.cfm">
<cfinclude template="../../model/m_forms/qry_AttachmentStatus.cfm">
<cfset docs=#AttachmentStatus(id_ara,id_cat)#>		
<!--- If in controller, or rejected and this person is the contract manager, they will see form. Otherwise view only --->
<cfif ((FormorView EQ "Form")  AND (ListFind('2,8,9',id_status)) 
      and ((ID_contract EQ session.id_user) OR (FindnoCase(id_contract,session.delegators)))
)
OR
(
(FormorView EQ "Form")  AND (ListFind('4,5',id_status)) 
      and ((id_controller EQ session.id_user) OR (FindnoCase(id_controller,session.delegators)))
)

OR
(
(FormorView EQ "Form")  AND (ListFind('1',id_status)) 
      and ((id_PM EQ session.id_user) OR (FindnoCase(id_PM,session.delegators)))
)
>

<div id="docdesc" style="width: 800px;overflow: hidden; border: 1px #cccccc; ;margin:0px; color:#cccccc;">
<cfoutput>
<fieldset> <legend><b>Category #ThisCat# Documentation</b></legend>
            
<!---<cfinclude template="dsp_messages.cfm">---><!--- If present display ConfirmMsg, ErrorMsg, Warning Msg --->

<cfform method="Post" id="DocUpload" name="DocUpload" enctype="multipart/form-data" action="index.cfm?fuseaction=app.ARA_Docs_include">
<cfinput type="hidden" name="ReturnTo" value="#ReturnTo#">
<cfinput type="hidden" name="action" value="#action#">
<cfinput type="hidden" name="FormOrView" value="#FormOrView#">
<Cfif isDefined('id_attachment') and (ID_attachment NEQ "")>
	<cfinput type="hidden" name="id_attachment" value="#id_attachment#">
	<cfinput type="hidden" name="FileName" value="#fileName#">
</cfif>
<table width="750" cellpadding=2 class="border" cellspacing=2>

<tr>
	<td  class="border">
		<cfif Action NEQ "Update">
			
			<b>Upload supporting documents (.pdf, .xls, and .xlsx format only).</b><br><br>
				<div onclick="$('input[type=file]').click()" width=150 height=30 >
			   <input name="Filename" required="Yes" Message="Select a file to Upload" type="file" maxlength="200"  id="upload" size="150"  /></div>
				
				<br><font class="tiny">Maximum length of filename is 28 characters. Name will be truncated.</font> 
			
		<cfelse><!--- can only update Meta data for Update --->
		<p style="margin-left:20px;">
		<font class="message">Updating Information for File: <b>#Filename#</b><br>
		Size: #numberformat(Filesize,",")# Uploaded: #Date#
		</p>
		</cfif>
    </td>
	<td class="border" width=400 rowspan="2"><b>#returnto#  Documentation:</b>
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
		 <cfif (isdefined("Filetype") and Find(ID_attachtype,Filetype)) OR (DocTypes.Recordcount EQ 1)>
		<cfinput type="checkbox" name="ID_attachtype" value="#ID_attachtype#" Required="Yes" Message="Check the required information this document contains" Checked>
		<cfelse>
			<cfinput type="checkbox" name="ID_attachtype" value="#ID_attachtype#" Required="Yes" Message="Check the required information this document contains">
		</cfif>
</td>
		<td valign="top">#Short_desc#...<br>
		<font class="tiny" style="color:##777777;">#long_desc#</font><br><br></td>
		</tr>
	</cfloop>
		<tr>
			<td valign="top">&nbsp;</td>
			<td valign="top">
			<cfif Doctypes.Recordcount EQ 0>
				<cfinput type="checkbox" CHECKED name="ID_attachtype" value="26">
				
			<cfelse>
				<cfinput type="checkbox" name="ID_attachtype" value="26">
			</cfif>
			
			</td>
			<td valign="top">
			Optional Documentation<br>
			<font class="tiny" style="color:##777777;">Documents are not required by the ARA system, but the user considers them necessary to process the ARA.</font><br><br>
			</td>
	</table>
	</td>
</tr>
<tr>
	<td class="border">
    	<cfif isdefined("description")>
        <br><b>Description</b>:&nbsp;&nbsp;<cfinput name="description" id="description" value="#description#" required="Yes" Message="Describe the contents of the document" type="text" maxlength="2000" class="inputtext2" size="60"/><br>
        <cfelse>
        <br><b>Description</b>:&nbsp;&nbsp;<cfinput name="description" id="description" value="" required="Yes" Message="Describe the contents of the document" type="text" maxlength="2000" class="inputtext2" size="60"/><br>
        </cfif>
		
    </td>
</tr>
<tr>
	<td colspan=2 class="border" align="center"><input type="hidden" value="#id_cat#" name="id_cat">
    <input type="hidden" value="#id_ara#" name="id_ara">
		<input type="submit" class="button" value="#buttontext#">
			</td></tr>
	</td>
</tr>


</table>
</cfform>
</cfoutput>

</div>
</cfif><!--- Form or View If ....I think! --->

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
