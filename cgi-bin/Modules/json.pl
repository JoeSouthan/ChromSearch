#! /usr/bin/perl -w
#
#	Script to serve JSON
#
use strict;
use JSON;
use GenJSON;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use Data::Dumper;#Debug
my $cgi = new CGI;
my $json = JSON->new;
my @params= $cgi->param();

my ($selector, $query,$type);
# json.pl?selector=(search/single)&$query=(query)&type=(searchType)
foreach my $params (@params) {
	if ($params eq "query") {
		$query = $cgi->param($params);
	} elsif ($params eq "searchType") {
		$type = $cgi->param($params);
	} elsif ($params eq "selector") {
		$selector = $cgi->param($params);
	} 
}


#Debug
# $query = "2780780";
# $type = "GeneID";
# $selector = "search";


#Print the JSON header
print $cgi->header('application/json');

#Time for logic!
unless (defined ($selector) or defined ($query) or defined ($selector) or defined ($type)) {
	print GenJSON::error();
} else {
	#User wants a search
	if ( $selector eq "search") {
		print GenJSON::testJSONSearch();
		#my $result = GenJSON::doSearch($query,$type);
	#User Wants a single gene
	} elsif ($selector eq "single") {
		print GenJSON::testJSONSingle();
	#Catch all
	} else {
		print GenJSON::error();
	}

}
