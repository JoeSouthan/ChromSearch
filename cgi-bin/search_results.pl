#! /usr/bin/perl -w
use strict;
use SOAP::Lite;
use CGI;
use Time::HiRes qw ( time );
use Data::Dumper;
my $timestart = time();
my $cgi = new CGI;
my @params= $cgi->param();
my $soap = SOAP::Lite->uri('ChromoDB')->proxy('http://joes-pi.dyndns.org/cgi-bin/proxy.pl');


#Do search, Take post
#Declaring variables for search
my ($query, $type, @queryFault, $fault);


#Take the Params from the POST
foreach my $params (@params) {
	if ($params eq "query") {
		$query = $cgi->param($params);
	} elsif ($params eq "searchType") {
		$type = $cgi->param($params);
	}
}

#Do Results				
#Subroutine to call from the package
#Debug
$query = "TEST1234";
$type = "GeneID";
my $returnSearch = $soap->getSearchResults($query,$type)->result;

#Parse the result to array
my %results;
my @resultArray = split ( ',', $returnSearch);
my @sequences;

#Debug
@sequences = qw ( NCS:ATGCCCCCATATATATATACCCCATATA CODON:ATATATATATATATATATTAT INTRON:CCCCAAATTTATTTATTAT CODON:ATATATATATATATATATTAT INTRON:CCCCAAATTTATTTATTAT);
@resultArray = qw (Test test test test);

#Build the result hash
for (my $i=0; $i<@resultArray; $i++){
	#get the sequence
	#my @sequenceFetch = $soap->showCodingSequence($resultArray[$i])->result;
	#Debug
	$results{$resultArray[$i]} = [@sequences];
}

#Reference
my $resultRef = \@resultArray;


#Time to check
#Did they enter a query or type?
unless (defined ($query)) {
	push (@queryFault, "No Query entered");
}
unless (defined($type)) {
	push (@queryFault,"No Type selected");
	
}

#Get the errors for the search back
unless (@queryFault){
	if ($returnSearch =~ /^ERROR:(.*)/) {
		$fault = $1;
	}
}


#Stop that clock
my $timestop = time();
my $gentime = $timestop - $timestart;


#Do HTML output
my $faultRef;
if (@queryFault){
	$faultRef = \@queryFault;
	htmlError($faultRef);
} elsif ($fault) {
	htmlError($fault);
} else {
	htmlOut ($resultRef, $cgi, $query, $gentime);

}		


# =============================
#
#	
#	Subroutines
#
#
# =============================

#Header for the page
sub htmlHeader {
print $_[0]->header();
print <<__EOF;
<!DOCTYPE HTML>
<html>
<head>
	<meta charset="utf-8">
	<title>Results - Chromosome 12 Search Engine (Name subject to change - any ideas?)</title>
	<link href="../css/style.css" rel="stylesheet" type="text/css">
__EOF
	if (defined ($_[1])) {
		genChartJS($_[1]);
	}
print <<__JSOUTPUT;
</head>

<body>
	<div class="wrapper">
		<div class="header">
			<h1>Results</h1>
		</div>
		<div class="searchform">
__JSOUTPUT
}
sub htmlFooter {
print <<__EOF3;
   
        <div class="footer">
        	<p>Results generated in $_[0] second(s).</p>
        </div>
    </div>

</div>
</body>
</html>
__EOF3
}
sub genChartJS {
	
my @results = @{$_[0]};
print <<__JS1;
	<script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
    function drawChart() {
       var options = {
          isStacked: true,
          hAxis : {},
          legend: {},
          chartArea : {left:5, top: 5 ,'width':'80%', 'height':'90%'},
          width: 650,
          height: 50
        };
__JS1
	for (my $i=0; $i<@results; $i++) {
		print <<__JS2
		var data$i = google.visualization.arrayToDataTable([
          ['Gene', 'NCR', 'Intron', 'Exon'],
          ['Gene',  1000,      400, 500]
        ]);
		var chart$i = new google.visualization.BarChart(document.getElementById('chart_div$i'));
        chart$i.draw(data$i, options);
__JS2
		
	}
	print <<__JS3;
		}
		google.setOnLoadCallback(drawChart);
		google.load("visualization", "1", {packages:["corechart"]});

	</script>
__JS3
}

#Main Output
sub htmlOut {

#Gotta Catch 'em all
my ($resultArrayRef, $cgi, $query, $gentime) = @_;
my @resultArray = @{$resultArrayRef};

#Print HTML
	htmlHeader($cgi,$resultArrayRef);
	
print "<h2 class=\"center\">Results for: <i>$query</i>.</h2>";
#Loop it!
for (my $i = 0; $i<@resultArray; $i++){
print <<__EOF2;
	<div class="result">
        	<div class="genename">$resultArray[$i]</div>
            <div class="diagram" id="chart_div$i">
            </div>
            <div class="link"><a href="return_single.pl?gene=$resultArray[$i]">More &raquo;</a></div>
    </div>
__EOF2
}
	htmlFooter($gentime);
}

#
#
#
#	HTML Errors
#
#
#

#General Error
sub htmlError {
	my @faultSub;
	if (ref($_[0]) eq "ARRAY") {
		@faultSub = @{$_[0]};
	} else {
		 @faultSub = prettyErrors($_[0]);
	}
	#Print the Header
	htmlHeader($cgi);
print <<__WHOOPS;
	<div>
		<h2 class="center">Sorry &#9785;</h2>
		<p class="center">Error: @faultSub</p>
	</div>
__WHOOPS
	htmlFooter($gentime);

}

sub prettyErrors {
	my ($error) = @{_};
	#Catch DB errors
	if ($error eq "ZERO_LENGTH_PARAM") {
		return "Search was of zero length, please enter a suitable search.";
	} elsif ($error eq "EMPTY_ID") {
		return "No ID was entered.";
	} elsif ($error eq "UNRECOGNIZED_ID") {
		return "Unknown ID.";
	} elsif ($error eq "NO_DB_CONNECTION") {
		return "The Database connection has failed. A trained team of monkeys have been dispached.";
	} elsif ($error eq "NO_DB_MATCHES") {
		return "No results can be found for your search.";
	} elsif ($error eq "DB_COLUMN_EMPTY") {
		return "There is no data (Database error).";
	} elsif ($error eq "INVALID_ID") {
		return "The ID entered was invalid.";
	} else {
		return "Unknown Error. $error";
	}	
}
