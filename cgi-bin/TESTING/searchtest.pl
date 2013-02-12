#! /usr/bin/perl -w
use strict;
use SOAP::Lite;
my $soap = SOAP::Lite
				#The package to call
				->uri('ChromoDB')
				->proxy('http://joes-pi.dyndns.org/cgi-bin/proxy.pl');
				
my ($query, $type) = @ARGV;

#print $query;
#print $type;
print my $returnSearch = $soap->getSearchResults($query,$type)->result;
print my $hello = $soap->showCodingSeq($query)->result;
