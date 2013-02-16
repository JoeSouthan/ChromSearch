$(document).ready(function(){ 
	$.ajaxSetup({
        beforeSend: function(xhr, status) {
            $("#spinner").fadeIn("fast");
        },
        complete: function() {
            $("#spinner").fadeOut("fast");
			$("#cutter").slideDown("fast");
			$("cutter-text").fadeOut("fast");
			$("#cutter-text").html("Please Choose what restriction enzymes to cut with:");
			$("cutter-text").fadeIn("fast");
        }
    });
	$("#show4").click(function() {
	  $("#cutter").ajax({ type:"GET", url:"load_enz.pl", data: {gene : "$geneID"});
	});	
});