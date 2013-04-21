// 	JavaScript 
	//Load in Google Graphs API
	google.load("visualization", "1", {packages:["corechart"]});
$(document).ready(function() {
	// Variables
	var textBox 	 = $("#searchquery"),
		main		 = $("#main"),
		mainWrapper	 = $("#main_wrapper"),
		content		 = $("#content"),
		help		 = $("#help"),
		overlay		 = $("#overlay"),
		loader		 = $("#loader"),
		radioName	 = $("input[name=searchType]:radio"),
		radioValue	 = $("input[name=searchType]:checked", "#mainSearch").val(),
		perpage 	 = $("#perpage").val(),
		error		 = $("#errorbox"),
		errordiv	 = $("#errordiv"),
		breadcrumbs  = $("#breadcrumbs-wrapper"),
		titles		 = $("#titles"),
		ColNCS 		 = "#5C6E7C",
		ColEXON		 = "#AAC1D2",
		ColINTRON	 = "#A65534",
		browse		 = $("#browse"),
		browseb		 = $("#browsebox"),
		searchID 	 = $("#searchform"),
		searchbox	 = $("#searchbox"),
		welcome 	 = $("#welcome"),
		validation   = $("#validation")
		;
	//Scans the page for links and adds "#!/"" to it
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
	//Run the Ajax links when loaded in
	$("#content").ajaxComplete( function() {
		ajaxLinks();
	});
	//Ajax call setup
	$.ajaxSetup({
		beforeSend: function(xhr, status) {
			loader.fadeIn("fast");
			overlay.fadeIn("fast");
		},
		success: function(xhr, status) {
			loader.fadeOut("fast");
			overlay.fadeOut("fast");
			$("#timeout").slideUp("fast");
		},
		error: function(jqXHR, exception, m) {	
			if (exception === "timeout") {
				$("#timeout").slideDown("fast");
			} else {
				loader.fadeOut("fast");
				errordiv.html("Ajax error: "+jqXHR.status+".");
				$("#timeout").slideUp("fast");
				showError();
			}
		},
		cache:true,
		timeout:10000
	});
	//Function to centre a popup
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

	//Help Functions
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

	//Main Functions
	function showMain () {
		main.show();
	}
	function hideMain () {
		main.hide();
	}

	//Content Functions
	function showContent () {
		content.show();
	}
	function hideContent () {
		content.hide();
	}
	//Clears the #content div
	function clearContent () {
		content.html("");
	}

	//Error Functions
	function showError () {
		error.fadeIn("fast").delay(6000).fadeOut("fast");
		main.show();
		$.History.go('!/');
		overlay.delay(6000).fadeOut("fast");
	}	
	
	//Search Validation
	function validateSearch () {
		if (textBox.val().length < 3) {
			validation.fadeIn("fast");
			validation.html("<p>Query must be greater than 3 characters</p>");
			textBox.addClass("error");
			return false;
		} else {
			validation.fadeOut("fast");
			textBox.removeClass("error");
			return true;
		} 
	}	
	//Do a JSON search based on URL recieved by history.js
	function doSearch (searchterms) {
		// eg !,search,GeneID,123p,10,0
		var dataStructure = {}
		if (searchterms[1] == "search"){
			dataStructure = {selector: searchterms[1], searchType: searchterms[2], query:searchterms[3] };
		} else if (searchterms[1] == "single"){ 
			dataStructure = {selector: searchterms[1], query:searchterms[2] };
		} else if (searchterms[1] == "browse") {
			var check = /([aA-zZ])/i;
			var browseletter = check.exec(searchterms[2]);
			dataStructure = {selector: searchterms[1], query:browseletter[1]};
		}
		var result = $.ajax ({
			url:"json.json",
			//url:"cgi-bin/json.pl?",
			type: "GET",
			dataType: "json",
			data: dataStructure,
			success: function (data) {
				if (searchterms[1] == "search") {
					outputSearchHTML(data);		
					loader.fadeOut("fast");
					overlay.fadeOut("fast");
				} else if (searchterms[1] == "single") {
					outputSingleHTML(data);		
					loader.fadeOut("fast");
					overlay.fadeOut("fast");
				} else if (searchterms[1] == "browse"){
					outputSearchHTML(data);
					loader.fadeOut("fast");
					overlay.fadeOut("fast");
				} else {
					console.log(searchterms[1]);
				}
			},
		
		});
	}
	//Output JSON to HTML
	function outputSearchHTML (data) {
		var counter = 0;
		content.html('<div class="center result-spacer"><h2>Results</h2></div>');
		content.append('<div class="titles" id="titles"><div class="title title-acc" id="namesort">Accession</div><div class="title title-product" id="productsort">Protein Product</div><div class="title title-diagram">Gene Layout</div><div class="title title-loc" id="lengthsort">Length</div><div class="title title-loc" id="locationsort">Location</div>');
		$.each(data, function(i,val) {
			var features = val["SeqFeat"];
			var name = i;
			content.append('\
				<div class="result" id="'+i+'">\
					<div class="result-div acc"><span id="acc"><a href="return_single.pl?gene='+val["GeneName"]+'">'+i+'</a></span></div> \
					<div class="result-div product"><span id="product">Protein Product</span></div> \
					<div class="result-div diagram" id="chart_div'+counter+'"></div> \
					<div class="result-div link"><span id="length">'+val["GeneLength"]+'</span></div> \
					<div class="result-div link"><span id="location">24.q13</span></div> \
				</div>');
			google.setOnLoadCallback(drawChart(features,counter, name));
			counter++;
		});
		$(".result").wrapAll('<div id="result-wrapper"/>');
	
	
	}
	//Outputs the Single page HTML
	function outputSingleHTML (data) {
		var counter = 0;
		//console.log(data);
		$.each(data, function (i,val) {
			var features = val["SeqFeat"];
			var name = i;
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
            	<a id="show1">Click to reveal DNA Sequence</a> \
            	<div id="SequenceDNA"> \
					<span></span> \
				</div> \
                <br /> \
                <a id="show2">Click to reveal Translated Amino Acid Sequence</a> \
                <div id="SequenceAA"> \
					<span></span> \
				</div> \
				<br /> \
				<a id="show3">Codon usage</a> \
				<div id="codonusage"> \
					<span></span> \
				</div> \
            </div> \
        </div> \
    </div>');
		google.setOnLoadCallback(drawChart(features,counter, name));
		});
	}

	//Google Charts API
	//Draw charts
	function drawChart (features, counter, name) {
		//Split up features array strings into separate arrays
		var feats = [name];
		var numbers = [name];
		$.each(features,function() {
			var f1 = this.split(";");
			feats.push(f1[0]);
			var difference = f1[1].split(":");
			var glength = Math.abs(parseInt(difference[0])-parseInt(difference[1]));
			//console.log(glength);
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
			legend: { position: 'none'},
			chartArea : {left:5, top: 5 ,'width':'80%', 'height':'90%'},
			width: 420,
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

	//Breadcrumbs function eg Home>>Search>>"query"
	function setBreadcrumbs (urlState) {
		// eg !,search,GeneID,123p,10,0
		var selector;
		var location;
		if (urlState) {
			if (urlState[1] == "search") {
				selector = "Search Result";
				location = urlState[3];
				breadcrumbs.html('<a href="" id="home">Home &raquo;</a> <span>'+selector+' &raquo;</span> <span>'+location+'</span>');
			} else if (urlState[1] == "single"){
				location = urlState[2];
				selector = "Single Result";
				breadcrumbs.html('<a href="" id="home">Home &raquo;</a> <span>'+selector+' &raquo;</span> <span>'+location+'</span>');
			} else if (urlState[1] == "browse") {
				location = urlState[2];
				selector = "Browsing";
				breadcrumbs.html('<a href="" id="home">Home &raquo;</a> <span>'+selector+' &raquo;</span> <span>'+location+'</span>');
			} else {
				breadcrumbs.html("");
			}
		} else {
			breadcrumbs.html("");
		}
	}

	//Sorts the results
	//Adapted from: http://stackoverflow.com/questions/7831712/jquery-sort-divs-by-innerhtml-of-children
	function sortIt(parent, childSelector, keySelector, mode, sortid, type) {
		var up = type + " &#9650;";
		var down = type + " &#9660;";
	   	if (sortid.hasClass("desc") || sortid.text() == type ) {
			//sort asc
			sortid.html(up).text();
			sortid.removeClass("desc");
			sortid.addClass("asc");
		} else if (sortid.hasClass("asc")) {
			//sort desc
			sortid.html(down).text();
			sortid.removeClass("asc");
			sortid.addClass("desc");
		}
	    var items = parent.children(childSelector).sort(function(a, b) {
	    if (keySelector == "span#length" || keySelector == "span#location") {
	    	var vA = parseInt($(keySelector, a).text());
        	var vB = parseInt($(keySelector, b).text());
	    } else {
        	var vA = $(keySelector, a).text();
        	var vB = $(keySelector, b).text();
    	}


    	if (mode == "desc"){
        	return (vA > vB) ? -1 : (vA < vB) ? 1 : 0;
    	} else if (mode == "asc") {
        	return (vA < vB) ? -1 : (vA > vB) ? 1 : 0;
    	}
    	});
   		parent.append(items);
	}
	function titleHandler (urlState){
		if (urlState) {
			if (urlState[1] == "single") {
				document.title = "12Chrom - viewing \""+urlState[2]+"\"";
			} else if (urlState[1] == "search") {
				document.title = "12Chrom - searching \""+urlState[2]+"\"";
			} else if (urlState[1] == "browse") {
				document.title ="12Chrom - Browsing \""+urlState[2]+"\"";
			} else {
				document.title ="12Chrom - Chromosome 12 Analysis Tool";
			}
		} else {
			document.title ="12Chrom - Chromosome 12 Analysis Tool";
		}

	}
	function resetIndex (urlState) {
		welcome.show();
		searchID.hide();
		browse.hide();
		closeHelp();
		showMain();
		hideContent();
		clearContent();
		setBreadcrumbs(urlState);
		titleHandler(urlState);
	}
	function searchHandler (urlState) {
		clearContent();
		doSearch(urlState);
		setBreadcrumbs(urlState);
		hideMain();
		closeHelp();
		showContent();
		ajaxLinks();
		titleHandler(urlState);
	}




	$('#namesort').live("click", function() {
		if ($(this).hasClass("desc") || $(this).text() == "Accession" ) {
			sortIt($('#result-wrapper'), "div", "span#acc", "asc", $("#namesort"), "Accession");
		} else {
			sortIt($('#result-wrapper'), "div", "span#acc", "desc", $("#namesort"), "Accession");
		}
	});
	$('#productsort').live("click", function() {
		if ($(this).hasClass("desc") || $(this).text() == "Accession" ) {
			sortIt($('#result-wrapper'), "div", "span#product", "asc", $("#productsort"), "Protein Product");
		} else {
			sortIt($('#result-wrapper'), "div", "span#product", "desc", $("#productsort"), "Protein Product");
		}
	});
	$('#lengthsort').live("click", function() {
		if ($(this).hasClass("desc") || $(this).text() == "Accession" ) {
			sortIt($('#result-wrapper'), "div", "span#length", "asc", $("#lengthsort"), "Length");
		} else {
			sortIt($('#result-wrapper'), "div", "span#length", "desc", $("#lengthsort"), "Length");
		}
	});
	$('#locationsort').live("click", function() {
		if ($(this).hasClass("desc") || $(this).text() == "Accession" ) {
			sortIt($('#result-wrapper'), "div", "span#location", "asc", $("#locationsort"), "Location");
		} else {
			sortIt($('#result-wrapper'), "div", "span#location", "desc", $("#locationsort"), "Location");
		}
	});



	//Visual
		//Toggles 
		$("#show1").live("click" , function() { 
			$("#SequenceDNA").slideToggle("fast");
		});
		$("#show2").live("click", function() { 
			$("#SequenceAA").slideToggle("fast");
		});
		$("#show3").live("click" ,function() { 
			$("#codonusage").slideToggle("fast");
		});
		$("#browsebox").live("click", function() {
			browse.show();
			welcome.hide();
		});
		$("#searchbox").live("click", function() {
			welcome.hide();
			searchID.show();
		});
		$("#home").live("click", function() {
			$.History.go("!/");
		});

		//Search Submitters
		$("#browsesubmit").live("click", function(event) {
			event.preventDefault();
			var selection = $('select[name="selection"]').val();
			$.History.go("!/browse/"+selection);
		});
		$("#searchsubmit").live("click", function(event){ 
			event.preventDefault();
			var radioVal = $("input[name=searchType]:checked", "#mainSearch").val();
			var query = textBox.val();
			$.History.go("!/search/"+radioVal+"/"+query)
		});
		$("#show4").live("click", function() { 
			$("#cutter").slideToggle("fast");
		});
		$("#closepopup").live("click", function() {
			closeHelp();
		});
		$("#overlay").live("click", function() {
			closeHelp();
		});
		$(window).resize(function() {  
			centerPopup();  
		}); 
		function moveTitle () {
			var offset = $(window).scrollTop()+103;
			if ($(window).scrollTop() > 10) 
				$("#titles").stop().animate({ top:"50px"},"fast");
			else 
				$("#titles").stop().animate({ top:offset},"fast");
		}
		$(window).scroll(moveTitle);
		moveTitle();
		ajaxLinks();
		$("#no-js-alert").hide();
	
		//jQueryUi
		$("#searchType").buttonset();
		$('input[type="submit"], input[type="reset"]').button();
	
	//jQuery plugin: History.js 
	//Looks at the url and does operations based on what it gets	
	$.History.bind(function(state) {
		urlState = state.split(/\//g);
	//	console.log(urlState);
	//	alert(state);
		switch (true) {
				case(urlState[1] == "help"):
					openHelp();
					centerPopup();
					break;
				case(urlState[1] == "search"):
					searchHandler(urlState);
					break;
				case(urlState[1] == "single"):
					searchHandler(urlState);
					break;
				case(urlState[1] == "browse"):
					searchHandler(urlState);
					break;
				default:
					if (urlState == undefined) {
						alert("Incorrect url.");
					}
					resetIndex(urlState);
					break;
			}
				
		});
		
});
