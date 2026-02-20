<script>
  $(document).ready(function(){
		  $("#ARAUser").autocomplete("index.cfm?fuseaction=app.SearchUserAutoComplete",
			{
				minChars:1,
				delay:200,
				extraParams: {limit:100}, 
				autoFill:false,
				matchSubset:true,
				matchContains:1,
				cacheLength:100,
				selectOnly:1
			});
});
</script>
<p class="smtitle">Search</p>
<p class="title">Search ARA, Docs, Emails</p>
<cfform method="Post" preservedata="True" enctype="multipart/form-data" action="">
<cfinput type="hidden" name="DoSearch" value="Yes">
<table class="border" width="100%" cellpadding=2 cellspacing=2>
<!--- ****************************** Sector Group ********************************  --->
<tr>
	<td class="border" >Sector</td>
	<td  class="border">
		
		<cfquery name="getSector" datasource="#application.dsn#">
			Select * from sector 
			order by sectorName
		</cfquery>
		<cfselect class="inputtext" name="sectorName">
        		<option value=""> -- Sector -- </option>			
			<cfoutput query="getSector">
				<option value="#sectorname#">#sectorname#</option>
			</cfoutput>
		</cfselect>
	</td>
	<td class="border" >Group</td>
	<td  class="border">		
		<cfquery name="getGroup" datasource="#application.dsn#">
			Select distinct division as groupname
			from v_ara
			where division in ('CEW', 'FSG', 'ISR','LVC')
		</cfquery>
		<cfselect  class="inputtext" name="groupName">
        		<option value=""> -- Group -- </option>			
			<cfoutput query="getGroup">
				<option value="#groupName#">#groupName#</option>
			</cfoutput>
				<option value="LVC">LVC</option>
		</cfselect>
	</td>
</tr>

<!--- ****************************** Sector Group ********************************  --->
<tr>
	<td class="border"  colspan="1">Amount Containing</td>
	 <!--- ****************************** ARA Amount ********************************  --->
	 <td align="left" nowrap class="border">$
	 <cfinput name="amount" type="text"  class="inputtext" value="" message="Please enter a valid amount for ARA" size=9 maxlength=12>
	 
	 </td>
	<td class="border" >ARA User</td>
	<td  class="border"><cfinput type="text" name="ARAUser" id="ARAUser" size=40  class="inputtext">
    <!---
	<cfquery name="getPpl" datasource="#Application.dsn#">
		SELECT * from users order by last_name, first_name
 	</cfquery>
    <cfselect  class="inputtext" name="id_user"> 
    		<option value=""> -- Last Name, First Name -- </option>
		<cfoutput query="getPpl">
         	<option value="#id_user#">#last_name#, #first_name#</option>
        </cfoutput>
    </cfselect>---></td>
</tr>

<!--- ****************************** ARA ID & Risk Category ********************************  --->
<tr>
	<td  class="border">ARA ID</td>
	<td class="border"><cfinput  class="inputtext" name="id_ara" value="" type="text" size=15 maxlength="15"></td>
	<td  class="border">Risk Category</td>
	<td class="border"><cfquery name="getRCat" datasource="#Application.dsn#">
		SELECT * From category order by risklevel, catName
 	</cfquery>
    <cfselect  class="inputtext" name="id_cat"> 
    		<option value=""> -- Risk Category -- </option>
		<cfoutput query="getRCat">
         	<option value="#id_cat#">#catname#</option>
        </cfoutput>
    </cfselect> 
	</td>
</tr>

<!--- ****************************** JAMIS & Status ********************************  --->
<tr>
	<td  class="border">CostPoint Contract</td>
	<td class="border"><cfinput  class="inputtext" type="text" size=15 name="JamisNo" value=""></td>
	<td  class="border">CLINS</td>
	<td class="border"><cfinput  class="inputtext" type="text" size=15 name="clinNo" value=""></td>
</tr>

<tr>
	<td class="border"  colspan="1">
        Expiration Date
	 </td>
	 <!--- ****************************** Expiration Date ********************************  --->
	 <td  nowrap class="border">
	 <cfinput name="expirationDate" type="datefield" value=""  class="inputtext" validate="date" message="ARA Expiration Date invalid" size=9 maxlength=13>
	 
	 </td>
	 
	  <!--- ****************************** ARA Status ********************************  --->
	 <td  class="border">Status</td>
	<td class="border"><cfquery name="getStatus" datasource="#Application.dsn#">
		SELECT * From status order by statusName
 	</cfquery>
    <cfselect  class="inputtext" name="id_status"> 
    		<option value=""> -- Search on Status -- </option>
		<cfoutput query="getStatus">
         	<option value="#id_status#">#statusName#</option>
        </cfoutput>
    </cfselect>
    </td>
