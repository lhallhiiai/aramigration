
	<cfoutput>
		<!--- For binary uploads, need to first load to temp directory -- then save it to database --->
		<cfset destDir="#Getdirectoryfrompath(GetCurrentTemplatePath())#">
       
		<cffile action="readbinary" file="#application.PDFDirDel#/#createdpdf#" variable="insFile" />
        <cfif isDefined('id_ara') and id_ara NEQ "">
        <cfquery name="getAraAppLogID" datasource="#Application.dsn#">
			select max(id_araAppLog) as ID_araAppLog from araAppLOG where id_ara='#id_ara#'
		</cfquery>
        </cfif>
        
		<cfquery name="insEmail" datasource="#Application.dsn#" result="insAttchmnt">
   		INSERT INTO emailLog
              (
              id_emailType
              ,subject
			  ,MsgTo
			  ,MsgCC
			  ,message_pdf
			  ,sentDate
			  <cfif isDefined('id_ara') and id_ara NEQ "">
			  ,id_ara
              ,statusID
              ,ID_araAppLog
			  </cfif>
              )
        VALUES
              (
              <cfqueryparam value ="#id_emailType#" cfsqltype = "CF_SQL_INTEGER" />
			  ,<cfqueryparam value ="#subject#" cfsqltype="cf_sql_varchar" />
              ,<cfqueryparam value ="#To#" cfsqltype="cf_sql_varchar" />
              ,<cfqueryparam value ="#CC#" cfsqltype = "CF_SQL_varchar">
			  ,<cfqueryparam value ="#insFile#" cfsqltype="cf_sql_blob" />
			  ,<cfqueryparam value="#now()#" cfsqltype="CF_SQL_TIMESTAMP" />
			  <cfif isDefined('id_ara') and id_ara NEQ "">
			  ,<cfqueryparam value ="#id_ara#" cfsqltype = "CF_SQL_INTEGER" />
              ,<cfqueryparam value ="#id_status#" cfsqltype = "CF_SQL_INTEGER" />
              ,'#getAraAppLogID.ID_araAppLog#'
			  </cfif>
			  )
   		</cfquery>
		<cfquery name="getThisID" datasource="#Application.dsn#">
			Select Max(id_emailLog) as thisID From emailLog
		</cfquery>
		<cfset ThisID = #getThisID.ThisID#>	
		<cfif id_emailType EQ 2><!--- Delegation: MGann added 9/16/2013 --->
			<cfquery name="setEmailID" datasource="#application.dsn#">
				Update emaillog
				set
				id_delegation=#id_delegation#
				where id_emailLog=#thisID#
			</cfquery>
		</cfif>
		<!--- +++++++++++++++++  Delete Temporary File +++++++++++++++++++++  --->
		
		<CFFILE ACTION="Delete"
  				FILE="#application.PDFDirDel#\#createdpdf#">
	</cfoutput>


