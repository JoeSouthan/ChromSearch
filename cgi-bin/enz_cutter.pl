#! /usr/bin/perl -w
#
#   enz_cutter.pl - Cuts a sequence
#   Written by: Joseph Southan
#   Date:       6/2/13
#   Email:      joseph@southanuk.co.uk
#   Usage:      enz_cutter.pl?(gene=[Accession Number]&enzymes=[Comma separated list])
#   Requires:   CGI, CGI::Carp, WebHTML
#   Updated:    10/5/13
#
use strict;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use Data::Dumper;
use lib 'Modules';
use WebHTML;

#Define the usual
my $cgi = new CGI;

#Find what enzymes they want  - POST
my ($gene, @enzymes, $mode);
my @params= $cgi->param();

#Sort the POST
foreach my $params (@params) {
    if ($params eq "gene") {
        $gene = $cgi->param($params);
    } elsif ($params eq "enzymes") {
        @enzymes = $cgi->param('enzymes');
    }       
}
#Join up the enzymes
my $enzymes_joined = join(",", @enzymes);

my $showForm = 0;
unless (defined ($gene)) {
    #Show the box and enzymes
    ($gene, $enzymes_joined, $mode) = (0, 0, 0);
} else {
    unless (@enzymes) {
        # Show just the ezymes
        $mode = 1;
    } else {
        #Do the cuts and display
        $mode = 2;
    }
}
#Output the HTML
outputEnzCutter($gene, $enzymes_joined, $mode, $cgi);