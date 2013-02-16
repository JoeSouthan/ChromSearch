#! /usr/bin/perl -w
use strict;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use SOAP::Lite;
use Time::HiRes qw ( time );
use Data::Dumper;#Debug

#Define the usual
my $cgi = new CGI;
my $soap = SOAP::Lite
				->uri('ChromoDB')
				->proxy('http://joes-pi.dyndns.org/cgi-bin/Modules');
my $time = time();

#Find what enzymes they want  - POST
my ($custom, @enzymes, $gene,$query);
my @params= $cgi->param();

#Sort the POST
foreach my $params (@params) {
	if ($params eq "custom") {
		$custom = $cgi->param($params);
	} elsif ($params eq "enzyme") {
		@enzymes = $cgi->param('enzyme');
	} elsif ($params eq "gene") {
		$gene = $cgi->param($params);
	}
		
}

#Expecting Data as Name:XX|XXXX, NOT READY
#Join up the enzymes requested and request the sequence cuts
#my $requestedEnzymes = join(',' , @enzymes);
#my $requestEnz = $soap->getSupportedRes($requestedEnzymes)->result;
#Split result to hash
#my %enzymeHash = split /[:,]/, $requestEnz;

#Debug
my $enzymes = "BamHI:G|GATCC,EcoRI:G|AATTC,TaqI:T|CGA,";
my %enzymeHash = split /[:,]/, $enzymes;

#Request the Sequence
#SOAP is a go!
#my $sequence = $soap->getDNAsequence($gene)->result;

#Debug
my $sequence = "GTGGCGCAGGCAGGTTTTATCTTAACCCGACACTGGCGGGACACCCCGCAAGGGACAGAAGTCTCCTTCTGGCTGGCGACGGACAACGGGCCGTTGCAGGTTACGCTTGCACCGCAAGAGTCCGTGGCGTTTATTCCCGCCGATCAGGTTCCCCGCGCTCAGCATATTTTGCAGGGTGAACAAGGCTTTCGCCTGACACCGCTGGCGTTAAAGGATTTTCACCGCCAGCCGGTGTATGGCCTTTACTGTCGCGCCCATCGCCAATTGATGAATTACGAAAAGCGCCTGCGTGAAGGTGGCGTTACCGTCTACGAGGCCGATGTGCGTCCGCCAGAACGCTATCTGATGGAGCGGTTTATCACCTCACCGGTGTGGGTCGAGGGTGATATGCACAATGGCACTATCGTTAATGCCCGTCTGAAACCGCATCCCGACTATCGTCCGCCGCTCAAGTGGGTTTCTATAGATATTGAAACCACCCGCCACGGTGAGCTGTACTGCATCGGCCTGGAAGGCTGCGGGCAGCGCATCGTTTATATGTGGGGCCGGAGAATGGCGACGCCTCCTCGCTTGATTTCGAACTGGAATACGTCGCCAGCCGCCCGCAGTTGCTGGAAAAACTCAACGCCTGGTTTGCCAACTACGATCCTGATGTGATCATCGGTTGGAACGTGGTGCAGTTCGATCTGCGAATGCTGCAAAAACATGCCGAGCGTTACCGTCTTCCGCTGCGTCTTGGGCGCGATAATAGCGAGCTGGAGTGGCGCGAGCACGGCTTTAAAAACGGCGTCTTTTTTGCCCAGGCTAAAGGTCGGCTAATTATCGACGGTATCGAGGCGCTGAAATCCGCGTTCTGGAATTTCTCTTCATTCTCGCTGGAAACTGTCGCTCAGGAGCTATTAGGCGAAGGAAAATCTATCGATAACCCGTGGGATCGAATGGACGAAATTGACCGCCGT";


#
#
#	Output HTML
#
#
print $cgi->header();
print <<__HTML;
<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<title>Results - Chromosome _ Search Engine (Name subject to change - any ideas?)</title>
<link href="css/style.css" rel="stylesheet" type="text/css">
</head>

<body>
<div class="wrapper">
	<div class="header">
    	<h1>Results</h1>
    </div>
    <div class="searchform">
    	<h2 class="center">Enzymatic Cleavage results for: <i>$gene</i>.</h2>
        <div class="singleresult">
                <div class="single-wide">
                <div class="enzyme-result">
__HTML

if (defined ($custom) > 0) {
	print <<__CUSTOM;
                   		<h2>Your Custom Sequence</h2>
                        <h3>ATGCTGCA|TCATCG</h3>
                        <div class="sequence">
                        	<pre>ATGC<span class="green underline">TGCA</span>    ATCATCG</pre>
                            <pre>TACG    <span class="red overline">ACGT</span>TAGTAGC</pre>
                        </div>
__CUSTOM
}
print "\t\t\t<h2>Other Sequences</h2>\n";

#Process the sequence
#Avert your eyes if you like nice looking code
for my $enz (sort keys %enzymeHash) {
	my $cutseq = $enzymeHash{$enz};
	#Remove the |
	$cutseq =~ s/[|]// ;
	#Do the cut
	my $count = 0;
	print "\t\t\t<h3>$enz</h3>\n\t\t\t<div class=\"sequence\">\n";
	while ($sequence =~ /(..)($cutseq)(..)/g){
		print "\t\t\t\t<p>Cuts at $-[0] $+[0]</p>\n";
		print "\t\t\t\t<pre>$1<span class=\"green\">$2</span>$3</pre>\n";
		$count++;

	}
	#Check for no cuts
	if ($count == 0) {
		print "\t\t\t\t<p>No matches</p>\n";
	} else {
		print "\t\t\t\t<p>There were $count cuts</p>\n";
	}
	print "\t\t\t</div>\n";
}
my $stoptime = time();
my $gentime = $stoptime -$time;
#Print the footer
print <<__RESULTS;
                 </div>
                <div id="SequenceDNA">
					<pre>$sequence</pre>
                </div>

                
                </div>
            </div>
        </div>
       
        <div class="footer">
        	<p>Results generated in $gentime second(s).</p>
        </div>
    </div>

</div>
</body>
</html>
__RESULTS
