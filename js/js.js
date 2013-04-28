// 	JavaScript 
//Load in Google Graphs API
google.load("visualization", "1", {packages:["corechart"]});
$(document).ready(function() {
	// 
	//	Variables
	//
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
			validation   = $("#validation"),
			EnzC_CB 	 = $("#EnzCutter_cb"),
			defaultCuts  = "EcoRI,BsuMI,BamHI";
			;
	//
	//	Ajax
	//
		//Global ajax call setup
		$.ajaxSetup({
			beforeSend: function(xhr, status) {

			},
			success: function(xhr, status) {
				loader.fadeOut("fast");
				overlay.fadeOut("fast");
			},
			error: function(jqXHR, exception, m) {	
				if (exception === "timeout") {
					$("#timeout").slideDown("fast");
				} else {
					loader.fadeOut("fast");
					errorOut(jqXHR, "ajax", this.url,m);
					$("#timeout").slideUp("fast");
				}
			},
			cache:true,
			timeout:10000
		});
		//Search Ajax call
		function doSearch (searchterms) {
			// eg !,search,GeneID,123p,10,0
			var dataStructure = {}
			if (searchterms[1] == "search"){
				dataStructure = {selector: searchterms[1], searchType: searchterms[2], query:searchterms[3] };
			} else if (searchterms[1] == "single"){ 
				dataStructure = {selector: searchterms[1], query:searchterms[2] };
			} else if (searchterms[1] == "browse") {
				var check = /([aA-zZ1-9])/i;
				var browseletter = check.exec(searchterms[2]);
				dataStructure = {selector: searchterms[1], query:browseletter[1]};
			}
			var result = $.ajax ({
				//url:"json.json",
				url:"cgi-bin/json.pl?",
				type: "GET",
				dataType: "json",
				data: dataStructure,
				beforeSend: function() {			
					loader.fadeIn("fast");
					overlay.fadeIn("fast");},
				success: function (data) {
					if (data['error']){
						errorOut(data, searchterms[1],this.url);
					} else {
						if (searchterms[1] == "search") {
							outputSearchHTML(data);		
						} else if (searchterms[1] == "single") {
							outputSingleHTML(data);		
						} else if (searchterms[1] == "browse"){
							outputSearchHTML(data);
						} else {
							console.log(searchterms[1]);
						}
						overlay.fadeOut("fast");
					}
					loader.fadeOut("fast");
					
				},
			
			});
		}

		//JSON for EnzCutter
		function EnzCutter (submit, context) {
			if (submit[0] == "GetRES"){
				dataStructure = {selector: "res" , mode:"GetRES"};
			} else if (submit[0] == "CalcRES") {
				if (context == "single"){ 
					dataStructure = {selector: "res", mode:"CalcRES", gene:defaultCuts, query:submit[2]};
				} else {
					dataStructure = {selector: "res", mode:"CalcRES", gene:submit[1], query:submit[2]};
				}
			}
			var result = $.ajax ({
				url:"cgi-bin/json.pl",
				//url:"res.json",
				type:"POST",
				data: dataStructure,
				dataType:"json",
				beforeSend: function() {
					loader.fadeIn("fast");
				},
				success: function (data) {
					if (submit[0] == "GetRES"){
						populateEnzCutter(data);
					} else if (submit[0] == "CalcRES") {
						outputEnzCutter(data,context);
					}
					loader.fadeOut("fast");
					overlay.fadeOut("fast");
				}
			});
		}
		function outputEnzCutter (data, context){
			var outputDiv;
			if (context == "single") {
				outputDiv = $("#EnzCutter_Results_single");
			} else {
				outputDiv = $("#EnzCutter_Results");
				outputDiv.append('<div id="closepopup">Close?</div>');
				outputDiv.append('<h2 class="center" id="EnzCutter_results_h2">Results</h2>');
			}
			console.log
			
			$.each(data, function(i,val) {
					$.each(val, function (key,value){
						if (key == "error") {
							outputDiv.append('<h3 id="EnzCutter_results_h3>Error</h3><p>'+value+'</p>');
						} else {
							var count =1;
							outputDiv.append('<h3 id="EnzCutter_results_h3">'+key+'</h3>');
								$.each(value, function (cut, details){
									if (cut == "error") {
										outputDiv.append('<div id="EnzCutter_results_div"><h4>No Cuts</h4></div>');
									} else {
										var regex_enzcutter = /[\||,]/g;
										var seqfor = details["sequence-forward"];
										var seqrev = details["sequence-reverse"];
										var seqfor_split = seqfor.split(regex_enzcutter);
										var seqrev_split = seqrev.split(regex_enzcutter);
										var spaces = seqfor_split[2].length;

										var spaces_display = Array(spaces).join("&nbsp;");
										var seqfor_display = '<span class="red-b">'+seqfor_split[0]+'</span><span class="blue">'+seqfor_split[1]+'</span><span class="bold">'+spaces_display+'|</span><span class="blue">'+seqfor_split[2]+'</span><span class="red-b">'+seqfor_split[3]+'</span>';
										var seqrev_display = '<span class="red-b">'+seqrev_split[0]+'</span><span class="blue">'+seqrev_split[1]+'</span><span class="bold">|'+spaces_display+'</span><span class="blue">'+seqrev_split[2]+'</span><span class="red-b">'+seqrev_split[3]+'</span>';

										outputDiv.append('<div id="EnzCutter_results_div"><h4>Cut '+count+'</h4>\
											<div id="seq-for" class="sequence">5\''+seqfor_display+'3\'</div> \
											<div id="seq-rev" class="sequence">3\''+seqrev_display+'5\'</div> \
											<div id="seq-cut"><span>Cut used </span><span class="bold">'+details["cut"]+'</span></div> \
											<div id="seq-location"><span>Location </span><span class="bold">'+details["location"]+'</span></div> \
											</div>');
										count++;
									}
								});
						}
						
					});
			});
			if (context == "single"){ 
				$("#EnzCutter_Results_single").slideDown("fast");
				$("#EnzCutter_spinner").fadeOut("fast");
			} else {
				$("#EnzCutter_Results").slideDown("fast");
				$("#EnzCutter").slideUp("fast");
			};
			
		}
		//Load help
		function doHelp (page) {
			var result = $.ajax ({
				url:"cgi-bin/json.pl?selector=help",
				//url:"help.json",
				type:"GET",
				data: page[0],
				dataType:"json",
				beforeSend: function() {
					loader.fadeIn("fast");
				},
				success: function (data) {
					outputHelp(data);
					help.slideDown("fast");
					loader.fadeOut("fast");
					overlay.fadeOut("fast");
				}
			});
		}

	//
	//	Visual Functions
	//

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

		//Search Validation
		function validateSearch () {
			if (textBox.val().length < 3) {
				validation.fadeIn("fast");
				validation.html("<p>Query must be greater than 3 characters</p>");
				textBox.addClass("error");
				return 0;
			} else {
				validation.fadeOut("fast");
				textBox.removeClass("error");
				return 1;
			} 
		}
		//Set Breadcrumbs for current location
		function setBreadcrumbs (urlState) {
			// eg !,search,GeneID,123p,10,0
			var selector;
			var location;
			if (urlState) {
				if (urlState[1] == "search" && urlState[2].length >1 ) {
					selector = "Search Result";
					location = urlState[3];
					breadcrumbs.html('<a href="" id="home">Home &raquo;</a> <span>'+selector+' &raquo;</span> <span>'+location+'</span>');
				} else if (urlState[1] == "single"){
					location = urlState[2];
					selector = "Single Result";
					breadcrumbs.html('<a href="" id="home">Home &raquo;</a> <span>'+selector+' &raquo;</span> <span>'+location+'</span>');
				} else if (urlState[1] == "browse" && urlState[2].length>=1) {
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
		function sortIt(parent, childSelector, keySelector, mode, sortid) {
		   	if (sortid.hasClass("desc")) {
				//sort asc
				sortid.removeClass("desc");
				sortid.addClass("asc");
			} else if (sortid.hasClass("asc")) {
				//sort desc
				sortid.removeClass("asc");
				sortid.addClass("desc");
			} else {
				sortid.addClass("asc");
				sortid.removeClass("unsorted");
			}
		    var items = parent.children(childSelector).sort(function(a, b) {
		    if (keySelector == "span#length") {
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
		//Sort Logic


			$('#namesort, #productsort, #lengthsort, #locationsort').live("click", function() {
				var spans = { namesort:"span#acc", productsort:"span#product", lengthsort:"span#length", locationsort:"span#location"};
				var location = spans[$(this).attr("id")];
				if ($(this).hasClass("unsorted")) {
					sortIt($('#result-wrapper'), "div", location, "asc", $(this));
				} else if ($(this).hasClass("asc")) {
					sortIt($('#result-wrapper'), "div", location, "desc", $(this));
				} else if ($(this).hasClass("desc")) {
					sortIt($('#result-wrapper'), "div", location, "asc", $(this));
				}
			});

		//
		//Change the page title based on context
		function titleHandler (urlState){
			if (urlState) {
				if (urlState[1] == "single" && urlState[2] >= 1) {
					document.title = "12Chrom - viewing \""+urlState[2]+"\"";
				} else if (urlState[1] == "search" && urlState[2] >= 1) {
					document.title = "12Chrom - searching \""+urlState[2]+"\"";
				} else if (urlState[1] == "browse" && urlState[2] >= 1) {
					document.title ="12Chrom - Browsing \""+urlState[2]+"\"";
				} else {
					document.title ="12Chrom - Chromosome 12 Analysis Tool";
				}
			} else {
				document.title ="12Chrom - Chromosome 12 Analysis Tool";
			}

		}


	//
	//	Output HTML
	//
		//Output Search JSON to HTML
		function outputSearchHTML (data) {
			var counter = 0;
			content.html('<div class="titles-fixed" id="titles"><div class="title title-acc unsorted" id="namesort">Accession</div><div class="title title-product unsorted" id="productsort">Protein Product</div><div class="title title-diagram">Gene Layout</div><div class="title title-len unsorted" id="lengthsort">Length</div><div class="title title-loc unsorted" id="locationsort">Location</div>');
			$.each(data, function(i,val) {
				var features = val["SeqFeat"];
				var name = i;
				content.append('\
					<div class="result" id="'+i+'">\
						<div class="result-div acc"><span id="acc"><div class="red pointer underline" id="single_open"><a href="#!/single/'+i+'">'+i+'</a></div><span id="single_id">'+val["GeneName"]+'</span></div> \
						<div class="result-div product"><span id="product">'+val["ProteinName"]+'</span></div> \
						<div class="result-div diagram" id="chart_div'+counter+'"></div> \
						<div class="result-div link"><span id="length">'+val["GeneLength"]+'</span></div> \
						<div class="result-div link"><span id="location">'+val["ChromosomeLocation"]+'</span></div> \
					</div>');
				google.setOnLoadCallback(drawChart(features,counter, name, "search"));
				counter++;
			});
			content.prepend('<div class="center result-spacer"><h2>'+counter+' Results</h2></div>');
			$(".result").wrapAll('<div id="result-wrapper"/>');
		
		
		}
		//Outputs the Single page HTML
		function outputSingleHTML (data) {
			var counter = 0;
			var name;
			var codon;
			$.each(data, function (i,val) {
				var features = val["SeqFeat"];
				var pnamel = val["ProteinName"].length;
				var pname = val["ProteinName"];
				codon = val["CodonUsage"];
				name = i;
				if (pnamel < 1) {
					pname = "Unknown";
				}
				content.html(' \
	    <div class="searchform"> \
	    	<h2 class="center">Single result for: '+i+'.</h2> \
	        <div class="singleresult"> \
	        	<div class="info"> \
	            	<span>Length: </span><span class="bold">'+val["GeneLength"]+'</span><span> | Gene ID: </span><span class="bold">'+val["GeneName"]+'</span><span> | Genbank Accession: </span><span class="bold">'+i+'</span><span> | Protein ID: </span><span class="bold">'+val["ProteinId"]+'</span><span> | Chromosomal Location: </span><span class="bold">'+val["ChromosomeLocation"]+'</span> \
	            </div> \
	            <div class="single-wide"> \
	            	<h2>Protein Product</h2>\
	            	<p>'+pname+'</p>\
	            	<h2>Sequence Characteristics</h2> \
	            	<h3>Gene Layout</h3> \
	                <div class="diagram centerdiv" id="chart_div0"></div>\
	                <h3>Codon Usage</h3> \
					<div id="codon_img" class="center"> \
						<a href="cgi-bin/codon_img.pl?download=true&gene='+i+'" alt="Codon Usage"><img src="cgi-bin/codon_img.pl?show=true&gene='+i+'" alt="Codon Usage"/></a> \
					</div> \
	                <h2>Common Restriction Sites</h2> \
	                <div id="EnzCutter_spinner" class="center"><p class="bold center">Loading common restriction sites</p><img src="img/pacman.gif" class="center" alt="Loading" height="24" width="24" /> </div>\
	                <div id="EnzCutter_Results_single"></div> \
	                <h2>EnzCutter</h2> \
	                <div class="bold underline red pointer" id="EnzCutter_open">Would you like to cut your own?</div> \
	            </div> \
	            <div class="clearfix"></div> \
	            <div class="single-wide"> \
	            	<h2>Sequences</h2> \
	            	<div class="bold underline red pointer" id="show1">Click to reveal DNA Sequence</div> \
	            	<div id="SequenceDNA"> \
	            		<span id="DNASeq"></span> \
					</div> \
	                <br /> \
	                <div class="bold underline red pointer" id="show2">Click to reveal Translated Amino Acid Sequence</div> \
	                <div id="SequenceAA"> \
						<span id="AASeq"></span> \
					</div> \
					<br /> \
					<div class="bold underline red pointer" id="show3">Codon usage</div> \
					<div id="codonusage"> \
						<span id="CodonUsageSeq"></span> \
					</div> \
	            </div> \
	        </div> \
	    </div>');

		//Put in the sequences
			//Output DNA Sequence
			for (var j = 0; j < val["DNASeqFASTA"].length; j++){
				$("#DNASeq").append('<p class="sequence">'+val["DNASeqFASTA"][j]+'</p>');
			}
			//Output AA Sequence
			for (var k =0; k < val["AASeqFASTA"].length; k++){
				$("#AASeq").append('<p class="sequence">'+val["AASeqFASTA"][k]+'</p>');
			}
			//Output Codon Sequence
			$.each(codon, function (aa,val) {
				$("#CodonUsageSeq").append ('<div id="aaname" class="bold">'+aa+'</div>');
				$.each(val, function(triplet, usage){
					$("#CodonUsageSeq").append('<pre><span class="bold">'+triplet+': </span><span>'+usage+'</span></pre>');
				});
			});

			$("#EnzCutter_currentGene").html("<p class=\"bold\">"+i+"</p>");
			$("#EnzCutter_welcome").html("<p>Please choose enzymes to cleave with.</p>");
			$("textarea#EnzCutter_textarea").remove();
			EnzCutter(["CalcRES", "", i],"single");
			google.setOnLoadCallback(drawChart(features,counter, name, "single"));
			});
		}
		//Output help
		function outputHelp (data) {
			$.each(data, function (i,val) {
				return true;
			});
		}
		//Write RES to Enzcutter
		//Textex
		function populateEnzCutter (data){
			var counter = 0 ;
			var dataArray = [];
			$.each (data, function(i,val){
				dataArray.push(i);
				counter++;
			});
			$("#EnzCutter_number").html("<span>"+counter+" Enzymes avaliable</span>");
			$('#EnzCutter_autocomplete').textext({
	            plugins : 'autocomplete tags filter arrow'
	        })
	        .bind('getSuggestions', function(e, data){
	            var list = dataArray,
	                textext = $(e.target).textext()[0],
	                query = (data ? data.query : '') || ''
	                ;

	            $(this).trigger(
	                'setSuggestions',
	                { result : textext.itemManager().filter(list, query) }
	            );
	        });
		}

		//Print errors to div
		function errorOut (data, context, url, m){
			if (context == "search" || context == "browse" || context =="single"){
				$("div#errorbox.boxes>div#closepopup").hide();
				errordiv.html('<span class="bold">Error: </span>'+data['error']+'<br />Please <span class="bold underline red pointer" id="showSearch">try again.</span>');
			} else if (context =="ajax") {
				$("div#errorbox.boxes>div#closepopup").show();
				errordiv.html('<span class="bold">Ajax error: </span>'+data.status+'<br /><span class="bold">Error: </span>'+m+'<br /><span class="bold">URL: </span>'+url);
			}
			overlay.fadeIn("fast");
			error.fadeIn("fast");
		}
		
		
		//Google Charts API
		//Draw charts
		function drawChart (features, counter, name, context) {
			//Split up features array strings into separate arrays
			var feats = [name];
			var numbers = [name];
			$.each(features,function() {
				var f1 = this.split(";");
				feats.push(f1[0]);
				var difference = f1[1].split(":");
				var glength = Math.abs(parseInt(difference[0])-parseInt(difference[1]));
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
			
			var options;
			if (context == "single") {
				options = {
					isStacked: true,
					hAxis : {},
					legend: {},
					chartArea : {left:5, top: 5 ,'width':'80%', 'height':'80%'},
					width: 850,
					height: 100,
					colors: colours,
				};
			} else {
				options = {
					isStacked: true,
					hAxis : {},
					legend: { position: 'none'},
					chartArea : {left:5, top: 5 ,'width':'80%', 'height':'90%'},
					width: 420,
					height: 50,
					colors: colours,
				};
			}
		
			var data1 = google.visualization.arrayToDataTable([
				feats,
				numbers
			]);
			var chart = new google.visualization.BarChart(document.getElementById('chart_div'+counter));
			chart.draw(data1, options );	
		}




	//
	//	Reset Functions
	//	
		//Resets the page	
		function resetIndex (urlState) {
			welcome.show();
			searchID.hide();
			browse.hide();
			showMain();
			hideContent();
			clearContent();
			setBreadcrumbs(urlState);
			titleHandler(urlState);
			replaceTextbox();
			$("#EnzCutter").slideUp("fast");
			$("#EnzCutter_Results").slideUp("fast");
			help.slideUp("fast");
			overlay.fadeOut("fast");
			error.fadeOut("fast");

		}
		//Handles search calls
		function searchHandler (urlState) {
			clearContent();
			doSearch(urlState);
			setBreadcrumbs(urlState);
			hideMain();
			help.slideUp("fast");
			showContent();
			titleHandler(urlState);
		}
		//Replaces textarea in enzcutter
		function replaceTextbox () {
			$("#EnzCutter_autocompleteWrapper").html('<textarea type="text" name="query" id="EnzCutter_textarea" autofocus="autofocus" cols="40" rows="4" style="width:400px"></textarea>');
			$("#EnzCutter_currentGene").html("");
		}	




	//
	//	Welcome / Search
	//
		//Shows the Browse form 
		$("#browsebox").live("click", function() {
			$.History.go("!/browse/");
		});
		//Show the search form
		$("#searchbox, #showSearch").live("click", function() {
			$.History.go("!/search/");
		});
		//Browse Submit
		$("#browsesubmit").live("click", function(event) {
			event.preventDefault();
			var selection = $('select[name="selection"]').val();
			$.History.go("!/browse/"+selection);
		});
		//Search Submit
		$("#searchsubmit").live("click", function(event){ 
			event.preventDefault();
			var validate = validateSearch();
			var radioVal = $("input[name=searchType]:checked", "#mainSearch").val();
			var query = textBox.val();
			if (validate == 1) {
				$.History.go("!/search/"+radioVal+"/"+query);
			} 
		});
	//
	//	Single
	//
		//Shows Sequence DNA on Single
		$("#show1").live("click" , function() { 
			$("#SequenceDNA").slideToggle("fast");
		});
		//SHows Sequence AA on single
		$("#show2").live("click", function() { 
			$("#SequenceAA").slideToggle("fast");
		});
		//Shows Codon Usage on single
		$("#show3").live("click" ,function() { 
			$("#codonusage").slideToggle("fast");
		});
	//
	//	Navbar
	//
		//Set home
		$("#home").live("click", function(event) {
			event.preventDefault();
			$.History.go("!/");
		});
		//Open EnzCutter
		$("#EnzCutter_open , #EnzCutter_frontbox").live("click", function(event){
			event.preventDefault();	
			$("#EnzCutter").slideToggle("fast");
		});
		//Help
		$("#help_open, #helpbox").live("click", function(event){
			event.preventDefault();
			doHelp("test");
		});
		//Contact
		$("#contact_open").live("click", function(event) {
			event.preventDefault();
			$("#contact").slideToggle("fast");
		});

	//
	//	Boxes
	//
		$("#closepopup").live("click", function() {
			$(this).parent().slideUp();
			overlay.fadeOut("fast");
		});

	//
	//	EnzCutter
	//

		$("#EnzCutter_submit").live("click", function(event) {
			event.preventDefault();
			var sequence = $("textarea#EnzCutter_textarea").val();
			var enzymes = $("input[name=autocomplete]").val();
			var regex = /\w+/g;
			enzymes = enzymes.match(regex);
			enzymes = enzymes.join(',');
			if (sequence === undefined) {
				sequence = $("#EnzCutter_currentGene").text();
			}
			if (enzymes) {
				if (sequence.length < 5) {
					$("#EnzCutter_number").html('<span class="red">Sequence must be longer than 10 characters.</span>');
				} else {
					$("#EnzCutter_Results").html('');
					EnzCutter(["CalcRES", enzymes, sequence]);
				}
			} else { 
				$("#EnzCutter_number").html('<span class="red">Please choose an enzyme.</span>');
			}
		});

	//
	//	Window functions
	//
		//Centre a popup on resize
		$(window).resize(function() {  
			centerPopup();  
		}); 
		//Move the headers down with the page
		function moveTitle () {
			var offset = $(window).scrollTop()+110;
			if ($(window).scrollTop() > 2) {
				$("#titles").stop().animate({ top:"50px"},"fast");
			} else {
				$("#titles").stop().animate({ top:offset},"fast");
			}
		}
		$(window).scroll(moveTitle);
	//
	//	Initialising functions/page
	//
		//Window functions
		moveTitle();
		//Touch Enzcutter to load RES
		EnzCutter(["GetRES"]);
		//Hide JS Alert for good users
		$("#no-js-alert").slideUp("fast");
	
		//jQueryUi
		$("#searchType").buttonset();
		$('input[type="submit"], input[type="reset"]').button();
	
	//jQuery plugin: History.js 
	//Looks at the url and does operations based on what it gets	
	$.History.bind(function(state) {
		urlState = state.split(/\//g);
		switch (true) {
				case(urlState[1] == "help"):
					//Need to work something out for this
					break;
				case(urlState[1] == "search"):
					if (urlState[2].length > 1){
						searchHandler(urlState);
					} else {
						resetIndex(urlState);
						welcome.hide();
						searchID.show();
					}
					break;
				case(urlState[1] == "single"):
					searchHandler(urlState);
					break;
				case(urlState[1] == "browse"):
					if (urlState[2].length >= 1){
						searchHandler(urlState);
					} else {
						resetIndex(urlState);
						browse.show();
						welcome.hide();
					}
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
//A Secret
var kkeys = [], secret = "38,38,40,40,37,39,37,39,66,65";
$(document).keydown(function(e) {
  kkeys.push( e.keyCode );
  if ( kkeys.toString().indexOf( secret ) >= 0 ) {
    $(document).unbind('keydown',arguments.callee);
        $("#seq-for, #seq-rev").prepend('<div class="pacman" style="position:relative; top:-5px; left:0px; height:0px; width:0px;"><img width="24" height="24" src="img/pacman.gif" /></div>');
       	$(".pacman").animate({"left":"2000px"}, {duration:10000,queue: false});
       	$("#EnzCutter_open").append('<div style="position:relative; top:4px; opacity:1; height:0;"><img width="24" height="24" src="img/pacman.gif" /></div>');
       	$("div#EnzCutter_frontbox>span.boxspan").remove();
       	$("#EnzCutter_fronttext").html('<div style="height:0;"><img width="50" height="50" src="img/pacman.gif" /></div>')
       	$("#seq-for, #seq-rev").animate({"left":"-400px"},{duration:4000, queue:false});

  }
});