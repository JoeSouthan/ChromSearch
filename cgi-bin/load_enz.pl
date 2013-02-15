#! /usr/bin/perl -w
#
#	Display all the restriction enzymes
#
use strict;
use SOAP::Lite;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use Time::HiRes qw ( time );

my $cgi = new CGI;
my $soap = SOAP::Lite->uri('ChromoDB')->proxy('http://joes-pi.dyndns.org/cgi-bin/Modules');

# When implimented:
# my @enzymes = $soap->getSupportedRES("Names")->paramsout;

#Debug
my @enzymes = qw (EcoRI BamFI BsuMI);


# Output HTML
print $cgi->header();
print <<__HTML;
<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<title>Avaliable Enzymes</title>
<link href="../css/style.css" rel="stylesheet" type="text/css">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
<script language="javascript" type="text/javascript" src="../js/js.js"></script>
</head>
<body>
__HTML
foreach my $enz (@enzymes) {
	print "<input type=\"checkbox\" name=\"enzyme\" value=\"$enz\"/>$enz <br />\n";
}
print <<__FOOTER;
</body>
</html>
__FOOTER
