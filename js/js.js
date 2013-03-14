// 	JavaScript 

//From -http://www.joelpeterson.com/blog/2010/12/quick-and-easy-windowless-popup-overlay-in-jquery/
function centerPopup(){  
    var winw = $(window).width();  
    var winh = $(window).height();  
    var popw = $('#help').width();  
    var poph = $('#help').height();  
    $("#help").css({  
        "position" : "absolute",  
  //      "top" : winh/2-poph/2,  
        "left" : winw/2-popw/2  
    }); 
}

function loadit(url) {
	$("#main").load(url);
}
function closeHelp() {
	  $("#overlay").fadeOut("fast");
	  $("#help").slideUp("fast");
}
function openHelp() {
				$("#overlay").fadeIn("fast");
				$("#help").slideDown("fast");

}
$(document).ready(function(){ 
	//Existing 
	$("#show1").click(function() { 
		$("#SequenceDNA").slideToggle("fast");
	});
	$("#show2").click(function() { 
		$("#SequenceAA").slideToggle("fast");
	});
	$("#show3").click(function() { 
		$("#codonusage").slideToggle("fast");
	});
	// $("#show4").click(function() { 
		// $("#cutter").slideToggle("fast");
	// });
	$("#closepopup").click(function() {
		closeHelp();
	});
	$("#overlay").click(function() {
		closeHelp();
	});
	$("#showadvanced").click(function() {
		$("#advanced").slideToggle("fast");
	});
	$(window).resize(function() {  
		centerPopup();  
	}); 
//---------------------------------//
	//clone the main
	var cloned = $("#main").clone();
	//Ajax
	$.ajaxSetup({
        beforeSend: function(xhr, status) {
            $("#loader").fadeIn("fast");
			$("#overlay").fadeIn("fast");
        },
		success: function(xhr, status) {
			$("#loader").fadeOut("fast");
			$("#overlay").fadeOut("fast");
		},
		error: function(jqXHR, exception) {
			alert("Ajax error: " + jqXHR.status +".");
		},
		cache:true
	});
	//set up address bar
	$.address.crawlable(true);
	$.address.init(function(event) {
		$('a').address(function() {
			return $(this).attr('href').replace(location.pathname, '');

		});
	})
	.change (function(event) {
		//$("#main").load($('[rel=address:' + event.value+ ']').attr('href'));
		//alert(""+event.value+"");
		//loadit($(this).attr('href'));
		switch (true) {
			case(event.value == undefined):
				alert("error");
			case(event.value == "/"):
				closeHelp();
				$("#main").html(cloned);
				break;
			case(event.value == "/help"):
				openHelp();
				centerPopup();
				break;
			case(event.value == "/submit"):
				closeHelp();
				//alert($('#mainSearch').serialize());
				$("#main").load("cgi-bin/search_results.pl?"+$('#mainSearch').serialize());
				break;
		}
		});
});