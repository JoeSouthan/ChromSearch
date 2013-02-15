#! /usr/bin/perl -w
use strict;

#use SOAP::Lite +trace=>'debug';
use SOAP::Lite;
use Data::Dumper;
my $soap = SOAP::Lite
				#The package to call
				->uri('ArrayTest')
				->proxy('http://joes-pi.dyndns.org/cgi-bin/proxy.pl');
				

my @result = $soap->Array()->paramsout;

#my $returnSearch = $result[1];

#print $returnSearch;

print Dumper @result;