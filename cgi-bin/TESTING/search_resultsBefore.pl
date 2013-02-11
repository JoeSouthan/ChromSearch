#! /usr/bin/perl -w
use strict;
use SOAP::Lite;
use CGI;
use Time::HiRes qw ( time );
my $timestart = time();
my $cgi = new CGI;
my @params= $cgi->param();
my $soap = SOAP::Lite
				#The package to call
				->uri('DBinterface')
				->proxy('http://joes-pi.dyndns.org/cgi-bin/search');
#Do search, Take post

#Declaring variables for search
my ($query, $type);

foreach my $params (@params) {
	if ($params eq "query") {
		$query = $cgi->param($params);
	} elsif ($params eq "searchType") {
		$type = $cgi->param($params);
	}
}



#Do Results				
	#Subroutine to call from the package

	#This is just me getting my thoughts together
	#Do search doesn't do anything... yet!
my $returnSearch = $soap 
			->getSearchResults($query,$type)
			->result;
#Debug


print $returnSearch;

#Parse the result to array
#my @resultArray = split ( ',', $returnSearch);
my @resultArray = ("One","Two","Three"); #DEBUG

my $timestop = time();
my $gentime = $timestop - $timestart;


#
#
#
#	Generate results
#	dummyresults.html
#
#
#
print $cgi->header();
print <<__EOF;
	<!DOCTYPE HTML>
	<html>
	<head>
	<meta charset="utf-8">
	<title>Results - Chromosome _ Search Engine (Name subject to change - any ideas?)</title>
	<link href="../css/style.css" rel="stylesheet" type="text/css">
	</head>

	<body>
	<div class="wrapper">
		<div class="header">
			<h1>Results</h1>
		</div>
		<div class="searchform">
		<h2 class="center">Results for: <i>$query</i>.</h2>
__EOF
#
#
#
unless (defined ($query)){
	print <<__WHOOPS;
	
	<div class="result>
		<h1 class="center">Something went wrong</div>
	</div>
	   
        <div class="footer">
        	<p>Results generated in $gentime second(s).</p>
        </div>
    </div>

</div>
</body>
</html>

__WHOOPS
}else {

#Loop it!
foreach my $results (@resultArray){
	print <<__EOF2;
	<div class="result">
        	<div class="genename">$results</div>
            <div class="diagram">
            	 Needs some sort of routine to draw this diagram
            </div>
            <div class="link"><a href="return_single.pl?gene=$results">More &raquo;</a></div>
    </div>
__EOF2
}
print <<__EOF3;
   
        <div class="footer">
        	<p>Results generated in $gentime second(s).</p>
        </div>
    </div>

</div>
</body>
</html>
__EOF3
}
