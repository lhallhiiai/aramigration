<cfparam name="next_app" default="">
<cfset whichtab="approvals">
<cfparam name="DivShow" default="Showform">
<cfset pagetitle="ARA Approvals">
<cfset returnto="Approvals">
<cfparam name="testit" default="1">
<cfparam name="currentCycle" default="1">

<cfoutput>
<cfif isPrint EQ "No">
<!-- 1  --><table width=100% cellpadding=0 cellspacing=0 border=0>
		<tr>
		<td valign="top">
		<p class="title">
		Approvals</p>
		</td>
		<td valign="top" align="right">
		<a class="embed" href="#self#?fuseaction=app.ARA_cfdocument&AID=#AID#">Print ARA <img src="images/PrinterIcon.gif" border=0></a>
<!-- /1  --></td></tr></table>
</cfif>
<!--- ARA Summary Info at top of page --->
<cfif isPrint EQ "No">
<fieldset><legend><b>Approval Log</b></legend>
</cfif>
<!--- ARA Navigational Tabs --->

<!---  Default to current cycle, provide links to other cycles --->
<cfquery name="AllCycles" datasource="#Application.dsn#">
	SELECT Distinct cycle
	From ARAapplog
	where id_ara=#id_ara#
	Order by cycle DESC
</cfquery>
<cfparam name="thiscycle" default="#ListGetAt(ValueList(Allcycles.cycle),1)#">

<!--- ++++++++++++++++     SHOW / HIDE REJECT DIV   +++++++++++++++++++ --->
	<!--- dsp_ARA_top_summary  ARA info, test for rejected and get log info --->
	<cfquery name="RejLog" datasource="#application.dsn#">
		Select top 1 * from ARAapplog
		where id_ara=#id_ara#
		and isRejection='True'
		and cycle=#thiscycle#
		Order by ApprovalDate Desc
	</cfquery>	
	
<!--- ++++++++++++++++     END REJECT DIV   +++++++++++++++++++ --->

<br><br>
<cfinclude template="dsp_messages.cfm">

</cfoutput>
<!--- Must have an amount from PM to determine thresholds --->
<cfif (id_status GTE 2) AND (Len(thresh_list) GT 0)>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cffunction name="Job_Person">
	<cfargument name="JobID" required="yes">
	<cfif Find(jobID,'1,2,3')><!--- is PM, Contracts,Controller pull from ara --->
			<cfquery name="ARA_User" datasource="#Application.dsn#">
				SELECT     ara.ID_PM, ara.ID_Contract, ara.ID_Controller, 
						v_users.empname, v_users.fk_delegateTo_ID, v_users.title, 
						v_users.sctr,v_users.grp,v_users.oprtn,v_users.dvsn,
						v_users.id_user, v_users.oprid, v_users.Approve_Grp,
                    			v_users.id_job, v_users.delegateTo_oprid, ara.id_ara
				FROM     ara INNER JOIN v_users ON 
				<cfif jobID Eq 1>
					ara.ID_PM = v_users.id_user
				<cfelseif jobID eq 2>
					ara.ID_Contract = v_users.id_user
				<cfelseif jobID eq 3>
					ara.ID_Controller = v_users.id_user
				</cfif>
				where id_ara=#id_ara#
			</cfquery>
		<cfelse>
			<cfquery name="ARA_User" datasource="#Application.dsn#">
				Select empname,title,id_user, oprid, id_job,delegateTo_oprid,sctr,grp,oprtn,dvsn,Approve_grp
				from
				v_users
				where Id_job=#jobID# and oprid is not null
				<!---<cfif i EQ 4>
					and dvsn='#division#'
				</cfif>
				<cfif Find(jobID,'5,6')>
					and oprtn='#op#'
				<cfelseif find(jobID,'7,8,9')>
					AND (approve_grp ='#Group#'
					OR grp='#Group#')
				<cfelseif find(jobID,'10,11,12')>
					and sctr='#sector#'
				</cfif>--->
				and Inactive='False'
			</cfquery>
		</cfif>
		<cfset approver_count=ARA_User.recordcount>
