#! /usr/bin/perl -w
#
#	Script to serve JSON
#
use strict;
use JSON;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use Data::Dumper;#Debug
use lib 'Modules';
use GenJSON;

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
#Search
unless (defined ($selector)) {
	print GenJSON::error("No selector chosen");
} else {
	unless (defined ($query)) {
		print GenJSON::error("No query selected");
	} else {
		if ( $selector eq "search") {
			unless (defined ($type)) {
				print GenJSON::error("No type selected");
			} else {
				print GenJSON::testJSONSearch();
				#my $result = GenJSON::doSearch($query,$type);
			}
		} elsif ($selector eq "single") {
			print GenJSON::testJSONSingle();
		} else {
			print GenJSON::error("Invalid selector");
		}
	}
	
}
