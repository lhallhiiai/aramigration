<cfparam name="id_note" default="">
<cfif NOT isdefined('url.aid')>
	<cfset AID=#encrypt(id_ara,request.encryptKey,request.encryptType,'hex')#>
</cfif>
<cffunction name="NoteInfo">
	<cfargument name="this_id_note" required="no">
	
	<cfif isDefined('this_id_note') and (#this_id_note# NEQ "")>
		<cfquery name="n" datasource="#Application.dsn#">
			Select * from ara_note
			where ara_note.id_note=#this_id_note#
		</cfquery>
		<cfset note=#n.note#>
		<cfset added_by=#n.added_by#>
		<cfset added_on=#dateformat(n.added_on,"MM/DD/YY")#>
		<cfset updated_by=#n.updated_by#>
		<cfset updated_on=#dateformat(n.updated_on,"MM/DD/YY")#>
	<cfelse>
		<!--- Check to see if there is a note for this participant ID and pull up most recent --->
		<cfquery name="Existing_notes" datasource="#Application.dsn#">
			SELECT MAX(id_note) AS lastNote
			from ara_note
			where id_ara=#id_ara#
		</cfquery>
		<cfif NOT isDefined('Existing_notes.LastNote')>
			<cfset note="">
			<cfset added_by=#session.id_user#>
			<cfset added_on=#dateformat(now(),"MM/DD/YY")#>
			<cfset updated_by=#session.id_user#>
			<cfset updated_on=#dateformat(now(),"MM/DD/YY")#>
		<cfelse>
			<cfset id_note=#Existing_notes.lastNote#>
			<cfset note="">
			<!--- cfset note=#noteinfo(Existing_notes.lastNote)# --->
		</cfif>
	</cfif>
	<cfreturn note>
</cffunction>
	
<cfswitch expression="#Action#">
<cfcase value="InsertSetup">
	<cfset info=#NoteInfo()#>
	<cfif #note# EQ "">
		<cfset buttontext="Add">
		<cfset action="Insert"><!--- next action --->
	<cfelse>
		<cfset buttontext="Update">
		<cfset action="Update">
	</cfif>
</cfcase>
<cfcase value="UpdateSetup">
	<cfset info=#NoteInfo(id_note)#>
	<cfset buttontext="Update">
	<cfset Action="Update">
</cfcase>
<cfcase value="DeleteSetup">
	<cfset info=#NoteInfo(id_note)#>
	<cfset PageTitle="Delete Note">
	<cfset buttontext="Delete">
	<cfset Action="Delete">

</cfcase>
<cfcase value="Insert">
    <cftransaction>
	<cfquery name="NewCat" datasource="#Application.dsn#">
		Insert Into ara_note
		(id_ara,note,added_by,added_on,updated_by, updated_on)
		Values
	(#id_ara#,'#note#','#session.id_user#',getDate(),'#session.id_user#',getDate())
	</CFquery>
	<cfquery name="NoteID" datasource="#Application.dsn#">
		SELECT MAX(id_note) AS NewNoteID
		FROM ara_note
	</cfquery>
	<cfset id_note=#NoteID.NewNoteID#>
	</cftransaction>
	<cfset confirmMsg="Note Added.">
	<cflocation url="index.cfm?fuseaction=app.ara_note&Action=Updatesetup&this_id_note=#id_note#&AID=#AID#&confirmMsg=#confirmMsg#" addtoken="No">
</cfcase>

<cfcase Value="Update">
	<cfquery name="Update" datasource="#Application.dsn#">
		Update ara_note
		Set
		note='#note#',
		updated_by='#session.id_user#',
		updated_on=getDate()
		
		where id_note=#ID_note#
	</cfquery>
	
	<cfset confirmMsg="Note updated.">
	<cflocation url="index.cfm?fuseaction=app.ara_note&Action=Updatesetup&AID=#AID#&this_id_note=#id_note#&id_note=#id_note#&confirmMsg=#confirmMsg#" addToken="No">
	
</cfcase>
<cfcase value="Delete">
	<cfquery name="DelNote" datasource="#Application.dsn#">
		delete from ara_note
		where id_note=#id_note#
	</cfquery>
	<cfset confirmMsg="Note Deleted.">
	<cflocation url="index.cfm?fuseaction=app.ara_note&Action=insertsetup&AID=#AID#&confirmMsg=#confirmMsg#" addToken="No">

</cfcase>
</cfswitch>