</cffunction>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<cfoutput>
<!-- 1  --><table cellpadding=0 cellspacing=0 width=100%>
<tr>
	<td valign="top" width=70%>
	
	<cfset loopcnt=1>
	<cfparam name="archive" default="No">
	<p><b>Approval Cycle(s):</b>&nbsp;&nbsp;
	<cfloop query="AllCycles">
		<!--- Superscript for cycle number --->
		<cfswitch expression="#allCycles.cycle#">
			<cfcase value="1"><cfset sup="st"></cfcase>
			<cfcase value="2"><cfset sup="nd"></cfcase>
			<cfcase value="3"><cfset sup="rd"></cfcase>
			<cfdefaultcase><cfset sup="th"></cfdefaultcase>
		</cfswitch>
		
		<!--- Where u r marker ---><cfif thisCycle EQ cycle>&nbsp;&nbsp;<img src="images/RightArrow.png"></cfif>
		<cfif loopcnt EQ 1>
			<a class="embed" href="index.cfm?Fuseaction=app.ARA_approvals&AID=#AID#&ID_Status=6&CurrentCycle=#AllCycles.cycle#&Thiscycle=#cycle#">
			Current #AllCycles.cycle#<sup>#sup#</sup></a> 

		<cfelse>
			<cfif thisCycle NEQ cycle>&nbsp;&nbsp;|&nbsp;&nbsp;</cfif>
			<a class="embed" href="index.cfm?Fuseaction=app.ARA_approvals&AID=#AID#&ID_Status=6&CurrentCycle=#AllCycles.cycle#&Thiscycle=#cycle#&Archive=Yes">
			#AllCycles.cycle#<sup>#sup#</sup></a> 
		</cfif> 
		<cfset loopcnt=loopcnt+1>
	</cfloop>
	</p>
	<!-- 2 --><table cellpadding=2 width=100% cellspacing=2 class="border">
	<tr>
		<td><!--- thresh_list is #thresh_list#<br> ---><!--- cfdump var="#session#" format="text" --->
		<!-- 3 --><table cellpadding=2 width=100% cellspacing=2>
		<cfquery name="Last" datasource="#application.dsn#"><!--- Pull up most recent approval --->
			Select top 1 * from araApplog
			where id_ara=#id_ara#    
			Order by ApprovalDate DESC
		</cfquery>
		<!--- cfdump var="#Last#" format="text" --->
		<cfif last.recordcount EQ 0>
			<cfset last_index=1>
		<cfelse>
			<!--- Find job title in the list of the last person to approve --->
			<cfset last_index=ListFind(thresh_list,Last.id_job)>
		</cfif>
		
		<!--- Do not get next if approved, rejected, or cancelled --->
		<!--- CFIF NOT ListFind('12,8,9,10,13',id_status)> Not Approved(12),Rejected(8,9), or Cancelled (10) Exported --->
		<CFIF ListFind('1,2,3,4,5,6,7',id_status)><!--- Pre-Approved states --->
		

				<cfset next_App=ListGetAt(thresh_List,(last_Index+1))><!--- Get Next in Chain --->
			<!--- cfif val(last_index+2) LTE Len(Thresh_list)>
				<cfset next_app=ListGetAt(thresh_list,(last_index+2))>
			<cfelse>
				<cfset next_app=13><!--- Last_index + 2 is longer than the list...going to CCS --->
			</cfif --->
			<!--- cfoutput>id_status is #id_status# #thresh_list# next_app is #next_app#</cfoutput --->
		<cfelse><!--- If it was 12,8,9,or 10, there is no next approval --->
			<!--- cfoutput>id_status is #id_status# #thresh_list#</cfoutput --->
			<!--- cfset next_app=ListGetAt(thresh_List,(last_Index)) --->
			
		</cfif>
		<!--- Last.id_job is #last.id_job# Next approval is #next_app# Last Index is #last_index# --->
		<cfset current_approval=1>
		<cfset loopcount=1>
	    <cfset session.nextapprover = "">	
        <cfset session.nextapprover_d = "">	
        
