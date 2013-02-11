#! /usr/bin/perl -w
use strict;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use SOAP::Lite;
#use Bio::Restriction::EnzymeCollection; 
#use Bio::Restriction::Analysis;#Should we use this?
#use Bio::PrimarySeq;
#use Data::Dumper;#Debug

#Define the usual
my $cgi = new CGI;
my $soap = SOAP::Lite
				->uri('ChromoDB')
				->proxy('http://joes-pi.dyndns.org/cgi-bin/Modules');


#Find what enzymes they want  - POST
my ($custom, @enzymes, $gene,$query,@fragments);
my @params= $cgi->param();

#Debug

#$query = "something";
#$gene = $ARGV[0];

foreach my $params (@params) {
	if ($params eq "custom") {
		$query = $cgi->param($params);
	} elsif ($params eq "enzyme") {
		@enzymes = $cgi->param('enzyme');
	} elsif ($params eq "gene") {
		$gene = $cgi->param($params);
	}
		
}

#@enzymes = qw( BamFI EcoRI EcoRII TaqI);

#Fetch the restriction sites for each enzyme
my @restrictionSites;
foreach my $enzyme (@enzymes) {
	}


#SOAP is a go!
#my $sequence = $soap->getDNAsequence($gene)->result;
my $sequence = "GTGGCGCAGGCAGGTTTTATCTTAACCCGACACTGGCGGGACACCCCGCAAGGGACAGAAGTCTCCTTCTGGCTGGCGACGGACAACGGGCCGTTGCAGGTTACGCTTGCACCGCAAGAGTCCGTGGCGTTTATTCCCGCCGATCAGGTTCCCCGCGCTCAGCATATTTTGCAGGGTGAACAAGGCTTTCGCCTGACACCGCTGGCGTTAAAGGATTTTCACCGCCAGCCGGTGTATGGCCTTTACTGTCGCGCCCATCGCCAATTGATGAATTACGAAAAGCGCCTGCGTGAAGGTGGCGTTACCGTCTACGAGGCCGATGTGCGTCCGCCAGAACGCTATCTGATGGAGCGGTTTATCACCTCACCGGTGTGGGTCGAGGGTGATATGCACAATGGCACTATCGTTAATGCCCGTCTGAAACCGCATCCCGACTATCGTCCGCCGCTCAAGTGGGTTTCTATAGATATTGAAACCACCCGCCACGGTGAGCTGTACTGCATCGGCCTGGAAGGCTGCGGGCAGCGCATCGTTTATATGTGGGGCCGGAGAATGGCGACGCCTCCTCGCTTGATTTCGAACTGGAATACGTCGCCAGCCGCCCGCAGTTGCTGGAAAAACTCAACGCCTGGTTTGCCAACTACGATCCTGATGTGATCATCGGTTGGAACGTGGTGCAGTTCGATCTGCGAATGCTGCAAAAACATGCCGAGCGTTACCGTCTTCCGCTGCGTCTTGGGCGCGATAATAGCGAGCTGGAGTGGCGCGAGCACGGCTTTAAAAACGGCGTCTTTTTTGCCCAGGCTAAAGGTCGGCTAATTATCGACGGTATCGAGGCGCTGAAATCCGCGTTCTGGAATTTCTCTTCATTCTCGCTGGAAACTGTCGCTCAGGAGCTATTAGGCGAAGGAAAATCTATCGATAACCCGTGGGATCGAATGGACGAAATTGACCGCCGT";


#Do the cut
# my $all_collection = Bio::Restriction::EnzymeCollection->new();
# my $seq = Bio::PrimarySeq->new
      # (-seq =>"$sequence",
       # -primary_id => 'synopsis',
       # -molecule => 'dna');
# my $ra = Bio::Restriction::Analysis->new(-seq=>$seq);
# my $all_cutters = $ra->cutters;

 # my @gel;
 
# foreach my $enzyme (@enzymes) {
	# print $enzyme;
  # my @bam_maps = $ra->fragment_maps("$enzyme");
  # print @bam_maps;
  # foreach my $i (@bam_maps) {
     # my $start = $i->{start};
     # my $end = $i->{end};
     # my $sequence = $i->{seq};
 ##   push @gel, "$start--$sequence--$end";
	# push @gel, "--$sequence--";
     # @gel = sort {length $b <=> length $a} @gel;
   # }
   # print join("\n", @gel) . "\n";
#print Dumper(@bam_maps);
# }



print $cgi->header();
print <<__HTML;
<!DOCTYPE HTML>
<html>
<head>
	<meta charset="utf-8">
	<title>Results - Chromosome 12 Search Engine (Name subject to change - any ideas?)</title>
	<link href="../css/style.css" rel="stylesheet" type="text/css">
</head>

<body>
	<div class="wrapper">
		<div class="header">
			<h1>Results</h1>
		</div>
		<div class="searchform">
		<div class="result">
		<p>custom query = $gene $query </p>
__HTML

foreach my $choices (@enzymes) {
	print $choices;
}


print <<__HTML2
		</div>
        <div class="footer">
        	<p>Results generated in second(s).</p>
        </div>
    </div>

</div>
</body>
</html>
__HTML2
