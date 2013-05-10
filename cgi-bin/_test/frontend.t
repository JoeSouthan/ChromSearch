#! /usr/bin/perl -w
#
#	enz_cutter.pl - Cuts a sequence
#	Written by: Joseph Southan
#	Date: 		6/2/13
#	Email:		joseph@southanuk.co.uk
#	Usage: 		None
#	Requires:	GenJSON, WebHTML, EnzCutter, GenJSON, JSON, Test::Simple
#	Updated:	6/5/13
#
use strict;
use JSON;

use lib '../Modules';
use GenJSON;
use CodonImager;
use WebHTML;
use EnzCutter;
use Data::Dumper;
use Test::Simple tests => 1;


#GenJSON tests

my $enzymes = "EcoRI,BamHI,BsuMI";
#doSearch doSingle doBrowse getRES CalcRES error
print "GenJSON Tests \n";
GenJSON_t_doSearch();
GenJSON_t_doSingle();
GenJSON_t_doBrowse();
GenJSON_t_EnzCutter();
sub GenJSON_t_doSearch {
	my $json = new JSON;
	my $result = GenJSON::doSearch("AF164120","AccessionNumber");
	my $json_decode = $json->decode($result);

	print "\ndoSearch - Expected\n\n";
		ok (ref($json_decode->{AF164120}) eq "HASH", "Hash returned" );
		ok ($json_decode->{AF164120}->{GeneName} eq "5726484", "GeneName - 5726484" );
		ok ($json_decode->{AF164120}->{GeneLength} eq "345", "GeneLength - 345" );
		ok ($json_decode->{AF164120}->{ChromosomeLocation} eq "12q24.2", "ChromosomeLocation - 12q24.2" );
		ok ($json_decode->{AF164120}->{ProteinId} eq "AAD48447.1", "ProteinId - AAD48447.1" );
		ok (ref($json_decode->{AF164120}->{SeqFeat}) eq "ARRAY", "SeqFeat - Valid Array" );
		ok ($json_decode->{AF164120}->{ProteinName} eq "mitochondrial aldehyde dehydrogenase 2", "ProteinName - \"mitochondrial aldehyde dehydrogenase 2\"" );

	print "\ndoSearch - Bad tests\n\n";
		my $result_fail = GenJSON::doSearch("AF164120", "GeneId");
		my $json_decode_fail = $json->decode($result_fail);
		ok ($json_decode_fail->{error} eq "ERROR:UNRECOGNIZED_ID", "Bad id \"GeneID\" passed, error returned");
		my $result_fail_1 = GenJSON::doSearch();
		my $json_decode_fail_1 = $json->decode($result_fail_1);
		ok ($json_decode_fail_1->{error} eq "Search: Parameters missing", "Bad Parameters");
	print "####\n";
}
sub GenJSON_t_doSingle {
	my $json = new JSON;
	my $result = GenJSON::doSingle("AF164120");
	my $json_decode = $json->decode($result);

	print "\ndoSingle - Expected\n\n";
		ok(ref($json_decode->{AF164120}->{CodonUsage}) eq "HASH", "CodonUsage - Hash obtained");
		ok(ref($json_decode->{AF164120}->{DNASeqFASTA}) eq "ARRAY", "DNASeqFASTA - Array obtained");
		ok(ref($json_decode->{AF164120}->{AASeqFASTA}) eq "ARRAY", "AASeqFASTA - Array obtained");
		ok($json_decode->{AF164120}->{AASeqFASTA}[0] eq ">gi|5726484|gb|AAD48447.1|mitochondrial aldehyde dehydrogenase 2", "Correct AASeqFASTA format");
		ok($json_decode->{AF164120}->{DNASeqFASTA}[0] eq ">gi|5726484|gb|AAD48447.1|mitochondrial aldehyde dehydrogenase 2", "Correct DNASeqFASTA format");
}

sub GenJSON_t_doBrowse {
	my $json = new JSON;
	my %result = GenJSON::doBrowse("a");
	my $number_results = keys(%result);
#	my $json_decode = $json->decode($result);
	print $number_results;
}
sub GenJSON_t_EnzCutter {
	print Dumper EnzCutter::doCut("ATTTT", "AA|AA");
	print Dumper EnzCutter::doCut("ATTTT", "|AAAA");
	print Dumper EnzCutter::doCut("ATTTT", "at|Ta");
	print Dumper EnzCutter::doCut("ATTTT", "A|TT");
}
	print Dumper GenJSON::Sanitise("Te\$\$st\|\"\'\.\,\$\£");
