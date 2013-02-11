#!/usr/bin/perl

use SOAP::Lite;

my $name = shift;

print "\nCalling the SOAP server...\n";
print "The SOAP server says:\n";
$s = SOAP::Lite
    ->uri('urn:hello')
    ->proxy('http://joes-pi.dyndns.org/cgi-bin/proxy.pl');

print $s->sayHello($name)->result;
print "\n\n";
