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
$(document).ready(function(){ 
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
  $("#showhelp").click(function() {
	  $("#overlay").fadeIn("fast");
	  $("#help").slideDown("fast");
	  centerPopup();
	});
  $("#closepopup").click(function() {
	  $("#overlay").fadeOut("fast");
	  $("#help").slideUp("fast");
	});
  $("#overlay").click(function() {
	  $("#overlay").fadeOut("fast");
	  $("#help").slideUp("fast");
	});
  $("#showadvanced").click(function() {
    $("#advanced").slideToggle("fast");
	});
  $(window).resize(function() {  
	centerPopup();  
	}); 
});

