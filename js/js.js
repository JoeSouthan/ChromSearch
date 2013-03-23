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
		errordiv	 = $("#errordiv"),
		breadcrumbs  = $("#breadcrumbs-wrapper"),
		ColNCS 		 = "#1668F5",
		ColEXON		 = "#F0ED3C",
		ColINTRON	 = "#CEF5CF"
		;

	
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
				if ($(this).is('[href^=#!/]')){
					//do nothing
				} else {
					$(this).attr("href", "#!/" + href);	
				}
			}
		});
	}
	//Ajax
	$.ajaxSetup({
		beforeSend: function(xhr, status) {
			loader.fadeIn("fast");
			overlay.fadeIn("fast");
		},
		success: function(xhr, status) {
			loader.fadeOut("fast");
			overlay.fadeOut("fast");
			//google.setOnLoadCallback(drawChart(xhr));                                                   
		},
		error: function(jqXHR, exception) {
			loader.fadeOut("fast");
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
		return "#!/search/"+radioVal+"/"+query+"/"+perpage+"/0";
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
		var searchLink = createSearchLink("link");
		submitButton.attr("href", searchLink);
		searchLive.html("<p>You are searching for: "+query+" using a "+radioVal+" search.</p>");	
	}
	
	//Do a JSON search
	function doSearch (searchterms) {
		// eg !,search,GeneID,123p,10,0
		var dataStructure = {}
		if (searchterms[1] == "search"){
			dataStructure = {selector: searchterms[1], searchType: searchterms[2], query:searchterms[3] };
		} else if (searchterms[1] == "single"){ 
			dataStructure = {selector: searchterms[1], query:searchterms[2] };
		}
		var result = $.ajax ({
			//url:"json.json",
			url:"cgi-bin/json.pl?",
			type: "GET",
			dataType: "json",
			data: dataStructure,
			success: function (data) {
				if (searchterms[1] == "search") {
					outputSearchHTML(data);		
					loader.fadeOut("fast");
					overlay.fadeOut("fast");
					//return [data, counter];
				} else if (searchterms[1] == "single") {
					outputSingleHTML(data);		
					loader.fadeOut("fast");
					overlay.fadeOut("fast");
				} else {
					alert(searchterms[1]);
				}
			},
		
		});
	}
	//Output JSON to HTML
	function outputSearchHTML (data) {
		var counter = 0;
		content.html('<div class="center"><h2>Results</h2></div>');
		$.each(data, function(i,val) {
			//alert(i+","+val["name"]);
		//	console.log(i,val);
			var features = val["SeqFeat"];
			content.append('\
				<div class="result">\
					<div class="genename">'+val["GeneName"]+'</div> \
					<div class="diagram" id="chart_div'+counter+'"></div> \
					<div class="link"><a href="return_single.pl?gene='+i+'">More &raquo;</a></div> \
				</div>');
			google.setOnLoadCallback(drawChart(features,counter));
			counter++;
		});
	
	
	}
	function outputSingleHTML (data) {
		var counter = 0;
		$.each(data, function (i,val) {
			var features = val["SeqFeat"];
			content.html(' \
    <div class="searchform"> \
    	<h2 class="center">Single result for: '+i+'.</h2> \
        <div class="singleresult"> \
        	<div class="info"> \
            	<span>Name: '+val["GeneName"]+' | Genbank Accession: '+i+' | Chromosomal Location: '+val["GeneLength"]+'</span> \
            </div> \
            <div class="single-wide"> \
            	<h2>Protein Product</h2>\
            	<p>Some Product</p>\
            	<h2>Sequence Characteristics</h2> \
            	<h3>Gene Layout</h3> \
                <div class="diagram centerdiv" id="chart_div0"></div>\
                <h3>Codon Usage</h3> \
				<div class="center"> \
					<img src="img/test.png" alt="Codon Usage"/> \
				</div> \
                <h2>Common Restriction Sites</h2> \
                <h3>EcoR1</h3> \
                <p>Some Text</p> \
                <h3>BamH1</h3> \
                <h3>BsuMI</h3> \
                <p id="cutter-text">Would you like to <a href="#cutter" id="show4">cut your own?</a></p> \
				<div id="spinner"> \
					<img src="../img/ajaxloader.gif" alt="Loading" width="24" height="24" /> \
				</div> \
                <div id="cutter"> \
                </div> \
            </div> \
            <div class="clearfix"></div> \
            <div class="single-wide"> \
            	<h2>Sequences</h2> \
            	<a href="#SequenceDNA" id="show1">Click to reveal DNA Sequence</a> \
            	<div id="SequenceDNA"> \
					<span></span> \
				</div> \
                <br /> \
                <a href="#SequenceAA" id="show2">Click to reveal Translated Amino Acid Sequence</a> \
                <div id="SequenceAA"> \
					<span></span> \
				</div> \
				<br /> \
				<a href="#codonusage" id="show3">Codon usage</a> \
				<div id="codonusage"> \
					<span></span> \
				</div> \
            </div> \
        </div> \
    </div>');
		google.setOnLoadCallback(drawChart(features,counter));
		});
	}

	//Google Charts API
	//Draw charts
	function drawChart (features, counter) {
		//Split up features array strings into separate arrays
		var feats = ["Gene"];
		var numbers = ["Gene"];
		$.each(features,function() {
			var f1 = this.split(";");
			feats.push(f1[0]);
			var difference = f1[1].split(":");
			var glength = Math.abs(parseInt(difference[0])-parseInt(difference[1]));
			console.log(glength);
			numbers.push(glength);
		});
		//Set the colours based on the sequence feature
		var colours = [];
		$.each(feats, function () {
			if (this == "NCS"){
				colours.push(ColNCS);
			} else if (this == "EXON") {
				colours.push(ColEXON);
			} else if (this == "INTRON") {
				colours.push(ColINTRON);
			} 
		});
		
		var options = {
			isStacked: true,
			hAxis : {},
			legend: {},
			chartArea : {left:5, top: 5 ,'width':'80%', 'height':'90%'},
			width: 650,
			height: 50,
			colors: colours,
		};
	
		var data1 = google.visualization.arrayToDataTable([
			feats,
			numbers
		]);
		var chart = new google.visualization.BarChart(document.getElementById('chart_div'+counter));
		chart.draw(data1, options );	
	}
	function setBreadcrumbs (urlState) {
		// eg !,search,GeneID,123p,10,0
		var selector;
		var location;
		if (urlState[1] == "search") {
			selector = "Search Result";
			location = urlState[3];
			breadcrumbs.html('<a href="">Home &raquo;</a> <span>'+selector+' &raquo;</span> <span>'+location+'</span>');
		} else if (urlState[1] == "single"){
			location = urlState[2];
			selector = "Single Result";
			breadcrumbs.html('<a href="/">Home &raquo;</a> <span>'+selector+' &raquo;</span> <span>'+location+'</span>');
		} else {
			breadcrumbs.html("");

		}

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
	submitButton.fadeTo("fast", 0.2);
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
					setBreadcrumbs(urlState);
					break;
				case(urlState[1] == "help"):
					openHelp();
					centerPopup();
					break;
				case(urlState[1] == "search"):
					//content.load("cgi-bin/search_results.pl?"+$('#mainSearch').serialize());
					//content.load("DummyResults/dummyresults.html#wrapper");
					//Do the search
					doSearch(urlState);
					setBreadcrumbs(urlState);
					hideMain();
					closeHelp();
					showContent();
					ajaxLinks();
					//alert($('#mainSearch').serialize());
					break;
				case(urlState[1] == "single"):
					//content.load("cgi-bin/return_single.pl?id="+urlState[2]);
					doSearch(urlState);
					setBreadcrumbs(urlState);
					hideMain();
					closeHelp();
					showContent();
					ajaxLinks();
					break;
			}
				
		});
		
});