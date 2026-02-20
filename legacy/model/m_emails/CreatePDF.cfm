<!--- Create temporary, unique file name --->
<cfset createdpdf="#session.oprid#" & "#dateformat(now(),'MMDDYY')#" & "#timeformat(now(),'HHmmss')#" & ".pdf">
<cfoutput>
<cfdocument filename="#application.PDFDir#/#createdpdf#"   margintop="1" marginleft=".50" marginbottom="1" marginright=".50" format="PDF" backgroundvisible="yes" overwrite="yes" pageType="letter" unit="in">
#MsgHdr# #MsgDist# #MsgBody#
</cfdocument>
</cfoutput>
<!--- cflocation url="EmailDocument.pdf" --->