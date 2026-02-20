<cfajaximport tags="cfform">
<table width=100% cellpadding=2 cellspacing=2 class="border">
<tr>
	<!----             select Company                    --->
	<td width="25%" class="border" valign="bottom">
	Company
	</td>
	<td class="border" colspan="5">default company zzzzzzzzzzzzzzzz#DefaultCompany#
	<cfif id_cat NEQ 10>
	 <img src="images/ControllerStep.gif" align="right" alt="">
	 </cfif>
	 <input type="radio" name="company" id="company"  value="ALIN" <cfif #getController.company# EQ "ALIN">checked
	 <cfelseif DefaultCompany EQ "ALIN">Checked</cfif>>ALIN 
     <input type="radio" name="company" id="company2" value="WCGS" <cfif #getController.company# EQ "WCGS">checked
	 <cfelseif DefaultCompany EQ "WCGS">Checked</cfif>>WCGS
     <input type="radio" name="company" id="company3" value="WCON" <cfif #getController.company# EQ "WCON">checked
	 <cfelseif DefaultCompany EQ "WCON"></cfif>>WCON
     <input type="radio" name="company" id="company4" value="CANA" <cfif #getController.company# EQ "CANA">checked
	 <cfelseif DefaultCompany EQ "CANA"></cfif>>CANA
</tr>
<cfdiv id="UserDiv" bind="url:view/display/dsp_ClinFormV2.cfm?company={company}">