</tr>

<tr>
	
	 
	  <!--- ****************************** Customer ********************************  --->
	 <td  class="border">Customer</td>
	<td colspan=4 class="border"><cfinput  class="inputtext" type="text" size=15 name="customername" value="">
    </td>
</tr>


<tr>
	<td class="border" align="center" colspan=4 >
		<!---onClick="JavaScript: window.location.href='index.cfm?Fuseaction=app.Search';"--->
		<cfinput name="Reset" type="button" value="Reset" onClick="JavaScript: window.location.href='index.cfm?fuseaction=app.searchARA&Menu=ARA_Sea';">
		<cfinput type="submit" name="find" value="Find"> 
		
	</td></tr>
</table>
</cfform>
<!--- if search button is clicked --->
<cfif isdefined("form.doSearch")>
<cfif len(form.araUser) gt 5>
<cfset id_User=left(ListGetAT(Form.araUser,2,':'), len(ListGetAT(Form.araUser,2,':'))-1)>
<cfelse>
<cfset id_user = "">
</cfif>
<cfparam name="activesort" default="startdate">
<cfset strURL = "">
<cfset listClin = "">
<cfif #clinNo# NEQ "">
	<cfquery name="getClins" datasource="#application.dsn#"> 
    	select * from CLINS where clinNo like '%#clinNo#%'
    </cfquery>
    <cfloop query="getClins">
    	<cfif listfind(listClin, #getClins.id_ara#) EQ 0>
    		<cfset listClin = listappend(listClin, #getClins.id_ara#)>
        </cfif>
     </cfloop>
</cfif>

<cfif isDefined("id_status")>
	<cfset strURL = strURL & "&id_status=" & id_status>
</cfif>
<cfif isDefined("id_user")>
	<cfset strURL = strURL & "&id_user=" & id_user>
</cfif>
<cfif isDefined("JamisNo")>
	<cfset strURL = strURL & "&JamisNo=" & JamisNo>
</cfif>
<cfif isDefined("id_cat")>
	<cfset strURL = strURL & "&id_cat=" &id_cat>
</cfif>
<cfif isDefined("id_ara")>
	<cfset strURL = strURL & "&id_ara=" &id_ara>
</cfif>
<cfif isDefined("sectorName")>
	<cfset strURL = strURL & "&sectorName=" & sectorName>
</cfif>
<cfif isDefined("clinNo")>
	<cfset strURL = strURL & "&clinNo=" &clinNo>
</cfif>
<cfif isDefined("groupName")>
	<cfset strURL = strURL & "&division=" & groupName>
</cfif>
<cfif isDefined("amount")>
	<cfset strURL = strURL & "&amount=" & amount>
</cfif>
<cfif isDefined("expirationDate")>
	<cfset strURL = strURL & "&expirationDate=" & expirationDate>
</cfif>

<cfquery name="ara" datasource="#application.dsn#">  
		Select * from v_ara
		where (1=1)
		<cfif #expirationDate# NEQ "">
			and convert(varchar(20), startdate, 101) like '#expirationDate#%'
		</cfif>
		<cfif #id_status# NEQ "">
			and id_status= #id_status#
		</cfif>
		<cfif #id_user# NEQ "">
			and (id_user = #id_user# or id_pm = #id_user# or id_contract = #id_user# or id_controller = #id_user#)
		</cfif>
        <cfif #JamisNo# NEQ "">
			and jamisNo like '%#JamisNo#%'
		</cfif>
        <cfif #id_cat# NEQ "">
			and id_cat = #id_cat#
		</cfif>
        <cfif #id_ara# NEQ "">
			and reference like '%#id_ara#%'
		</cfif>
        <cfif #customername# NEQ "">
			and customername like '%#customername#%'
		</cfif>
        <cfif #sectorName# NEQ "">
			and sector = '#sectorName#'
		</cfif>
        <cfif #clinNo# NEQ "" and len(listClin) NEQ 0>
			and id_ara in (#listClin#)
		</cfif>
        <cfif #groupName# NEQ "">
			and division = '#groupName#'
		</cfif> 
        <cfif #amount# NEQ "">
			and (amountTotal like '%#amount#%' or totalAnticipated like '%#amount#%') 
		</cfif>        
		Order BY #activeSort#
	</cfquery>
<cfoutput>#ara.recordcount# records found. <p></p><p></p></cfoutput>
<cfoutput><h3>
<a href="view/display/dsp_searchExport.cfm?fuseaction=app.searchExportARA&Menu=ARA_Sea&expirationDate=#Dateformat(expirationDate,"MM/DD/YY")#&id_status=#id_status#&id_url=#id_user#&jamisno=#JamisNo#&id_cat=#id_cat#&id_ara=#id_ara#&customerName=#customername#&sectorName=#sectorName#&clinNo=#clinNo#&groupName=#groupName#&amount=#amount#&id_user=#id_User#">Export Search Result</a></h3></cfoutput>

<cfoutput>
<table cellpadding=2 width=100% cellspacing=2 class="border">
<tr>
	<td class="grad">&nbsp;</td>
	<td nowrap class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=reference&Menu=ARA_Sea&strURL=#strURL#" class="embed">ID & Revision</a>
	<cfif activeSort EQ 'ara.reference'><img src="images/sort.png"></cfif></td>
	<td nowrap class="grad">CLINS</td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=JamisNo&Menu=ARA_Sea&strURL=#strURL#" class="embed">PROJECT ID ##</a>
	<cfif activeSort EQ 'ara.JamisNo'><img src="images/sort.png"></cfif>
	</td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=title&Menu=ARA_Sea&strURL=#strURL#" class="embed">Title</a>
	<cfif activeSort EQ 'ara.Title'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=CustomerName&Menu=ARA_Sea&strURL=#strURL#" class="embed">Customer</a>
	<cfif activeSort EQ 'ara.CustomerName'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=ExpirationDate&Menu=ARA_Sea&strURL=#strURL#" class="embed">Expiration</a>
	<cfif activeSort EQ 'ara.StartDate'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=amountTotal&Menu=ARA_Sea&strURL=#strURL#" class="embed">Amount Total</a>
	<cfif activeSort EQ 'ara.AmountTotal'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=id_status&Menu=ARA_Sea&strURL=#strURL#" class="embed">State</a>
	<cfif activeSort EQ 'ara.id_status'><img src="images/sort.png"></cfif></td>
</tr>
</cfoutput>
<cfset count=1>
<cfoutput query="ara">
<tr>
	<td class="border">#count#.</td>
	<cfset AID=#encrypt(id_ara,request.encryptkey,request.encrypttype,'hex')#></td>
	
	<td nowrap class="border"><a href="index.cfm?Fuseaction=app.ARA_PM&AID=#AID#&Menu=ARA_Detail" class="embed">#reference#</a></td>
	<td class="border">
    
		<cfquery name="CLINfo" datasource="#application.dsn#">
			SELECT * 
			FROM CLINS
			WHERE id_ara = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id_ara#">
		</cfquery>
		#clinfo.clinno#
	</td>
	<td nowrap class="border">#JamisNo#</td>
	<td class="border">#title#</td>
	<td class="border">#customerName#</td>
	<td class="border">#Dateformat(expirationDate,"MM/DD/YY")#</td>
	<td class="border">#dollarformat(amountTotal)#</td>
	<td class="border">#statusName#</td>
	<cfset count=count+1>
</tr>
</cfoutput>
</table>
<p></p>

</cfif>

<!--- if sort link is clicked --->

<cfif isdefined("url.activesort")>
<cfset strURL = "">
<cfif isDefined("url.id_status")>
	<cfset strURL = strURL & "&id_status=" & url.id_status>
</cfif>
<cfif isDefined("url.id_user")>
	<cfset strURL = strURL & "&id_user=" & url.id_user>
</cfif>
<cfif isDefined("url.JamisNo")>
	<cfset strURL = strURL & "&JamisNo=" & url.JamisNo>
</cfif>
<cfif isDefined("url.id_cat")>
	<cfset strURL = strURL & "&id_cat=" &url.id_cat>
</cfif>

<cfif isDefined("url.id_ara")>
	<cfset strURL = strURL & "&id_ara=" &url.id_ara>
</cfif>
<cfif isDefined("url.customername")>
	<cfset strURL = strURL & "&customername=" &url.customername>
</cfif>
<cfif isDefined("url.sectorName")>
	<cfset strURL = strURL & "&sectorName=" & url.sectorName>
</cfif>
<cfif isDefined("url.clinNo")>
	<cfset strURL = strURL & "&clinNo=" &url.clinNo>
</cfif>
<cfif isDefined("url.groupName")>
	<cfset strURL = strURL & "&groupName=" & url.groupName>
</cfif>
<cfif isDefined("url.amount")>
	<cfset strURL = strURL & "&amount=" & url.amount>
</cfif>
<cfif isDefined("url.expirationDate")>
	<cfset strURL = strURL & "&expirationDate=" & url.expirationDate>
</cfif>
<cfset listClin = "">
<cfif #url.clinNo# NEQ "">
	<cfquery name="getClins" datasource="#application.dsn#"> 
    	select * from CLINS where clinNo = '#url.clinNo#'
    </cfquery>
    <cfloop query="getClins">
    	<cfif listfind(listClin, #getClins.id_ara#) EQ 0>
    		<cfset listClin = listappend(listClin, #getClins.id_ara#)>
        </cfif>
     </cfloop>
</cfif>

<cfquery name="ara" datasource="#application.dsn#">  
		Select * from v_ara
		where (1=1)
		<cfif #url.expirationDate# NEQ "">
			and convert(varchar(20), startdate, 101) like '#url.expirationDate#%'
		</cfif>
		<cfif #url.id_status# NEQ "">
			and id_status= #id_status#
		</cfif>
		<cfif #url.id_user# NEQ "">
			and (id_user = #id_user# or id_pm = #url.id_user# or id_contract = #url.id_user# or id_controller = #url.id_user#)
		</cfif>
        <cfif #url.JamisNo# NEQ "">
			and jamisNo like '%#url.JamisNo#%'
		</cfif>
        <cfif #url.id_cat# NEQ "">
			and id_cat = #url.id_cat#
		</cfif>
        <cfif #url.id_ara# NEQ "">
			and reference like '%#url.id_ara#%'
		</cfif>
        <cfif isdefined("url.customername") and #url.customername# NEQ "">
			and customername like '%#url.customername#%'
		</cfif>
        <cfif #url.sectorName# NEQ "">
			and sector = '#sectorName#'
		</cfif>
        <cfif #url.clinNo# NEQ "" and len(listClin) NEQ 0>
			and id_ara in (#url.listClin#)
		</cfif>
        <cfif #url.groupName# NEQ "">
			and grp = '#url.groupName#'
		</cfif> 
        <cfif #url.amount# NEQ "">
			and (amountTotal like '%#url.amount#%' or totalAnticipated like '%#url.amount#%') 
		</cfif>        
		Order BY #url.activeSort#
	</cfquery>

<cfoutput>#ara.recordcount# records found.</cfoutput>
<cfoutput>
<table cellpadding=2 width=100% cellspacing=2 class="border">
<tr>
	<td class="grad">&nbsp;</td>
	<td nowrap class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=reference&Menu=ARA_Sea&strURL=#strURL#" class="embed">ID & Revision</a>
	<cfif activeSort EQ 'ara.reference'><img src="images/sort.png"></cfif></td>
	<td nowrap class="grad">CLINS</td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=JamisNo&Menu=ARA_Sea&strURL=#strURL#" class="embed">Project ID ##</a>
	<cfif activeSort EQ 'ara.JamisNo'><img src="images/sort.png"></cfif>
	</td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=title&Menu=ARA_Sea&strURL=#strURL#" class="embed">Title</a>
	<cfif activeSort EQ 'ara.Title'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=CustomerName&Menu=ARA_Sea&strURL=#strURL#" class="embed">Customer</a>
	<cfif activeSort EQ 'ara.CustomerName'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=StartDate&Menu=ARA_Sea&strURL=#strURL#" class="embed">Expiration</a>
	<cfif activeSort EQ 'ara.StartDate'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=reference&Menu=ARA_Sea&strURL=#strURL#" class="embed" bgcolor="##EEEEEE">Awaiting Approval By</a></td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=amountTotal&Menu=ARA_Sea&strURL=#strURL#" class="embed">Amount Total</a>
	<cfif activeSort EQ 'ara.AmountTotal'><img src="images/sort.png"></cfif></td>
	<td class="grad"><a href="#self#?fuseaction=app.searchARA&activesort=id_status&Menu=ARA_Sea&strURL=#strURL#" class="embed">State</a>
	<cfif activeSort EQ 'ara.id_status'><img src="images/sort.png"></cfif></td>
</tr>
</cfoutput>
<cfset count=1>
<cfoutput query="ara">
<tr>
	<td class="border">#count#.</td>
	<cfset AID=#encrypt(id_ara,request.encryptkey,request.encrypttype,'hex')#></td>
	
	<td nowrap class="border"><a href="index.cfm?Fuseaction=app.ARA_PM&AID=#AID#&Menu=ARA_Detail" class="embed">#reference#</a></td>
	<td class="border">
		<cfquery name="CLINfo" datasource="#application.ods#">
			SELECT clin_no, clin_desc, end_date
			FROM jobcost.t_clin_master_ckis
			WHERE cnct_no = <cfqueryparam cfsqltype="cf_sql_varchar" value="#jamisNo#">
		</cfquery>
		#clinfo.clin_no#
	</td>
	<td nowrap class="border">#JamisNo#</td>
	<td class="border">#title#</td>
	<td class="border">#customerName#</td>
	<td class="border">#Dateformat(startDate,"MM/DD/YY")#</td>
	<td class="border" bgcolor="##EEEEEEE">TBD</td>
	<td class="border">#dollarformat(amountTotal)#</td>
	<td class="border">#statusName#</td>
	<cfset count=count+1>
</tr>
</cfoutput>
</table>
</cfif>