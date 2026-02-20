<cfparam name="oprid" default=""/>
 <cfquery name="getUser" datasource="#application.dsn#">
			SELECT  users.id_user, users.emplID, users.oprid, users.ID_group, users.ID_sector, 
			        users.ID_role, users.ID_job, users.empname, users.first_name, 
                    users.last_name, users.Status, users.Inactive, groups.groupName, 
					sector.sectorName, jobTitle.title AS title, jobTitle.description, 
					jobTitle.appOrder, role.roleName, role.roleShort, role.roleDesc
			FROM     users INNER JOIN
                      role ON users.ID_role = role.ID_role INNER JOIN
                      groups ON users.ID_group = groups.ID_group INNER JOIN
                      sector ON users.ID_sector = sector.ID_sector INNER JOIN
                      jobTitle ON users.ID_job = jobTitle.id_job
			where oprid = '#oprid#'
		</cfquery>
		<cfoutput query="getUser">
			first_name:#first_name##chr(59)# 
			last_name:#last_name##chr(59)#
			sector:#sectorName##chr(59)#
			role:#roleName##chr(59)#
			group:#groupName##chr(59)#
			title:#title##chr(10)#
		</cfoutput>	