<!--- MAIN LOOP:   Loop through list of approval job ids   --->

<cfloop index="i" list="#thresh_list#">
			<cfset del_flag=0>
		    <!--- Check to see whether we have gotten this approval  --->
			<cfquery name="CheckLog" datasource="#Application.dsn#">
				Select * from araAppLog,jobTitle,users
				where id_ara=#id_ara#
				and cycle=#thiscycle#
				and id_status <> 1
				and araAppLog.id_job=#i#
				and araApplog.id_user=Users.id_user
				and users.id_job=jobTitle.id_job
			</cfquery>
			
			<!--- tr><td colspan=5>Recordcount is #checklog.recordcount#...#i#...#thresh_list# 
			<cfdump var="#checklog#" format="text">
			<cfif #checklog.recordcount# EQ 1>
				<!--- cfdump var="#checklog#" format="text" --->
			</cfif>
			</td></tr --->
			
<!--- Part 1: Have Rejection or approval for this Job (i) --->
<cfif CheckLog.RecordCount GT 0>
		<tr <cfif CheckLog.isRejection IS 'True'>bgcolor="##EEEEEE"</cfif>>
		<td width=20 class="border">#loopcount#.</td>
		<cfif CheckLog.isRejection IS 'True'>
			<td class="done" width=28 bgcolor="##EEEEEE"><img src="images/ThisOne.png"></td>
			<td  class="border">#CheckLog.title#</td>
			<td class="border">
				#Checklog.EmpName# 
				<cfif (CheckLog.oprid_delegateFrom NEQ "") AND (Checklog.oprid NEQ Checklog.oprid_delegateFrom)>
					<br>
					<font class="smuc">DELEGATE OF</font>  #CheckLog.oprid_delegateFrom#
				</cfif>
			</td>
			<td class="border">
				<font class="red"><b>REJECTED ... #DateFormat(RejLog.ApprovalDate,"MM/DD/YY")#
					#timeformat(RejLog.ApprovalDate,"hh:mm tt")#</b></font>
			</td>
		<cfelse><!--- Not Rejected --->
			<td class="notdone"  width=28 bgcolor="##f4f5f6" valign="top">
			<img src="images/IconBlueCheck.gif" alt="Approved"></td>
			<td  class="border">#CheckLog.title# </td>
			<td class="border">#Checklog.EmpName# 
			<cfif (CheckLog.oprid_delegateFrom NEQ "") AND (Checklog.oprid NEQ Checklog.oprid_delegateFrom)>
				<br><font class="smuc" >DELEGATE OF</font>  #CheckLog.oprid_delegateFrom#
			</cfif>
			<td nowrap class="border"><cfif (ListFind('2,5,9',id_cat)) and CheckLog.id_job LT 4>Completed<cfelse>Approved</cfif> #dateformat(CheckLog.approvalDate,'mm/dd/yy')# ...  #timeformat(CheckLog.approvalDate,'hh:mm tt')#
			</td>
</cfif>
</tr>
				
<!--- Part 2: Have nothing for this Job (i) --->

<cfelse><!--- do not yet have approval for this job_id --->

		<cfif i EQ next_app>
			<tr <cfif (NOT ListFind('8,9',id_status) AND (Archive EQ 'No'))>bgcolor="##EEEEEE"</cfif>>
		<cfelse>
			<tr>
		</cfif>

<!--- col 1: --->
		<td valign="top" class="border">#loopcount#. </td>
<!--- Col 2: image arrow (next) or minus (not done yet) --->
		<td width=28 valign="top" class="border">
			<cfif (NOT ListFind('8,9',id_status) AND (Archive EQ 'No')) AND (i EQ Next_app)>
				<img src="images/ThisOne.png" alt="Next Approval">
			<cfelse>
				<img src="images/IconNotDone.gif" alt="Not approved Yet">
			</cfif>
		</td>	
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		<cfset this_approval=#Job_Person(i)#>
		<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		
