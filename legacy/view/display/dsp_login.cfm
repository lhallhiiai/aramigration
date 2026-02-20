
<cfoutput>
<table border=0 cellpadding=0 cellspacing=0>
<tr>
<td valign="top">

<cfform name="save" method="post" action="">
	#message#
	<table width=350 class="border" align="center" cellpadding=2 cellspacing=2>
	<tr>
		<td class="border">User Name:</td>	
		<td class="border">
			<cfinput type="text" name="userName">
		</td>
	</tr>
	<tr>
		<td class="border">Password:</td>
		<td class="border"><cfinput type="password" name="pass"></td>
	</tr>
	<tr>
		<td class="border" colspan=2 align="center">
			<cfinput name="submit" type="submit" value="Login">
	</td></tr></table>
</cfform>
</td>
<td width=20><img src="images/spacer.gif"></td>
<td valign="top">

</td>
</tr>
</table>
</cfoutput>