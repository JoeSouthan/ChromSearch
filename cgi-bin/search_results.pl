#! /usr/bin/perl -w
#
#   search_results.pl - Serves the results of a search
#   Written by: Joseph Southan
#   Date:       31/1/13
#   Email:      joseph@southanuk.co.uk
#   Usage:      search_results.pl?&search=[search/browse]&query=[query/A-Z](&type=[search type])
#   Requires:   CGI, CGI::Carp, ChromoDB, WebHTML
#   Updated:    2/5/13
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
my ($query, $type, $mode, $selection, $switch, %results);

#Take the Params from the GET
foreach my $params (@params) {
    if ($params eq "query") {
        $query = Sanitise($cgi->param($params));
    } elsif ($params eq "searchType") {
        $type = Sanitise($cgi->param($params));
    } elsif ($params eq "search") {
        $mode = Sanitise($cgi->param($params));
    } elsif ($params eq "selection") {
        $selection = Sanitise($cgi->param($params));
    }
}

#Do the search
#Debug
    # $query = "q13";
    # $type = "ChromosomeLocation";
    # $mode = "search";

unless (defined($mode)) {
    $mode = "error";
    $results{"error"} = "Mode isn't defined";
} else {
    if ($mode eq "browse") {
        unless (defined($selection)){
            $mode = "error";
            $results{"error"} = "Selection wasn't defined";
        } else {
            $query = $selection;
            $type = "AccessionNumber";
            $switch = 1;
            %results = ChromoDB::GetSearchResults ($query, $type, $switch);
        }
    } elsif ($mode eq "search") {
        unless (defined($query)) {
            $mode = "error";
            $results{"error"} = "No query";
        } else {
            $switch = 0;
            %results = ChromoDB::GetSearchResults ($query, $type, $switch);
        }
    } else {
        $mode = "error";
        $results{"error"} = "Wrong Mode flag";
    }
}

#Hash reference
my $resultRef = \%results;

#Output HTML
outputSearchHTML($resultRef, $cgi, $query, $mode);

###############################################################################################################################
#   Function:       Sanitise                                                                                                  #
#   Description:    Removes unwanted characters                                                                               #
#   Usage:          Sanitise([String])                                                                                        #
#   Returns:        String                                                                                                    #
########################################################################################################################################################
sub Sanitise {
    my $input = $_[0];
    $input =~ s/[^a-zA-Z0-9\|\.\"\,\']//g;
    return $input;
}
