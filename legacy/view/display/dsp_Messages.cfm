<!--- generic message include to display all messages.	--->
<!--- this include should be positioned after and text.	--->
<!--- be sure that all prior <cfoutput> tags are closed before this include.	--->

<cfparam name="message" default="">
<cfparam name="confirmMsg" default="">
<cfparam name="warningMsg" default="">
<cfparam name="errorMsg" default="">
<cfparam name="TblWidth" default=800>
<cfoutput>


<cfif confirmMsg NEQ "">
	<cfif #errorMsg# EQ ""><!--- Use HTTP_Referrer on docupload. Can return to page with Confirm and Error Message,
	                             So only want to show errorMsg in that instance --->
	<table align="left" width=#TblWidth# cellpadding=5 border=0>
	<tr>
	<td width=26 ><img src="images/IconBlueCheck.gif"></td>
	<td align="left"> 
	<p class="confirmMsg">#confirmMsg#</p>
	</td></tr></table><br clear="all">
	</cfif>
</cfif>
<cfif warningMsg NEQ "">
	<table  align="left" width=#TblWidth# align="center" cellpadding=5 border=0>
	<tr>
	<td width=26><img src="images/MessageWarning.gif">
	<td align="left"> <p class="warningMsg">
	#warningMsg#</p>
	</td></tr>
	</table><br clear="all">
</cfif>

<cfif errorMsg NEQ "">
	<table  align="left" width=#TblWidth# align="left"  cellpadding=5 border=0>
	<tr>
	<td width=26><img src="images/MessageIconRedX.gif"></td>
	<td align="left"> <p class="errorMsg">
	#errorMsg#</p>
	</td></tr>
	</table><br clear="all">
	</cfif>
</cfoutput>
<br clear="all">