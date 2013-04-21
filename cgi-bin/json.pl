#! /usr/bin/perl -w
#
#	Script to serve JSON with logic to prevent wrong usage
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

my ($selector, $query,$type,$mode,$gene, $sequence, $page);
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
	} elsif ($params eq "sequence") {
		$sequence = $cgi->param($params);
	} elsif ($params eq "page") {
		$page = $cgi->param($params);
	}
}

sub fixGene {
	if ($query =~s/%2C/\,/g) {
		#Need logic for duplicates
	}
}

#Debug
	# $query = "q13";
	# $type = "ChromosomeLocation";
	# $selector = "res";
	# $mode = "CalcRES";
	# $gene = "EcoRI%252CBamHI";
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
					if (defined($sequence)){
						print GenJSON::error("RES: Please only use one of either gene or sequence");
					} else {
						unless (5 <= length($gene)) {
							print GenJSON::error("RES: Gene ID is too small");
						} else {
							fixGene();
							print GenJSON::CalcRES($query,$gene);
						}
					}
				} elsif (defined($sequence)) {
					if (defined($gene)){
						print GenJSON::error("RES: Please only use one of either gene or sequence");
					} else {
						fixGene();
						print GenJSON::CalcRES($query,$sequence);
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
				#print GenJSON::doBrowse($query,$type);
				#Temp
				print GenJSON::doSearch($query,$type);
			} else {
				print GenJSON::error("Search: Invalid selector");
			}
		}
	} elsif	($selector eq "help"){
		unless (defined($page)){
			print GenJSON::error("Help: No page") ;
		} else {
			print GenJSON::help($page);
		}
	} else {
		print GenJSON::error("General: Invalid selector");
	}
}

