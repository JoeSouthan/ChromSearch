// 
//
//  Title:          12Chrom Javascript Controller 
//  Description:    Operates on the Model-Viewer-Controller theory of Web programs
//                  Uses the jQuery Library and the History jQuery plugin
//                  Interacts with the JSON API, cgi-bin/json.pl via AJAX
//                  Uses the Google Charts API for data visualisation
//  Created by:     Joseph Southan
//  Email:          joseph@southanuk.co.uk
//  Date:           27/01/2013
//  Updated:        3/5/2013
//

//Load in Google Graphs API
google.load("visualization", "1", {packages:["corechart"]});
//When the DOM is ready
$(document).ready(function() {
    ////////////////////////////////
    //                            //
    // Variables                  //
    //                            //
    /////////////////////////////////////////////////////////////////
        var textBox      = $("#searchquery"),
            main         = $("#main"),
            mainWrapper  = $("#main_wrapper"),
            content      = $("#content"),
            overlay      = $("#overlay"),
            loader       = $("#loader"),
            radioName    = $("input[name=searchType]:radio"),
            radioValue   = $("input[name=searchType]:checked", "#mainSearch").val(),
            perpage      = $("#perpage").val(),
            error        = $("#errorbox"),
            errordiv     = $("#errordiv"),
            breadcrumbs  = $("#breadcrumbs-wrapper"),
            titles       = $("#titles"),
            ColNCS       = "#5C6E7C",
            ColEXON      = "#AAC1D2",
            ColINTRON    = "#A65534",
            browse       = $("#browse"),
            browseb      = $("#browsebox"),
            searchID     = $("#searchform"),
            searchbox    = $("#searchbox"),
            welcome      = $("#welcome"),
            validation   = $("#validation"),
            EnzC_CB      = $("#EnzCutter_cb"),
            Boxes        = $(".boxes"),
            defaultCuts  = "EcoRI,BsuMI,BamHI";
            ;
    /////////////////////////////////////////////////////////////////

    ////////////////////////////////
    //                            //
    // History.js                 //
    //                            //
    /////////////////////////////////////////////////////////////////
    //History.js
        //jQuery plugin: History.js 
        //Looks at the url and does operations based on what it gets    
    $.History.bind(function(state) {
        urlState = state.split(/\//g);
        switch (true) {
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
    /////////////////////////////////////////////////////////////////

    ////////////////////////////////
    //                            //
    // AJAX                       //
    //                            //
    /////////////////////////////////////////////////////////////////
    
    //
    //  AJAX setup
    //
        //Global ajax call setup
        //Defines how AJAX calls work
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
                    $("html, body").animate({ scrollTop: 0 }, "fast");
                    overlay.fadeIn("slow");
                } else {
                    loader.fadeOut("fast");
                    errorOut(jqXHR, "ajax", this.url,m);
                    $("#timeout").slideUp("fast");
                }
            },
            cache:true,
            timeout:10000
        });
        //Function: doSearch
            //Main search Function
            //Takes searchterms from the History plugin and breaks the string down to search
                //searchterms eg: !/search/[search type]/[query]
            //Outputs results and handles errors
        function doSearch (searchterms) {
            var dataStructure = {};
            //Defines how the search will be carried out
            if (searchterms[1] == "search"){
                dataStructure = {selector: searchterms[1], searchType: searchterms[2], query:searchterms[3] };
            } else if (searchterms[1] == "single"){ 
                dataStructure = {selector: searchterms[1], query:searchterms[2] };
            } else if (searchterms[1] == "browse") {
                var check = /([aA-zZ1-9])/i;
                var browseletter = check.exec(searchterms[2]);
                dataStructure = {selector: searchterms[1], query:browseletter[1]};
            }
            //Do the AJAX call
            var result = $.ajax ({
                url:"cgi-bin/json.pl?",
                type: "GET",
                dataType: "json",
                data: dataStructure,
                beforeSend: function() {            
                    loader.fadeIn("fast");
                    overlay.fadeIn("fast");
                },
                success: function (data) {
                    //Pass errors to 
                    if (data['error']){
                        errorOut(data, searchterms[1],this.url);
                    } else {
                        //Search is good, send results to appropriate function
                        if (searchterms[1] == "search") {
                            outputSearchHTML(data);     
                        } else if (searchterms[1] == "single") {
                            outputSingleHTML(data);     
                        } else if (searchterms[1] == "browse"){
                            outputSearchHTML(data);
                        } else {
                            //Just incase
                            console.log(searchterms[1]);
                        }
                        overlay.fadeOut("fast");
                    }
                    loader.fadeOut("fast");
                },
            });
        }
        //Function: EnzCutter
            //JSON AJAX function for EnzCutter
            //Takes (submit,context)
                //submit = ["GetRES/CalcRES", Enzymes (a comma separated string), Query string/Sequence]
                //context = Takes "single" for a single page othewise will wait for a sequence to be entered
            //GetRES returns list of restriction enzymes
        function EnzCutter (submit, context) {
            if (submit[0] == "GetRES"){
                dataStructure = {selector: "res" , mode:"GetRES"};
            } else if (submit[0] == "CalcRES") {
                if (context == "single"){ 
                    //defaultcuts will cut the sequence with the cuts required
                    dataStructure = {selector: "res", mode:"CalcRES", gene:defaultCuts, query:submit[2]};
                } else {
                    dataStructure = {selector: "res", mode:"CalcRES", gene:submit[1], query:submit[2]};
                }
            }
            //Does the search
            var result = $.ajax ({
                url:"cgi-bin/json.pl",
                type:"POST",
                data: dataStructure,
                dataType:"json",
                beforeSend: function() {
                    loader.fadeIn("fast");
                },
                success: function (data) {
                    //Output the results
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
    /////////////////////////////////////////////////////////////////

    ////////////////////////////////
    //                            //
    // Visual                     //
    //                            //
    /////////////////////////////////////////////////////////////////

        //Function: centerPopup
            //Function to centre a popup
            //Adapted from http://www.joelpeterson.com/blog/2010/12/quick-and-easy-windowless-popup-overlay-in-jquery/
        function centerPopup(){  
            var winw = $(window).width();  
            var popw = Boxes.width();  
            Boxes.css({  
                "position" : "absolute",  
                "left" : winw/2-popw/2  
            }); 
        }
        //Function validateSearch
            //Search Validation, ensures search is greater than 3 characters
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
        //Function: setBreadcrumbs
            //Set Breadcrumbs for current location
            //Takes urlState from the searchHandler
        function setBreadcrumbs (urlState) {
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
        //Function: sortIt
        //Takes parent, childSelector, keySelector, mode, sortid. Will sort asc by default
            //parent = Div containing the results
            //childSelector = Div to sort by
            //keySelector = span title
            //mode = sort asc/desc
            //sortid = current class on span
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

        //Function: titleHandler 
            //Takes urlState from searchHandler
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
    /////////////////////////////////////////////////////////////////

    ////////////////////////////////
    //                            //
    // HTML Output                //
    //                            //
    /////////////////////////////////////////////////////////////////
        //Function: outputSearchHTML
            //Takes data from doSearch
            //Output Search JSON to HTML
        function outputSearchHTML (data) {
            var counter = 0;
            content.html('<div class="titles-fixed" id="titles"><div class="title title-acc unsorted" id="namesort">Accession</div><div class="title title-product unsorted" id="productsort">Protein Product</div><div class="title title-diagram">Gene Layout</div><div class="title title-len unsorted" id="lengthsort">Length</div><div class="title title-loc unsorted" id="locationsort">Location</div></div>');
            //Go through each result returned
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
                //Draw the layout graph
                google.setOnLoadCallback(drawChart(features,counter, name, "search"));
                counter++;
            });
            content.prepend('<div class="center result-spacer"><h2>'+counter+' Results</h2></div>');
            $(".result").wrapAll('<div id="result-wrapper"/>');
            $("#help_open").attr("href", "help/#help_search");
            $('#help_open').parent('div').animate({opacity: 1}, 500).delay(1000).animate({opacity:0.4},2000);
        }
        //Function: outputSingleHTML
            //Takes data from doSearch
            //Outputs the Single page HTML
        function outputSingleHTML (data) {
            var counter = 0;
            var name;
            var codon;
            var features;
            var feat_seq;
            $.each(data, function (i,val) {
                features = val["SeqFeat"];
                var pnamel = val["ProteinName"].length;
                var pname = val["ProteinName"];
                feat_seq = val["FeatureSequences"];
                codon = val["CodonUsage"];
                name = i;
                if (pnamel < 1) {
                    pname = "Unknown";
                }
                content.html(' \
                <div class="searchform"> \
                    <h2 class="center">Single result for: '+i+'.</h2> \
                    <div class="singleresult"> \
                        <div class="single-left"> \
                            <ul> \
                                <li>Length: <span class="bold">'+val["GeneLength"]+'</span></li> \
                                <li>GenInfo ID: <a href="http://www.ncbi.nlm.nih.gov/nuccore/'+val["GeneName"]+'" target="_blank" title="NCBI">'+val["GeneName"]+'</a></li> \
                                <li>Genbank Accession: <a href="http://www.ncbi.nlm.nih.gov/nuccore/'+i+'" target="_blank" title="NCBI">'+i+'</a></li> \
                            </ul> \
                            </div> \
                            <div class="single-left"> \
                            <ul> \
                                <li>Protein ID: <a href="http://www.uniprot.org/uniprot/?query='+val["ProteinId"]+'&sort=score" target="_blank" title="UniProt">'+val["ProteinId"]+'</a></li> \
                                <li>Chromosomal Location: <span class="bold">'+val["ChromosomeLocation"]+'</span></li> \
                            </ul> \
                            </div> \
                        <div class="single-wide"> \
                            <h2>Protein Product</h2>\
                            <p>'+pname+'</p> \
                            <h2>Sequence Characteristics</h2> \
                            <h3>Gene Layout</h3> \
                            <div class="diagram centerdiv" id="chart_div0"></div> \
                            <h3>Sequence Features</h3> \
                            <div class="seq-feats" id="seq-feats-span"> \
                            </div> \
                            <div class="seq-feats-show" id="seq-feats-show">Click to show sequence features.</div> \
                            <h3>Codon Usage</h3> \
                            <div id="codon_img" class="center"> \
                                <a href="cgi-bin/codon_img.pl?download=true&gene='+i+'" alt="Codon Usage"><img src="cgi-bin/codon_img.pl?show=true&gene='+i+'" alt="Codon Usage" width="500" height="324" /></a> \
                            </div> \
                            <div id= "pie_div" class="center" style="left:18%;"></div> \
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
            var pie_data = [["Triplets","Usage"]];
            $.each(codon, function (aa,val) {
                $("#CodonUsageSeq").append ('<div id="aaname" class="bold">'+aa+'</div>');
                $.each(val, function(triplet, usage){
                    $("#CodonUsageSeq").append('<pre><span class="bold">'+triplet+': </span><span>'+usage+'</span></pre>');
                    pie_data.push([triplet, parseFloat(usage[0])]);
                });
            });
            //Output sequence features as text
            for (var l = 0; l< feat_seq.length; l++) {
                var seq_local_regex = (/\|/g);
                var seq_local = feat_seq[l].split(seq_local_regex);
                $("#seq-feats-span").append('<span class="seq-'+seq_local[0]+'"><a title="'+seq_local[0]+'">'+seq_local[1]+'</a></span>');
            };
            //Change EnzCutter to single mode
            $("#EnzCutter_currentGene").html("<p class=\"bold\">"+i+"</p>");
            $("#EnzCutter_welcome").html("<p>Please choose enzymes to cleave with.</p>");
            $("textarea#EnzCutter_textarea").remove();
            EnzCutter(["CalcRES", "", i],"single");
            $("#help_open").attr("href", "help/#help_single");
            $('#help_open').parent('div').animate({opacity: 1}, 500).delay(1000).animate({opacity:0.4},2000);
            //Draw charts
            google.setOnLoadCallback(drawChart(features,counter, name, "single"));
            google.setOnLoadCallback(drawPieChart(pie_data));
            });
        }
        //Function: outputEnzCutter
            //Handles the output of EnzCutter 
            //Takes (data,context)
                //data = JSON data returned
                //context = Set by the searchHandler, single will output on the single page
        function outputEnzCutter (data, context){
            var outputDiv;
            //Change the div for the context
            if (context == "single") {
                outputDiv = $("#EnzCutter_Results_single");
            } else {
                outputDiv = $("#EnzCutter_Results");
                outputDiv.append('<div class="closepopup">Close?</div>');
                outputDiv.append('<h2 class="center" id="EnzCutter_results_h2">Results</h2>');
            }
            //Run through each cut returned and display the results appropriately   
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
                                        //Cut the results so spans can be applied
                                        var regex_enzcutter = /[\||,]/g;
                                        var seqfor = details["sequence-forward"];
                                        var seqrev = details["sequence-reverse"];
                                        var seqfor_split = seqfor.split(regex_enzcutter);
                                        var seqrev_split = seqrev.split(regex_enzcutter);
                                        var spaces = seqfor_split[2].length;

                                        var spaces_display = Array(spaces).join("&nbsp;");
                                        var seqfor_display = '<span class="red-b">'+seqfor_split[0]+'</span><span class="blue blue-b">'+seqfor_split[1]+'</span><span class="bold">'+spaces_display+'|</span><span class="blue blue-b">'+seqfor_split[2]+'</span><span class="red-b">'+seqfor_split[3]+'</span>';
                                        var seqrev_display = '<span class="red-b">'+seqrev_split[0]+'</span><span class="blue blue-b">'+seqrev_split[1]+'</span><span class="bold">|'+spaces_display+'</span><span class="blue blue-b">'+seqrev_split[2]+'</span><span class="red-b">'+seqrev_split[3]+'</span>';

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
        //Function: populateEnzCutter
            //Takes JSON data from search
            //Ouputs the avaliavle restriction enzymes to the EnzCutter box
            //Uses Textex to provide suggestions
        function populateEnzCutter (data){
            var counter = 0 ;
            var dataArray = [];
            $.each (data, function(i,val){
                dataArray.push(i);
                counter++;
            });
            $("#EnzCutter_number").html("<span>"+counter+" Enzymes avaliable</span>");
            //This section is mostly based off example code from the plugin
            $('#EnzCutter_autocomplete').textext({
                plugins : 'tags prompt focus autocomplete arrow',
                prompt: "Type a letter..."
            })
            .bind('getSuggestions', function(e, data){
                var list = dataArray,
                    textext = $(e.target).textext()[0],
                    query = (data ? data.query : '') || '';
                $(this).trigger(
                    'setSuggestions',
                    { result : textext.itemManager().filter(list, query) }
                );
            });
        }
        //Function: errorOut
            //Takes data, context, url, (m)
            //Print errors to div
            //data = JSON data
            //context = context where the error occoured
            //url = json.pl url where error occoured
            //m = type of error
        function errorOut (data, context, url, m){
            if (context == "search" || context == "browse" || context =="single"){
                $("div#errorbox.boxes>div.closepopup").hide();
                errordiv.html('<span class="bold">Error: </span>'+data['error']+'<br />Please <span class="bold underline red pointer" id="showSearch">try again.</span>');
            } else if (context =="ajax") {
                $("div#errorbox.boxes>div.closepopup").show();
                errordiv.html('<span class="bold">Ajax error: </span>'+data.status+'<br /><span class="bold">Error: </span>'+m+'<br /><span class="bold">URL: </span>'+url);
            }
            overlay.fadeIn("fast");
            error.fadeIn("fast");
        }
        
        //Function: drawChart
            //Google Charts API
            //Draws layout charts
            //Takes features, counter, name, context
            //features = JSON value containing the sequence features
            //counter = Current div number
            //name = Name of the gene
            //context = Where the chart appears, affects the size and positioning
        function drawChart (features, counter, name, context) {
            //Split up features array strings into separate arrays
            if (features[0] === null){ 
                return;
            } else {
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
                    options = { isStacked: true, hAxis : {}, legend: {}, chartArea : {left:5, top: 5 ,'width':'80%', 'height':'80%'}, width: 850, height: 100, colors: colours};
                } else {
                    options = { isStacked: true, hAxis : {}, legend: { position: 'none'}, chartArea : {left:5, top: 5 ,'width':'80%', 'height':'90%'}, width: 420, height: 50, colors: colours};
                }
                var data1 = google.visualization.arrayToDataTable([feats,numbers]);
                var chart = new google.visualization.BarChart(document.getElementById('chart_div'+counter));
                chart.draw(data1, options );
            }   
        }
        //Function: drawPieChart
            //Takes data from outputSingleHTML
            //Draws a pie chart of codon usage
        function drawPieChart (data) {
            var wrapper = new google.visualization.ChartWrapper({
                chartType: 'PieChart',
                dataTable:  data,
                options: {'title': 'Codon Usage \(triplets\)',chartArea : {'width':'80%', 'height':'80%'}, width:700, height:600},
                containerId: 'pie_div'
            });
            wrapper.draw();
        }
    /////////////////////////////////////////////////////////////////

    ////////////////////////////////
    //                            //
    // Reset                      //
    //                            //
    /////////////////////////////////////////////////////////////////
        //Function: resetIndex
            //Takes urlState from History.js
            //Resets the page   
        function resetIndex (urlState) {
            //Show
            main.show();
            welcome.show();
            //Hide
            searchID.hide();
            browse.hide();
            content.hide();
            Boxes.slideUp("fast");
            overlay.fadeOut("fast");
            error.fadeOut("fast");
            //Blank out the Content ID and replace the textbox in EnzCutter
            content.html("");
            replaceTextbox();
            //Change the help link
            $("#help_open").attr("href", "help/#help_main");
            //Functions
            setBreadcrumbs(urlState);
            titleHandler(urlState);
        }
        //Function: searchHandler
            //Takes urlState from History.js
            //Handles search calls
        function searchHandler (urlState) {
            content.html("");
            doSearch(urlState);
            setBreadcrumbs(urlState);
            main.hide();
            Boxes.slideUp("fast");
            content.show();
            titleHandler(urlState);
        }
        //Function: replaceTextbox
            //Replaces textarea in enzcutter if the user had already visited a single page
        function replaceTextbox () {
            $("#EnzCutter_autocompleteWrapper").html('<textarea type="text" name="query" id="EnzCutter_textarea" autofocus="autofocus" cols="40" rows="4" style="width:400px"></textarea>');
            $("#EnzCutter_currentGene").html("");
        }
    /////////////////////////////////////////////////////////////////

    ////////////////////////////////
    //                            //
    // Clicky bits                //
    //                            //
    /////////////////////////////////////////////////////////////////

    //
    //  Welcome / Search
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
    //  Single
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
        $("#seq-feats-show").live("click", function() {
            $("#seq-feats-span").css({"height":"auto", "overflow":"auto"});
            $("#seq-feats-show").fadeOut("slow");
        });
    //
    //  Navbar
    //
        //Set home
        $(".home").live("click", function(event) {
            event.preventDefault();
            $.History.go("!/");
        });
        //Open EnzCutter
        $("#EnzCutter_open , #EnzCutter_frontbox").live("click", function(event){
            event.preventDefault(); 
            $("#EnzCutter").slideToggle("fast");
        });
        //Contact
        $("#contact_open").live("click", function(event) {
            event.preventDefault();
            $("#contact").slideToggle("fast");
        });

    //
    //  Boxes
    //
        $(".closepopup").live("click", function() {
            $(this).parent().slideUp();
            overlay.fadeOut("fast");
        });

    //
    //  EnzCutter
    //

        $("#EnzCutter_submit").live("click", function(event) {
            event.preventDefault();
            var sequence = $("textarea#EnzCutter_textarea").val();
            var enzymes = $("input[name=autocomplete]").val();
            var regex = /"(.+)"/g;
            enzymes = enzymes.match(regex);
            enzymes = enzymes.join(',');
            enzymes = enzymes.replace(/"/g, '');
            if (sequence === undefined) {
                sequence = $("#EnzCutter_currentGene").text();
            }
            if (enzymes) {
                if (sequence.length < 5) {
                    $("#EnzCutter_number").html('<span class="red">Sequence must be longer than 10 characters.</span>');
                } else {
                    $("#EnzCutter_Results").html('');
                    EnzCutter(["CalcRES", enzymes, sequence]);
                    $("#help_open").attr("href", "help/#help_enzcutter");
                    $('#help_open').parent('div').animate({opacity: 1}, 500).delay(1000).animate({opacity:0.4},2000);

                }
            } else { 
                $("#EnzCutter_number").html('<span class="red">Please choose an enzyme or enter your own: A|TTTT (5\').</span>');
            }       
        });

    //
    //  Window functions
    //
        //Centre a popup on resize
        $(window).resize(function() {  
            centerPopup();  
        }); 
        centerPopup();
        //Function: moveTitle
            //Moves the headers for the search results down with the page
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
    //  Initialising functions/page
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
        $( document ).tooltip({track: true});
    /////////////////////////////////////////////////////////////////////////
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