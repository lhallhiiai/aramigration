<!--- Deriving the organization chain and managers from the division --->

<cfset div_id="0934"><!--- cae --->

<cfquery name="bottom" datasource="#Application.Ods#">
select * from org_ckis
where dvsn=934
</cfquery>

<cfdump var="#bottom.org_mngr#" format="text">

<cfquery name="mgr1" datasource="#Application.ods#">
	Select * from empl_ckis
	where empl_nmbr='#bottom.org_mngr#'
</cfquery>

<cfdump var="#mgr1#" format="text">
<!--- now look for the operation above the division. Division will be blank. --->
<cfquery name="op" datasource="#Application.Ods#">
select * from org_ckis
where dvsn='' and oprtn='#bottom.oprtn#'
</cfquery>

<cfdump var="#op#" format="text">

<!--- Get the manager of the operation --->
<cfquery name="mgr2" datasource="#Application.ods#">
	Select * from empl_ckis
	where empl_nmbr='#op.org_mngr#'
</cfquery>
<cfdump var="#mgr2#" format="text">

<!--- get division info --->

<cfquery name="div" datasource="#Application.Ods#">
select * from org_ckis
where oprtn='' and grp='#op.dvsn#'
</cfquery>

<cfdump var="#div#" format="text">
