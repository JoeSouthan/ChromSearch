#! /usr/bin/perl -w
use strict;
use SOAP::Lite;
#my $soap = SOAP::Lite
#				->uri('urn:hello')
#				->proxy('http://joes-pi.dyndns.org/cgi-bin/proxy.pl');
my $soap = SOAP::Lite
    ->uri('TestDB')
    ->proxy('http://joes-pi.dyndns.org/cgi-bin/proxy.pl');
my ($query, $type) = @ARGV;

#print $query;
#print $type;

#my $result = $soap->doconnect->result;
 
#print my $returnSearch = $soap
	#->getSearchResults("TEST1234","GeneID")
	#->result;
#print my $dohello = $soap->sayHello($query)->result;
my $result = $soap->doconnect->result;
#my $result= $soap->doreflect($query)->result;

print $result;