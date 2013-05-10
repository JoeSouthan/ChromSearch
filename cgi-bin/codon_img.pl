#! /usr/bin/perl -w
#
#   codon_img.pl - Serves an image of codon usage
#   Written by: Joseph Southan
#   Date:       5/2/13
#   Email:      joseph@southanuk.co.uk
#   Usage:      codon_img.pl?&gene=[Accession]&(download/show=true)
#   Requires:   CodonImager, CGI, CGI::Carp
#   Updated:    10/5/13
#
use strict;
use lib 'Modules';
use CodonImager;
use Data::Dumper;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 

my $cgi = new CGI;
my @params= $cgi->param();



my ($download, $show, $gene) = (0, 0, "");
unless (@params){ 
    #Throw an error
    CodonImager::error();
} else {
    foreach my $params (@params) {
        if ($params eq "show" and $params eq "download") {
            CodonImager::error();
        } elsif ($params eq "download") {
            $download = 1;
        } elsif ($params eq "show") {
            $show = 1;
        } elsif ($params eq "gene") {
            $gene = Sanitise($cgi->param($params));
        } else {
            CodonImager::error();
        }
    }
}

#Debug
#$gene = "UUU:0.1,UUC:0.2,UUA:0.3,UUG:0.4,CUU:0.5,CUC:0.6,CUA:0.7,CUG:0.8,AUU:0.9,AUC:1.0,AUA:0.1,AUG:0.2,GUU:0.3,GUC:0.4,GUA:0.5,GUG:0.6,";
#$gene = "AB002805";
# $show = 1;

#Output the Image
if (defined($download) and $download == 1){
    if (length($gene) > 1){
        CodonImager::downloadImg($gene);
    } else {
        CodonImager::error();
    }
} elsif (defined($show) and $show == 1) {
    if (length($gene) > 1){
        CodonImager::displayImg($gene);
    } else {
        CodonImager::error();
    }
}
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
