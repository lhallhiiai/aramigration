<!--- Query to pull Users, roles, sector, groups --->
<cfparam name="sort" default="last_name">
<cfparam name="inActive" default="0">

<cfquery name="gUsers" datasource="#application.dsn#">
	SELECT  *
	FROM    v_users
	Where 1=1
<cfif isDefined('StaleUsers')>
	and  (sctr IS NULL and grp IS NULL) and Inactive=0
<cfelseif (NOT isDefined('ShowExisting'))><!--- doing lookup to see if user exists or not, disgard inactive setting --->
	and inActive=#inactive#
</cfif>
<!--- might be looking up single user based on ID or oprid --->
<cfif isDefined('id_user') and (id_user NEQ "")>
	and id_user=#id_user#
</cfif>
<cfif isDefined('oprid') and (oprid NEQ "")>
	and oprid='#oprid#'
</cfif>	
<cfif isDefined('ForSector') and (ForSector NEQ "")>
	and sctr='#ForSector#'
</cfif>

<cfif sort NEQ "grp">
	Order by #sort#,grp, apporder
<cfelse>
	Order by grp, apporder
</cfif>
</cfquery>




