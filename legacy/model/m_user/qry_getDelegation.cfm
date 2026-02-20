<!---  Get Delegation List, or info on one delegation --->

<cfquery name="Del" datasource="#Application.dsn#">
SELECT DISTINCT delegation.id_delegation, delegation.fk_delegateFrom_ID, delegation.fk_delegateTo_ID, delegation.delegateFrom_oprid
, delegation.delegateTo_oprid, delegation.startDate, delegation.endDate

, users.id_user as delegator_userid, users.ID_group as delegator_groupID, groups.groupName as delegator_groupName
, users.ID_sector as delegator_sectorID, role.RoleName as delegator_role, sector.sectorName as delegator_sectorName
, users.empname as delegator_empname, users.oprid as delegateFrom_oprid, users.Inactive as delegator_inactive

, u2.id_user as Delegate_To_userid, u2.ID_group as Delegate_To_groupID, g2.groupName as Delegate_To_groupName
, u2.ID_sector as Delegate_To_sectorID, r2.RoleName as Delegate_To_role, s2.sectorName as Delegate_To_sectorName
, u2.empname as Delegate_To_empname, u2.oprid as delegateTo_oprid, u2.Inactive as Delegate_To_inactive

FROM        delegation 
            INNER JOIN users ON delegation.fk_delegateFrom_ID = users.id_user 
            INNER JOIN role on users.id_role=role.id_role
                  INNER JOIN groups ON users.ID_group = groups.ID_group 
                  INNER JOIN sector ON users.ID_sector = sector.ID_sector
                  
                  INNER JOIN users u2 ON delegation.fk_delegateTo_ID = u2.id_user 
                  INNER JOIN role r2 on users.id_role=r2.id_role
                  INNER JOIN groups g2 ON users.ID_group = g2.ID_group 
                  INNER JOIN sector s2 ON users.ID_sector = s2.ID_sector

<cfif isDefined('id_delegation') and (id_delegation NEQ "")>
WHERE id_delegation=#id_delegation#
</cfif>
</cfquery>