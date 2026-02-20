

<script>
  $(document).ready(function(){
              $("#alion_org").autocomplete("index.cfm?fuseaction=app.OrgAutoComplete",
                {
                                minChars:2,
                                delay:200,
                                extraParams: {limit:100,sector: function() { return $("input[name='Sector']:checked").val(); }}, 
                                autoFill:false,
                                matchSubset:true,
                                matchContains:1,
                                cacheLength:100,
                                selectOnly:1
                });
                $("#alion_org").result(function(event,data)
                {
                                var tmp = data[0].split(" [");
                                var name = tmp[0];
                                /* var oprid = tmp[1].replace("]",""); */
                                $("#alion_org").val(oprid);
                });

                $("input[name='Sector']").change(function() {
                	$('input#alion_org').flushCache();
                });
				$("#OMSNum").autocomplete("index.cfm?fuseaction=app.omsAutoComplete",
                {
                                minChars:2,
                                delay:200,
                                extraParams: {limit:100}, 
                                autoFill:false,
                                matchSubset:true,
                                matchContains:1,
                                cacheLength:100,
                                selectOnly:1
                });
				$("#JamisNum").autocomplete("index.cfm?fuseaction=app.jamisNoAutoComplete",
                {
                                minChars:2,
                                delay:200,
                                extraParams: {limit:100}, 
                                autoFill:false,
                                matchSubset:true,
                                matchContains:1,
                                cacheLength:100,
                                selectOnly:1
                });
				

  });
 </script>
 

<form>

	<input name="JamisNum" id="JamisNum" size=90 class="inputtext" maxlength=100>

</form>	