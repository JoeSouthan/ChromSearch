#! /usr/bin/perl -w
package WebHTML;
use HelpText;
use strict;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw (htmlHeader htmlOut htmlFooter htmlError prettyErrors);

#=============================
#	Main HTML Output
#		For a successful search, output the HTML
#		Takes 
#			[0] = Hash reference - String
#			[1] = CGI header - String
#			[2] = The Query - String
#			[3] = Generation time - String
#			[4] = Page count - Interger
#			[5] = pageNumber - Interger
#=============================
sub htmlOut {

	#Gotta Catch 'em all
	my ($resultRef, $cgi, $query, $gentime, $pagecount, $pageNumber, $resultCount, $type, $perpage) = @_;
	#my @resultArray = @{$resultArrayRef};
	my %resultHash = %{$resultRef};
	my $hashLength = scalar keys %resultHash;
	my $counter = 0;

	#Print HTML
	#htmlHeader($cgi,$resultRef);
	print "<h2 class=\"center\">$resultCount Result(s) for: <i>$query</i>.</h2>";
	#Loop it!

	for my $genes (sort keys %resultHash){
		#print "$genes: @{$resultHash{$genes}} ";
		print <<__EOF2;
		<div class="result">
				<div class="genename">$genes</div>
				<div class="diagram" id="chart_div$counter">
				</div>
				<div class="link"><a href="return_single.pl?gene=$genes">More &raquo;</a></div>
		</div>
__EOF2
		$counter++;
	}
	if ($pagecount > 1) {
		for (my $i = 0 ; $i < $pagecount; $i++) {
			if ($i == $pageNumber) {
				print "<span>[$i]</span>";
			} else {
			print "<span><a href=\"?page=$i&searchType=$type&query=$query&perpage=$perpage\">[$i]</a></span>";
			}
		}
		print "\t\t</p>\n";
	}
	htmlFooter($gentime);
}

#=============================
#	HTML Header
#		Provides the header for the output page
#		Takes:
#			[0] = CGI header - String
#			(1) = Optional; if the page contains a gene layout barchart, send the result hash reference over - String
#			(1) = If you pass a string, it will generate JS for loading ajax page on return_single
#=============================
sub htmlHeader {
	print $_[0]->header();
	print <<__EOF;
<!DOCTYPE HTML>
<html>
<head>
	<meta charset="utf-8">
	<title>Results - Chromosome 12 Search Engine (Name subject to change - any ideas?)</title>
	<link href="../css/style.css" rel="stylesheet" type="text/css">
	<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
	<script language="javascript" type="text/javascript" src="../js/js.js"></script>
</head>

	<body>
	<div id="help">
	<a id="closepopup">x</a>
	<div class="float-left">
__EOF
		&helpTextError();
print <<__NAVPRINT
	</div>
</div>
<div id="overlay"></div>
		<div class="wrapper">

			<div class="header">
				<h1>Results</h1>
			        <span class="subheader">Chromosome 12 Analysis Tool</span>
        <div class="navbar">
			<div class="item">
				<a href="../index.html">Home</a>
			</div>
			<div class="item">
				<a href="enz_cutter.pl">EnzCutter</a>
			</div>
			<div class="item">
				<a href="#" id="showhelp">Help</a>
			</div>
			<div class="item">
				<a href="#">Contact </a>
			</div>
        </div>
			</div>
			<div class="searchform">
__NAVPRINT
}
#=============================
#	HTML Footer
#		Prints the Footer
#		Takes:
#		[0] Gentime
#=============================
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

#=============================
#	HTML Errors
#		Takes an array reference or string and outputs an error page
#		Takes:
#		
#=============================

sub htmlError {
	my ($cgi, $gentime,@faultSub) = @_;
	if (ref($_[2]) eq "ARRAY") {
		@faultSub = @{$_[2]};
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
	#Print the Footer
	htmlFooter($gentime);

}
#=============================
#	Nice errors
#		Turns ugly errors, into nice errors!
#=============================
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

1;