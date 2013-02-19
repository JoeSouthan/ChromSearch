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
my $soap = SOAP::Lite->uri('ChromoDB')->proxy('http://c2:coursework123@joes-pi.dyndns.org/cgi-bin/proxy.pl');

# When implimented:
# my @enzymes = $soap->getSupportedRES("Names")->paramsout;

#Get what gene they want to cut with
my $gene;
my @params= $cgi->param();
foreach my $params (@params) {
	if ($params eq "gene") {
		$gene = $cgi->param($params);
	}
}


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
<form method="post" action="enz_cutter.pl">
    <input type="hidden" name="gene" value="$gene" />
__HTML
foreach my $enz (@enzymes) {
	print "\t<input type=\"checkbox\" name=\"enzyme\" value=\"$enz\"/>$enz <br />\n";
}
print <<__FOOTER;
    <input type="text" width="100" name="custom" placeholder="Custom search" /> Use AA|AAAA to define your search<br />
	<input type="submit" value="Submit" /><input type="reset" value="Reset" />
                
    </form>
</body>
</html>
__FOOTER
