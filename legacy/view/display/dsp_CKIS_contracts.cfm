

<cfquery name="ARAContract" datasource="#Application.dsn#">
	Select distinct ContractNo
	from v_ara
	where ContractNo <> 'Early Start'
</cfquery>
<cfset ARAContracts=valuelist(ARAContract.ContractNo)>
<!--- cfquery name="CheckJamis" datasource="#Application.dsn#">
	Select ContractNo,reference,id_cat,reference,jamisNo
	from v_ara
	where contractNo IN (#ARAContracts#)
</cfquery --->

<cfset notfound=0>
<cfset notFoundList="">
<cfoutput>
<cfloop index="i" list="#aracontracts#">
	<cfquery name="CheckJamis" datasource="#Application.dsn#">
	Select ContractNo,reference,id_cat,reference,jamisNo
	from v_ara
	where contractNo ='#i#'
</cfquery>

<cfquery name="Findit" datasource="#Application.ods#">


<!--- New Query as of 12/16/2012: --->

SELECT isnull(cm.[cnct_no],ck.cnct_no) as JamisNo
      ,isnull(cm.[cnct_desc], ck.cnct_desc) as Cnct_Desc 
      ,isnull(cm.[cust_cnct_no], ck.cnct_no) as Cust_Cnct_No
      ,isnull(cm.[company], ck.company) as Company
FROM [cae_ods].[jobcost].[t_cnct_master_ckis] as cm
left join (  select cs.JAMIS_Num as [cnct_no], a.Title as [cnct_desc], cs.Cust_Cntrct_Num as [cust_cnct_no], pn.Party_AKA as [company]
             FROM [ckis].[Agrmnt_ckis] as a
            join (SELECT [Agrmnt_ID]
            ,max([Agrmnt_Vrsn]) as Agr_Ver 
             FROM [ckis].[Agrmnt_ckis]
                              group by [Agrmnt_ID]) as a1
                    on a.Agrmnt_ID = a1.Agrmnt_ID
                              and a.Agrmnt_Vrsn = a1.Agr_Ver
            join ckis.Cntrct_Spcfc_ckis as cs
                    on a.Agrmnt_Srl_Num = cs.Agrmnt_Srl_Num
            join ckis.Agrmnt_Party_ckis as ap
                    on a.Agrmnt_Srl_Num = ap.Agrmnt_Srl_Num
                    and ap.Party_Role_Code = 0
            join ckis.Party_Name_ckis as pn
                    on ap.Party_ID = pn.Party_ID
                              and ap.Party_Name_ID = pn.Party_Name_ID) as ck
on cm.cnct_no = ck.cnct_no

where isnull(cm.[cust_cnct_no], ck.cnct_no) = '#i#'

</cfquery>
<cfif Findit.Recordcount GT 0>
	<!--- ARA: #checkJamis.reference# JAMISNO: #checkJamis.JamisNo# CONTRACT: #FindIt.cust_cnct_no# Title: #Findit.cnct_desc# --->
	<!--- cfdump var="#findit#" format="text" --->
	<!--- cfquery name="getID" datasource="#Application.ods#">
	select agreement_id,org_sector,org_group from agreements
	where ContractNumber='#FindIt.cust_cnct_no#'
	</cfquery>
	<cfif getid.recordcount GT 0>
		Found in Agreements<br>
	<cfelse>
		<br><br><font style="background-color:##ffff66;">Contract: #FindIt.cust_cnct_no# JamisNo: #CheckJamis.JamisNo# - Not found in CAE_ODS agreements</font><br><br>
		
	</cfif --->
<cfelse>
	<cfset notfound=val(notfound+1)>
	<font style="background-color: ##EEEEEE">NotFound Count: #notfound# ARA #checkJamis.reference# did not find agreement for #CheckJamis.ContractNo#.<br></font>
	<cfset notfoundList=ListAppend(notfoundList,CheckJamis.ContractNo)>

</cfif>

</cfloop>
</cfoutput>


This path is:
<cfset thisPath=#Getdirectoryfrompath(GetCurrentTemplatePath())#>
<cfoutput>
#thispath#
</cfoutput>
