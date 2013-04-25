#! /usr/bin/perl -w
use lib 'Modules';
use CodonImager;
use Data::Dumper;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 

my $cgi = new CGI;
my @params= $cgi->param();



my ($download, $show, $gene) = (0, 0, "");
unless (@params){ 
	CodonImager::error();
} else {
	foreach my $params (@params) {
		if ($params eq "show" and $params eq "download") {
			CodonImager::error();
		} elsif ($params eq "download") {
			$download = 1;
		} elsif ($params eq "show") {
			$show = 1;
			#$type = $cgi->param($params);
		} elsif ($params eq "gene") {
			$gene = $cgi->param($params);
		} else {
			CodonImager::error();
		}
	}
}

#Debug
$gene = "UUU:0.1,UUC:0.2,UUA:0.3,UUG:0.4,CUU:0.5,CUC:0.6,CUA:0.7,CUG:0.8,AUU:0.9,AUC:1.0,AUA:0.1,AUG:0.2,GUU:0.3,GUC:0.4,GUA:0.5,GUG:0.6,";
# $show = 1;

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
