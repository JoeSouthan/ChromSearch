#! /usr/bin/perl -w
#
#	Show individual gene result
#
use strict;
use SOAP::Lite;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use Time::HiRes qw ( time );
use lib 'Modules';
use CodonImager;

my $timestart = time();
my $cgi = new CGI;
my $soap = SOAP::Lite
				#The package to call
				->uri('ChromoDB')
				->proxy('http://joes-pi.dyndns.org/cgi-bin/Modules');
#	
#	Get the param from the link and find the relevant info
#	

my ($before, $gene)= 1;
my @values = split(/&/,$ENV{QUERY_STRING});
($before, $gene) = split(/=/, $values[0]);


#Search Statements
#my $showall = $soap->showAllIdentifiers($gene)->result;
#my $DNASeq = $soap->getDNAsequence($gene)->result;
#my $AASeq = $soap->getAAsequence($gene)->result;
#my @showCodingSeq = $soap->showCodingSeq($gene)->result;



#Dummy Data
#Avaliable Restiction Enzymes
#Would be a SOAP query
my $geneID 		= $gene;
my $accs 		= "FooBaR";
my $loc 		= "R457";
my $dnaSeq 		= "Bacon ipsum dolor sit amet bacon hamburger flank andouille, ham hock ham biltong chicken ground round beef ribs pork belly";
my $aaSeq 		= "pastrami pancetta jerky. Jerky tri-tip spare ribs tongue. Fatback shank ribeye ham t-bone filet mignon biltong sausage sirloin";
my $codeSeq		= "Something";

my @enzymes = ("EcoR1", "BamH1", "BsuMI");
my $pProduct = "Something, something else, something more";
my $codons = "UUU:0.1,UUC:0.2,UUA:0.3,UUG:0.4,CUU:0.5,CUC:0.6,CUA:0.7,CUG:0.8,AUU:0.9,AUC:1.0,AUA:0.1,AUG:0.2,GUU:0.3,GUC:0.4,GUA:0.5,GUG:0.6,";
my $image = CodonImager::CreateImage($codons);

#String to arrays

my @products = split (',', $pProduct);
my $timestop = time();
my $timegen = $timestop - $timestart;
#unless (defined ($gene)) {
#	print "Please specify a gene name";
#} else {
print $cgi->header();
print <<__EOF1;

<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<title>Results - Chromosome 12 Search Engine (Name subject to change - any ideas?)</title>
<link href="../css/style.css" rel="stylesheet" type="text/css">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js"></script>
<script language="javascript" type="text/javascript" src="../js/js.js"></script>
</head>

<body>
<div class="wrapper">
	<div class="header">
    	<h1>Single Result</h1>
    </div>
    <div class="searchform">
    	<h2 class="center">Single result for: <i>$geneID</i>.</h2>
        <div class="singleresult">
        	<div class="info">
            	<span>$geneID | Gene Accession: $accs | Location: $loc</span>
            </div>
            <div class="single-left">
            	<h2>Sequence Characteristics</h2>
                <p>Some text</p>
				<h2>Codon Usage<h2>
				<div class="center">
					<img src="$image" alt="Codon Usage"/>
					<img src="../img/bar.png" alt="Codon Usage" width="500px" height="30px" />
				</div>
                <h2>Common Restriction Sites</h2>

                <h3>EcoR1</h3>
                <p>Some Text</p>
                <h3>BamH1</h3>
                <h3>BsuMI</h3>
                <p>Would you like to <a href="#cutter" id="show4">cut your own?</a></p>
                <div id="cutter">
                <form method="post" action="enz_cutter.pl">
                	<input type="hidden" name="gene" value="$geneID" />
                	<input type="checkbox" name="enzyme" value="EcoRI"/>EcoR1 <br />
                	<input type="checkbox" name="enzyme" value="BsuMI"/>BsuMI <br />
                	<input type="checkbox" name="enzyme" value="Foo"/>Foo <br />
                	<input type="checkbox" name="enzyme" value="Bar"/>Bar <br />
                    <input type="text" width="100" name="custom" placeholder="Custom search" /> Use AA|AAAA to define your search<br />
					<input type="submit" value="Submit" /><input type="reset" value="Reset" />
                
                </form>
                
                
                
                </div>
            </div>
            <div class="single-right">
            	<h2>Protein Products</h2>
                <ul>
__EOF1

foreach my $pP (@products) {
                print "\t\t\t<li>$pP</li>\n";
}
print <<__EOF2;
                </ul>
                 
            </div>
            
            <div class="clearfix"></div>
            
            <div class="single-wide">
            	<h2>Sequences</h2>
            	<a href="#SequenceDNA" id="show1">Click to reveal DNA Sequence</a>
            	<div id="SequenceDNA">
					<span>$dnaSeq</span>
				</div>
                <br />
                <a href="#SequenceAA" id="show2">Click to reveal Translated Amino Acid Sequence</a>
                <div id="SequenceAA">
					<span>$aaSeq</span>
				</div>
				<br />
				<a href="#codonusage" id="show3">Codon usage</a>
				<div id="codonusage">
					<span>$codons</span>
				</div>
            </div>
        </div>
       
        <div class="footer">
        	<p>Results generated in $timegen second(s)</p>
        </div>
    </div>

</div>
</body>
</html>
__EOF2
