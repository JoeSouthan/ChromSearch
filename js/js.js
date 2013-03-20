// 	JavaScript 
	google.load("visualization", "1", {packages:["corechart"]});
$(document).ready(function() {
// Variables
	var textBox 	 = $("#searchquery"),
		submitButton = $("#submitSearch"),
		searchLive	 = $("#searchTerms"),
		main		 = $("#main"),
		mainWrapper	 = $("#main_wrapper"),
		content		 = $("#content"),
		help		 = $("#help"),
		overlay		 = $("#overlay"),
		loader		 = $("#loader"),
		radioName	 = $("input[name=searchType]:radio"),
		radioValue	 = $("input[name=searchType]:checked", "#mainSearch").val(),
		query 		 = textBox.val(),
		perpage 	 = $("#perpage").val(),
		error		 = $("#errorbox"),
		errordiv	 = $("#errordiv")
		;
	//Google Charts API

	var options = {
		isStacked: true,
		hAxis : {},
		legend: {},
		chartArea : {left:5, top: 5 ,'width':'80%', 'height':'90%'},
		width: 650,
		height: 50
	};
	
	
	function ajaxLinks () {
		$("a").each (function() {
			var href = $(this).attr("href");
			if (href) {
				var href = $(this).attr("href");
				var urlSplit = href.split("?")[1];
				//alert(urlSplit);
				if ($(this).is('[href^=#!/]')){
					//do nothing
				} else {
					if (urlSplit) {
						if (urlSplit.match(/^gene=/)) {
							var singleID = urlSplit.split("=")[1];
							$(this).attr("href", "#!/single/" +singleID );
						}
					} else {
						$(this).attr("href", "#!/" + href);
					}
				}
			} else {
			}
		});
	}
	//Ajax
	$.ajaxSetup({
		beforeSend: function(xhr, status) {
			loader.slideDown("fast");
			overlay.fadeIn("fast");
		},
		success: function(xhr, status) {
			loader.slideUp("fast");
			overlay.fadeOut("fast");
			//google.setOnLoadCallback(drawChart(xhr));                                                   
		},
		error: function(jqXHR, exception) {
			loader.slideUp("fast");
			errordiv.html("Ajax error: "+jqXHR.status+".");
			showError();
		},
		cache:true
	});
	$("#content").ajaxComplete( function() {
		ajaxLinks();
	});
	//-----------

	//From -http://www.joelpeterson.com/blog/2010/12/quick-and-easy-windowless-popup-overlay-in-jquery/
	function centerPopup(){  
		var winw = $(window).width();  
		var winh = $(window).height();  
		var popw = help.width();  
		var poph = help.height();  
		help.css({  
			"position" : "absolute",  
	  //    "top" : winh/2-poph/2,  
			"left" : winw/2-popw/2  
		}); 
	}
	//-----------------
	function loadit(url) {
		main.load(url);
	}
	function closeHelp() {
		if (help.is(":visible")) {
			overlay.fadeOut("fast");
			help.slideUp("fast");
		}
	}
	function openHelp() {
		overlay.fadeIn("fast");
		help.slideDown("fast");

	}
	function showMain () {
		main.show();
	}
	function hideMain () {
		main.hide();
	}
	function showContent () {
		content.show();
	}
	function hideContent () {
		content.hide();
	}
	function showError () {
		error.fadeIn("fast").delay(6000).fadeOut("fast");
		main.show();
		$.History.go('!/');
		overlay.delay(6000).fadeOut("fast");
	}

	
	
	function createSearchLink (type) {
		var query = textBox.val();
		var perpage = $("#perpage").val();
		var radioVal = $("input[name=searchType]:checked", "#mainSearch").val();
		return "#!/search/"+radioValue+"/"+query+"/"+perpage+"/0";
	}



	//Search Validation
	function validateSearch () {
		if (textBox.val().length < 3) {
			submitButton.removeAttr("href");
			submitButton.fadeTo("slow", 0.2);
			textBox.addClass("error");
			return false;
		} else {
			var searchLink = createSearchLink("link");
			submitButton.attr("href", searchLink);
			submitButton.fadeTo("fast", 1);
			textBox.removeClass("error");
			return true;
		} 
	}
	function showSearch (){
		var query = textBox.val();
		var perpage = $("#perpage").val();
		var radioVal = $("input[name=searchType]:checked", "#mainSearch").val();
		searchLive.html("<p>You are searching for: "+query+" using a "+radioVal+" search.</p>");	
	}
	
	function doSearch (searchterms) {
		// eg !,search,GeneID,123p,10,0
		$.ajax ({
			url:"json.json",
			type: "GET",
			dataType: "json",
			data: {selector: searchterms[1], searchType: searchterms[2], query:searchterms[3]},
			success: function (data) {
				var counter = 0;
				content.html('<h2>Results</h2>');
				$.each(data, function(i, val) {
					var features = val["sequencefeatures"];
					content.append('<div class="result"><div class="genename">'+val["name"]+'</div><div class="diagram" id="chart_div'+counter+'"></div><div class="link"><a href="return_single.pl?gene='+val["name"]+'">More &raquo;</a></div></div>');
				    google.setOnLoadCallback(drawChart(features,counter));
					counter++;
				});
				console.log(data);
			//	alert(data["test"]["length"]);			
				loader.slideUp("fast");
				overlay.fadeOut("fast");
				//return [data, counter];
			},
		
		});
	}
	function drawChart (features, counter) {
		var feats = ["Gene"];
		var numbers = ["Gene"];
		$.each(features,function() {
			var f1 = this.split(":");
			feats.push(f1[0]);
			numbers.push(parseInt(f1[1]));
		});
		var data1 = google.visualization.arrayToDataTable([
			feats,
			numbers
		]);
		var chart = new google.visualization.BarChart(document.getElementById('chart_div'+counter));
		chart.draw(data1, options);	
	}
	

	//blur
	textBox.blur(validateSearch);
	textBox.blur(showSearch);
	radioName.blur(showSearch);
	//$("a").hover(ajaxLinks);
	//keypress
	textBox.keyup(validateSearch);
	textBox.keyup(showSearch);
	radioName.keyup(showSearch);
	//Change
	radioName.change(showSearch);

	//Toggles 
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
	$(document).on("click", "#showadvanced", function() {
		$("#advanced").slideToggle("fast");
	});
	$(window).resize(function() {  
		centerPopup();  
	}); 
//---------------------------------//

	submitButton.removeAttr("href");
	submitButton.fadeTo("slow", 0.2);
	ajaxLinks();
	$("#no-js").hide();
	$("#no-js-alert").hide();
	$("#searchLink").show();
	
	//jQueryUi
	$("#searchType").buttonset();
	
	submitButton.click(function () {
		//alert ("click");
	});
	//reject browsers
	
	
	$.History.bind(function(state) {
		urlState = state.split(/\//g);
	//	alert(urlState[1]);
	//	alert(state);
		switch (true) {
				case(state == undefined):
					alert("error");
					break;
				case(urlState[1] == "/" || urlState[1] == ""):
					closeHelp();
					showMain();
					hideContent();
					break;
				case(urlState[1] == "help"):
					openHelp();
					centerPopup();
					break;
				case(urlState[1] == "search"):
					//content.load("cgi-bin/search_results.pl?"+$('#mainSearch').serialize());
					//content.load("DummyResults/dummyresults.html#wrapper");
					doSearch(urlState);
					hideMain();
					closeHelp();
					showContent();
					ajaxLinks();
					//alert($('#mainSearch').serialize());
					break;
				case(urlState[1] == "single"):
					content.load("cgi-bin/return_single.pl?id="+urlState[2]);
					closeHelp();
					ajaxLinks();
					break;
			}
				
		});
		
});