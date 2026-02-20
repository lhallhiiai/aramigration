<cfset pagetitle="ARA Org Chart">
<p class="smtitle">admin</p>
<p class="title"><cfoutput>#pagetitle#</cfoutput>

<cfquery name="Sec" datasource="#Application.dsn#">
	select distinct sctr from v_users
</cfquery>

<cfoutput query="Sec">
<p><b>#sctr#</b></p>
	<!--- Groups under this sector  --->
	<cfquery name="Group" datasource="#Application.dsn#">
		Select distinct grp from v_users
		where sctr='#sctr#'
	</cfquery>
	<ol>
		<cfloop query="Group">
			<li>Group: #grp#</li>
			<!--- Ops under this Group --->
			<cfquery name="Ops" datasource="#Application.dsn#">
				Select distinct oprtn from v_users 
				where grp='#Group.grp#'
				and sctr='#Sec.sctr#'
			</cfquery>
			<ol>
			<cfloop query="Ops">
				<li>Operation: #oprtn#<br></li>
				<!--- Divisions Under this Op --->
				<cfquery name="divs" datasource="#Application.dsn#">
					Select Distinct dvsn
					from v_users
					where oprtn='#ops.oprtn#'
					and grp='#group.grp#'
					and sctr='#Sec.sctr#'
				</cfquery>
				<br><ol>
				<CFLOOP query="divs">
					<li>Division: #dvsn#<br></li>
					<cfquery name="People" datasource="#Application.dsn#">
						Select empname,title,appOrder,delegateTo_OprID
						from v_users
						where oprtn='#ops.oprtn#'
						and grp='#group.grp#'
						and sctr='#Sec.sctr#'
						and dvsn='#divs.dvsn#'
						order by appOrder
					</cfquery>
					<br>
					<ol>
						<cfloop query="People">
						<li>#empname#, #title#
						<cfif delegateTo_OprID NEQ "">
							<cfquery name="GetDel" datasource="#Application.dsn#">
								SELECT * FROM v_users
								where oprid = '#delegateTo_oprID#' 
							</cfquery>
							, Delegated to #delegateTo_oprID#, #GetDel.title#, #GetDel.sctr#, 
							#GetDel.grp#, #GetDel.oprtn#, #GetDel.dvsn#
							
						</cfif>
						</li>
						</cfloop>
					</ol><br>
				</cfloop>
				</ol>
			</cfloop>
			</ol>
		</cfloop>
	</ol>



</cfoutput>