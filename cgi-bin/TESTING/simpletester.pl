#! /usr/bin/perl -w
use strict;
use SOAP::Lite;

my $soap = SOAP::Lite->uri('ChromoDB')->proxy('http://joes-pi.dyndns.org/cgi-bin/proxy.pl');
my $soap2 = SOAP::Lite->uri('hello')->proxy('http://joes-pi.dyndns.org/cgi-bin/proxy.pl');
				
my $query = <>;
my $geneid = "GeneID";
my $result= $soap->getSearchResults($query, $geneid)->result;
my $result2 = $soap2->sayHello($query)->result;
print $result;
print $result2;