#! /usr/bin/perl -w
use strict;
use SOAP::Lite;
use Data::Dumper;
my $soap = SOAP::Lite
				#The package to call
				->uri('ChromoDB')
				->proxy('http://c2:coursework123@joes-pi.dyndns.org/cgi-bin/proxy.pl');
				
my ($query, $type) = @ARGV;
 $query = "2780780";
 $type = "GeneID";

#print $query;
#print $type;
print my $returnSearch = $soap->getSearchResults($query,$type)->result;
print Dumper $returnSearch;
#print my $hello = $soap->showCodingSeq($query)->result;