<!--- Col 3: Job Title of  approver (and Delegatee) --->
			<td valign="top" class="border">
			<cfif ARA_user.DelegateTo_Oprid NEQ "">
				<cfquery name="del" datasource="#application.dsn#">
					select empname as del_empname,title as del_title,id_user as del_id_user,oprid as del_oprid
					from v_users
					where oprid='#ARA_user.DelegateTo_Oprid#'
				</cfquery>
				<cfset oprid_delegateFrom=ARA_User.oprID>
				<cfset oprid_delegateTo=del.del_oprid>
				<cfset del_flag=1>
			<cfelse>
				<cfset del.del_id_user="">
				<cfset oprid_delegateTo="">
				<cfset oprid_delegateFrom="">
			</cfif>
			
			#Ara_User.title#<br>
			<cfif del_flag>
				<font class="smuc" >DELEGATED TO:</font><br>
					 #del.del_title# 
			</cfif>
			<cfif approver_count GT 1>
				<br>(One approver needed)
			</cfif>
			</td>
			
<!--- Col 4: Name of approver and delegate --->
			
			<td class="border">
			<cfif (NOT ListFind('8,9',id_status) AND (Archive EQ 'No'))>
				<CFIF approver_count EQ 0>
					<font style="font-size:7px; font-family: MS Trebuchet;color:##cc0033;">
					NO ARA USER IS DEFINED IN THIS POSITION
				<cfelseif approver_count EQ 1><!--- NOT CCS, where there can be 4 --->
		
						<cfif i EQ next_app><font style="font-weight:bold;"></cfif>
						#ARA_User.empname# <br>
                        <cfif len(session.nextapprover) EQ 0>
                        	<cfset session.nextapprover = #ARA_User.oprid#>
                        </cfif>
                        <cfif len(session.nextapprover_d) EQ 0>
                        	<cfset session.nextapprover_d = #ARA_User.DELEGATETO_OPRID#>
                        </cfif>
						<!--- #Ara_User.sctr# #Ara_User.grp# #Ara_User.oprtn# #Ara_User.dvsn# --->
						
						<cfif del_flag>
							<font class="smuc" >DELEGATED TO:</font><br>
							 #del.del_empname#
						</cfif>
				<cfelse><!--- CCS has more that one --->
						<cfloop query="ARA_User">
						#empname#<br>
						<!--- #Ara_User.sctr# #Ara_User.grp# #Ara_User.oprtn# #Ara_User.dvsn#<br>
						#org# --->
						</cfloop>
				</cfif>
			</cfif>
					
