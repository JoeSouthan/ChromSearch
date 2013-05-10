#! /usr/bin/perl -w
#
#	json.pl - Serves generated JSON
#	Written by: Joseph Southan
#	Date: 		18/3/13
#	Email:		joseph@southanuk.co.uk
#	Usage: 		json.pl?selector=[selector]
#				Selectors:
#					GET:
#						"single" 	&query=[Accession]
#						"search"	&searchType=[Search Type]&query=[query]
#						"browse" 	&query=[A-Z]
#						"res" 		-
#							"GetRES"; 	&mode=GetRES
#					POST:
#						"res" 
#							"CalcRES";	&query=[sequence/Accession]
#	Requires:	CGI, CGI::Carp, GenJSON
#	Updated:	10/5/13
#
use strict;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use Data::Dumper;
use lib 'Modules';
use GenJSON;

my $cgi = new CGI;
my @params= $cgi->param();

my ($selector, $query,$type,$mode,$gene, $page);
foreach my $params (@params) {
	if ($params eq "query") {
		$query = $cgi->param($params);
	} elsif ($params eq "searchType") {
		$type = $cgi->param($params);
	} elsif ($params eq "selector") {
		$selector = $cgi->param($params);
	} elsif ($params eq "mode") {
		$mode = $cgi->param($params);
	} elsif ($params eq "gene") {
		$gene = $cgi->param($params);
	}  elsif ($params eq "page") {
		$page = $cgi->param($params);
	}
}


#Debug
	# $query = "AB002805";
	# $type = "ChromosomeLocation";
	# $selector = "res";
	# $mode = "CalcRES";
	# $gene = "EcoRI%2CBamHI";
	# %252C
	# $sequence = "AFAPFMPAMFPMAF";


#Print the JSON header
print $cgi->header('application/json');

#Time for logic!
#Search
unless (defined ($selector)) {
	print GenJSON::error("General: No selector chosen");
} else {
	# RES mode
	if ($selector eq "res") {
		unless (defined($mode)) {
			print GenJSON::error("RES: No mode selected");
		} else {
			if ($mode eq "GetRES") {
				print GenJSON::getRes();
			} elsif ($mode eq "CalcRES") {
				if (defined($gene)) {
					unless (4 <= length($query)) {
						print GenJSON::error("RES: Gene ID/Sequence length is too small");
					} else {
						print GenJSON::CalcRES($query, $gene);
					}
				} else {
					print GenJSON::error("RES: No sequence or Gene ID");
				}
			} else {
				print GenJSON::error("RES: Invalid Mode");
			}
		}
	# Search mode
	} elsif ($selector eq "single" or $selector eq "search" or $selector eq "browse") {
		unless (defined ($query)) {
			print GenJSON::error("Search: No query selected");
		} else {
			if ( $selector eq "search") {
				unless (defined ($type)) {
					print GenJSON::error("Search: No type selected");
				} else {
					print GenJSON::doSearch($query,$type);
				}
			} elsif ($selector eq "single") {
				print GenJSON::doSingle($query);
			} elsif ($selector eq "browse")  {
				print GenJSON::doBrowse($query);
			} else {
				print GenJSON::error("Search: Invalid selector");
			}
		}
	} else {
		print GenJSON::error("General: Invalid selector");
	}
}

