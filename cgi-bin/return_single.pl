#! /usr/bin/perl -w
#
#   return_single.pl - Returns a single result
#   Written by: Joseph Southan
#   Date:       24/1/13
#   Email:      joseph@southanuk.co.uk
#   Usage:      return_single?gene=[accession]
#   Requires:   CGI, CGI::Carp, ChromoDB, WebHTML
#   Updated:    10/5/13
#
use strict;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use lib 'Modules';
use ChromoDB;
use WebHTML;
my $cgi = new CGI;
my @params= $cgi->param();

#Do search, Take post
#Declaring variables for search
my ($gene, %results);

#Take the Params from the GET
foreach my $params (@params) {
    if ($params eq "gene") {
        $gene = $cgi->param($params);
    } 
}

my ($type, $mode) = ("AccessionNumber", 2);

#Debug
#   $gene = "AY114088";

unless (defined($gene)) {
    $results{"error"} = "No accession number";
} else {
    %results = ChromoDB::GetSearchResults ($gene, $type, $mode);
}

my $resultRef = \%results;
outputSingleHTML($resultRef, $cgi, $gene);