<!--- COL 5: R E J E C T   or  A P P R O V E  OR Pending     ---->
		<td align="center" class="border">
		<cfif i NEQ next_app>
			Pending
		<cfelse><!--- this Job is the next approval --->
				<!--- PMs, Contract Mgrs, Controllers should approved from tabs, not approval page so state is set properly--->
				<!--- cfset NotPMCMCON=ListFind("1,2,3",session.id_job) --->
				<cfif Find(session.id_user, PMCC_List) and (id_status LT 6)>
					<cfset PMCMCON=True>
				<cfelse>
					<cfset PMCMCon=False>
				</cfif>
				<!--- DEBUG --->
				<!--- PMCMCon is #PMCMCon# The person who is logged in has been delegated to by:
				#session.delegators# PM_ID is: #PM_ID#<br>
				The id_user of this approver is: #Ara_user.id_user#<br>
				This session id_user is #session.Id_user#, and the delegated to id_user is #del.del_id_user#<br>
				Do we find the ara approver in delegators? #(Find(Ara_user.id_user,session.delegators))#<br>
				--->
				
				
				<!--- is owner delegating to this person? Is this person the owner, or delegatee?
				      or is this person part of CCs [a group] and this is the final step  --->
				<cfif  (PMCMCon is False) and ((session.id_user EQ Ara_user.id_user) OR (session.id_user EQ del.del_id_user))
				      OR (ListFind((Valuelist(ARA_User.id_user)),session.id_user)
					  AND (id_status NEQ 8 AND id_status NEQ 9))>
					<cfif loopcount EQ ListLen(thresh_list)>
						<cfset ThisisFinal="True">
					<cfelseif loopcount EQ val(ListLen(thresh_list)-1)>
						<cfset ThisisFinal="Next">
					<cfelse>
						<cfset ThisisFinal="">
					</cfif>
					
					<cfif PMCMCON is False><!--- Core team should use tabs to approve, not approval page --->
					<!--- ++++++++++++++++++  APPROVE +++++++++++++++  --->
					<cfset ApproveComment="Approval #loopcount#: Approved by #session.jobtitle#  [#session.empname#].">
					<cfif del_flag EQ 1 and (oprid_delegateTo EQ session.oprid)>
					<!--- Then the delgatee is doing the approval --->
						<cfset ApproveComment="#ApproveComment#" & " [Delegation from #oprid_delegateFrom# to #oprid_delegateTo#]">
					</cfif>
					<img src="images/tabcheck.png" align="absbottom">&nbsp;&nbsp; <a class="green" href="index.cfm?Fuseaction=app.approve&aid=#url.aid#&cycle=#thiscycle#&id_status=6&this_job=#i#&ThisisFinal=#ThisisFinal#&comment=#ApproveComment#&oprid_delegateFrom=#oprid_delegateFrom#&oprid_delegateTo=#oprid_delegateTo#&Approver=#session.empname#"><b>APPROVE</b></a>
				 <!--- ++++++++++++++++++  REJECT  +++++++++++++++  --->
				 <cfif del_flag EQ 1>
						<cfset RejComment="Approval #i#: REJECTED by #session.empname#. Approval authority Delegated by #ARA_user.empname#.">
					<cfelse> 
						<cfset RejectComment="Approval #i#: REJECTED by #Ara_user.empname#, #Ara_user.Title#">
					</cfif>
&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/redX.png" align="absbottom">&nbsp;&nbsp;<a class="red" href="##"  onClick="showrej();return false;"><b>REJECT</b></a>&nbsp;&nbsp;
				 <cfelse>
				 	Approve or Reject from tab
				  </cfif>
		   	<cfelse>
				Pending		
			</cfif><!--- This session.user is approver --->
			</td>
			</tr>
			
			</cfif>
</cfif><!--- Part 2: Do not yet have approval for this job --->
<cfset loopcount=loopcount+1>
</cfloop>
		
		<!-- 3 --></td></tr></table>
	<!-- 2 --></td></tr></table>
	</td>
</cfoutput>	
	<!--- Column gutter: space, line, space  --->
		<td width=10><img src="images/spacer.gif" width=10></td>
		<td width=1 bgcolor="white"><img src="images/spacer.gif" width=1></td>
		<td width=10><img src="images/spacer.gif" width=10></td>
	<!--- end gutter --->
	<td valign="top" width=50%>
	<cfif NOT Find(id_status,"10,12") AND isPrint EQ 'No'><!--- do not include reject form if Approved ofr Cancelled --->
		<cfinclude template="dsp_reject.cfm">
	</cfif>
	
	</td>
	
</tr>
</table>


<cfelse>
	<cfif id_status LT 2 and Len(thresh_List GT 0)>
	<p>The approval chain is determined by the ARA amount. The PM must supply an amount before the approval chain can be displayed.</p>
	<cfelseif Len(thresh_list) EQ 0>
	<p>The Total Amount of this ARA <cfoutput>($#numberformat(amountTotal)#)</cfoutput> does not have required approvals in the <a class="embed" href="index.cfm?fuseaction=app.Admin_thresholdsV2">Threshold Approval Matrix for this category.</a>
	</cfif>
	
</cfif>